function test_signal, trange, dt
  t_size = round((trange[1]-trange[0])/dt)
  tvector = dindgen(t_size)
  tvector = tvector*dt
  tvector = tvector+trange[0]
  
  freq1 = 170000.0
  phase1 = randomu(seed)*2*!pi-!pi
  
  freq2 = 150000.0
  phase2 = randomu(seed)*2*!pi-!pi
  
;  stop
  freq3 = freq1+freq2
;  freq3 = freq1 + freq2
;  phase3 = 0.77
;  phase3 = phase1 + phase2
  phase3 = randomu(seed)*2*!pi-!pi
;  yvector = sin(2*!PI*freq1*tvector+phase1)*sin(2*!PI*freq2*tvector+phase2) + 0.001*randomn(seed,n_elements(tvector))
;  yvector = sin(2*!PI*freq1*tvector+phase1) + sin(2*!PI*freq2*tvector+phase2) + 1.0/2.0*sin(2*!PI*freq3*tvector+phase3) $
;    +sin(2*!PI*freq1*tvector+phase1)*sin(2*!PI*freq2*tvector+phase2) + 0.2*randomn(seed,n_elements(tvector))
;   yvector = sin(2*!PI*freq1*tvector+phase1)
  yvector = sin(2*!PI*freq1*tvector+phase1) + sin(2*!PI*freq2*tvector+phase2) + 1.0/2.0*sin(2*!PI*freq3*tvector+phase3) $
    + 0.2*randomn(seed,n_elements(tvector))
;  yvector = sin(2*!PI*freq1*tvector+phase1) + 0.001*randomn(seed,n_elements(tvector))
;  print, n_elements(tvector), n_elements(yvector)
;  print, yvector
  ycplot, tvector, yvector
  
  stop
  
  result = CREATE_STRUCT('tvector',tvector,'yvector',yvector)
  return, result
end