function gen_deltan1
  lamb_x=1e-2
  lamb_y=2e-2
  n_0=1
  x_0=3e-2
  y_0=1e-2
  v_y=750
  len_x=25e-2 ;m
  len_y=20e-2
  len_t=500e-6 ;second
  divide_x=0.5e-3
  divide_y=0.5e-2
  divide_t=0.5e-6
  size_x=len_x/divide_x+1
  size_y=len_y/divide_y+1
  size_t=len_t/divide_t+1
  del_n=fltarr(size_x,size_y,size_t)
  xaxis = findgen(size_x)*divide_x
  yaxis = findgen(size_y)*divide_y
  taxis = findgen(size_t)*divide_t
 ;------------------------------------------------------------- Vriable setting

  for i=0L, size_x-1 do begin
    for j=0L, size_y-1 do begin
      del_n[i, j, *] = n_0 * exp(-(xaxis[i]-x_0)^2.0/(2.0*lamb_x^2.0)) * $
                             exp(-(yaxis[j]-(v_y*taxis+y_0))^2.0/(2.0*lamb_y^2.0)) * $
                             cos(2.0*!pi*(yaxis[j]-(v_y*taxis+y_0))/lamb_y)
    endfor
  endfor

  result = {deln:del_n, x:xaxis, y:yaxis, t:taxis}
  return, result

;  for i=0,size_x-1 do begin
;     for j=0,size_y-1 do begin
;        for k=0,size_t-1 do begin ; (i,j,k)
;           del_n[i,j,k]=n_0*exp(-(i*divide_x-x_0)^2/(2*lamb_x^2)-(j*divide_y-(v_y*k*divide_t+y_0))^2/(2*lamb_y^2))
;        endfor
;     endfor
;  endfor


;  return,del_n
end
