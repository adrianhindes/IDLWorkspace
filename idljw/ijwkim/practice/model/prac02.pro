pro prac02

  period = 1.0
  baseN = 10.0
  randomwidth = 10.0
  rep = 10.0
  del_t = period/baseN
  decay = 0.005
  amp = 0.5
  
  N=1000
  
  a = fltarr(333)
  a[*] = 0
  b = fltarr(334)
  b[*] = 1
  
  c = [a,b,a]
  
  han = HANNING(1000, /DOUBLE)
  plot, han
  plot, c
  
  N21 = N/2 +1
  F = INDGEN(N)
  F[N21] = N21 - N + FINDGEN(N21-2)
  F = F/(N*del_t)
  F = shift(F, -N21)
  
  han_f = fft(han)
  han_power = han_f*conj(han_f)
  
  c_f = fft(c)
  c_power = c_f*conj(c_f)
  
  window, /free, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
  plot, F, shift(han_power, -N21), xrange = [-1, 1], /ylog
  plot, F, shift(c_power, -N21), xrange = [-1, 1], /ylog
  

end