pro csco
;cs lamp coherence modeling
r1=0.8
r2=0.2
line=[[658.60216, r1],[658.65096,r2]]
dellam=double((line(0,1)-line(0,0))/line(0,0))
temp=double(0.01+findgen(40))
delay=double(findgen(8000))
csr=make_array(8000,40,/double)
scon=make_array(8000,40,/double)
dcon=make_array(8000,40,/double)
csp=make_array(8000,40,/dcomplex)
for i=0,39 do begin
  for j=0,7999 do begin
  swidth=temp(i)/(1.68*1d8*132.9*8.0*double(alog(2.0)))
  csr(j,i)=sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)
  csp(j,i)=dcomplex(r1*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)+r2*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)*cos(2*!pi*dellam*delay(j)),r2*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)*sin(2*!pi*dellam*delay(j)))
  endfor
  scon(*,i)=csr(*,i)/max(csr(*,i))
   dcon(*,i)=csp(*,i)/max(csp(*,i))
endfor

phase=atan(csp,/phase)
stop
end
