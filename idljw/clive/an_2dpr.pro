@fppos
@pr_prof2
;goto,ee
path=getenv('HOME')+'/idl/clive/settings/'&file='log_probe_run6.csv'
readtextc,path+file,data0,nskip=0
sh=data0[0,1:*]
rad=data0[1,1:*]
th=data0[2,1:*]
idx=where(sh ne '')
sh=sh(idx)
sh=long(sh)
rad=float(rad(idx))
th=float(th(idx)) -0.7


nsh=n_elements(sh)
coh=complexarr(nsh)

;frng=[200e3,300e3]
frng=[100e3,200e3]
;frng=35e3+[-1,1]*15e3/2
;frng=10e3+[-1,1]*5e3/2
;frng=[1e3,5e3]

;frng=[50e3,100e3]doi
;frng=[10e3,50e3]
;frng=[10e3,100e3]

;dum=temporary(frng)
for i=0,nsh-1 do begin
doit,sh(i),frng=frng,coh1=coh1dum,tr=[0.02,0.03]+0.01,mode='isat'
;continue
;coh1dum= getpar( sh(i), 'isatfork', tw=[.03,.04],y=y,st=st)
;coh1dum= getpar( sh(i), 'vfloatfork', tw=[.03,.04],y=y,st=st)

coh(i)=coh1dum

endfor
ee:
r=fltarr(nsh)
z=fltarr(nsh)
for i=0,nsh-1 do begin
   fppos,rad(i),th(i),rdum,zdum
   r(i)=rdum & z(i)=zdum
endfor
radx=rad
thx=th
contourn2,float(coh),radx,thx,/irr,/dots,pal=-2,pos=posarr(3,1,0),/cb
contourn2,imaginary(coh),radx,thx,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/cb
contourn2,abs(coh),radx,thx,/irr,/dots,pos=posarr(/next),/noer,/cb

stop
 
rf=(read_ascii('~/r1_new.csv',delim=',')).(0)*1000
zf=(read_ascii('~/z1_new.csv',delim=',')).(0)*1000
rhof=(read_csv('~/rho1_new.csv')).(0)




rhof=sqrt(rhof)
vw=[0.2,0.8,1.0]
nv=n_elements(vw)

;mkfig,'~/pcoh1.eps',xsize=23,ysize=14,font_size=9
contourn2,float(coh),r,z,/irr,/dots,pal=-2,pos=posarr(3,1,0,cny=0.1),/iso,/cb,xtitle='R(m)',ytitle='Z(m)',title='Real part'

for i=0,nv-1 do begin
   i2=value_locate(rhof,vw(i))
   oplot,rf(i2,*),zf(i2,*),col=2
endfor


contourn2,imaginary(coh),r,z,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb,xtitle='R(m)',ytitle='Z(m)',title='Imaginary part'
for i=0,nv-1 do begin
   i2=value_locate(rhof,vw(i))
   oplot,rf(i2,*),zf(i2,*),col=2
endfor

contourn2,abs(coh),r,z,/irr,/dots,pos=posarr(/next),/noer,/iso,/cb,xtitle='R(m)',ytitle='Z(m)',title='Absolute value'
for i=0,nv-1 do begin
   i2=value_locate(rhof,vw(i))
   oplot,rf(i2,*),zf(i2,*),col=2
endfor
stop
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
pos=posarr(3,2,0,cny=0.1,cnx=0.1);/next)
contourn2,float(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=pos,/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Real part, meas'


contourn2,imaginary(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Imaginary part, meas'

contourn2,abs(coh(ii))/nfact,rho(ii),eta(ii),/irr,/dots,pos=posarr(/next),/noer,/iso,/cb,offx=1,xtitle='r/a',ytitle=textoidl('\theta'),title='Absolute value, meas'
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

