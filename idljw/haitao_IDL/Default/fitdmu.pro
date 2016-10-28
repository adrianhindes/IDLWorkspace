
pro fitdmu, x1,y1,c1,c2,c3,c4,p1,p2,p3,p4

fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 9 05-2-2014.SPE'
read_spe, fil1, lam, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 10 05-2-2014.SPE'
read_spe, fil2, lam, t,d2,texp=texp,str=str,fac=fac & d2=float(d2)
han=hanning(512,512)
cal=d2-d1
cf=fft(cal*han,/center)
cf1=cf
cf2=cf
cf3=cf
cf4=cf
cfd=cf
cf1(findgen(250),*)=0
cf1(findgen(512-270)+270,*)=0
cf1(*,findgen(330))=0
cf1(*,findgen(512-350)+350)=0
cs1=fft(cf1,/inverse,/center)

cf2(findgen(280),*)=0
cf2(findgen(512-300)+300,*)=0
cf2(*,findgen(290))=0
cf2(*,findgen(512-310)+310)=0
cs2=fft(cf2,/inverse,/center)

cf3(findgen(280),*)=0
cf3(findgen(512-300)+300,*)=0
cf3(*,findgen(200))=0
cf3(*,findgen(512-220)+220)=0
cs3=fft(cf3,/inverse,/center)

cf4(findgen(315),*)=0
cf4(findgen(512-335)+335,*)=0
cf4(*,findgen(245))=0
cf4(*,findgen(512-265)+265)=0
cs4=fft(cf4,/inverse,/center)

cfd(findgen(245),*)=0
cfd(findgen(512-265)+265,*)=0
cfd(*,findgen(245))=0
cfd(*,findgen(512-265)+265)=0
csd=fft(cfd,/inverse,/center)

fil3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 13 05-2-2014.SPE'
read_spe, fil3, lam, t,d3,texp=texp,str=str,fac=fac & d3=float(d3)
fil4='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 14 05-2-2014.SPE'
read_spe, fil4, lam, t,d4,texp=texp,str=str,fac=fac & d4=float(d4)
sig=d3-d4
sf=fft(sig*han,/center)
sf1=sf
sf2=sf
sf3=sf
sf4=sf
sfd=sf
sf1(findgen(250),*)=0
sf1(findgen(512-270)+270,*)=0
sf1(*,findgen(330))=0
sf1(*,findgen(512-350)+350)=0
ss1=fft(sf1,/inverse,/center)

sf2(findgen(280),*)=0
sf2(findgen(512-300)+300,*)=0
sf2(*,findgen(290))=0
sf2(*,findgen(512-310)+310)=0
ss2=fft(sf2,/inverse,/center)

sf3(findgen(280),*)=0
sf3(findgen(512-300)+300,*)=0
sf3(*,findgen(200))=0
sf3(*,findgen(512-220)+220)=0
ss3=fft(sf3,/inverse,/center)

sf4(findgen(315),*)=0
sf4(findgen(512-335)+335,*)=0
sf4(*,findgen(245))=0
sf4(*,findgen(512-265)+265)=0
ss4=fft(sf4,/inverse,/center)

sfd(findgen(245),*)=0
sfd(findgen(512-265)+265,*)=0
sfd(*,findgen(245))=0
sfd(*,findgen(512-265)+265)=0
ssd=fft(sfd,/inverse,/center)


cm1=(2*ss1/ssd)/(2*cs1/csd)
cm2=(2*ss2/ssd)/(2*cs2/csd)
cm3=(2*ss3/ssd)/(2*cs3/csd)
cm4=(2*ss4/ssd)/(2*cs4/csd)

stop
temp=make_array(512,512,/float)
flow=make_array(512,512,/float)
cr=make_array(512,512,/float)
hr=make_array(512,512,/float)
for i=100,400 do begin
  for j=100,400 do begin
data1=[cm1(i,j),cm2(i,j),cm3(i,j),cm4(i,j)]
;data1=[dcomplex(c1*cos(p1),c1*sin(p1)),dcomplex(c2*cos(p2),c2*sin(p2)),dcomplex(c3*cos(p3),c3*sin(p3)),dcomplex(c4*cos(p4),c4*sin(p4))]
x=i
y=j
data=data1
save, x,y,data, filename='Measured data.save'
;pp=[1,1,0,1,0]
;index=where(pp eq 1)
;sd=[1.5,50.0,2.0, 0.1]  ;two parameter fitting
sd=[1.5,4.5,1.5,0.10];,0.2]
;xi=[[1.0, 0.0],[0.0, 1.0]]
;xi=[[1.0, 0.0,0.0],ss1
;[0.0, 1.0,0.0],[0.0, 0.0,1.0]] ;3 parameters
xi=[[1.0, 0.0,0.0,0.0],[0.0, 1.0,0.0,0.0],[0.0, 0.0,1.0,0.0],[0.0, 0.0,0.0,1.0]]
;xi=[[1.0, 0.0,0.0,0.0,0.0],[0.0, 1.0,0.0,0.0,0.0],[0.0, 0.0,1.0,0.0,0.0],[0.0, 0.0,0.0,1.0,0.0],[0.0, 0.0,0.0,0.0,1.0]]
ftol=1*1e-4
POWELL, sd, xi, ftol, fmin, 'fitting'
temp(i,j)=sd(0)
flow(i,j)=sd(1)
cr(i,j)=sd(2)
hr(i,j)=sd(3)
;print, 'Temperature:',sd(0)
;print, 'Velocity:',sd(1)
;print, 'Carbon line ratio:',sd(2)
;print, 'H alpha ratio:',sd(3)
;print, 'Hot part h alpha ratio:',sd(4)
;print, 'Minimum value:',fmin

 endfor
endfor
stop
end



