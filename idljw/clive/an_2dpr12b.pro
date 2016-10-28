@doit
@fppos
@pr_prof2


;goto,ee



;sh=intspace(87837,87886)
sh = intspace(89504,89539)
sh=long(sh)

;tr=[.02,.03]
;tr=[.06,.07];8,.09]
;tr=[.03,.04]
tr=[.045,.055]
;tr=[.005,.015]
mode='isat'

nsh=n_elements(sh)
coh=complexarr(nsh)

frng=[20e3,200e3]
;frng=[2000,20e3]
;frng=[200e3,300e3]
;frng=[100e3,200e3]
;frng=[3e3,9e3]
;frng=[2e3,300e3]
;frng=35e3+[-1,1]*15e3/2
;frng=10e3+[-1,1]*5e3/2
;frng=[1e3,5e3]

;frng=[50e3,100e3]doi
;frng=[10e3,50e3]
;frng=[10e3,100e3]

;dum=temporary(frng)
rad=fltarr(nsh)
th=fltarr(nsh)
for i=0,nsh-1 do begin
mdsopen,'h1data',sh(i)
   rad(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERXPOS')
   th(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERYPOS')


   doit,sh(i),frng=frng,coh1=coh1dum,tr=tr,mode=mode;,/tunetime
;continue
;coh1dum= getpar( sh(i), 'isatfork', tw=[.03,.04],y=y,st=st)
;coh1dum= getpar( sh(i), 'vfloatfork', tw=[.03,.04],y=y,st=st)

   coh(i)=coh1dum

endfor
ee:
xbpp=250
rbpp=1112+xbpp-45


r=fltarr(nsh)
z=fltarr(nsh)
for i=0,nsh-1 do begin
;   fppos3,rad(i),th(i),rdum,zdum & zdum+=5
   fppos3,rad(i)-10,th(i),rdum,zdum

   r(i)=rdum & z(i)=zdum
endfor
radx=rad
thx=th
contourn2,float(coh),radx,thx,/irr,/dots,pal=-2,pos=posarr(3,1,0),/cb
contourn2,imaginary(coh),radx,thx,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/cb
contourn2,abs(coh),radx,thx,/irr,/dots,pos=posarr(/next),/noer,/cb

;stop
 
;rf=(read_ascii('~/r1_new.csv',delim=',')).(0)*1000
;zf=(read_ascii('~/z1_new.csv',delim=',')).(0)*1000
;rhof=(read_csv('~/rho1_new.csv')).(0)




;rhof=sqrt(rhof)
;vw=[0.2,0.8,1.0]
;nv=n_elements(vw)

;mkfig,'~/pcoh1.eps',xsize=23,ysize=14,font_size=9
;contourn2,float(coh),r,z,/irr,/dots,pal=-2,pos=posarr(3,1,0,cny=0.1),/cb,xtitle='R(m)',ytitle='Z(m)',title='Real part'

;for i=0,nv-1 do begin
;   i2=value_locate(rhof,vw(i))
;   oplot,rf(i2,*),zf(i2,*),col=2
;endfor


;contourn2,imaginary(coh),r,z,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/cb,xtit;le='R(m)',ytitle='Z(m)',title='Imaginary part'
;for i=0,nv-1 do begin
;   i2=value_locate(rhof,vw(i))
;   oplot,rf(i2,*),zf(i2,*),col=2
;endfor

;contourn2,abs(coh),r,z,/irr,/dots,pos=posarr(/next),/noer,/cb,xtitle='R(m)',yti;tle='Z(m)',title='Absolute value'
;for i=0,nv-1 do begin
;   i2=value_locate(rhof,vw(i))
;   oplot,rf(i2,*),zf(i2,*),col=2
;endfor
;stop
;ensdfig,/gs,/jp

;rhof2=rhof # replicate(1,100)

;etaf1=(linspace(0,2*!pi,101))(0:99)
;etaf1=shift(etaf1,50)
;etaf2=replicate(1,99) # (etaf1)

;cetaf2=cos(etaf2)
;setaf2=sin(etaf2)

;triangulate,rf,zf,tri
;gs=[10,10.]/2.
;rhofn=trigrid(rf,zf,rhof2,tri,gs,xgrid=rfn,ygrid=zfn,missing=!values.f_nan)
;cetafn=trigrid(rf,zf,cetaf2,tri,gs,xgrid=rfn,ygrid=zfn,missing=!values.f_nan)
;setafn=trigrid(rf,zf,setaf2,tri,gs,xgrid=rfn,ygrid=zfn,missing=!values.f_nan)

;ix=interpol(findgen(n_elements(rfn)),rfn,r)
;iy=interpol(findgen(n_elements(zfn)),zfn,z)
;rho=interpolate(rhofn,ix,iy)
;ceta=interpolate(cetafn,ix,iy)
;seta=interpolate(setafn,ix,iy)
;eta=atan(seta,ceta);

;ii=where(finite(rho))

;nfact=max(abs(coh(ii)))
;stop
;mkfig,'~/pcoh2.eps',xsize=20,ysize=20,font_size=10

ii=findgen(n_elements(coh))
loaddata
mb_cart2flux, r*1e-3,z*1e-3,rho,eta,phi=7.2*!dtor & rho=sqrt(rho)

mb_cart2flux, rbpp*1e-3,0,rhobpp,etabpp,phi=0*!dtor & rhobpp=sqrt(rhobpp)


erase
pos=posarr(4,1,0,cny=0.1,cnx=0.1);/next)
contourn2,float(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=pos,/noer,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Real part, meas'


contourn2,imaginary(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=posarr(/next),/noer,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Imaginary part, meas'

contourn2,abs(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pos=posarr(/next),/noer,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Absolute value, meas'


contourn2,atan2(coh(ii))*!radeg,rho(ii),eta(ii),/irr,/dots,pos=posarr(/next),/noer,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='phase, meas',pal=-2
stop


rho0=0.9
eta0=0.15
dr=rho(ii)-rho0
deta=eta(ii)-eta0
kr=-10.
m0=10.
deltar=0.1
deltaeta=0.5
eiy=complex(0,1)
model=exp(-dr^2/deltar^2 - deta^2/deltaeta^2 + eiy * kr * dr + eiy * m0 * deta)


contourn2,float(model),rho(ii),eta(ii),/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Real part, model'


contourn2,imaginary(model),rho(ii),eta(ii),/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Imaginary part, model'


contourn2,abs(model),rho(ii),eta(ii),/irr,/dots,pos=posarr(/next),/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Absolute value, model'

endfig,/gs,/jp

dr2=rhof2-rho0
idx=where(etaf2 gt !pi)
etaf2b=etaf2 & etaf2b(idx)-=2*!pi
deta2=etaf2b-eta0

model2=exp(-dr2^2/deltar^2 - deta2^2/deltaeta^2 + eiy * kr * dr2 + eiy * m0 * deta2)
;mkfig,'~/model_big.eps',xsize=11,ysize=13,font_size=9
contourn2,float(model2),rf,zf,/irr,pal=-2,/cb,/iso,zr=[-1,1],xtitle='R(m)',ytitle='Z(m)',title='Real part, correlation (model)'
for i=0,nv-1 do begin
   i2=value_locate(rhof,vw(i))
   oplot,rf(i2,*),zf(i2,*),col=2
endfor
endfig,/gs,/jp
end

