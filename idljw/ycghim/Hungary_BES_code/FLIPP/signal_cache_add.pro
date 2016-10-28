pro signal_cache_add,time=time,data=data,starttime=starttime,sampletime=sampletime,name=name,errormess=errormess

;***********************************************************************************
;* PRO SIGNAL_CACHE_ADD                        S. Zoletnik    04.08.2008           *
;*---------------------------------------------------------------------------------*
;* Adds a signal to the signal cache.                                              *
;* The signal cache is a common block in the IDL program  where signals            *
;* can be stored. Each signal has a name and data vector (1D). The time            *
;* vector can be either defined by an explicit time vector or by the               *
;* combination of a starttime and sampletime.                                      *
;* Cache routines:                                                                 *
;*  SIGNAL_CACHE_ADD: Adds a signal to the cache.                                  *
;*  SIGNAL_CACHE_GET: Read a signal from the cache.                                *
;*  SIGNAL_CACHE_DELETE: Delete a signal (or all signals) from the cache.          *
;*                                                                                 *
;* Arguments to SIGNAL_CACHE_ADD:                                                  *
;* INPUT:                                                                          *
;*  time: Time vector (1D). Can be omitted if starttime and sampletime is set.     *
;*  data: Data vector (1D).                                                        *
;*  name: Name of the signal (string). If a signal with the same name already      *
;*        exists it will be overwritten.                                           *
;*  starttime: The time of the first sample [sec].                                 *
;*  sampletime: The time step between two samples [sec]. starttime and sampletime  *
;*              are optional they can be omitted of time vector is set.            *
;* OUTPUT:                                                                         *
;*  errormess: Error message or ''                                                 *
;***********************************************************************************

errormess = ''
if (not defined(data) and (not defined(starttime) or not defined(sampletime))) then begin
  errormess = 'Error in SIGNAL_CACHE_ADD.PRO: Either time vector or starttime/sampletime must be defined.'
  return
endif
if (not defined(data)) then begin
  errormess = 'Error in SIGNAL_CACHE_ADD.PRO: Data vector must be defined.'
  return
endif
if (defined(time)) then begin
  if (n_elements(time) ne n_elements(data)) then begin
    errormess = 'Error in SIGNAL_CACHE_ADD.PRO: Data and time vectors must have same number of elements.'
    return
  endif
endif
if (not defined(name)) then begin
  errormess = 'Error in SIGNAL_CACHE_ADD.PRO: Name must be defined.'
  return
endif
if (size(name,/type) ne 7) then begin
  errormess = 'Error in SIGNAL_CACHE_ADD.PRO: Name must be a string.'
  return
endif
if (n_elements(name) ne 1) then begin
  errormess = 'Error in SIGNAL_CACHE_ADD.PRO: Name must be a scalar.'
  return
endif

if (not defined(starttime)) then starttime = !values.f_nan;
if (not defined(sampletime)) then sampletime = !values.f_nan;
if (not defined(time)) then time = !values.f_nan;

n_cache = 300
command = 'common signal_cache'
for i=1,n_cache do begin
  command = command+',c'+i2str(i)
endfor
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
      command = 'w_name = c'+i2str(i)+'.name'
      if (not execute(command)) then return
      if (strupcase(w_name) eq strupcase(name)) then begin
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
command = 'c'+i2str(found)+'={empty:0, name:name,time:time,data:data,starttime:starttime,sampletime:sampletime}'
if (not execute(command)) then return
return

end
