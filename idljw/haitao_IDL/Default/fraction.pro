function fraction,fra, spf=spf
line=486.133
l1=5.0
l2=15.0
delay1=abs(l1*1d-3*linbo3(line)/(line*1d-9))
delay2=abs(l2*1d-3*linbo3(line)/(line*1d-9))
temp=double(0.01+findgen(40))
delay=double(findgen(300))*20
lam=484.0+findgen(1000)*0.005
nswidth=temp(0)/(1.68*1d8*1.0*8.0*double(alog(2.0)))
sp=make_array(1000,40,/float)
norlamda=(lam-line)/line
spf=make_array(300,40,20,/dcomplex)
spfi=make_array(300,40,20,/double)
dcon=make_array(300,40,20,/double)
scon=make_array(300,40,20,/double)
dellam=findgen(20)*4.861*1e-4-4.861*1e-3
for i=0,39 do begin
  for j=0,299  do begin
    for k=0,19 do begin
  swidth=temp(i)/(1.68*1d8*1.0*8.0*double(alog(2.0)))
  spf(j,i,k)=dcomplex(fra*exp(-!pi^2*swidth*delay(j)^2)+(1.0-fra)*exp(-!pi^2*nswidth*delay(j)^2)*cos(2*!pi*dellam(k)*delay(j)),(1.0-fra)*exp(-!pi^2*nswidth*delay(j)^2)*sin(2*!pi*dellam(k)*delay(j))) ;wiener-kinchine theorem, normalization after fourier transform
  ;spf(j,i)=fra*1/(!pi*swidth^2*sqrt(2))*exp(-!pi^2*swidth*delay(j)^2)+(1.0-fra)*1/(!pi*nswidth^2*sqrt(2))*exp(-!pi^2*nswidth*delay(j)^2)
  ;spfi(j,i,k)=sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)
   dcon(j,i,k)=abs(spf(j,i,k))
  endfor
  ;dcon(*,i,k)=abs(spf(*,i)
  ;scon(*,i,k)=spfi(*,i)/max(spfi(*,i))
  ;sp(*, i,k)=fra*exp(-norlamda^2/2/swidth)+(1-fra)*exp(-norlamda^2/2/nswidth)
endfor
endfor
return, dcon
end 
