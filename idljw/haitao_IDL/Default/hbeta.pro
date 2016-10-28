pro hbeta

c=3.0*1e8 
m=1.67*1e-27 
k=1.38*1e-23
hbeta=486.133 
L1=5.0 ;length in mm
L2=15.0 ;length in mm
delta_n=linbo3(hbeta, kapa=kapa)
H_kapa=kapa
Tc_h1=2*m*(hbeta*1e-9)^2*c^2/(L1*1e-3)^2/k/H_kapa^2/delta_n^2/!pi^2/4/11600.0 ;5 mm linbo3
Tc_h2=2*m*(hbeta*1e-9)^2*c^2/(L2*1e-3)^2/k/H_kapa^2/delta_n^2/!pi^2/4/11600.0 ;15 linbo3



fil3_5='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81121.SPE' ;hbeta using 5 mm linbo3 delay 
fil3_6='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81124.SPE'
fil3_7='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81125.SPE'
fil3_8='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81126.SPE'
fil3_9='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81127.SPE'
cal1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\calibration 5 29-10-2013.SPE
cal2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\calibration 6 29-10-2013.SPE
fil=[fil3_5,fil3_6,fil3_7,fil3_8,fil3_9]
read_spe, cal1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
cd=d
read_spe, cal2, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
bd=d
cald=cd-bd
han=hanning(512,128)
fcal=fft(cald*han,/center)
dcf=fcal
fcal(findgen(200),*)=0
fcal(findgen(512-245)+245,*)=0
dcf(findgen(245),*)=0
dcf(findgen(512-270)+270,*)=0
ccal=fft(fcal, /inverse,/center)
dc=fft(dcf, /center,/inverse)
ccon=2*abs(ccal)/abs(dc)


con=make_array(512,128,5,/float)
pha=make_array(512,128,5,/float)
for i=0,4 do begin
read_spe, fil(i), lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
data=reform(d(*,*,20)-d(*,*,2))
fd=fft(data,/center)
bd=fd
fd(findgen(200),*)=0
fd(findgen(512-245)+245,*)=0
bd(findgen(245),*)=0
bd(findgen(512-270)+270,*)=0
c=fft(fd, /center,/inverse)
dc=fft(bd,/center,/inverse)
con(*,*,i)=2*abs(c)/abs(dc)/ccon
pha(*,*,i)=atan(c/ccal,/phase)
endfor
tem=-alog(con(*,*,2))*Tc_h1


fil3_20='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81029.SPE';hbeta using 15 mm delay
fil3_21='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81031.SPE'
fil3_22='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81033.SPE'
fil3_23='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81034.SPE'
fil3_24='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81035.SPE'
cal3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\calibration 3 24-10-2013.SPE'
cal4='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\calibration 4 24-10-2013.SPE'
fil1=[fil3_20,fil3_21,fil3_22,fil3_23,fil3_24]
read_spe, cal3, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
cd1=d
read_spe, cal4, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
bd1=d
cald1=cd1-bd1
han=hanning(512,128)
fcal1=fft(cald1*han,/center)
dcf1=fcal1
fcal1(findgen(200),*)=0
fcal1(findgen(512-245)+245,*)=0
dcf1(findgen(245),*)=0
dcf1(findgen(512-270)+270,*)=0
ccal1=fft(fcal, /inverse,/center)
dc1=fft(dcf1, /center,/inverse)
ccon1=2*abs(ccal1)/abs(dc1)

con1=make_array(512,128,5,/float)
pha1=make_array(512,128,5,/float)
for i=0,4 do begin
read_spe, fil1(i), lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
data1=reform(d(*,*,20)-d(*,*,2))
fd1=fft(data1,/center)
bd1=fd1
fd1(findgen(200),*)=0
fd1(findgen(512-245)+245,*)=0
bd1(findgen(245),*)=0
bd1(findgen(512-270)+270,*)=0
c1=fft(fd, /center,/inverse)
dc1=fft(bd,/center,/inverse)
con1(*,*,i)=2*abs(c1)/abs(dc1)/ccon1
pha1(*,*,i)=atan(c1/ccal1,/phase)
endfor
tem1=-alog(con1(*,*,2))*Tc_h2

; Hbeat line with 5 mm delay from experiments 29-10-2013
fil14='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_30_18.spe'
fil15='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_57_40.spe'
fil16='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_58_41.spe'
fil17='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 16_01_04.spe'
fil18='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 16_02_24.spe'

read_spe, fil16, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
spd=d(*,2,3)-d(*,2,8)
spd=spd/max(spd)
lam=reverse(lam)
scalld, ltmp,dtmp,l0=486.5,fwhm=2.0,opt='a2'
line1=484.78
line2=488.0
line=486.10
r1=interpol(spd,lam,line1)*interpol(dtmp,ltmp,line1)
r2=interpol(spd,lam,line2)*interpol(dtmp,ltmp,line2)
r=interpol(spd,lam,line)*interpol(dtmp,ltmp,line)
ratio1=r1/(r1+r2+r)
ratio2=r2/(r1+r2+r)
ratio=r/(r1+r2+r)

csr=make_array(8000,40,/double)
scon=make_array(8000,40,/double)
dcon=make_array(8000,40,/double)
csp=make_array(8000,40,/dcomplex)
dellam1=(line1-line)/line
dellam2=(line2-line)/line
temp=double(0.01+findgen(40))
delay=double(findgen(8000))
for i=0,39 do begin
  for j=0,7999 do begin
swidth=temp(i)/(1.68*1d8*1.0*8.0*double(alog(2.0)))
  csr(j,i)=sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)
  real_term=ratio*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)+ratio1*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)*cos(2*!pi*dellam1*delay(j))+ratio2*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)*cos(2*!pi*dellam2*delay(j))
  img_term=ratio1*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)*sin(2*!pi*dellam1*delay(j))+ratio2*sqrt(1/swidth/!pi)*exp(-!pi^2*swidth*delay(j)^2)*sin(2*!pi*dellam2*delay(j))
  csp(j,i)=dcomplex(real_term, img_term)
  endfor
  scon(*,i)=csr(*,i)/max(csr(*,i))
  dcon(*,i)=abs(csp(*,i))/max(abs(csp(*,i)))
endfor

p=plot(delay,dcon(*,15), title='Contrast variation with delay when tem eqs 15 ev', xtitle='Delay',ytitle='Contrast',name='Trible lines',color='red',layout=[1,2,2])
p1=plot(delay,scon(*,15), title='Contrast variation with delay when tem eqs 15 ev', xtitle='Delay',ytitle='Contrast',name='Single lines',color='blue',layout=[1,2,2],/current)
l=legend(target=[p,p1],position=[0.8,0.4,0.83,0.43])
p2=plot(lam, spd, title='H beta spectrum',xtitle='Wavelength/nm',ytitle='Normalized intensity',layout=[1,2,1],/current)




stop
end
