only2=0
;sh=7479 & off=72;69;62

;sh=7480 & off=72;69;62

sh=7426 & off=84
;sh=7358 & off=40;polariser 45 degish
;sh=7484 & off=92&xxt=10&only2=1.;polariser 40 degish

;sh=1207 & off=4


lam=659.89e-9
;

istata=fltarr(4)

for j=0,3 do begin
;    ang=(45)*!dtor
;    simimgnew,simg,sh=sh,lam=lam,svec=[1,cos(2*ang),sin(2*ang),0],ifr=j+off

    simg=getimgnew(sh,j+off,info=info,/getinfo)*1.0
ss=size(simg,/dim)
    plot,simg(ss(0)/2,ss(1)/2-10:ss(1)/2+10),psym=-4,noer=j gt 0,yr=j eq 0 ? [0,0] :!y.crange,col=j+1


;imgplot,simg,/cb,zr=[0,4000]

;stop
;simg=simimg_cxrs()
;print,kx,ky,kz

    newdemod,simg,cars,sh=sh,lam=lam,doplot=0,demodtype='basic',ix=ix,iy=iy,p=str,ifr=j+off,noinit=j gt 0,mat=mat,kx=kx,ky=ky,kz=kz,slist=slist,dmat=dmat,istat=istat1,thx=thx,thy=thy
istata(j)=istat1
;stop

endfor

print,'w,r,g,b'
print,istata


nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
for i=0,nx-1 do thv(i,*,0)=thx(i)
for j=0,ny-1 do thv(*,j,1)=thy(j)
;stop
gencarriers2,sh=sh,th=[0,0],/quiet,vth=thv,vkz=vkz,lam=661.e-9;659.89e-9

cref=exp(complex(0,1)*2*!pi*(vkz))
;stop
cars=cars / cref

;stop
;cref=cars(*,*,1)+cars(*,*,3) & cref/=abs(cref)
;for j=0,3 do cars(*,*,1+j*2) /= cref

;cref=abs(cars(*,*,1))
;for j=0,3 do cars(*,*,1+j*2)*= cref/abs(cars(*,*,1+j*2))

;stop
;cars(*,*,
;getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts
;contourn2,r
;imgplot,abs(cars(*,*,1)),xsty=1,ysty=1
;contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)

;stop


if only2 eq 1 then begin
    idx=[0,1,2,3]               ;indgen(4);+4
    mat=mat(*,idx)
    mat=[[mat],[0,0,0,20]]
    cars=cars(*,*,[idx,0])
    cars(*,*,4)=0.
endif

sz=size(cars,/dim)


la_svd,(mat),w,u,v
wi=1/w   ;                       &  wi(3)=0.
imat=v ## diag_matrix(wi) ## conj(transpose(u))

svec2=complexarr(sz(0),sz(1),4)
szm=size(mat,/dim)

for i=0,szm(0)-1 do for j=0,szm(1)-1 do svec2(*,*,i)+=imat(j,i) * cars(*,*,j)


ang=atan(abs(svec2(*,*,2)),abs(svec2(*,*,1)))/2*!radeg+str.camangle
;ang=atan(abs2(svec2(*,*,2)),abs2(svec2(*,*,1)))/2*!radeg+90+str.camangle

dop1=atan2(svec2(*,*,1))*!radeg
dop2=atan2(svec2(*,*,2))*!radeg

circ=abs2(svec2(*,*,3))/abs(svec2(*,*,0))
lin=sqrt(abs(svec2(*,*,1))^2 + abs(svec2(*,*,2))^2)/abs(svec2(*,*,0))
circr=circ/lin

eps=atan(circr)*!radeg

;delsimp=(atan2(cars(*,*,7))*!radeg - atan2(cars(*,*,5))*!radeg)/2.
;4
ang0=ang(sz(0)/2,sz(1)/2)
imgplot,(ang-ang0+3),/cb,pal=-2,zr=[-10,10]*2

;imgplot,!radeg*(ang-ang(sz(0)/2,sz(1)/2) ),/cb,pal=-2,zr=[-30,30]

;imgplot,eps,/cb,zr=[-10,10]*2,pal=-2


stop
end
;    -23.1555
;      102.722
;      85.3442
