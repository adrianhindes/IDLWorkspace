pro model06

;  period = 1.0
  period = 1.0 ;must be float or double
  baseN = 1000
  randomwidth = 300.0
  rep = 300.0
  del_t = period/baseN
;  decay = 0.5
  decay = 1.0
;  amp = 0.5
  amp = 0.5
  part_pts = 2^13
  error = 0.1
  amp_fluc= 0.1 ;ratio
  
  Ns = lonarr(rep)
  
;-------- making random ----------
  
  FOR i = 0L, rep-1 DO BEGIN
  
    Ns[i] = ULONG(randomwidth * 2.0 * (RANDOMU( seed, 1 )-0.5))
    
  ENDFOR
  
  Ns = Ns + baseN
  
;--------- making time ------------
  
  t = fltarr(baseN+randomwidth,rep)
  
;  plot, findgen(Ns[1])
  totalN = 0
  
  For i = 0, rep-1 do begin
    k = findgen(Ns[i])
    For j = 0, Ns[i]-1 do begin
      t[j,i] = k[j]*del_t
    Endfor
    totalN = totalN + Ns[i]
  Endfor

  N1 = totalN
  t1 = findgen(N1)
  t_gen1 = del_t*t1

;-------frequency part --------

  X = (FINDGEN((totalN - 1)/2) + 1)
  
  is_N_even = (totalN MOD 2) EQ 0

  if (is_N_even) then begin
    freq_total = [0.0, X, totalN/2, -totalN/2.0 + X]/(totalN*del_t)
    N21_total = totalN/2+1
    freq_total = shift(freq_total, -N21_total)
  endif else begin
    freq_total = [0.0, X, -(totalN/2.0 + 1.0) + X]/(totalN*del_t)
    N21_total = totalN/2+1
    freq_total = shift(freq_total, -N21_total)
  end
  
  X = (FINDGEN((part_pts - 1)/2) + 1)
  
  is_N_even = (part_pts MOD 2) EQ 0
  
  if (is_N_even) then begin
    freq = [0.0, X, part_pts/2, -part_pts/2.0 + X]/(part_pts*del_t)
    N21 = part_pts/2+1
    freq = shift(freq, -N21)
  endif else begin
    freq = [0.0, X, -(part_pts/2.0 + 1.0) + X]/(part_pts*del_t)
    N21 = part_pts/2+0.5
    freq = shift(freq, -N21)
  end
  
  print, n_elements(freq)
  print, 10
  
  
;---------make model -----------
  packet = fltarr(baseN+randomwidth,rep)
  
  amp_ran = fltarr(rep)
  
  for i = 0, rep-1 do begin
    amp_ran[i] = 1+ 2.0*(RANDOMU( seed, 1 )-0.5)*amp_fluc
  endfor
  
  For i = 0, rep-1 do begin  
    For j = 0, Ns[i]-1 do begin
      packet[j,i] = amp_ran[i]*amp*exp(-t[j,i]/decay)    ;k[j]*del_t
    Endfor
  Endfor
  
  model = fltarr(totalN)
  
  countN = 0
  for i = 0, rep-1 do begin
    for j = 0, Ns[i]-1 do begin
      model[countN+j] = packet[j,i]
    endfor
    countN = countN+Ns[i]
  endfor
  
  for i = 0, countN-1 do begin
    model[i] = model[i] + amp*2.0*(RANDOMU( seed, 1 )-0.5)*error
  endfor
  
  npts_model = N_ELEMENTS(model)
  print, npts_model
;  stop
  
  part_half_pts = part_pts/2
  part_half_num = Long(npts_model / part_half_pts)
  print, part_half_pts
  print, part_half_num
  print,part_pts*part_half_num
 ; stop
  
  piece_half = fltarr(part_half_pts,part_half_num)
  
  for i = 0, part_half_num-1 do begin
    piece_half[*,i] = model[i*part_half_pts:(i+1)*part_half_pts-1]
  endfor
  
  piece = fltarr(part_pts, part_half_num-1)
  for i = 0, part_half_num-2 do begin
    piece[0:part_half_pts-1, i] = piece_half[*,i]
    piece[part_half_pts:2*part_half_pts-1, i] = piece_half[*,i+1]
  endfor
  
;  plot, piece[*,10]
  
  piece_f = complexarr(part_pts,part_half_num-1)
  for i = 0, part_half_num-2 do begin
    piece_f[*,i] = fft(piece[*,i])
  endfor

  piece_power = complexarr(part_pts,part_half_num)
  for i = 0, part_half_num-2 do begin
    piece_power[*,i] = piece_f[*,i]*conj(piece_f[*,i])
  endfor
  
;  plot,  freq, shift(piece_power[*,10], -N21), xrange = [-10, 10], /ylog
;  stop

  average_power = fltarr(part_pts)
  average_power[*] = 0.0
  for i = 0, part_half_num-2 do begin
    average_power = average_power + reform(piece_power[*,i])
  endfor
  
  average_power = average_power/(part_half_num-1)
  
;  average_real = fltarr(part_pts)
;  average_imag = fltarr(part_pts)
;  average_real[*] = 0.0
;  average_imag[*] = 0.0
  
;  for i = 0, part_num-1 do begin
;    average_real = average_real + reform(real_part(piece_f[*,i]))
;    average_imag = average_imag + reform(imaginary(piece_f[*,i]))
;  endfor
;  
;  plot, freq, shift(piece_f[*,10]*conj(piece_f[*,10]), -N21), xrange = [-10, 10], /ylog
;  stop
;  
;  average_real = average_real/part_num
;  average_imag = average_imag/part_num
;  
;  average_f = complex(average_real, average_imag)

;  power_average = abs((average_f)*(conj(average_f)))
  
  model_f = fft(model)
  power = abs((model_f)*(conj(model_f)))

  window, /free, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
  plot, t_gen1, model, xrange = [0, 2]
  plot, freq, shift(average_power, -N21), xrange = [-10, 10] ,/ylog
;  oplot, freq, shift(average_power, -N21), $
     ;   col=truecolor('red'), thick=3
        

end
