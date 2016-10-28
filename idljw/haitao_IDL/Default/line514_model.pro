pro line514_model, wl, wr, dl,dr

line=[[513.294, 0.1417],$
      [513.328 ,0.1417],$
      [513.726 ,0.0493],$
      [513.917 ,0.0495],$
      [514.349 ,0.1359],$
      [514.516 ,0.3275],$
      [515.109 ,0.1544]]  ;theoretical data from clive

;wavelength correction
fil1='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\514 filter.spe' ;measured filter function
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 14_59_52.spe'; line profile distribution from plasma
read_spe, fil1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
read_spe, fil2, lam1, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
d1=reverse(d1,1)
d=d/max(d)
im=max(d, index)
cw=lam(index) ; measured filter center wavelength approximation
cr=make_array(10,7,/float)
d3=make_array(10,/float)
channel=findgen(10)+1
for i=0,9 do begin
  d2=d1(*,i,3)-mean(d1(0:400,i,3))
  d3(i)=total(d2)
  cr1=total(d2(435:465))
  cr2=total(d2(435:465))
  cr3=total(d2(465:495))
  cr4=total(d2(495:525))
  cr5=total(d2(525:555))
  cr6=total(d2(555:585))
  cr7=total(d2(600:630))
  cr(i,0)=cr1/(cr1+cr2+cr3+cr4+cr5+cr6+cr7)
  cr(i,1)=cr2/(cr1+cr2+cr3+cr4+cr5+cr6+cr7)
  cr(i,2)=cr3/(cr1+cr2+cr3+cr4+cr5+cr6+cr7)
  cr(i,3)=cr4/(cr1+cr2+cr3+cr4+cr5+cr6+cr7)
  cr(i,4)=cr5/(cr1+cr2+cr3+cr4+cr5+cr6+cr7)
  cr(i,5)=cr6/(cr1+cr2+cr3+cr4+cr5+cr6+cr7)
  cr(i,6)=cr7/(cr1+cr2+cr3+cr4+cr5+cr6+cr7)
  endfor
;p=plot(channel, cr(*,0),title='Relative intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,0.5],ytitle='Relative intensity',name='line 513.294 nm',symbol=0)
;p1=plot(channel, cr(*,1)+0.003,title='Relative intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,0.5],ytitle='Relative intensity',name='line 513.328 nm',symbol=1,/current)
;p2=plot(channel, cr(*,2),title='Relative intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,0.5],ytitle='Relative intensity',name='line 513.726 nm',symbol=2,/current)
;p3=plot(channel, cr(*,3),title='Relative intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,0.5],ytitle='Relative intensity',name='line 513.917 nm',symbol='o',/current)
;p4=plot(channel, cr(*,4),title='Relative intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,0.5],ytitle='Relative intensity',name='line 514.349 nm',symbol=4,/current)
;p5=plot(channel, cr(*,5),title='Relative intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,0.5],ytitle='Relative intensity',name='line 513.516 nm',symbol=5,/current)
;p6=plot(channel, cr(*,6),title='Relative intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,0.5],ytitle='Relative intensity',name='line 515.109 nm',symbol=6,/current)
;l=legend(target=[p,p1,p2,p3,p4,p5,p6],position=[0.90,0.85,0.95,0.9],/AUTO_TEXT_COLOR)
d3=d3/max(d3)
;p6=plot(channel, d3,title='Relative total intensity of 514 lines across channels',xtitle='Channel NO.',yrange=[0,1],ytitle='Relative intensity')


;d2=d1(*,1,3)
;d2=d2-mean(d2(0:400))
;d3=peaks(d2,3.5)
;d4=d2(d3)
;d4=[d4(0),d4(0),d4(1),d4(2),d4(3),d4(5),d4(6)]
;cr=d4/total(d4)



;scalld, ltmp,dtmp,l0=658,fwhm=2,opt='a3'  
  
;off-axis incidence of filter

c1=513.294  ;carbonII line wavelength from boyd's spectrum
c2=513.328
c3=513.726
c4=513.917
c5=514.349
c6=514.516
c7=515.109
rw=532.0
rw1=514.5
ew3=514.013
wc=[c1,c2,c3,c4,c5,c6,c7,rw,rw1,ew3]
;save, cr,wc,filename='Carbon 514 line ratios.save'
cr=line(1,*)
ss=16.0*1e-6 ;sensor size in m
f=50.0*1e-3  ;focal length in m
nf=2.05 ;refrective index of filter material
ia=make_array(512,128,/float) ;inceidence angle
del=make_array(512,128,/float)
ws=make_array(512,128,/float) ;shifted center wavelength
sc1r=make_array(512,128,/float) ;spatial line ratio of carbon line one across pixels
sc2r=make_array(512,128,/float) ;spatial line ratio of carbon line two across pixels
sc3r=make_array(512,128,/float)
sc4r=make_array(512,128,/float)
sc5r=make_array(512,128,/float)
sc6r=make_array(512,128,/float)
sc7r=make_array(512,128,/float)
lam_eff=make_array(512,128,/float) ;effective lam for pixels
phase=make_array(512,128,10,/float) ;phase difference 
intensity=make_array(512,128,/complex)
for i=0,511 do begin
  for j=0,127 do begin
    ia(i,j)=atan(sqrt(((i-255)*ss)^2+((j-63)*ss*4)^2),f) ;incidence angle
    del(i,j)=atan((i-255)*ss, (j-63)*4*ss)
    ws(i,j)=cw*(1-sqrt(1-(sin(ia(i,j))/nf)^2))
    sc1r1=interpol(d,lam-ws(i,j),c1,/QUADRATIC)*line(1,0)
    sc2r1=interpol(d,lam-ws(i,j),c2,/QUADRATIC)*line(1,1)
    sc3r1=interpol(d,lam-ws(i,j),c3,/QUADRATIC)*line(1,2)
    sc4r1=interpol(d,lam-ws(i,j),c4,/QUADRATIC)*line(1,3)
    sc5r1=interpol(d,lam-ws(i,j),c5,/QUADRATIC)*line(1,4)
    sc6r1=interpol(d,lam-ws(i,j),c6,/QUADRATIC)*line(1,5)
    sc7r1=interpol(d,lam-ws(i,j),c7,/QUADRATIC)*line(1,6)
    sc1r(i,j)=sc1r1/(sc1r1+sc2r1+sc3r1+sc4r1+sc5r1+sc6r1+sc7r1)
    sc2r(i,j)=sc2r1/(sc1r1+sc2r1+sc3r1+sc4r1+sc5r1+sc6r1+sc7r1)
    sc3r(i,j)=sc3r1/(sc1r1+sc2r1+sc3r1+sc4r1+sc5r1+sc6r1+sc7r1)
    sc4r(i,j)=sc4r1/(sc1r1+sc2r1+sc3r1+sc4r1+sc5r1+sc6r1+sc7r1)
    sc5r(i,j)=sc5r1/(sc1r1+sc2r1+sc3r1+sc4r1+sc5r1+sc6r1+sc7r1)
    sc6r(i,j)=sc6r1/(sc1r1+sc2r1+sc3r1+sc4r1+sc5r1+sc6r1+sc7r1)
    sc7r(i,j)=sc7r1/(sc1r1+sc2r1+sc3r1+sc4r1+sc5r1+sc6r1+sc7r1)
    ;lam_eff(i,j)=whr*shr(i,j)+c1*sc1r(i,j)+c2*sc2r(i,j)
for m=0,9 do begin
    lam_eff(i,j)=wc(m)
    wphase=veiras_eql(lam_eff(i,j),wl,ia(i,j),del(i,j)+wr+!pi/2,0)+veiras_eqb(lam_eff(i,j), 2.2,ia(i,j),del(i,j)+wr+!pi/2,0)+veiras_eqb(lam_eff(i,j), 1,ia(i,j),del(i,j)+wr,0)
    dphase=veiras_eqb(lam_eff(i,j), dl,ia(i,j),del(i,j)+dr+!pi/2,!pi/4)-veiras_eqb(lam_eff(i,j),dl,ia(i,j),del(i,j)+dr+!pi,!pi/4)
    phase(i,j,m)=wphase+dphase
endfor
   cs=sc1r(i,j)*cos(phase(i,j,0))+sc2r(i,j)*cos(phase(i,j,1))+sc3r(i,j)*cos(phase(i,j,2))+sc4r(i,j)*cos(phase(i,j,3))+sc5r(i,j)*cos(phase(i,j,4))+sc6r(i,j)*cos(phase(i,j,5))+sc7r(i,j)*cos(phase(i,j,6))
   si=sc1r(i,j)*sin(phase(i,j,0))+sc2r(i,j)*sin(phase(i,j,1))+sc3r(i,j)*sin(phase(i,j,2))+sc4r(i,j)*sin(phase(i,j,3))+sc5r(i,j)*sin(phase(i,j,4))+sc6r(i,j)*sin(phase(i,j,5))+sc7r(i,j)*sin(phase(i,j,6))
  intensity(i,j)=dcomplex(cs,si)
   endfor 
 endfor
 oc_514=abs(intensity) ;contrast offset for 514 lines with 13 mm delay
 save, oc_514, filename='contrast offset for 514 lines with 13 mm delay.save'
 
 stop
 x=findgen(5120)*0.1
 y=findgen(1280)*0.1
 g=image(rebin(real_part(intensity),5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling image of carbon 514 lines ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c=colorbar(target=g, orientation=1)
 
 
;phase demodulation
;f=fft(reverse(intensity,2),/center)
;f(0:200,*)=0
;f(240:*,*)=0
;f1=fft(f, /inverse, /center)
f1=intensity

;f2=fft(reverse(cos(phase(*,*,7)),2),/center) ;phase of line 532 nm
;f2(0:200,*)=0
;f2(240:*,*)=0
;f3=fft(f2, /inverse, /center)
f2=phase(*,*,7)
f3=dcomplex(cos(f2),sin(f2))

f4=atan(f3/f1, /phase)
jumpimg,f4
g1=image(rebin(f4,5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling phase shift between lines and 532 nm line ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c1=colorbar(target=g1, orientation=1)
;f5=fft(reverse(cos(phase(*,*,8)),2),/center) ;phase of line 514.0 nm
;f5(0:200,*)=0
;f5(240:*,*)=0
;f6=fft(f5, /inverse, /center)
f5=phase(*,*,8)
f6=dcomplex(cos(f5),sin(f5))
f7=atan(f6/f1, /phase)
f8=atan(f3/f6,/phase)
jumpimg,f8
f9=phase(*,*,9)
f10=dcomplex(cos(f9),sin(f9))
f11=atan(f1/f10,/phase)

g2=image(rebin(f7,5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling phase shift between lines and 514.5 nm line ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c2=colorbar(target=g2, orientation=1)
g3=image(rebin(f11,5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling phase shift between lines and effective wavelength ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c3=colorbar(target=g3, orientation=1)
g.save, 'Modeling image of carbon 514 lines.png',resolution=100
g1.save,'Modeling phase shift lines and 532 nm line.png ',resolution=100
g2.save,'Modeling phase shift between lines and 514.5 nm line.png ',resolution=100
g3.save,'Modeling phase shift between lines and effective wavelength.png ',resolution=100
ps514=f8
;save, ps514,filename='Phase shift between line 532 and 514.5.save'


 stop
 end