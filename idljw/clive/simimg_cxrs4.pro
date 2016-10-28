

function simimg_cxrs4
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
par1={crystal:'bbo',thickness:5*1.e-3,lambda:656e-9,facetilt:45*!dtor}
par2={crystal:'quartz',thickness:hwpd,lambda:656e-9,facetilt:0.}
par3={crystal:'bbo',thickness:7.5e-3,lambda:656e-9,facetilt:35*!dtor}

g=-!pi/4;+10*!dtor;!pi/8
dums=0.
mrotate,img,g,!pi/8
mwp,img,opd(thx,thy,par=par1,delta=g)
mrotate,img,g,!pi/8
mwp,img,opd(thx,thy,par=par2,delta=g)
mrotate,img,g,-!pi/8+!pi/2
mwp,img,opd(thx,thy,par=par3,delta=g)
mrotate,img,g,-!pi/8;4


simg=img(*,*,1)+img(*,*,0)
simg*=8000
imgplot,simg(0:100,0:100),/iso


d1= opd(0,0,par=par1)/2/!pi
d2= opd(0,0,par=par3)/2/!pi

d1b=opd(0,0,par=create_struct(par1,'temperature',0.25))/2/!pi
d2b=opd(0,0,par=create_struct(par3,'temperature',0.25))/2/!pi

dels=[d2,d1-d2,d1+d2]
delsb=[-d2,-d1+d2,-d1-d2]
print,'d1,d2=',d1,d2
print,'dd1,dd2=',d1b-d1,d2b-d2
print ,'temp chg norm to delta',(d1b-d1)/d1*d1,(d2b-d2)/d2*d1
;print,'d2,d1-d2,d1+d2=',dels

;print,'d2,-d1-d2,-d1+d2=',delsb
stop
return,simg
end



