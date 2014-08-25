--[[
  CAUTION: THIS IS JUST AN ALPHA VERSION AND MAY CONTAIN ERRORS

           RELEASED FOR PRELIMINARY EXPERIMENTATION AND FEEDBACK

           PENDING A THOROUGH INSPECTION, MAY AND PROBABLY STILL
           DOES IN SOME MINOR DETAIL CONTRADICT THE "OFFICIAL"
           SPECIFICATION

           veion (veijo.vilva@gmail.com)


 This Lua module is based on the PEG by xorxes for the morphology of Lojban.

 The original was modified by veion (veijo.vilva@gmail.com) to LPeg form
 (see below), with some optimizations.

 Requirements: lua5.1/luajit2 and LPeg library. Luajit doesn't seem to offer
 much benefit for the PEG but may make a difference in auxiliary operations.

 NB. LPeg doesn't employ Packrat methodology having been designed for pattern
     matching rather than for parsing. This means that this parser version
     handles complex words relatively or even abysmally slowly!

  lua    : http://www.lua.org
  luajit : http://luajit.org
  LPeg   : http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
           http://www.inf.puc-rio.br/~roberto/docs/peg.pdf (theoretical basis)
 
 All rules have the form 
 
 	name = peg_expression
 
 which means that the grammatical construct "name" is parsed using
 "peg_expression".  
 
 1)  Concatenation is expressed by juxtaposition with no operator symbol.
 2)  +   represents ORDERED alternation (choice).  If the first
         option succeeds, the others will never be checked.
 3)  ^-1 indicates that the element to the left is optional.
 4)  ^0  represents optional repetition of the construct to the left.
 5)  ^1  represents one_or_more repetition of the construct to the left.
 6)  ()  serves to indicate the grouping of the other operators.
 7)  #   indicates that the element to the right must follow (but the
         marked element itself does not absorb anything).
 8)  -   indicates that the element to the right must not follow (the
         marked element itself does not absorb anything).
 9)  .   represents any character.
 10) ' ' or " " represents a literal string.
 11) S"" represents a character class.    

 Repetitions grab as much as they can.

 The morphology grammar classifies words by their morphological class
 (cmene, gismu, lujvo, fuhivla, cmavo, and non_lojban_word). 
 
 The separate selma'o grammar assigns cmavo into grammatical classes
 (A, BAI, BAhE, ..., ZOhU).

 NB. some classes have been split into two in order to make it
     possible to test the longer cmavo before the shorter ones

--]]---------------------------------------------------------------------------

require"lpeg"

-- define visible external functions

local V      = lpeg.V
local P      = lpeg.P
local R      = lpeg.R
local S      = lpeg.S
local C      = lpeg.C
local Cc     = lpeg.Cc
local Ct     = lpeg.Ct
local Cmt    = lpeg.Cmt
local lmatch = lpeg.match
local print  = print
local match  = string.match
local len    = string.len
local sub    = string.sub
local find   = string.find
local gsub   = string.gsub

module(...)

-- gate function for fuhivla inclusion in lujvo

local check_fl -- the value for check_fl comes via function morphed

function fg(s,pos,w) -- calling convention: Cmt(P(true),fg) * fuhivla
  return check_fl
end

-- help functions for ZOI handling

function start_zoi(w)
  in_zoi = 1
  return '"ZOI","'..w..'"'
end

function check_zoi(s,pos,w)
-- temporary version: the non-L text/name must not contain a word starting with
-- the stop string
  if in_zoi then
    if in_zoi == 1 then in_zoi = 2
    else
      in_zoi = nil
      local delim = match(w,',"'.."([%a%']+)"..'"%)')
      if sub(s,pos,pos) == '.' then pos = pos+1 end
      local p = find(sub(s,pos),"%S")+pos-1
      local e = (find(sub(s,p),'[ %.]'..delim) or 0)+p
      local q = sub(s,p,e-2)
      local qs = q
      if len(q) > 12 then qs = sub(qs,1,12).."..." end
      w = w..'\nnon_lojban("\''..qs..'\'","'..q..'")\n'..w
      pos = e+len(delim)
      end
    end
  return pos,w
end

-- define shorthands for the non-terminals

selmaho = V"selmaho"

A     = V"A"
A2    = V"A2"
BAI   = V"BAI"
BAhE  = V"BAhE"
BE2   = V"BE2"
BEI   = V"BEI"
BEhO  = V"BEhO"
BIhE  = V"BIhE"
BIhI  = V"BIhI"
BO2   = V"BO2"
BOI   = V"BOI"
BU    = V"BU"
BY    = V"BY"
BY2   = V"BY2"
CAhA  = V"CAhA"
CAI   = V"CAI"
CEI   = V"CEI"
CEhE  = V"CEhE"
CO2   = V"CO2"
COI   = V"COI"
CU2   = V"CU2"
CUhE  = V"CUhE"
DAhO  = V"DAhO"
DOI   = V"DOI"
DOhU  = V"DOhU"
FA    = V"FA"
FA2   = V"FA2"
FAhA  = V"FAhA"
FAhO  = V"FAhO"
FEhE  = V"FEhE"
FEhU  = V"FEhU"
FIhO  = V"FIhO"
FOI   = V"FOI"
FUhA  = V"FUhA"
FUhE  = V"FUhE"
FUhO  = V"FUhO"
GA    = V"GA"
GA2   = V"GA2"
GAhO  = V"GAhO"
GEhU  = V"GEhU"
GI2   = V"GI2"
GIhA  = V"GIhA"
GOI   = V"GOI"
GOI2  = V"GOI2"
GOhA  = V"GOhA"
GOhA2 = V"GOhA2"
GUhA  = V"GUhA"
I2    = V"I2"
JA    = V"JA"
JA2   = V"JA2"
JAI   = V"JAI"
JOhI  = V"JOhI"
JOI   = V"JOI"
JOI2  = V"JOI2"
KE2   = V"KE2"
KEhE  = V"KEhE"
KEI   = V"KEI"
KI2   = V"KI2"
KOhA  = V"KOhA"
KOhA2 = V"KOhA2"
KU2   = V"KU2"
KUhE  = V"KUhE"
KUhO  = V"KUhO"
LA    = V"LA"
LA2   = V"LA2"
LAU   = V"LAU"
LAhE  = V"LAhE"
LE    = V"LE"
LE2   = V"LE2"
LEhU  = V"LEhU"
LI    = V"LI"
LI2   = V"LI2"
LIhU  = V"LIhU"
LOhO  = V"LOhO"
LOhU  = V"LOhU"
LU2   = V"LU2"
LUhU  = V"LUhU"
MAhO  = V"MAhO"
MAI   = V"MAI"
ME2   = V"ME2"
MEhU  = V"MEhU"
MOhE  = V"MOhE"
MOhI  = V"MOhI"
MOI   = V"MOI"
NA    = V"NA"
NA2   = V"NA2"
NAI   = V"NAI"
NAhE  = V"NAhE"
NAhU  = V"NAhU"
NIhE  = V"NIhE"
NIhO  = V"NIhO"
NOI   = V"NOI"
NU    = V"NU"
NU2   = V"NU2"
NUhA  = V"NUhA"
NUhI  = V"NUhI"
NUhU  = V"NUhU"
PA    = V"PA"
PA2   = V"PA2"
PEhE  = V"PEhE"
PEhO  = V"PEhO"
PU2   = V"PU2"
RAhO  = V"RAhO"
ROI   = V"ROI"
SA2   = V"SA2"
SE2   = V"SE2"
SEI   = V"SEI"
SEhU  = V"SEhU"
SI2   = V"SI2"
SOI   = V"SOI"
SU2   = V"SU2"
TAhE  = V"TAhE"
TEhU  = V"TEhU"
TEI   = V"TEI"
TO    = V"TO"
TO2   = V"TO2"
TOI   = V"TOI"
TUhE  = V"TUhE"
TUhU  = V"TUhU"
UI    = V"UI"
UI2   = V"UI2"
VA2   = V"VA2"
VAU   = V"VAU"
VEI   = V"VEI"
VEhO  = V"VEhO"
VUhU  = V"VUhU"
VEhA  = V"VEhA"
VIhA  = V"VIhA"
VUhO  = V"VUhO"
XI2   = V"XI2"
Y     = V"Y"
ZAhO  = V"ZAhO"
ZEhA  = V"ZEhA"
ZEI   = V"ZEI"
ZI2   = V"ZI2"
ZIhE  = V"ZIhE"
ZO2   = V"ZO2"
ZOI   = V"ZOI"
ZOhU  = V"ZOhU"

words                   = V"words"
word                    = V"word"
lojban_word             = V"lojban_word"
brivla                  = V"brivla"
cmene                   = V"cmene"
zifcme                  = V"zifcme"
jbocme                  = V"jbocme"
cmavo                   = V"cmavo"
CVCy_lujvo              = V"CVCy_lujvo"
cmavo_form              = V"cmavo_form"
lujvo                   = V"lujvo"
brivla_core             = V"brivla_core"
stressed_initial_rafsi  = V"stressed_initial_rafsi"
initial_rafsi           = V"initial_rafsi"
any_extended_rafsi      = V"any_extended_rafsi"
fuhivla                 = V"fuhivla"
stressed_extended_rafsi = V"stressed_extended_rafsi"
extended_rafsi          = V"extended_rafsi"
stressed_brivla_rafsi   = V"stressed_brivla_rafsi"
brivla_rafsi            = V"brivla_rafsi"
stressed_fuhivla_rafsi  = V"stressed_fuhivla_rafsi"
fuhivla_rafsi           = V"fuhivla_rafsi"
fuhivla_head            = V"fuhivla_head"
brivla_head             = V"brivla_head"
slinkuhi                = V"slinkuhi"
rafsi_string            = V"rafsi_string"
gismu                   = V"gismu"
CVV_final_rafsi         = V"CVV_final_rafsi"
short_final_rafsi       = V"short_final_rafsi"
stressed_y_rafsi        = V"stressed_y_rafsi"
stressed_y_less_rafsi   = V"stressed_y_less_rafsi"
stressed_long_rafsi     = V"stressed_long_rafsi"
stressed_CVC_rafsi      = V"stressed_CVC_rafsi"
stressed_CCV_rafsi      = V"stressed_CCV_rafsi"
stressed_CVV_rafsi      = V"stressed_CVV_rafsi"
y_rafsi                 = V"y_rafsi"
y_less_rafsi            = V"y_less_rafsi"
long_rafsi              = V"long_rafsi"
CVC_rafsi               = V"CVC_rafsi"
CCV_rafsi               = V"CCV_rafsi"
CVV_rafsi               = V"CVV_rafsi"
r_hyphen                = V"r_hyphen"
final_syllable          = V"final_syllable"
stressed_syllable       = V"stressed_syllable"
stressed_diphthong      = V"stressed_diphthong"
stressed_vowel          = V"stressed_vowel"
unstressed_syllable     = V"unstressed_syllable"
unstressed_diphthong    = V"unstressed_diphthong"
unstressed_vowel        = V"unstressed_vowel"
stress                  = V"stress"
stressed                = V"stressed"
any_syllable            = V"any_syllable"
syllable                = V"syllable"
consonantal_syllable    = V"consonantal_syllable"
coda                    = V"coda"
onset                   = V"onset"
nucleus                 = V"nucleus"
glide                   = V"glide"
diphthong               = V"diphthong"
vowel                   = V"vowel"
cluster                 = V"cluster"
initial_pair            = V"initial_pair"
initial                 = V"initial"
affricate               = V"affricate"
liquid                  = V"liquid"
other                   = V"other"
sibilant                = V"sibilant"
consonant               = V"consonant"
syllabic                = V"syllabic"
voiced                  = V"voiced"
unvoiced                = V"unvoiced"
digit                   = V"digit"
post_word               = V"post_word"
pause                   = V"pause"
EOF                     = V"EOF"
comma                   = V"comma"
non_lojban_word         = V"non_lojban_word"
non_space               = V"non_space"
space_char              = V"space_char"
spaces                  = V"spaces"
initial_spaces          = V"initial_spaces"
ybu                     = V"ybu"

a = V"a"
e = V"e"
i = V"i"
o = V"o"
u = V"u"
y = V"y"
l = V"l"
m = V"m"
n = V"n"
r = V"r"
b = V"b"
d = V"d"
g = V"g"
v = V"v"
j = V"j"
z = V"z"
s = V"s"
c = V"c"
x = V"x"
k = V"k"
f = V"f"
p = V"p"
t = V"t"
h = V"h"

--- GRAMMAR for assigning cmavos to selma'o -----------------------------------

classes = P{
"selmaho",
selmaho = 
 BAI + BAhE + BEI + BEhO + BIhE + BIhI + BOI + 
 CAhA + CAI + CEI + CEhE + COI + CUhE + DAhO + DOI + DOhU + 
 FA + FAhA + FAhO + FEhE + FEhU + FIhO + FOI + FUhA + FUhE + FUhO +
 GA + GAhO + GEhU + GIhA + GOI + NOI + GOhA + GUhA + JA + JAI + JOhI +
 JOI + KEhE + KEI + LAhE + MAI + KOhA + KUhE + KUhO + LA + LAU +
 LE + LEhU + LI + LIhU + LOhO + LOhU + LUhU + MAhO + MEhU +
 MOhE + MOhI + MOI + NA + NAI + NAhE + NAhU + NIhE + NIhO + NOI + NU +
 NUhA + NUhI +NUhU + PA + PEhE + PEhO + RAhO + ROI + SEI +
 SEhU + SOI + TAhE + TEhU + TEI + TO + TOI + TUhE + TUhU + UI +
 VAU + VEI + VEhO + VUhU + VEhA + VIhA + VUhO +
 ZAhO + ZEhA + ZEI + ZIhE + ZOI + ZOhU +
 A + BE2 + BO2 + BU + CO2 + CU2 + FA2 + GA2 + GI2 + GIhA + GOhA2 + GOI2 + JA2 +
 JOI2 + KE2 + KI2 + KOhA2 + KU2 + LA2 + LE2 + LI2 + LU2 + ME2 + NA2 + NU2 +
 PA2 + PU2 + SA2 + SE2 + SI2 + SU2 + TO2 +  UI2 + A2 + VA2 + XI2 + ZI2 + ZO2 +
 I2 + BY + BY2 + Y, 

a = P'a',
e = P'e',
i = P'i',
o = P'o',
u = P'u',
y = P'y',

l = P'l',
m = P'm',
n = P'n',
r = P'r',
b = P'b',
d = P'd',
g = P'g',
v = P'v',
j = P'j',
z = P'z',
s = P's',
c = P'c',
x = P'x',
k = P'k',
f = P'f',
p = P'p',
t = P't',
h = S"'h",

digit = R"09",
ybu = Y * S".\t\n\r?! "^0 * BU/"ybu",

A    = (j*i)/'"A","%0"',
A2   = (a + e + o + u)/'"A","%0"',
BAI  = (d*(u*h*(o + i) + i*h*o + e*h*i + o*h*e) + s*(i*h*u + a*u) +
       z*(a*u + u*h*e) + k*(i*h*(i + u) + o*i + a*(i + h*(a + i)) + u*h*u) +
       c*(u*h*u + a*(h*i + u) + i*h*(o + e + u)) +
       t*(u*h*i + i*h*(u + i) + a*(h*i + i)) + j*(i*h*(u + o + e) + a*h*(i + e)) +
       r*(i*h*(a + i) + a*(h*(i + a) + i)) +
       n*i*h*i + m*(u*h*(i + u) + a*(u + h*(i + e))) + v*a*h*(u + o) +
       p*(u*h*(e + a) + a*h*(u + a) + o*h*i + i*h*o) +
       b*(a*(i + h*i + u) + e*h*i) + f*(i*h*e + a*(u + h*e)) +
       l*(e*h*a + i*h*e + a*h*u) +
       g*a*(h*a + u) + m*e*h*(a + e))/'"BAI","%0"',
BAhE = (b*a*h*e + z*a*h*e)/'"BAhE","%0"',
BE2  = (b*e)/'"BE","%0"',
BEI  = (b*e*i)/'"BEI","%0"',
BEhO = (b*e*h*o)/'"BEhO","%0"',
BIhE = (b*i*h*e)/'"BIhE","%0"',
BIhI = (m*i*h*i + b*i*h*(o + i))/'"BIhI","%0"',
BO2  = (b*o)/'"BO","%0"',
BOI  = (b*o*i)/'"BOI","%0"',
BU   = (b*u)/'"BU","%0"',
BY   = (j*(o*h*o + e*h*o) + r*u*h*o + g*(e*h*o + a*h*e) + l*o*h*a + n*a*h*a +
         s*e*h*e + t*o*h*a + y*h*y + b*y + c*y + d*y + f*y + g*y + j*y + k*y +
         l*y + m*y + n*y + p*y + r*y + s*y + t*y + v*y + x*y + z*y)/'"BY","%0"',
BY2  = ybu/'"BY","ybu"',
CAhA = (c*a*h*a + p*u*h*i + n*u*h*o + k*a*h*e)/'"CAhA","%0"',
CAI  = (p*e*i + c*(a*i + u*h*i) + s*a*i + r*u*h*e)/'"CAI","%0"',
CEI  = (c*e*i)/'"CEI","%0"',
CEhE = (c*e*h*e)/'"CEhE","%0"',
CO2  = (c*o)/'"CO","%0"',
COI  = (j*u*h*i + c*o*(i + h*o) + f*(i*h*i + e*h*o) + t*a*h*a +
         m*(u*h*o + i*h*e) + p*e*h*u + k*(e*h*o + i*h*e) + n*u*h*e + r*e*h*i +
	     b*e*h*e + j*e*h*e + v*i*h*o)/'"COI","%0"',
CU2  = (c*u)/'"CU","%0"',
CUhE = (c*u*h*e + n*a*u)/'"CUhE","%0"',
DAhO = (d*a*h*o)/'"DAhO","%0"',
DOI  = (d*o*i)/'"DOI","%0"',
DOhU = (d*o*h*u)/'"DOhU","%0"',
FA   = (f*(a*i + i*h*a))/'"FA","%0"',
FA2  = (f*(a + e + o + u + i))/'"FA","%0"',
FAhA = (d*u*h*a + b*(e*h*a + u*h*u) + n*(e*h*u + i*h*a + e*h*(a + i)) +
         v*u*h*a + g*a*h*u + t*(i*h*a + o*h*o + e*h*e) + c*a*h*u +
	     z*(u*h*a + o*h*(i + a) + e*h*o) + r*(i*h*u + u*h*u + e*h*o) +
	     p*a*h*o + f*a*h*a)/'"FAhA","%0"',
FAhO = (f*a*h*o + x*a*h*o)/'"FAhO","%0"', -- xaho for pgm internal use
FEhE = (f*e*h*e)/'"FEhE","%0"',
FEhU = (f*e*h*u)/'"FEhU","%0"',
FIhO = (f*i*h*o)/'"FIhO","%0"',
FOI  = (f*o*i)/'"FOI","%0"',
FUhA = (f*u*h*a)/'"FUhA","%0"',
FUhE = (f*u*h*e)/'"FUhE","%0"',
FUhO = (f*u*h*o)/'"FUhO","%0"',
GA   = (g*e*h*i)/'"GA","%0"',
GA2  = (g*(e + o + a + u))/'"GA","%0"',
GAhO = (k*e*h*i + g*a*h*o)/'"GAhO","%0"',
GEhU = (g*e*h*u)/'"GEhU","%0"',
GI2  = (g*i)/'"GI","%0"',
GIhA = (g*i*h*(e + i + o + a + u))/'"GIhA","%0"',
GOI  = (n*o*h*u + g*o*i + p*(o*h*u + o*h*e))/'"GOI","%0"',
GOI2 = (n*e + p*(e + o))/'"GOI","%0"',
GOhA = (n*(e*i + o*h*a) + g*o*h*(u + o + i + e + a) +
         b*u*h*(a + e + i) + c*o*h*e)/'"GOhA","%0"',
GOhA2 = (m*o + d*u)/'"GOhA","%0"',
GUhA = (g*u*h*(e + i + o + a + u))/'"GUhA","%0"',
I2   = (i)/'"I","%0"',
JA   = (j*e*h*i)/'"JA","%0"',
JA2  = (j*(e + o + a + u))/'"JA","%0"',
JAI  = (j*a*i)/'"JAI","%0"',
JOhI = (j*o*h*i)/'"JOhI","%0"',
JOI  = (f*a*h*u + p*i*h*u + j*(o*(i + h*(u + e)) + u*h*e) + c*e*h*o +
         k*u*h*a)/'"JOI","%0"',
JOI2 = (c*e)/'"JOI","%0"',
KE2  = (k*e)/'"KE","%0"',
KEhE = (k*e*h*e)/'"KEhE","%0"',
KEI  = (k*e*i)/'"KEI","%0"',
KI2  = (k*i)/'"KI","%0"',
KOhA = (d*(a*h*(u + e) + i*h*(u + e) + e*(h*(u + e) + i) +
         o*h*(i + o)) + m*(i*h*(o + a) + a*h*a) + k*(e*h*a +
	     o*h*(a + e + i + o + u)) + f*o*h*(u + a + e + i + o) +
	     v*o*h*(a + e + i + o + u) + z*(i*h*o + u*h*i + o*h*e) +
         c*e*h*u)/'"KOhA","%0"',
KOhA2 = (r*(u + i + a) + t*(a + u + i) + m*(a + i) + d*(a + e + i + o) +
          k*o)/'"KOhA","%0"',
KU2  = (k*u)/'"KU","%0"',
KUhE = (k*u*h*e)/'"KUhE","%0"',
KUhO = (k*u*h*o)/'"KUhO","%0"',
LA   = (l*a*(i + h*i))/'"LA","%0"',
LA2  = (l*a)/'"LA","%0"',
LAU  = (c*e*h*a + l*a*u + z*a*i + t*a*u)/'"LAU","%0"',
LAhE = (t*u*h*a + l*(u*h*(a + o + i + e) + a*h*e) + v*u*h*i)/'"LAhE","%0"',
LE   = (l*(e*(i + h*(i + e)) + o*(i + h*(i + e))))/'"LE","%0"',
LE2  = (l*(o + e))/'"LE","%0"',
LEhU = (l*e*h*u)/'"LEhU","%0"',
LI   = (m*e*h*o)/'"LI","%0"',
LI2  = (l*i)/'"LI","%0"',
LIhU = (l*i*h*u)/'"LIhU","%0"',
LOhO = (l*o*h*o)/'"LOhO","%0"',
LOhU = (l*o*h*u)/'"LOhU","%0"',
LU2  = (l*u)/'"LU","%0"',
LUhU = (l*u*h*u)/'"LUhU","%0"',
MAhO = (m*a*h*o)/'"MAhO","%0"',
MAI  = (m*(o*h*o + a*i))/'"MAI","%0"',
ME2  = (m*e)/'"ME","%0"',
MEhU = (m*e*h*u)/'"MEhU","%0"',
MOhE = (m*o*h*e)/'"MOhE","%0"',
MOhI = (m*o*h*i)/'"MOhI","%0"',
MOI  = (m*(e*i + o*i) + s*i*h*e + c*u*h*o + v*a*h*e)/'"MOI","%0"',
NA   = (j*a*h*a)/'"NA","%0"',
NA2  = (n*a)/'"NA","%0"',
NAI  = (n*a*i)/'"NAI","%0"',
NAhE = (t*o*h*e + j*e*h*a + n*(a*h*e + o*h*e))/'"NAhE","%0"',
NAhU = (n*a*h*u)/'"NAhU","%0"',
NIhE = (n*i*h*e)/'"NIhE","%0"',
NIhO = (n*(i*h*o + o*h*i))/'"NIhO","%0"',
NOI  = (p*o*i + n*o*i + v*o*i)/'"NOI","%0"',
NU   = (d*u*h*u + s*(i*h*o + u*h*u) + l*i*h*i + j*e*i + z*(u*h*o + a*h*i) +
         m*u*h*e + p*u*h*u)/'"NU","%0"',
NU2  = (n*(i + u) + k*a)/'"NU","%0"',
NUhA = (n*u*h*a)/'"NUhA","%0"',
NUhI = (n*u*h*i)/'"NUhI","%0"',
NUhU = (n*u*h*u)/'"NUhU","%0"',
PA   = (d*(a*(h*a + u) + u*h*e) + f*(e*i + i*h*u) + g*a*i + j*(a*u + i*h*i) +
         r*(e*i + a*(h*e + u))  + v*a*i   + p*(i*h*e + a*i) +
         z*a*h*u + m*(e*h*i + a*h*u + o*h*a) + n*(i*h*u + o*h*o) +
         k*(i*h*o + a*h*o) + c*(e*h*i + i*h*i) +
         s*(o*h*(a + i + e + o + u) + u*h*(o + e)) +
	     t*(e*h*o + u*h*o))/'"PA","%0"',
PA2  = (p*i + r*o + x*o + n*o + p*a + r*e + c*i + v*o + m*u + x*a +
         z*e + b*i + s*o + digit)/'"PA","%0"',
PEhE = (p*e*h*e)/'"PEhE","%0"',
PEhO = (p*e*h*o)/'"PEhO","%0"',
PU2  = (b*a + p*u + c*a)/'"PU","%0"',
RAhO = (r*a*h*o)/'"RAhO","%0"',
ROI  = (r*(e*h*u + o*i))/'"ROI","%0"',
SA2  = (s*a)/'"SA","%0"',
SE2  = (s*e + t*e + v*e + x*e)/'"SE","%0"',
SEI  = (s*e*i + t*i*h*o)/'"SEI","%0"',
SEhU = (s*e*h*u)/'"SEhU","%0"',
SI2  = (s*i)/'"SI","%0"',
SOI  = (s*o*i)/'"SOI","%0"',
SU2  = (s*u)/'"SU","%0"',
TAhE = (r*u*h*i + t*a*h*e + d*i*h*i + n*a*h*o)/'"TAhE","%0"',
TEhU = (t*e*h*u)/'"TEhU","%0"',
TEI  = (t*e*i)/'"TEI","%0"',
TO   = (t*o*h*i)/'"TO","%0"',
TO2  = (t*o)/'"TO","%0"',
TOI  = (t*o*i)/'"TOI","%0"',
TUhE = (t*u*h*e)/'"TUhE","%0"',
TUhU = (t*u*h*u)/'"TUhU","%0"',
UI   = (i*h*(a + o + e + u + i) + a*h*(e + a + i + o + u) +
         u*h*(i + o + a + u + e) + o*h*(i + e + o + a + u) + 
         e*h*(e + i + a + o + u) +
         b*(a*h*(a + u) + i*h*u + e*h*u + u*h*o) +
         j*(a*h*o + u*h*(a + o) + e*h*u + o*h*a + i*h*a) +
         c*a*h*e + t*(i*h*e + a*h*(o + u) + o*h*u) +
         k*(a*h*u + e*h*u + a*u + u*h*i + i*h*a) +
	     s*(e*h*(o + i + a) + a*h*(e + a +u) + u*h*a + i*h*a) +
         z*(a*h*a + o*h*o + u*h*u) + p*(e*h*(i + a) + a*(h*e + u) + o*h*o) +
         r*(u*h*a + a*h*u + o*h*(i + e + o + a + e) + i*h*e) +
         l*(i*h*(a + o) + a*h*a + e*h*o) + m*(u*h*a + i*h*u) +
         d*(o*h*a + a*(h*i + i))+ v*(a*h*i + u*h*e) +
         n*a*h*i + f*u*h*i + g*(a*h*i + e*h*e))/'"UI","%0"',
UI2  = (i*(e + a + i + u + o) + o*i + u*(o + a + i + u + e) + a*(u + i) +
         e*i + x*u)/'"UI","%0"',
VA2  = (v*(i + a + u))/'"VA","%0"',
VAU  = (v*a*u)/'"VAU","%0"',
VEI  = (v*e*i)/'"VEI","%0"',
VEhO = (v*e*h*o)/'"VEhO","%0"',
VUhU = (g*e*(h*a + i) + f*(u*h*u + e*h*(i + a) + a*h*i) +
         p*(i*h*(i + a) + a*h*i) + v*(u*h*u + a*h*a) +
         s*(u*h*i + a*h*(o + i) + i*h*i) +
         j*u*h*u + t*e*h*a + c*u*h*a +
         n*e*h*o + d*e*h*o + r*(e*h*a + i*h*o))/'"VUhU","%0"',
VEhA = (v*e*h*(u + a + i + e))/'"VEhA","%0"',
VIhA = (v*i*h*(i + a + u + e))/'"VIhA","%0"',
VUhO = (v*u*h*o)/'"VUhO","%0"',
XI2  = (x*i)/'"XI","%0"',
Y    = (y^1)/'"Y","%0"',
ZAhO = (c*(o*h*(i + u + a) + a*h*o) + p*u*h*o + m*o*h*u +
         d*(e*h*a + i*h*a) + b*a*h*o + z*a*h*o)/'"ZAhO","%0"',
ZEhA = (z*e*h*(u + a + i + e))/'"ZEhA","%0"',
ZEI  = (z*e*i)/'"ZEI","%0"',
ZI2  = (z*(u + a + i))/'"ZI","%0"',
ZIhE = (z*i*h*e)/'"ZIhE","%0"',
ZO2  = (z*o)/'"ZO","%0"',
ZOI  = (z*o*i + l*a*h*o)/start_zoi,
ZOhU = (z*o*h*u)/'"ZOhU","%0"',
}

function assign_class(s)
  return 'cmavo('..(lmatch(classes,s) or ('"UNKNOWN","'..s..'")'))..')'
end

---  Morphology grammar -------------------------------------------------------

morpho = P{
"words",
words       = Ct(pause^-1 * (word * pause^-1)^0),
word        = Cmt(lojban_word,check_zoi) +
              non_lojban_word,
lojban_word = cmene +
              cmavo +
              brivla,
brivla      = (gismu + fuhivla + lujvo)/'brivla(%1)',

--- CMENE ----------------------------------------------------------------

cmene  = (jbocme + zifcme)/'cmene("%0")',
zifcme = -h * (nucleus + glide + h + consonant * -pause + digit)^0 *
           consonant * #pause,
jbocme = #zifcme * (any_syllable + digit)^1 * #pause,

--- CMAVO ----------------------------------------------------------------

-- the assignment of cmavos to selma'o is performed by an external grammar
-- via function assign_class
 
cmavo                  = (ybu + -CVCy_lujvo * cmavo_form)/assign_class * #post_word ,

CVCy_lujvo             = CVC_rafsi * y * h^-1 * initial_rafsi^0 * brivla_core +
                         stressed_CVC_rafsi * y * short_final_rafsi,

cmavo_form             = -h * -cluster * onset * (nucleus * h)^0 *
                           (-stressed * nucleus + nucleus * -cluster) +
                         y^1 +
                         digit,

--- LUJVO ----------------------------------------------------------------

lujvo                  = (initial_rafsi^0 * brivla_core)/'"lujvo","%0"',
brivla_core            = Cmt(P(true),fg)* fuhivla + -- gated fuhivla check
                         gismu +
                         CVV_final_rafsi +
                         stressed_initial_rafsi * short_final_rafsi ,

stressed_initial_rafsi = stressed_extended_rafsi +
                         stressed_y_rafsi +
                         stressed_y_less_rafsi,

initial_rafsi          = extended_rafsi +
                         y_rafsi +
                         -any_extended_rafsi * y_less_rafsi,
any_extended_rafsi     = Cmt(P(true),fg) * fuhivla +
                         extended_rafsi +
                         stressed_extended_rafsi,

--- FUHIVLA ----------------------------------------------------------------

fuhivla                 = (fuhivla_head * stressed_syllable * consonantal_syllable^0 *
                          final_syllable)/'"fuhivla","%0"',

stressed_extended_rafsi = stressed_brivla_rafsi +
                          stressed_fuhivla_rafsi ,
extended_rafsi          = brivla_rafsi +
                          fuhivla_rafsi,

stressed_brivla_rafsi   = #unstressed_syllable * brivla_head *
                            stressed_syllable * h * y,

brivla_rafsi            = #(syllable * consonantal_syllable^0 * syllable) *
                           brivla_head * h * y * h^-1,

stressed_fuhivla_rafsi  = fuhivla_head * stressed_syllable * #consonant *
                           onset * y ,

fuhivla_rafsi           = #unstressed_syllable * fuhivla_head * #consonant *
                           onset * y * h^-1,

fuhivla_head            = -rafsi_string * -cmavo * brivla_head,
brivla_head             = -slinkuhi * -h * #onset * unstressed_syllable^0,
slinkuhi                = consonant * rafsi_string,
rafsi_string            = y_less_rafsi^0 * (
                            gismu +
                            CVV_final_rafsi +
                            stressed_y_less_rafsi * short_final_rafsi +
                            y_rafsi +
                            stressed_y_rafsi +
                            stressed_y_less_rafsi^-1 * initial_pair * y
                            ),

--- GISMU ----------------------------------------------------------------

gismu                 = (initial_pair * stressed_vowel + consonant *
                         stressed_vowel * consonant) * #final_syllable *
                         consonant * vowel/'"gismu","%0"' * #post_word,

CVV_final_rafsi       = consonant * stressed_vowel * h * #final_syllable *
                         vowel * #post_word,

short_final_rafsi     = #final_syllable *
                          (consonant * diphthong + initial_pair * vowel) *
                          #post_word,

stressed_y_rafsi      = (stressed_long_rafsi + stressed_CVC_rafsi) * y,
stressed_y_less_rafsi = stressed_CVC_rafsi * -y +
                        stressed_CCV_rafsi +
                        stressed_CVV_rafsi,

stressed_long_rafsi   = initial_pair * stressed_vowel * consonant +
                        consonant * stressed_vowel * consonant * consonant,

stressed_CVC_rafsi    = consonant * stressed_vowel * consonant,
stressed_CCV_rafsi    = initial_pair * stressed_vowel ,
stressed_CVV_rafsi    = consonant * (unstressed_vowel * h * stressed_vowel +
                        stressed_diphthong) * r_hyphen^-1 ,

y_rafsi               = (long_rafsi + CVC_rafsi) * y * h^-1,
y_less_rafsi          = -y_rafsi * (CVC_rafsi * -y + CCV_rafsi + CVV_rafsi) *
                          -any_extended_rafsi,

long_rafsi            = initial_pair * unstressed_vowel * consonant +
                        consonant * unstressed_vowel * consonant * consonant,

CVC_rafsi             = consonant * unstressed_vowel * consonant,
CCV_rafsi             = initial_pair * unstressed_vowel,
CVV_rafsi             = consonant * (unstressed_vowel * h * unstressed_vowel +
                          unstressed_diphthong) * r_hyphen^-1,

r_hyphen              = r * #consonant +
                        n * #r,

-------------------------------------------------------------------

final_syllable        = onset * -y * -stressed * nucleus * -cmene * #post_word,
stressed_syllable     = #stressed * syllable +
                        syllable * #stress,
stressed_diphthong    = #stressed * diphthong +
                        diphthong * #stress,
stressed_vowel        = #stressed * vowel +
                        vowel * #stress,
unstressed_syllable   = -stressed * syllable * -stress +
                        consonantal_syllable,
unstressed_diphthong  = -stressed * diphthong * -stress,
unstressed_vowel      = -stressed * vowel * -stress,
stress                = consonant^0 * y^-1 * syllable * pause,
stressed              = onset * comma^0 * S"AEIOU",
any_syllable          = onset * nucleus * coda^-1 +
                        consonantal_syllable ,
syllable              = onset * -y * nucleus * coda^-1,
consonantal_syllable  = consonant * syllabic *
                          #(consonantal_syllable + onset) *
                          (consonant * #spaces)^-1,

coda                  = -any_syllable * consonant * #any_syllable +
                        syllabic^-1 * consonant^-1 * #pause ,

onset                 = h +
                        consonant^-1 * glide +
                        initial,
nucleus               = vowel +
                        diphthong +
                        y * -nucleus,
glide                 = (i + u) * #nucleus * -glide,
diphthong             = (a * (i + u) + (e + o) * i) * -nucleus * -glide,
vowel                 = (a + e + i + o + u) * -nucleus,

a = comma^0 * S"aA" ,
e = comma^0 * S"eE" ,
i = comma^0 * S"iI" ,
o = comma^0 * S"oO" ,
u = comma^0 * S"uU" ,
y = comma^0 * S"yY" ,

cluster      = consonant^2,
initial_pair = #initial * consonant * consonant * -consonant,
initial      = (affricate + sibilant^-1 * other^-1 * liquid^-1) * -consonant *
                 -glide,
affricate    = t * (c + s) + d * (j + z),
liquid       = l + r ,
other        = p + t * -l + k + f + x + b + d * -l + g + v + m + n * -liquid ,
sibilant     = c + s * -x + j * -n + z * -n * -liquid,
consonant    = voiced + unvoiced + syllabic,
syllabic     = l + m + n + r,
voiced       = b + d + g + j + v + z,
unvoiced     = c + f + k + p + s + t + x,

l = comma^0 * S"lL" * -h * -l,
m = comma^0 * S"mM" * -h * -m * -z,
n = comma^0 * S"nN" * -h * -n * -affricate,
r = comma^0 * S"rR" * -h * -r,
b = comma^0 * S"bB" * -h * -b * -unvoiced,
d = comma^0 * S"dD" * -h * -d * -unvoiced,
g = comma^0 * S"gG" * -h * -g * -unvoiced,
v = comma^0 * S"vV" * -h * -v * -unvoiced,
j = comma^0 * S"jJ" * -h * -j * -z * -unvoiced,
z = comma^0 * S"zZ" * -h * -z * -j * -unvoiced,
s = comma^0 * S"sS" * -h * -s * -c * -voiced,
c = comma^0 * S"cC" * -h * -c * -s * -x * -voiced,
x = comma^0 * S"xX" * -h * -x * -c * -k * -voiced,
k = comma^0 * S"kK" * -h * -k * -x * -voiced,
f = comma^0 * S"fF" * -h * -f * -voiced,
p = comma^0 * S"pP" * -h * -p * -voiced,
t = comma^0 * S"tT" * -h * -t * -voiced,
h = comma^0 * S"'h" * #nucleus,

digit           = comma^0 * R"09" * -h * -nucleus,
comma           = P",",
post_word       = pause +
                  -nucleus * lojban_word,
pause           = comma^0 * space_char^1 +
                  EOF,
EOF             = comma^0 * -1,

non_lojban_word = non_space^1/'non_lojban("%0","%0")',

non_space       = -space_char * P(1),
space_char      = S".\t\n\r?!\" ",
spaces          = -Y * initial_spaces,
initial_spaces  = (comma^0 * space_char + -ybu * Y)^1 * EOF^-1 +
                  EOF,

ybu  = y/"ybu" * space_char^0 * #BU,
Y    = y^1/'"Y","%0"',
BU   = (b*u)/'"BU","%0"',
}

--- INTERFACE -----

--- given input string s returns a table of words, formatted as function calls

function morphed(s,cfl)
  check_fl = cfl
  return lmatch(morpho,s)
end

function version()
  return "alpha 9 / July 8, 2012"
end
