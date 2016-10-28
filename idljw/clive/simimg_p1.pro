

function simimg_p1,s0,s1,s2,s3,mode=mode
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

img=fltarr(nx,ny,4)
img(*,*,0)=s0
img(*,*,1)=s1
img(*,*,2)=s2
img(*,*,3)=s3

g=0

par0={crystal:'quartz',thickness:0.6e-3,lambda:656e-9,facetilt:0.}
par1={crystal:'bbo',thickness:5e-3,lambda:656e-9,facetilt:45*!dtor}
par2={crystal:'bbo',thickness:5e-3,lambda:656e-9,facetilt:45*!dtor}
par3={crystal:'bbo',thickness:7.5e-3,lambda:656e-9,facetilt:55*!dtor}

;wpd1=opd(thx,thy,par=par0,delta=g)

if mode eq 'phase' then begin
    g=-!pi/4
    mwp,img,!pi/2 
    mrotate,img,g,!pi/4
endif
dum1=opd(thx,thy,par=par1,delta=g)&g1=g&mwp,img,dum1
mrotate,img,g,!pi/2
dum2=opd(thx,thy,par=par2,delta=g)&g2=g&mwp,img,dum2
mrotate,img,g,-!pi/4
dum3=opd(thx,thy,par=par3,delta=g)&g3=g&mwp,img,dum3
mrotate,img,g,!pi/4
simg=img(*,*,1)
;imgplot,simg(0:100,0:100)
;stop
return,simg
end



