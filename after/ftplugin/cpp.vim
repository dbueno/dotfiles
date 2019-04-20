" Doxygen comments need some special treatment. This makes a 3-part comment
" group starting with //!, continuing with // with the same indent, and ending
" with //
" Support bulleted lists with - in my comments
set comments=
" These seem to work in this order
set comments+=://!
set comments+=://
" But put this forst and all hell breaks loose??
"set comments+=sO://\ -,mO://\ \ ,exO://
"set comments^=sO://!,mbO://\ ,eO://
"set comments^=fb://\ -


" Setting this for now because of euforia
set makeprg+=\ all\ tags
