pro test_integral

  initial_r = 30e-2
  range_phi = !PI/9
  len_r=25e-2 ;m
  len_phi=range_phi*2
  len_t=200e-6 ;second
  divide_r=0.5e-2
  divide_phi=!PI/360
  divide_t=0.5e-6
  size_r=len_r/divide_r+1
  size_phi=len_phi/divide_phi+1
  size_t=len_t/divide_t+1

vt = dindgen(size_t)

OPENR, 1, 'Vel_fluc_03.dat'

for i=0L, round(size_t)-1 do begin
  readf, 1, velocity
  vt[i] = velocity
endfor

close, 1

vt_int = dindgen(size_t)

OPENR, 1, 'vt_int.dat'

for i=0L, round(size_t)-1 do begin
  readf, 1, velocity
  vt_int[i] = velocity
endfor

close, 1

stop

end