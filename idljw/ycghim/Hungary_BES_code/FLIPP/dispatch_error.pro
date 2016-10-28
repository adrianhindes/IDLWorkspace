function dispatch_error,errormess,silent=silent
; ********************* DISPATCH_ERROR.PRO *********** S. Zoletnik 05.10.1998 **

if (errormess eq '') then return,0
if (not keyword_set(silent)) then print,errormess
return,1
end
