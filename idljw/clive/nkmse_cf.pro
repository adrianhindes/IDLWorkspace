
;sh=7366&t0=0.0
;sh=7348 &t0=0.0 & tr=[1,9];[-1,9] ; first shot
;sh=7426 &t0=0.0 & tr=[0,9];[-1,9] ; one beam only before muck
sh=7427 &t0=0.0 & tr=[0,9];[-1,9]  ; one beam only, 2:8

;sh=7430 &t0=0.0 & tr=[0,9];[-1,9]  ; hmode
;sh=7434 &t0=0.0 & tr=[0,9];[-1,9]  ; one beam only, supposedly better?

;sh=7357 &t0=0.0 & tr=[0,9];[-1,9]  ; polarizer in 45
;sh=7358 &t0=0.0 & tr=[0,9];[-1,9]  ; polarizer in 50 ;verified ang2
;changes an ang 1 is quite nonzero

;if n_elements(ip) gt 0 then goto,aa1
spawn,'hostname',host
if host ne 'ikstar.nfri.re.kr' then mdsconnect,'172.17.250.100:8005'
mdsopen,'kstar',sh
;nbi=mdsvalue('\NB1_PB1')
;tnbi=mdsvalue('DIM_OF(\NB1_PB1)')
nbi1=cgetdata('\NB11_I0')
nbi2=cgetdata('\NB12_I0')
ip=cgetdata('\PCRC03')

mdsdisconnect


aa1:

mdsopen,'mse',sh
flc0=cgetdata('.DAQ.DATA:FLC_0')
flc1=cgetdata('.DAQ.DATA:FLC_1')
dtframe=cgetdata('.SENSICAM.TIMING.FRAME_TIME')
nimg=cgetdata('.SENSICAM.TIMING.NUM_IMAGES')

bpat={$
hbin:fix(strmid((cgetdata('.SENSICAM.SETTINGS.H_BIN')).v,3,1)),$
vbin:fix(strmid((cgetdata('.SENSICAM.SETTINGS.V_BIN')).v,3,1)),$
x1:(cgetdata('.SENSICAM.SETTINGS.ROI_LEFT')).v,$
x2:(cgetdata('.SENSICAM.SETTINGS.ROI_RIGHT')).v,$
Y1:(cgetdata('.SENSICAM.SETTINGS.ROI_BOTTOM')).v,$
Y2:(cgetdata('.SENSICAM.SETTINGS.ROI_TOP')).v}


;plot,flc0.t,flc0.v,xr=[0,.5]
;oplot,tmy,fflc0,psym=4,col=2




f=fft_t_to_f(flc1.t)
s=abs(fft(flc1.v))
iz=value_locate(f,[5,500.])
dum=max(s(iz(0):iz(1)),imax) & imax+=iz(0)
freq=f(imax)
;plot,flc1.t,flc1.v
;retall
dtframe2=1/freq/2
print,'dtframe=',dtframe.v
print,'dtframe2=',dtframe2*1000
if abs( 1 - dtframe.v/(dtframe2*1000)) lt 0.1 then begin
;if 1 eq 1 then begin
    dtframe.v=dtframe2*1000
    print,'set from dtframe2'
endif
wait,1


;fflc0=


doplot=0


;retall

r=0
;prec='c' & rc=1201 & prei=0
prer='c' & r=sh


;prearr=[replicate(prer,nimg)]
;rarr=[prer,replicate(r,nimg)]
;idxarr=[prei,indgen(nimg)+2]
nimg=nimg.v
prearr=[replicate(prer,nimg)]
rarr=[replicate(r,nimg)]
idxarr=[50,indgen(nimg)]

idxarrd=idxarr & idxarrd(0)=0
tmy=(idxarrd+0.5) * dtframe.v/1000. + t0

flc0.t-=flc0.t(0)
flc1.t-=flc1.t(0)
fflc0=interpol(flc0.v,flc0.t,tmy-t0)
fflc1=interpol(flc1.v,flc1.t,tmy-t0)



for i=0,nimg-1 do begin

demodcs, img,outs, doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},override=doplot eq 1
;limg=total(img,2)
;    stop
    if i eq 0 then begin
        outsr=outs
        sz=size(outs.c1,/dim)
        ph1s=fltarr(sz(0),sz(1),nimg)
        ph2s=ph1s
        ph3s=ph1s
;        ph5s=ph1s
        a1s=fltarr(sz(0),sz(1),nimg)
        a2s=a1s
        a3s=a1s
;        a5s=a1s
        a4s=a1s
        
        outss=replicate(outs,nimg)
;        continue
    endif
    outss(i)=outs

    ph1=atan2(outs.c1/outsr.c1)
    ph2=atan2(outs.c2/outsr.c2)
    ph3=atan2(outs.c3/outsr.c3)
;    ph5=atan2(outs.c5/outsr.c5)

    a1=abs(outs.c1)/abs(outs.c4)*2
    a2=abs(outs.c2)/abs(outs.c4)*2
    a3=abs(outs.c3)/abs(outs.c4)*2
;    a5=abs(outs.c5)/abs(outs.c4)

    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    ph3s(*,*,i)=ph3
;    ph5s(*,*,i)=ph5

    a4s(*,*,i)=abs(outs.c4)
    a1s(*,*,i)=a1
    a2s(*,*,i)=a2
    a3s(*,*,i)=a3
;    a5s(*,*,i)=a5
;    if i gt 0 then begin
;        a1s(*,*,i)/=a1s(*,*,0)
;        a2s(*,*,i)/=a2s(*,*,0)
;        a3s(*,*,i)/=a3s(*,*,0)
;        a5s(*,*,i)/=a5s(*,*,0)
;    endif
goto,ee
pos=posarr(2,2,0)&zr=[0,1]
imgplot,a1s(*,*,i),pos=posarr(/curr),/cb,title='a1'
imgplot,a4s(*,*,i),pos=posarr(/next),/cb,title='a4',/noe
imgplot,ph1s(*,*,i),pos=posarr(/next),/cb,title='ph1',/noer
xyouts,0.5,0.95,string(prearr(i),rarr(i),idxarr(i)),ali=0.5,/norm
ee:
;stop
endfor

; ph1sa=ph1s
; ph1sb=ph1s


; ph1ss=ph1s
; ph1sd=ph1s


; for i=0,nimg/2-1 do begin
; ph1sd(*,*,2*i+0)=(ph1s(*,*,2*i) - ph1s(*,*,2*i+1)) 
; ph1ss(*,*,2*i+0)=(ph1s(*,*,2*i) + ph1s(*,*,2*i+1)) 
; ph1sd(*,*,2*i+1)=ph1sd(*,*,2*i+0)
; ph1ss(*,*,2*i+1)=ph1ss(*,*,2*i+0)
; endfor


; for i=0,nimg/4-1 do begin
; ph1sa(*,*,4*i+0)=(ph1s(*,*,4*i) - ph1s(*,*,4*i+2)) / $
;                  (ph1s(*,*,4*i) + ph1s(*,*,4*i+2))
; ph1sa(*,*,4*i+1)=ph1sa(*,*,4*i+0)
; ph1sa(*,*,4*i+2)=ph1sa(*,*,4*i+0)
; ph1sa(*,*,4*i+3)=ph1sa(*,*,4*i+0)

; ph1sb(*,*,4*i+0)=ph1s(*,*,4*i+1) - ph1s(*,*,4*i+3) / $
;                  (ph1s(*,*,4*i+1) + ph1s(*,*,4*i+3))
; ph1sb(*,*,4*i+1)=ph1sb(*,*,4*i+0)
; ph1sb(*,*,4*i+2)=ph1sb(*,*,4*i+0)
; ph1sb(*,*,4*i+3)=ph1sb(*,*,4*i+0)
; endfor

;flc 0 is qwp,flc1 is hwp
;so ia1/ib1 are paired for fflc positive
;so ia2/ib2 are paired for fflc negative

ia1=where(fflc0 gt 0 and fflc1 gt 0)
ib1=where(fflc0 gt 0 and fflc1 lt 0)
ia2=where(fflc0 lt 0 and fflc1 gt 0)
ib2=where(fflc0 lt 0 and fflc1 lt 0)

if ia2(0) eq -1 then ia2=ia1
if ib2(0) eq -1 then ib2=ib1

if ia1(0) eq -1 then ia1=ia2
if ib1(0) eq -1 then ib1=ib2


a1sia1=a1s(*,*,ia1)
a1sia2=a1s(*,*,ia2)
a1sib1=a1s(*,*,ib1)
a1sib2=a1s(*,*,ib2)

a4sia1=a4s(*,*,ia1)
a4sia2=a4s(*,*,ia2)
a4sib1=a4s(*,*,ib1)
a4sib2=a4s(*,*,ib2)




ang1=ph1s(*,*,ia1)-ph1s(*,*,ib1)
ds1=ph1s(*,*,ia1)+ph1s(*,*,ib1)

ang1/=4
ang2=ph1s(*,*,ia2)-ph1s(*,*,ib2)
ang2/=4
ang2-=16*!dtor
ds2=ph1s(*,*,ia2)+ph1s(*,*,ib2)

tmy22=tmy(ia2)
tmy21=tmy(ia1)


nx=n_elements(a4s(*,0,0))
ny=n_elements(a4s(0,*,0))
;plot,a4s(112/2,95/2,*),psym=4
a4s(*,*,0)=0.

ax=40
ay=ny/2
plot,ip.t,-ip.v,xr=tr
plot,nbi1.t,nbi1.v,xr=!x.crange,col=2,/noer
;plot,nbi2.t,nbi2.v,xr=!x.crange,col=10,/noer
plot,tmy,a4s(ax,ay,*),xr=!x.crange,col=4,/noer,psym=-4

plot,tmy21,a1sia1(ax,ay,*),xr=!x.crange,col=3,/noer,psym=-4,zr=[0,0.5]


;plot,tmy,(ph1s(ax,ay,*)),xr=!x.crange,col=5,/noer

plot,tmy21,(ang1(ax,ay,*)),xr=!x.crange,col=6,/noer,psym=-4
plot,tmy22,(ang2(ax,ay,*)),xr=!x.crange,col=7,/noer,psym=-4

plot,tmy21,(ds1(ax,ay,*)),xr=!x.crange,col=8,/noer,thick=3,psym=-4
plot,tmy22,(ds2(ax,ay,*)),xr=!x.crange,col=9,/noer,thick=3,psym=-4


cursor,dx,dy,/down
iw=value_locate(tmy,dx)
iw2=value_locate(tmy2,dx)

pos=posarr(2,3,0)
imgplot,a4sia1(*,*,iw2),pos=posarr(/curr),title='intensity'
imgplot,a1sia1(*,*,iw2),pos=posarr(/next),title='contrast',/noer,/cb

imgplot,ang1(*,*,iw2),pos=posarr(/next),/noer,title='ang1',zr=[-.2,.2]*2,pal=-2,/cb
imgplot,ang2(*,*,iw2),pos=posarr(/next),/noer,title='ang2',zr=[-.2,.2]*.5,pal=-2,/cb
imgplot,ds1(*,*,iw2),pos=posarr(/next),/noer,title='ds1',zr=[-1,1]*4,pal=-2,/cb
imgplot,ds2(*,*,iw2),pos=posarr(/next),/noer,title='ds2',zr=[-1,1]*4,pal=-2,/cb

tang1=(ang1(ax,ay,*))
tang2=(ang2(ax,ay,*))

;plot,tmy,(ph1sa(nx/2,ny/2,*)),xr=!x.crange,col=5,/noer
;plot,tmy,(ph1sb(nx/2,ny/2,*)),xr=!x.crange,col=6,/noer



end

