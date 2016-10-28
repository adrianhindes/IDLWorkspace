

function simimg_cxrs
;,s0,s1,s2,s3,mode=mode,dosynth=dosynth,deltawp=deltawp,opt=config
common cbb,x2,y2,f2

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

s0=1
s1=1
s2=0
s3=0
    

img=fltarr(nx,ny,4)
img(*,*,0)=s0
img(*,*,1)=s1
img(*,*,2)=s2
img(*,*,3)=s3
;hwpd=0.61824284e-3 ;for 8.5 order
hwpd= 0.036367225e-3 ;for zero order
par1={crystal:'bbo',thickness:5e-3,lambda:656e-9,facetilt:45*!dtor}
par2={crystal:'quartz',thickness:hwpd,lambda:656e-9,facetilt:0.}
par3={crystal:'bbo',thickness:2.5e-3,lambda:656e-9,facetilt:45*!dtor}

g=!pi/4
dums=0.
mrotate,img,g,!pi/8
dang1=ang_err( thx, thy, par=par1,delta=g)&mrotate,img, dums,dang1
dum1=opd(thx,thy,par=par1,delta=g)&g1=g&mwp,img,dum1
mrotate,img, dums,-dang1

mrotate,img,g,!pi/8
dang2=ang_err( thx, thy, par=par2,delta=g)&mrotate,img, dums,dang2
dum2=opd(thx,thy,par=par2,delta=g)&g2=g&mwp,img,dum2
mrotate,img, dums,-dang2


mrotate,img,g,-!pi/8-!pi/2

dang3=ang_err( thx, thy, par=par3,delta=g)&mrotate,img, dums,dang3
dum3=opd(thx,thy,par=par3,delta=g)&g3=g&mwp,img,dum3
mrotate,img, dums,-dang3

mrotate,img,g,-!pi/4
simg=img(*,*,1)+img(*,*,0)
simg*=8000
imgplot,simg(0:100,0:100)
stop
return,simg
end



