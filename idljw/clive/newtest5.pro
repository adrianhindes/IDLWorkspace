;goto,ee
nimg=16
;iarr=[3,intspace(0,14)];*3
nimg=24;34
iarr=[intspace(0,33)]
iarr=[shift(intspace(0,23),0*4),intspace(24,33)]
for i=0,nimg-1 do begin
    r=101;89;84                        ;80;81
;i=0
    mode='amp'
    img=getimg(r,index=iarr(i))
;imgplot,img
    sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
          filt:{type:'hat'},$
          aoffs:60.,$
          c1offs:180+180,$
          c2offs:0+180,$
          c3offs: 0,$
          fracbw:1.0,$
          pixfringe:10,$
          typthres:'win',$
          thres:0.1}
    doplot=0
    demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=1. ,save={txt:'run',shot:r,ix:iarr(i)},downsamp=sets.pixfringe,override=doplot eq 1;,linalong=45*!dtor;,/noopl
;limg=total(img,2)
    
    if i eq 0 then begin
        outsr=outs
        sz=size(outs.c1,/dim)
        ph1s=fltarr(sz(0),sz(1),nimg)
        ph2s=ph1s
        phxs=ph1s
        circ1s=fltarr(sz(0),sz(1),nimg)
        circ2s=circ1s
        circxs=circ1s

        outss=replicate(outs,nimg)
;        continue
    endif
    outss(i)=outs
    if mode eq 'phase' then begin
        c1c=outs.c1/outsr.c1
        c2c=outs.c2/outsr.c2
        ph1=atan2(c1c)
        ph2=atan2(c2c)
        phx=(ph1-ph2)/2.
        if i eq 0 then phx(0,0)=1.
    endif
    if mode eq 'amp' then begin
        c1c=outs.c1/outsr.c1
        c2c=outs.c2/outsr.c2
        c3c=outs.c3/outsr.c3

        sc1c = float(c1c)/abs(float(c1c));*0+1
        sc2c = float(c2c)/abs(float(c2c));*0+1
        sc3c = float(c3c)/abs(float(c3c));*0+1
        
        ph1=atan(abs(outs.c3) * sc3c,2*abs(outs.c1)*sc1c)
        ph2=atan(abs(outs.c3) * sc3c,2*abs(outs.c2)*sc2c)
        phx=atan(abs(outs.c3) * sc3c,(abs(outs.c1)*sc1c + abs(outs.c2)*sc2c) )


        circ1=atan2(c1c);*sc1c)
        circ2=atan2(c2c);*sc2c)
        circx=(circ1+circ2)/2.

    endif

    pos=posarr(3,1,0)
    zrr=[-.1,.1]
    icx=sz(0)*0.5
    icy=sz(1)*0.5
    imgplot,ph1-ph1(icx,icy),pos=pos,/cb,title=i*7.5,zr=zrr,pal=-2
    imgplot,ph2-ph2(icx,icy),/noer,pos=posarr(/next),/cb,zr=zrr,pal=-2
    imgplot,phx-phx(icx,icy),/noer,pos=posarr(/next),/cb,zr=zrr,pal=-2
    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    phxs(*,*,i)=phx

    circ1s(*,*,i)=circ1
    circ2s(*,*,i)=circ2
    circxs(*,*,i)=circx

;a=''&read,'',a
;    stop
endfor
ee:

ix=sz(0)*0.5
iy=sz(1)*0.5


zfit=intspace(0,nimg-1) / 24. * 2 * !pi ;linspace(0,2*!pi,25)
;plot,zfit*!radeg,

ph1t=phs_jump(ph1s(ix,iy,*))*!radeg
circ1t=circ1s(ix,iy,*)*!radeg
circ2t=circ2s(ix,iy,*)*!radeg
plot,zfit*!radeg,deriv(zfit*!radeg,ph1t),psym=-4

retall

;zz=rebin(ph1s,86,65,50)
ax=5
ay=5
zz=congrid(ph1s,ax,ay,nimg)
zz2=congrid(ph2s,ax,ay,nimg)
zzr=transpose(reform(zz,ax*ay,nimg))
zzr2=transpose(reform(zz2,ax*ay,nimg))
for i=0,ax*ay-1 do zzr(*,i)=phs_jump(zzr(*,i))
for i=0,ax*ay-1 do zzr2(*,i)=phs_jump(zzr2(*,i))
;plotm,zz
z=phs_jump(ph1s(ix,iy,*))
z2=phs_jump(ph2s(ix,iy,*))
plot,z
ix=indgen(n_elements(z))
ii=intspace(0,24)
dum=linfit(ix(ii),z(ii),yfit=zfit)
zfit=dum(0)+ix*dum(1)
zfit=intspace(0,nimg-1) / 24. * 2 * !pi ;linspace(0,2*!pi,25)
zfit(32:*)=0.
oplot,zfit,col=2
plot,z-zfit,yr=[-.1,.1]
zfit2=zfit#replicate(1,ax*ay)
plotm,(zzr-zzr2)/2.-zfit2,yr=[-.3,.3]/3
;oplot,-z2,col=2
;plot,(z+z2)/2-zfit


end
