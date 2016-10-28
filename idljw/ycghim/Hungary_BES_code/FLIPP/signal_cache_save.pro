pro signal_cache_save,file=filename,errormess=errormess
;***********************************************************************************
;* PRO SIGNAL_CACHE_SAVE                       S. Zoletnik    05.09.2008           *
;*---------------------------------------------------------------------------------*
;* Saves the contents of the signal cache in an IDL save file.                     *
;*                                                                                 *
;* INPUT:                                                                          *
;*  file: name of the save file.                                                   *
;* OUTPUT:                                                                         *
;*  errormess: Error message or ''                                                 *
;***********************************************************************************

errormess = ''
if (not defined(filename)) then begin
  errormess = 'Error in SIGNAL_CACHE_SAVE.PRO: File name must be defined.'
  print,errormess
  return
endif
if (size(filename,/type) ne 7) then begin
  errormess = 'Error in SIGNAL_CACHE_SAVE.PRO: File name must be a string.'
  print,errormess
  return
endif

n_cache = 300
command = 'common signal_cache'
for i=1,n_cache do begin
  command = command+',c'+i2str(i)
endfor
if (not execute(command)) then begin
  errormess = 'Error saving signal cache to file.'
  print,errormess
  return
endif

command = 'save,file=filename
for i=1,n_cache do begin
  command = command+',c'+i2str(i)
endfor
print,command
if (not execute(command,0,0)) then begin
  errormess = 'Error saving signal cache to file.'
  print,errormess
  return
endif

return
end
