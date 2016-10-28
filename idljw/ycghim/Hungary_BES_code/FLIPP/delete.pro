pro delete,var
;***********************************************
;  DELETE.PRO         S. Zoletnik  3.2.2012
;***********************************************
; Deletes (makes undefined) a variable.
;***********************************************

if (defined(var)) then a=temporary(var)

return

end