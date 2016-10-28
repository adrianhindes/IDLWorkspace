pro rect

  OPENR, 1, 'Vel_fluc_03.dat'
  size_t = 400
  for i=0L, round(size_t)-1 do begin
    readf, 1, velocity
    vt[i] = velocity
  endfor
  
  close, 1
end