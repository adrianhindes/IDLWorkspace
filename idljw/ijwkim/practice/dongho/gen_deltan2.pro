function gen_deltan2

  start_time = systime()
  tau_fluc=100e-6 ;[seconds]
  f_fluc=10e3 ;[Hz]
  vel_rms_perc = 0.1
  N = 20
  lamb_x=3.51e-2
  lamb_y=20e-2
  tau_life=15e-6
  vm =20000 ;m/s
  len_x=25e-2 ;m
  len_y=20e-2
  len_t=2000e-6 ;second
  divide_x=0.5e-2
  divide_y=0.5e-2
  divide_t=0.5e-6
  size_x=len_x/divide_x+1
  size_y=len_y/divide_y+1
  size_t=len_t/divide_t+1
  del_n=fltarr(size_x,size_y,size_t)
  xaxis = findgen(size_x)*divide_x
  yaxis = findgen(size_y)*divide_y
  taxis = findgen(size_t)*divide_t
  vt = findgen(size_t*2)
  ex=fltarr(1)
  n0=random_gaussian(N)
  vy=random_gaussian(size_t)
  x0=random_linear(N)*len_x
  y0=random_linear(N)*len_y
  t0=random_linear(N)*len_t

  ;------------------------------------------------------------- Vriable setting
;  for i=0L, size_t-1 do begin
;    ex[0]=exp(-taxis[i]^2.0/tau_fluc^2.0)
;    vt[i] = vm + convol(vy,ex)*sin(2.0*!pi*f_fluc*taxis[i])
;  endfor
;  vt = vm + convol(vy, kernel)*sin(2.0*!pi*f_fluc*taxis)

  kernel_axis = findgen(tau_fluc/divide_t*5.0)*divide_t
  kernel = exp(-kernel_axis^2.0/tau_fluc^2.0)*sin(2.0*!pi*f_fluc*kernel_axis)
  vfluc = convol(vy, kernel)
  rms_vfluc=sqrt(total(vfluc*vfluc/size_t))
  a=vel_rms_perc * vm / rms_vfluc
  vfluc = vfluc * a  
  vt = vm + vfluc ;require scaling.
 
  for k=0L, N-1 do begin
    for i=0L, size_x-1 do begin
      for j=0L, size_y-1 do begin
        del_n[i, j, *] = del_n[i, j, *] + n0[k] * $
          exp(-(xaxis[i]-x0[k])^2.0/(2.0*lamb_x^2.0)) * $
          exp(-(yaxis[j]+(vt*(taxis-t0[k])-y0[k]))^2.0/(2.0*lamb_y^2.0)) * $
          exp(-(taxis-t0[k])^2.0/(2.0*tau_life^2)) * $
          cos(2.0*!pi*(yaxis[j]+vt*(taxis-t0[k])-y0[k])/lamb_y)
      endfor
    endfor
    PRINT, k
  endfor

  end_time = systime()

  result = {deln:del_n, x:xaxis, y:yaxis, t:taxis, vel:vt, tau_fluc:tau_fluc, f_fluc:f_fluc, N:N, $
            lamb_x:lamb_x, lamb_y:lamb_y, tau_life:tau_life, vm:vm, len_x:len_x, len_y:len_y, len_t:len_t, $
            vel_rms_perc:vel_rms_perc, start_time:start_time, end_time:end_time}


; save, result, filename='gen_deltan2_test_02.sav'


  return, result

 end
