FUNCTION bes_coherency, shot, ch1, ch2, ch1_array = ch1_array, ch2_array = ch2_array, $
  trange=trange, subwindow_npts = subwindow_npts, $
  overlap = overlap, han = han, $
  plot = plot, hungary = hungary, read_already = read_already
  
  default, subwindow_npts, 1024L
  
  shot_number = shot
  dt = 5e-07
  
  if KEYWORD_SET(ch1_array) then begin
    channel1 = ch1_array
    channel2 = ch2_array
  endif else begin
    if KEYWORD_SET(hungary) then begin
      channel1 = bes_read_data(shot_number, ch1, trange=trange,/hungary)
      channel2 = bes_read_data(shot_number, ch2, trange=trange,/hungary)
    endif else begin
      channel1 = bes_read_data(shot_number, ch1, trange=trange)
      channel2 = bes_read_data(shot_number, ch2, trange=trange)
    endelse
  endelse
  
  if KEYWORD_SET(ch1_array) then begin
    subwindow_size = subwindow_npts
    subwindow_number = floor(size(channel1,/N_ELEMENTS)/subwindow_size)
    reform_channel1 = reform(channel1(0:subwindow_number*subwindow_size-1),[subwindow_size,subwindow_number])
    reform_channel2 = reform(channel2(0:subwindow_number*subwindow_size-1),[subwindow_size,subwindow_number])
  endif else begin
    subwindow_size = subwindow_npts
    subwindow_number = floor(size(channel1.data,/N_ELEMENTS)/subwindow_size)
    reform_channel1 = reform(channel1.data(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])
    reform_channel2 = reform(channel2.data(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])
  endelse
   

  
  fft_channel1 = dblarr(size(reform_channel1,/dimensions))
  for i = 0L, subwindow_number-1 do begin
    fft_channel1(*,i) = fft(reform_channel1(*,i),-1)
  endfor
;  fft_channel1 = abs(fft(reform_channel1,-1))
    fft_channel2 = dblarr(size(reform_channel2,/dimensions))
  for i = 0L, subwindow_number-1 do begin
    fft_channel2(*,i) = fft(reform_channel2(*,i),-1)
  endfor

  T = dt
  N = subwindow_size
  X = (FINDGEN((N - 1)/2) + 1)
  is_N_even = (N MOD 2) EQ 0
  if (is_N_even) then $
    freq = [0.0, X, N/2, -N/2 + X]/(N*T) $
  else $
    freq = [0.0, X, -(N/2 + 1) + X]/(N*T)

  fft_sum1 = dblarr(subwindow_size)
  fft_sum2 = dblarr(subwindow_size)
  fft_sum12 = dblarr(subwindow_size)
  for i = 0L, subwindow_number-1 do begin
    fft_sum1 = fft_sum1 + real_part(fft_channel1(*,i))^2 + imaginary(fft_channel1(*,i))^2
    fft_sum2 = fft_sum2 + real_part(fft_channel2(*,i))^2 + imaginary(fft_channel2(*,i))^2
    fft_sum12 = fft_sum12 + real_part(fft_channel1(*,i))*real_part(fft_channel2(*,i)) - imaginary(fft_channel1(*,i))*imaginary(fft_channel2(*,i))
  endfor
  fft_sum1 = fft_sum1/subwindow_number
  fft_sum2 = fft_sum2/subwindow_number
  fft_sum12 = fft_sum12/subwindow_number
  
  coherence12 = sqrt(fft_sum12^2/fft_sum1/fft_sum2)

  if (is_N_even) then begin
    freq_fix = shift(freq,-N/2-1)
    coherence_fix = shift(coherence12,-N/2-1)
  endif else begin
    freq_fix = shift(freq,-N/2-1)
    coherence_fix = shift(coherence12,-N/2-1)
  endelse
  
  if KEYWORD_SET(plot) then begin
    ycplot, freq_fix, sqrt(coherence_fix), out_base_id = oid
  endif

;  ycplot, freq, sqrt(coherence12), out_base_id = oid
  result = CREATE_STRUCT('freq',freq_fix,'coherence',coherence_fix)
  return, result
END