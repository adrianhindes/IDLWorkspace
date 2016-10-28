; This procedure to test the bispectrum routine

PRO bispectrum_test, test

  han = 1
  subtract_mean = 1
  num_subwindows = 64L
  subwindow_npts = 1024L

  signal = FLTARR(num_subwindows, subwindow_npts)
  noise = FLTARR(num_subwindows, subwindow_npts)
  dt = 0.5e-6
  time = findgen(subwindow_npts)*dt
  for i=0L, num_subwindows-1 do begin
    noise = 0.1*randomn(seed, subwindow_npts)
    if test eq 1 then begin
      freq1 = 300.0e3
      freq2 = 200.0e3
      freq3 = 500.0e3
      freq1_amp = 1.0
      freq2_amp = 1.0
      freq3_amp = 0.5
      couple_amp = 1.0
      phase1 = ((randomu(seed, 1)-0.5))[0]*2.0*!pi
      phase2 = ((randomu(seed, 1)-0.5))[0]*2.0*!pi
      phase3 = ((randomu(seed, 1)-0.5))[0]*2.0*!pi
      signal[i, *] = freq1_amp*cos(2.0*!pi*freq1*time+phase1) + $
                     freq2_amp*cos(2.0*!pi*freq2*time+phase2) + $
                     freq3_amp*cos(2.0*!pi*freq3*time+phase3) + $
                     couple_amp*cos(2.0*!pi*freq1*time+phase1)*cos(2.0*!pi*freq2*time+phase2) + $
                     noise
    endif else if test eq 2 then begin 
      freq1 = 100.0e3
      freq2 = 150.0e3
      freq1_amp = 1.0
      freq2_amp = 1.0
      couple_amp = 1.0
      phase1 = ((randomu(seed, 1)-0.5))[0]*2.0*!pi
      phase2 = ((randomu(seed, 1)-0.5))[0]*2.0*!pi 
      signal[i, *] = freq1_amp*cos(2.0*!pi*freq1*time+phase1) + $
                     freq2_amp*cos(2.0*!pi*freq2*time+phase2) + $
                     couple_amp*cos(2.0*!pi*(freq1+freq2)*time+phase1+phase2) + $
                     noise
    endif

  endfor

; Generate the frequency domain
  temp_freq = (findgen((subwindow_npts-1)/2)+1)
  if (subwindow_npts mod 2) eq 0 then $
    freq = [0.0, temp_freq, subwindow_npts/2, -subwindow_npts/2+temp_freq] $
  else $
    freq = [0.0, temp_freq, -(subwindow_npts/2+1) + temp_freq]
  freq = freq / (subwindow_npts*dt)
  inx_nyquist = subwindow_npts/2
  freq = freq[0:inx_nyquist] ;use only positive frequencies

  if han eq 1 then begin
    applied_window = hanning(subwindow_npts)
  endif  else begin 
    applied_window = fltarr(subwindow_npts)
    applied_window[*] = 1.0
  endelse
  fft_signal = complexarr(num_subwindows, subwindow_npts/2+1)
  for i=0L, num_subwindows - 1 do begin
    temp_signal = reform(signal[i, *])
    temp_signal_mean = TOTAL(temp_signal)/N_ELEMENTS(temp_signal)
    if subtract_mean then $
      temp_signal = applied_window*(temp_signal-temp_signal_mean) $
    else $
      temp_signal = applied_window*temp_signal
    temp_fft_signal = FFT(temp_signal)
    fft_signal[i, *] = temp_fft_signal[0:inx_nyquist]
  endfor


; Calculate the bispectrum
; Detailed description of how to calculate this is written on p.6-16 of Research Note# 2013-002.
  PRINT, 'Calculating bispectrum of the signal...', format='(A,$)'
  num_freq = N_ELEMENTS(freq)
  bispec_signal = complexarr(num_freq, num_freq)
  bispec_err = fltarr(num_freq, num_freq)
  bicohe_signal = fltarr(num_freq, num_freq)
  bicohe_err = fltarr(num_freq, num_freq)
  q = num_freq
  total_iteration = q/2.0
  percent_progress = LONG(total_iteration*(findgen(10)+1.0)*0.1)
  for l=0L, total_iteration do begin
    for k=l, q-l-1 do begin
    ; Calculate bispectrum
      temp_bispec = TOTAL(fft_signal[*, k]*fft_signal[*, l]*conj(fft_signal[*, k+l]))
      bispec_signal[k, l] = temp_bispec/num_subwindows
    ; Calculate powers for bicoherency
      temp_power_kl = TOTAL(ABS(fft_signal[*, k]*fft_signal[*, l])^2.0)/num_subwindows    
      temp_power_k_plus_l = TOTAL(ABS(fft_signal[*, k+l])^2.0)/num_subwindows
    ; Calculate bicoherency
      bicohe_signal[k, l] = ABS(bispec_signal[k, l])^2.0/(temp_power_kl*temp_power_k_plus_l)
    endfor
    inx_progress = WHERE(percent_progress eq l, count)
    if count gt 0 then begin
      str = STRCOMPRESS(STRING((inx_progress+1)*10, format='(i0)'), /remove_all)+'% '
      print, str, format='(A,$)'
    endif
  endfor  

; Calculate the bispectrum using the symmetry property in Region A'
  for l=0L, total_iteration do begin
    for k=l, q-l-1 do begin
      bispec_signal[l, k] = bispec_signal[k, l]
      bicohe_signal[l, k] = bicohe_signal[k, l]
    endfor
  endfor
  
; Calculate the bisepctrum using the symmetry property in Region B and B'
  bispec_signal_below = complexarr(num_freq, num_freq)
  bicohe_signal_below = fltarr(num_freq, num_freq)
  for l=0L, num_freq-1 do begin
    for k=0, num_freq-1 do begin
      if  l le k then begin
        bispec_signal_below[k, l] = CONJ(bispec_signal[l, k-l])
        bicohe_signal_below[k, l] = bicohe_signal[l, k-l]
     endif else begin
        bispec_signal_below[k, l] = bispec_signal[k, -k+l]    
        bicohe_signal_below[k, l] = bicohe_signal[k, -k+l]
     endelse
    endfor
  endfor

  freq_y = [-1.0*REVERSE(freq[1:num_freq-1]), freq]
  inx_freq_y_zero = where(freq_y eq 0)
  inx_freq_y_zero = inx_freq_y_zero[0]
  freq_x = freq
  nx = N_ELEMENTS(freq)
  ny = N_ELEMENTS(freq_y)

  bispec_signal_total = complexarr(nx, ny)
  bicohe_signal_total = fltarr(nx, ny)
  for i=0, ny - 1 do begin
    if freq_y[i] lt 0 then begin
      bispec_signal_total[*, i] = bispec_signal_below[*, num_freq-1-i]
      bicohe_signal_total[*, i] = bicohe_signal_below[*, num_freq-1-i]
    endif else begin
      bispec_signal_total[*, i] = bispec_signal[*, i-inx_freq_y_zero]
      bicohe_signal_total[*, i] = bicohe_signal[*, i-inx_freq_y_zero]
    endelse
  endfor


; Calculate autopower of the signal  
  power = fft_signal*conj(fft_signal)
  power = abs(power)
  power = total(power, 1)/num_subwindows

  PRINT, 'DONE!'
  
  ycplot, freq/1e3, power
  ycshade, bicohe_signal_total, freq_x/1e3, freq_y/1e3, ctable_num=3, ctable_invert=1, title='bicohe'
  ycshade, ABS(bispec_signal_total), freq_x/1e3, freq_y/1e3, ctable_num=3, ctable_invert=1, title='ABS(bispec)'
  ycshade, ATAN(bispec_signal_total, /phase), freq_x/1e3, freq_y/1e3, ctable_num=6, title='ATAN(bispec)'

END
