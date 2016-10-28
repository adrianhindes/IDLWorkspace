pro eddy_making_2d_theta_phi

  start_time = systime()
  print, start_time
  
  tau_fluc=100e-6 ;[seconds]
  f_fluc=10e3 ;[Hz]
  vel_rms_perc = 0


  tau_life=15e-6
  vm =50000 ;m/s
  v_phase_group=1.0 ;(phase velocity)/(group velocity). Note: group velocity is vm.
  
  lamb_x=3.51e-2
  lamb_y=20e-2
  lamb_z=100e-2
  N = 100000
  
  initial_r = 30e-2
  range_theta = !PI/18
  
  len_r=25e-2 ;m
  len_theta=range_theta*2
  len_phi = !PI*2/3
  len_t=3000e-6 ;second

  divide_r=10e-3
  divide_theta=!PI/135
  divide_phi = !PI/30
  divide_t=0.5e-6
  
  wide_window = 20
  time_wide_window = 2
  
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
  
  stop


  del_n=fltarr(size_r,size_theta,size_t)
  r_axis = findgen(size_r)*divide_r + initial_r
  theta_axis = findgen(size_theta)*divide_theta - range_theta
  phi_axis = findgen(size_phi)*divide_phi
;  print, theta_axis
;  stop
  t_axis = findgen(size_t)*divide_t
  
;  print, t_axis
  vt_group = findgen(size_t*10)
;  ex=fltarr(1)
  n0=random_gaussian(N)
  vy_group=random_gaussian(size_t*10)
  
  vt_phase = findgen(size_t*10)
  vy_phase=random_gaussian(size_t*10)
  
  r0 = fltarr(N)
  theta0 = fltarr(N)
  phi0 = fltarr(N)
  t0 = fltarr(N)
  
  
;  print, randomu(seed, 20)
;  stop
 ; randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
  ;randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
  for i=0, N-1 do begin
    x_sam =randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
;    print, x_sam
    y_sam =randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
;    print, y_sam
    theta_sam = atan(y_sam/x_sam)
;    print, theta_sam
;    print, 100
    while (atan(y_sam/x_sam) LT -range_theta) || (atan(y_sam/x_sam) GT range_theta) do begin
      x_sam =randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
      y_sam =randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
      theta_sam = atan(y_sam/x_sam)
      while (x_sam/cos(theta_sam) LT initial_r) || (x_sam/cos(theta_sam) GT (initial_r+len_r)) do begin
        x_sam =randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
        y_sam =randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
        theta_sam = atan(y_sam/x_sam)
      endwhile
    endwhile
    theta0[i] = theta_sam
    phi0[i] = randomu(seed, 1)*len_phi*wide_window-0.5*len_phi*(wide_window-1)
    r0[i] = x_sam/cos(theta_sam)
    t0[i] = randomu(seed, 1)*len_t*2
  endfor
  
  ;I need to improve this part because parallel direciton eddy density is not homogeneous
  
  OPENW, 1, 'Eddy_N100000_3d_140917_30_2.dat'
  for i=0, N-1 do begin
    printf, 1, n0[i], r0[i], theta0[i], phi0[i], t0[i]
;    print, n0[i], r0[i], theta0[i], phi0[i], t0[i]
  endfor
  
  CLOSE, 1
  
;  print, theta0
;  print, 1
;  print, r0
;  print, t0
  
;  stop
  
;  For i = 0, rep-1 do begin
;    k = findgen(Ns[i])
;    For j = 0, Ns[i]-1 do begin
;      t[j,i] = k[j]*del_t
;    Endfor
;    totalN = totalN + Ns[i]
;  Endfor
;  x0=random_linear(N)*len_x
;  y0=random_linear(N)*len_y
;  t0=random_linear(N)*len_t

  ;------------------------------------------------------------- Vriable setting
;  for i=0L, size_t-1 do begin
;    ex[0]=exp(-taxis[i]^2.0/tau_fluc^2.0)
;    vt_group[i] = vm + convol(vy_group,ex)*sin(2.0*!pi*f_fluc*taxis[i])
;  endfor
;  vt_group = vm + convol(vy_group, kernel)*sin(2.0*!pi*f_fluc*taxis)

;-----------------------------------------------------velocity fluctuation

  kernel_axis = findgen(tau_fluc/divide_t*5)*divide_t-(tau_fluc*5)/2.0
;  window, /free, xsize = 900, ysize =1200
;  !P.MULTI = [0,1,2]
;  plot, kernel_axis
  kernel = exp(-kernel_axis^2.0/tau_fluc^2.0)*sin(2.0*!pi*f_fluc*kernel_axis)
  vfluc = convol(vy_group, kernel)
  rms_vfluc=sqrt(total(vfluc*vfluc/(size_t*10)))
  a=vel_rms_perc * vm / rms_vfluc
  
;  print, a
  vfluc = vfluc * a  
;  print, vfluc
  vt_group = vm + vfluc ;require scaling
  
  window, 30
  plot, vt_group
  
  kernel_axis_phase = findgen(tau_fluc/divide_t*5)*divide_t-(tau_fluc*5)/2.0
  ;  window, /free, xsize = 900, ysize =1200
  ;  !P.MULTI = [0,1,2]
  ;  plot, kernel_axis
  kernel_phase = exp(-kernel_axis_phase^2.0/tau_fluc^2.0)*sin(2.0*!pi*f_fluc*kernel_axis)
  vfluc_phase = convol(vy_phase, kernel_phase)
  rms_vfluc_phase=sqrt(total(vfluc_phase*vfluc_phase/(size_t*10)))
  a=vel_rms_perc * vm / rms_vfluc_phase
  vfluc_phase = vfluc_phase * a
  vt_phase = vm*v_phase_group + vfluc_phase ;require scaling
  
  plot, vt_phase, xrange =[200, 2000], yrange = [0, 60000]
  
;  stop

  OPENW, 1, 'Vel_fluc_3d_group_140917_30_2.dat'
  for i=500, size_t*5-1 do begin
    printf, 1, vt_group[i]
 ;   print, vt_group[i]
  endfor
  
  CLOSE, 1
  
  OPENW, 2, 'Vel_fluc_3d_phase_140917_30_2.dat'
  for i=500, size_t*5-1 do begin
    printf, 2, vt_phase[i]
 ;   print, vt_phase[i]
  endfor
  
  CLOSE, 2
  
  stop
  
;  r_average = initial_r +len_r/2
;  theta_dot = vt/r_average
; 
; 
; ---------------------------------------density calculation
;;  stop
;  for k=0L, N-1 do begin
;    for i=0L, size_r-1 do begin
;      for j=0L, size_theta-1 do begin
;        del_n[i, j, *] = del_n[i, j, *] + n0[k] * $
;          exp(-(r_axis[i]-r0[k])^2.0/(2.0*lamb_x^2.0)) * $
;          exp(-(theta_axis[j]+(theta_dot*(t_axis-t0[k])-theta0[k]))^2.0/(2.0*(lamb_y/r_axis[i])^2.0)) * $
;          exp(-(t_axis-t0[k])^2.0/(2.0*tau_life^2)) * $
;          cos(2.0*!pi*(theta_axis[j]+(theta_dot*(t_axis-t0[k])-theta0[k]))/(lamb_y/r_axis[i]))
;      endfor
;    endfor
;    PRINT, k
;  endfor
;
;  end_time = systime()
;  print, end_time
;
;----------------------make density data file
;
;  OPENW, 1, 'eddy017.dat'
;  PRINTF, 1, size_r
;  PRINTF, 1, size_theta
;  PRINTF, 1, size_t
;  printf, 1, initial_r
;  printf, 1, range_theta
;  printf, 1, len_r
;  printf, 1, len_theta
;  printf, 1, len_t
;  printf, 1, divide_r
;  printf, 1, divide_theta
;  printf, 1, divide_t
;  printf, 1, 10000000000
;  for k=0L, size_t-1 do begin
;    for j=0L, size_theta-1 do begin
;      for i=0L, size_r-1 do begin
;          printf, 1, del_n[i, j, k]
;      endfor
;    endfor
;  endfor
;
;  CLOSE, 1  
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;size_inrad = 41
;size_theta = 51
;size_t = 4001
;
;del_n = fltarr(size_inrad, size_theta, size_t)
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