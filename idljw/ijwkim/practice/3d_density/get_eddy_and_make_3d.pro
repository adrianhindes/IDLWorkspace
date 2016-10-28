pro get_eddy_and_make_3d

  tau_fluc=100e-6 ;[seconds]
  f_fluc=10e3 ;[Hz]
  vel_rms_perc = 0.1
  
  tau_life=500e-6
  vm =20000 ;m/s
  
  lamb_x=3.51e-2
  lamb_y=20e-2
  lamb_z=100e-2
  N = 30
  R=1.0
  
  initial_r = 30e-2
  range_theta = !PI/18
  
  len_r=25e-2 ;m
  len_theta=range_theta*2
  len_phi = !PI*2/3
  len_t=20000e-6 ;second

  divide_r=10e-3
  divide_theta=!PI/90
  divide_phi = !PI/30
  divide_t=0.5e-6
  
  size_r=len_r/divide_r+1
  size_theta=len_theta/divide_theta+1
  size_phi = len_phi/divide_phi+1
  size_t=len_t/divide_t+1
  
  print, size_r
  print, size_theta
  print, size_phi
  print, size_t
  print, tau_fluc/divide_t*5.0
  
;  stop
  x_range_1 = initial_r*0.7
  x_range_2 = initial_r + len_r
  y_range_1 = -x_range_2*range_theta
  y_range_2 = x_range_2*range_theta
  
  print, x_range_1
  print, x_range_2
  print, y_range_1
  print, y_range_2
  
  ;  stop
  
  
  del_n=dblarr(size_r,size_theta,size_phi,size_t)
  r_axis = dindgen(size_r)*divide_r + initial_r
  theta_axis = dindgen(size_theta)*divide_theta - range_theta
  phi_axis = dindgen(size_phi)*divide_phi
  ;  print, phi_axis
  ;  stop
  t_axis = dindgen(size_t)*divide_t
  
  alpha = dblarr(size_r)
  be = dblarr(size_r)
  
  for i=0L, size_r-1 do begin
    alpha[i] = 0.5
    be[i] = 0.1
  endfor
  
  ;  print, t_axis
  vt = dindgen(size_t)
  ;  ex=fltarr(1)
  
  
;  n0=random_gaussian(N)
  vy=random_gaussian(size_t)
  
  n0 = dblarr(N)
  r0 = dblarr(N)
  theta0 = dblarr(N)
  phi0 = dblarr(N)
  t0 = dblarr(N)
  
OPENR, 1, 'Eddy_N100000_3d_06.dat'
  print, 'asdfasdfasdf'

for i=0L, N-1 do begin
  readf, 1, n0_text, r0_text, theta0_text,phi0_text, t0_text

  print, n0_text, t0_text
  n0[i] = n0_text
  r0[i] = r0_text
  theta0[i] = theta0_text
  phi0[i] = phi0_text
  t0[i] = t0_text
endfor

close, 1


;n0 = getEddy(*,0)
;r0 = getEddy(*,1)
;phi0 = getEddy(*,2)
;t0 = getEddy(*,3)



vt_group = dblarr(round(size_r),round(size_t))
vt_phase = dblarr(round(size_r),round(size_t))

OPENR, 1, 'Vel_fluc_3d_group.dat'

for i=0L, round(size_t)-1 do begin
  readf, 1, velocity
  vt_group[0,i] = velocity
endfor

close, 1

for i=0L, round(size_r)-1 do begin
  vt_group[i,*] = vt_group[0,*]
endfor

OPENR, 1, 'Vel_fluc_3d_phase.dat'

for i=0L, round(size_t)-1 do begin
  readf, 1, velocity
  vt_phase[i] = velocity
endfor

close, 1

for i=0L, round(size_r)-1 do begin
  vt_phase[i,*] = vt_phase[0,*]
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  r_average = initial_r +len_r/2
  phi_dot = vt_group/r_average
  
  phi_int = dblarr(round(size_t))
  
  for i = 0L, size_t-1 do begin
    for j = 0L, i-1 do begin
      phi_int[i] = phi_int[i]+ (phi_dot[j]+phi_dot[j-1])*divide_t/2
    endfor
  endfor
  
  phi_int02 = dblarr(round(size_r),round(size_t))
  
  for i=0L, round(size_r)-1 do begin
    phi_int02[i,*] = phi_int[*]
  endfor
  
  stop
  
  for k=0L, N-1 do begin
    for i=0L, size_r-1 do begin
      for j=0L, size_theta-1 do begin
        for l=0L, size_phi-1 do begin
          del_n[i, j, l, *] = del_n[i, j, l, *] + n0[k] * $
            exp(-(r_axis[i]-r0[k])^2.0/(2.0*lamb_x^2.0)) * $
            exp(-((theta_axis[j]*cos(alpha[i])+phi_axis[l]*sin(alpha[i]))-(phi_int02[i,*]-phi_int02[i,round(k)])*sin(alpha[i]-be[i])-(theta0[k]*cos(alpha[i])+phi0[k]*sin(alpha[i])))^2.0/(2.0*(lamb_y/r_axis[i])^2.0)) * $
            exp(-((-theta_axis[j]*sin(alpha[i])+phi_axis[l]*cos(alpha[i]))-(phi_int02[i,*]-phi_int02[i,round(k)])*cos(alpha[i]-be[i])-(-theta0[k]*sin(alpha[i])+phi0[k]*cos(alpha[i])))^2.0/(2.0*(lamb_z/(R + r_axis[i]*cos(theta_axis[j])))^2.0)) * $
            exp(-(t_axis-t0[k])^2.0/(2.0*tau_life^2)) * $
            cos(2.0*!pi*((theta_axis[j]*cos(alpha[i])+phi_axis[l]*sin(alpha[i]))-(phi_int02[i,*]-phi_int02[i,round(k)])*sin(alpha[i]-be[i])-(theta0[k]*cos(alpha[i])+phi0[k]*sin(alpha[i])))/(lamb_y/r_axis[i]))
        endfor
      endfor
    endfor
    PRINT, k
  endfor
  
  stop
;  stop
  for k=0L, N-1 do begin
    for i=0L, size_r-1 do begin
      for j=0L, size_phi-1 do begin
        del_n[i, j, *] = del_n[i, j, *] + n0[k] * $
          exp(-(r_axis[i]-r0[k])^2.0/(2.0*lamb_x^2.0)) * $
          exp(-(phi_axis[j]-(phi_int-phi_int[round(k)])-phi0[k])^2.0/(2.0*(lamb_y/r_axis[i])^2.0)) * $
          exp(-(t_axis-t0[k])^2.0/(2.0*tau_life^2)) * $
          cos(2.0*!pi*(phi_axis[j]-(phi_int-phi_int[round(k)])-phi0[k])/(lamb_y/r_axis[i]))
      endfor
    endfor
    PRINT, k
  endfor
  
end_time = systime()
print, end_time


;stop

OPENW, lun, 'eddy042.bin', /get_lun
PRINTF, lun, double(size_r)
PRINTF, lun, double(size_phi)
PRINTF, lun, double(size_t)
printf, lun, double(initial_r)
printf, lun, double(range_phi)
printf, lun, double(len_r)
printf, lun, double(len_phi)
printf, lun, double(len_t)
printf, lun, double(divide_r)
printf, lun, double(divide_phi)
printf, lun, double(divide_t)
printf, lun, double(10000000000)
for i=0L, size_r-1 do begin
  for j=0L, size_phi-1 do begin
    for k=0L, size_t-1 do begin
      printf, lun, double(del_n[i, j, k])
    endfor
  endfor
endfor

CLOSE, lun

free_lun, lun

stop
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