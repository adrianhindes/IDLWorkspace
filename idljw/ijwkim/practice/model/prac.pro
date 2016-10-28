pro prac

  period = 1.0
  baseN = 10.0
  randomwidth = 10.0
  rep = 10.0
  del_t = period/baseN
  decay = 0.005
  amp = 0.5
  
  Ns = lonarr(30)
  
  FOR i = 0L, rep-1 DO BEGIN
  
    Ns[i] = ULONG(randomwidth * 2.0 * (RANDOMU( seed, 1 )-0.5))
    
  ENDFOR
  
  Ns = Ns + baseN
  
  t = fltarr(baseN+randomwidth,rep)
  
  
  totalN = 0
;  plot, findgen(Ns[1])
  
  For i = 0, rep-1 do begin
    k = findgen(Ns[i])
    For j = 0, Ns[i]-1 do begin
      t[j,i] = k[j]*del_t
    Endfor
    totalN = totalN + Ns[i]
  Endfor
  
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
    
  print, freq
  plot, freq
  
  print ,fltarr(10)

;weights = lonarr(30)
;
;FOR i = 0, 29 DO BEGIN
;
;weights[i] = ULONG(200 * (RANDOMU( seed, 1 )-0.5))
;
;ENDFOR
;
;print, weights

;repeat begin
;  N = ULONG(200 * (RANDOMU( seed, 1 )-0.5))
;  print, N
;endrep until N EQ -55
;
;print, N


;  period = 1.0
;  N = 1000.0
;  rep = 10.0
;  del_t = period/N
;  
;  t = findgen(N)
;  t_gen = del_t*t
;  
;  line = 5-5*t_gen
;  
;  plot, line
;  
;  line_f = fft(line)
;  
;  N21 = N/2 +1
;  F = INDGEN(N)
;  F[N21] = N21 - N + FINDGEN(N21-2)
;  F = F/(N*del_t)
;  F = shift(F, -N21)
;  
;  plot, F, shift(line_f,-N21), xrange = [-10, 10]
;  plot, F, shift(line_f,-N21), xrange = [-10, 10], /ylog
  

end