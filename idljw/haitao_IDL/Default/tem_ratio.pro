function tem_ratio, temp, delay,cons
cline=[657.805,658.288]
dellam=double((cline(1)-cline(0)))/cline(0)
swidth=temp/(1.68*1d8*12.0*8.0*double(alog(2.0)))
r1=findgen(300)*0.1/(1+findgen(300)*0.1)
r2=1.0/(1+findgen(300)*0.1)
con=make_array(300)
for i=0,299 do begin
con(i)=abs(dcomplex(r1(i)*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay^2)+r2(i)*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay^2)*cos(2*!pi*dellam*delay),r2(i)*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay^2)*sin(2*!pi*dellam*delay)))
endfor
con=con/max(con)
index=where(abs(cons-con)lt 0.01)
d=r1/r2
ratio=d(index)
return, ratio
stop
end