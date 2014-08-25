--[[
                  LLLP = Lojban Lua LPeg

                    (Version = alpha 8)

             by veion (veijo.vilva@gmail.com)


           CAUTION: THIS IS JUST AN ALPHA VERSION

    RELEASED FOR PRELIMINARY EXPERIMENTATION AND FEEDBACK


    An experimental driver pgm for the LPeg version of the Lojban PEG


 Requirements:

     lua5.1 or luajit2 and LPeg library (either built-in or external

 Luajit doesn't seem to offer any benefit for the PEG but makes a difference
 in auxiliary operations. However, for smaller texts the difference is quite
 negligible.

 NB. LPeg doesn't employ Packrat methodology having been designed for pattern
     matching rather than for parsing. This means that this parser version
     handles complex words relatively or even abysmally slowly!

  lua    : http://www.lua.org
  luajit : http://luajit.org
  LPeg   : http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
           http://www.inf.puc-rio.br/~roberto/docs/peg.pdf (theoretical basis)
 
  Running:

     lua lllp.lua lojban_file_name  (or luajit instead of lua)


  NB. presently the output goes to STDOUT and can be re-directed as required

  NB. the output parameters can be set by editing lllp_params.lua

  NB. input text is sliced at blank lines and handled block by block. This
      means that terminated structures mustn't span blank lines!
      
  NB. punctuation handling is still deficient (this is an alpha version)

  Lua commenting conventions can be used within the Lojban files:

--]]

--    --   two or more adjacent dashes mark the rest of line as comment
--    --[[ starts a multi-line comment ending at --]] or EOF
--         A space between -- and [[ can be used to de-activate the commenting



version = "alpha 9 / July 8, 2012" --- !!!!!!!!!!!!!!!

-- load required modules

local l    = require"lpeg"            -- LPeg library module

local m    = require"lllp_morphology" -- Lojban morphology LPeg

local p    = require"lllp_syntax_r"   -- Lojban syntax LPeg
                                       -- this is a reduced output version
                                       -- for full output change _r to _f

local x    = require"lllp_lujvo_splitter" -- lujvo splitting LPeg

-- Lojban LPeg matching functions

local morphed = m.morphed
local parse   = p.parse
local lsplit  = x.split

-- shortcuts for some lua standard functions

local ins    = table.insert
local concat = table.concat
local sort   = table.sort
local find   = string.find
local len    = string.len
local sub    = string.sub
local gsub   = string.gsub
local match  = string.match
local gmatch = string.gmatch
local format = string.format
local upper  = string.upper
local lower  = string.lower
local max    = math.max
local floor  = math.floor

local create = coroutine.create
local yield  = coroutine.yield
local resume = coroutine.resume

-- set max stack depth for LPeg

l.setmaxstack(2000)


io.stderr:write("\n  Lua/LPeg Lojban Parser (",version,")\n\n")
io.stderr:write("    Morphology LPeg (",m.version(),")\n")
io.stderr:write("    Parser LPeg     (",p.version(),")\n")

-- define input file and try to open it for reading

local lojban_file = arg[1]

if not lojban_file then
  io.stderr:write("\nUsage: lua lojban_lpeg lojban_file_name\n\n")
  return
  end

local ff,err = io.open(lojban_file,"r")

if not ff then
  io.stderr:write("\n  !!! ",err,'\n')
  return
  end

local pf = io.open("lllp_params.lua")   -- try to open user parameter file
local par = {}

if pf then                               -- if successful then
  local pp = loadstring(pf:read"*a")
  pf:close()
  if not pp then                         -- compilation failed
    io.stderr:write("\n !!! lua syntax error in lllp_params.lua\n")
    return
    end
  local p = pp()   -- try to load parameters
  if p then par = p end                 -- if OK then use them
  end

function get_par(n)
  if n == false then
    return false
  else
    return true
    end
end

decode_rafsi = get_par(par.decode_rafsi) -- try to decode rafsi
do_stats     = get_par(par.do_stats)   -- gather statistics

if decode_rafsi then
  local rf = io.open("lllp_r2g.lua") -- try to open the rafsi table file
  if rf then                         -- if successful
    loadstring(rf:read"*a")()         -- try to compile the table definition
    end
  decode_rafsi = type(r2g) == "table" -- check success
  end

-- set output

local output,err

if type(par.out) == "string" then      -- is a file name given
  output,err = io.open(par.out,"w")    -- try to open for writing
  if not output then                   -- if not successful
    io.stderr:write('\n',err,'\n\n')   
    return                             -- terminate the pgm
    end
elseif par.out ~= io.stdout then       -- no name and not STDOUT
  io.stderr:write("\n*** ERROR: strange value set for par.out ***\n\n")
  return                                -- terminate the pgm
  end
if not output then output = io.stdout end  -- use default == STDOUT

-- create a reader

local reader = create(
  function(f)
    local outnb = true  -- block number title switch
    local nb    = 0     --  block number
    local block = {}    -- block contents
    local skip  = false -- long comment skip
    local ccnt  = 0     -- nested long comment count
    local b,e
    for line in f:lines() do
      local skip_next = false
      if len(line) > 0 and find(line,"%S") then        -- comment handling
        if skip then
          b,e = find(line,"%]%]")
          if b then
            ccnt = ccnt - 1
            if ccnt == 0 then
              skip = false
              line = sub(line,e+1)
              end
          elseif find(line,"%-%-%[%[") then
            ccnt = ccnt + 1
            end
          end
        if not skip then
          local cmd = match(line,"^%-%-%%%s*(.*%S)%s*$")
          if cmd then
            io.stderr:write("\nCommand: ",cmd,'\n\n')
            cmd = loadstring(cmd)
            if type(cmd) == "function" then
              out = nil
              cmd()
              if out and out ~= par.out then
                if output ~= io.stdout then
                  output:close()
                  end
                if out == io.stdout then output = io.stdout
                elseif type(out) == "string" then
                  output,err = io.open(out,"w")
                  if not output then
                    io.stderr:write('\n### ',err,'\n\n')
                    return
                    end
                  end
                end
            else
              io.stderr:write("\n*** ERROR in command! ***\n")
              end
          else
            b,e = find(line,"%-%-%[%[")
            if b then
              ccnt = 1
              if b == 1 then
                skip = true
              else
                skip_next = true
                line = sub(line,1,b-1)
                end
              end
            end 
          end  
        end
      if not skip then
        b = find(line,"%-%-")
        if b then line = sub(line,1,b-1) end      -- EOL comment
        if len(line) > 0 and find(line,"%S") then
          if outnb then
            nb = nb + 1
            output:write("\n**** Block ",nb," ****\n\n")
            outnb = false
            end
          ins(block,line)
          line = match(line,"(.*%S)%s*$")  -- cut trailing space chars
          if len(line) < 81 then output:write(" ",line,"\n")
          else                              -- split long lines for listing
            repeat
              local cutpnt = find(sub(line,1,80),"%s+%S*$")
              output:write(sub(line,1,cutpnt-1),'\n')
              line = sub(line,cutpnt+1) 
              until len(line) <= 80
            if len(line) > 0 then output:write(line,'\n') end
            end
        elseif #block > 0 then       -- non-empty block
          ins(block,"xaho")           -- EOB mark for error check after parse
          yield(concat(block," "),nb) -- return block contents, block number 
          block = {}
          outnb = true
          end
        if skip_next then
          skip = true
          skip_next = false
          end
        end
      end
    f:close()
    if #block > 0 then              -- non-epty block at EOF
      ins(block,"xaho")             -- add EOB mark just in case
      yield(concat(block," "),nb)
      end
    return
  end
  )
    
function blocks(f)           -- block iterator factory
  return function()
    local status, block, nb = resume(reader,f)
    if not status then return nil end
    return block,nb
    end
end

io.stderr:write('\n -- Analyzing "',lojban_file,'"\n')

-- morphology stage -----------------------------------------------------------

local check_fuhivla_lujvo = get_par(par.check_fuhivla_lujvo)

function morph(text)
  local wordpgm = morphed(text,check_fuhivla_lujvo)
  -- insert a morphology modifier here if required
  -- wordpgm is a table containing word formatting function calls
  --   to be executed at the next stage  
  return wordpgm
end

-- statistics gathering -------------------------------------------------------

local counts = {}             -- table of tables

function gather_stats(tn,cn)  -- a general statistics gathering function

  -- tn = table name, cn = class name
  -- the function will create new tables on the fly and gather frequency
  -- data for the classes, also created on the fly 

  if not do_stats then return end
  local c = counts[tn]
  if not c then           -- table tn doesn't exist
    counts[tn] = {}       -- create
    c = counts[tn]
    end
  if not c[cn] then       -- class cn within table tn doesn't exist
    c[cn] = 1              -- initiate counter
  else
    c[cn] = c[cn]+1        -- increment counter  
    end
end

-- syntax stage ---------------------------------------------------------------

split_lujvo = get_par(par.split_lujvo)  -- indicate lujvo split
                                              -- gather rafsi statistics

local wordlist = {}

-- formatting functions for the various word types

function cmavo(s,c)
  ins(wordlist," C("..s.."/"..c..")") -- insert formatted entry to wordlist
  gather_stats("selma'o",s)
  gather_stats("cmavo",c)
end

function brivla(s,c)
  if s == "lujvo" then

    if split_lujvo then
      c = concat(lsplit(c,check_fuhivla_lujvo),'')
      if find(c,"%-") then
        for r in gmatch(c,"%-[%a']+") do
          r = gsub(r,"%-","")
          gather_stats("rafsi",r)
          end
        c = gsub(c,"%-","")
        end
      end
    gather_stats("lujvo",c)      
    end

  ins(wordlist," B("..s.."/"..c..")")
  if s == "gismu" then gather_stats("gismu",c) end
  if s == "fuhivla" then gather_stats("fu'ivla",c) end  
end

function cmene(c)
  ins(wordlist," N("..c..")")
  gather_stats("cmene",c)
end

function non_lojbanx(c)
  ins(wordlist," nonL("..c..")")
  gather_stats("non-lojban words",c) 
end
function non_lojban(s,c)
  ins(wordlist," nonL("..s.."/"..c..")")
  gather_stats("non-lojban words",s) 
end

function syntax(wordpgm,nb)  -- handle one block of words (text)

  -- wordpgm = a table of function calls (as text) prepared by
  -- the morphology PEG
  -- nb = sequence number of the block

-- format the word list for the syntax PEGn by compiling and executing
-- the word function calls
  
  wordlist = {}  -- clear the list
  
  for _,word in ipairs(wordpgm) do loadstring(word)() end


-- transform the table of words into a string, try to parse it and
-- concatenate the parse table into a string

  local wt = concat(wordlist,"")
--print(wt)
  local wp = parse(wt)
  local pt = concat(wp,"\n")
--print(pt)
--[[
-- NB. this section is for my testing purposes only!
--
-- The numbers produced have no real meaning outside the program context.
--
-- I had to remove some intermediate levels from the tree in order to
-- prevent the standard lua/luajit interpreter from hitting internal
-- syntax level limit while handling the parse tree of "Alice".
--
-- I use this code segment to find out the maximum parse tree depth coming
-- out of the parser PEG
 
  local mx, level = 0, 0
  
  for w in gmatch(pt,"[%{%}]") do
    if w == '{' then level = level+1 else level = level-1 end
    mx = max(mx,level)
    end
 
  output:write("\nMax nesting level in the generated parse tree = ",mx,"\n")
--]]  
    
-- try to compile the table definition returned by the parser

  local tf, err = loadstring(pt)

  if type(tf) =="function" then        -- if succesful
    local tree = tf()                  -- execute the resulting function
    if type(tree) == "table" then      -- parse OK
      return tree
      end
  else
    io.stderr:write("!! block ",nb," / parse tree :\n   ",err,"\n")
    output:write("\nERROR MESSAGE concersing the parse tree:\n\n  ",
                 err,'\n') -- something funny
    end
end

-- tree output stage ---------------------------------------------------------------

-- *******  output parameters  *********************************

no_sub = get_par(par.no_sub) -- true if numbered sub-rules are to be excluded
                          -- NB. this parameter has presently no effect
use_excl = tonumber(par.use_excl) or 0 -- exclusion list to use
no_singles = get_par(par.no_singles)  -- exclude rules with just a single offspring
elisions   = get_par(par.elisions) -- true if elided terminators are to be indicated
incl_expl  = get_par(par.incl_expl)  -- true if explanation tags are to be printed

-- exclusion lists

excl_list = {}
excl_list[0] = {} -- nul list

-- an ad lib exclusion list for the pretty printer, several can be provided

excl_list[1] = par.excl_list[1] or
  {"text","paragraphs","terms","term","bridi tail"}

-- set the exclusion list to use

excl_list = excl_list[use_excl]

excl = {}  -- table of exclusions

-- fill the table according to the selected list

for _,w in ipairs(excl_list) do excl[w] = 1 end

-- add items to be always excluded

excl["rp expression tail"] = 1

-- define forced includes

local use_user_incl = false

for i,v in pairs(par.incl) do -- check whether par.incl is non-empty
  use_user_incl = true        -- yes
  break
  end
  
if use_user_incl then
  incl = par.incl        -- use user defined inclusion table
else                     -- else use default
  incl = {}
  incl.sumti        = 1
  incl.selbri       = 1
  incl.operator     = 1
--incl.quantifier   = 1
  incl.interval     = 1
  incl.indicator    = 1
  incl.tag          = 1
  incl.stag         = 1
  incl["short scope link"] = 1
  incl["tense modal"] = 1
  incl["CU clause"] = 1
  incl["I clause"]  = 1
  end
         
-- define desired text replacements for word classes and brivla types

gg = par.gg or {BRIVLA = "brivla =", CMAVO = ""} -- word classes

cg = par.cg or {gismu = "", lujvo = "", fuhivla = "/F/"} -- BRIVLA types

-- default pretty printer

function pretty_print(t,prefix) -- a recursive, selective tree printer

  -- t      = (sub)tree
  -- prefix = line indent prefix
  
  if type(t) == "table" and t[1] then -- handle non-empty trees
    local p  = prefix
    local tt = t.tag  -- name of non-terminal or nil
    local include,cm,got_FAhO
    if tt then -- decide whether a non-terminal is displayed
      if find(tt,"^<") then include = incl_expl
      else 
        include = not excl[tt] and not (no_sub and find(tt,"%d"))
          and not (no_singles and (#t == 1) or (#t == 2 and t[2].tag == "*ELIDED"))
        include = include or incl[tt]
        end
      if include then
        output:write(p,tt,'\n')
        end
      end  
    for _,elem in ipairs(t) do
      local ety = type(elem)
      if ety == "table" then
        local save = p  -- save indent level
        if include then p = p.."| " end
        local et = elem.tag
        if et then -- handle tagged terminals or go down one non-terminal level
          if et == "CMAVO" then
            if elem[1][2] ~= "xaho" then  -- omit end of block marker
              output:write(p, gg[et] or et.." ", elem[1][2],
                sub("      ",1,4-len(elem[1][2]))," (",elem[1][1],")\n")
              end
            if elem[1][1] == "FAhO" then got_FAhO = true end              
          elseif et == "BRIVLA" then
             local w,t = elem[1][2], elem[1][1]
             output:write(p,gg[et] or et," ",w,"  ",cg[t],"\n")
             if decode_rafsi and t == "lujvo" then
               output:write(p,sub("         ",1,len(gg[et] or et)+1))
               local d = ""
               for r in gmatch(w,"[%a']+") do
                 local g = r2g[r]
                 if not g then
                   g = match(r,"([%a']+)[yrn]$")
                   g = g and (gr2g[g] or r2g[g])
                   end
                 d = d..(g or r)..'|'
                 end
               output:write(sub(d,1,len(d)-1),'\n')
               end
          elseif et == "CMENE" then
            --output:write(p,gg[et] or et.." ",elem[1],'\n')
            output:write(p,elem[1],'\n')
          elseif et == "*ELIDED" then
            gather_stats("elisions",elem[1])
            if elisions then
              output:write(p,'(',gsub(lower(elem[1]),"h","'"),')\n')
              end
          elseif et == "non-L" then
            output:write(p,gg[et] or et," ",elem[1][1],'\n')  
          else -- non-terminal, go down
            got_FAhO = pretty_print(elem,p) or got_FAhO end
        else -- un-tagged terminal
          for _,ee in pairs(elem) do p = p.." "..ee end
          output:write(p,'\n')
          end
        p = save  -- restore indent level
        --[[ this section is for my own testing purposes
      else -- handle scalar elements, coded just in case
        if tt then output:write(p,"|  ",elem,'\n')
        else output:write(elem,'\n')
          end --]]
        end
      end
    return got_FAhO
    end
end

-- statistics section ---------------------------------------------------------

function freq_list(s,counts,func,minn) -- write a sorted list with associated counts

  -- s = list, func = sort function or nil
  
  if type(func) == "function" then sort(s,func) else sort(s) end

  local mx = 0
  for _,name in ipairs(s) do mx = max(mx,len(name)) end
  local nx = math.floor(80/(mx+8))
  local nfmt = "%-"..mx.."s"
  local ne = 0
  local diff = false
  local fst = counts[s[1]]
  if fst < minn then return end
  
  for _,name in ipairs(s) do
    local cnt = counts[name]
    if cnt < minn then break end
    if cnt ~= fst then diff = true end
    output:write(format(nfmt,name),format("%5d | ",cnt))
    ne = ne+1
    if ne == nx then
      output:write('\n')
      ne = 0
      end
    end
  if ne > 0 then output:write('\n') end
  output:write('\n')
  return diff
end

function stats(wt)          -- prepare word and frequency lists for output

  -- wt = table name

  local cnts = counts[wt]      -- try to get the table from the table of tables
  if not cnts then return end -- no table by that name
  
  -- prepare a list of class names
  
  local names = {}
  for n,_ in pairs(cnts) do ins(names,n) end
  
  if #names == 0 then return end  -- no classes found
  
  output:write("  ",upper(wt),"\n\n")    -- section title
  
  output:write(#names," different ",wt," found:\n\n")
  
  -- the first list section is sorted by the class names
  -- (default sort so no sort function given)
  
  local diff = freq_list(names,cnts,false,0)
    
  -- the second list section is sorted by the class frequencies
  -- (sort function specified)
  
  if diff then   -- there are different frequencies
  
    output:write(wt," sorted by frequency:\n\n")
  
    freq_list(names,cnts,
      function(a,b)
        return (cnts[a] > cnts[b]) or (cnts[a] == cnts[b]) and (a < b)
      end,
      2
      ) 
    end  
end

function statistics()  -- statistics output for the full text
  output:write("\n       STATISTICS\n\n")
  counts.cmavo.xaho = nil
  local stat_tables = {"cmavo","selma'o","elisions","gismu","lujvo","fu'ivla",
    "cmene","non-lojban words","rafsi"}
  for _,wt in ipairs(stat_tables) do stats(wt) end
end

-- MAIN PROGRAM ---------------------------------------------------------------

-- handle the input file block by block

for block,nb in blocks(ff) do        -- iterate over the text blocks                                      

  io.stderr:write("block ",nb,"\n")  -- just info to the terminal
  
  local mm = morph(block)            -- handle the morphology
 
  if mm then                         -- got something
    local tree = syntax(mm,nb)          -- try to get a parse tree
    if tree then                     -- got a tree, pretty print it
      output:write("\n ---- Parse ----\n\n")
      local got_FAhO = pretty_print(tree,"") -- print the tree, indent == ""    
      if got_FAhO then               -- EOB/EOF found, full block in the tree
        output:write("\n**** Block "..nb.." passed ****")
      else
        io.stderr:write("!! No fa'o or EOB marker parsed at block ",nb,"\n")
        output:write("\n*** ERROR at block ",nb," : parse terminated prematurely!")
        end
      end
    output:write("\n\n----------------------------------------------------\n")
    
  else                               -- got nothing from morphology
    io.stderr:write("block ",nb," skipped!\n\n")
    end
  end

if do_stats then statistics() end

if output ~= io.stdout then
  output:close()
  end

-- END OF PROGRAM -------------------------------------------------------------