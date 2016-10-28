
;sh=7366&t0=0.0
;sh=7348 &t0=0.0 & tr=[1,9];[-1,9] ; first shot
;sh=7426 &t0=0.0 & tr=[0,9];[-1,9] ; one beam only before muck
;sh=7427 &t0=0.0 & tr=[0,9];[-1,9]  ; one beam only, 2:8

;sh=7431 &t0=0.0 & tr=[0,9];[-1,9]  ; hmode
;sh=7434 &t0=0.0 & tr=[0,9];[-1,9]  ; one beam only, supposedly better?

;sh=7357 &t0=0.0 & tr=[0,9];[-1,9]  ; polarizer in 45
;sh=7358 &t0=0.0 & tr=[0,9];[-1,9]  ; polarizer in 50 ;verified ang2
;changes an ang 1 is quite nonzero

;sh=7485 &t0=0.0 & tr=[0,4.8];[-1,9]  ; first shot, circular w jogs


;sh=7526 & 
;t0=0.0 & tr=[0,9] ; monday first acquired shot (many missed0.r nkmsea
;t0=-0.12

sh=7523 &t0=0.0 & tr=[0,4.8];[-1,9]  ; first shot, circular w jogs

sh=7897 & tr=[0,4.8]


sh=7484 & tr=[0,4.8]

;
;if n_elements(ip) gt 0 then goto,aa1
spawn,'hostname',host
if host ne 'ikstar.nfri.re.kr' then mdsconnect,'172.17.250.100:8005'
mdsopen,'kstar',sh
;nbi=mdsvalue('\NB1_PB1')
;tnbi=mdsvalue('DIM_OF(\NB1_PB1)')
nbi1=cgetdata('\NB11_I0')
nbi2=cgetdata('\NB12_I0')
ip=cgetdata('\PCRC03')


if host ne 'ikstar.nfri.re.kr' then mdsdisconnect


aa1:
mdsclose
mdsopen,'mse',sh
flc0=cgetdata('.DAQ.DATA:FLC_0',/norest)
flc1=cgetdata('.DAQ.DATA:FLC_1',/norest)
if sh le 7829 then begin
    dtframe=(cgetdata('.SENSICAM.TIMING.FRAME_TIME')).v / 1000 ; ms to s
    nimg=(cgetdata('.SENSICAM.TIMING.NUM_IMAGES')).v
endif else begin
    dum=getimg(sh,pre='',index=0,sm=4,info=info,/getinfo,mdsplus=0)
    nimg=info.num_images
endelse


gettim,sh=sh,tstart=t0,ft=dtframe,iidx=iidx
if n_elements(iidx) eq 0 then iidx=findgen(nimg)
idx=findgen(nimg)

nimg=nimg+1

doplot=0
prer='' & r=sh
nimg=nimg
prearr=[replicate(prer,nimg)]
rarr=[replicate(r,nimg)]
idxarr=[50,idx]
iidxarr=[50,iidx]

idxarrd=iidxarr & idxarrd(0)=0
tmy=(idxarrd+0.5) * dtframe + t0

flc0.t-=flc0.t(0)
flc1.t-=flc1.t(0)
fflc0=interpolo(flc0.v,flc0.t,tmy-t0)
fflc1=interpolo(flc1.v,flc1.t,tmy-t0)
inc=indgen(nimg-1)+1
fflc0=fflc0(inc)
fflc1=fflc1(inc)

print,'nimg=',nimg
for i=0,nimg-1 do begin
print,prearr(i),rarr(i),idxarr(i)
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


;for gas
;plot,ph1s(*,ny/2,1)/4*!radeg
;retall



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
ib2=ia2+1
;ib2=where(fflc0 lt 0 and fflc1 lt 0)

if ia2(0) eq -1 then ia2=ia1
if ib2(0) eq -1 then ib2=ib1

if ia1(0) eq -1 or sh eq 7486 then ia1=ia2
if ib1(0) eq -1 or sh eq 7486 then ib1=ib2

ia2=inc(ia2) ; reindex to consider the ones other than the first cal one
ib2=inc(ib2)
ia1=inc(ia1)
ib1=inc(ib1)


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
ang2=ph1s(*,*,ib2)-ph1s(*,*,ia2)
ang2/=4
ang2-=18*!dtor
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
plot,nbi2.t,nbi2.v,xr=!x.crange,col=10,/noer
plot,tmy,a4s(ax,ay,*),xr=!x.crange,col=4,/noer,psym=-4

plot,tmy21,a1sia1(ax,ay,*),xr=!x.crange,col=3,/noer,psym=-4,zr=[0,0.5]


;plot,tmy,(ph1s(ax,ay,*)),xr=!x.crange,col=5,/noer

plot,tmy21,(ang1(ax,ay,*)),xr=!x.crange,col=6,/noer,psym=-4
plot,tmy22,(ang2(ax,ay,*)),xr=!x.crange,col=7,/noer,psym=-4

plot,tmy21,(ds1(ax,ay,*)),xr=!x.crange,col=8,/noer,thick=3,psym=-4
plot,tmy22,(ds2(ax,ay,*)),xr=!x.crange,col=9,/noer,thick=3,psym=-4


cursor,dx,dy,/down

print,'clicked on ',dx

iw=value_locate(tmy,dx)
;iw2=value_locate(tmy2,dx)
dum=min(abs(dx-tmy22),iw2)


pos=posarr(2,3,0)
imgplot,a4sia1(*,*,iw2),pos=posarr(/curr),title='intensity'
imgplot,a1sia1(*,*,iw2),pos=posarr(/next),title='contrast',/noer,/cb

imgplot,ang1(*,*,iw2),pos=posarr(/next),/noer,title='ang1',pal=-2,/cb
imgplot,ang2(*,*,iw2),pos=posarr(/next),/noer,title='ang2',zr=[-.2,.2]*2,pal=-2,/cb
imgplot,ds1(*,*,iw2),pos=posarr(/next),/noer,title='ds1',zr=[-1,1]*4,pal=-2,/cb
imgplot,ds2(*,*,iw2),pos=posarr(/next),/noer,title='ds2',zr=[-1,1]*4,pal=-2,/cb

tang1=(ang1(ax,ay,*))
tang2=(ang2(ax,ay,*))

cursor,dx,dy,/down


;mkfig,'~/thist.eps',xsize=9,ysize=7,font_size=9

imgplot,transpose(reform(ang2(*,ay,*)))*!radeg,tmy21,indgen(n_elements(ang2(*,0,0))),/cb,pal=-2,zr=[-.2,.2]*0.95*!radeg,xr=[0,5]

;,xtitle='Time (s)',ytitle='Position across camera (super-pixels)',title='Polarization angle evolution in shot 7957',pos=posarr(1,1,0,cnx=0.1,cny=0.15)
;plot,tmy,(ph1sa(nx/2,ny/2,*)),xr=!x.crange,col=5,/noer
;plot,tmy,(ph1sb(nx/2,ny/2,*)),xr=!x.crange,col=6,/noer

endfig,/gs,/jp
;retall
cursor,dx,dy,/down
 ift=where(finite(ang2(*,ay,iw2)))
 org=(ang2(ift,ay,iw2)*4)/4
 cor=phs_jump(ang2(ift,ay,iw2)*4)/4
 nn=n_elements(org)/2
 cor2 = cor - cor(nn) + org(nn)
 plot,cor2*!radeg,psym=-4;,yr=[0,40]
plot,a1sia1(ift,ay,iw2),yr=[0,1],col=2,/noer
plot,a4sia1(ift,ay,iw2),col=4,/noer
print,'mean angle 20 to 40 is'
print,mean(cor2(20:40))*!radeg
end

