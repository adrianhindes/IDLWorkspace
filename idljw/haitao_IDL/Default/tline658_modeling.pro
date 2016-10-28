pro tline658_modeling, wl, wr, dl,dr
;wavelength correction
;fil1='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\658 filter.spe' ;measured filter function
scalld, ltmp,dtmp,l0=658.0,fwhm=2,opt='a3'  
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_13_03.spe'; line profile distribution from plasma
;read_spe, fil1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
read_spe, fil2, lam1, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
d1=reverse(d1,1)
;d=d/max(d)
im=max(dtmp, index)
cw=658.0 ; measured filter center wavelength approximation
hr=make_array(10,/float);lines ratio of h alpha line across channels
c1r=make_array(10,/float);line ratio of carbon line one across channels
c2r=make_array(10,/float);line ratio of carbon line two across channels
for m=0,9 do begin
  n=reform(d1(*,m,1))
  n=n-mean(n(0:200))
  a=float(max(n(0:400)))
  b=float(max(n(400:520)))
  c=float(max(n(520:600)))
  hr(m)=a/(a+b+c)
  c1r(m)=b/(a+b+c)
  c2r(m)=c/(a+b+c)
  endfor

;off-axis incidence of filter
whr=656.279 ;h alpha line wavelength from Nist
c1=657.805  ;carbonII line wavelength from Nist
c2=658.288
wne=659.895 ;ne lamp wavelength
ss=16.0*1e-6 ;sensor size in m
f=50.0*1e-3  ;focal length in m
nf=2.05 ;refrective index of filter material
ia=make_array(512,128,/float) ;inceidence angle
del=make_array(512,128,/float)
ws=make_array(512,128,/float) ;shifted center wavelength
shr=make_array(512,128,/float) ;spatial lines ratio of h alpha line 
sc1r=make_array(512,128,/float) ;spatial line ratio of carbon line one across channels
sc2r=make_array(512,128,/float) ;spatial line ratio of carbon line two across channels
lam_eff=make_array(512,128,/float) ;effective lam for pixels
phase=make_array(512,128,/float) ;phase difference 
for i=0,511 do begin
  for j=0,127 do begin
    ia(i,j)=atan(sqrt(((i-255)*ss)^2+((j-63)*ss*4)^2),f) ;incidence angle
    del(i,j)=atan((i-255)*ss, (j-63)*4*ss)
    ws(i,j)=cw*(1-sqrt(1-(sin(ia(i,j))/nf)^2))
    shr1=interpol(dtmp,ltmp-ws(i,j),whr,/QUADRATIC)*hr(2)
    sc1r1=interpol(dtmp,ltmp-ws(i,j),c1,/QUADRATIC)*c1r(2)
    sc2r1=interpol(dtmp,ltmp-ws(i,j),c2,/QUADRATIC)*c2r(2)
    shr(i,j)=shr1/(shr1+sc1r1+sc2r1)
    sc1r(i,j)=sc1r1/(shr1+sc1r1+sc2r1)
    sc2r(i,j)=sc2r1/(shr1+sc1r1+sc2r1)
    lam_eff(i,j)=whr*shr(i,j)+c1*sc1r(i,j)+c2*sc2r(i,j)
    ;lam_eff(i,j)=659.895
    wphase=veiras_eql(lam_eff(i,j),wl,ia(i,j),del(i,j)+wr,0)+veiras_eql(lam_eff(i,j), 15.0,ia(i,j),del(i,j)+wr,0)
    dphase=veiras_eqb(lam_eff(i,j), dl,ia(i,j),del(i,j)+dr,!pi/4)+veiras_eqb(lam_eff(i,j),dl,ia(i,j),del(i,j)+dr+!pi/2,!pi/4)
    dphase1=veiras_eqb(lam_eff(i,j), 1.0,ia(i,j),del(i,j)+dr,!pi/4)+veiras_eqb(lam_eff(i,j), 1.0,ia(i,j),del(i,j)+dr+!pi/2,!pi/4)
    dphase=dphase+dphase1
    phase(i,j)=wphase+dphase
 endfor 
 endfor
 ;phase2=make_array(512,128,/float)
 ;phase2=phase
 ;save, phase2, filename='line660 phase.save'
;w=window(window_title='Phase shift caused by H alpha ratio',dimens
;
;ions=[1200,1000])
 restore, 'line660 phase.save' ;phase2
 restore, 'line658 phase.save' ;phase1
;phase_r=phase1-phase
 ;channel=findgen(10)+1
 ;xpixel=findgen(512)
;ypixel=findgen(128)
;p=plot(lam1,d1(*,2,1),xtitle='wavelength/nm',ytitle='Intensity',title='Typical spectrometer data of plasma',layout=[2,2,1],/current)
;p1=plot(channel, hr, xtitle='Channel No.', ytitle='H alpha ratio',title='H alpha line ratio across channel',symbol='o',color='red', layout=[2,2,2],/current)
;p2=image(phase, xpixel, ypixel,axis_style=1,rgb_table=4, xtitle='X pixel',ytitle='Y pixel', title='Phase(radians) for channel 9 ratio',layout=[2,2,3],aspect_ratio=4,/current)
;c=colorbar(target=p2, orientation=1)
;p3=image(phase_r, xpixel, ypixel,axis_style=1, rgb_table=4,xtitle='X pixel',ytitle='Y pixel', title='Phase(radians) shift for channel 7 and 5',layout=[2,2,4],aspect_ratio=4,/current)
;c=colorbar(target=p3, orientation=1)
x=findgen(5120)*0.1
 y=findgen(1280)*0.1
 ;g=image(rebin(lam_eff,5120,1280),x,y, axis_style=1,rgb_table=4,title='Effective Wavelength for 2 nm filter in theory',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c=colorbar(target=g, orientation=1)
g1=image(rebin(cos(reverse(phase,2)),5120,1280),x,y, axis_style=1,rgb_table=4,title='Modeling image of carbon line 658 for 2 nm filter in theory',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c1=colorbar(target=g1, orientation=1)
;p4=plot(lam, d, xrange=[654,662],title='Center line profiles',xtitle='Wavelength(nm)',yrange=[0,1],ytitle='Relative intensity')
;p5=plot(lam1, d1(*,1,1)/max(d1(*,2,1)), xrange=[654,662],xtitle='Wavelength(nm)',ytitle='Relative intensity',yrange=[0,1],/current)
;trans=[interpol(d,lam-ws(255,63),whr,/QUADRATIC),interpol(d,lam-ws(255,63),c1,/QUADRATIC),interpol(d,lam-ws(255,63),c2,/QUADRATIC)]
ir=[hr(2), c1r(2),c2r(2)]
;c=[whr,c1,c2]
;a=atan(sin(phase),cos(phase))
;jumpimg,a
;a1=atan(sin(phase1),cos(phase1))
;jumpimg, a1
;a2=atan(sin(phase2),cos(phase2))
;jumpimg, a2
;g2=image(rebin(phase-phase2,5120,1280), x,y,rgb_table=4, axis_style=1,title='Modeling phase difference between triple lines and 660 nm line for 2 nm filter in theory', xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c2=colorbar(target=g2, orientation=1)
;g3=image(rebin(phase1-phase2,5120,1280), x,y,rgb_table=4, axis_style=1,title='Modeling phase difference between 658 nm and 660 nm line for 2 nm filter in theory', xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c3=colorbar(target=g3, orientation=1)
;g.save, 'Effective wavelength for 1 nm filter in theory.png'
g1.save,'Modeling image of carbon line 658 for  nm filter in theory.png'
;g2.save, 'Modeling phase difference between triple lines and 660 nm line.png'
;g3.save, 'Modeling phase difference between 658 nm and 660 nm line.png'

 stop
 end
 