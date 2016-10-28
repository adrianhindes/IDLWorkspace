;This function calcaultes the cross-correlation of BES data

; sample code is
; a = jw_bes_xcorr(9127,'4-1','3-1',trange=[3.4,3.8],freq_filter=[0.01, 1.0],subwindow_npts=2048)

FUNCTION jw_bes_xcorr_old, shot, ch1, ch2, $
  trange=trange , freq_filter = freq_filter, subwindow_npts = subwindow_npts, $
  overlap = overlap, han = han, $
  plot = plot, filter_plot = filter_plot, hungary = hungary
  
  result = {err:0, errmsg:''}

  ; Set the default values
  default, freq_filter, [0.0, 1.0e6]
  default, subwindow_npts, 1024.0
  default, overlap, 0.5
  default, han, 1
  default, power_plot, 0
  default, phase_plot, 0
  default, coherency_plot, 0
  default, oplot_power, 0
  default, oplot_phase, 0
  default, oplot_coherency, 0
  default, xlog, 0
  default, ylog, 0
  default, verbose, 0
  default, dt, 5e-7

  dt = 5e-07
  life_time = 15e-06
  subwindow = life_time*30

  ;shot_number= 9127, channel 4-6, 3-6, 2-6 ,1-6, time: 3.4-3.8sec
  shot_number = shot
;  time_start = 3.4
;  time_end = 3.8
  
  if KEYWORD_SET(hungary) then begin
    channel1 = bes_read_data(shot_number, channel_number1, trange=trange,/hungary)
    channel2 = bes_read_data(shot_number, channel_number2, trange=trange,/hungary)
  endif else begin
    channel1 = bes_read_data(shot_number, ch1, trange=trange)
    channel2 = bes_read_data(shot_number, ch2, trange=trange)
  endelse
  
;  ycplot,channel1.tvector,channel1.data
;  ycplot,channel2.tvector,channel2.data

  print, 'channel1 variance: ' , variance(channel1.data)/mean(channel1.data)
  print, 'channel2 variance: ' , variance(channel2.data)/mean(channel2.data)
  ;print, subwindowsize

;  subwindow_size = floor(subwindow/dt)
  subwindow_size = subwindow_npts
  subwindow_number = floor(size(channel1.data,/N_ELEMENTS)/subwindow_size)

  print, subwindow_size
  print, 'subwindow_number: ', subwindow_number

  asdf = randomn(seed,size(channel1.data,/N_ELEMENTS))
  ;reform_channel1 = reform(asdf(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])

reform_channel1 = reform(channel1.data(1:subwindow_number*subwindow_size)/mean(channel1.data(1:subwindow_number*subwindow_size)),[subwindow_size,subwindow_number])
reform_channel2 = reform(channel2.data(1:subwindow_number*subwindow_size)/mean(channel2.data(1:subwindow_number*subwindow_size)),[subwindow_size,subwindow_number])

;reform_channel1 = reform(JW_BANDPASS(channel1.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])
;reform_channel2 = reform(JW_BANDPASS(channel2.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])
;reform_channel3 = reform(JW_BANDPASS(channel3.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])
;reform_channel4 = reform(JW_BANDPASS(channel4.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])

;result = dblarr(subwindow_size,subwindow_number)
for i = 0L, subwindow_number-1 do begin
  reform_channel1(*,i) = JW_BANDPASS(reform_channel1(*,i), freq_filter[0], freq_filter[1] , BUTTERWORTH=50.0)
  reform_channel2(*,i) = JW_BANDPASS(reform_channel2(*,i), freq_filter[0], freq_filter[1] , BUTTERWORTH=50.0)
endfor
  ;reform_channel1 = JW_BANDPASS(reform_channel1, 0.2, 1 , BUTTERWORTH=100)
  ;reform_channel2 = JW_BANDPASS(reform_channel2, 0.2, 1 , BUTTERWORTH=100)
  ;reform_channel3 = JW_BANDPASS(reform_channel3, 0.2, 1 , BUTTERWORTH=100)
  ;reform_channel4 = JW_BANDPASS(reform_channel4, 0.2, 1 , BUTTERWORTH=100)


xcorr_lag = [-(subwindow_size-1):subwindow_size-1:1]
correlation12 = dblarr(subwindow_number,subwindow_size*2-1)

for i = 0L, subwindow_number-1 do begin
  correlation12(i,*) = yc_correlate(reform_channel1(*,i),reform_channel2(*,i),xcorr_lag)
endfor

mean_xcorr02 = total(correlation12,1)/subwindow_number

;ycplot, xcorr_lag*dt*1e6, mean_xcorr02, out_base_id = oid
mean_envelope02 = sqrt((hilbert(mean_xcorr02))^2.0 + mean_xcorr02^2.0)
;ycplot, xcorr_lag*dt*1e6, mean_envelope02, oplot_id = oid

corr_value = dblarr(2,subwindow_number)

fit_points = [where((xcorr_lag LT -1)*(xcorr_lag GT -5)), where((xcorr_lag GT 1)*(xcorr_lag LT 5)) ]

hilb = dblarr(size(correlation12,/dimensions))
for i = 0L, subwindow_number-1 do begin
  if (ch1 eq ch2) then begin
    corr_fit = jw_quad_fit(xcorr_lag[fit_points],correlation12[i,fit_points] )
    corr_value[0,i] = corr_fit[2]
    corr_value[1,i] = corr_fit[2]
  endif else begin
    xcorr = correlation12[i,*]
    corr_value[0,i] = xcorr[where(xcorr_lag EQ 0)]
    hilb[i,*] = hilbert(correlation12[i,*])
    envelope02 = sqrt((hilbert(correlation12[i,*]))^2.0 + correlation12[i,*]^2.0)
    corr_value[1,i] = envelope02[where(xcorr_lag EQ 0)]
  endelse
endfor

hilb_sum = dblarr(size(hilb[1,*],/dimensions))
corr_sum = dblarr(size(correlation12[1,*],/dimensions))
for i= 0L, subwindow_number-1 do begin
  hilb_sum = hilb_sum + hilb[i,*]
  corr_sum = corr_sum + correlation12[i,*]
endfor
hilb_sum = hilb_sum/subwindow_number
corr_sum = corr_sum/subwindow_number

corr_value2 = sqrt(hilb_sum^2.0 + corr_sum^2.0)

;ycplot, xcorr_lag, corr_sum, out_base_id = oid
;ycplot, xcorr_lag, corr_value2, oplot_id = oid

get_var = dblarr(subwindow_number)
for i = 0L, subwindow_number-1 do begin
  get_var[i] = mean( (reform_channel1[*,i]-mean(reform_channel1[*,i]))^2)
;  get_var(i) = mean( (reform_channel1(*,i)-mean(reform_channel1(*,i)) *(reform_channel2(*,i)-mean(reform_channel2(*,i))
endfor

;mean((piece-mean(piece)).*(piece02-mean(piece02)))/std(piece,1)/std(piece02,1)

  result = CREATE_STRUCT(result, 'lag', xcorr_lag*dt, 'xcorr', correlation12, 'xcorr_mean', mean_xcorr02, 'corr_value', corr_value,'corr_value2',corr_value2, 'var', get_var)
  return, result
end
;
;FUNCTION bes_spectrum, shot, ch1, ch2, trange, $
;  freq_filter = freq_filter, subwindow_npts = subwindow_npts, $
;  overlap = overlap, han = han, $
;  power_plot = power_plot, phase_plot = phase_plot, coherency_plot = coherency_plot, $
;  oplot_power = oplot_power, oplot_phase = oplot_phase, oplot_coherency = oplot_coherency, $
;  xlog = xlog, ylog = ylog, verbose = verbose
;
;  ;******************************************************************************************************
;  ; FUNCTION : bes_spectrum                                                                             *
;  ; Author   : Young-chul Ghim                                                                          *
;  ; Date     : 27th. Dec. 2012                                                                          *
;  ;******************************************************************************************************
;  ; PURPOSE  :                                                                                          *
;  ;   1. To calculate the spectrum (power, phase and coherency) of BES signal at a fixed time           *
;  ;   2. To plot the results (if plot keywords are set)                                                 *
;  ;******************************************************************************************************
;  ; INPUT parameters                                                                                    *
;  ;     shot: <integer>: Shot number                                                                    *
;  ;      ch1: <string>: channel number                                                                  *
;  ;           example: '1-1', '3-2', '4-8'                                                              *
;  ;      ch2: <string>: channel number                                                                  *
;  ;           example: '1-1', '3-2', '4-8'                                                              *
;  ;           NOTE: if ch1 and ch2 are same, then auto-spectrum is calculated.                          *
;  ;                 if ch1 and ch2 are different, then cross-spectrum is calculated.                    *
;  ;      trange:two element vector <floating>: time range in sec where the spectrum is to be calculated *
;  ; Keywords                                                                                            *
;  ;     freq_filter: two element vector <floating>: frequency range to be filtered in [Hz]              *
;  ;     subwindow_npts: scalar <LONG>: Number of data points where FFT is to be performed.              *
;  ;            Note:                                                                                    *
;  ;              1. If subwindow_npts is not a power of 2, then the function will choose the number     *
;  ;                    which is a power of 2 and the closest to the specified subwindow_npts.           *
;  ;              2. If subwindow_npts is larger than the number points available in trange, then        *
;  ;                    the program will force subwindow_npts to be the number of points in trange.      *
;  ;     overlap: scalar <floating>: subwindow overlap fraction                                          *
;  ;                                 Allowed range is 0.0 <= overlap <= 0.5                              *
;  ;     han: 1 or 0: if 1, then a hanning window is applied to each subwindow.                          *
;  ;                  if 0, then a hanning window is not applied.                                        *
;  ;     power_plot: 1 or 0: if 1, then plots a power as a function of frequency                         *
;  ;     phase_plot: 1 or 0: if 1, then plots a phase as a function of frequency                         *
;  ;     coherency_plot: 1 or 0: if 1, then plots a coherency as a function of frequency                 *
;  ;     oplot_power: scalar <long>: give the ycplot ID number to overplot the power                     *
;  ;     oplot_phase: scalar <long>: give the ycplot ID number to overplot the phase                     *
;  ;     oplot_coherency: scalar <long>: give the ycplot ID number to overplot the coherency             *
;  ;     xlog: 1 or 0: if 1, then x-axis is in log-scale; otherwise linear-scale                         *
;  ;     ylog: 1 or 0: if 1, then y-axis is in log-scale; otherwise linear-scale                         *
;  ;     verbose: 1 or 0: if 1, then the procedure prints out messages as it runs                        *
;  ;******************************************************************************************************
;  ; Return value                                                                                        *
;  ;   It returns a strucutre:                                                                           *
;  ;      result.err: if 0, then no error.                                                               *
;  ;                  if not 0, then error                                                               *
;  ;      result.errmsg: contains error message if result.err is not 0,                                  *
;  ;                     otherwise contains empty string                                                 *
;  ;      result.freq: vector <floating>: contains frequency vector in [Hz]                              *
;  ;      result.spectrum: vector <complex>: contains spectrum as a function of frequency                *
;  ;                       i.e., FFT(ch1)*CONJ(FFT(ch2))                                                 *
;  ;      result.spectrum_real_err: vector <floating>: contains error bar size of real part of spectrum  *
;  ;                       Note: If error bar size cannot be estimated, then it is filled with 0's.      *
;  ;      result.spectrum_img_err: vector <floating>: contains error bar size of img part of spectrum    *
;  ;                       Note: If error bar size cannot be estimated, then it is filled with 0's.      *
;  ;      result.power: vector <floating>: contains power as a function of frequency                     *
;  ;                       i.e., ABS(result.spectrum)                                                    *
;  ;      result.power_err: vector <floating>: contains error bar size of power                          *
;  ;                       Note: If error bar size cannot be estimated, then it is filled with 0's.      *
;  ;      result.phase: vector <floating>: contains phase as a function of frequency                     *
;  ;                       i.e., ATAN( Im(result.spectrum)/Re(result.spectrum) )                         *
;  ;      result.phase_err: vector <floating>: contains error bar size of phase                          *
;  ;                       Note: If error bar size cannot be estimated, then it is filled with 0's.      *
;  ;      result.coherency: vector <floating>: contains coherency as a function of frequency             *
;  ;                        Note that if ch1 = ch2, then coherency = 1 by definition                     *
;  ;      result.coherency_err: vector <floating>: contains error bar size of coherency                  *
;  ;                       Note: If error bar size cannot be estimated, then it is filled with 0's.      *
;  ;      result.coherency_thresh: scalar <floating>: contains noise threshold of coherency              *
;  ;                       Note: If error bar size cannot be estimated, then it is 0.                    *
;  ;******************************************************************************************************
;  ; Exmples                                                                                             *
;  ;    d = bes_spectrum(7821, '1-2', '1-3', trange=[0.3, 0.4], freq_filter=[2e4, 1e5])                  *
;  ;******************************************************************************************************
;
;  result = {err:0, errmsg:''}
;
;  ; Set the default values
;  default, freq_filter, [0.0, 1.0e6]
;  default, subwindow_npts, 1024L
;  default, overlap, 0.5
;  default, han, 1
;  default, power_plot, 0
;  default, phase_plot, 0
;  default, coherency_plot, 0
;  default, oplot_power, 0
;  default, oplot_phase, 0
;  default, oplot_coherency, 0
;  default, xlog, 0
;  default, ylog, 0
;  default, verbose, 0
;  default, dt, 0.5e-6
;
;  ; check number of parameters
;  if N_PARAMs() ne 4 then begin
;    if verbose eq 1 then PRINT, 'Incorrect function call.'
;    result.err = 1
;    result.errmsg = 'Incorrect function call.'
;    RETURN, result
;  endif
;
;  ; check auto- or cross-spectrum
;  if STRCMP(ch1, ch2) eq 1 then $
;    auto_spec = 1 $
;  else $
;    auto_spec = 0
;
;  ; check the subwindow_npts
;  good_npts = LONG(2^4)
;  for i = 5, 23 do begin
;    good_npts = [good_npts, 2L^LONG(i)]
;  endfor
;  sub_npts = (subwindow_npts GT MAX(good_npts)) ? MAX(good_npts) : subwindow_npts
;  sub_npts = (sub_npts LT MIN(good_npts)) ? MIN(good_npts) : sub_npts
;  inx_floor = WHERE(good_npts LE sub_npts, cnt) & inx_floor = inx_floor[cnt-1]
;  inx_ceil = WHERE(good_npts GE sub_npts) & inx_ceil = inx_ceil[0]
;  sub_npts = (ABS(good_npts[inx_floor] - sub_npts) GE ABS(good_npts[inx_ceil] - sub_npts)) ? good_npts[inx_ceil] : good_npts[inx_floor]
;
;  ; read the bes data
;  d1 = bes_read_data(shot, ch1, trange=trange)
;  if d1.err lt 0 then begin
;    if verbose eq 1 then PRINT, d1.errmsg
;    result.err = d1.err
;    result.errmsg = d1.errmsg
;    RETURN, result
;  endif
;
;  if auto_spec eq 0 then begin
;    d2 = bes_read_data(shot, ch2, trange=trange)
;    if d2.err lt 0 then begin
;      if verbose eq 1 then PRINT, d2.errmsg
;      result.err = d2.err
;      result.errmsg = d2.errmsg
;      RETURN, result
;    endif
;  endif
;
;  ; Frequency filter the signal
;  if verbose eq 1 then PRINT, 'Frequency Filtering the signal...', format='(A,$)'
;  s1 = yc_freq_filter(d1.data, dt, freq_filter[0], freq_filter[1])
;  if auto_spec eq 0 then begin
;    s2 = yc_freq_filter(d2.data, dt, freq_filter[0], freq_filter[1])
;  endif
;  if verbose eq 1 then PRINT,'Done!'
;
;  ; Extract the filter signal
;  data1 = s1.data[s1.inx_nonzero_begin:s1.inx_nonzero_end]
;  if auto_spec eq 0 then begin
;    data2 = s2.data[s2.inx_nonzero_begin:s2.inx_nonzero_end]
;  endif
;  data_npts = N_ELEMENTS(data1)
;  sub_npts = (data_npts LE sub_npts) ? data_npts : sub_npts
;
;  ; Calculate the number of subwindows
;  num_subwindow = 0L
;  inx_start = 0
;  while (inx_start + sub_npts - 1) LE (data_npts - 1) do begin
;    if num_subwindow eq 0 then begin
;      inx_subwindow_start = 0
;    endif else begin
;      inx_subwindow_start = [inx_subwindow_start, inx_start]
;    endelse
;    num_subwindow += 1L
;    inx_start = inx_start + (sub_npts - 1L) * (1.0 - overlap)
;  endwhile
;
;  ; Perform FFT
;  if verbose eq 1 then PRINT, 'Performing FFT...', format='(A,$)'
;  spec1 = complexarr(sub_npts, num_subwindow)
;  spec2 = complexarr(sub_npts, num_subwindow)
;  if han eq 1 then begin
;    han_window = hanning(sub_npts)
;  endif else begin
;    han_window = REPLICATE(1.0, sub_npts)
;  endelse
;  for i=0L, num_subwindow - 1 do begin
;    inx_curr = inx_subwindow_start[i]
;    ;Note: applying hanning window requires careful procedure if the signal to be FFTed containes finite DC values.
;    temp_data = data1[inx_curr:inx_curr+sub_npts-1]
;    ;    avg_temp_data = TOTAL(temp_data)/sub_npts
;    ;    temp_data = (temp_data - avg_temp_data)*han_window + avg_temp_data
;    temp_data = temp_data*han_window
;    spec1[*, i] = FFT(temp_data)
;    if auto_spec eq 0 then begin
;      spec2[*, i] = FFT(data2[inx_curr:inx_curr+sub_npts-1]*han_window)
;    endif else begin
;      spec2[*, i] = spec1[*, i]
;    endelse
;  endfor
;  if verbose eq 1 then PRINT, 'Done!'
;
;  ; Calculate averaged spectrum, power, phase and coherency
;  if verbose eq 1 then PRINT, 'Calculating averaged spectrum, power, phase and coherency...', format='(A,$)'
;  temp_spec12 = spec1 * CONJ(spec2)
;  avg_spec12 = TOTAL(temp_spec12, 2)/num_subwindow
;  avg_power12 = ABS(avg_spec12)
;  avg_phase12 = ATAN(avg_spec12, /phase)
;  if auto_spec eq 0 then begin
;    temp_spec11 = spec1 * CONJ(spec1)
;    avg_spec11 = TOTAL(temp_spec11, 2)/num_subwindow
;    avg_power11 = ABS(avg_spec11)
;    temp_spec22 = spec2 * CONJ(spec2)
;    avg_spec22 = TOTAL(temp_spec22, 2)/num_subwindow
;    avg_power22 = ABS(avg_spec22)
;    coherency12 = (avg_power12 * avg_power12) / (avg_power11 * avg_power22)
;  endif else begin
;    coherency12 = FLTARR(sub_npts)
;    coherency12[*] = 1.0
;  endelse
;  ; Calculate error bars
;  real_spec12 = REAL_PART(temp_spec12)
;  avg_real_spec12 = TOTAL(real_spec12, 2)/num_subwindow
;  img_spec12 = IMAGINARY(temp_spec12)
;  avg_img_spec12 = TOTAL(img_spec12, 2)/num_subwindow
;  spec_real_err = FLTARR(sub_npts)
;  spec_img_err = FLTARR(sub_npts)
;  power_err = FLTARR(sub_npts)
;  phase_err = FLTARR(sub_npts)
;  coherency_err = FLTARR(sub_npts)
;  for i = 0L, sub_npts-1 do begin
;    spec_real_err[i] = STDDEV(real_spec12[i, *])/SQRT(num_subwindow)
;    spec_img_err[i] = STDDEV(img_spec12[i, *])/SQRT(num_subwindow)
;  endfor
;  ;power error bar: power = SQRT(real^2 + img^2)
;  ; Error propagation
;  ; 1. due to real^2 --> call it sigma_real_square
;  ; 2. due to img^2 --> call it sigma_img_square
;  sigma_real_square = 2.0 * spec_real_err * avg_real_spec12
;  sigma_img_square = 2.0 * spec_img_err * avg_img_spec12
;  ; 3. due to real^2 + img^2 --> call it sigma_square_sum
;  sigma_square_sum = SQRT(sigma_real_square*sigma_real_square + sigma_img_square*sigma_img_square)
;  ; 4. due to SQRT(real^2+img^2) --> this is the power_err
;  power_err = 0.5 * sigma_square_sum / avg_power12
;  ;phase error bar: phase = ATAN(img/real)
;  ; if auto_spec = 1, then phase = 0 by definition, thus no need to calculate phase_err for this case.
;  if auto_spec eq 0 then begin
;    ; Error propagation
;    ; 1. due to img/real --> call it sigma_img_over_real
;    sigma_img_over_real = SQRT( (spec_img_err/avg_img_spec12)*(spec_img_err/avg_img_spec12) + $
;      (spec_real_err/avg_real_spec12)*(spec_real_err/avg_real_spec12) ) * $
;      (avg_img_spec12/avg_real_spec12)
;    ; 2. due to ATAN(img/real) --> This is phase_err
;    phase_err = sigma_img_over_real / (1.0 + ( (avg_img_spec12/avg_real_spec12)*(avg_img_spec12/avg_real_spec12) ))
;  endif else begin
;    phase_err[*] = 0.0 ;by definition, there is no error.
;  endelse
;  ;coherency erro bar: coherency = (avg_power12)^2/(avg_power11*avg_power22)
;  ;if auto_spec = 1, then coherency = 1 by definition, thus no need to calculate coherency_err for this case.
;  if auto_spec eq 0 then begin
;    ; Error propagation
;    ; 1. due to (avg_power12)^2 --> call it sigma_power12_square
;    sigma_power12_square = 2.0 * power_err * avg_power12
;    ; 2. due to avg_power11 --> call it sigma_power11 (Note: avg_power11 = ABS(avg_spec11) and avg_spec11 is purely real by definition.)
;    ; 3. due to avg_power22 --> call it sigma_power22 (Note: avg_power22 = ABS(avg_spec22) and avg_spec22 is purely real by definition.)
;    sigma_power11 = FLTARR(sub_npts)
;    sigma_power22 = FLTARR(sub_npts)
;    real_spec11 = REAL_PART(temp_spec11)
;    real_spec22 = REAL_PART(temp_spec22)
;    for i = 0L, sub_npts - 1 do begin
;      sigma_power11[i] = STDDEV(real_spec11[i, *])/SQRT(num_subwindow)
;      sigma_power22[i] = STDDEV(real_spec22[i, *])/SQRT(num_subwindow)
;    endfor
;    ; 4. due to avg_power11 * avg_power22 --> call it sigma_power11_22
;    sigma_power11_22 = SQRT( (sigma_power11/avg_power11)^2 + (sigma_power22/avg_power22)^2 ) * avg_power11 * avg_power22
;    ; 5 due to (avg_power12)^2/(avg_power11*avg_power22) --> this is coherency_err
;    coherency_err = SQRT( (sigma_power12_square/(avg_power12*avg_power12))^2 + (sigma_power11_22/(avg_power11*avg_power22))^2 ) * coherency12
;  endif else begin
;    coherency_err[*] = 0.0
;  endelse
;  coherency_thresh = 1.0/SQRT(num_subwindow)
;  if verbose eq 1 then PRINT, 'Done!'
;
;  ; Calculate Frequency Domain
;  N21 = sub_npts/2 + 1 ;Midpoints + 1 is the most negative frequency subscript
;  freq = LINDGEN(sub_npts)
;  if sub_npts mod 2 eq 0 then begin
;    freq[N21] = N21 - sub_npts + FINDGEN(N21-2) ;inserting negative frequency
;  endif else begin
;    freq[N21] = N21 - sub_npts + FINDGEN(N21-1) ;inserting negative frequency
;  endelse
;  freq = freq/(sub_npts*dt) ;now, freq contains the unit of [Hz].
;
;  ; Shift all the result so that the most negative frequency comes the first in the array, then save the results.
;  result = CREATE_STRUCT(result, 'freq', SHIFT(freq, -N21), 'spectrum', SHIFT(avg_spec12, -N21), $
;    'spectrum_real_err', SHIFT(spec_real_err, -N21), 'spectrum_img_err', SHIFT(spec_img_err, -N21), $
;    'power', SHIFT(avg_power12, -N21), 'power_err', SHIFT(power_err, -N21), $
;    'phase', SHIFT(avg_phase12, -N21), 'phase_err', SHIFT(phase_err, -N21), $
;    'coherency', SHIFT(coherency12, -N21), 'coherency_err', SHIFT(coherency_err, -N21), $
;    'coherency_thresh', coherency_thresh)
;
;  ; plot the result
;  str_legend = '#' + STRING(shot, format='(i0)') + ' ' + $
;    'Ch(' + ch1 + ', ' + ch2 + ') ' + $
;    '[' + STRING(trange[0]*1e3, format='(f0.4)') + ', ' + STRING(trange[1]*1e3, format='(f0.4)') + ']msec ' + $
;    '[' + STRING(freq_filter[0]*1e-3, format='(f0.2)') + ', ' + STRING(freq_filter[1]*1e-3, format='(f0.2)') + ']kHz'
;  if power_plot eq 1 then begin
;    ycplot, result.freq*1e-3, result.power, error = result.power_err, legend_item = str_legend, xlog = xlog, ylog = ylog, $
;      xtitle = 'Frequency [kHz]', ytitle = 'Power'
;  endif
;
;  if oplot_power ne 0 then begin
;    ycplot, result.freq*1e-3, result.power, error = result.power_err, legend_item = str_legend, oplot_id = oplot_power
;  endif
;
;  if phase_plot eq 1 then begin
;    ycplot, result.freq*1e-3, result.phase, error = result.phase_err, legend_item = str_legend, xlog = xlog, ylog = ylog, $
;      xtitle = 'Frequency [kHz]', ytitle = 'Phase [rad]'
;  endif
;
;  if oplot_phase ne 0 then begin
;    ycplot, result.freq*1e-3, result.phase, error = result.phase_err, legend_item = str_legend, oplot_id = oplot_phase
;  endif
;
;  if coherency_plot eq 1 then begin
;    ycplot, result.freq*1e-3, result.coherency, error = result.coherency_err, legend_item = str_legend, xlog = xlog, ylog = ylog, $
;      xtitle = 'Frequency [kHz]', ytitle = 'Coherency', out_base_id = oid
;  endif
;
;  if oplot_coherency ne 0 then begin
;    ycplot, result.freq*1e-3, result.coherency, error = result.coherency_err, legend_item = str_legend, oplot_id = oplot_coherency
;  endif
;
;
;  RETURN, result
;
;END
