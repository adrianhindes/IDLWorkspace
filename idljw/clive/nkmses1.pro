
if n_elements(skip) ne 0 then if skip eq 1  then goto,noload
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
t0=-0.1
sh=8046
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
prer='' & r=sh


dum=file_search('~/tmp/demod/'+prer+'*'+string(sh,format='(I0)')+'*',count=nimg)
idxarr=intarr(nimg)
cnt=0
for i=0,nimg-1 do begin
    spl=strsplit(dum(i),'/',/extract)&    nspl=n_elements(spl)
    if prer eq '' then isel=1 else isel=2
    num=(strsplit(spl(nspl-1) ,'_.',/extract))[isel]
;    print,num
    if strlen(num) gt 3 then continue
    idxarr(cnt)=fix(num)
    cnt=cnt+1

endfor
nimg=cnt
idxarr=idxarr(0:nimg-1)

idxarr=idxarr(sort(idxarr))

if nimg gt 100 then begin
ds=floor(nimg/100.)
nimg=nimg/ds
idxarr=idxarr(indgen(nimg)*ds)

endif

;idxarr=intspace(0,49)*4 & nimg=50
;idxarr=intspace(0,99) & nimg=100

rarr=replicate(sh,nimg)
;44,46,47,48,49
nimg=nimg+1
;idxarr=[43,idxarr]
;rarr=[8018,rarr]


idxarr=[35]
rarr=[8044]
prearr=['']
nimg=2

idxarr=[300,idxarr]
rarr=[8054,rarr]

prearr=['',replicate(prer,nimg-1)]


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

    ph1o=ph1
    ph2o=ph2
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

if i eq 0 then continue
;goto,ee
pos=posarr(2,3,0)&zr=[0,1]
imgplot,a1s(*,*,i),pos=posarr(/curr),/cb,title='a1'
imgplot,a2s(*,*,i),pos=posarr(/next),/cb,title='a2',/noe
;imgplot,ph1s(*,*,i),pos=posarr(/next),/cb,title='ph1',/noer
;imgplot,ph2s(*,*,i),pos=posarr(/next),/cb,title='ph2',/noer
ny=n_elements(ph1s(0,*,0))
plot,ph1s(*,ny/2,i)*!radeg,pos=posarr(/next),title='ph1 and 2',/noer,$
  yr=[-360,0]
oplot,ph2s(*,ny/2,i)*!radeg,col=2
ang=(phss(*,*,i)*!radeg+180)/2 - 25 + 20
plot,ang(*,ny/2),pos=posarr(/next),title='phs and d',/noer,yr=[0,50]

contourn2,ang,zr=[0,30],/cb,pos=posarr(/next),/noer,title='ang'
;oplot,phds(*,ny/2,i)*!radeg,col=2



xyouts,0.5,0.95,string(prearr(i),rarr(i),idxarr(i)),ali=0.5,/norm
stop
ee:
;stop
endfor
noload:
end

