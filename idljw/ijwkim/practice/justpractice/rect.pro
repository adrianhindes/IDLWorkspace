pro rect

  OPENR, 1, 'Vel_fluc_03.dat'
  size_t = 400
  
  vt = fltarr(400)
  for i=0L, round(size_t)-1 do begin
    readf, 1, velocity
    vt[i] = velocity
  endfor
  
  close, 1
  
  
  x = findgen(400)
  p = plot(x*0.5,vt/1000, xtitle = 'time ($\mu$s)', ytitle = 'velocity (km/s)')
  
  stop
end