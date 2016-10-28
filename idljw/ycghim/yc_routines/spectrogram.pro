;This function calcualtes the spectrogram (power and phase) of input signal.

FUNCTION spectrogram, in1, in2, in_tvector, dt, $
                      freq_filter = freq_filter, subwindow_npts = subwindow_npts, num_subwindow_avg = num_subwindow_avg, $
                      overlap = overlap, han = han, $
                      power_plot = power_plot, phase_plot = phase_plot, $
                      verbose = verbose
  
;*************************************************************************************************************
; Function: spectrogm
; Author  : Young-chul Ghim
; Date    : 8th. September. 2013
;*************************************************************************************************************
; PURPOSE :
;   1. To calculate the spectrogram (power and phase) of input signal
;   2. To plot the results (if plot keywords are set)
;*************************************************************************************************************
; INPUT parameters
;    in1: <1D floating array>
;    in2: <1D floating array>
;        NOTE: in1 and in2 will be FFTed. 
;              If in1 EQ in2, then AUTOPOWER
;              If in1 NE in2, then CROSSPOWER
;    in_tvector: <1D floating array>: contains input time vecotr in [sec]
;    dt: <FLOATING scalar>: time resolution of the input singal in [sec].
; KEYWORDS
;    freq_filter: <two element floating vector>: frequency range to be filtered in [Hz]
;    subwindow_npts: <LONG scalar>: number of data points where FFT is to be perforemd.
;               NOTE:
;                  If subwindow_npts is not a power of 2, then the function will choose the number which is a pwoer 2
;                  and the closest to the specified subwindows_npts.
;    num_subwindow_avg: <LONG scalar>: number of subwindows to be averaged.
;    overlap: <FLOATGIN scalar>: subwindow overlap fraction.
;             Allowed range is 0.0 <= overlap <= 0.5
;    han: <1 or 0>: if 1, then a hanning window is applied to each subwindow.
;                   if 0, then a hanning window is not applied.
;    power_plot: <1 or 0>: if 1, then plots a power as a fucntion of time and frequency.
;    phase_plot: <1 or 0>: if 1, then plots a phase as a function of time and frequency.
;    coherency_plot: <1 or 0>: if 1, then plot a coherency as a function of time and frequency.
;    verbose: <1 or 0>: if 1, then the procedure prints out messgae as it runs.
;*************************************************************************************************************
; Return value
;    This function returns a structure.
;      result.err: if 0, then no error.
;                  if 1, then error
;      result.errmsg: contains error message if result.err is not 0, otherwise it contains empty string.
;      result.freq: <1D floating array>: contains frequency vector in [Hz]
;      result.tvector: <1D floating array>: continas time vector in [s]
;      result.spectrum: <2D complex array>: contains spectrum as a function of time and frequency.
;      result.power: <2D floating array>: contains power as a function of time and frequency.
;                                         i.e. ABS(result.specturm)
;      result.phase: <2D floating array>: contains phase as a function of time and frequency.
;                                         i.e. ATAN(Im(result.spectrum)/Re(result.spectrum))
;*************************************************************************************************************

  result = {err:0, errmsg:''}

; Set the defulat values
  default, freq_filter, [0.0, 1.0e6]
  default, subwindow_npts, 1024L
  default, num_subwindow_avg, 2
  default, overlap, 0.5
  default, han, 1
  default, power_plot, 1
  default, phase_plot, 0
  default, verbose, 0

; Check the number of input parameters
  if N_PARAMS() ne 4 then begin
    if verbose eq 1 then PRINT, 'Incorrect function call.'
    result.err = 1
    result.errmsg = 'Incorrect function call.'
    RETURN, result
  endif 

; Check the subwindow_npts
  good_npts = LONG(2^4)
  for i = 5, 23 do begin
    good_npts = [good_npts, 2L^LONG(i)]
  endfor
  sub_npts = (subwindow_npts GT MAX(good_npts)) ? MAX(good_npts) : subwindow_npts
  sub_npts = (sub_npts LT MIN(good_npts)) ? MIN(good_npts) : sub_npts
  inx_floor = WHERE(good_npts LE sub_npts, cnt) & inx_floor = inx_floor[cnt-1]
  inx_ceil = WHERE(good_npts GE sub_npts) & inx_ceil = inx_ceil[0]
  sub_npts = (ABS(good_npts[inx_floor]-sub_npts) GE ABS(good_npts[inx_ceil]-sub_npts)) ? good_npts[inx_ceil] : good_npts[inx_floow] 

; Frequency filter the signal
  if verbose eq 1 then PRINT, 'Frequency filtering the signal...', format='(A,$)'
  s1 = yc_freq_filter(in1, dt, freq_filter[0], freq_filter[1])
  s2 = yc_freq_filter(in2, dt, freq_filter[0], freq_filter[1])
  if verbose eq 1 then PRINT, 'Done!'

; Extract the filtered signal
  data1 = s1.data[s1.inx_nonzero_begin:s1.inx_nonzero_end]
  data2 = s2.data[s2.inx_nonzero_begin:s2.inx_nonzero_end]
  data_npts = N_ELEMENTS(data1)
  sub_npts = (data_npts LE sub_npts) ? data_npts: sub_npts
  raw_tvector = in_tvector[s1.inx_nonzero_begin:s1.inx_nonzero_end]

; Calculate the number of subwindows
  num_subwindow = 0L
  inx_start = 0
  while (inx_start + sub_npts - 1) LE (data_npts - 1) do begin
    if num_subwindow eq 0 then begin
      inx_subwindow_start = 0
    endif else begin
      inx_subwindow_start = [inx_subwindow_start, inx_start]
   endelse
   num_subwindow += 1L
   inx_start = inx_start + (sub_npts - 1L) * (1.0 - overlap)
  endwhile

; Perform FFT
  if verbose eq 1 then PRINT, 'Performing FFT...', format = '(A,$)'
  spec1 = complexarr(sub_npts, num_subwindow)
  spec2 = complexarr(sub_npts, num_subwindow)
  if han eq 1 then begin
    han_window = hanning(sub_npts)
  endif else begin
    han_window = REPLICATE(1.0, sub_npts)
  endelse
  for i = 0L, num_subwindow - 1 do begin
    inx_curr = inx_subwindow_start[i]
  ;Note: applying hanning window require careful procedure if the singal to be FFTed contains finited DC values.
    spec1[*, i] = FFT(data1[inx_curr:inx_curr+sub_npts-1]*han_window)
    spec2[*, i] = FFT(data2[inx_curr:inx_curr+sub_npts-1]*han_window)
  endfor
  if verbose eq 1 then PRINT, 'Done!'

; Calculte the output tvector
  if num_subwindow_avg LE 0 then num_subwindow_avg = 1
  i = 0L
  while (i+1)*num_subwindow_avg LE num_subwindow do begin
    temp_start_time = raw_tvector[inx_subwindow_start[i*num_subwindow_avg]]
    temp_end_time = raw_tvector[inx_subwindow_start[(i+1)*num_subwindow_avg-1] + sub_npts - 1]
    if i eq 0 then begin
      tvector = (temp_start_time + temp_end_time) / 2.0
   endif else begin
      tvector = [tvector, (temp_start_time + temp_end_time)/2.0]
   endelse
   i = i + 1L
  endwhile
  ntvector = N_ELEMENTS(tvector)

; Calculate averaged spectrum, power and phase
  if verbose eq 1 then PRINT, 'Calculating averaged spectrum, power and phase...', format='(A,$)'
  temp_spec12 = spec1 * CONJ(spec2)
  avg_spec12 = complexarr(ntvector, sub_npts)
  for i = 0L, ntvector - 1 do begin
    avg_spec12[i, *] = TOTAL(temp_spec12[*, i*num_subwindow_avg:(i+1)*num_subwindow_avg-1], 2)/num_subwindow_avg
  endfor
  avg_power12 = ABS(avg_spec12)
  avg_phase12 = ATAN(avg_spec12, /phase)

; Calculate frequency domain
  N21 = sub_npts/2 + 1 ;midpoints + 1 is the most negative frequency subscript
  freq = LINDGEN(sub_npts)
  if sub_npts mod 2 eq 0 then begin
    freq[n21] = N21 - sub_npts + FINDGEN(N21-2); inserting negative frequency
  endif else begin
    freq[n21] = N21 - sub_npts + FINDGEN(N21-1); insertinv negative frequency
  endelse 
  freq = freq/(sub_npts*dt)

; Shift all the reulst so that the most negative frequency comes the first in the array, then save the results.
  result = CREATE_STRUCT(result, 'freq', SHIFT(freq, -N21), 'tvector', tvector, 'spectrum', SHIFT(avg_spec12, 0, -N21), $
                                 'power', SHIFT(avg_power12, 0, -N21), 'phase', SHIFT(avg_phase12, 0, -N21))

; Plot the result
  str_freq_filter = '[' + STRING(freq_filter[0]*1e-3, format='(f0.2)') + ', ' + STRING(freq_filter[1]*1e-3, format='(f0.2)') + ']'
  title = str_freq_filter
  xtitle = 'Time [sec]'
  ytitle = 'Frequency [kHz]'
  if power_plot eq 1 then begin
    ycshade, alog10(result.power), result.tvector, result.freq*1e-3, $
             xtitle = xtitle, ytitle = ytitle, title = title, ztitle = 'alog10(power)'
  endif

  if phase_plot eq 1 then begin
    ycshade, result.phase, result.tvector, result.freq*1e-3, $
             xtitle = xtitle, ytitle = ytitle, title = title, ztitle = 'alog10(power)'
  endif

  RETURN, result

END
