pro model01

  period = 1.0
  baseN = 1000
  randomwidth = 300.0
  rep = 30.0
  del_t = period/baseN
  decay = 0.5
  amp = 0.5
  part = 2^13
  
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
    freq = [0.0, X, totalN/2, -totalN/2.0 + X]/(totalN*del_t)
    N21 = totalN/2+1
    freq = shift(freq, -N21)
  endif else begin
    freq = [0.0, X, -(totalN/2.0 + 1.0) + X]/(totalN*del_t)
    N21 = totalN/2+0.5
    freq = shift(freq, -N21)
  end
  
;---------make model -----------
  packet = fltarr(baseN+randomwidth,rep)
  
  For i = 0, rep-1 do begin  
    For j = 0, Ns[i]-1 do begin
      packet[j,i] = amp*exp(-t[j,i]/decay)    ;k[j]*del_t
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
  
  npts_model = N_ELEMENTS(model)
  print, npts_model
;  stop
  
  num_part = Long(npts_model / part)
  print, part
  print, num_part
  print,part*num_part
;  stop
  
  model_f = fft(model)
  power = abs((model_f)*(conj(model_f)))
  
  window, 1, xsize = 900, ysize =1200
  !P.MULTI = [0,1,2]
  plot, t_gen1, model
  ;plot, freq, shift(model_f, -N21), xrange = [-10, 10], /ylog
  plot, freq, shift(power, -N21), xrange = [-10, 10], /ylog

end