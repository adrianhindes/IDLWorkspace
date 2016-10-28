pro calcim,img

awx=1376*6.5e-6 
nx=1376
ny=1040
x1=linspace(-awx/2,awx/2,nx)
awy=awx * ny/nx
y1=linspace(-awy/2,awy/2,ny)
x2=x1 # replicate(1,ny)
y2=replicate(1,nx) # y1
f2=50e-3 
lambda=656e-9

thx=x2/f2
thy=y2/f2



s0=1.
thh=0;!pi/2
s1=cos(2*thh)
s2=sin(2*thh)
s3=0.    

img=fltarr(nx,ny,4)
img(*,*,0)=s0
img(*,*,1)=s1
img(*,*,2)=s2
img(*,*,3)=s3

par={crystal:'bbo',thickness:7.5e-3,lambda:656e-9,facetilt:35*!dtor}
;par={crystal:'bbo',thickness:5e-3,lambda:656e-9,facetilt:45*!dtor}

;wpd1=opd(thx,thy,par=par0,delta=g)

g=0.
dums=0.
dang1=ang_err( thx, thy, par=par,delta=g)

mrotate,img, dums,dang1
dum1=opd(thx,thy,par=par,delta=g)&g1=g&mwp,img,dum1
mrotate,img, dums,-dang1

mrotate,img,g,!pi/4
simg=img(*,*,1)+img(*,*,0)
img=simg*8000

end


; img=1. + 0.06 * cos(2*!pi*x2/10)
; img=img*8000
; imgplot,img
; stop
; end



function nonan,x
idx=where(finite(x) eq 0)
y=x
if idx(0) ne -1 then y(idx)=0.
return,y
end

;r=118 & mul=1.&par={facetilt:45*!dtor}
r=117 & mul=sqrt(2)&par={facetilt:35*!dtor}
r=113
doplot=1
 img=getimg(r)
;calcim,img


 sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
       filt:{type:'hat'},$
       aoffs:60.,$
       c1offs:180+180,$
       c2offs:0+180,$
       c3offs: 45+90,$
       fracbw:1.0,$
       pixfringe:14/mul,$
       typthres:'win',$
       thres:0.01}
    demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=1. ,save={txt:'run',shot:r,ix:0},downsamp=sets.pixfringe,override=1,/noopl;doplot eq 1;,linalong=45*!dtor;,/noopl

frac=2*abs(outs.c3)/abs(outs.c4) ; 2 because plus and minus
imgplot,frac,/cb



awx=6.5e-6 * 1376
nx=n_elements(frac(*,0))
ny=n_elements(frac(0,*))
x1=linspace(-awx/2,awx/2,nx)
awy=awx * ny/nx
y1=linspace(-awy/2,awy/2,ny);-awy*0.3
x2=x1 # replicate(1,ny)
y2=replicate(1,nx) # y1
f2=50e-3 
lambda=656e-9

thx=x2/f2
thy=y2/f2

cbbo,n_e=n_e,n_o=n_o,lambda=656e-9
ref=(n_e+n_o)/2.
;ref=1
ref=n_e*sqrt(2)                         ;/0.8
da=ang_err(thx/ref,thy/ref,par=par,delta=0*!dtor)

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

