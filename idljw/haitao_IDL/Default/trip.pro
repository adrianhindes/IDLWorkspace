function trip,x,y
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

rh=findgen(20)*0.01
r=findgen(30)*0.05+1.5
v=-2000+findgen(40)*100  ;assuming flow velocity
c=3.0*1e8
pr=make_array(40,30,20,/double)
pr1=make_array(40,30,20,/double)
pr2=make_array(40,30,20,/double)
pr3=make_array(40,30,20,/double)
for i=0,39 do begin
  ps=v(i)/c*(ph1+ph1_1)
  ps1=v(i)/c*(ph1)
  ps2=v(i)/c*(ph1_1)
  ps3=v(i)/c*(ph1-ph1_1)
  for j=0,29 do begin
    for t=0,19 do begin
  pr(i,j,t)=atan(dcomplex(rh(t)*cos(ph3+ph3_1)+(1-rh(t))*r(j)/(1+r(j))*cos(ph1+ph1_1)+(1-rh(t))/(1+r(j))*cos(ph2+ph2_1),rh(t)*sin(ph3+ph3_1)+(1-rh(t))*r(j)/(1+r(j))*sin(ph1+ph1_1)+(1-rh(t))/(1+r(j))*sin(ph2+ph2_1)),/phase)+ps-atan(dcomplex(cos(ph4+ph4_1),sin(ph4+ph4_1)),/phase)
  pr1(i,j,t)=atan(dcomplex(rh(t)*cos(ph3)+(1-rh(t))*r(j)/(1+r(j))*cos(ph1)+(1-rh(t))/(1+r(j))*cos(ph2),rh(t)*sin(ph3)+(1-rh(t))*r(j)/(1+r(j))*sin(ph1)+(1-rh(t))/(1+r(j))*sin(ph2)),/phase)+ps1-atan(dcomplex(cos(ph4),sin(ph4)),/phase)
  pr2(i,j,t)=atan(dcomplex(rh(t)*cos(ph3_1)+(1-rh(t))*r(j)/(1+r(j))*cos(ph1_1)+(1-rh(t))/(1+r(j))*cos(ph2_1),rh(t)*sin(ph3_1)+(1-rh(t))*r(j)/(1+r(j))*sin(ph1_1)+(1-rh(t))/(1+r(j))*sin(ph2_1)),/phase)+ps2-atan(dcomplex(cos(ph4_1),sin(ph4_1)),/phase) 
  pr3(i,j,t)=atan(dcomplex(rh(t)*cos(ph3-ph3_1)+(1-rh(t))*r(j)/(1+r(j))*cos(ph1-ph1_1)+(1-rh(t))/(1+r(j))*cos(ph2-ph2_1),rh(t)*sin(ph3-ph3_1)+(1-rh(t))*r(j)/(1+r(j))*sin(ph1-ph1_1)+(1-rh(t))/(1+r(j))*sin(ph2-ph2_1)),/phase)+ps3-atan(dcomplex(cos(ph4-ph4_1),sin(ph4-ph4_1)),/phase)
      endfor
      endfor
      endfor
  p1=ph1+ph1_1
  p2=ph1
  p3=ph1_1
  p4=ph1-ph1_1
  phase={pplus:pr,plong:pr1,pshort:pr2,pmins:pr3,ppha:p1,lpha:p2,spha:p3,mpha:p4}    
      
return, phase    
 stop
 end
  
