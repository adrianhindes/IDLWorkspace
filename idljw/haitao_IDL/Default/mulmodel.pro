pro mulmodel, wl1, wl2, dl1,dl2 


scalld, ltmp,dtmp,l0=659.0,fwhm=2.3,opt='a3'  

;wavelength correction
;fil1='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\658 filter.spe' ;measured filter function
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_13_03.spe'; line profile distribution from plasma
;read_spe, fil1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
read_spe, fil2, lam1, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
d1=reverse(d1,1)
;lam=lam+1.0
d=dtmp
lam=ltmp
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
dd=reform(d1(*,1,3)-d1(*,1,10))
p=plot(lam,d,title='Filter function for 659.0 nm and 2.3 width',xtitle='Wavelength/nm',ytitle='Normalized intensity',color='red',name='Filter fuction',xrange=[654,662],yrange=[0,1])
p1=plot(lam1,dd/max(dd),title='Filter function for 659.0 nm and 2.3 width',xtitle='Wavelength/nm',ytitle='Normalized intensity',color='blue',name='Carbon lines',xrange=[654,662],yrange=[0,1],/current)
;l=legend(target=[p,p1])
stop
d2=d2/max(d2)

channel=findgen(10)+1
p=plot(channel,c1r,xtitle='Channel No.',ytitle='Relative ratio',title='Triple lines relative intensity ratio',yrange=[0,1],color='red',name='line 657.805 nm')
p1=plot(channel,c2r,xtitle='Channel No.',ytitle='Relative ratio',title='Triple lines relative intensity ratio',yrange=[0,1],color='blue',name='line 658.288 nm',/current)
p2=plot(channel,hr,xtitle='Channel No.',ytitle='Relative ratio',title='Triple lines relative intensity ratio',yrange=[0,1],color='green',name='line 656.279 nm',/current)
l=legend(target=[p,p1,p2],position=[0.90,0.85,0.95,0.9],/AUTO_TEXT_COLOR) 
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
ia=make_array(512,512,/float) ;inceidence angle
del=make_array(512,512,/float)
ws=make_array(512,512,/float) ;shifted center wavelength
shr=make_array(512,512,/float) ;spatial lines ratio of h alpha line 
sc1r=make_array(512,512,/float) ;spatial line ratio of carbon line one across channels
sc2r=make_array(512,512,/float) ;spatial line ratio of carbon line two across channels
lam_eff=make_array(512,512,/float) ;effective lam for pixels
phase=make_array(512,512,5,/float) ;phase difference 
intensity=make_array(512,512,/complex)
intensity1=make_array(512,512,/complex)
wave=[whr,c1,c2,wne,rw]
for i=0,511 do begin
  for j=0,511 do begin
    ia(i,j)=atan(sqrt(((i-255)*ss)^2+((j-255)*ss)^2),f) ;incidence angle
    del(i,j)=atan((i-255)*ss, (j-255)*ss)
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
    wphase=veiras_eql(lam_eff(i,j),wl1,ia(i,j),del(i,j)-!pi/4+!pi/2,0)+veiras_eqb(lam_eff(i,j), wl2,ia(i,j),del(i,j)+!pi/2+!pi/4,0)+veiras_eqb(lam_eff(i,j), 1.0,ia(i,j),del(i,j)+!pi/2-!pi/4,0)
    dphase=veiras_eqb(lam_eff(i,j), dl1,ia(i,j),del(i,j)+!pi/2-!pi/4,!pi/4)
    dphase1=veiras_eqb(lam_eff(i,j), dl2,ia(i,j),del(i,j)+!pi/2+!pi/4,!pi/4)
    dphase=dphase+dphase1
    phase(i,j,m)=wphase+dphase
endfor
  intensity(i,j)=dcomplex(shr(i,j)*cos(phase(i,j,0))+sc1r(i,j)*cos(phase(i,j,1))+sc2r(i,j)*cos(phase(i,j,2)), shr(i,j)*sin(phase(i,j,0))+sc1r(i,j)*sin(phase(i,j,1))+sc2r(i,j)*sin(phase(i,j,2)))
  intensity1(i,j)=dcomplex(sc1r(i,j)/(sc1r(i,j)+sc2r(i,j))*cos(phase(i,j,1))+sc2r(i,j)/(sc1r(i,j)+sc2r(i,j))*cos(phase(i,j,2)), sc1r(i,j)/(sc1r(i,j)+sc2r(i,j))*sin(phase(i,j,1))+sc2r(i,j)/(sc1r(i,j)+sc2r(i,j))*sin(phase(i,j,2)))
 endfor 
 endfor
 ra=sc1r/sc2r
 p=plot(findgen(512),shr(*,255),title='H alpha raito for 659.3 nm filter with 2.3 nm bandwidth and 3 cavities',xtitle='X pixel',ytitle='H alpha ratio',layout=[1,2,1])
 p=plot(findgen(512),ra(*,255),title='Carbon line raito I1/I2 for 659.3 nm filter with 2.3 nm bandwidth and 3 cavities',xtitle='X pixel',ytitle='Carbon line ratio I1/I2',layout=[1,2,2],/current)
stop

 save, shr,sc1r,sc2r, filename='Ratio data for filter 658.2 with 0.8 nm width with 3 cavity.save'
stop
 save, shrs,filename='H alpha ratio with shifted filter.save'
 ;save, shr,filename='H alpha ratio with current filter.save'
 ;save, shr,filename='H alpha ratio with proposed filter.save'
 restore, 'H alpha ratio with shifted filter.save'
restore, 'H alpha ratio with current filter.save'
shrc=shr
restore, 'H alpha ratio with proposed filter.save'
p=plot(shrc(*,255), title='H alpha ratio for filters',xtitle='X pixel', ytitle='H alpha ratio',color='red',name='Current filter')
p1=plot(shr(*,255), title='H alpha ratio for filters',xtitle='X pixel', ytitle='H alpha ratio',color='blue',name='Proposed filter',/overplot)
p2=plot(shrs(*,255), title='H alpha ratio for filters',xtitle='X pixel', ytitle='H alpha ratio',name='Heated filter',/overplot)
l=legend(target=[p,p1,p2],position=[0.75,0.88,0.85,0.93],/AUTO_TEXT_COLOR)
 
stop 
end