pro randomdata01

  ;make delta t and number of points
  N = 1000
  del_t = 1e-3
  t = findgen(N)
  t_gen = del_t*t
  
  N21 = N/2 +1
  F = INDGEN(N)
  F[N21] = N21 - N + FINDGEN(N21-2)
  F = F/(N*del_t)
  F = shift(F, -N21)
  
  freq1 = 20
  freq2 = 15
  freq3 = 5*!Pi
  
  wave1 = sin(2.0*!PI*freq1*t_gen)
  wave2 = sin(2.0*!PI*freq2*t_gen)
  wave3 = sin(2.0*!PI*freq3*t_gen)
  
  wave = wave1 + wave2 + wave3
  
  
  f_wave = fft(wave1)
  power = f_wave*conj(f_wave)
  
  
  window, /free, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
  plot, t_gen, wave1
  plot, F, shift(imaginary(f_wave), -N21), xrange = [-100, 100]
  
;  t_life = 0.0001
;  damp = wave*exp(-(t_gen)^2/(t_life)^2)
;  
;  f_damp = FFT(damp)
;  G_damp = f_damp*conj(f_damp)
;  G_damp = real_part(G_damp)
;  C_damp = FFT(G_damp, /inverse)
;  C_damp = real_part(C_damp)
;  
;  
;  
;  power_damp = f_damp*conj(f_damp)
;  power_damp = abs(power_damp)
  
  
  
;window, 1, xsize = 900, ysize =1200
;!P.MULTI = [0,1,2]
;plot, F, shift(C_damp, -N21)
;plot, F, shift(power_damp, -N21), /ylog
  
  
  
end
