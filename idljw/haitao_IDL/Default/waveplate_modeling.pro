function veiras_eql, wavelength, l,alpha, del, sita,n_e=n_e,n_o=n_o ;veiras equation for Linbo3
 delta=linbo3(wavelength, n_e=n_e,n_o=n_o)
 term1=sqrt(n_o^2-sin(alpha)^2)
 term2=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del)*sin(alpha)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
 term3=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del)^2)*sin(alpha)^2)
 phase_shift=2*!pi*l*1e-3/(wavelength*1e-9)*(term1+term2+term3)
 return, phase_shift
end

function veiras_eqb, wavelength, l,alpha, del, sita,n_e=n_e,n_o=n_o ;veiras equation for BBO
 delta=bbo(wavelength, n_e=n_e,n_o=n_o)
 term1=sqrt(n_o^2-sin(alpha)^2)
 term2=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del)*sin(alpha)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
 term3=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del)^2)*sin(alpha)^2)
 phase_shift=2*!pi*l*1e-3/(wavelength*1e-9)*(term1+term2+term3)
 return, phase_shift
end

function veiras_eqc, wavelength, l,alpha, del, sita,n_e=n_e,n_o=n_o ;veiras equation for BBO
 delta=ccalcite(wavelength, n_e=n_e,n_o=n_o)
 term1=sqrt(n_o^2-sin(alpha)^2)
 term2=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del)*sin(alpha)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
 term3=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del)^2)*sin(alpha)^2)
 phase_shift=2*!pi*l*1e-3/(wavelength*1e-9)*(term1+term2+term3)
 return, phase_shift
end


function waveplatel, wavelength,wl,wr
alpha=make_array(512,128,/double)
del=make_array(512,128,/double)
phase_shift=make_array(512,128,/double) ;delay thickness in mm
;wavelength=532.0 ; wavelength in nm
delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
;delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(512,128,/double)
term2=make_array(512,128,/double)
term3=make_array(512,128,/double)
simulation=make_array(512,128,/double)
sita=0
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,511 do begin
  for j=0,127 do begin
  del(i,j)=atan((i-255)*sensor, (j-63)*4*sensor)+wr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-63)*sensor*4)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*wl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return , phase_shift
end

function waveplateb, wavelength,wl,wr
alpha=make_array(512,128,/double)
del=make_array(512,128,/double)
phase_shift=make_array(512,128,/double) ;delay thickness in mm
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(512,128,/double)
term2=make_array(512,128,/double)
term3=make_array(512,128,/double)
simulation=make_array(512,128,/double)
sita=0
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,511 do begin
  for j=0,127 do begin
  del(i,j)=atan((i-255)*sensor, (j-63)*4*sensor)+wr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-63)*sensor*4)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*wl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return , phase_shift
end

;displacer bbo
function displacer, wavelength,dl ,dr
alpha=make_array(512,128,/double)
del=make_array(512,128,/double)
phase_shift=make_array(512,128,/double)
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(512,128,/double)
term2=make_array(512,128,/double)
term3=make_array(512,128,/double)
simulation=make_array(512,128,/double)
sita=!pi/4
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,511 do begin
  for j=0,127 do begin
  del(i,j)=atan((i-255)*sensor, (j-63)*4*sensor)+dr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-63)*sensor*4)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*dl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return,phase_shift
end


function displacerc, wavelength,dl ,dr
alpha=make_array(512,128,/double)
del=make_array(512,128,/double)
phase_shift=make_array(512,128,/double)
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n2=ccalcite(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(512,128,/double)
term2=make_array(512,128,/double)
term3=make_array(512,128,/double)
simulation=make_array(512,128,/double)
sita=!pi/4
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,511 do begin
  for j=0,127 do begin
  del(i,j)=atan((i-255)*sensor, (j-63)*4*sensor)+dr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-63)*sensor*4)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*dl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return,phase_shift
end

pro line658_modeling, wl, wr, dl,dr 
;hypobolic pattern generating for thesis
pd=waveplatel(658.0,35,0.0)
file='C:\haitao\papers\study topics\H-1 projection\data and results\rs image data\add delay plate.tif'
file1='C:\haitao\papers\study topics\H-1 projection\data and results\rs image data\calibration image.tif'
ig=read_tiff(file)
ig1=read_tiff(file1)
g=image(rotate(ig1(200:400,200:400),1))
stop
;scalld, ltmp,dtmp,l0=658.0,fwhm=1.5,opt='a3'  

;wavelength correction
fil1='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\658 filter.spe' ;measured filter function
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_13_03.spe'; line profile distribution from plasma
read_spe, fil1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
read_spe, fil2, lam1, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
d1=reverse(d1,1)
lam=lam
;d=dtmp
;lam=ltmp
d=d/max(d)
im=max(d, index)
cw=lam(index) ; measured filter center wavelength approximation


hr=make_array(10,/float);lines ratio of h alpha line across channels
c1r=make_array(10,/float);line ratio of carbon line one across channels
c2r=make_array(10,/float);line ratio of carbon line two across channels
d2=make_array(10,/float)
for m=0,9 do begin
  n=reform(d1(*,m,2))
  n=n-d1(*,m,8)
  a=total(n(260:330))
  b=total(n(460:530))
  c=total(n(530:600))
  hr(m)=a/(a+b+c)
  c1r(m)=b/(a+b+c)
  c2r(m)=c/(a+b+c)
  d2(m)=total(n)
  endfor
;save, hr, c1r, c2r, filename='Relative ratio of carbon 658 lines.save'

d2=d2/max(d2)

channel=findgen(10)+1
;p=plot(channel,c1r,xtitle='Channel No.',ytitle='Relative ratio',title='Triple lines relative intensity ratio',yrange=[0,1],color='red',name='line 657.805 nm')
;p1=plot(channel,c2r,xtitle='Channel No.',ytitle='Relative ratio',title='Triple lines relative intensity ratio',yrange=[0,1],color='blue',name='line 658.288 nm',/current)
;p2=plot(channel,hr,xtitle='Channel No.',ytitle='Relative ratio',title='Triple lines relative intensity ratio',yrange=[0,1],color='green',name='line 656.279 nm',/current)
;l=legend(target=[p,p1,p2],position=[0.90,0.85,0.95,0.9],/AUTO_TEXT_COLOR) 
;p2=plot(channel,d2,xtitle='Channel No.',ytitle='Relative intensity',title='Relative total intensity of different channels',color='green')
;p3=plot(channel,c1r/(c1r+c2r),xtitle='Channel No.',ytitle='Relative intensity',title='Relative intensity of two carbon lines',yrange=[0,1],color='blue',name='line 657.805 nm')
;p4=plot(channel,c2r/(c1r+c2r),xtitle='Channel No.',ytitle='Relative intensity',title='Relative intensity of two carbon lines',color='red',yrange=[0,1],name='line 658.288 nm',/current)
;l=legend(target=[p3,p4],position=[0.90,0.85,0.95,0.9],/AUTO_TEXT_COLOR)
;p5=plot(channel, d2, title='Relative total intensity of different channels',xtitle='Channel NO.',ytitle='Relative intensity')
 
;off-axis incidence of filter
whr=656.279 ;h alpha line wavelength from Nist
c1=657.805  ;carbonII line wavelength from Nist
c2=658.288
wne=659.895 ;ne lamp wavelength
rw=657.963 ;effective wavelength from two carbon line alone
ss=16.0*1e-6 ;sensor size in m
f=85.0*1e-3  ;focal length in m
nf=2.05 ;refrective index of filter material
ia=make_array(512,128,/float) ;inceidence angle
del=make_array(512,128,/float)
ws=make_array(512,128,/float) ;shifted center wavelength
shr=make_array(512,128,/float) ;spatial lines ratio of h alpha line 
sc1r=make_array(512,128,/float) ;spatial line ratio of carbon line one across channels
sc2r=make_array(512,128,/float) ;spatial line ratio of carbon line two across channels
lam_eff=make_array(512,128,/float) ;effective lam for pixels
phase=make_array(512,128,5,/float) ;phase difference 
intensity=make_array(512,128,/complex)
intensity1=make_array(512,128,/complex)
wave=[whr,c1,c2,wne,rw]
for i=0,511 do begin
  for j=0,127 do begin
    ia(i,j)=atan(sqrt(((i-255)*ss)^2+((j-63)*ss*4)^2),f) ;incidence angle
    del(i,j)=atan((i-255)*ss, (j-63)*4*ss)
    ws(i,j)=cw*(1-sqrt(1-(sin(ia(i,j))/nf)^2))
    shr1=interpol(d,lam-ws(i,j),whr,/QUADRATIC)*hr(2)
    sc1r1=interpol(d,lam-ws(i,j),c1,/QUADRATIC)*c1r(2)
    sc2r1=interpol(d,lam-ws(i,j),c2,/QUADRATIC)*c2r(2)
    shr(i,j)=shr1/(shr1+sc1r1+sc2r1)
    sc1r(i,j)=sc1r1/(sc1r1+sc2r1+shr1)
    sc2r(i,j)=sc2r1/(sc1r1+sc2r1+shr1)
    ;lam_eff(i,j)=whr*shr(i,j)+c1*sc1r(i,j)+c2*sc2r(i,j)
for m=0,4 do begin
    lam_eff(i,j)=wave(m)
    wphase=veiras_eql(lam_eff(i,j),wl,ia(i,j),del(i,j)+wr+!pi/2,0)*klinbo3(lam_eff(i,j))+veiras_eql(lam_eff(i,j), 15.0,ia(i,j),del(i,j)+wr+!pi/2,0)*klinbo3(lam_eff(i,j))
    dphase=veiras_eqb(lam_eff(i,j), dl,ia(i,j),del(i,j)+dr+!pi/2,!pi/4)*kbbo(lam_eff(i,j))-veiras_eqb(lam_eff(i,j),dl,ia(i,j),del(i,j)+dr+!pi,!pi/4)*kbbo(lam_eff(i,j))
    ;dphase1=veiras_eqb(lam_eff(i,j), 1.0,ia(i,j),del(i,j)+dr+!pi/2,!pi/4)*kbbo(lam_eff(i,j))-veiras_eqb(lam_eff(i,j), 1.0,ia(i,j),del(i,j)+dr+!pi,!pi/4)*kbbo(lam_eff(i,j))
    dphase=dphase;+dphase1
    phase(i,j,m)=wphase+dphase
endfor
  intensity(i,j)=dcomplex(shr(i,j)*cos(phase(i,j,0))+sc1r(i,j)*cos(phase(i,j,1))+sc2r(i,j)*cos(phase(i,j,2)), shr(i,j)*sin(phase(i,j,0))+sc1r(i,j)*sin(phase(i,j,1))+sc2r(i,j)*sin(phase(i,j,2)))
  intensity1(i,j)=dcomplex(sc1r(i,j)/(sc1r(i,j)+sc2r(i,j))*cos(phase(i,j,1))+sc2r(i,j)/(sc1r(i,j)+sc2r(i,j))*cos(phase(i,j,2)), sc1r(i,j)/(sc1r(i,j)+sc2r(i,j))*sin(phase(i,j,1))+sc2r(i,j)/(sc1r(i,j)+sc2r(i,j))*sin(phase(i,j,2)))
 endfor 
 endfor
 ccontrast=abs(intensity)
 ;save, ccontrast, filename='compensation contrast for 10 mm savart plate.save'
stop 
;oc_658=abs(intensity)
;save, oc_658, filename='contrast offset for 658 lines with 35 mm delay.save'
 stop
;rp=waveplate(658,20.0,!pi/4)+waveplate(658,15.0,!pi/4)+displacer(658,1.0,!pi/4)-displacer(658,1.0,3*!pi/4)+displacer(658,1.25,!pi/4)-displacer(658,1.25,3*!pi/4)
;g1=image(rebin(phase-rp,5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling image of carbon line 658',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c1=colorbar(target=g1,orientation=1)



 x=findgen(5120)*0.1
 y=findgen(1280)*0.1
 stop
;phase demodulation
;f=fft(reverse(intensity,2),/center)
;f(0:170,*)=0
;f(220:*,*)=0
;f1=fft(f, /inverse, /center)
;f1=dcomplex(cos(reverse(intensity,2)),sin(reverse(intensity,2)))
f1=intensity

;f2=fft(cos(phase(*,*,4)),/center) ;phase of line effective wavelength
;f2(0:170,*)=0
;f2(220:*,*)=0
;f3=fft(f2, /inverse, /center)
;f3=dcomplex(cos(reverse(phase(*,*,4),2)),sin(reverse(phase(*,*,4),2)))
f2=phase(*,*,4)
f3=dcomplex(cos(f2),sin(f2))
f4=atan(f1/f3, /phase)
 jumpimg,f4
f5=fft(cos(phase(*,*,3)),/center) ;phase of Neon line
;f5(0:170,*)=0
;f5(220:*,*)=0
;f6=fft(f5, /inverse, /center)
f5=phase(*,*,3)
f6=dcomplex(cos(f5),sin(f5))
;f6=dcomplex(cos(reverse(phase(*,*,3),2)),sin(reverse(phase(*,*,3),2)))
f7=atan(f1/f6, /phase)
jumpimg,f7
f8=atan(f3/f6,/phase)

g4=image(rebin(f4,5120,1280),x,y, axis_style=1,rgb_table=4,max_value=2.0,min_value=1.90,title='Modeling phase shift between triple lines and effective wavelength ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c4=colorbar(target=g4, orientation=1)
g5=image(rebin(f7,5120,1280),x,y, axis_style=1,rgb_table=4,max_value=-1,min_value=-4,title='Modeling phase shift between triple lines and Neon line ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c5=colorbar(target=g5, orientation=1) 
g6=image(rebin(f8,5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling phase shift between Neon line and effective wavelength ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c6=colorbar(target=g6, orientation=1) 
g7=image(rebin(real_part(intensity),5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling image of triple 658 carbon lines ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c7=colorbar(target=g7, orientation=1) 
ps658=f8
 
;save, ps658, filename='Phase shift between 658 nm line and neon line.save'
 
 


 ;g=image(rebin(reverse(intensity,2),5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling image of carbon 658 line',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c=colorbar(target=g, orientation=1)
;g1=image(rebin(cos(reverse(phase,2)),5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling image of carbon line 658',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c1=colorbar(target=g1, orientation=1)
;p4=plot(lam, d, xrange=[654,662],title='Center line profiles',xtitle='Wavelength(nm)',yrange=[0,1],ytitle='Relative intensity')
;p5=plot(lam1, d1(*,1,1)/max(d1(*,2,1)), xrange=[654,662],xtitle='Wavelength(nm)',ytitle='Relative intensity',yrange=[0,1],/current)
;trans=[interpol(d,lam-ws(255,63),whr,/QUADRATIC),interpol(d,lam-ws(255,63),c1,/QUADRATIC),interpol(d,lam-ws(255,63),c2,/QUADRATIC)]
;ir=[hr(2), c1r(2),c2r(2)]
;c=[whr,c1,c2]
;a=atan(sin(phase),cos(phase))
;jumpimg,a
;a1=atan(sin(phase1),cos(phase1))
;jumpimg, a1
;a2=atan(sin(phase2),cos(phase2))
;jumpimg, a2
;g2=image(rebin(phase-phase2,5120,1280), x,y,rgb_table=4, axis_style=1,title='Modeling phase difference between triple lines and 660 nm line', xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c2=colorbar(target=g2, orientation=1)
;g3=image(rebin(phase1-phase2,5120,1280), x,y,rgb_table=4, axis_style=1,title='Modeling phase difference between 658 nm and 660 nm line', xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c3=colorbar(target=g3, orientation=1)
;g.save, 'Effective wavelength for 658 nm filter.png'
;g1.save, 'Modeling image of carbon line 658 for 80 mm lens.png'
;g2.save, 'Modeling phase difference between triple lines and 660 nm line.png'
;g3.save, 'Modeling phase difference between 658 nm and 660 nm line.png'

;g4.save, 'Modeling phase shift between triple lines and effective wavelength.png',resolution=100
;g5.save, 'Modeling phase shift between triple lines and Neon line.png ',resolution=100
;g6.save, 'Modeling phase shift between Neon line and effective wavelength.png',resolution=100
;g7.save,  'Modeling image of two 658 carbon lines.png ', resolution=100
;fil3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81137.SPE'
;read_spe, fil3, lam2, t,d2,texp=texp,str=str,fac=fac & d2=float(d2)

 stop
 end
 

 
