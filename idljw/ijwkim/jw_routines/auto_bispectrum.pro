;This function calculates the bispectrum (or bicoherency) of input signal

FUNCTION auto_bispectrum, in1, dt, $
                     freq_filter = freq_filter, subwindow_npts = subwindow_npts, overlap = overlap, han = han, subtract_mean = subtract_mean,  $
                     plot_bispec = plot_bispec, plot_bicohe = plot_bicohe, plot_power = plot_power, verbose = verbose


;*************************************************************************************************************
; FUNCTION: bispectrum
; Author  : Young-chul Ghim
; Date    : 12th. November. 2013
;*************************************************************************************************************
; PURPOSE :
;   1. To calculate the auto-bispectrum (or bicoherency) of the input signal.
;   NOTE: Detailed description of bispectrum is written on p.6-16 of Research Note# 2013-002.
;*************************************************************************************************************
; INPUT parameters
;    in1: <1D floating array>: contains the time series data
;    dt: <floating scalar>: time resolution of the input signal in [sec]
;
; KEYWORDS
;    freq_filter: <two element floating vector>: frequency range to be filtered in [Hz]
;    subwindow_npts: <LONG scalar>: number of data points where FFT is to be perforemd.
;               NOTE:
;                  If subwindow_npts is not a power of 2, then the function will choose the number which is a pwoer 2
;                  and the closest to the specified subwindows_npts.
;    overlap: <FLOATGIN scalar>: subwindow overlap fraction.
;             Allowed range is 0.0 <= overlap <= 0.5
;    han: <1 or 0>: if 1, then a hanning window is applied to each subwindow.
;                   if 0, then a hanning window is not applied.
;    subtract_mean: <1 or 0>: if 1, then the mean of the signal (after freq. filter) is subtracted.
;                             if 0, then the mean of the signal is not subtracted.
;    plot_bispec: plots the magnitude of the bispectrum and phase
;    plot_bicohe: plots the bicoherency
;    plot_power: plots the autopower spectrum
;    verbose: <1 or 0>: if 1, then the procedure prints out messgae as it runs.
;*************************************************************************************************************
; Return value
;   This funciton returns a structure.
;     result.err: if 0, then no error
;                 if 1, then error
;     result.errmsg: contains error message if result.err is not 0, otherwise it contains empty string.
;     result.freqx: <1D floating array>: contains frequency vector for x-axis in [Hz]
;     result.freqy: <1D floating array>: contains frequency vector for y-axis in [Hz]
;     result.bispectrum: <2D complex array>: contains the bispectrum
;     result.bicoherency: <2D floating array>: contains the bicoherency, NOTE: this is 0 unless coherency keyword is set.
;     result.bicoherency_noise_floor: <floating> contains the noise floor of the bicoherency
;*************************************************************************************************************

  result = {err:0, errmsg:''}

; check the calling procedure
  if N_PARAMS() ne 2 then begin
    PRINT, 'Calling proceduer error.'
    PRINT, 'Call this funsion with the following form: result = bispectrum(input_signal, dt)'
    result.err = 1
    result.errmsg = 'Proper calling procedure is not used.'
    return, result
  endif
  signal = in1
  npts = N_ELEMENTS(signal)
  time = findgen(npts)*dt

; set the default values
  default, nyquist_freq, (1.0/dt)*0.5
  default, freq_filter, [0.0, nyquist_freq]
  default, subwindow_npts, 1024L
  default, overlap, 0.8
  default, han, 1
  default, subtract_mean, 1
  default, plot_bispec, 0
  default, plot_bicohe, 1
  default, plot_power, 0
  default, verbose, 1

; frequency filter the signal
  if verbose then begin
    str = 'Frequency filtering the singal [' + string(freq_filter[0]*1e-3, format='(f0.2)') + ', ' + $
          string(freq_filter[1]*1e-3, format='(f0.2)') + ']kHz...'
    PRINT, str, format='(A,$)'
  endif
  filtered_signal = yc_freq_filter(signal, dt, freq_filter[0], freq_filter[1])
  if verbose then PRINT, 'DONE!'

; Remove zeros that are generated by the frequency filtering function
  inx_start = filtered_signal.inx_nonzero_begin
  inx_end = filtered_signal.inx_nonzero_end
  signal = filtered_signal.data[inx_start:inx_end]
  time = time[inx_start:inx_end]
  npts = inx_end - inx_start + 1

; Create subwindows in accordance with the subwindow_npts keyword
  if verbose then PRINT, 'Creating subwindows...', format='(A,$)'   
  if subwindow_npts GT npts then subwindow_npts = npts
  if overlap LT 0.0 then overlap = 0.0
  if overlap GT 0.5 then overlap = 0.5
  inx_subwindow_start = 0L
  inx_curr = 0L
  num_subwindows = 0L
  repeat begin
    num_subwindows = num_subwindows + 1L
    inx_curr = inx_curr + subwindow_npts * (1.0 - overlap)
    inx_subwindow_start = [inx_subwindow_start, inx_curr]
  endrep until (inx_curr+subwindow_npts-1) GT (npts-1)
  inx_subwindow_start = inx_subwindow_start[0:num_subwindows-1]
  if verbose then PRINT, 'DONE!'

; Generate the frequency domain
  if verbose then PRINT, 'Fourier transforming the signal...', format='(A,$)'
  temp_freq = (findgen((subwindow_npts-1)/2)+1)
  if (subwindow_npts mod 2) eq 0 then $
    freq = [0.0, temp_freq, subwindow_npts/2, -subwindow_npts/2+temp_freq] $
  else $
    freq = [0.0, temp_freq, -(subwindow_npts/2+1) + temp_freq]
  freq = freq / (subwindow_npts*dt)
  inx_nyquist = subwindow_npts/2
  freq = freq[0:inx_nyquist] ;use only positive frequencies

; Fourier transform the signal for each subwindow
  if han eq 1 then begin
    applied_window = hanning(subwindow_npts)
  endif  else begin 
    applied_window = fltarr(subwindow_npts)
    applied_window[*] = 1.0
  endelse
  fft_signal = complexarr(num_subwindows, subwindow_npts/2+1)
  for i=0L, num_subwindows - 1 do begin
    inx_curr = inx_subwindow_start[i]
    temp_signal = signal[inx_curr:inx_curr+subwindow_npts-1]
    temp_signal_mean = TOTAL(temp_signal)/N_ELEMENTS(temp_signal)
    if subtract_mean then $
      temp_signal = applied_window*(temp_signal-temp_signal_mean) $
    else $
      temp_signal = applied_window*temp_signal
    temp_fft_signal = FFT(temp_signal)
    fft_signal[i, *] = temp_fft_signal[0:inx_nyquist]
  endfor
  if verbose then PRINT, 'DONE!'

; Calculate the bispectrum
; Detailed description of how to calculate this is written on p.6-16 of Research Note# 2013-002.
  if verbose then PRINT, 'Calculating bispectrum of the signal...', format='(A,$)'
  num_freq = N_ELEMENTS(freq)
  bispec_signal_above = complexarr(num_freq, num_freq)
  bicohe_signal_above = fltarr(num_freq, num_freq)
  q = num_freq
  total_iteration = q/2.0
  percent_progress = LONG(total_iteration*(findgen(10)+1.0)*0.1)
  for l=0L, total_iteration do begin
    for k=l, q-l-1 do begin
    ; Calculate bispectrum
      temp_bispec = TOTAL(fft_signal[*, k]*fft_signal[*, l]*conj(fft_signal[*, k+l]))
      bispec_signal_above[k, l] = temp_bispec/num_subwindows
    ; Calculate powers for bicoherency
      temp_power_kl = TOTAL(ABS(fft_signal[*, k]*fft_signal[*, l])^2.0)/num_subwindows    
      temp_power_k_plus_l = TOTAL(ABS(fft_signal[*, k+l])^2.0)/num_subwindows
    ; Calculate bicoherency
      bicohe_signal_above[k, l] = ABS(bispec_signal_above[k, l])/SQRT(temp_power_kl*temp_power_k_plus_l)
    endfor
    if verbose then begin
      inx_progress = WHERE(percent_progress eq l, count)
      if count gt 0 then begin
        str = STRCOMPRESS(STRING((inx_progress+1)*10, format='(i0)'), /remove_all)+'% '
        print, str, format='(A,$)'
      endif
    endif
  endfor 
  if verbose then PRINT, 'DONE!'

; Calculate the bispectrum using the symmetry property in other regions
  if verbose then PRINT, 'Calculating bispectrum using the symmetry property...', format='(A,$)'
  for l=0L, total_iteration do begin
    for k=l, q-l-1 do begin
      bispec_signal_above[l, k] = bispec_signal_above[k, l]
      bicohe_signal_above[l, k] = bicohe_signal_above[k, l]
    endfor
  endfor
  bispec_signal_below = complexarr(num_freq, num_freq)
  bicohe_signal_below = fltarr(num_freq, num_freq)
  for l=0L, num_freq-1 do begin
    for k=0L, num_freq-1 do begin
      if l LE k then begin
        bispec_signal_below[k, l] = CONJ(bispec_signal_above[l, k-l])
        bicohe_signal_below[k, l] = bicohe_signal_above[l, k-l]
      endif else begin
        bispec_signal_below[k, l] = bispec_signal_above[k, l-k]
        bicohe_signal_below[k, l] = bicohe_signal_above[k, l-k]
      endelse
    endfor
  endfor
 
  freqx = freq
  freqy = [-1.0*REVERSE(freq[1:num_freq-1]), freq]
  inx_freqy_zero = WHERE(freqy eq 0.0)
  inx_freqy_zero = inx_freqy_zero[0]
  nx = N_ELEMENTS(freqx)
  ny = n_ELEMENTS(freqy)

  bispec_signal = complexarr(nx, ny)
  bicohe_signal = fltarr(nx, ny)
  for i=0L, ny - 1 do begin
    if freqy[i] lt 0 then begin
      bispec_signal[*, i] = bispec_signal_below[*, num_freq-1-i]
      bicohe_signal[*, i] = bicohe_signal_below[*, num_freq-1-i]
    endif else begin
      bispec_signal[*, i] = bispec_signal_above[*, i-inx_freqy_zero]
      bicohe_signal[*, i] = bicohe_signal_above[*, i-inx_freqy_zero]
    endelse
  endfor
  bicoherency_noise_floor = SQRT(1.0/num_subwindows)
    
  power = fft_signal*conj(fft_signal)
  power = abs(power)
  power = total(power, 1)/num_subwindows

  if verbose then PRINT, 'DONE!'
  
; plot_bispec = plot_bispec, plot_bicohe = plot_bicohe,
  if plot_bispec then begin
    ycshade, ABS(bispec_signal), freqx/1e3, freqy/1e3, ctable_num=3, ctable_invert=1, $
             xtitle = 'Freq [kHz]', ytitle = 'Freq [kHz]', title = 'ABS(bispectrum)'
    ycshade, ATAN(bispec_signal, /phase), freqx/1e3, freqy/1e3, ctable_num=3, ctable_invert=1, $
             xtitle = 'Freq [kHz]', ytitle = 'Freq [kHz]', title = 'ATAN(bispectrum, /phase)'
  endif

  if plot_bicohe then begin
    title = 'Bicoherency (noise floor: ' + STRING(bicoherency_noise_floor, format='(f0.2)') + ')'
    ycshade, bicohe_signal, freqx/1e3, freqy/1e3, ctable_num=3, ctable_invert=1, $
             xtitle = 'Freq [kHz]', ytitle = 'Freq [kHz]', title = title
  endif

  if plot_power then begin
    power = TOTAL(ABS(fft_signal*conj(fft_signal)), 1)/num_subwindows
    ycplot, freqx/1e3, power,  xtitle='Freq [kHz]', ytitle = 'Autopower spectrum', /ylog
  endif
  
  result = CREATE_STRUCT(result, 'freqx', freqx, 'freqy', freqy, 'bispectrum', bispec_signal, $
                                 'bicoherency', bicohe_signal, 'bicoherency_noise_floor', bicoherency_noise_floor)

  return, result

END
