function chatem, delay
c=3.0*1e8 
m=1.67*1e-27 
k=1.38*1e-23
tc=2*12*m*c^2/k/(delay^2)/11600.

return, tc
end

pro mddmu, x, y, conl,cons, ph

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
pp1=waveplatel1(line(0,0), 19.5, -!pi/4)*kapal+displacer1(line(0,0), 5.0, -!pi/4)*kapab+waveplateb1(line(0,0), 1.0, -!pi/4)*kapab
p1_1=waveplatel1(line(0,1), 20.0, -!pi/4)*kapal+displacer1(line(0,1), 5.0, -!pi/4)*kapab+waveplateb1(line(0,1), 1.0, -!pi/4)*kapab
pp1_1=waveplatel1(line(0,1), 19.5, -!pi/4)*kapal+displacer1(line(0,1), 5.0, -!pi/4)*kapab+waveplateb1(line(0,0), 1.0, -!pi/4)*kapab
p2=(waveplatel1(line(0,0), 7.5, !pi/4)*kapal+displacer1(line(0,0), 5.0, !pi/4))*kapab  ;reference one
pp2=(waveplatel1(line(0,0), 7.5, !pi/4)*kapal+displacer1(line(0,0), 5.0, !pi/4))*kapab
p2_1=(waveplatel1(line(0,1), 7.5, !pi/4)*kapal+displacer1(line(0,1), 5.0, !pi/4))*kapab
pp2_1=(waveplatel1(line(0,1), 7.5, !pi/4)*kapal+displacer1(line(0,1), 5.0, !pi/4))*kapab
d1=dcomplex(ri1*cos(p1+p2)+ri2*cos(p1_1+p2_1),ri1*sin(p1+p2)+ri2*sin(p1_1+p2_1))  ;reference one
d2=dcomplex(ri1*cos(p1-p2)+ri2*cos(p1_1-p2_1),ri1*sin(p1-p2)+ri2*sin(p1_1-p2_1))

phs=make_array(512,512,100,/float)
cons=make_array(512,512,100,/float)
clr=make_array(100,/float)
cr=findgen(100)*0.0038
for i=0, 99 do begin
I1=ri1+cr(i)
I2=ri2-cr(i)
clr(i)=I1/I2
dd=dcomplex(I1*cos(p1+p2)+I2*cos(p1_1+p2_1),I1*sin(p1+p2)+I2*sin(p1_1+p2_1))  ;two carbon line ratio change effect
phs(*,*,i)=atan(dd/d1, /phase)*180.0/!pi
cons(*,*,i)=abs(dd)-abs(d1)
endfor
save, phs, clr,filename='Phase shift caused by carbon line ratio change.save'
stop
rh=findgen(21)*0.01    ; halpha contamination evalution
hdelt=bbo(wh,kapa=kapa)
hkapab=kapa
hdelt1=linbo3(wh,kapa=kapa)
hkapal=kapa
pal=waveplatel1(wh, 20.0, -!pi/4)*hkapal+displacer1(wh, 5.0, -!pi/4)*hkapab+waveplateb1(wh, 1.0, -!pi/4)*hkapab+(waveplatel1(wh, 7.5, !pi/4)*hkapal+displacer1(wh, 5.0, !pi/4))*hkapab 
ha_ps=make_array(512,512,21)
for j=0,20 do begin
hd=dcomplex(rh(j)*cos(pal)+(1-rh(j))*ri1*cos(p1+p2)+(1-rh(j))*ri2*cos(p1_1+p2_1),rh(j)*sin(pal)+(1-rh(j))*ri1*sin(p1+p2)+(1-rh(j))*ri2*sin(p1_1+p2_1))
ha_ps(*,*,j)=atan(hd/d1,/phase)
endfor
c=3*1e8
tp=p1+p2
g3=plot(rh,-ha_ps(255,255,*)/tp(255,255)*c,title='Flow error caused by H alpha contamination', xtitle='H alpha ratio',ytitle='Flow error caused by H alpha contamination(m/s)')

rcon=conl/abs(d1)
tem=-alog(rcon)*chatem(p1+p2)
restore, 'contrast change with ratio.save'
index=where(abs(tem(x,y)-temp)lt 0.005)
d3=reform(contem(*,index, *))
wave_delay=length*abs(deltl_n)/(line(0,0)*1e-6)*kapal
p3=(p1-p2)/2/!pi
index1=where(abs((p3(x,y))-wave_delay)lt 20.)
d4=reform(d3(index1, *))
index2=where(abs(d4-cons)lt 0.005)
ratio=rt(index2)
restore, 'Phase compensation for ratio change.save' ;phase compensation caused by ratio change, phase change refer to initail one 
phc=ps_ratio(x,y,index2) ;ratio phase compensation in degrees
;pha=(p1+p2+p1_1+p2_1)/2
d5=dcomplex(cos(pc),sin(pc))
I1=ratio/(ratio+1)
I2=1.0/(ratio+1)
I1=I1(0)
I2=I2(0)
d6=dcomplex(I1*cos(p1+p2)+I2*cos(p1_1+p2_1),I1*sin(p1+p2)+I2*sin(p1_1+p2_1))
phtc=atan(d6/d5,/phase)
;pht=atan((I1-I2)/(I1+I2)*tan(del))+pha  ;phase term of two lines 
;phtc=pht-pc
phase=ph-phc/180.0*!pi-phtc(x,y)
c=3.0*1e8
tp=p1+p2
flow=phase/tp(x,y)*c
r=(ri1-rs)/(ri2+rs)
g=plot(r, reform(ps_ratio(255,255,*))/180.0*!pi/tp(255,255)*c, title='Flow error caused by ratio change', xtitle='Two carbon line ratio I1/I2', ytitle='Flow error caused  by ratio change (m/s)')
g1=plot(r, d4, title='Contrast chagne with ratio at shorter delay',xtitle='Two carbon line ratio I1/I2',ytitle='Contrast')
g2=plot(r, -alog(contem(129,1800,*))*18.0, title='Temperature chagne with ratio at longer delay near Tc',xtitle='Two carbon line ratio I1/I2',ytitle='Temperature(eV)')
stop
end
