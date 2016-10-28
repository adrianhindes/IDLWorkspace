pro sigproc_corr_vs_time,signal_name_in_1,signal_name_in_2,corr_signal_out=corr_signal_out,timerange=timerange,tau=tau,$
                     fitorder=fitorder,lowcut=lowcut,errorproc=errorproc,errormess=errormess

;******************************************************************************************
;* SIGPROC_CORR_VS_TIME.PRO                                                               *
;* Calculates shifted product of two signals after subtracting a trend (polynomial fit    *
;* or low frequency cut) and outputs the signal.                                          *
;*                                                                                        *
;* INPUT:                                                                                 *
;*   signal_name_in_1 (string): The name of the first signal in the signal cache.         *
;*   signal_name_in_2 (string): The name of the second signal in the signal cache.        *
;*   corr_signal_out (string): The name of the output signal.                             *
;*   timerange: Processing time range [min,max] in seconds  (optional)                    *
;*   tau: The time shift in seconds. Will be rounded to closest sample.                   *
;*   fitorder: Polynomial fir order for detrend                                           *
;*   lowcut:   Low frequency cut by subtracting signal with <lowcut> microsecond          *
;*             integration.                                                               *
;*   errorproc: Name of error processing function. If not set error messages are printed  *
;*              on the screen.                                                            *
;* OUTPUT:                                                                                *
;*   errormess: Output error message or '' if no error occured.                           *
;******************************************************************************************

default,tau,0.   ; sec
default,fitorder,2  ; Polynomial fit order for detrend

errormess = ''

if (not defined(signal_name_in_1)) then begin
  errormess = 'First signal name is not set.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif

if (not defined(signal_name_in_2)) then begin
  errormess = 'Second signal name is not set.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif


; Reading signal 1
signal_cache_get, sampletime=sampletime1, time=time_sig1, data=signal1, name=signal_name_in_1,errormess=errormess
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif
default,sampletime1,(time_sig1[n_elements(time_sig1)-1]-time_sig1[0])/(n_elements(time_sig1)-1)
if (defined(timerange)) then begin
  ind = where((time_sig1 gt timerange[0]) and (time_sig1 lt timerange[1]))
  if (ind[0] lt 0) then begin
    errormess = 'No data in time range.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    return
  endif
  time_sig1 = time_sig1[ind]
  signal1 = signal1[ind]
endif

; Reading signal 2
signal_cache_get, sampletime=sampletime2, time=time_sig2, data=signal2, name=signal_name_in_2,errormess=errormess
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif
default,sampletime2,(time_sig2[n_elements(time_sig2)-1]-time_sig2[0])/(n_elements(time_sig2)-1)
if (defined(timerange)) then begin
  ind = where((time_sig2 gt timerange[0]) and (time_sig2 lt timerange[1]))
  if (ind[0] lt 0) then begin
    errormess = 'No data in time range.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    return
  endif
  time_sig2 = time_sig2[ind]
  signal2 = signal2[ind]
endif

; Checking if sampletimes are identical. Cannot process signals with different sampletime.
if (abs(sampletime1-sampletime2)/((sampletime1+sampletime2)/2) gt 1e-3) then begin
  errormess = 'Sampletime of two signals is different.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif
sampletime = sampletime1


; The number of samples
npoints = min([n_elements(signal1),n_elements(signal2)])
; Ensuring that length of two signals is identical
if (n_elements(signal1) ne n_elements(signal2)) then begin
  signal1 = signal1[0:npoints-1]
  time_sig1 = time_sig1[0:npoints-1]
  signal2 = signal2[0:npoints-1]
  time_sig2 = time_sig2[0:npoints-1]
endif

; Detrend
if (defined(lowcut)) then begin
  signal1 = signal1 - integ(signal1,lowcut*1e-6/sampletime)
  signal2 = signal2 - integ(signal2,lowcut*1e-6/sampletime)
endif else begin
  x = dindgen(npoints)*sampletime
  p = poly_fit(x,double(signal1),fitorder)
  b = p[0]
  for i=1,fitorder do begin
    b = b + p[i]*x^i
  endfor
  signal1 = signal1 - b

  p = poly_fit(x,double(signal2),fitorder)
  b = p[0]
  for i=1,fitorder do begin
    b = b + p[i]*x^i
  endfor
  signal2 = signal2 - b
endelse

; Calculating the time difference between the first samples.
dt = time_sig2[0]-time_sig1[0]
tau_sample = round((tau-dt)/sampletime)

if (tau_sample ge 0) then begin
  corrsignal = signal1[0:npoints-1-tau_sample]*signal2[tau_sample:npoints-1]
  time_out = time_sig1[0:npoints-1-tau_sample]
endif else begin
  corrsignal = signal1[-tau_sample:npoints-1]*signal2[0:npoints-1+tau_sample]
  time_out = time_sig1[-tau_sample:npoints-1]
endelse

signal_cache_add, time=time_out, data=corrsignal, name=corr_signal_out,errormess=e
if (e ne '') then begin
  print,e
  return
endif


end