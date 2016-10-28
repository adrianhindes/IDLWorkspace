function fitting, m,con=con,phase=phase
;temp=m(0)
;vel=m(1)
;r=m(2)
;rh=m(3)
;rhi=m(4)   ;five parameters fitting

temp=m(0)
vel=m(1)
r=m(2)
rh=m(3)
rhi=m(4)  ;keep h alpha ratio constant and hot part constant

;temp=m(0)
;vel=m(1)
;r=m(2)
;rh=m(3)
;rhi=0.5  ;keep h alpha ratio vataible but hot part constant


;temp=findgen(40)
;rh=findgen(20)*0.01
;rhi=findgen(11)*0.1
;r=findgen(30)*0.05+1.5
;v=-2000+findgen(40)*100 
restore, 'Measured data.save'
c=3.0*1e8
f=85 ;focal length
sensor=16.0*1e-6 ;sensor size in m
ang=!pi/4
apha=atan(sqrt(((x-255)*sensor)^2+((y-255)*sensor)^2),f*1e-3)
delw=atan((x-255)*sensor, (y-255)*sensor)+ang+!pi/2
delw1=atan((x-255)*sensor, (y-255)*sensor)+ang+!pi/2+!pi/2
lc1=657.805
lc2=658.288
lh=656.279
cl=659.895
wbl=20.0
wl=3.3
dl=3.0

ph1=veiras_eqb(lc1,wbl, apha,delw,0.)*kbbo(lc1)-veiras_eql(lc1,wl, apha,delw1,0.)*klinbo3(lc1)+veiras_eqb(lc1,dl, apha,delw,!pi/4)*kbbo(lc1)
ph2=veiras_eqb(lc2,wbl, apha,delw,0.)*kbbo(lc2)-veiras_eql(lc2,wl, apha,delw1,0.)*klinbo3(lc2)+veiras_eqb(lc1,dl, apha,delw,!pi/4)*kbbo(lc2)
ph3=veiras_eqb(lh,wbl, apha,delw,0.)*kbbo(lh)-veiras_eql(lh,wl, apha,delw1,0.)*klinbo3(lh)+veiras_eqb(lh,dl, apha,delw,!pi/4)*kbbo(lh)
ph4=veiras_eqb(cl,wbl, apha,delw,0.)*kbbo(cl)-veiras_eql(cl,wl, apha,delw1,0.)*klinbo3(cl)+veiras_eqb(cl,dl, apha,delw,!pi/4)*kbbo(cl)

wbl1=8.0
wl1=1.3
dl1=3.0
ang1=3*!pi/4
delw_1=atan((x-255)*sensor, (y-255)*sensor)+ang+!pi/2
delw1_1=atan((x-255)*sensor, (y-255)*sensor)+ang+!pi/2+!pi/2
ph1_1=veiras_eqb(lc1,wbl1, apha,delw_1,0)*kbbo(lc1)-veiras_eql(lc1,wl1, apha,delw1_1,0)*klinbo3(lc1)+veiras_eqb(lc1,dl1, apha,delw_1,!pi/4)*kbbo(lc1)
ph2_1=veiras_eqb(lc2,wbl1, apha,delw_1,0)*kbbo(lc2)-veiras_eql(lc2,wl1, apha,delw1_1,0)*klinbo3(lc2)+veiras_eqb(lc1,dl1, apha,delw_1,!pi/4)*kbbo(lc2)
ph3_1=veiras_eqb(lh,wbl1, apha,delw_1,0)*kbbo(lh)-veiras_eql(lh,wl1, apha,delw1_1,0)*klinbo3(lh)+veiras_eqb(lh,dl1, apha,delw_1,!pi/4)*kbbo(lh)
ph4_1=veiras_eqb(cl,wbl1, apha,delw_1,0)*kbbo(cl)-veiras_eql(cl,wl1, apha,delw1_1,0)*klinbo3(cl)+veiras_eqb(cl,dl1, apha,delw_1,!pi/4)*kbbo(cl)


ps=vel/c*(ph1+ph1_1)*1000.0
ps1=vel/c*(ph1)*1000.0
ps2=vel/c*(ph1_1)*1000.0
ps3=vel/c*(ph1-ph1_1)*1000.0   ;using velocity in units of 1 km /s

;de1=atan(dcomplex(rh*cos(ph3+ph3_1)+(1-rh)*r/(1+r)*cos(ph1+ph1_1)+(1-rh)/(1+r)*cos(ph2+ph2_1),rh*sin(ph3+ph3_1)+(1-rh)*r/(1+r)*sin(ph1+ph1_1)+(1-rh)/(1+r)*sin(ph2+ph2_1)),/phase)+ps-atan(dcomplex(cos(ph4+ph4_1),sin(ph4+ph4_1)),/phase)
;de2=atan(dcomplex(rh*cos(ph3)+(1-rh)*r/(1+r)*cos(ph1)+(1-rh)/(1+r)*cos(ph2),rh*sin(ph3)+(1-rh)*r/(1+r)*sin(ph1)+(1-rh)/(1+r)*sin(ph2)),/phase)+ps1-atan(dcomplex(cos(ph4),sin(ph4)),/phase)
;de3=atan(dcomplex(rh*cos(ph3_1)+(1-rh)*r/(1+r)*cos(ph1_1)+(1-rh)/(1+r)*cos(ph2_1),rh*sin(ph3_1)+(1-rh)*r/(1+r)*sin(ph1_1)+(1-rh)/(1+r)*sin(ph2_1)),/phase)+ps2-atan(dcomplex(cos(ph4_1),sin(ph4_1)),/phase)
;de4=atan(dcomplex(rh*cos(ph3-ph3_1)+(1-rh)*r/(1+r)*cos(ph1-ph1_1)+(1-rh)/(1+r)*cos(ph2-ph2_1),rh*sin(ph3-ph3_1)+(1-rh)*r/(1+r)*sin(ph1-ph1_1)+(1-rh)/(1+r)*sin(ph2-ph2_1)),/phase)+ps3-atan(dcomplex(cos(ph4-ph4_1),sin(ph4-ph4_1)),/phase)

delay1=(ph1+ph1_1)/2/!pi
delay2=(ph1)/2/!pi
delay3=(ph1_1)/2/!pi
delay4=(ph1-ph1_1)/2/!pi
dellam=(lc2-lc1)/lc1
dellam1=(lh-lc1)/lc1
swidthh=temp*10/(1.68*1d8*1.0*8.0*double(alog(2.0))) ; use temperature in units of 10 eV
swidth0=0.01/(1.68*1d8*1.0*8.0*double(alog(2.0)))
swidthc=temp*10/(1.68*1d8*12.0*8.0*double(alog(2.0)))
rp1=(1-rhi)*rh*exp(-!pi^2*swidth0*delay1^2)*cos(2*!pi*dellam1*delay1)+rhi*rh*exp(-!pi^2*swidthh*delay1^2)*cos(2*!pi*dellam1*delay1)+(1-rh)*r/(1+r)*exp(-!pi^2*swidthc*delay1^2)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay1^2)*cos(2*!pi*dellam*delay1)
ip1=(1-rhi)*rh*exp(-!pi^2*swidth0*delay1^2)*sin(2*!pi*dellam1*delay1)+rhi*rh*exp(-!pi^2*swidthh*delay1^2)*sin(2*!pi*dellam1*delay1)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay1^2)*sin(2*!pi*dellam*delay1)
con1=abs(dcomplex(rp1,ip1))
phase1=atan(dcomplex(rp1,ip1),/phase)+ps-atan(dcomplex(cos(ph4+ph4_1),sin(ph4+ph4_1)),/phase)

rp2=(1-rhi)*rh*exp(-!pi^2*swidth0*delay2^2)*cos(2*!pi*dellam1*delay2)+rhi*rh*exp(-!pi^2*swidthh*delay2^2)*cos(2*!pi*dellam1*delay2)+(1-rh)*r/(1+r)*exp(-!pi^2*swidthc*delay2^2)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay2^2)*cos(2*!pi*dellam*delay2)
ip2=(1-rhi)*rh*exp(-!pi^2*swidth0*delay2^2)*sin(2*!pi*dellam1*delay2)+rhi*rh*exp(-!pi^2*swidthh*delay2^2)*sin(2*!pi*dellam1*delay2)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay2^2)*sin(2*!pi*dellam*delay2)
con2=abs(dcomplex(rp2,ip2))
phase2=atan(dcomplex(rp2,ip2),/phase)+ps1-atan(dcomplex(cos(ph4),sin(ph4)),/phase)

  
rp3=(1-rhi)*rh*exp(-!pi^2*swidth0*delay3^2)*cos(2*!pi*dellam1*delay3)+rhi*rh*exp(-!pi^2*swidthh*delay3^2)*cos(2*!pi*dellam1*delay3)+(1-rh)*r/(1+r)*exp(-!pi^2*swidthc*delay3^2)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay3^2)*cos(2*!pi*dellam*delay3)
ip3=(1-rhi)*rh*exp(-!pi^2*swidth0*delay3^2)*sin(2*!pi*dellam1*delay3)+rhi*rh*exp(-!pi^2*swidthh*delay3^2)*sin(2*!pi*dellam1*delay3)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay3^2)*sin(2*!pi*dellam*delay3)
con3=abs(dcomplex(rp3,ip3))
phase3=atan(dcomplex(rp3,ip3),/phase)+ps2-atan(dcomplex(cos(ph4_1),sin(ph4_1)),/phase)  

rp4=(1-rhi)*rh*exp(-!pi^2*swidth0*delay4^2)*cos(2*!pi*dellam1*delay4)+rhi*rh*exp(-!pi^2*swidthh*delay4^2)*cos(2*!pi*dellam1*delay4)+(1-rh)*r/(1+r)*exp(-!pi^2*swidthc*delay4^2)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay4^2)*cos(2*!pi*dellam*delay4)
ip4=(1-rhi)*rh*exp(-!pi^2*swidth0*delay4^2)*sin(2*!pi*dellam1*delay4)+rhi*rh*exp(-!pi^2*swidthh*delay4^2)*sin(2*!pi*dellam1*delay4)+(1-rh)/(1+r)*exp(-!pi^2*swidthc*delay4^2)*sin(2*!pi*dellam*delay4)
con4=abs(dcomplex(rp4,ip4))
phase4=atan(dcomplex(rp4,ip4),/phase)+ps3-atan(dcomplex(cos(ph4-ph4_1),sin(ph4-ph4_1)),/phase)

con=[con1, con2,con3,con4]
phase=[phase1,phase2,phase3,phase4]
fitdata=[dcomplex(con1*cos(phase1),con1*sin(phase1)),dcomplex(con2*cos(phase2),con2*sin(phase2)),dcomplex(con3*cos(phase3),con3*sin(phase3)),dcomplex(con4*cos(phase4),con4*sin(phase4))]
diff=(fitdata-data)
msq=abs(diff)
msq=total(msq)

return, msq
stop
end

  