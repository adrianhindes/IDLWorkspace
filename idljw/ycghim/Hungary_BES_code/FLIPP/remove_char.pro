function remove_char,str,chr

;**********************************************************************
; Removes all occurences of a charecter from a string
; INPUT:
;   str: a string
;   chr: a character
; Return value is a copy of str with all occurrences of chr left out
;**********************************************************************
mod_str = str
ind = strsplit(mod_str,chr)
if (n_elements(ind) gt 1) then begin
  mod_str_save = mod_str
  mod_str = ''
  ind1 = [ind, strlen(mod_str_save)+1]
  for i=0, n_elements(ind)-1 do begin
    mod_str = mod_str+strmid(mod_str_save,ind1[i],(ind1[i+1]-ind1[i])-1)
  endfor
  ; Doing this recursively to remove conscutive occurrences
  mod_str = remove_char(mod_str,chr)
endif
return,mod_str
end