if n_elements(nbi) gt 0 then goto,aa1
mdsconnect,'172.17.250.100:8005'
mdsopen,'kstar',7266
;nbi=mdsvalue('\NB1_PB1')
;tnbi=mdsvalue('DIM_OF(\NB1_PB1)')
nbi=cgetdata('NB1_PB1')
ip=cgetdata('PCRC03')

aa1:


doplot=0


sets1={win:{type:'sg',sgmul:1.2,sgexp:10},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75+22.5+1.,$   
      c1offs:-12,$
        c2offs:12,$
        c3offs: 0.,$
        fracbw:0.4,$
        pixfringe:5.4*105/50.,$        
        typthres:'win',$
        thres:0.1}             

noload=1
r=0
prec='edge_cal_sumd' & sets=sets1
prer='c' & r=7274;66;4

nimg=99
prearr=[prec,replicate(prer,nimg-1)]
rarr=[0,replicate(r,nimg-1)]
;;idxarr=[0,5,7,20,40,60,80,99]
idxarr=[0,3,4,5,6,7,8,9,10];
idxarr=[0,50];indgen(198)+2]
nonumarr=[2,replicate(0,nimg-1)]
smarr=[2,replicate(1,nimg-1)]

for i=0,nimg-1 do begin

if noload eq 0 then begin
    img=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=idxarr(i),sm=smarr(i)) ;/16
    
    if i gt 0 then begin
        imgz=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=1,sm=smarr(i)) ;/16
        img-=imgz
    endif
endif else begin
    img=0
endelse

demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.16,r5fac=0.6,/dofifth,plotwin=0;,linalong=1;,/noopl
;limg=total(img,2)
;    stop
    if i eq 0 then begin
        outsr=outs
        sz=size(outs.c1,/dim)
        ph1s=fltarr(sz(0),sz(1),nimg)
        ph2s=ph1s
        ph3s=ph1s
        ph5s=ph1s
        a1s=fltarr(sz(0),sz(1),nimg)
        a2s=a1s
        a3s=a1s
        a5s=a1s
        a4s=a1s
        
        outss=replicate(outs,nimg)
;        continue
    endif
    outss(i)=outs

    ph1=atan2(outs.c1/outsr.c1)
    ph2=atan2(outs.c2/outsr.c2)
    ph3=atan2(outs.c3/outsr.c3)
    ph5=atan2(outs.c5/outsr.c5)

    a1=abs(outs.c1)/abs(outs.c4)
    a2=abs(outs.c2)/abs(outs.c4)
    a3=abs(outs.c3)/abs(outs.c4)
    a5=abs(outs.c5)/abs(outs.c4)

    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    ph3s(*,*,i)=ph3
    ph5s(*,*,i)=ph5

    a4s(*,*,i)=abs(outs.c4)
    a1s(*,*,i)=a1
    a2s(*,*,i)=a2
    a3s(*,*,i)=a3
    a5s(*,*,i)=a5
    if i gt 0 then begin
        a1s(*,*,i)/=a1s(*,*,0)
        a2s(*,*,i)/=a2s(*,*,0)
        a3s(*,*,i)/=a3s(*,*,0)
        a5s(*,*,i)/=a5s(*,*,0)
    endif
;goto,ee
if i eq 1 then begin
    mkfig,'~/img1.eps',xsize=12,ysize=11,font_size=9
endif
pos=posarr(2,2,0)&zr=[0,1]
imgplot,a1s(*,*,i),pos=posarr(/curr),/cb,title='sumordiff',zr=zr
imgplot,a2s(*,*,i),pos=posarr(/next),/cb,title='difforsum',/noer,zr=zr
imgplot,a3s(*,*,i),pos=posarr(/next),/cb,title='5mm',/noer,zr=zr
imgplot,a5s(*,*,i),pos=posarr(/next),/cb,title='3mm',/noer,zr=zr
xyouts,0.5,0.95,string(prearr(i),rarr(i),idxarr(i)),ali=0.5,/norm
ee:
if i eq 1 then begin
    endfig,/gs,/jp

    stop
endif
endfor

pos=posarr(2,2,0)
imgplot,a4s(*,*,56),zr=[0,.3e4],pos=pos,title='off'
imgplot,a4s(*,*,54),zr=[0,.3e4],pos=posarr(/next),/noer,title='on'
imgplot,a4s(*,*,54)-a4s(*,*,56),zr=[0,.3e4],pos=posarr(/next),/noer,title='on-off'
nx=n_elements(a4s(*,0,0))
ny=n_elements(a4s(0,*,0))
;plot,a4s(112/2,95/2,*),psym=4
a4s(*,*,0)=0.
tmy=0.099 * (idxarr)
plot,ip.t,-ip.v,xr=[0,13]
plot,nbi.t,nbi.v,xr=!x.crange,col=2,/noer
plot,tmy,a4s(nx/2,ny/2,*),xr=!x.crange,col=4,/noer,psym=-4
plot,tmy,-phs_jump(ph3s(nx/2,ny/2,*)),xr=!x.crange,col=5,/noer,yr=[0,5]
oplot,tmy,phs_jump(ph5s(nx/2,ny/2,*)),col=6
oplot,tmy,phs_jump(ph1s(nx/2,ny/2,*)),col=7
oplot,tmy,-phs_jump(ph2s(nx/2,ny/2,*)),col=9


end

