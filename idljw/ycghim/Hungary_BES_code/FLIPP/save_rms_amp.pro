pro save_rms_amp,shot,signal,tvect=tvect,tres=tres,fitorder=fitorder,errormess=errormess,silent=silent,$
   data_source=data_source,trange=trange

;*****************************************************************************
; Reads signal <signal> from shot. Subtracts a <fitorder> order polynomial
; fit as trend and calculated the RMS fluctuation amplitude for short 
; time intervals. If <tres> is set then this will be used for the length of 
; the short time intervals (units: sec). If <tvect> is set the RMS amplitudes will be 
; determined on intervals centered around these points with interval length 
; equal to the distance between points.
; The result is saved in file data/<shot><signal>_rms.sav, see get_rawsignal.pro
; on using these files. 
;*****************************************************************************

default,fitorder,2
if (defined(tres)) then tres= double(tres)

errormess = ''

if (not defined(tres) and not defined(tvect)) then begin
  errormess = 'One of tres and tvect should be set.'
  if (not keyword_set(silent)) then begin
    print,errormess
  endif
  return
endif

if (defined(tres) and defined(tvect)) then begin
  errormess = 'Only one of tres and tvect may be set.'
  if (not keyword_set(silent)) then begin
    print,errormess
  endif
  return
endif

get_rawsignal,shot,signal,t,d,data_source=data_source,errormess=errormess,trange=trange
if (errormess ne '') then begin
  if (not keyword_set(silent)) then begin
    print,errormess
  endif
  return
endif
p = poly_fit(t,d,fitorder)
b = p[0]
for i=1,fitorder do begin
  b = b+p[i]*t^i
endfor
d = d-b  

if (defined(tvect)) then begin
  tres = tvect[1]-tvect[0]
endif else begin
  tvect = lindgen(long((max(t)-min(t))/tres))*tres+tres/2+min(t)
endelse   

data = fltarr(n_elements(tvect))
for i=0,n_elements(tvect)-1 do begin
  ind = where((t ge tvect[i]-tres/2) and (t lt tvect[i]+tres/2))
  if (ind[0] lt 0) then begin
    errormess = 'No data in time interval '+string(tvect[i]-tres/2)+'-'+string(tvect[i]-tres/2)+'.'
    if (not keyword_set(silent)) then begin
      print,errormess
    endif
stop
    return
  endif
  data[i] = sqrt(total(d[ind]^2)/n_elements(ind))  
endfor

sampletime = tres
starttime = tvect[0]
w = str_sep(signal,'/')
w = w[n_elements(w)-1] 
save,data,sampletime,starttime,file=dir_f_name('data',i2str(shot,digits=5)+w+'_rms.sav')

end


   


