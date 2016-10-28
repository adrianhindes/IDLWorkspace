function remove_characters,signal_in,find_string, found=found
default,find_string,['/',':','<']
mod_sig=signal_in
found=0
  for j=0,n_elements(find_string)-1 do begin
      i=0
      ind=-1
      while (i NE -1) do begin
        i=strpos(mod_sig,find_string[j],i)
        IF (i NE -1) THEN BEGIN
          if ind[0] EQ -1 then begin
            ind=i
          endif else begin
            ind=[ind,i]
          endelse
          i=i+1
        endif
      endwhile
  
      mod_sig_save = mod_sig
      if ind[0] NE -1 then begin
        found=1
        ind=ind[sort(ind)]
        if (ind[0] ge 0) then begin
          mod_sig = ''
          for i=0, n_elements(ind) do begin
            ind1 = [-1, ind, strlen(mod_sig_save)]
            mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+STRLEN(find_string[j]),(ind1[i+1]-ind1[i])-1)
          endfor   
        endif
      endif
  endfor

if found EQ 0 then return,signal_in
if found EQ 1 then return,mod_sig 

end
