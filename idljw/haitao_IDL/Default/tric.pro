function tric,delayc
lc1=657.805
lc2=658.288
lh=656.279
;delayc=5300
;delayc1=delayc*abs(bbo(lc2)/bbo(lc1))*lc1/lc2
;delayh=delayc*abs(bbo(lh)/bbo(lc1))*lc1/lh
delayc1=delayc
delayh=delayc
temp=findgen(40)
rh=findgen(20)*0.01*0.9  ;90% hot part?
r=findgen(30)*0.05+1.5
;rc1=findgen(30)*0.01+0.4
;spf=make_array(,40,30,20,/float)
tcon0=make_array(40,30,20,/float)
;spfi=make_array(40,30,20,/float)
;spfi0=make_array(40,30,20,/float)
tcon=make_array(40,30,20,/float)
;scon=make_array(40,30,20,/float)
dellam=(lc2-lc1)/lc1
dellam1=(lh-lc1)/lc1
for t=0,39 do begin
for i=0,19 do begin
  for j=0,29  do begin
  swidthh=temp(t)/(1.68*1d8*1.0*8.0*double(alog(2.0)))
  swidthc=temp(t)/(1.68*1d8*12.0*8.0*double(alog(2.0)))
  swidthh0=0.01/(1.68*1d8*1.0*8.0*double(alog(2.0)))
  swidthc0=0.01/(1.68*1d8*12.0*8.0*double(alog(2.0)))
  rp=rh(i)*exp(-!pi^2*swidthh*delayh^2)*cos(2*!pi*dellam1*delayh)+(1-rh(i))*r(j)/(1+r(j))*exp(-!pi^2*swidthc*delayc^2)+(1-rh(i))/(1+r(j))*exp(-!pi^2*swidthc*delayc1^2)*cos(2*!pi*dellam*delayc1)
  ip=rh(i)*exp(-!pi^2*swidthh*delayh^2)*sin(2*!pi*dellam1*delayh)+(1-rh(i))/(1+r(j))*exp(-!pi^2*swidthc*delayc1^2)*sin(2*!pi*dellam*delayc1)
  tcon(t,j,i)=abs(dcomplex(rp,ip))
  ;tcon(t,j,i)=rh(i)*exp(-!pi^2*swidthh*delayh^2)+(1-rh(i))*r(j)/(1+r(j))*exp(-!pi^2*swidthc*delayc^2)+(1-rh(i))/(1+r(j))*exp(-!pi^2*swidthc*delayc1^2)   ;wiener-kinchine theorem, normalization after fourier transform
  ;tcon0(t,j,i)=rh(i)*exp(-!pi^2*swidthh0*delayh^2)+(1-rh(i))*r(j)/(1+r(j))*exp(-!pi^2*swidthc0*delayc^2)+(1-rh(i))/(1+r(j))*exp(-!pi^2*swidthc0*delayc1^2)
  ;tcon(t,j,i)=tcon(t,j,i)/tcon0(t,j,i)
  ;spf(j,i)=fra*1/(!pi*swidth^2*sqrt(2))*exp(-!pi^2*swidth*delay(j)^2)+(1.0-fra)*1/(!pi*nswidth^2*sqrt(2))*exp(-!pi^2*nswidth*delay(j)^2)
  ;spfi(t,j,i)=r(j)/(1+r(j))*exp(-!pi^2*swidthc*delayc^2)+1.0/(1+r(j))*exp(-!pi^2*swidthc*delayc1^2)
  ;spfi0(t,j,i)=r(j)/(1+r(j))*exp(-!pi^2*swidthc0*delayc^2)+1.0/(1+r(j))*exp(-!pi^2*swidthc0*delayc1^2)
  ;spfi(t,j,i)=spfi(j,i)/spfi0(j,i)
  endfor
  ;dcon(*,i)=spf(*,i)/max(spf(*,i))
  ;scon(*,i)=spfi(*,i)/max(spfi(*,i))
  ;sp(*, i)=fra*exp(-norlamda^2/2/swidth)+(1-fra)*exp(-norlamda^2/2/nswidth)
endfor
endfor
return, tcon
stop
end