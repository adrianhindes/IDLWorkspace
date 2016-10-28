;sh=7274&dtframe=0.0208
;sh=7266&dtframe=0.099 & t0=-0.18
sh=7290 & dtframe=0.01 & t0=-0.027

if n_elements(nbi) gt 0 then goto,aa1
spawn,'hostname',host
if host ne 'ikstar.nfri.re.kr' then mdsconnect,'172.17.250.100:8005'
mdsopen,'kstar',sh
;nbi=mdsvalue('\NB1_PB1')
;tnbi=mdsvalue('DIM_OF(\NB1_PB1)')
nbi=cgetdata('\NB1_PB1',/norest)
ip=cgetdata('\PCRC03',/norest)

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


r=0
prec='cal_532_sumd161_1600_1_1080' & sets=sets1
prer='c' & r=sh

nimg=400-2

prearr=[prec,replicate(prer,nimg-1)]
rarr=[0,replicate(r,nimg-1)]
idxarr=[0,indgen(nimg-1)+2]


for i=0,nimg-1 do begin

demodcs, img,outs, doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.16,r5fac=0.6,/dofifth,plotwin=0;,linalong=1;,/noopl
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
pos=posarr(2,3,0)&zr=[0,1]
imgplot,a1s(*,*,i),pos=posarr(/curr),/cb,title='sumordiff',zr=zr
imgplot,a2s(*,*,i),pos=posarr(/next),/cb,title='difforsum',/noer,zr=zr
imgplot,a3s(*,*,i),pos=posarr(/next),/cb,title='5mm',/noer,zr=zr
imgplot,a5s(*,*,i),pos=posarr(/next),/cb,title='3mm',/noer,zr=zr
imgplot,a4s(*,*,i),pos=posarr(/next),/cb,title='li',/noer
xyouts,0.5,0.95,string(prearr(i),rarr(i),idxarr(i)),ali=0.5,/norm
a='' & read,'',a
ee:
;stop
endfor

nx=n_elements(a4s(*,0,0))
ny=n_elements(a4s(0,*,0))
;plot,a4s(112/2,95/2,*),psym=4
a4s(*,*,0)=0.
tmy=dtframe * (idxarr) +t0
plot,ip.t,-ip.v,xr=[1.2,1.7]+1;0,6];2.2,3.2] 
plot,nbi.t,nbi.v,xr=!x.crange,col=2,/noer
plot,tmy,a4s(nx/2,ny/2,*),xr=!x.crange,col=4,/noer,psym=-4
plot,tmy,-phs_jump(ph3s(nx/2,ny/2,*)),xr=!x.crange,col=5,/noer,yr=[0,5]
oplot,tmy,phs_jump(ph5s(nx/2,ny/2,*)),col=6
oplot,tmy,phs_jump(ph1s(nx/2,ny/2,*)),col=7
oplot,tmy,-phs_jump(ph2s(nx/2,ny/2,*)),col=9
cursor,dx1,dy,/down
cursor,dx2,dy,/down
dum=min(abs(dx1-tmy),i1)
dum=min(abs(dx2-tmy),i2)
oplot,tmy(i1)*[1,1],!y.crange
oplot,tmy(i2)*[1,1],!y.crange
cursor,dx,dy,/down


pos=posarr(2,2,0)
zr=[0,.2e4]
imgplot,a4s(*,*,i1),zr=zr,pos=pos,title='off'
imgplot,a4s(*,*,i2),zr=zr,pos=posarr(/next),/noer,title='on'
imgplot,a4s(*,*,i1)-a4s(*,*,i2),pos=posarr(/next),/noer,title='on-off'



end

