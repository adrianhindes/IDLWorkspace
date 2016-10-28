pro signal_cache_delete,name=name,all=all,errormess=errormess
;***********************************************************************************
;* PRO SIGNAL_CACHE_DELETE                       S. Zoletnik    04.08.2008         *
;*---------------------------------------------------------------------------------*
;* Deletes a signal in the signal cache.                                           *
;* The signal cache is a common block in the IDL program, where signals            *
;* can be stored. Each signal has a name and data vector (1D). The time            *
;* vector can be either defined by an explicit time vector or by the               *
;* combination of a starttime and sampletime.                                      *
;* Cache routines:                                                                 *
;*  SIGNAL_CACHE_ADD: Adds a signal to the cache.                                  *
;*  SIGNAL_CACHE_GET: Read a signal from the cache.                                *
;*  SIGNAL_CACHE_DELETE: Delete a signal (or all signals) from the cache.          *
;*                                                                                 *
;* Arguments to SIGNAL_CACHE_DELETE:                                               *
;* INPUT:                                                                          *
;*  name: Name of the signal (string). Can contain wildcard characters as well.    *
;*  /all: Delete all signals                                                       *
;* OUTPUT:                                                                         *
;*  errormess: Error message or ''. If signal is not found no error will be        *
;*             generated.                                                          *
;***********************************************************************************

errormess = ''

if (not defined(name) and not keyword_set(all)) then begin
  errormess = 'Error in SIGNAL_CACHE_DELETE.PRO: Name or /ALL must be defined.'
  return
endif
if (defined(name)) then begin
  if (size(name,/type) ne 7) then begin
    errormess = 'Error in SIGNAL_CACHE_DELETE.PRO: Name must be a string.'
    return
  endif
endif

n_cache = 300
command = 'common signal_cache'
for i=1,n_cache do begin
  command = command+',c'+i2str(i)
endfor
if (not execute(command)) then return


for i=1,n_cache do begin
  command = 'res = defined(c'+i2str(i)+')'
  if (not execute(command)) then return
  if res then begin
    command = 'empty = c'+i2str(i)+'.empty'
    if (not execute(command)) then return
    if (not empty) then begin
      if (keyword_set(all)) then begin
        command = 'c'+i2str(i)+'={empty:1, name:'''',time:0,data:0,starttime:!values.f_nan,sampletime:!values.f_nan}'
        if (not execute(command)) then return
      endif else begin
        command = 'w_name = c'+i2str(i)+'.name'
        if (not execute(command)) then return
        if (strmatch(strupcase(w_name),strupcase(name))) then begin
          command = 'c'+i2str(i)+'={empty:1, name:'''',time:0,data:0,starttime:!values.f_nan,sampletime:!values.f_nan}'
          if (not execute(command)) then return
        endif
      endelse
    endif
  endif
endfor

return

end
