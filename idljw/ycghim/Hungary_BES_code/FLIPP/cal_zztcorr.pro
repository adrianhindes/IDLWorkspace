pro cal_zztcorr,k,ks,calshot,p,ps,channels=channels,data_source=data_source,calfac=cal
; multiplies the cross-correlation function and its errors with channel 
; calibration factors.

default,channels,findgen(24)+1

cal=getcal(calshot,data_source=data_source)
nz=(size(k))(1)

for i=0,nz-1 do begin
  k(i,*,*)=k(i,*,*)*cal(channels(i)-1)  
  ks(i,*,*)=ks(i,*,*)*cal(channels(i)-1)  
  k(*,i,*)=k(*,i,*)*cal(channels(i)-1)
  ks(*,i,*)=ks(*,i,*)*cal(channels(i)-1)
  if (keyword_set(p)) then p(i,*)=p(i,*)*cal(channels(i)-1)
  if (keyword_set(ps)) then ps(i,*)=ps(i,*)*cal(channels(i)-1)
endfor
end  
