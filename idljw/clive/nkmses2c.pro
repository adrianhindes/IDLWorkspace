dtframe={v: 1./40.*1000}



doplot=0

;prer=''&sh=8049&idxarr=[175]&nimg=1 & shref=8014&idxref=150 & prerref='' & coff=-30.

;prer=''&sh=8049&idxarr=[175]&nimg=1 & shref=8054&idxref=200 & prerref='' & coff=+75

;prer=''&sh=1604&idxarr=[39]&nimg=1 & shref=1605&idxref=39 & prerref='' & coff=0.

;prer=''&sh=1604&idxarr=[39]&nimg=1 & shref=1610&idxref=0 & prerref='' & coff=5;;compare old cal with cir cwith new cal with circ

;prer=''&sh=1607&idxarr=[0]&nimg=1 & shref=1608&idxref=0 & prerref='' & coff=5;;compare change focus with not change focus

;prer=''&sh=1614&idxarr=[0]&nimg=1 & shref=1610&idxref=0 & prerref='' & coff=-15;;this one is rot stage compared with big circ

;prer=''&sh=1609&idxarr=[0]&nimg=1 & shref=1610&idxref=0 & prerref='' & coff=-8;;this one is small circ(backwards) compared with big circ

;prer=''&sh=1615&idxarr=[0]&nimg=1 & shref=1614&idxref=0 & prerref='' & coff=20+12-6;;this one not proper filt vs proper filt


;prer=''&sh=1622&idxarr=[0]&nimg=1 & shref=1620&idxref=0 & prerref='' & coff=0;640 and 659 rougly

prer=''&sh=1624&idxarr=[0]&nimg=1 & shref=1625&idxref=0 & prerref='' & coff=0;653 and 659 rougly

;;;prer=''&sh=1623&idxarr=[0]&nimg=1 & shref=1624&idxref=0 & prerref='' & coff=0;650 and 653 rougly


;prer=''&sh=8049&idxarr=[175]&nimg=1 & shref=1605&idxref=39 & prerref='' & coff=20.

;prer=''&sh=8052&idxarr=[155]&nimg=1 & shref=8054&idxref=200 & prerref='' & coff=+75


;prer=''&sh=8052&idxarr=[35]&nimg=1 & shref=1605&idxref=39 & prerref='' & coff=20.-7


;prer=''&sh=8049&idxarr=[175]&nimg=1 & shref=1604&idxref=39 & prerref='' & coff=20.


;prer='c'&sh=8049&idxarr=[175]&nimg=1 & shref=8054&idxref=200 & prerref='c' & coff=-30.+90
;prer='c'&sh=8049&idxarr=[100]&nimg=1 & shref=1605&idxref=39 & prerref='' & coff=12.
;prer='c'&sh=8049&idxarr=[175]&nimg=1 & shref=1604&idxref=39 & prerref='' & coff=12.

;prer=''&sh=8054&idxarr=[200]&nimg=1 & shref=1605&idxref=39 & prerref='' & coff=-65.
;prer=''&sh=8014&idxarr=[150]&nimg=1 & shref=1605&idxref=39 & prerref=''&coff=40.

;prer=''&sh=8018&idxarr=[200]&nimg=1 & shref=1605&idxref=39 & prerref=''&coff=20.

;prer=''&sh=8054&idxarr=[200]&nimg=1 & shref=1605&idxref=39 & prerref=''&coff=-60.



rarr=replicate(sh,nimg)

nimg=nimg+1

idxarr=[idxref,idxarr]
rarr=[shref,rarr]

prearr=[prerref,replicate(prer,nimg-1)]


idxarrd=idxarr & idxarrd(0)=0

;tmy=(idxarrd+0.5) * dtframe.v/1000. + t0
;tr=minmax(tmy)
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
plot,phss(*,ny/2,i)*!radeg,pos=posarr(/next),title='phs and d',/noer,yr=[-180,180];,yr=[-20,20]
oplot,phds(*,ny/2,i)*!radeg,col=2



xyouts,0.5,0.95,string(prearr(i),rarr(i),idxarr(i)),ali=0.5,/norm
stop
ee:
;stop
endfor


sum=phss(*,*,1)
dif=phds(*,*,1)
;sum=phds(*,*,1)
;dif=phss(*,*,1)
;imgplot,sum,pos=posarr(2,1,0)
;imgplot,diff,pos=posarr(/next),/noer
imgplot,dif*!radeg,/cb,pos=posarr(2,1,0),pal=-2
ang=(sum*!radeg+180*0)/2 + coff  ;;-25 +10. + 90.
imgplot,ang,/cb,zr=[-30,30],pos=posarr(/next),/noer,pal=-2
print,'hey'
stop
plot,ang(*,220),yr=[-10,10]
;wait,3
;plot,ang(*,200),yr=[-30,30]
  
end
 
