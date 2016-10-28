function integ,data,par2,par3
; ************** INTEG.PRO ******************************************
; *     S. Zoletnik  ~1998                                          *
; *     Upgraded for non-equdistant time vectors 24.03.2008 S.Z.    *
; *******************************************************************
; * Integrates the signal as an RC electronic circuit               *.
; * There are two ways to call this function:                       *
; * 1) integ(data,tau)                                              *
; *    data is equidistantly sampled and tau integration time       *
; *    constant is in sample number units                           *
; * 2) integ(data,time,tau)                                         *
; *    time is the time vector for data. In this case tau is in real*
; *    time units.                                                  *
; * Assumes that the signal before the first sample was continously *
; * at the level of the mean of the signal in the first integration *
; * time length.                                                    *
; *******************************************************************

if (n_params() eq 2) then begin
  tau = par2
  if (tau eq 0) then return,data
  n = n_elements(data)
  datai=dblarr(n)
  datai=data
  c=exp(-1./double(tau))
  if (n lt tau) then begin
    datai[0] = mean(data)/(1-c)
  endif else begin
    datai[0]=mean(data[0:tau-1])/(1-c)
  endelse
  for i=long(1),n-1 do begin
    datai(i)=datai(i-1)*c+data(i)
  endfor
  return,datai*(1-c)
endif else begin
  tau = par3
  if (tau eq 0) then return,data
  time = par2
  n = n_elements(data)
  if (n ne n_elements(time)) then begin
    print,'INTEG.PRO: time and data vectors are of different length.'
    return,0
  endif
  dt = time[1:n-1]-time[0:n-2]
  ind = where(abs(dt-dt[0]) gt dt[0]*0.1)
  if (ind[0] lt 0) then begin
    ; The time vector is equidistant
    tau = tau/dt[0]
    datai=data
    c=exp(-1./double(tau))
    if (n lt tau) then begin
      datai[0] = mean(data)/(1-c)
    endif else begin
      datai[0]=mean(data[0:tau-1])/(1-c)
    endelse
    for i=long(1),n-1 do begin
      datai[i]=datai[i-1]*c+data[i]
    endfor
    return,datai*(1-c)
  endif else begin
    ; Time vector is non-equidistant
    datai=dblarr(n)
    c=exp(-dt/double(tau))
    n = n_elements(where((time-time[0]) lt tau))
    datai[0]=mean(data[0:n-1])
    for i=long(1),n_elements(data)-1 do begin
      datai[i]=datai[i-1]*c[i-1]+data[i]*(1-c[i-1])
    endfor
    return,datai
  endelse
endelse


end