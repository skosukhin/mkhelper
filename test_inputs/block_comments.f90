some string
  /* this is a real

block
     comment */

"/* this must stay */"

/* this

 block "comment

needs to be removed */"

/* several */ /* block */ /*comments*/

"a quoted string with \" /*" this should stay */

final string
 /* line */_ keep 0_
/* several
   lines */_ keep 1 _/* more
   lines */
_keep 2_
'/*'_ keep 3 _'*/'
'/*' /* more
lines */_ keep 4_'/*' "*/"
"/*_ keep 5_*/"
"/*_ keep 6_"
/* line 
"*/_keep 7_" */
keep 8/* drop these
lines inside unterminated block
