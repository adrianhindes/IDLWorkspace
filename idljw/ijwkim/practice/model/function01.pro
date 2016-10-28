pro function01

  period = 0.5
  N = 1000
  rep = 10
  del_t = period/N
  decay = 20
  amp = 0.5
  
  Pro modelpro, per, Num, repeat, delta, decay_t, amplitude
  t = findgen(N)
  t_gen = del_t*t
  
  N1 = N*rep
  t1 = findgen(N*rep)
  t_gen1 = del_t*t1
  
  N21 = N1/2 +1
  F = INDGEN(N1)
  F[N21] = N21 - N1 + FINDGEN(N21-2)
  F = F/(N1*del_t)
  F = shift(F, -N21)
  
  packet = amp*exp(-decay*t_gen)
  print, packet
  model = packet
  
  i=1
  repeat begin
    model = [model,packet]
    ;print, model
    i++
  endrep until i EQ rep
  
  model_f = fft(model)
  power = abs((model_f)*(conj(model_f)))
  
  window, 1, xsize = 900, ysize =1200
  !P.MULTI = [0,1,3]
  plot, t_gen1, model
  plot, F, shift(model_f, -N21), xrange = [-20, 20]
  plot, F, shift(power, -N21), xrange = [-20, 20]
  return
  end
  
  modelpro, period, N, rep, del_t, decay, amp

end