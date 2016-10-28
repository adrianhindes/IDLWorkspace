pro mddmuf, x, y, tem,r,v

ri1=800.0/(800.0+570.0)
ri2=570.0/(800.0+570.0)
line=[[657.805,ri1],$
     [658.288 ,ri2]]

deltb_n=bbo(line(0,0),kapa=kapa)
kapab=kapa
deltl_n=linbo3(line(0,0),kapa=kapa)
kapal=kapa

wh=656.279 ;h alpha wavelength
cl=659.895
cdelt=bbo(cl,kapa=kapa)
ckapab=kapa
cdelt1=linbo3(cl,kapa=kapa)
ckapal=kapa
pc=waveplatel1(cl, 20.0, -!pi/4)*ckapal+displacer1(cl, 5.0, -!pi/4)*ckapab+waveplateb1(cl, 1.0, -!pi/4)*ckapab+(waveplatel1(cl, 7.5, !pi/4)*ckapal+displacer1(cl, 5.0, !pi/4))*ckapab ;calibration line
p1=waveplatel1(line(0,0), 20.0, -!pi/4)*kapal+displacer1(line(0,0), 5.0, -!pi/4)*kapab+waveplateb1(line(0,0), 1.0, -!pi/4)*kapab
p1_1=waveplatel1(line(0,1), 20.0, -!pi/4)*kapal+displacer1(line(0,1), 5.0, -!pi/4)*kapab+waveplateb1(line(0,1), 1.0, -!pi/4)*kapab
p2=(waveplatel1(line(0,0), 7.5, !pi/4)*kapal+displacer1(line(0,0), 5.0, !pi/4))*kapab  ;reference one
p2_1=(waveplatel1(line(0,1), 7.5, !pi/4)*kapal+displacer1(line(0,1), 5.0, !pi/4))*kapab
d1=dcomplex(ri1*cos(p1+p2)+ri2*cos(p1_1+p2_1),ri1*sin(p1+p2)+ri2*sin(p1_1+p2_1))  ;reference one
d2=dcomplex(ri1*cos(p1-p2)+ri2*cos(p1_1-p2_1),ri1*sin(p1-p2)+ri2*sin(p1_1-p2_1))
rcon=exp(-tem/chatem(p1+p2))
conl=rcon*abs(d1)

restore, 'contrast change with ratio.save'
index=where(abs(tem-temp)lt 0.005)
d3=reform(contem(*,index, *))
wave_delay=length*abs(deltl_n)/(line(0,0)*1e-6)*kapal
p3=(p1-p2)/2/!pi
index1=where(abs((p3(x,y))-wave_delay)lt 20.)
d4=reform(d3(index1, *))
index2=where(abs(rt-r)lt 0.03)
cons=d4(index2)

restore, 'Phase compensation for ratio change.save' ;phase compensation caused by ratio change, phase change refer to initail one 
phc=ps_ratio(x,y,index2) ;ratio phase compensation in degrees
;pha=(p1+p2+p1_1+p2_1)/2
d5=dcomplex(cos(pc),sin(pc))
I1=r/(r+1)
I2=1.0/(r+1)
I1=I1(0)
I2=I2(0)
d6=dcomplex(I1*cos(p1+p2)+I2*cos(p1_1+p2_1),I1*sin(p1+p2)+I2*sin(p1_1+p2_1))
phtc=atan(d6/d5,/phase)
;pht=atan((I1-I2)/(I1+I2)*tan(del))+pha  ;phase term of two lines 
;phtc=pht-pc
tp=p1+p2
c=3.0*1e8
phase=v/c*tp(x,y)+phtc(x,y)+phc/180.0*!pi
stop
phase=ph-phc
c=3.0*1e8
tp=p1+p2
flow=phase/180.0*!pi/tp(x,y)*c
r=(ri1-rs)/(ri2+rs)
g=plot(r, reform(ps_ratio(255,255,*))/180.0*!pi/tp(255,255)*c, title='Flow error caused by ratio change', xtitle='Two carbon line ratio I1/I2', ytitle='Flow error caused  by ratio change (m/s)')
g1=plot(r, d4, title='Contrast chagne with ratio at shorter delay',xtitle='Two carbon line ratio I1/I2',ytitle='Contrast')
g2=plot(r, -alog(contem(129,1800,*))*18.0, title='Temperature chagne with ratio at longer delay near Tc',xtitle='Two carbon line ratio I1/I2',ytitle='Temperature(eV)')
stop
end