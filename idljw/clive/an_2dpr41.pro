@fppos
@pr_prof2
;goto,ee
path=getenv('HOME')+'/idl/clive/settings/'&file='log_probe_run41.csv'
readtextc,path+file,data0,nskip=0
sh=data0[0,1:*]
kap=data0[1,1:*]
rbp=data0[2,1:*]

rad=data0[3,1:*]
th=data0[4,1:*]
sel=data0[5,1:*]
idx=where(sh ne '')
sh=sh(idx)
sh=long(sh)
rad=float(rad(idx))
th=float(th(idx))
rbp=float(rbp(idx))
kap=float(kap(idx))
sel=float(sel(idx))
idx=where(sel eq 4);kap eq 0.83 );and rbp eq 1.33)
;stop
rbp=rbp(idx)
kap=kap(idx)
rad=rad(idx)
th=th(idx)
sh=sh(idx)


;stop


nsh=n_elements(sh)
coh=complexarr(nsh)

;frng=[200e3,300e3]
;frng=[100e3,200e3]
;frng=[50e3,100e3]
frng=[10e3,50e3]
for i=0,nsh-1 do begin
;doit,sh(i),frng=frng,coh1=coh1dum
;doit,sh(i);,frng=frng,coh1=coh1dum
coh1dum= getpar( sh(i), 'isatfork', tw=[.03,.04],y=y,st=st)
;if i eq 0 then plot, y.t,y.v else oplot,y.t,y.v,col=i+1

;stop
coh(i)=coh1dum

endfor
;stop
ee:
r=fltarr(nsh)
z=fltarr(nsh)
for i=0,nsh-1 do begin
   fppos,rad(i),th(i),rdum,zdum
   r(i)=rdum & z(i)=zdum
endfor



; contourn2,float(coh),rad,th,/irr,/dots,pal=-2,pos=posarr(3,2,0),/cb
; contourn2,imaginary(coh),rad,th,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/cb
; contourn2,abs(coh),rad,th,/irr,/dots,pos=posarr(/next),/noer,/cb

rf=(read_ascii('~/r1_new.csv',delim=',')).(0)*1000
zf=(read_ascii('~/z1_new.csv',delim=',')).(0)*1000
rhof=(read_csv('~/rho1_new.csv')).(0)

rhof=sqrt(rhof)
vw=[0.5,1.0]

; contourn2,abs(coh),r,z,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb

;plot,rf,zf,/nodata,xr=[1200,1360],yr=[0,250]
 contourn2,imaginary(coh),r,z,/irr,/dots,pal=-2,/iso,/cb,xr=[1200,1360],yr=[0,250]

 for i=0,1 do begin
   i2=value_locate(rhof,vw(i))
   oplot,rf(i2,*),zf(i2,*),col=2
endfor
oplot,r,z,psym=4

stop
plot,th,abs(coh)       
stop
 plot,th,atan2(coh)

;; contourn2,imaginary(coh),r,z,/irr,/dots,pal=-2,pos=posarr(/next),/noer,/iso,/cb
;; for i=0,1 do begin
;;    i2=value_locate(rhof,vw(i))
;;    oplot,rf(i2,*),zf(i2,*),col=2
;; endfor

;; contourn2,abs(coh),r,z,/irr,/dots,pos=posarr(/next),/noer,/iso,/cb
;; for i=0,1 do begin
;;    i2=value_locate(rhof,vw(i))
;;    oplot,rf(i2,*),zf(i2,*),col=2
;; endfor
 end

