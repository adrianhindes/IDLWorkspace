pro nebula_default,var,default,string,quiet=quiet
if (not keyword_set(quiet)) then quiet=0
if (n_elements(var) eq 0) then begin
  var=default 
  if ((n_elements(string) ne 0) and (not quiet)) then $
	print, string+' [',default,'] -- default taken'
endif else if ((n_elements(string) ne 0) and (not quiet)) then $
	print, string+' [',var,'] '
return
end
