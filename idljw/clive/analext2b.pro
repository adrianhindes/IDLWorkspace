function nonan,x
idx=where(finite(x) eq 0)
y=x
if idx(0) ne -1 then y(idx)=0.
return,y
end

r=113
doplot=1
 img=getimg(r)
 sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
       filt:{type:'hat'},$
       aoffs:60.,$
       c1offs:180+180,$
       c2offs:0+180,$
       c3offs: 45,$
       fracbw:1.0,$
       pixfringe:14,$
       typthres:'win',$
       thres:0.01}
    demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=1. ,save={txt:'run',shot:r,ix:0},downsamp=sets.pixfringe,override=1;doplot eq 1;,linalong=45*!dtor;,/noopl

frac=2*abs(outs.c3)/abs(outs.c4) ; 2 because plus and minus
imgplot,frac,/cb



awx=6.5e-6 * 1376
nx=91
ny=73
x1=linspace(-awx/2,awx/2,nx)
awy=awx * ny/nx
y1=linspace(-awy/2,awy/2,ny)-awy*0.07
x2=x1 # replicate(1,ny)
y2=replicate(1,nx) # y1
f2=105e-3 
lambda=656e-9

thx=x2/f2
thy=y2/f2

par={facetilt:45*!dtor}
da=ang_err(thx,thy,par=par,delta=45*!dtor)

fracs=abs(2*da)

ix=linspace(0,nx-1,nx)
iy=linspace(0,ny-1,nx)
l1=frac(50,*);interpolate(frac,ix,iy)
l2=fracs(50,*);interpolate(fracs,ix,iy)
;sg1=l1*0+1 -2 * (ix lt 42)
;sg2=l1*0+1 -2 * (ix lt 45)
;l1=l1*sg1
;l2=l2*sg2
plot,l1
oplot,l2,col=2
;plot,(deriv(smooth(nonan(l1),5))>0)/.0025
;oplot,deriv(l2)/.0025,col=2

;!p.multi=[0,1,2]
;plotm,frac,yr=[0,.12]
;plotm,fracs
;!p.multi=0


;limg=total(img,2)
end

