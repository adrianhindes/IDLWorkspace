pro polar_gen_sample_no2

  start_time = systime()
  print, start_time
  
  tau_fluc=100e-6 ;[seconds]
  f_fluc=10e3 ;[Hz]
  vel_rms_perc = 0.1


  tau_life=15e-6
  vm =20000 ;m/s
  
  lamb_x=3.51e-2
  lamb_y=20e-2
  N = 10
  
  initial_r = 30e-2
  range_phi = !PI/9
  len_r=25e-2 ;m
  len_phi=range_phi*2
  len_t=2000e-6 ;second
  divide_r=0.5e-2
  divide_phi=!PI/180
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
  n0=random_gaussian(N)
  vy=random_gaussian(size_t)
  
  r0 = dblarr(N)
  phi0 = dblarr(N)
  t0 = dblarr(N)
  
;  print, randomu(seed, 20)
;  stop
 ; randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
  ;randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
  for i=0, N-1 do begin
    x_sam =randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
;    print, x_sam
    y_sam =randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
;    print, y_sam
    phi_sam = atan(y_sam/x_sam)
;    print, phi_sam
;    print, 100
    while (atan(y_sam/x_sam) LT -range_phi) || (atan(y_sam/x_sam) GT range_phi) do begin
      x_sam =randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
      y_sam =randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
      phi_sam = atan(y_sam/x_sam)
      while (x_sam/cos(phi_sam) LT initial_r) || (x_sam/cos(phi_sam) GT (initial_r+len_r)) do begin
        x_sam =randomu(seed, 1)*(x_range_2 - x_range_1)+x_range_1
        y_sam =randomu(seed, 1)*(y_range_2 - y_range_1)+y_range_1
        phi_sam = atan(y_sam/x_sam)
      endwhile
    endwhile
    phi0[i] = phi_sam
    r0[i] = x_sam/cos(phi_sam)
    t0[i] = randomu(seed, 1)*len_t
  endfor
  
;  print, phi0
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
;    vt[i] = vm + convol(vy,ex)*sin(2.0*!pi*f_fluc*taxis[i])
;  endfor
;  vt = vm + convol(vy, kernel)*sin(2.0*!pi*f_fluc*taxis)

  kernel_axis = dindgen(tau_fluc/divide_t*0.5)*divide_t
  kernel = exp(-kernel_axis^2.0/tau_fluc^2.0)*sin(2.0*!pi*f_fluc*kernel_axis)
  vfluc = convol(vy, kernel)
  rms_vfluc=sqrt(total(vfluc*vfluc/size_t))
  a=vel_rms_perc * vm / rms_vfluc
  vfluc = vfluc * a  
  vt = vm + vfluc ;require scaling.
  r_average = initial_r +len_r/2
  phi_dot = vt/r_average
 
;  stop

  for i=20L, 32-1 do begin
    for j=20L, 32-1 do begin
      for l=0L, size_t-1 do begin
        for k=0L, N-1 do begin
            del_n[i, j, l] = del_n[i, j, l] + n0[k] * $
            exp(-(r_axis[i]-r0[k])^2.0/(2.0*lamb_x^2.0)) * $
            exp(-(phi_axis[j]+(phi_dot[l]*(t_axis[l]-t0[k])-phi0[k]))^2.0/(2.0*(lamb_y/r_axis[i])^2.0)) * $
            exp(-(t_axis[l]-t0[k])^2.0/(2.0*tau_life^2)) * $
            cos(2.0*!pi*(phi_axis[j]+(phi_dot[l]*(t_axis[l]-t0[k])-phi0[k]))/(lamb_y/r_axis[i]))
        endfor
      endfor
    endfor
  endfor

  end_time = systime()
  print, end_time

  OPENW, 1, 'eddy022.dat'
  PRINTF, 1, size_r
  PRINTF, 1, size_phi
  PRINTF, 1, size_t
  printf, 1, initial_r
  printf, 1, range_phi
  printf, 1, len_r
  printf, 1, len_phi
  printf, 1, len_t
  printf, 1, divide_r
  printf, 1, divide_phi
  printf, 1, divide_t
  printf, 1, 10000000000
  for k=0L, size_t-1 do begin
    for j=0L, size_phi-1 do begin
      for i=0L, size_r-1 do begin
          printf, 1, del_n[i, j, k]
      endfor
    endfor
  endfor

  CLOSE, 1  
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

stop

end