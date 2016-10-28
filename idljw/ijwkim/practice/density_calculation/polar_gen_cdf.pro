pro polar_gen_cdf

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
  range_phi = !PI/18
  len_r=25e-2 ;m
  len_phi=!PI/9
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
  vt = dindgen(size_t)
  ex=dblarr(1)
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

  kernel_axis = Dindgen(tau_fluc/divide_t*0.5)*divide_t
  kernel = exp(-kernel_axis^2.0/tau_fluc^2.0)*sin(2.0*!pi*f_fluc*kernel_axis)
  vfluc = convol(vy, kernel)
  rms_vfluc=sqrt(total(vfluc*vfluc/size_t))
  a=vel_rms_perc * vm / rms_vfluc
  vfluc = vfluc * a  
  vt = vm + vfluc ;require scaling.
  r_average = initial_r +len_r/2
  phi_dot = vt/r_average
 
;  stop
  for k=0L, N-1 do begin
    for i=0L, size_r-1 do begin
      for j=0L, size_phi-1 do begin
        del_n[i, j, *] = del_n[i, j, *] + n0[k] * $
          exp(-(r_axis[i]*cos(phi_axis[j])-r0[k]*cos(phi0[k]))^2.0/(2.0*lamb_x^2.0)) * $
          exp(-(r_axis[i]*sin(phi_axis[j])+(phi_dot*r0[k]*(t_axis-t0[k])-r0[k]*sin(phi0[k])))^2.0/(2.0*lamb_y^2.0)) * $
          exp(-(t_axis-t0[k])^2.0/(2.0*tau_life^2)) * $
          cos(2.0*!pi*(r_axis[i]*sin(phi_axis[j])+(phi_dot*r0[k]*(t_axis-t0[k])-r0[k]*sin(phi0[k])))/lamb_y)
      endfor
    endfor
    PRINT, k
  endfor

  end_time = systime()
  print, end_time

  id = ncdf_create('eddy.nc', /CLOBBER)
  ncdf_control, id, /FILL
  
  scalar_id = ncdf_dimdef(id, 'scalar', 1)
  
  dim = SIZE(del_n, /dim)
  dim_r_id = NCDF_DIMDEF(id, 'dim_r', size_r)
  dim_phi_id = NCDF_DIMDEF(id, 'dim_phi', size_phi)
  dim_t_id = NCDF_DIMDEF(id, 'dim_t', size_t)
  
; Define the variables of netCDF
;  R_LTi_id = NCDF_VARDEF(id, 'R_LTi', [npts_id])
;  NCDF_ATTPUT, id, R_LTi_id, 'Description', 'R/LTi'
  size_r_id = NCDF_VARDEF(id, 'size_r', [scalar_id])
  ncdf_attput, id, size_r_id, 'Description', 'size_r'
  
  size_phi_id = NCDF_VARDEF(id, 'size_phi', [scalar_id])
  ncdf_attput, id, size_phi_id, 'Description', 'size_phi'
  
  size_t_id = NCDF_VARDEF(id, 'size_t', [scalar_id])
  ncdf_attput, id, size_t_id, 'Description', 'size_t'
  
  initial_r_id = NCDF_VARDEF(id, 'initial_r', [scalar_id])
  ncdf_attput, id, initial_r_id, 'Description', 'initial_r'
  
  range_phi_id = NCDF_VARDEF(id, 'range_phi', [scalar_id])
  ncdf_attput, id, range_phi_id, 'Description', 'range_phi'
  
  len_r_id = NCDF_VARDEF(id, 'len_r', [scalar_id])
  ncdf_attput, id, len_r_id, 'Description', 'len_r'
  
  len_phi_id = NCDF_VARDEF(id, 'len_phi', [scalar_id])
  ncdf_attput, id, len_phi_id, 'Description', 'len_phi'
  
  len_t_id = NCDF_VARDEF(id, 'len_t', [scalar_id])
  ncdf_attput, id, len_t_id, 'Description', 'len_t'
  
  divide_r_id = NCDF_VARDEF(id, 'divide_r', [scalar_id])
  ncdf_attput, id, divide_r_id, 'Description', 'divide_r'
  
  divide_phi_id = NCDF_VARDEF(id, 'divide_phi', [scalar_id])
  ncdf_attput, id, divide_phi_id, 'Description', 'divide_phi'
  
  divide_t_id = NCDF_VARDEF(id, 'divide_t', [scalar_id])
  ncdf_attput, id, divide_t_id, 'Description', 'divide_t'
  
  del_n_id = NCDF_VARDEF(id, 'del_n', [dim_r_id, dim_phi_id, dim_t_id])
  ncdf_attput, id, del_n_id, 'Description', 'del_n'
  
  ; Put the file in data mode
  NCDF_CONTROL, id, /endef
  
  
;  PRINTF, 1, size_r
;  PRINTF, 1, size_phi
;  PRINTF, 1, size_t
;  printf, 1, initial_r
;  printf, 1, range_phi
;  printf, 1, len_r
;  printf, 1, len_phi
;  printf, 1, len_t
;  printf, 1, divide_r
;  printf, 1, divide_phi
;  printf, 1, divide_t
  
  ; Input the data
  NCDF_VARPUT, id, size_r_id, size_r
  NCDF_VARPUT, id, size_phi_id, size_phi
  NCDF_VARPUT, id, size_t_id, size_t
  NCDF_VARPUT, id, initial_r_id, initial_r
  NCDF_VARPUT, id, range_phi_id, range_phi
  NCDF_VARPUT, id, len_r_id, len_r
  NCDF_VARPUT, id, len_phi_id, len_phi
  NCDF_VARPUT, id, len_t_id, len_t
  NCDF_VARPUT, id, divide_r_id, divide_r
  NCDF_VARPUT, id, divide_phi_id, divide_phi
  NCDF_VARPUT, id, divide_t_id, divide_t
  NCDF_VARPUT, id, del_n_id, del_n
  
  NCDF_VARGET, id, del_n_id , del_n_data
  
  NCDF_CLOSE, id
  
  stop
  
  print, del_n_data[*,*,8]

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


end