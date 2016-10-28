pro argonmodel
;agdon line 488nm coherence modeling
wl=488.0 ;wavelength 488 nm
temp=double(0.01+findgen(40))
delay=double(findgen(20000))*2.0

con=make_array(20000,40,/double)
csr=make_array(20000,40,/double)
for i=0,39 do begin
  for j=0,19999 do begin
  swidth=temp(i)/(1.68*1d8*18.0*8.0*double(alog(2.0)))
  csr(j,i)=sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)
  endfor
  con(*,i)=csr(*,i)/max(csr(*,i))
endfor
deltnb=bbo(wl,kapa=kapa)
kapab=kapa
deltnl=linbo3(wl,kapa=kapa)
kapal=kapa
db=80.0
dl=10.0
wave=(waveplateb(wl,80.0,0.0)+displacer(wl,3.0,0.0))*kapab/2.0/!pi ;group wave delay generated by 80mm bbo and 10.0 mm linbo3
delay1=delay(round(wave/2.0))



stop
end
