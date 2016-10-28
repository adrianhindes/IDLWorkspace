pro correlation
  
  N = 3000
  del_x = 0.01
  N21 = N/2 +1
  F = INDGEN(N)
  F[N21] = N21 - N + FINDGEN(N21-2)
  F = F/(N*del_x)
  F = shift(F, -N21)
  
  x = dindgen(N)
  x = x*del_x
  a01 = 10.0
  b01 = 5.0
  c01 = 1.0
  
  Gfunction01 = a01*exp(-(x-b01)^2/(2*c01^2));*cos(10*x)
  
  a02 = 8.0
  b02 = 4.0
  c02 = 3.0
  ;Gfunction02 = (-(x-b02*0.7)^2+ a02*0.7)*(a02*exp(-(x-b02)^2/(2*c02^2)))/8;*cos(7.6*x))/5
  Gfunction02 = (-(x-b02*0.7)^2+ a02*0.7)*a02*exp(-(x-b01)^2/(2*c02^2));*cos(10*x)
;  Gfunction02 = sin(x/3)
  
  
  window, /free, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
  plot, x, Gfunction01, xrange = [0, 30]
  oplot, x, Gfunction02, col=truecolor('red'); xrange = [0, 30] ;,/ylog
  
  
  f_01 = FFT(Gfunction01)
  G_01 = f_01*conj(f_01)
  C_01 = FFT(G_01, /inverse)
  C_01 = real_part(C_01)
  
  power_01 = f_01*conj(f_01)
  power_01 = abs(power_01)
  
  window, 1, xsize = 900, ysize = 1200
  !P.MULTI = [0,1,2]
  plot, F, shift(C_01, -N21)
  plot, F, shift(power_01, -N21), xrange = [-10, 10];, /ylog
  
  f_02 = FFT(Gfunction02)
  G_02 = f_02*conj(f_02)
  G_02 = real_part(G_02)
  C_02 = FFT(G_02, /inverse)
  C_02 = real_part(C_02)
  
  power_02 = f_02*conj(f_02)
  power_02 = abs(power_02)
  
  ;k = A_CORRELATE(wave ,t_gen)
  
  window, 2, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
;  plot, k
  plot, F, shift(C_02, -N21)
  plot, F, shift(power_02, -N21), xrange = [-10, 10];, /ylog
  
  
  G_12 = f_01*conj(f_02)
  C_12 = FFT(G_12, /inverse)
  C_12 = real_part(C_12)
  
  power_12 = f_01*conj(f_02)
  power_12 = abs(power_12)
  
  window, 3, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
  ;  plot, k
  plot, F, shift(C_12, -N21)
  plot, F, shift(power_12, -N21), xrange = [-10, 10];, /ylog
  
  coefficient = G_12*conj(G_12)/(G_01*G_02)
  
  print, coefficient
  window, 4, xsize = 900, ysize = 1200
  !P.MULTI = [0,1,2]
  plot, abs(coefficient), yrange = [0, 3];, -N21)
;  plot, F, shift(power_02, -N21), /ylog
  
  
  print, correlate(Gfunction01, Gfunction02)
  
  
  stop
  
  
end
