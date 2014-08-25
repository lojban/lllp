--[[
  CAUTION: THIS IS JUST AN ALPHA VERSION AND MAY CONTAIN ERRORS

           RELEASED FOR PRELIMINARY EXPERIMENTATION AND FEEDBACK

           PENDING A THOROUGH INSPECTION, MAY AND PROBABLY STILL
           DOES IN SOME MINOR DETAIL CONTRADICT THE "OFFICIAL"
           SPECIFICATION

           THERE ARE TWO KINDS OF INTENTIONAL MODIFICATIONS:

             1) MODIFICATIONS FOR SPEEDING UP THE PARSING PROCESS
             2) MODIFICATIONS WHICH PROVIDE SOME EXTRA BRACKETING
                USEFUL AT THE EXTERNAL PRETTY PRINTING STAGE

           THESE MODIFICATIONS OUGHT NOT ULTIMATELY AFFECT THE
           LANGUAGE ACCEPTED OR REJECTED BY THIS PARSER. 
          
  NB. the numbered intermediate rules (e.g. selbri-1) are excluded
      from the generated parse tree in order to avoid hitting the
      lua/luajit syntax level limit while interpreting the tree at
      the later stages

 This is a Parsing Expression Grammar for Lojban.

 Robin's lojban.peg converted to employ Lpeg. Some comments have been
 deleted.

 requires lua5.1/luajit2 and lpeg library to run

  lua    : http://www.lua.org
  luajit : http://luajit.org/
  Lpeg   : http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html

  June 24, 2012

  mi'e veion  (veijo.vilva@gmail.com)

--]]---------------------------------------------------------------------------

require"lpeg"

local P      = lpeg.P
local V      = lpeg.V
local C      = lpeg.C
local Cg     = lpeg.Cg
local Ct     = lpeg.Ct
local Cc     = lpeg.Cc
local Cf     = lpeg.Cf
local Cmt    = lpeg.Cmt
local lmatch = lpeg.match
local print  = print
local match  = string.match
local len    = string.len

module(...)

function inner_tail(s)
  return s
end

function frame(f,i)
  return '\n{tag="CMAVO",{"'..f..'","'..i..'"}},\n'
end

function split(i)
  local t,w = match(i,"([^/]+)/(.+)")
--  local t,w = match(i,"(%a+)/([%w'|]+)")
  return '{"'..t..'","'..w..'"}'
end

function spot(s,pos,w)  -- temporary help function for testing
  print(pos,w)
  return pos
end

function catch_word(s,pos,w)
  mark = w
  return pos,w
end

function match_word(s,pos,w)
  if w == mark then return pos,w end
end

function cumul(acc,s)
  return acc..s
end

-- define non-terminals

tree = V"tree"
text = V"text"
text_part_2 = V"text_part_2"
intro_si_clause = V"intro_si_clause"
faho_clause = V"faho_clause"
text_1 = V"text_1"
paragraphs = V"paragraphs"
paragraph = V"paragraph"
statement = V"statement"
statement_1 = V"statement_1"
statement_2 = V"statement_2"
statement_3 = V"statement_3"
fragment = V"fragment"
prenex = V"prenex"
sentence = V"sentence"
sentence_sa = V"sentence_sa"
sentence_start = V"sentence_start"
subsentence = V"subsentence"
bridi_tail = V"bridi_tail"
bridi_tail_1 = V"bridi_tail_1"
bridi_tail_2 = V"bridi_tail_2"
bridi_tail_3 = V"bridi_tail_3"
gek_sentence = V"gek_sentence"
tail_terms = V"tail_terms"
terms = V"terms"
terms_1 = V"terms_1"
terms_2 = V"terms_2"
pehe_sa = V"pehe_sa"
cehe_sa = V"cehe_sa"
term = V"term"
term_1 = V"term_1"
term_sa = V"term_sa"
termset = V"termset"
gek_termset = V"gek_termset"
terms_gik_terms = V"terms_gik_terms"
sumti = V"sumti"
sumti_1 = V"sumti_1"
sumti_2 = V"sumti_2"
sumti_3 = V"sumti_3"
sumti_4 = V"sumti_4"
sumti_5 = V"sumti_5"
sumti_6 = V"sumti_6"
li_clause = V"li_clause"
sumti_tail = V"sumti_tail"
sumti_tail_1 = V"sumti_tail_1"
relative_clauses = V"relative_clauses"
relative_clause = V"relative_clause"
relative_clause_1 = V"relative_clause_1"
selbri = V"selbri"
selbri_1 = V"selbri_1"
selbri_2 = V"selbri_2"
selbri_3 = V"selbri_3"
selbri_4 = V"selbri_4"
selbri_5 = V"selbri_5"
selbri_6 = V"selbri_6"
tanru_unit = V"tanru_unit"
tanru_unit_1 = V"tanru_unit_1"
tanru_unit_2 = V"tanru_unit_2"
zei_lujvo = V"zei_lujvo"
linkargs = V"linkargs"
linkargs_1 = V"linkargs_1"
links = V"links"
links_1 = V"links_1"
quantifier = V"quantifier"
mex = V"mex"
mex_0 = V"mex_0"
rp_clause = V"rp_clause"
mex_1 = V"mex_1"
mex_2 = V"mex_2"
mex_forethought = V"mex_forethought"
fore_operands = V"fore_operands"
rp_expression = V"rp_expression"
rp_expression_tail = V"rp_expression_tail"
operator = V"operator"
operator_0 = V"operator_0"
operator_1 = V"operator_1"
operator_2 = V"operator_2"
mex_operator = V"mex_operator"
operand = V"operand"
operand_0 = V"operand_0"
operand_1 = V"operand_1"
operand_2 = V"operand_2"
operand_3 = V"operand_3"
number = V"number"
lerfu_string = V"lerfu_string"
lerfu_word = V"lerfu_word"
ek = V"ek"
gihek = V"gihek"
gihek_1 = V"gihek_1"
jek = V"jek"
joik = V"joik"
interval = V"interval"
joik_ek = V"joik_ek"
joik_ek_1 = V"joik_ek_1"
joik_jek = V"joik_jek"
gek = V"gek"
guhek = V"guhek"
gik = V"gik"
tag = V"tag"
stag = V"stag"
tense_modal = V"tense_modal"
simple_tense_modal = V"simple_tense_modal"
time = V"time"
time_offset = V"time_offset"
space = V"space"
space_offset = V"space_offset"
space_interval = V"space_interval"
space_int_props = V"space_int_props"
interval_property = V"interval_property"
free = V"free"
xi_clause = V"xi_clause"
vocative = V"vocative"
indicators = V"indicators"
indicator = V"indicator"
zei_clause = V"zei_clause"
bu_clause = V"bu_clause"
zei_tail = V"zei_tail"
bu_tail = V"bu_tail"
pre_zei_bu = V"pre_zei_bu"
post_clause = V"post_clause"
pre_clause = V"pre_clause"
BRIVLA_clause = V"BRIVLA_clause"
CMENE_clause = V"CMENE_clause"
A_clause = V"A_clause"
BAI_clause = V"BAI_clause"
BAhE_clause = V"BAhE_clause"
BE_clause = V"BE_clause"
BEI_clause = V"BEI_clause"
BEhO_clause = V"BEhO_clause"
BIhE_clause = V"BIhE_clause"
BIhI_clause = V"BIhI_clause"
BO_clause = V"BO_clause"
BOI_clause = V"BOI_clause"
BU_clause = V"BU_clause"
BY_clause = V"BY_clause"
CAhA_clause = V"CAhA_clause"
CAI_clause = V"CAI_clause"
CEI_clause = V"CEI_clause"
CEhE_clause = V"CEhE_clause"
CO_clause = V"CO_clause"
COI_clause = V"COI_clause"
CU_clause = V"CU_clause"
CUhE_clause = V"CUhE_clause"
DAhO_clause = V"DAhO_clause"
DOI_clause = V"DOI_clause"
DOhU_clause = V"DOhU_clause"
FA_clause = V"FA_clause"
FAhA_clause = V"FAhA_clause"
FAhO_clause = V"FAhO_clause"
FEhE_clause = V"FEhE_clause"
FEhU_clause = V"FEhU_clause"
FIhO_clause = V"FIhO_clause"
FOI_clause = V"FOI_clause"
FUhA_clause = V"FUhA_clause"
FUhE_clause = V"FUhE_clause"
FUhO_clause = V"FUhO_clause"
GA_clause = V"GA_clause"
GAhO_clause = V"GAhO_clause"
GEhU_clause = V"GEhU_clause"
GI_clause = V"GI_clause"
GIhA_clause = V"GIhA_clause"
GOI_clause = V"GOI_clause"
GOhA_clause = V"GOhA_clause"
GUhA_clause = V"GUhA_clause"
I_clause = V"I_clause"
JA_clause = V"JA_clause"
JAI_clause = V"JAI_clause"
JOhI_clause = V"JOhI_clause"
JOI_clause = V"JOI_clause"
KE_clause = V"KE_clause"
KEhE_clause = V"KEhE_clause"
KEI_clause = V"KEI_clause"
KI_clause = V"KI_clause"
KOhA_clause = V"KOhA_clause"
KU_clause = V"KU_clause"
KUhE_clause = V"KUhE_clause"
KUhO_clause = V"KUhO_clause"
LA_clause = V"LA_clause"
LAU_clause = V"LAU_clause"
LAhE_clause = V"LAhE_clause"
LE_clause = V"LE_clause"
LEhU_clause = V"LEhU_clause"
LI_clause = V"LI_clause"
LIhU_clause = V"LIhU_clause"
LOhO_clause = V"LOhO_clause"
LOhU_clause = V"LOhU_clause"
LOhU_pre = V"LOhU_pre"
LU_clause = V"LU_clause"
LUhU_clause = V"LUhU_clause"
MAhO_clause = V"MAhO_clause"
MAI_clause = V"MAI_clause"
ME_clause = V"ME_clause"
MEhU_clause = V"MEhU_clause"
MOhE_clause = V"MOhE_clause"
MOhI_clause = V"MOhI_clause"
MOI_clause = V"MOI_clause"
NA_clause = V"NA_clause"
NAI_clause = V"NAI_clause"
NAhE_clause = V"NAhE_clause"
NAhU_clause = V"NAhU_clause"
NIhE_clause = V"NIhE_clause"
NIhO_clause = V"NIhO_clause"
NOI_clause = V"NOI_clause"
NU_clause = V"NU_clause"
NUhA_clause = V"NUhA_clause"
NUhI_clause = V"NUhI_clause"
NUhU_clause = V"NUhU_clause"
PA_clause = V"PA_clause"
PEhE_clause = V"PEhE_clause"
PEhO_clause = V"PEhO_clause"
PU_clause = V"PU_clause"
RAhO_clause = V"RAhO_clause"
ROI_clause = V"ROI_clause"
SE_clause = V"SE_clause"
SEI_clause = V"SEI_clause"
SEhU_clause = V"SEhU_clause"
SOI_clause = V"SOI_clause"
TAhE_clause = V"TAhE_clause"
TEhU_clause = V"TEhU_clause"
TEI_clause = V"TEI_clause"
TO_clause = V"TO_clause"
TOI_clause = V"TOI_clause"
TUhE_clause = V"TUhE_clause"
TUhU_clause = V"TUhU_clause"
UI_clause = V"UI_clause"
VA_clause = V"VA_clause"
VAU_clause = V"VAU_clause"
VEI_clause = V"VEI_clause"
VEhO_clause = V"VEhO_clause"
VUhU_clause = V"VUhU_clause"
VEhA_clause = V"VEhA_clause"
VIhA_clause = V"VIhA_clause"
VUhO_clause = V"VUhO_clause"
XI_clause = V"XI_clause"
Y_clause = V"Y_clause"
ZAhO_clause = V"ZAhO_clause"
ZEhA_clause = V"ZEhA_clause"
ZEI_clause = V"ZEI_clause"
ZI_clause = V"ZI_clause"
ZIhE_clause = V"ZIhE_clause"
ZO_clause = V"ZO_clause"
ZO_pre = V"ZO_pre"
ZOI_clause = V"ZOI_clause"
ZOI_pre = V"ZOI_pre"
ZOhU_clause = V"ZOhU_clause"
inner_word = V"inner_word"
inner_word2 = V"inner_word2"
tail = V"tail"
space_char = V"space_char"
equals_char = V"equals_char"
open_paren = V"open_paren"
close_paren = V"close_paren"
close_dparen = V"close_dparen"
any_word = V"any_word"
spaces = V"spaces"
spaces_pre = V"spaces_pre"
dot_star = V"dot_star"
EOF = V"EOF"
zoi_open = V"zoi_open"
zoi_word = V"zoi_word"
zoi_close = V"zoi_close"
non_Lojban_word = V"non_Lojban_word"
CMAVO = V"CMAVO"
BRIVLA = V"BRIVLA"
CMENE = V"CMENE"
A = V"A"
BAI = V"BAI"
BAhE = V"BAhE"
BE = V"BE"
BEI = V"BEI"
BEhO = V"BEhO"
BIhE = V"BIhE"
BIhI = V"BIhI"
BO = V"BO"
BOI = V"BOI"
BU = V"BU"
BY = V"BY"
CAhA = V"CAhA"
CAI = V"CAI"
CEI = V"CEI"
CEhE = V"CEhE"
CO = V"CO"
COI = V"COI"
CU = V"CU"
CUhE = V"CUhE"
DAhO = V"DAhO"
DOI = V"DOI"
DOhU = V"DOhU"
FA = V"FA"
FAhA = V"FAhA"
FAhO = V"FAhO"
FEhE = V"FEhE"
FEhU = V"FEhU"
FIhO = V"FIhO"
FOI = V"FOI"
FUhA = V"FUhA"
FUhE = V"FUhE"
FUhO = V"FUhO"
GA = V"GA"
GAhO = V"GAhO"
GEhU = V"GEhU"
GI = V"GI"
GIhA = V"GIhA"
GOI = V"GOI"
GOhA = V"GOhA"
GUhA = V"GUhA"
I = V"I"
JA = V"JA"
JAI = V"JAI"
JOhI = V"JOhI"
JOI = V"JOI"
KE = V"KE"
KEhE = V"KEhE"
KEI = V"KEI"
KI = V"KI"
KOhA = V"KOhA"
KU = V"KU"
KUhE = V"KUhE"
KUhO = V"KUhO"
LA = V"LA"
LAU = V"LAU"
LAhE = V"LAhE"
LE = V"LE"
LEhU = V"LEhU"
LI = V"LI"
LIhU = V"LIhU"
LOhO = V"LOhO"
LOhU = V"LOhU"
LU = V"LU"
LUhU = V"LUhU"
MAhO = V"MAhO"
MAI = V"MAI"
ME = V"ME"
MEhU = V"MEhU"
MOhE = V"MOhE"
MOhI = V"MOhI"
MOI = V"MOI"
NA = V"NA"
NAI = V"NAI"
NAhE = V"NAhE"
NAhU = V"NAhU"
NIhE = V"NIhE"
NIhO = V"NIhO"
NOI = V"NOI"
NU = V"NU"
NUhA = V"NUhA"
NUhI = V"NUhI"
NUhU = V"NUhU"
PA = V"PA"
PEhE = V"PEhE"
PEhO = V"PEhO"
PU = V"PU"
RAhO = V"RAhO"
ROI = V"ROI"
SE = V"SE"
SEI = V"SEI"
SEhU = V"SEhU"
SOI = V"SOI"
TAhE = V"TAhE"
TEhU = V"TEhU"
TEI = V"TEI"
TO = V"TO"
TOI = V"TOI"
TUhE = V"TUhE"
TUhU = V"TUhU"
UI = V"UI"
VA = V"VA"
VAU = V"VAU"
VEI = V"VEI"
VEhO = V"VEhO"
VUhU = V"VUhU"
VEhA = V"VEhA"
VIhA = V"VIhA"
VUhO = V"VUhO"
XI = V"XI"
Y = V"Y"
ZAhO = V"ZAhO"
ZEhA = V"ZEhA"
ZEI = V"ZEI"
ZI = V"ZI"
ZIhE = V"ZIhE"
ZO = V"ZO"
ZOI = V"ZOI"
ZOhU = V"ZOhU"

-- ___ GRAMMAR ___ 

grammar = P{"tree",
tree = Ct(Cc"return " * text),
text = Cc'{tag="text",' *
  spaces^-1 * NAI_clause^0 * text_part_2 *
    (-text_1 * joik_jek)^-1 * text_1^-1 * faho_clause * EOF^-1
  * Cc'}',

text_part_2 = Cc'\n{tag="text part 2",' *
  ( 
  CMENE_clause^1 +
  indicators^-1
  ) * free^0
  * Cc'},',

faho_clause = (FAhO_clause * dot_star)^-1, 

text_1 = --Cc'\n{tag="text 1",' * ( 
  I_clause * (jek + joik)^-1 * (stag^-1 * BO_clause)^-1 * free^0 * text_1^-1 +
  NIhO_clause^1 * free^0 * paragraphs^-1 +
  paragraphs,
  --) * Cc'},',

paragraphs = Cc'\n{tag="paragraphs",' *
  paragraph * (NIhO_clause^1 * free^0 * paragraphs)^-1
  * Cc'},',

paragraph = Cc'\n{tag="paragraph",' *
  (statement + fragment) * (I_clause * -jek * -joik * -- joik_jek -- superfluous
  free^0 * (statement + fragment)^-1)^0 * Cc'},',

statement = Cc'\n{tag="statement",' * ( 
  statement_1 +
  prenex * statement
  ) * Cc'},',

statement_1 = -- Cc'\n{tag="statement 1",' *
  statement_2 * (I_clause * joik_jek * statement_2^-1)^0,
  -- * Cc'},',

statement_2 = -- Cc'\n{tag="statement 2",' * -- simplification OK ?
  statement_3 * ((I_clause * (jek + joik)^-1 * stag^-1 * BO_clause * free^0 *
 --   statement_2)^-1 + 
 --  (I_clause * (jek + joik)^-1 * stag^-1 * BO_clause * free^0)) * Cc'},',
  statement_2^-1)^-1),
--  * Cc'},',
   
statement_3 = --Cc'\n{tag="statement 3",' * (  
  sentence +
  tag^-1 * TUhE_clause * free^0 * text_1 *
    (TUhU_clause * Cc'\n{tag="*ELIDED","TUhU"},') * free^0,
 -- ) * Cc'},',

fragment = Cc'\n{tag="fragment",' * ( 
  prenex +
  terms * VAU_clause^-1 * free^0 +
  ek * free^0 +
  gihek * free^0 +
  quantifier +
  NA_clause * -JA_clause * free^0 +
  relative_clauses +
  links +
  linkargs
  ) * Cc'},',

prenex = Cc'\n{tag="prenex",' *
  terms * ZOhU_clause * free^0
  * Cc'},',

sentence = Cc'\n{tag="sentence",' *
  (terms * (CU_clause + Cc'\n{tag="*ELIDED","CU"},')* free^0)^-1 * bridi_tail
  * Cc'},',

subsentence = Cc'\n{tag="subsentence",' * ( 
  sentence +
  prenex * subsentence
  ) * Cc'},',

bridi_tail = Cc'\n{tag="bridi tail",' *
  bridi_tail_1 * (gihek * stag^-1 * KE_clause * free^0 * bridi_tail *
    (KEhE_clause + Cc'\n{tag="*ELIDED","KEhE"},') * free^0 * tail_terms)^-1
  * Cc'},',

bridi_tail_1 = --Cc'\n{tag="bridi tail 1",' *
  bridi_tail_2 * (gihek * -(stag^-1 * BO_clause) * -(stag^-1 * KE_clause) *
    free^0 * bridi_tail_2 * tail_terms)^0,
  --* Cc'},',

bridi_tail_2 = --Cc'\n{tag="bridi tail 2",' *
  bridi_tail_3 * (gihek * stag^-1 * BO_clause * free^0 * bridi_tail_2 *
  tail_terms)^-1,
  --* Cc'},',

bridi_tail_3 = --Cc'\n{tag="bridi tail 3",' * (  
  selbri * tail_terms +
  gek_sentence,
 -- ) * Cc'},',

gek_sentence = Cc'\n{tag="gek sentence",' * (  
  gek * subsentence * gik * subsentence * tail_terms +
  tag^-1 * Cc'\n{tag="grouping",' * KE_clause * free^0 * gek_sentence *
    (KEhE_clause + Cc'\n{tag="*ELIDED","KEhE"},') * Cc'},' * free^0 +
  NA_clause * free^0 * gek_sentence
  ) * Cc'},',

tail_terms = Cc'\n{tag="tail terms",' *
  terms^-1 * (VAU_clause + Cc'\n{tag="*ELIDED","VAU"},') * Cc'},' * free^0,

terms = Cc'\n{tag="terms",' * terms_1^1 * Cc'},', 

terms_1 = --Cc'\n{tag="terms 1",' *
  terms_2 * (PEhE_clause * free^0 * joik_jek * terms_2)^0,
  --* Cc'},',

terms_2 = --Cc'\n{tag="terms 2",' *
  term * (CEhE_clause * free^0 * term)^0,
  --* Cc'},',

term = Cc'\n{tag="term",' * (  -- orig term-1, sumti tcita added, re-arranged
  sumti +
  (-gek * (Cc'\n{tag="<sumti tcita>",' * (tag * sumti) *
      Cc'},\n{tag="</sumti tcita>",""},' +
    tag * (KU_clause + Cc'\n{tag="*ELIDED","KU"},') * free^0 + 
    Cc'\n{tag="<FA clause>",' * FA_clause * Cc'},' * free^0 * (sumti +
      (KU_clause + Cc'\n{tag="*ELIDED","KU"},') * free^0))
    ) +
  termset +
  NA_clause * KU_clause * free^0
  ) * Cc'},',   

termset = Cc'\n{tag="termset",' * (  
  gek_termset +
  NUhI_clause * free^0 *
   (gek * terms * (NUhU_clause + Cc'\n{tag="*ELIDED","NUhU"},') * free^0 *
     gik)^-1 * terms * (NUhU_clause + Cc'\n{tag="*ELIDED","NUhU"},') * free^0
  ) * Cc'},',

gek_termset = Cc'\n{tag="gek termset",' * gek * terms_gik_terms * Cc'},', 

terms_gik_terms = Cc'\n{tag="terms gik terms",' * 
  term * (gik + terms_gik_terms) * term
  * Cc'},',

sumti = Cc'\n{tag="sumti",' *
  sumti_1 * (VUhO_clause * free^0 * relative_clauses)^-1
  * Cc'},',

sumti_1 = --Cc'\n{tag="sumti 1",' *
  sumti_2 * (  
    joik_ek * stag^-1 * KE_clause * free^0 * sumti *
    (KEhE_clause + Cc'\n{tag="*ELIDED","KEhE"},') * free^0
    )^-1,
  --* Cc'},',

sumti_2 = --Cc'\n{tag="sumti 2",' *
  sumti_3 * (joik_ek * sumti_3)^0,
  --* Cc'},',

sumti_3 = --Cc'\n{tag="sumti 3",' *  
  sumti_4 * (joik_ek * stag^-1 * BO_clause * free^0 * sumti_3)^-1,
  --* Cc'},',

sumti_4 = --Cc'\n{tag="sumti 4",' * (
  sumti_5 +
  gek * sumti * gik * sumti_4,
  --) * Cc'},',

sumti_5 = --Cc'\n{tag="sumti 5",' * (  
  quantifier^-1 * sumti_6 * relative_clauses^-1 +
  quantifier * selbri * (KU_clause + Cc'\n{tag="*ELIDED","KU"},') * free^0 *
    relative_clauses^-1,
  --) * Cc'},',

sumti_6 = --Cc'\n{tag="sumti 6",' * ( -- re-arranged
  Cc'\n{tag="<description>",' * LE_clause *
    free^0 * sumti_tail * (KU_clause + Cc'\n{tag="*ELIDED","KU"},') *
    free^0 * 
    Cc'},\n{tag="</description>",""},' +
  Cc'\n{tag="<name>",' * LA_clause *
    free^0 * sumti_tail * (KU_clause + Cc'\n{tag="*ELIDED","KU"},') *
    free^0 *
    Cc'},\n{tag="</name>",""},' +
  KOhA_clause * free^0 +    
  Cc'\n{tag="<name>",' * LA_clause * free^0 * relative_clauses^-1 *
    CMENE_clause^1 * free^0 * Cc'},' +
  Cc'\n{tag="<single word quote>",'* ZO_clause * free^0 * Cc'},' +
  ZOI_clause * free^0 +
  Cc'\n{tag="<word quotation>",' *
    LOhU_clause * free^0
    * Cc'},\n{tag="</word quotation>",""},' +
  lerfu_string * -MOI_clause * (BOI_clause + Cc'\n{tag="*ELIDED","BOI"},') *
    free^0 +
  Cc'\n{tag="<text quotation>",' *
    LU_clause * text * Cc',' * (LIhU_clause + Cc'\n{tag="*ELIDED","LIhU"},') *
    free^0 
    * Cc'},\n{tag="</text quotation>",""},' +
  (Cc'\n{tag="<referent of>",' * LAhE_clause +
   Cc'\n{tag="<scalar contrary>",' * NAhE_clause * BO_clause)* free^0 *
    relative_clauses^-1 * sumti * (LUhU_clause + Cc'\n{tag="*ELIDED","LUhU"},') *
    free^0 * Cc'},' +
  li_clause,
  --) * Cc'},',

li_clause = Cc'\n{tag="li clause",' *
  LI_clause * free^0 * mex * (LOhO_clause + Cc'\n{tag="*ELIDED","LOhO"},')
    * free^0
  * Cc'},',

sumti_tail = Cc'\n{tag="sumti tail",' * ( 
  (sumti_6 * relative_clauses^-1)^-1 * sumti_tail_1 +
  relative_clauses * sumti_tail_1
  ) * Cc'},',

sumti_tail_1 = --Cc'\n{tag="sumti tail 1",' * ( -- !!! simplified
  selbri * relative_clauses^-1 +
  quantifier * (selbri * relative_clauses^-1 + sumti),
  --) * Cc'},',

relative_clauses = Cc'\n{tag="relative clauses",' *
  relative_clause * (ZIhE_clause * free^0 * relative_clause)^0
  * Cc'},',

relative_clause = Cc'\n{tag="relative clause",' *
  (  
  GOI_clause * free^0 * term * (GEhU_clause + Cc'\n{tag="*ELIDED","GEhU"},') +
  NOI_clause * free^0 * subsentence *
    (KUhO_clause + Cc'\n{tag="*ELIDED","KUhO"},')
  ) * free^0
  * Cc'},',

selbri = Cc'\n{tag="selbri",' *
  tag^-1 * selbri_1
  * Cc'},',  

selbri_1 = --Cc'\n{tag="selbri 1",' * (  
  selbri_2 +
  NA_clause * free^0 * selbri,
  --) * Cc'},',

selbri_2 = --Cc'\n{tag="selbri 2",' *  
  selbri_3 * (CO_clause * free^0 * selbri_2)^-1,
  --* Cc'},',

selbri_3 = --Cc'\n{tag="selbri 3",' *
  selbri_4^1,
  --* Cc'},', 

selbri_4 = --Cc'\n{tag="selbri 4",' *
  selbri_5 * ( 
    joik_jek * selbri_5 +
    joik * stag^-1 * Cc'\n{tag="<grouping>",' * KE_clause * free^0 * selbri_3 *
      (KEhE_clause + Cc'\n{tag="*ELIDED","KEhE"},') * free^0 *
      Cc'},\n{tag="</grouping>",""},'
    )^0,
  --* Cc'},',

selbri_5 = --Cc'\n{tag="selbri 5",' *
  selbri_6 * ((jek + joik) * stag^-1 * BO_clause * free^0 * selbri_5)^-1,
  --* Cc'},',

selbri_6 = --Cc'\n{tag="selbri 6",' * ( 
  tanru_unit * (BO_clause * free^0 * selbri_6)^-1 +
  NAhE_clause^-1 * free^0 * guhek * selbri * gik * selbri_6,
  --) * Cc'},',

tanru_unit = Cc'\n{tag="tanru unit",' * 
  tanru_unit_1 * (CEI_clause * free^0 * tanru_unit_1)^0
  * Cc'},',

tanru_unit_1 = --Cc'\n{tag="tanru unit 1",' * 
  tanru_unit_2 * linkargs^-1,
  --* Cc'},',

tanru_unit_2 = --Cc'\n{tag="tanru unit 2",' * (
  zei_lujvo * free^0 +  -- ADDED BY VV, must be checked !!!!  !!!!! !!!!!
  BRIVLA_clause * free^0 +
  Cc'\n{tag="<recent bridi>",' * GOhA_clause * RAhO_clause^-1 * free^0 * Cc'},' +
  Cc'\n{tag="<grouping>",' * KE_clause * free^0 * selbri_3 *
    (KEhE_clause + Cc'\n{tag="*ELIDED","KEhE"},') * free^0 *
    Cc'},\n{tag="</grouping>",""},' +
  Cc'\n{tag="<sumti to selbri>",' *
    ME_clause * free^0 * (sumti + lerfu_string) *
    (MEhU_clause + Cc'\n{tag="*ELIDED","MEhU"},') * free^0 * MOI_clause^-1 *
    free^0 * Cc'},\n{tag="</sumti to selbri>",""},' +
  (number + lerfu_string) * MOI_clause * free^0 +
  Cc'\n{tag="<operator to selbri>",' * NUhA_clause * free^0 * mex_operator * Cc'},'+
  SE_clause * free^0 * tanru_unit_2 +
  Cc'\n{tag="<modal conversion>",' * JAI_clause * free^0 * tag^-1 *
    tanru_unit_2 * Cc'},\n{tag="</modal conversion>",""},' +
  NAhE_clause * free^0 * tanru_unit_2 +
  Cc'\n{tag="<abstraction>",' * NU_clause * NAI_clause^-1 * free^0 *
    (joik_jek * NU_clause * NAI_clause^-1 * free^0)^0 * subsentence *
    (KEI_clause + Cc'\n{tag="*ELIDED","KEI"},') *
    free^0 * Cc'},\n{tag="</abstraction>",""},',
  --) * Cc'},',

zei_lujvo = Cc'\n{tag="<zei lujvo>",' *  -- ADDED by VV, must be checked !!!
  (any_word * ZEI)^1 * (BRIVLA + (CMAVO + CMENE) * #BRIVLA_clause)
  * Cc'},\n{tag="</zei lujvo>",""},',
  
linkargs = Cc'\n{tag="linkargs",' *
  BE_clause * free^0 * term * links^-1 *
    (BEhO_clause + Cc'\n{tag="*ELIDED","BEhO"},') * free^0 *
  Cc'},',

links = Cc'\n{tag="links",' *
  BEI_clause * free^0 * term * links^-1
  * Cc'},',

quantifier = Cc'\n{tag="quantifier",' * ( 
  number * -MOI_clause * (BOI_clause + Cc'\n{tag="*ELIDED","BOI"},') +
  VEI_clause * free^0 * mex * (VEhO_clause + Cc'\ntag="*ELIDED","VEhO"},')
  ) * free^0
  * Cc'},', 

mex = Cc'\n{tag="mex",' * (
  mex_1 * (operator * mex_1)^0 +
  rp_clause
  ) * Cc'},',

rp_clause = Cc'\n{tag="rp clause",' *
  FUhA_clause * free^0 * rp_expression
  * Cc'},',

mex_1 = --Cc'\n{tag="mex 1",' * 
  mex_2 * (BIhE_clause * free^0 * operator * mex_1)^-1,
  --* Cc'},',

mex_2 = --Cc'\n{tag="mex_2",' * (
  operand +
  mex_forethought,
  --) * Cc'},', 

mex_forethought = Cc'\n{tag="mex forethought",' * 
  PEhO_clause^-1 * free^0 * operator * fore_operands *
    (KUhE_clause + Cc'\n{tag="*ELIDED","KUhE"},') * free^0
  * Cc'},',

fore_operands = Cc'\n{tag="fore operands",' *
  mex_2^1
  * Cc'},', 

rp_expression = operand * -operand +  -- VV, output bracketing, matter of taste 
  Cc'\n{tag="rp expression",' *
    operand * rp_expression_tail
  * Cc'},', 

rp_expression_tail = Cc'\n{tag="rp expression tail",' *  
  (rp_expression * operator * rp_expression_tail)^-1
  * Cc'},',


operator = Cc'\n{tag="operator",' *
  operator_1 * ( 
    joik_jek * operator_1 +
    joik * stag^-1 * Cc'\n{tag="grouping",' * KE_clause * free^0 * operator *
      (KEhE_clause + Cc'\n{tag="*ELIDED","KEhE"},') * free^0
    )^0
  * Cc'},',


operator_1 = --Cc'\n{tag="operator 1",' * (  
  operator_2 + 
  guhek * operator_1 * gik * operator_2 +
  operator_2 * (jek + joik) * stag^-1 * BO_clause * free^0 * operator_1,
  --) * Cc'},',

operator_2 = --Cc'\n{tag="operator 2",' * (
  mex_operator +  
  KE_clause * free^0 * operator * (KEhE_clause * Cc'\n{tag="*ELIDED","KEhE"},') *
  free^0,
  --) * Cc'},',

mex_operator = Cc'\n{tag="mex operator",' * (  
  SE_clause * free^0 * mex_operator +
  NAhE_clause * free^0 * mex_operator +
  MAhO_clause * free^0 * mex * (TEhU_clause + Cc'\n{tag="*ELIDED","TEhU"},') *
    free^0 +
  NAhU_clause * free^0 * selbri *
    (TEhU_clause + Cc'\n[tag="*ELIDED","TEhU"},') * free^0 +
  VUhU_clause * free^0
  ) * Cc'},',

operand = --Cc'\n{tag="operand",' *
  operand_1 * (joik_ek * stag^-1 * KE_clause * free^0 * operand *
    (KEhE_clause + Cc'\n{tag="*ELIDED","KEhE"},') * free^0)^-1,
  --* Cc'},',  

operand_1 = --Cc'\n{tag="operand 1",' *
  operand_2 * (joik_ek * operand_2)^0,
  --* Cc'},',

operand_2 = --Cc'\n{tag="operand 2",' *
  operand_3 * (joik_ek * stag^-1 * BO_clause * free^0 * operand_2)^-1,
  --* Cc'},',

operand_3 = --Cc'\n{tag="operand 3",' * (  
  quantifier +
  lerfu_string * -MOI_clause *
    (BOI_clause + Cc'\n{tag="*ELIDED","BOI"},') * free^0 +
  NIhE_clause * free^0 * selbri * (TEhU_clause + Cc'\n{tag="*ELIDED","TEhU"},') *
    free^0 +
  MOhE_clause * free^0 * sumti * (TEhU_clause + Cc'\n{tag="*ELIDED","TEhU"},') *
    free^0 +
  JOhI_clause * free^0 * mex_2^1 *
    (TEhU_clause + Cc'\n{tag="*ELIDED","TEhU"},') * free^0 +
  gek * operand * gik * operand_3 +
  (LAhE_clause * free^0 + NAhE_clause * BO_clause * free^0) * operand *
    (LUhU_clause + Cc'\n{tag="*ELIDED","LUhU"},') * free^0,
  --) * Cc'},',

number = Cc'\n{tag="number",' *
  PA_clause * (PA_clause + lerfu_word)^0
  * Cc'},',

lerfu_string = Cc'\n{tag="lerfu string",' *
  lerfu_word * (PA_clause + lerfu_word)^0
  * Cc'},',

lerfu_word = Cc'\n{tag="lerfu word",' * (  
  BY_clause +
  LAU_clause * lerfu_word +
  TEI_clause * lerfu_string * FOI_clause
  ) * Cc'},',

ek = Cc'\n{tag="ek",' *
  NA_clause^-1 * SE_clause^-1 * A_clause * NAI_clause^-1
  * Cc'},',

gihek = Cc'\n{tag="gihek",' *
  NA_clause^-1 * SE_clause^-1 * GIhA_clause * NAI_clause^-1
  * Cc'},',

jek = Cc'\n{tag="jek",' *
  NA_clause^-1 * SE_clause^-1 * JA_clause * NAI_clause^-1
  * Cc'},',

joik = Cc'\n{tag="joik",' * (  
  SE_clause^-1 * JOI_clause * NAI_clause^-1 +
  interval +
  GAhO_clause * interval * GAhO_clause
  ) * Cc'},',

interval = Cc'\n{tag="interval",' *
  SE_clause^-1 * BIhI_clause * NAI_clause^-1
  * Cc'},',

joik_ek = Cc'\n{tag="joik ek",' * (
  joik * free^0 +
  ek * free^0
  ) * Cc'},', 

joik_jek = Cc'\n{tag="joik jek",' * (
  joik * free^0 +
  jek * free^0
  ) * Cc'},',   

gek = Cc'\n{tag="gek",' * (  
  SE_clause^-1 * GA_clause * NAI_clause^-1 * free^0 +
  joik * GI_clause * free^0 +
  stag * gik
  ) * Cc'},',

guhek = Cc'\n{tag="guhek",' *
  SE_clause^-1 * GUhA_clause * NAI_clause^-1 * free^0
  * Cc'},',

gik = Cc'\n{tag="gik",' *
  GI_clause * NAI_clause^-1 * free^0
  * Cc'},', 

tag = Cc'\n{tag="tag",' *
  tense_modal * (joik_jek * tense_modal)^0
  * Cc'},', 

stag = Cc'\n{tag="stag",' * (  
  simple_tense_modal * ((jek + joik) * simple_tense_modal)^0 +
  tense_modal * (joik_jek * tense_modal)^0
  ) * Cc'},',

tense_modal = Cc'\n{tag="tense modal",' *
  (  
  simple_tense_modal +
  FIhO_clause * free^0 * selbri *
    (FEhU_clause + Cc'\n{tag="*ELIDED","FEhU"},')
  ) * free^0
  * Cc'},',

simple_tense_modal = Cc'\n{tag="simple tense modal",' * ( 
  NAhE_clause^-1 * (
    SE_clause^-1 * BAI_clause * NAI_clause^-1 + --* KI_clause^-1 +
--  NAhE_clause^-1 * (
    (time * space^-1 + space * time^-1) * CAhA_clause^-1 +
--    (time * space^-1 + space * time^-1) * CAhA_clause +
--    (time * space^-1 + space * time^-1) +
    CAhA_clause
    ) * KI_clause^-1 +
  KI_clause +
  CUhE_clause
  ) * Cc'},',

time = Cc'\n{tag="time",' * ( -- factored
  ZI_clause * time_offset^0 * (ZEhA_clause *
    (PU_clause * NAI_clause^-1)^-1)^-1 * interval_property^0 +
--  ZI_clause^-1 * (
    time_offset^1 * (ZEhA_clause * (PU_clause * NAI_clause^-1)^-1)^-1 *
      interval_property^0 +
--    time_offset^0 * (
      ZEhA_clause * (PU_clause * NAI_clause^-1)^-1 * interval_property^0 +
      (ZEhA_clause * (PU_clause * NAI_clause^-1)^-1)^-1 * interval_property^1
--      )
--    )
  ) * Cc'},',

time_offset = Cc'\n{tag="time offset",' *
  PU_clause * NAI_clause^-1 * ZI_clause^-1
  * Cc'},',

space = Cc'\n{tag="space",' * (  -- factored
  VA_clause * space_offset^0 * space_interval^-1 *
    (MOhI_clause * space_offset)^-1 +
--  VA_clause^-1 * (
    space_offset^1 * space_interval^-1 * (MOhI_clause * space_offset)^-1 +
--    space_offset^0 * (
      space_interval * (MOhI_clause * space_offset)^-1 +
      space_interval^-1 *
      MOhI_clause * space_offset
--      )
--    )
  ) * Cc'},',

space_offset = Cc'\n{tag="space offset",' *
  FAhA_clause * NAI_clause^-1 * VA_clause^-1
  * Cc'},',

space_interval = Cc'\n{tag="space interval",' * (  
  (VEhA_clause * VIhA_clause + VEhA_clause + VIhA_clause) *
    (FAhA_clause * NAI_clause^-1)^-1 * space_int_props^-1 +
-- (VEhA_clause + VIhA_clause + VEhA_clause * VIhA_clause) *
--    (FAhA_clause * NAI_clause^-1)^-1 +  -- combined with the above rule 
  space_int_props
  ) * Cc'},',

space_int_props = Cc'\n{tag="space int props",' *  
  (FEhE_clause * interval_property)^1 * Cc'},',

interval_property = Cc'\n{tag="interval property",' *
  (  
  number * ROI_clause +
  TAhE_clause +
  ZAhO_clause
  ) * NAI_clause^-1
  * Cc'},',

free = --Cc'\n{tag="<free>",' * (  
  Cc'\n{tag="<discursive bridi>",' * SEI_clause * free^0 *
    (terms * (CU_clause + Cc'\n{tag="*ELIDED","CU"},') * free^0)^-1 * selbri *
    (SEhU_clause + Cc'\n{tag="*ELIDED","SEhU"},') *
    Cc'},\n{tag="</discursive bridi>",""},' +
  Cc'\n{tag="<reciprocal sumti>",' * SOI_clause * free^0 * sumti * sumti^-1 *
    (SEhU_clause + Cc'\n{tag="*ELIDED","SEhU"},') *
    Cc'},\n{tag="</reciprocal sumti>",""},'+
  Cc'\n{tag="<vocative phrase>",' * vocative * (
    relative_clauses^-1 * (
      selbri +
      CMENE_clause^1 * free^0
      ) * relative_clauses^-1 +
    sumti^-1
    ) * (DOhU_clause + Cc'\n{tag="*ELIDED","DOhU"},') *
    Cc'},\n{tag="</vocative phrase>",""},' +
  Cc'\n{tag="<sentence ordinal>",' * (number + lerfu_string) * MAI_clause * Cc'},'+
  Cc'\n{tag="<parenthetical note>",' * TO_clause * text * Cc',' *
    (TOI_clause * Cc'\n{tag="*ELIDED","TOI"},') *
    Cc'},\n{tag="</parenthetical note>",""},' +
  xi_clause +
  Y_clause
  , --) * Cc'},\n{tag="</free>",""},',

xi_clause = Cc'\n{tag="<subscript>",' *
  XI_clause * free^0 * ( 
    (number + lerfu_string) * (BOI_clause + Cc'\n{tag="*ELIDED","BOI"},') +
    VEI_clause * free^0 * mex * (VEhO_clause + Cc'\n{tag="*ELIDED","VEhO"},')
    )
  * Cc'},\n{tag="</subscript>",""},',

-- ?? xi_clause = XI * free^0 * quantifier ??

vocative = Cc'\n{tag="vocative",' * (  
  (COI_clause * NAI_clause^-1)^1 * DOI_clause^-1 +
  DOI_clause
  ) * Cc'},',

indicators = Cc'\n{tag="indicators",' *
  FUhE_clause^-1 * indicator^1
  * Cc'},',

indicator = Cc'\n{tag="indicator",' *
  (  
  (UI_clause + CAI_clause) * NAI_clause^-1 +
  DAhO_clause +
  FUhO_clause
  ) * -BU_clause
  * Cc'},',

-- Magic Words ------------------------------------------------------------

-- NB NB NB : THIS SECTION MUST STILL BE CHECKED !!!!!!!!!

-- zei_clause = pre_zei_bu * (zei_tail^-1 * bu_tail)^0 * zei_tail,

bu_clause  = pre_zei_bu * (bu_tail^-1 * zei_tail)^0 * bu_tail,

zei_tail   = (ZEI_clause * any_word)^1,
bu_tail    = BU_clause^1,

pre_zei_bu = LOhU_pre +
             ZO_pre +
             ZOI_pre +
             -ZEI_clause * -BU_clause * -FAhO_clause * any_word,

-------------------------------------------------------------------------------

post_clause = spaces^-1 * -ZEI_clause * -BU_clause * indicators^0, 

pre_clause = BAhE_clause^-1,  

-------------------------------------------------------------------------------

BRIVLA_clause = pre_clause * BRIVLA * spaces^-1 * post_clause,

  -- + zei_clause, -- NB !!!! moved to selbri, must be checked !!!!

CMENE_clause = pre_clause * CMENE * spaces^-1 * post_clause, 

-------------------------------------------------------------------------------

--         eks; basic afterthought logical connectives 
A_clause = pre_clause * A * post_clause,

--         modal operators 
BAI_clause = pre_clause * BAI * post_clause,

--         next word intensifier 
BAhE_clause = BAhE * spaces^-1 * -ZEI_clause * -BU_clause,

--         sumti link to attach sumti to a selbri 
BE_clause = pre_clause * BE * post_clause,

--         multiple sumti separator between BE, BEI 
BEI_clause = pre_clause * BEI * post_clause,

--         terminates BEBEI specified descriptors 
BEhO_clause = pre_clause * BEhO * post_clause,

--         prefix for high_priority MEX operator 
BIhE_clause = pre_clause * BIhE * post_clause,

--         interval component of JOI 
BIhI_clause = pre_clause * BIhI * post_clause,

--         joins two units with shortest scope 
BO_clause = Cc'\n{tag="short scope link",' *
              pre_clause * BO * post_clause *
              Cc'},',

--         number or lerfu_string terminator 
BOI_clause = pre_clause * BOI * post_clause,

--         turns any word into a BY lerfu word 
BU_clause = pre_clause * BU * spaces^-1,

--         individual lerfu words 
BY_clause = pre_clause * (bu_clause + BY) * post_clause, -- !!!! bu_clause

--         specifies actualitypotentiality of tense 
CAhA_clause = pre_clause * CAhA * post_clause,

--         afterthought intensity marker 
CAI_clause = pre_clause * CAI * post_clause,

--         pro_bridi assignment operator 
CEI_clause = pre_clause * CEI * post_clause,

--         afterthought term list connective 
CEhE_clause = pre_clause * CEhE * post_clause,

--         tanru inversion  
CO_clause = pre_clause * CO * post_clause,


COI_clause = pre_clause * COI * post_clause,

--         separator between head sumti and selbri 
CU_clause = Cc'\n{tag="<CU clause>",' *
  pre_clause * CU * post_clause
  * Cc'},',

--         tensemodal question 
CUhE_clause = pre_clause * CUhE * post_clause,

--         cancel anaphoracataphora assignments 
DAhO_clause = pre_clause * DAhO * post_clause,

--         vocative marker 
DOI_clause = pre_clause * DOI * post_clause,

--         terminator for DOI_marked vocatives 
DOhU_clause = pre_clause * DOhU * post_clause,

--         modifier head generic case tag 
FA_clause = pre_clause * FA * post_clause,

--         superdirections in space 
FAhA_clause = pre_clause * FAhA * post_clause,

FAhO_clause = pre_clause * FAhO * spaces^-1,

--         space interval mod flag 
FEhE_clause = pre_clause * FEhE * post_clause,

--         ends bridi to modal conversion 
FEhU_clause = pre_clause * FEhU * post_clause,

--         marks bridi to modal conversion 
FIhO_clause = pre_clause * FIhO * post_clause,

--         end compound lerfu 
FOI_clause = pre_clause * FOI * post_clause,

--         reverse Polish flag 
FUhA_clause = pre_clause * FUhA * post_clause,

--         open long scope for indicator 
FUhE_clause = pre_clause * FUhE * post_clause,

--         close long scope for indicator 
FUhO_clause = pre_clause * FUhO * post_clause,

--         geks; forethought logical connectives 
GA_clause = pre_clause * GA * post_clause,

--         openclosed interval markers for BIhI 
GAhO_clause = pre_clause * GAhO * post_clause,

--         marker ending GOI relative clauses 
GEhU_clause = pre_clause * GEhU * post_clause,

--         forethought medial marker 
GI_clause = pre_clause * GI * post_clause,

--         logical connectives for bridi_tails 
GIhA_clause = pre_clause * GIhA * post_clause,

--         attaches a sumti modifier to a sumti 
GOI_clause = pre_clause * GOI * post_clause,

--         pro_bridi 
GOhA_clause = pre_clause * GOhA * post_clause,

--         GEK for tanru units, corresponds to JEKs 
GUhA_clause = pre_clause * GUhA * post_clause,

--         sentence link 
I_clause = Cc'\n{tag="<I clause>",' *
  pre_clause * I * post_clause
  * Cc'},',

--         jeks; logical connectives within tanru 
JA_clause = Cc'\n{tag="JA clause",' *
  pre_clause * JA * post_clause
  * Cc'},',

--         modal conversion flag 
JAI_clause = pre_clause * JAI * post_clause,

--         flags an array operand 
JOhI_clause = pre_clause * JOhI * post_clause,

--         non_logical connectives 
JOI_clause = pre_clause * JOI * post_clause,

--         left long scope marker 
KE_clause = pre_clause * KE * post_clause,

--         right terminator for KE groups 
KEhE_clause = pre_clause * KEhE * post_clause,

--         right terminator, NU abstractions 
KEI_clause = pre_clause * KEI * post_clause,

--         multiple utterance scope for tenses 
KI_clause = pre_clause * KI * post_clause,

--         sumti anaphora 
KOhA_clause = pre_clause * KOhA * spaces^-1 * post_clause,

--         right terminator for descriptions, etc. 
KU_clause = pre_clause * KU * post_clause,

--         MEX forethought delimiter 
KUhE_clause = pre_clause * KUhE * post_clause,

--         right terminator, NOI relative clauses 
KUhO_clause = pre_clause * KUhO * post_clause,

--         name descriptors 
LA_clause = pre_clause * LA * post_clause,

--         lerfu prefixes 
LAU_clause = pre_clause * LAU * post_clause,

--         sumti qualifiers 
LAhE_clause = pre_clause * LAhE * post_clause,

--         sumti descriptors 
LE_clause = pre_clause * LE * post_clause,

--         possibly ungrammatical text right quote 

LEhU_clause = pre_clause * LEhU * post_clause,

--         convert number to sumti 
LI_clause = pre_clause * LI * post_clause,

--         grammatical text right quote 
LIhU_clause = pre_clause * LIhU * post_clause,

--         elidable terminator for LI 
LOhO_clause = pre_clause * LOhO * post_clause,

--         possibly ungrammatical text left quote
LOhU_clause = --Cc'\n{tag="LOhU clause",' *
  LOhU_pre * post_clause,
  --* Cc'},',
LOhU_pre = pre_clause * LOhU * spaces^-1 * (-LEhU * any_word)^0 * LEhU_clause *
  spaces^-1,

--         grammatical text left quote 
LU_clause = pre_clause * LU * post_clause,

--         LAhE close delimiter 
LUhU_clause = pre_clause * LUhU * post_clause,

--         change MEX expressions to MEX operators 
MAhO_clause = pre_clause * MAhO * post_clause,

--         change numbers to utterance ordinals 
MAI_clause = pre_clause * MAI * post_clause,

--         converts a sumti into a tanru_unit 
ME_clause = pre_clause * ME * post_clause,

--         terminator for ME 
MEhU_clause = pre_clause * MEhU * post_clause,

--         change sumti to operand, inverse of LI 
MOhE_clause = pre_clause * MOhE * post_clause,

--         motion tense marker 
MOhI_clause = pre_clause * MOhI * post_clause,

--         change number to selbri 
MOI_clause = pre_clause * MOI * post_clause,

--         bridi negation  
NA_clause = pre_clause * NA * post_clause,

--         attached to words to negate them 
NAI_clause = pre_clause * NAI * post_clause,

--         scalar negation  
NAhE_clause = pre_clause * NAhE * post_clause,

--         change a selbri into an operator 
NAhU_clause = pre_clause * NAhU * post_clause,

--         change selbri to operand; inverse of MOI 
NIhE_clause = pre_clause * NIhE * post_clause,

--         new paragraph; change of subject 
NIhO_clause = pre_clause * NIhO * post_clause,

--         attaches a subordinate clause to a sumti 
NOI_clause = pre_clause * NOI * post_clause,

--         abstraction  
NU_clause = pre_clause * NU * post_clause,

--         change operator to selbri; inverse of MOhE 
NUhA_clause = pre_clause * NUhA * post_clause,

--         marks the start of a termset 
NUhI_clause = pre_clause * NUhI * post_clause,

--         marks the middle and end of a termset 
NUhU_clause = pre_clause * NUhU * post_clause,

--         numbers and numeric punctuation 
PA_clause = pre_clause * PA * post_clause,

--         afterthought termset connective prefix 
PEhE_clause = pre_clause * PEhE * post_clause,

--         forethought (Polish) flag 
PEhO_clause = pre_clause * PEhO * post_clause,

--         directions in time 
PU_clause = pre_clause * PU * post_clause,

--         flag for modified interpretation of GOhI 
RAhO_clause = pre_clause * RAhO * post_clause,

--         converts number to extensional tense 
ROI_clause = pre_clause * ROI * post_clause,

--         conversions 
SE_clause = pre_clause * SE * post_clause,

--         metalinguistic bridi insert marker 
SEI_clause = pre_clause * SEI * post_clause,

--         metalinguistic bridi end marker 
SEhU_clause = pre_clause * SEhU * post_clause,

--         reciprocal sumti marker 
SOI_clause = pre_clause * SOI * post_clause,

--         tense interval properties 
TAhE_clause = pre_clause * TAhE * post_clause,

--         closing gap for MEX constructs 
TEhU_clause = pre_clause * TEhU * post_clause,

--         start compound lerfu 
TEI_clause = pre_clause * TEI * post_clause,

--         left discursive parenthesis 
TO_clause = pre_clause * TO * post_clause,

--         right discursive parenthesis 
TOI_clause = pre_clause * TOI * post_clause,

--         multiple utterance scope mark 
TUhE_clause = pre_clause * TUhE * post_clause,

--         multiple utterance end scope mark 
TUhU_clause = pre_clause * TUhU * post_clause,

--         attitudinals, observationals, discursives 
UI_clause = pre_clause * UI * post_clause,

--         distance in space_time 
VA_clause = pre_clause * VA * post_clause,

--         end simple bridi or bridi_tail 
VAU_clause = pre_clause * VAU * post_clause,

--         left MEX bracket 
VEI_clause = pre_clause * VEI * post_clause,

--         right MEX bracket 
VEhO_clause = pre_clause * VEhO * post_clause,

--         MEX operator 
VUhU_clause = pre_clause * VUhU * post_clause,

--         space_time interval size 
VEhA_clause =  pre_clause * VEhA * post_clause,

--         space_time dimensionality marker 
VIhA_clause = pre_clause * VIhA * post_clause,

-- glue between logically connected sumti and relative clauses
VUhO_clause = pre_clause * VUhO * post_clause,

--         subscripting operator 
XI_clause = pre_clause * XI * post_clause,

--         hesitation 
-- NB test version

Y_clause = Cc'\n{tag="hesitation",' * spaces^-1 * Y * spaces^-1 * Cc'},',

--         event properties _ inchoative, etc. 
ZAhO_clause = pre_clause * ZAhO * post_clause,

--         time interval size tense 
ZEhA_clause = pre_clause * ZEhA * post_clause,

--         lujvo glue 
ZEI_clause = pre_clause * ZEI * post_clause,

--         time distance tense 
ZI_clause = pre_clause * ZI * post_clause,

--         conjoins relative clauses 
ZIhE_clause = pre_clause * ZIhE * post_clause,

--         single word metalinguistic quote marker 
ZO_clause = ZO_pre * post_clause,
ZO_pre    = pre_clause * ZO * spaces^-1 * any_word * spaces^-1,

--         delimited quote marker 
ZOI_clause = Cc'\n{tag="non-Lojban quotation",' *
  ZOI_pre * post_clause
  * Cc'},',
ZOI_pre    = pre_clause * ZOI * spaces^-1 * zoi_open * zoi_word^0 * zoi_close *
             spaces^-1,

--         prenex terminator (not elidable) 
ZOhU_clause = pre_clause * ZOhU * post_clause,

inner_word   = (-close_paren * P(1))^1,

tail         = inner_word/inner_tail,

space_char   = P' ',
equals_char  = P'=',
open_paren   = P"(",
close_paren  = P")",
close_dparen = P"))",

--         any single lexable Lojban words 
any_word = (CMAVO + BRIVLA + CMENE) * spaces^-1,

spaces = (spaces_pre * inner_word * close_paren)^0,
spaces_pre = P" spaces=( " + " initialSpaces=( ",

dot_star = P(1)^0,
EOF = P(-1),

-------------------------------------------------------------------------------
--
-- non-Lojban quote handling

-- NB. morpholy section has combined the whole quote into a single
--     non-L word

zoi_open = Cmt(any_word,catch_word),

zoi_word = spaces^-1 * -Cmt(any_word,match_word) * non_Lojban_word,

zoi_close = spaces^-1 * Cmt(any_word,match_word), 

-------------------------------------------------------------------------------

non_Lojban_word = P" nonL(" *
--  (inner_word/'\n{tag="non-L","%0"},') * close_paren,
  Cf(Cc'\n{tag="non-L",' * (inner_word/split) *
  close_paren * Cc'},',cumul),

CMAVO = P" C(" * Cf(Cc'\n{tag="CMAVO",' * (inner_word/split) *
  close_paren * Cc'},',cumul),

BRIVLA = P" B(" * Cf(Cc'\n{tag="BRIVLA",' * (inner_word/split) *
  close_paren * Cc'},',cumul),

CMENE = P" N(" * (inner_word/'\n{tag="CMENE","%0"},') * close_paren,

A = P" C(A/" * (Cc"A" * tail)/frame * close_paren,

BAI = P" C(BAI/" * (Cc"BAI" * tail)/frame * close_paren,

BAhE = P" C(BAhE/" * (Cc"BAhE" * tail)/frame * close_paren,

BE = P" C(BE/" * (Cc"BE" * tail)/frame * close_paren,

BEI = P" C(BEI/" * (Cc"BEI" * tail)/frame * close_paren,

BEhO = P" C(BEhO/" * (Cc"BEhO" * tail)/frame * close_paren,

BIhE = P" C(BIhE/" * (Cc"BIhE" * tail)/frame * close_paren,

BIhI = P" C(BIhI/" * (Cc"BIhI" * tail)/frame * close_paren,

BO = P" C(BO/" * (Cc"BO" * tail)/frame * close_paren,

BOI = P" C(BOI/" * (Cc"BOI" * tail)/frame * close_paren,

BU = P" C(BU/" * (Cc"BU" * tail)/frame * close_paren,

BY = P" C(BY/" * (Cc"BY" * tail)/frame * close_paren,

CAhA = P" C(CAhA/" * (Cc"CAhA" * tail)/frame * close_paren,

CAI = P" C(CAI/" * (Cc"CAI" * tail)/frame * close_paren,

CEI = P" C(CEI/" * (Cc"CEI" * tail)/frame * close_paren,

CEhE = P" C(CEhE/" * (Cc"CEhE" * tail)/frame * close_paren,

CO = P" C(CO/" * (Cc"CO" * tail)/frame * close_paren,

COI = P" C(COI/" * (Cc"COI" * tail)/frame * close_paren,

CU = P" C(CU/" * ((Cc"CU" * tail)/frame) * close_paren,

CUhE = P" C(CUhE/" * (Cc"CUhE" * tail)/frame * close_paren,

DAhO = P" C(DAhO/" * (Cc"DAhO" * tail)/frame * close_paren,

DOI = P" C(DOI/" * (Cc"DOI" * tail)/frame * close_paren,

DOhU = P" C(DOhU/" * (Cc"DOhU" * tail)/frame * close_paren,

FA = P" C(FA/" * (Cc"FA" * tail)/frame * close_paren,

FAhA = P" C(FAhA/" * (Cc"FAhA" * tail)/frame * close_paren,

FAhO = P" C(FAhO/" * (Cc"FAhO" * tail)/frame * close_paren,

FEhE = P" C(FEhE/" * (Cc"FEhE" * tail)/frame * close_paren,

FEhU = P" C(FEhU/" * (Cc"FEhI" * tail)/frame * close_paren,

FIhO = P" C(FIhO/" * (Cc"FIhO" * tail)/frame * close_paren,

FOI = P" C(FOI/" * (Cc"FOI" * tail)/frame * close_paren,

FUhA = P" C(FUhA/" * (Cc"FUhA" * tail)/frame * close_paren,

FUhE = P" C(FUhE/" * (Cc"FUhE" * tail)/frame * close_paren,

FUhO = P" C(FUhO/" * (Cc"FUhO" * tail)/frame * close_paren,

GA = P" C(GA/" * (Cc"GA" * tail)/frame * close_paren,

GAhO = P" C(GAhO/" * (Cc"GAhO" * tail)/frame * close_paren,

GEhU = P" C(GEhU/" * (Cc"GEhU" * tail)/frame * close_paren,

GI = P" C(GI/" * (Cc"GI" * tail)/frame * close_paren,

GIhA = P" C(GIhA/" * (Cc"GIhA" * tail)/frame * close_paren,

GOI = P" C(GOI/" * (Cc"GOI" * tail)/frame * close_paren,

GOhA = P" C(GOhA/" * (Cc"GOhA" * tail)/frame * close_paren,

GUhA = P" C(GUhA/" * (Cc"GUhA" * tail)/frame * close_paren,

I = P" C(I/" * (Cc"I" * tail)/frame * close_paren,

JA = P" C(JA/" * (Cc"JA" * tail)/frame * close_paren,

JAI = P" C(JAI/" * (Cc"JAI" * tail)/frame * close_paren,

JOhI = P" C(JOhI/" * (Cc"JOhI" * tail)/frame * close_paren,

JOI = P" C(JOI/" * (Cc"JOI" * tail)/frame * close_paren,

KE = P" C(KE/" * (Cc"KE" * tail)/frame * close_paren,

KEhE = P" C(KEhE/" * (Cc"KEhE" * tail)/frame * close_paren,

KEI = P" C(KEI/" * (Cc"KEI" * tail)/frame * close_paren,

KI = P" C(KI/" * (Cc"KI" * tail)/frame * close_paren,

KOhA = P" C(KOhA/" * (Cc"KOhA" * tail)/frame * close_paren,

KU = P" C(KU/" * (Cc"KU" * tail)/frame * close_paren,

KUhE = P" C(KUhE/" * (Cc"KUhE" * tail)/frame * close_paren,

KUhO = P" C(KUhO/" * (Cc"KUhO" * tail)/frame * close_paren,

LA = P" C(LA/" * (Cc"LA" * tail)/frame * close_paren,

LAU = P" C(LAU/" * (Cc"LAU" * tail)/frame * close_paren,

LAhE = P" C(LAhE/" * (Cc"LAhE" * tail)/frame * close_paren,

LE = P" C(LE/" * (Cc"LE" * tail)/frame * close_paren,

LEhU = P" C(LEhU/" * (Cc"LEhU" * tail)/frame * close_paren,

LI = P" C(LI/" * (Cc"LI" * tail)/frame * close_paren,

LIhU = P" C(LIhU/" * (Cc"LIhU" * tail)/frame * close_paren,

LOhO = P" C(LOhO/" * (Cc"LOhO" * tail)/frame * close_paren,

LOhU = P" C(LOhU/" * (Cc"LOhU" * tail)/frame * close_paren,

LU = P" C(LU/" * (Cc"LU" * tail)/frame * close_paren,

LUhU = P" C(LUhU/" * (Cc"LUhU" * tail)/frame * close_paren,

MAhO = P" C(MAhO/" * (Cc"MAhO" * tail)/frame * close_paren,

MAI = P" C(MAI/" * (Cc"MAI" * tail)/frame * close_paren,

ME = P" C(ME/" * (Cc"ME" * tail)/frame * close_paren,

MEhU = P" C(MEhU/" * (Cc"MEhU" * tail)/frame * close_paren,

MOhE = P" C(MOhE/" * (Cc"MOhE" * tail)/frame * close_paren,

MOhI = P" C(MOhI/" * (Cc"MOhI" * tail)/frame * close_paren,

MOI = P" C(MOI/" * (Cc"MOI" * tail)/frame * close_paren,

NA = P" C(NA/" * (Cc"NA" * tail)/frame * close_paren,

NAI = P" C(NAI/" * (Cc"NAI" * tail)/frame * close_paren,

NAhE = P" C(NAhE/" * (Cc"NAhE" * tail)/frame * close_paren,

NAhU = P" C(NAhU/" * (Cc"NAhU" * tail)/frame * close_paren,

NIhE = P" C(NIhE/" * (Cc"NIhE" * tail)/frame * close_paren,

NIhO = P" C(NIhO/" * (Cc"NIhO" * tail)/frame * close_paren,

NOI = P" C(NOI/" * (Cc"NOI" * tail)/frame * close_paren,

NU = P" C(NU/" * (Cc"NU" * tail)/frame * close_paren,

NUhA = P" C(NUhA/" * (Cc"NUhA" * tail)/frame * close_paren,

NUhI = P" C(NUhI/" * (Cc"NUhI" * tail)/frame * close_paren,

NUhU = P" C(NUhU/" * (Cc"NUhU" * tail)/frame * close_paren,

PA = P" C(PA/" * (Cc"PA" * tail)/frame * close_paren,

PEhE = P" C(PEhE/" * (Cc"PEhE" * tail)/frame * close_paren,

PEhO = P" C(PEhO/" * (Cc"PEhO" * tail)/frame * close_paren,

PU = P" C(PU/" * (Cc"PU" * tail)/frame * close_paren,

RAhO = P" C(RAhO/" * (Cc"RAhO" * tail)/frame * close_paren,

ROI = P" C(ROI/" * (Cc"ROI" * tail)/frame * close_paren,

SE = P" C(SE/" * (Cc"SE" * tail)/frame * close_paren,

SEI = P" C(SEI/" * (Cc"SEI" * tail)/frame * close_paren,

SEhU = P" C(SEhU/" * (Cc"SEhU" * tail)/frame * close_paren,

SOI = P" C(SOI/" * (Cc"SOI" * tail)/frame * close_paren,

TAhE = P" C(TAhE/" * (Cc"TAhE" * tail)/frame * close_paren,

TEhU = P" C(TEhU/" * (Cc"TEhU" * tail)/frame * close_paren,

TEI = P" C(TEI/" * (Cc"TEI" * tail)/frame * close_paren,

TO = P" C(TO/" * (Cc"TO" * tail)/frame * close_paren,

TOI = P" C(TOI/" * (Cc"TOI" * tail)/frame * close_paren,

TUhE = P" C(TUhE/" * (Cc"TUhE" * tail)/frame * close_paren,

TUhU = P" C(TUhU/" * (Cc"TUhU" * tail)/frame * close_paren,

UI = P" C(UI/" * (Cc"UI" * tail)/frame * close_paren,

VA = P" C(VA/" * (Cc"VA" * tail)/frame * close_paren,

VAU = P" C(VAU/" * (Cc"VAU" * tail)/frame * close_paren,

VEI = P" C(VEI/" * (Cc"VEI" * tail)/frame * close_paren,

VEhO = P" C(VEhO/" * (Cc"VEhO" * tail)/frame * close_paren,

VEhA = P" C(VEhA/" * (Cc"VEhA" * tail)/frame * close_paren,

VIhA = P" C(VIhA/" * (Cc"VIhA" * tail)/frame * close_paren,

VUhO = P" C(VUhO/" * (Cc"VUhO" * tail)/frame * close_paren,

VUhU = P" C(VUhU/" * (Cc"VUhU" * tail)/frame * close_paren,

XI = P" C(XI/" * (Cc"XI" * tail)/frame * close_paren,

Y = P" C(Y/" * (Cc"Y" * tail)/frame * close_paren,

ZAhO = P" C(ZAhO/" * (Cc"ZAhO" * tail)/frame * close_paren,

ZEhA = P" C(ZEhA/" * (Cc"ZEhA" * tail)/frame * close_paren,

ZEI = P" C(ZEI/" * (Cc"ZEI" * tail)/frame * close_paren,

ZI = P" C(ZI/" * (Cc"ZI" * tail)/frame * close_paren,

ZIhE = P" C(ZIhE/" * (Cc"ZIhE" * tail)/frame * close_paren,

ZO = P" C(ZO/" * (Cc"ZO" * tail)/frame * close_paren,

ZOI = P" C(ZOI/" * (Cc"ZOI" * tail)/frame * close_paren,

ZOhU = P" C(ZOhU/" * (Cc"ZOhU" * tail)/frame * close_paren
}

function parse(s)
  return lmatch(grammar,s)
end

function version()
  return "alpha 9 / July 8, 2012"
end
