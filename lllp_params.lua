--[[
           user definable parameters for LLLP


  matches LLLP version alpha 8

  These parameter values can be overridden in the lojban input file using
  comment lines starting with --% at the beginning of line and containing
  lua statements separated with semicolons. The parameter names must be used
  without the "par." prefix, e.g.
  
     --% elisions = false; decode_rafsi = false; out = "xyz_parse.txt"
     
  These command lines can be inserted at the beginning of the file and
  also between text blocks preceded by an empty line.
--]]

local par = {}

-- define parse output file

par.out = io.stdout -- output file, e.g., par.out = "xyz.txt"

-- whether input may contain fuhivla lujvo (Is there such a beast?)

par.check_fuhivla_lujvo = false

-- lujvo splitting at the morphology stage
 
par.split_lujvo = true     -- indicate lujvo split in the tree output and
                           -- gather rafsi statistics

-- rafsi decoding

par.rafsi_file   = "lllp_r2g.lua"  -- rafsi-to-gismu tables
par.decode_rafsi =  true           -- try to decode rafsi in the parse tree

-- output parameters

par.no_sub     = true  -- true if numbered sub-rules are to be excluded
                        -- NB. this parameter has presently no effect
                          
par.use_excl   = 1     -- define the exclusion list to be used, 0 = nul list

par.no_singles = true  -- exclude rules with just a single offspring
par.elisions   = true  -- true if elided terminators are to be indicated
par.incl_expl  = true  -- true if explanation tags are to be printed (<...>)

-- exclusion lists for the pretty printer, several can be provided

par.excl_list = {}  -- empty table, DO NOT REMOVE THIS LINE
par.excl_list[1] = {"text","paragraphs","terms","term","bridi tail"} -- list 1

-- add items to be always excluded

par.excl = {}  -- empty table, DO NOT REMOVE THIS LINE
par.excl["rp expression tail"] = 1

-- define forced includes (These definitions are required to include tags
--                         which otherwise would be excluded when no_singles
--                         is true. Set according to your personal taste or
--                         requirements.
--   NB. set no_singles to false to see what tags are available

par.incl = {}  -- empty table, DO NOT REMOVE THIS LINE
par.incl.sumti        = 1
par.incl.selbri       = 1
par.incl.operator     = 1
par.incl.quantifier   = 1
par.incl.interval     = 1
par.incl.indicator    = 1
par.incl.tag          = 1
par.incl.stag         = 1
par.incl["short scope link"] = 1
par.incl["tense modal"] = 1
par.incl["CU clause"] = 1
par.incl["I clause"]  = 1

-- define desired text replacements for word classes and brivla types

par.gg = {BRIVLA = "brivla =", CMAVO = ""} -- word classes

par.cg = {gismu = "", lujvo = "", fuhivla = "/F/"} -- BRIVLA types

par.do_stats = true -- produce word usage statistics

return par