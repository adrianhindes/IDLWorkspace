pro model02

  period = 1.0
  N = 1000.0
  rep = 10.0
  del_t = period/N
  decay = 1
  amp = 0.5
  
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
  
; plot, F
;  stop
  
  packet = amp*exp(-t_gen/decay)
  print, packet
  model = packet
  
  i=1
  repeat begin
    model = [model,packet]
    ;print, model
    i++
  endrep until i EQ rep
  
;  for i=0L, rep-1 do begin
;    model = [model, packet]
;  endfor
  
;  npts_packet = N_ELEMENTS(packet)
;  npts_model = npts_packet*rep
;  model = fltarr(npts_model)
;  for i=0L, rep-1 do begin
;    model[i*npts_packet:(i+1)*npts_packet-1] = packet
;  endfor
;    stop
  
  
  model_f = fft(model)
  model_f = model_f
  power = abs((model_f)*(conj(model_f)))
  
  window, 1, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
  plot, t_gen1, model
  ;plot, F, shift(model_f, -N21), xrange = [-10, 10], /ylog
  plot, F, shift(power, -N21), xrange = [-10, 10], /ylog

end