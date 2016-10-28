;=======================================================================================
; 
; This is function that return the density fluctuation from the synthetic data
;
;=======================================================================================
;
;<Input parameter>
;  1. 
;
;=======================================================================================
;
;<Output result>
;  Numbers that generated from the function
;
;=======================================================================================


function gen_deltan

  lamb_x=3.53e-2 ;cm
  lamb_y=20e-2   ;cm
  tau_life=15e-6 ;micro seconds
  N=500 ;Trial time
  ;Making Arrays
  x=findgen(51)*0.5e-2
  y=findgen(26)*0.5e-2
  t=findgen(1001)*0.5e-6
  ; x[i],y[i] : [cm]
  ; t[i]      : [micro second]

  
  ;Generate normal random numbers
  del_n0=random_gaussian(N)
  del_vy=random_gaussian(1001)
  ;Generate uniform random numbers
  x0=random_linear(N)*25e-2
  y0=random_linear(N)*20e-2
  t0=random_linear(N)*500e-6 ;cause the time range is 0~500 micro seconds

  ;Calculate v_y
  tau_fluc=500e-6 ;[micro seconds]
  f_fluc=10e3 ;[kHz]
  ex=exp((-t)*t/tau_fluc^2)
  v_y=convol(del_vy,ex)*sin(2*!pi*f_fluc*t)
  
  ans=0 ;
  for i=0,(N-1) do begin
     ans=ans+del_n0[i]*exp((-1)*((x-x0[i])^2/(2*lamb_x^2)+(y+v_y[i]*(t-t0[i])-y0[i])^2/(2*lamb_y^2)+(t-t0[i])^2/(2*tau_life^2))*cos(2*!pi*(y+v_y[i]*(t-t0[i])-y0[i])/lamb_y))
  endfor

  return, ans
end


