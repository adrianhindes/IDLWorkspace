pro signal_cache_get,time=time,data=data,starttime=starttime,sampletime=sampletime,name=name,errormess=errormess,notime=notime
;***********************************************************************************
;* PRO SIGNAL_CACHE_GET                        S. Zoletnik    04.08.2008           *
;*---------------------------------------------------------------------------------*
;* Gets a signal from the signal cache.                                            *
;* The signal cache is a common block in the IDL program, where signals            *
;* can be stored. Each signal has a name and data vector (1D). The time            *
;* vector can be either defined by an explicit time vector or by the               *
;* combination of a starttime and sampletime.                                      *
;* Cache routines:                                                                 *
;*  SIGNAL_CACHE_ADD: Adds a signal to the cache.                                  *
;*  SIGNAL_CACHE_GET: Read a signal from the cache.                                *
;*  SIGNAL_CACHE_DELETE: Delete a signal (or all signals) from the cache.          *
;*                                                                                 *
;* Arguments to SIGNAL_CACHE_GET:                                                  *
;* INPUT:                                                                          *
;*  name: Name of the signal (string).                                             *
;*  /notime: Do not construct output time vector. If this keyword is not set a     *
;*           time vector will be generated from sampletime and starttime if the    *
;*           time vector was not stored with the data                              *
;* OUTPUT:                                                                         *
;*  time: Time vector (1D). This is the original time vector or constructed from   *
;*        starttime and sampletime.                                                *
;*  data: Data vector (1D).                                                        *
;*  starttime: The time of the first sample [sec].                                 *
;*  sampletime: The time step between two samples [sec]. starttime and sampletime  *
;*              might be NaN if they were not stored with the data.                *
;*  errormess: Error message or ''                                                 *
;***********************************************************************************


errormess = ''
if (not defined(name)) then begin
  errormess = 'Error in SIGNAL_CACHE_GET.PRO: Name must be defined.'
  return
endif
if (size(name,/type) ne 7) then begin
  errormess = 'Error in SIGNAL_CACHE_GET.PRO: Name must be a string.'
  return
endif

n_cache = 300
command = 'common signal_cache'
for i=1,n_cache do begin
  command = command+',c'+i2str(i)
endfor
if (not execute(command)) then return

found = -1
for i=1,n_cache do begin
  command = 'res = defined(c'+i2str(i)+')'
  if (not execute(command)) then return
  if res then begin
    command = 'empty = c'+i2str(i)+'.empty'
    if (not execute(command)) then return
    if (not empty) then begin
      command = 'w_name = c'+i2str(i)+'.name'
      if (not execute(command)) then return
      if (strupcase(w_name) eq strupcase(name)) then begin
        found = i
        break
      endif
    endif
  endif
endfor

if (found lt 0) then begin
  errormess = 'Cannot find signal in cache: '+name
  return
endif

command = 'time =c'+i2str(found)+'.time & data=c'+i2str(found)+'.data & starttime=c'+i2str(found)+'.starttime &  sampletime=c'+i2str(found)+'.sampletime'
if (not execute(command)) then return
if (not keyword_set(notime)) then begin
  if ((n_elements(time) eq 1) and not finite(time[0])) then begin
    time = dindgen(n_elements(data))*sampletime+starttime
  endif
endif
return

end
