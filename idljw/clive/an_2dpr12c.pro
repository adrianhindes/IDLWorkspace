@pr_prof2
@tdcorr
@fppos
;goto,ee

sh=intspace(87837,87886)
;sh=intspace(89504,89539)
sh=long(sh)

;tr=;[.02,.03]
tr=20e-3+[-1,1]*1e-3
mode='isat'
;frng=[1e3,100e3]
frng=[-1,-1]
lmax=600 

nsh=n_elements(sh)
coh=complexarr(nsh)
rad=fltarr(nsh)
th=fltarr(nsh)

corr=fltarr(2*lmax+1,nsh)
maxcc=fltarr(nsh)
tlag=fltarr(nsh)
mn=fltarr(nsh)

for i=0,nsh-1 do begin
mdsopen,'h1data',sh(i)
   rad(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERXPOS')
   th(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERYPOS')


tdcorr, sh(i), tr, frng, tlag1,maxcc1,velocity=velocity,doplot=1,lmax=lmax,corr=corr1,method='new',wintype='hat',mn=mn1,/tunetime
corr(*,i)=corr1
tlag(i)=tlag1
maxcc(i)=maxcc1
mn(i)=mn1
;   doit,sh(i),frng=frng,coh1=coh1dum,tr=tr,mode=mode
;continue
;coh1dum= getpar( sh(i), 'isatfork', tw=[.03,.04],y=y,st=st)
;coh1dum= getpar( sh(i), 'vfloatfork', tw=[.03,.04],y=y,st=st)

;   coh(i)=coh1dum

endfor
ee:
r=fltarr(nsh)
z=fltarr(nsh)
for i=0,nsh-1 do begin
;   fppos3,rad(i)+20,th(i)-.1,rdum,zdum
   fppos3,rad(i)+10,th(i)-.1,rdum,zdum
;   fppos3,rad(i),th(i),rdum,zdum
   r(i)=rdum & z(i)=zdum
endfor
radx=rad
thx=th
contourn2,(maxcc),radx,thx,/irr,/dots,pal=-2,pos=posarr(3,1,0),/cb
contourn2,(tlag*1e6),radx,thx,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/cb
contourn2,corr(lmax,*),radx,thx,/irr,/dots,pos=posarr(/next),/noer,/cb,pal=-2

;stop
coh=corr(lmax+50,*) 

rf=(read_ascii('~/r1_new.csv',delim=',')).(0)*1000
zf=(read_ascii('~/z1_new.csv',delim=',')).(0)*1000
rhof=(read_csv('~/rho1_new.csv')).(0)




rhof=sqrt(rhof)
vw=[0.05,0.6,.7,.8,.9,1.]
nv=n_elements(vw)

;mkfig,'~/pcoh1.eps',xsize=23,ysize=14,font_size=9

;contourn2,corr(lmax,*),r,z,/irr,/dots,pos=posarr(1,1,0,cny=0.1),/iso,/cb,xtitle='R(m)',ytitle='Z(m)'

;mkfig,'~/ncanpts.eps',xsize=10,ysize=14,font_size=8
contourn2,mn,r,z,/irr,/dots,/iso,/cb,xtitle='R(m)',ytitle='Z(m)',xr=[1000,1350],yr=[-150,250],/inhibit

for i=0,nv-1 do begin
   i2=value_locate(rhof,vw(i))
   oplot,rf(i2,*),zf(i2,*),col=2
endfor
endfig,/gs,/jp
;stop

;; contourn2,corr(lmax+10,*),r,z,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb,xtitle='R(m)',ytitle='Z(m)',title='10micro delay'
;; for i=0,nv-1 do begin
;;    i2=value_locate(rhof,vw(i))
;;    oplot,rf(i2,*),zf(i2,*),col=2
;; endfor

;; contourn2,corr(lmax+20,*),r,z,/irr,/dots,pos=posarr(/next),/noer,/iso,/cb,xtitle='R(m)',ytitle='Z(m)',title='20 micro delay',pal=-2
;; for i=0,nv-1 do begin
;;    i2=value_locate(rhof,vw(i))
;;    oplot,rf(i2,*),zf(i2,*),col=2
;; endfor
;; stop
;ensdfig,/gs,/jp

rhof2=rhof # replicate(1,100)

etaf1=(linspace(0,2*!pi,101))(0:99)
;etaf1=shift(etaf1,50)
etaf2=replicate(1,99) # (etaf1)

cetaf2=cos(etaf2)
setaf2=sin(etaf2)

triangulate,rf,zf,tri
gs=[10,10.]/2.
rhofn=trigrid(rf,zf,rhof2,tri,gs,xgrid=rfn,ygrid=zfn,missing=!values.f_nan)
cetafn=trigrid(rf,zf,cetaf2,tri,gs,xgrid=rfn,ygrid=zfn,missing=!values.f_nan)
setafn=trigrid(rf,zf,setaf2,tri,gs,xgrid=rfn,ygrid=zfn,missing=!values.f_nan)

ix=interpol(findgen(n_elements(rfn)),rfn,r)
iy=interpol(findgen(n_elements(zfn)),zfn,z)
rho=interpolate(rhofn,ix,iy)
ceta=interpolate(cetafn,ix,iy)
seta=interpolate(setafn,ix,iy)
eta=atan(seta,ceta)

ii=where(finite(rho))

nfact=max(abs(coh(ii)))
;stop
;mkfig,'~/pcoh2.eps',xsize=20,ysize=20,font_size=10
erase

pos=posarr(3,1,0,cny=0.1,cnx=0.1);/next)
;contourn2,float(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=pos,/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Real part, meas'


;contourn2,imaginary(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Imaginary part, meas'



contourn2,mn(ii),rho(ii),eta(ii),/irr,/dots,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title=iloop

;stop

for iloop=0,lmax-1,10 do begin
;contourn2,(corr(lmax+iloop,ii)),rho(ii),eta(ii),/irr,/dots,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title=iloop,zr=[0,.08]

;adum='' & read,'',adum
endfor

;stop

triangulate, rho(ii),eta(ii),tri
corr(0,*)=mn
for i=0,2*lmax do begin
tmp=trigrid(rho(ii),eta(ii),corr(i,ii),tri,xgrid=rho1,ygrid=eta1)
if i eq 0 then begin
   sz=size(tmp,/dim)
   corr1=fltarr(sz(0),sz(1),2*lmax+1)
endif
corr1(*,*,i)=tmp
;stop
endfor
ee2:
cnt=0L
for isel=lmax,2*lmax, 10 do begin
;mkfig,'~/anim/img_'+string(cnt,format='(I2.2)')+'.eps',xsize=13,ysize=10,font_size=8
cnt++
imgplot, corr1(*,*,isel),rho1,eta1,pos=posarr(2,1,0,cny=0.1,cnx=0.1),zr=[0,.06],xtitle='r/a',ytitle=textoidl('\theta (rad)'),title=string(textoidl('\tau='),isel-lmax,textoidl('\mu s'),format='(A,I0,A)'),offx=1
imgplot, corr1(*,*,isel)-corr1(*,*,0),rho1,eta1,pos=posarr(/next),/noer,pal=-2,zr=[-.02,.02],offx=1,xtitle='r/a'
iw=30;5
oplot,rho1(iw)*[1,1],!y.crange,linesty=2

plot,eta1,corr1(iw,*,isel);,pos=posarr(/next),/noer
oplot,eta1,0.03 + 0.02 * cos(3 * eta1),col=2
;stop
endfig,/jp,/gs
;stop
;adum='' & read,'',adum
endfor
tee=findgen(2*lmax+1)-lmax

trial=fltarr(n_elements(tee),n_elements(eta1))
freq=6e3
etaoff=0
for i=0,n_elements(eta1)-1 do for j=0,n_elements(tee)-1 do begin
trial(j,i)=0.03+0.01 * cos(etaoff+3*eta1(i) - 2*!pi*freq*tee(j)*1e-6) + $
           0.007 * cos(etaoff+3*eta1(i) + 2*!pi*freq*tee(j)*1e-6)
endfor

xr=[-164,164]*1.5
zr=[0,.06]
mkfig,'~/tex/ishw/thist_cor.eps',xsize=8,ysize=4.5,font_size=8
imgplot,transpose(reform(corr1(iw,*,*))),tee,eta1,/cb,xr=xr,pal=5,xtitle=textoidl('\tau (\mu s)'),ytitle=textoidl('\theta (rad)'),offx=1.,pos=posarr(1,1,0,cnx=0.15,cny=0.1,fy=0.7)
;imgplot,trial,tee,eta1,pos=posarr(/next),/noer,/cb,xr=xr,zr=zr
endfig,/gs,/jp

end

