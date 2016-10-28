pro sigproc_tde_multi,signal_name_in_1,signal_name_in_2,td_signal_out=td_signal_out,power_signal_out=power_signal_out,$
              timerange=timerange,tres_out=delta_t,taurange=taurange,inttime=inttime,$
              fitorder=fitorder,lowcut=lowcut,errorproc=errorproc,errormess=errormess,cc=cc,cp=cp,cs=cs,winhn=winhn,minimum=minimum,asm=ms,acfw=acfw,$
              filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,filter_symmetric=filter_symmetric,$
              edge_extremum=edge_extremum,fit_parabola=fit_parabola, fit_points=fit_points

;******************************************************************************************
;* SIGPROC_TDE_MULTI.PRO                                                                  *
;* Time delay estimation from crosscorrelation in short time intervals. This procedure    *
;* processes signals in the signal cache and writes the output to the signla cache.       *
;* Multiple pairs of signals are processed and the correlation function is averaged over  *
;* signal pairs.                                                                          *
;*                                                                                        *
;* INPUT:                                                                                 *
;*   signal_name_in_1 (string): The names of the first signals in the signal cache.       *
;*   signal_name_in_2 (string): The names of the second signals in the signal cache.      *
;*     If the signal names are arrays pairs of signals will be correlated and the         *
;*     mean correlation function calculated before finding maximum.                       *
;*     (Applicable to /cs)                                                                *
;*   td_signal_out (string): The name of the output signal. The time delay values in      *
;*                             microsecond.                                               *
;*   Power_signal_out: The output amplitudes.                                             *
;*   timerange: Processing time range [min,max] in seconds                                *
;*   tres_out: The time resolution of the output signal [seconds]. Correlation is         *
;*             calculated on this long time intervals.                                    *
;*   taurange: Time lag range [sec] of the correlation function in which the maximum is   *
;*             searched.                                                                  *
;*   fitorder: Polynomial fit order for detrend                                           *
;*   lowcut:   Low frequency cut by subtracting signal with <lowcut> microsecond          *
;*             integration.                                                               *
;*   filter_low: The low frequency limit of the digital filter [Hz]  (def:0)              *
;*   filter_high: The high frequency limit of the digital filter [Hz]  (def: fsample/2)   *
;*   filter_order: filter_order  (def: 5)                                                 *
;*   filter_symmetric: Symmetric or asymmetric filter response function.                  *
;*   inttime:  Integration time [microseconds] to remove high frequency noise.            *
;*   /cc: Calculate correlation of correlation                                            *
;*   /cs: Calculate standard TDE                                                          *
;*   /cp: Use crossphase method (fit linear curve to crossphase)                          *
;*   /minimum: Look for time shift of a minimum in the correlation function               *
;*   /asm: Auto spectrum mean method                                                      *
;*   /acfw: Autocorrelation function width method                                         *
;*   /edge_extremum:if the maximum of the parabola is at the edge of taurange, returns    *
;*                 taurange[0]                                                            *
;*   /fit_parabola: fits all correlation points within taurange with a parabola           *
;*   fit_points: number of points for parabola fitting around the maximum                 *
;*   errorproc: Name of error processing function. If not set error messages are printed  *
;*              on the screen.                                                            *
;* OUTPUT:                                                                                *
;*   errormess: Output error message or '' if no error occured.                           *
;******************************************************************************************

default,delta_t,100e-6;   sec
default,taurange,[-delta_t/4, delta_t/4]   ; sec
default,subsample_cc,30 ; The subsampling for the correlation of correlation
default,filter_order,0

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

n1 = n_elements(signal_name_in_1)
n2 = n_elements(signal_name_in_2)
if (((n1 ne 1) or (n2 ne 1)) and (keyword_set(cp) or keyword_set(asm))) then begin
  errormess = 'Multiple signal pairs can be used for TDE, ACFM and CC methods.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif
if (n1 ne n2) then begin
  errormess = 'Number of input signals should be identical for signal 1 and signal 2.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif
nsig = n1

if ((taurange[1]-taurange[0]) gt delta_t*5) then begin
  errormess = 'Invalid tau range in sigproc_tde.pro.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  return
endif



; Reading signal 1
for isig=1,nsig do begin
  signal_cache_get, sampletime=sampletime1x, time=time_sig1x, data=signal1x, name=signal_name_in_1[isig-1],errormess=errormess
  if (errormess ne '') then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
   endif else begin
       print,errormess
    endelse
    return
  endif
  if (isig ne 1) then begin
    if ((where(time_sig1 ne time_sig1x))[0] ge 0)then begin
      errormess = 'Time vector of signals is different (signal 1).'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      return
    endif
  endif else begin
    time_sig1 = time_sig1x
    defsamp = (time_sig1[n_elements(time_sig1)-1]-time_sig1[0])/(n_elements(time_sig1)-1)
    default,sampletime1x,defsamp,/finite
    sampletime1 = sampletime1x
    if (not finite(sampletime1)) then sampletime1 = defsamp
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
    endif
    signal1 = fltarr(n_elements(time_sig1),nsig)
  endelse
  if (defined(timerange)) then begin
    signal1[*,isig-1] = signal1x[ind]
  endif else begin
    signal1[*,isig-1] = signal1x
  endelse
endfor ; Loop through first signal list

; Reading signal 2
for isig=1,nsig do begin
  signal_cache_get, sampletime=sampletime2x, time=time_sig2x, data=signal2x, name=signal_name_in_2[isig-1],errormess=errormess
  if (errormess ne '') then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    return
  endif
  if (isig ne 1) then begin
    if ((where(time_sig2 ne time_sig2x))[0] ge 0)then begin
      errormess = 'Time vector of signals is different (signal 2).'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      return
    endif
  endif else begin
    time_sig2 = time_sig2x
    defsamp = (time_sig2[n_elements(time_sig2)-1]-time_sig2[0])/(n_elements(time_sig2)-1)
    default,sampletime2x,defsamp,/finite
    sampletime2 = sampletime2x
    if (not finite(sampletime2)) then sampletime2 = defsamp
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
    endif
    signal2 = fltarr(n_elements(time_sig2),nsig)
  endelse
  if (defined(timerange)) then begin
    signal2[*,isig-1] = signal2x[ind]
  endif else begin
    signal2[*,isig-1] = signal2x
  endelse
endfor  ; Loop through second signal list

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

; Checking the time difference of the first samples
dt = time_sig2[0]-time_sig1[0]
if (dt lt taurange[0]) then begin
  ; If time difference is before start of time lag, truncating signal2
  ind = where(((time_sig2-time_sig1[0]) ge taurange[0]) and ((time_sig2-time_sig1[0]) le taurange[1]))
  if (ind[0] lt 0) then begin
    errormess = 'Cannot find first matching sample in in signal 2.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    return
  endif
  time_sig2 = time_sig2[ind[0]:n_elements(time_sig2)-1]
  signal2 = signal2[ind[0]:n_elements(signal2)-1,*]
endif else begin
  if (dt gt taurange[1]) then begin
    ; If time difference is after end of time lag, truncating signal1
    ind = where(((time_sig2[0]-time_sig1) ge taurange[0]) and ((time_sig2[0]-time_sig1) le taurange[1]))
    if (ind[0] lt 0) then begin
      errormess = 'Cannot find first matching sample in in signal 1.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      return
    endif
    time_sig1 = time_sig1[ind[0]:n_elements(time_sig1)-1]
    signal1 = signal1[ind[0]:n_elements(signal1)-1,*]
  endif
endelse

; The number of samples
npoints = min([n_elements(time_sig1),n_elements(time_sig2)])
; Ensuring that length of two signals is identical
if (n_elements(time_sig1) ne n_elements(time_sig2)) then begin
  signal1 = signal1[0:npoints-1,*]
  time_sig1 = time_sig1[0:npoints-1]
  signal2 = signal2[0:npoints-1,*]
  time_sig2 = time_sig2[0:npoints-1]
endif

; Low frequency filtering
if (keyword_set(lowcut)) then begin
  for isig=0,nsig-1 do begin
    signal1[*,isig] = reform(signal1[*,isig]) - integ(reform(signal1[*,isig]),lowcut*1e-6/sampletime)
    signal2[*,isig] = reform(signal2[*,isig]) - integ(reform(signal2[*,isig]),lowcut*1e-6/sampletime)
  endfor
endif

; Polynomial fit as baseline subtraction
if (defined(fitorder)) then begin
  x = dindgen(npoints)*sampletime
  for isig=0,nsig-1 do begin
    p = poly_fit(x,double(reform(signal1[*,isig])),fitorder)
    b = p[0]
    for i=1,fitorder do begin
      b = b + p[i]*x^i
    endfor
    signal1[*,isig] = reform(signal1[*,isig]) - b

    p = poly_fit(x,double(reform(signal2[*,isig])),fitorder)
    b = p[0]
    for i=1,fitorder do begin
      b = b + p[i]*x^i
    endfor
    signal2[*,isig] = reform(signal2[*,isig]) - b
  endfor
endif

; High frequency filtering (integration)
 if (keyword_set(inttime)) then begin
  for isig=0,nsig-1 do begin
    signal1[*,isig] = integ(reform(signal1[*,isig]),inttime*1e-6/sampletime)
    signal2[*,isig] = integ(reform(signal2[*,isig]),inttime*1e-6/sampletime)
  endfor
endif

; Bandpass filter
if (defined(filter_order) and defined(filter_low) and defined(filter_high)) then begin
  for isig=0,nsig-1 do begin
    signal1[*,isig] = bandpass_filter_data(reform(signal1[*,isig]),sampletime=sampletime,$
             filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
             filter_symmetric=filter_symmetric,errormess=errormess)
   if (errormess ne '') then begin
       if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif
      return
    endif
    signal2[*,isig] = bandpass_filter_data(reform(signal2[*,isig]),sampletime=sampletime,$
             filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
             filter_symmetric=filter_symmetric,errormess=errormess)
    if (errormess ne '') then begin
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif
      return
    endif
  endfor
endif

; Calculating the time difference between the first samples.
dt = time_sig2[0]-time_sig1[0]
; The time lag range in sample units
taurange_sample = [round((taurange[0]-dt)/sampletime), round((taurange[1]-dt)/sampletime)]
; The number of time lag values
n_tau = taurange_sample[1]-taurange_sample[0]+1
; The list of tau values
tau_list = (findgen(n_tau)+taurange_sample[0])*sampletime + dt
; The number of samples is one interval
delta_t_sample = round(delta_t/sampletime)
; The number of small intervals
n_delta_t = (long(npoints+taurange_sample[0]-taurange_sample[1])/delta_t_sample)
; The start sample of the first interval
start_sample = -taurange_sample[0]
if (start_sample lt 0) then start_sample = 0;

; Correlation in one delta_t interval
corr_array = dblarr(n_tau)
; An array storing the maximum value of the correlation
corr_value_array = dblarr(n_delta_t)
; An array storing the location of the maximum correlation
corr_loc_array = dblarr(n_delta_t)
; The following two arrays are for testing only
corr_value_array_idl = dblarr(n_delta_t)
corr_loc_array_idl = dblarr(n_delta_t)


if (keyword_set(cc)) then begin
  ; Determining the maximum correlation from the whole sample array
  global_corr_array = dblarr(n_tau)
  lowerboundary = start_sample
  upperboundary = npoints-taurange_sample[1]-1;
  signal1_cut = signal1[lowerboundary:upperboundary,*]
  signal2_cut = signal2[lowerboundary+taurange_sample[0]:upperboundary+taurange_sample[1],*]
  ; Calculating the cross-corelation function:
  k=0
  ind = lindgen(upperboundary-lowerboundary+1)
  for tau=taurange_sample[0],taurange_sample[1] do begin
    global_corr_array = total(signal1_cut * signal2_cut[ind+tau-taurange_sample[0],*])
    k += 1
  endfor
  ind_max = where(global_corr_array eq max(global_corr_array))
  if (n_elements(ind_max) gt 1) then begin
    global_ind_max_first = ind_max[where(abs(tau_list[ind_max]) eq min(abs(tau_list[ind_max])))]
  endif else begin
    global_ind_max_first = ind_max[0]
  endelse
  global_corr_array = global_corr_array/n_elements(signal1_cut)
  x = tau_list[[global_ind_max_first-1, global_ind_max_first, global_ind_max_first+1]]
  y = global_corr_array[[global_ind_max_first-1, global_ind_max_first, global_ind_max_first+1]]
  p = poly_fit(x,y,2,/double,status=s)
  global_maxloc = -p[1]/(2*p[2])
  global_maxval = p[0] + p[1]*global_maxloc + p[2]*global_maxloc^2
  corr_interpol_x = findgen((n_tau-1)*subsample_cc+1)/subsample_cc
  global_corr_array_interpol = interpolate(global_corr_array,corr_interpol_x)
endif

; Creation of the global cross-spectrum
if (keyword_set(cp)) then begin
  ; The mean time delay (between the subchannels) will be taken away to avoid "phase-jumps", the second signal will be delayed later by "mean_td"
  fluc_correlation,0, refch='cache/'+signal_name_in_1[0],plotch='cache/'+signal_name_in_2[0],taurange=[-30,30],timerange=timerange,$
          outtime=outtime,outcorr=outcorr,/noplot,/noverbose,errormess=errormess,/silent,lowcut=lowcut,inttime=inttime,$
          filter_low=filter_low,filter_high=filter_high,filter_order=filter_order
  if (errormess ne '') then begin
    ;print,errormess
    ;' There is an error at calling ''fluc_correlation''. Check shotnumber, signal names or other calling parameters.''
    return
  endif
  temp_var=parabola_extremum(x_array=outtime*1e-6,y_array=outcorr)
  mean_td=fix((temp_var[0]-dt)/sampletime)
  ;print,'mean time delay [point]',mean_td
  ;print,mean_td
  ;mean_td=0;
  for idt=1l, n_delta_t-2 do begin
    ; creating the pieces
    lowerboundary = idt*delta_t_sample + start_sample
    upperboundary = lowerboundary+delta_t_sample-1;
    signal1_cut = signal1[lowerboundary:upperboundary,*]
    signal2_cut = signal2[lowerboundary+mean_td:upperboundary+mean_td,*]

    if not defined(global_xspect) then begin
      global_xspect=fft(signal1_cut)*conj(fft(signal2_cut))
    endif else begin
      global_xspect=global_xspect+fft(signal1_cut)*conj(fft(signal2_cut))
    endelse
  endfor
  ; only the half part is needed
  global_xspect=global_xspect[0:n_elements(global_xspect)/2]
  global_xspect2=abs(global_xspect)^2
endif; end of the creation of the global frequency spectrum


; Index array in one interval
ind = lindgen(delta_t_sample)
; Loop through intervals
for idt=1l, n_delta_t-2 do begin
  ; creating the pieces
  lowerboundary = idt*delta_t_sample + start_sample
  upperboundary = lowerboundary+delta_t_sample-1;
  signal1_cut = signal1[lowerboundary:upperboundary,*]
  signal2_cut = signal2[lowerboundary+taurange_sample[0]:upperboundary+taurange_sample[1],*]

  if (keyword_set(cs) or keyword_set(cc) or keyword_set(acfw)) then begin
    ; Calculating the cross-corelation function:
    k=0
    for tau=taurange_sample[0],taurange_sample[1] do begin
      corr_array[k] = total(signal1_cut * signal2_cut[ind+tau-taurange_sample[0],*])
      k += 1
    endfor
    corr_array = corr_array/n_elements(signal1_cut)
  endif ; cs or cc

  if (keyword_set(cp)) then begin
    signal1_cut = signal1[lowerboundary:upperboundary,0]
    signal2_cut = signal2[lowerboundary+mean_td:upperboundary+mean_td,0]

    local_xspect=fft(signal1_cut)*conj(fft(signal2_cut))
    local_xspect=local_xspect[0:n_elements(local_xspect)/2]
    ; computing the phase
    p_array = atan(local_xspect,/phase)
    ; computing the slope of the linear function: fi=w*dt, where dt equals the intercept
    x_array=findgen(n_elements(p_array))
    y_array=p_array/(2*!pi)
    Sxy=total(x_array*y_array*global_xspect2)
    Sxx=total(x_array^2*global_xspect2)
    Sx=total(x_array*global_xspect2)
    Sy=total(y_array*global_xspect2)
    S=total(global_xspect2^2)
    delta=S*Sxx-Sx^2
    slope=(S*Sxy-Sx*Sy)/delta

    phasetest=0
    if phasetest eq 1 then begin
       intercept=(Sxx*Sy-Sx*Sxy)/delta
       y_comp=slope*x_array+intercept
       window,0
     plot,x_array,y_array,xtitle=['frequency[arb]'],ytitle=['phase[rad]'],title=['Linear regression (x-phase method)'],psym=1,charsize=2,charthick=2,xthick=2,ythick=2,thick=2
     oplot,x_array,y_comp,psym=0

     window,1
       plot,x_array,global_xspect/max(global_xspect),title=['Global cross-power'],xtitle=['frequency [arb.]'],$
       ytitle=['power [arb.]'],charsize=2,charthick=2,xthick=2,ythick=2,thick=2
       oplot,global_xspect/max(global_xspect),psym=1
       stop
    end

    corr_loc_array[idt] = (slope*n_elements(signal1_cut)+mean_td)*sampletime + dt
    corr_value_array[idt] = total(float(local_xspect*conj(local_xspect))*global_xspect2)/total(global_xspect2)

  endif  ; cp

  if (keyword_set(cc)) then begin
    ; Correlating the actual correlation function with the global one
    corr_array_interpol = interpolate(corr_array,corr_interpol_x)
    n_cc = long(n_elements(corr_array_interpol)/8)*2+1
    ;lags = findgen(n_cc)-((n_cc-1)/2)
    ;ccorr = c_correlate(global_corr_array_interpol, corr_array_interpol,lags,/covariance)
    lags = [-2,-1,0,1,2]
    ccorr = c_correlate(global_corr_array, corr_array,lags,/covariance)
    ;plot,ccorr
    ;wait,0.1
    ind_max = where(ccorr eq max(ccorr))
    if ((ind_max[0] eq 0) or (ind_max[0] eq n_elements(lags)-1)) then begin
      maxloc = lags[ind_max[0]]*sampletime
      maxval = ccorr[ind_max[0]]
    endif else begin
      x = [-1,0,1]*sampletime
      y = ccorr[ind_max[0]-1:ind_max[0]+1]
      p = poly_fit(x,y,2,/double,status=s)
      maxloc = -p[1]/(2*p[2])
      maxval = p[0] + p[1]*maxloc + p[2]*maxloc^2
    endelse
    corr_value_array[idt] = maxval
    corr_loc_array[idt] = maxloc
    ;corr_value_array[idt] = cc[ind_max]
    ;corr_loc_array[idt] = lags[ind_max]/subsample_cc*sampletime
    corr_loc_array = corr_loc_array + global_maxloc
  endif

  if (keyword_set(cs)) then begin ; This is TDE or ACFM
    ; Just looking for the maximum of the actual correlation function
    retval = parabola_extremum(x=tau_list,y=corr_array,minimum=minimum,fit_parabola=fit_parabola, fit_points=fit_points)
    corr_loc_array[idt] = retval[0]
;    plot,tau_list,corr_array
;   wait,0.5
    if (keyword_set(minimum)) then retval[1] = -retval[1]
    corr_value_array[idt] = retval[1];

    if keyword_set(edge_extremum) then begin
      if (retval[0] le tau_list[0]) or (retval[0] ge tau_list[n_elements(tau_list)-1]) then corr_loc_array[idt]=taurange[0]
    endif

  endif ; if cs

  if (keyword_set(acfw)) then begin
  corr_loc_array[idt]=total(tau_list*corr_array)/total(corr_array)
  endif ; if acfw

  if (keyword_set(ms)) then begin
    ;print,'s1: ',signal1_cut
    ampl=fft(signal1_cut)*conj(fft(signal1_cut))
    ;print,ampl
    ampl=(ampl[0:n_elements(signal1_cut)/2-1])
    if idt eq 1 then begin
      freq=(findgen(n_elements(ampl)))
      freq=freq/max(freq)/(2*sampletime)
      ;print,ampl
    endif
    mean_spect=double(total(freq*ampl)/total(ampl))
    corr_value_array[idt]=mean_spect
  endif
endfor ;end of the t iteration

; creating time vector for the calculated arrays
calctime_array = (dindgen(n_delta_t)+0.5)*delta_t_sample*sampletime + time_sig1[0] + start_sample*sampletime

if (size(td_signal_out,/type) eq 7) then begin
  signal_cache_add, time=calctime_array, data=corr_loc_array/1e-6, name=td_signal_out,errormess=e
  if (e ne '') then begin
    print,e
    return
  endif
endif

if (size(power_signal_out,/type) eq 7) then begin
  signal_cache_add, time=calctime_array, data=corr_value_array, name=power_signal_out,errormess=e
  if (e ne '') then begin
    print,e
    return
  endif
endif



end
