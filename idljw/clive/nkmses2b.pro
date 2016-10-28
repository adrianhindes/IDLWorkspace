
;if n_elements(skip) ne 0 then if skip eq 1  then goto,noload
;sh=7366&t0=0.0
;sh=7348 &t0=0.0 & tr=[1,9];[-1,9] ; first shot
;sh=7426 &t0=0.0 & tr=[0,9];[-1,9] ; one beam only before muck
;sh=7427 &t0=0.0 & tr=[0,9];[-1,9]  ; one beam only, 2:8

;sh=7431 &t0=0.0 & tr=[0,9];[-1,9]  ; hmode
;sh=7434 &t0=0.0 & tr=[0,9];[-1,9]  ; one beam only, supposedly better?

;sh=7357 &t0=0.0 & tr=[0,9];[-1,9]  ; polarizer in 45
;sh=7358 &t0=0.0 & tr=[0,9];[-1,9]  ; polarizer in 50 ;verified ang2
;changes an ang 1 is quite nonzero

;sh=7489 &t0=0.0 & tr=[0,9];[-1,9]  ; first shot, circular w jogs
;sh=7526 & 
t0=0.0  ; monday first acquired shot (many missed0.r nkmsea
;

sh=8018

t0=-0.1
if sh ge 8047 then tstart =-0.095
if sh ge 8049 then tstart =-0.09
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
dtframe={v: 1./40.*1000}



doplot=0


;retall

r=0
;prec='c' & rc=1201 & prei=0
prer='c' & r=sh

;sh=8018&idxarr=[43] & nimg=n_elements(idxarr)
;sh=8054&idxarr=[300] & nimg=n_elements(idxarr)
sh=8046&idxarr=[100]&nimg=1
;sh=8015&idxarr=[41]&nimg=1

;idxarr=intspace(0,49)*4 & nimg=50
;idxarr=intspace(0,99) & nimg=100

rarr=replicate(sh,nimg)

nimg=nimg+1
;idxarr=[0,idxarr]
;rarr=[1605,rarr]

;idxarr=[300,idxarr]
;rarr=[8054,rarr]

idxarr=[150,idxarr]
rarr=[8014,rarr]

prearr=['c',replicate(prer,nimg-1)]


idxarrd=idxarr & idxarrd(0)=0

tmy=(idxarrd+0.5) * dtframe.v/1000. + t0
tr=minmax(tmy)
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
        phss=ph1s
        phds=ph1s
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

    jumpimg,ph1
    jumpimg,ph2

    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    ph3s(*,*,i)=ph3
    phss(*,*,i)=(ph1+ph2)*0.5
    phds(*,*,i)=(ph1-ph2)*0.5

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
print, 'done ',i,' of',nimg


;goto,ee
pos=posarr(2,3,0)&zr=[0,1]
imgplot,a1s(*,*,i),pos=posarr(/curr),/cb,title='a1'
imgplot,a2s(*,*,i),pos=posarr(/next),/cb,title='a2',/noe
if i eq 0 then continue

imgplot,ph1s(*,*,i),pos=posarr(/next),/cb,title='ph1',/noer
imgplot,ph2s(*,*,i),pos=posarr(/next),/cb,title='ph2',/noer
ny=n_elements(ph1s(0,*,0))
plot,ph1s(*,ny/2,i)*!radeg,pos=posarr(/next),title='ph1 and 2',/noer;,yr=[-20,20]
oplot,ph2s(*,ny/2,i)*!radeg,col=2
plot,phss(*,ny/2,i)*!radeg,pos=posarr(/next),title='phs and d',/noer;,yr=[-20,20]
oplot,phds(*,ny/2,i)*!radeg,col=2



xyouts,0.5,0.95,string(prearr(i),rarr(i),idxarr(i)),ali=0.5,/norm
;stop
ee:
;stop
endfor


sum=phss(*,*,1)
dif=phds(*,*,1)
;imgplot,sum,pos=posarr(2,1,0)
;imgplot,diff,pos=posarr(/next),/noer
imgplot,dif*!radeg,/cb,pos=posarr(2,1,0)
ang=(sum*!radeg+180*0)/2 -25;+10.
imgplot,ang,/cb,zr=[-30,30],pos=posarr(/next),/noer,pal=-2
;plot,ang(*,200),yr=[-30,30]
 
end
