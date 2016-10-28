pro signal_cache_restore,file=filename,errormess=errormess,silent=silent,add=add
;***********************************************************************************
;* PRO SIGNAL_CACHE_RESTORE                    S. Zoletnik    05.09.2008           *
;*---------------------------------------------------------------------------------*
;* Restores the contents of the signal cache from an IDL save file saved with      *
;* signal_cache_save.pro. The contents before is erased unless /add is set.        *
;*                                                                                 *
;* INPUT:                                                                          *
;*  file: name of the save file.                                                   *
;*  /silent: Do not print error message just return in errormess                   *
;*  /add: Add contents and do not delete previous data                             *
;* OUTPUT:                                                                         *
;*  errormess: Error message or ''                                                 *
;***********************************************************************************

errormess = ''
if (not defined(filename)) then begin
  errormess = 'Error in SIGNAL_CACHE_RESTORE.PRO: File name must be defined.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (size(filename,/type) ne 7) then begin
  errormess = 'Error in SIGNAL_CACHE_RESTORE.PRO: File name must be a string.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

n_cache = 300
command = 'common signal_cache'
for i=1,n_cache do begin
  command = command+',c'+i2str(i)
endfor
if (not execute(command)) then begin
  errormess = 'Error restoring signal cache from file.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (not keyword_set(add)) then begin
  signal_cache_delete,/all
  catch,catch_err
  if (catch_err ne 0) then begin
    errormess = 'Error restoring signal cache from file: '+filename
    if (not keyword_set(silent)) then print,errormess
    catch,/cancel
    return
  endif else begin
    restore,filename
  endelse
  catch,/cancel
endif else begin
  ; saving cache contents
  count = 0
  for i=1,n_cache do begin
    command = 'res = defined(c'+i2str(i)+')'
    if (not execute(command)) then begin
      errormess = 'Error copying old signal cache.'
      return
    endif
    if res then begin
      command = 'empty = c'+i2str(i)+'.empty'
      if (not execute(command)) then begin
        errormess = 'Error copying old signal cache.'
        return
      endif
    endif else begin
      empty = 1
    endelse
    if (not empty) then begin
      command = 's'+i2str(count)+' = c'+i2str(i)
      if (not execute(command)) then begin
        errormess = 'Error copying old signal cache.'
        return
      endif
      command = 'c'+i2str(i)+'.data = 0 & c'+i2str(i)+'.time = 0 & c'+i2str(i)+'.empty=1'
      if (not execute(command)) then begin
        errormess = 'Error copying old signal cache.'
        return
      endif

      count = count + 1
    endif
  endfor
  signal_cache_delete,/all
  catch,catch_err
  if (catch_err ne 0) then begin
    errormess = 'Error restoring signal cache from file: '+filename
    if (not keyword_set(silent)) then print,errormess
    catch,/cancel
    return
  endif else begin
    restore,filename
  endelse
  catch,/cancel
  outcount = 0
  while outcount lt count do begin
    ; This is the name of the variable to add from the old cache
    command = 'w_name1 = s'+i2str(outcount)+'.name'
    if (not execute(command)) then return
    ; Finding cache element with same name or first empty element
    found = -1
    first_empty = -1
    for i=1,n_cache do begin
      command = 'res = defined(c'+i2str(i)+')'
      if (not execute(command)) then return
      if res then begin
        command = 'empty = c'+i2str(i)+'.empty'
        if (not execute(command)) then return
        if (empty) then begin
          if (first_empty lt 0) then begin
            first_empty = i
          endif
          continue
        endif else begin
          command = 'w_name2 = c'+i2str(i)+'.name'
          if (not execute(command)) then return
          if (strupcase(w_name1) eq strupcase(w_name2)) then begin
            found = i
            break
          endif
        endelse
      endif else begin
        if (first_empty lt 0) then begin
          first_empty = i
        endif
      endelse
    endfor

    if ((found lt 0) and (first_empty lt 0)) then begin
      errormess = 'Signal cache is full.'
      return
    endif

    if (found lt 0) then found = first_empty
    ; replacing cache element
    command = 'c'+i2str(found)+' = s'+i2str(outcount)
    ; erasing old element
    if (not execute(command)) then return
    command = 's'+i2str(outcount)+' = 0'
    if (not execute(command)) then return
    outcount = outcount + 1
  endwhile
endelse
return
end
