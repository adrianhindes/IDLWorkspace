@pr_prof2
@tdcorr
@fppos
goto,ee

sh=intspace(87837,87886)
sh=long(sh)

;tr=;[.02,.03]
tr=20e-3+[-1,1]*1e-3
trlint=[20e-3,30e-3]
;trlint=[80e-3,90e-3]
;tr=80e-3+[-1,1]*1e-3*5
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

lint=mn
for i=0,nsh-1 do begin
mdsopen,'h1data',sh(i)
   rad(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERXPOS')
   th(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERYPOS')


tdcorr, sh(i), tr, frng, tlag1,maxcc1,velocity=velocity,doplot=1,lmax=lmax,corr=corr1,method='new',wintype='hat',mn=mn1,tunetime=1
corr(*,i)=corr1
tlag(i)=tlag1
maxcc(i)=maxcc1
mn(i)=mn1

lint(i) =getpar( sh(i), 'isat', tw=trlint)

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
;   fppos3,rad(i)+0,th(i)+0.,rdum,zdum&   zdum+=5
   fppos3,rad(i)-10,th(i),rdum,zdum


;   fppos3,rad(i)+10,th(i)-.1,rdum,zdum
;   fppos3,rad(i),th(i)-.1,rdum,zdum
   r(i)=rdum & z(i)=zdum
endfor
radx=rad
thx=th
contourn2,(maxcc),radx,thx,/irr,/dots,pal=-2,pos=posarr(3,1,0),/cb
contourn2,(tlag*1e6),radx,thx,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/cb
contourn2,corr(lmax,*),radx,thx,/irr,/dots,pos=posarr(/next),/noer,/cb,pal=-2

;stop
coh=corr(lmax+50,*) 

contourn2,mn,r,z,/irr,/dots,/iso,/cb,xtitle='R(m)',ytitle='Z(m)',xr=[1000,1350],yr=[-150,250],/inhibit



loaddata
mb_cart2flux, r*1e-3,z*1e-3,rho,eta,phi=7.2*!dtor & rho=sqrt(rho)

masknot = (th eq 0 and rad eq 255.) 
masknot = masknot or (th eq 0 and rad eq 265.) 

mask= not masknot

mask2 = lint ge 17e-3 and lint le 28e-3*100
ii=where(finite(rho) and mask and mask2)


nfact=max(abs(coh(ii)))
;stop
;mkfig,'~/pcoh2.eps',xsize=20,ysize=20,font_size=10
erase

pos=posarr(3,1,0,cny=0.1,cnx=0.1);/next)
;contourn2,float(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=pos,/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Real part, meas'


;contourn2,imaginary(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Imaginary part, meas'

var=mn;lint;mn

contourn2,var(ii),r(ii),z(ii),/irr,/dots,/iso,/cb,xtitle='R(m)',ytitle='Z(m)',xr=[1170,1350],yr=[50,250],/inhibit,pos=posarr(2,1,0),xsty=1,ysty=1
;stop

nth=361&th1=linspace(0,2*!pi,nth)
vw=[0.05,0.6,.7,.8,.9,1.]
nv=n_elements(vw)
for i=0,nv-1 do begin
   mb_flux2cart, vw(i)^2*replicate(1,nth),th1,rdum,zdum,phi=7.2*!dtor
   oplot,rdum,zdum,col=2
;stop
endfor



contourn2,var(ii),rho(ii),eta(ii),/irr,/dots,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title=iloop,pos=posarr(/next),/noer,/cb
iw=29;14;20;25;iw=30
oplot,rho1(iw)*[1,1],!y.crange,col=2
;contourn2,corr(lmax+82,ii),rho(ii),eta(ii),/irr,/dots,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title=iloop

stop

for iloop=0,lmax-1,10 do begin
;contourn2,(corr(lmax+iloop,ii)),rho(ii),eta(ii),/irr,/dots,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title=iloop,zr=[0,.08]

;adum='' & read,'',adum
endfor

;stop

triangulate, rho(ii),eta(ii),tri
;corr(0,*)=mn


for i=0,2*lmax do begin
tmp=trigrid(rho(ii),eta(ii),corr(i,ii),tri,xgrid=rho1,ygrid=eta1)
tmps=trigrid(rho(ii),eta(ii),corr(i,ii)-mn(ii),tri,xgrid=rho1,ygrid=eta1)
if i eq 0 then begin
   sz=size(tmp,/dim)
   corr1=fltarr(sz(0),sz(1),2*lmax+1)
   corr1s=fltarr(sz(0),sz(1),2*lmax+1)
endif
corr1(*,*,i)=tmp
corr1s(*,*,i)=tmps

;stop
endfor
ee2:


cnt=0L
;mkfig,'~/tex/ishw/panel2.eps',xsize=8,ysize=9,font_size=8
;pos=posarr(2,2,0,cny=.1,cnx=0.1,fx=0.5)

pos=posarr(2,2,0,cny=.1,cnx=0.12,fx=0.,msratx=99,msraty=10)



for isel=lmax,lmax+123, 41 do begin
;mkfig,'~/anim/img_'+string(cnt,format='(I2.2)')+'.eps',xsize=13,ysize=10,font_size=8
;contourn2, corr1(*,*,isel),rho1,eta1,pos=pos,zr=[0,.06],xtitle='r/a',ytitle=textoidl('\theta (rad)'),title=string(textoidl('\tau='),isel-lmax,textoidl('\mu s'),format='(A,I0,A)'),offx=1,pal=5,/rev,noer=isel gt lmax;,/dots


;contourn2, corr1s(*,*,isel),rho1,eta1,pos=pos,zr=[-0.02,0.02],xtitle='r/a',ytitle=textoidl('\theta (rad)'),title=string(textoidl('\tau='),isel-lmax,textoidl('\mu s'),format='(A,I0,A)'),offx=1,pal=-2,noer=isel gt lmax,/cb,inhibit=isel ne (lmax+123)

xtitle1='r/a'
ytitle1=textoidl('\theta (rad)')
xtitle=''
ytitle=''
if n_elements(xtickname) ne 0 then dum=temporary(xtickname)
if n_elements(ytickname) ne 0 then dum=temporary(ytickname)
if cnt eq 0 then ytitle = ytitle1
if cnt eq 2 then ytitle = ytitle1
if cnt eq 2 then xtitle = xtitle1
if cnt eq 3 then xtitle = xtitle1
if cnt eq 0 or cnt eq 1 then xtickname=replicate(' ',6)
if cnt eq 1 or cnt eq 3 then ytickname=replicate(' ',6)
cnt++
contourn2, corr1s(*,*,isel),rho1,eta1,pos=pos,zr=[-0.02,0.02],xtitle=xtitle,ytitle=ytitle,title=string(textoidl('\tau='),isel-lmax,textoidl('\mu s'),format='(A,I0,A)'),offx=1,pal=-2,noer=isel gt lmax,/cb,inhibit=isel ne (lmax+123),xtickname=xtickname,ytickname=ytickname

pos=posarr(/next)
oplot,rho(ii),eta(ii),psym=8,symsize=.25
;plot,eta1,corr1(iw,*,isel),pos=posarr(/next),/noer
;oplot,eta1,0.03 + 0.02 * cos(3 * eta1),col=2
;adum='' & read,'',adum
endfor

endfig,/jp,/gs
stop

xr=[-164,164]*1.5
zr=[0,.06]
;mkfig,'~/tex/ishw/thist_cor.eps',xsize=8,ysize=4.5,font_size=8
;iw=30;5
tee=findgen(2*lmax+1)-lmax
imgplot,transpose(reform(corr1(iw,*,*))),tee,eta1,/cb,xr=xr,pal=5,xtitle=textoidl('\tau (\mu s)'),ytitle=textoidl('\theta (rad)'),offx=1.,pos=posarr(1,1,0,cnx=0.15,cny=0.1,fy=0.7)
stop


iw=14;29;14;20;25;iw=30

mkfig,'~/tex/ishw/thist_cor.eps',xsize=8,ysize=4.5,font_size=8

;mkfig,'~/tex/ishw/thist_cor.eps',xsize=8,ysize=9,font_size=8

pos=posarr(1,1,0,cnx=0.15,cny=0.1,fy=0.7)
;pos=posarr(1,2,0,cnx=.15,cny=.1)
contourn2,transpose(reform(corr1s(iw,*,*))),tee,eta1,/cb,xr=xr,pal=-2,xtitle=textoidl('\tau (\mu s)'),ytitle=textoidl('\theta (rad)'),offx=1.,pos=pos,yr=[0,1.25],ysty=1,title='r/a='+string(rho1(iw),format='(F4.2)')

;,pos=posarr(1,1,0,cnx=0.15,cny=0.1,fy=0.7)
;iw=29
;contourn2,transpose(reform(corr1s(iw,*,*))),tee,eta1,/cb,xr=xr,pal=-2,xtitle=textoidl('\tau (\mu s)'),ytitle=textoidl('\theta (rad)'),offx=1.,pos=posarr(/next),/noer,yr=[0,1.5],ysty=1,title='r/a='+string(rho1(iw),format='(F4.2)')

;imgplot,trial,tee,eta1,pos=posarr(/next),/noer,/cb,xr=xr,zr=zr
endfig,/gs,/jp


end

