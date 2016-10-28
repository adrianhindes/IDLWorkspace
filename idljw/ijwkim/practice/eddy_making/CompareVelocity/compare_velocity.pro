pro compare_velocity

  start_time = systime()
  print, start_time
  
  tau_fluc=100e-6 ;[seconds]
  f_fluc=10e3 ;[Hz]
  vel_rms_perc = 0.1
  
  
  tau_life=150e-6
  vm =20000 ;m/s
  
  lamb_x=3.51e-2
  lamb_y=20e-2
  N = 2
  
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
  
  print, size_r
  print, size_phi
  print, size_t
  print, tau_fluc/divide_t*5.0
  
  ;  stop
  x_range_1 = initial_r*0.7
  x_range_2 = initial_r + len_r
  y_range_1 = -x_range_2*range_phi
  y_range_2 = x_range_2*range_phi
  
  print, x_range_1
  print, x_range_2
  print, y_range_1
  print, y_range_2
  
  ;  stop
  
  
  del_n=dblarr(size_r,size_phi,size_t)
  r_axis = dindgen(size_r)*divide_r + initial_r
  phi_axis = dindgen(size_phi)*divide_phi - range_phi
  ;  print, phi_axis
  ;  stop
  t_axis = dindgen(size_t)*divide_t
  
  ;  print, t_axis
  vt = dindgen(size_t)
  ;  ex=fltarr(1)
  
  
;  n0=random_gaussian(N)
  vy=random_gaussian(size_t)
  
  n0 = dblarr(N)
  r0 = dblarr(N)
  phi0 = dblarr(N)
  t0 = dblarr(N)
  
OPENR, 1, 'Eddy_N10000_04.dat'
  print, 'asdfasdfasdf'

for i=0L, N-1 do begin
  readf, 1, n0_text, r0_text, phi0_text, t0_text

  print, n0_text, t0_text
  n0[i] = n0_text
  r0[i] = r0_text
  phi0[i] = phi0_text
  t0[i] = t0_text
endfor

close, 1

n02 = dblarr(N)
r02 = dblarr(N)
phi02 = dblarr(N)
t02 = dblarr(N)

OPENR, 1, 'Eddy_N10000_03.dat'
print, 'asdfasdfasdf'

for i=0L, N-1 do begin
  readf, 1, n0_text, r0_text, phi0_text, t0_text
  
  print, n0_text, t0_text
  n02[i] = n0_text
  r02[i] = r0_text
  phi02[i] = phi0_text
  t02[i] = t0_text
endfor

close, 1


;n0 = getEddy(*,0)
;r0 = getEddy(*,1)
;phi0 = getEddy(*,2)
;t0 = getEddy(*,3)



vt1 = dblarr(round(size_t))
vt2 = dblarr(round(size_t))

OPENR, 1, 'Vel_fluc_03.dat'

for i=0L, round(size_t)-1 do begin
  readf, 1, velocity
  vt[i] = velocity
endfor

close, 1

  r_average = initial_r +len_r/2
  phi_dot = vt/r_average

t2 = 21
t1 = 20

A_dot1 = (phi_dot[t2]+phi_dot[t1])/2+(phi_dot[t2]-phi_dot[t1])/divide_t*((t2+t1)/2*divide_t-t0[0])
A_dot2 = (phi_dot[t2]+phi_dot[t1])/2+(phi_dot[t2]-phi_dot[t1])/divide_t*((t2+t1)/2*divide_t-t02[0])
print, A_dot1, A_dot2


;B = (t2+t1)/2*divide_t
;C =(t2+t1)/2*divide_t-t02[0]
;D = (phi_dot[t2]-phi_dot[t1])/divide_t
;print, B, C, D
;print, C*D
;
;print, (phi_dot[t2]+phi_dot[t1])/2, 1000
;
;print, t02




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;size_inrad = 41
;size_phi = 51
;size_t = 4001
;
;del_n = fltarr(size_inrad, size_phi, size_t)
;
;del_n[*,*,*] = 0
;for k=0L, N-1 do begin
;  for i=0L, size_x-1 do begin
;    for j=0L, size_y-1 do begin
;      if ((j MOD 3) EQ 0) then begin
;        del_n[j,i,k] = 10
;      endif ((i MOD 5) EQ 0) then begin
;        del_n[j,i,k] = 10
;    endfor
;  endfor
;endfor

end