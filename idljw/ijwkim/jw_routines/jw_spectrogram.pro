function jw_spectrogram, tvector, ch1, ch2, $
                      freq_filter = freq_filter, subwindow_npts = subwindow_npts, num_subwindow_avg = num_subwindow_avg, $
                      overlap = overlap, han = han, $
                      power_plot = power_plot, phase_plot = phase_plot, $
                      verbose = verbose
  
;******************************************************************************************************
; FUNCTION : spectrogram                                                                              *
; Author   : Jaewook Kim (Original is made by Young-chul Ghim)                                        *
; Date     : 15th. Jan. 2015                                                                          *
;******************************************************************************************************
; PURPOSE  :                                                                                          *
;   1. To calculate the spectrogram (power, phase and coherency) of BES signal                        *
;   2. To plot the results (if plot keywords are set)                                                 *
;******************************************************************************************************
; INPUT parameters                                                                                    *
;     shot: <integer>: Shot number                                                                    *
;      ch1: data array 1                                                                              *
;      ch2: data array 2                                                                              *
;           NOTE: if ch1 and ch2 are same, then auto-spectrum is calculated.                          *
;                 if ch1 and ch2 are different, then cross-spectrum is calculated.                    *
; Keywords                                                                                            *
;     freq_filter: two element vector <floating>: frequency range to be filtered in [Hz]              *
;     subwindow_npts: scalar <LONG>: Number of data points where FFT is to be performed.              *
;            Note:                                                                                    *
;               If subwindow_npts is not a power of 2, then the function will choose the number       *
;                  which is a power of 2 and the closest to the specified subwindow_npts.             *
;     num_subwindow_avg: scalar <LONG>: number of subwindows to be averaged                           *
;     overlap: scalar <floating>: subwindow overlap fraction                                          *
;                                 Allowed range is 0.0 <= overlap <= 0.5                              *
;     han: 1 or 0: if 1, then a hanning window is applied to each subwindow.                          *
;                  if 0, then a hanning window is not applied.                                        *
;     power_plot: 1 or 0: if 1, then plots a power as a function of time and freq                     *
;     phase_plot: 1 or 0: if 1, then plots a phase as a function of time and freq                     *
;     verbose: 1 or 0: if 1, then the procedure prints out messages as it runs                        *
;******************************************************************************************************
; Return value                                                                                        *
;   It returns a strucutre:                                                                           *
;      result.err: if 0, then no error.                                                               *
;                  if not 0, then error                                                               *
;      result.errmsg: contains error message if result.err is not 0,                                  *
;                     otherwise contains empty string                                                 *
;      result.freq: vector <floating>: contains frequency vector in [Hz]                              *
;      result.tvector: vector <floating>: contains time vector in [s]                                 *
;      result.spectrum: 2D array <complex>: contains spectrum as a function of time and freq          *
;      result.power: 2D array <floating>: contains power as a function of time and freq               *
;                       i.e., ABS(result.spectrum)                                                    *     
;      result.phase: 2D array <floating>: contains phase as a function of time and freq               *
;                       i.e., ATAN( Im(result.spectrum)/Re(result.spectrum) )                         *
;******************************************************************************************************
; Exmples                                                                                             *
;    d = bes_spectrogram(7821, '1-3', '2-4', freq_filter=[5e3, 50e3], /power_plot)                    *
;******************************************************************************************************

  result = {err:0, errmsg:''}
  default, freq_filter, [0.0, 1.0e6]
  default, subwindow_npts, 1024L         
  default, num_subwindow_avg, 4
  default, overlap, 0.5                   
  default, han, 1
  default, power_plot, 0
  default, phase_plot, 0
  default, spectrum_plot, 0
  default, verbose, 0

; check number of parameters
  if N_PARAMs() ne 3 then begin
    if verbose eq 1 then PRINT, 'Incorrect function call.'
    result.err = 1
    result.errmsg = 'Incorrect function call.'
    RETURN, result
  endif

; check auto- or cross-spectrogram
  if array_equal(ch1, ch2) eq 1 then $
    auto_spec = 1 $
  else $
    auto_spec = 0

; check the subwindow_npts
  good_npts = LONG(2^4)
  for i = 5, 23 do begin
    good_npts = [good_npts, 2L^LONG(i)]
  endfor
  sub_npts = (subwindow_npts GT MAX(good_npts)) ? MAX(good_npts) : subwindow_npts
  sub_npts = (sub_npts LT MIN(good_npts)) ? MIN(good_npts) : sub_npts
  inx_floor = WHERE(good_npts LE sub_npts, cnt) & inx_floor = inx_floor[cnt-1]
  inx_ceil = WHERE(good_npts GE sub_npts) & inx_ceil = inx_ceil[0]
  sub_npts = (ABS(good_npts[inx_floor] - sub_npts) GE ABS(good_npts[inx_ceil] - sub_npts)) ? good_npts[inx_ceil] : good_npts[inx_floor]

; read the bes data
  d1 = ch1
  d2 = ch2

; Frequency filter the signal
  dt = tvector[1]-tvector[0]
  fs = 1.0/dt
  df = 1.0/(n_elements(tvector)*dt)
  freq_vector = (dindgen(fs/df)-floor(fs/df/2))*df

  high_pass = freq_filter[0]/(fs/2)
  low_pass = freq_filter[1]/(fs/2)
  
  print, high_pass
  print, low_pass
  
  if verbose eq 1 then PRINT, 'Frequency Filtering the signal...', format='(A,$)' 
  s1 = JW_BANDPASS(ch1, high_pass, low_pass, butterworth = 50)
  if auto_spec eq 0 then begin
    s2 = JW_BANDPASS(ch2, high_pass, low_pass, butterworth = 50)
  endif 
  if verbose eq 1 then PRINT,'Done!'

; Extract the filter signal
  data1 = s1
  if auto_spec eq 0 then begin
    data2 = s2
  endif
  data_npts = N_ELEMENTS(data1)
  sub_npts = (data_npts LE sub_npts) ? data_npts : sub_npts
  raw_tvector = tvector

; Calculate the number of subwindows
  num_subwindow = 0L
  inx_start = 0
  while (inx_start + sub_npts - 1) LE (data_npts - 1) do begin
    if num_subwindow eq 0 then begin
      inx_subwindow_start = 0
    endif else begin
      inx_subwindow_start = double([inx_subwindow_start, inx_start])
    endelse
    num_subwindow += 1L
    inx_start = inx_start + (sub_npts - 1L) * (1.0 - overlap)
  endwhile

; Perform FFT
  if verbose eq 1 then PRINT, 'Performing FFT...', format='(A,$)'
  spec1 = complexarr(sub_npts, num_subwindow)
  spec2 = complexarr(sub_npts, num_subwindow)
  if han eq 1 then begin
    han_window = hanning(sub_npts)
  endif else begin
    han_window = REPLICATE(1.0, sub_npts)
  endelse
  for i=0L, num_subwindow - 1 do begin
    inx_curr = inx_subwindow_start[i]
  ;Note: applying hanning window requires careful procedure if the signal to be FFTed containes finite DC values.
    temp_data = data1[inx_curr:inx_curr+sub_npts-1]
;    avg_temp_data = TOTAL(temp_data)/sub_npts
;    temp_data = (temp_data - avg_temp_data)*han_window + avg_temp_data
    temp_data = temp_data*han_window
    spec1[*, i] = FFT(temp_data)
    if auto_spec eq 0 then begin
      spec2[*, i] = FFT(data2[inx_curr:inx_curr+sub_npts-1]*han_window)
    endif else begin
      spec2[*, i] = spec1[*, i]
    endelse
  endfor
  if verbose eq 1 then PRINT, 'Done!'

; Calculate the output tvector
  if num_subwindow_avg LE 0 then num_subwindow_avg = 1
  i = 0L
  while (i+1)*num_subwindow_avg LE num_subwindow do begin
    temp_start_time = raw_tvector[inx_subwindow_start[i*num_subwindow_avg]]
    temp_end_time = raw_tvector[inx_subwindow_start[(i+1)*num_subwindow_avg-1] + sub_npts - 1]
    if i eq 0 then begin
      tvector = (temp_start_time + temp_end_time)/2.0
    endif else begin
      tvector = [tvector, (temp_start_time + temp_end_time)/2.0]
    endelse
    i = i + 1
  endwhile
  ntvector = N_ELEMENTS(tvector)

; Calculate averaged spectrum, power, and phase
  if verbose eq 1 then PRINT, 'Calculating averaged spectrum, power and phase...', format='(A,$)'
  temp_spec12 = spec1 * CONJ(spec2)
  avg_spec12 = complexarr(ntvector, sub_npts)
  for i=0L, ntvector-1 do begin    
    avg_spec12[i, *] = TOTAL(temp_spec12[*, i*num_subwindow_avg:(i+1)*num_subwindow_avg-1], 2)/num_subwindow_avg
  endfor
  avg_power12 = ABS(avg_spec12)
  avg_phase12 = ATAN(avg_spec12, /phase)

; Calculate Frequency Domain
  N21 = sub_npts/2 + 1 ;Midpoints + 1 is the most negative frequency subscript
  freq = LINDGEN(sub_npts)
  if sub_npts mod 2 eq 0 then begin
    freq[N21] = N21 - sub_npts + FINDGEN(N21-2) ;inserting negative frequency
  endif else begin
    freq[N21] = N21 - sub_npts + FINDGEN(N21-1) ;inserting negative frequency
  endelse
  freq = freq/(sub_npts*dt) ;now, freq contains the unit of [Hz].

; Shift all the result so that the most negative frequency comes the first in the array, then save the results.
  result = CREATE_STRUCT(result, 'freq', SHIFT(freq, -N21), 'tvector', tvector, 'spectrum', SHIFT(avg_spec12, 0, -N21), $
                                 'power', SHIFT(avg_power12, 0, -N21), 'phase', SHIFT(avg_phase12, 0, -N21))
  
  print, n_elements(tvector)                               
  print, n_elements(freq)
  print, n_elements(avg_power12)

; plot the result
  title = '[' + STRING(freq_filter[0]*1e-3, format='(f0.2)') + ', ' + STRING(freq_filter[1]*1e-3, format='(f0.2)') + ']kHz'
  xtitle = 'Time [sec]'
  ytitle = 'Frequency [kHz]'
  if power_plot eq 1 then begin
    ycshade, alog10(result.power), result.tvector, result.freq*1e-3, $
             xtitle = xtitle, ytitle = ytitle, title = title, ztitle = 'alog10(power)'
  endif

  if phase_plot eq 1 then begin
    ycshade, result.phase, result.tvector, result.freq*1e-3, $
             xtitle = xtitle, ytitle = ytitle, title = title, ztitle = 'phase'
  endif

  return, result

END
