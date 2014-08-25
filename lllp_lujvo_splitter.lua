--[[

                 A lujvo splitting LPeg module
             
  CAUTION: THIS IS JUST AN ALPHA VERSION AND MAY CONTAIN ERRORS

           RELEASED FOR PRELIMINARY EXPERIMENTATION AND FEEDBACK

           PENDING A THOROUGH INSPECTION, MAY AND PROBABLY STILL
           DOES IN SOME MINOR DETAIL CONTRADICT THE "OFFICIAL"
           SPECIFICATION

           veion (veijo.vilva@gmail.com)


 This Lua module is based on the PEG by xorxes for the morphology of Lojban.

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

local check_fl

function fg(s,pos,w)
  return check_fl
end

-- define shorthands for the non-terminals

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
comma                   = V"comma"

post_word = V'post_word'
pause = V"pause"
EOF = V"EOF"



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

---  lujvo splitter -------------------------------------------------------

splitter = P{
"lujvo",

--- CMAVO ----------------------------------------------------------------

-- the assignment of cmavos to selma'o is performed by an external grammar
-- via function assign_class
 
cmavo                  = (-CVCy_lujvo * cmavo_form) * #post_word ,
CVCy_lujvo             = CVC_rafsi * y * h^-1 * initial_rafsi^0 * brivla_core +
                         stressed_CVC_rafsi * y * short_final_rafsi,

cmavo_form             = -h * -cluster * onset * (nucleus * h)^0 *
                           (-stressed * nucleus + nucleus * -cluster),
                         
--- LUJVO ----------------------------------------------------------------

lujvo                  = Ct(initial_rafsi^0 * brivla_core),
brivla_core            = (Cmt(P(true),fg) * fuhivla + -- gated fuhivla check
                         gismu +
                         Cc'-'*CVV_final_rafsi +
                         Cc'-' * stressed_initial_rafsi * Cc'|-' *  short_final_rafsi),

stressed_initial_rafsi = (stressed_extended_rafsi +
                         stressed_y_rafsi +
                         stressed_y_less_rafsi)/"%0",

initial_rafsi          = (extended_rafsi +
                         y_rafsi +
                         -any_extended_rafsi * y_less_rafsi)/"-%1|",
any_extended_rafsi     = Cmt(P(true),fg) * fuhivla +
                         extended_rafsi +
                         stressed_extended_rafsi,

--- FUHIVLA ----------------------------------------------------------------

fuhivla                 = (fuhivla_head * stressed_syllable * consonantal_syllable^0 *
                          final_syllable)/"%0",

stressed_extended_rafsi = stressed_brivla_rafsi +
                          stressed_fuhivla_rafsi ,
extended_rafsi          = brivla_rafsi +
                          fuhivla_rafsi,

stressed_brivla_rafsi   = #unstressed_syllable * brivla_head *
                            stressed_syllable * h * y,

brivla_rafsi            = #(syllable * consonantal_syllable^0 * syllable) *
                           brivla_head * y * h^-1,

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
                         consonant * vowel/"%0",

CVV_final_rafsi       = (consonant * stressed_vowel * h * #final_syllable *
                         vowel)/"%0" * #post_word,

short_final_rafsi     = #final_syllable *
                          (consonant * diphthong + initial_pair * vowel)/"%0" *
                          #post_word,

stressed_y_rafsi      = (stressed_long_rafsi + stressed_CVC_rafsi) * y,
stressed_y_less_rafsi = stressed_CVC_rafsi * -y +
                        stressed_CCV_rafsi +
                        stressed_CVV_rafsi,

stressed_long_rafsi   = initial_pair * stressed_vowel * consonant +
                        consonant * stressed_vowel * consonant * consonant,

stressed_CVC_rafsi    = consonant * stressed_vowel * consonant,
stressed_CCV_rafsi    = initial_pair * stressed_vowel ,
stressed_CVV_rafsi    = (consonant * (unstressed_vowel * h * stressed_vowel +
                        stressed_diphthong) * r_hyphen^-1)/"%0" ,

y_rafsi               = ((long_rafsi + CVC_rafsi) * y)/"%0" * h^-1,
y_less_rafsi          = (-y_rafsi * (CVC_rafsi * -y + CCV_rafsi + CVV_rafsi) *
                          -any_extended_rafsi)/"%0",

long_rafsi            = initial_pair * unstressed_vowel * consonant +
                        consonant * unstressed_vowel * consonant * consonant,

CVC_rafsi             = consonant * unstressed_vowel * consonant,
CCV_rafsi             = initial_pair * unstressed_vowel,
CVV_rafsi             = (consonant * (unstressed_vowel * h * unstressed_vowel +
                          unstressed_diphthong) * r_hyphen^-1)/"%1",

r_hyphen              = r/"|r" * #consonant +
                        n/"|n" * #r,

-------------------------------------------------------------------

final_syllable        = onset * -y * -stressed * nucleus * #post_word,
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
                          (consonant)^-1,

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

comma           = P",",
post_word       = EOF,
pause           = comma^1 + EOF,
EOF             = -P(1),
}

function split(s,cfl)
  check_fl = cfl
  return lmatch(splitter,s)
end

function version()
  return "alpha 7 / July 7, 2012"
end
