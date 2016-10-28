pro qit2,isel,xxt,angout,eps,mm
only2=0
only3=0
;sh=8044 
;lam=656e-9
;7;3;8;7351

;isel=10

;sh=4 & off=+5 + 16*isel  &xoff=0&xxt=isel*5.

;sh=6 & off=+5 + 16*isel  &xoff=67&xxt=isel*10.+xoff

;sh=5 & off=+5 + 16*isel  &xoff=91.39&xxt=isel*10.+xoff


;sh=476.&off=+2+6+6*isel & xoff=9.07-7.5

;sh=478.&off=+2+6+6*isel & xoff=24.9

;sh=477.&off=+2+6+6*isel & xoff=11.2


;sh=62. & isel=0 & off=0 & xoff=0&xxt=xoff

;xx=[ 7.5, 22.5, 30, 37.5, 45, 52.5, 60, 67.5, 75, 82.5, 90, 97.5, 105, 112.5, 120, 127.5, 135, 142.5, 150, 157.5, 165, 172.5, 180, 187.5]+xoff&xxt=xx(isel)

;sh=1204&off=4&xxt=270+(sh-1203)*10-180-90


sh=7426 & off=52&xxt=0. & only2=0;plasma  - alex's shot;84
;sh=7479 & off=72&xxt=0.;plasma

;only3=1
;sh=7358 & off=-5&xxt=85.;polariser 45 degish

;sh=7483 & off=82&xxt=-0&only2=1.;polariser 50 degish 4.7% ang=-1.3



;sh=7484 & off=92&xxt=-10&only2=1.;polariser 40 degish;dif=14frac=.076

;sh=7485 & off=92&xxt=10&only2=1.;just after polariser 40 degish plasma shot


;sh=7502 & off=0&xxt=0&only2=1.;bgas 2.t
;sh=7498 & off=0&xxt=0&only2=1.;bgas 2.5t
;sh=7496 & off=0&xxt=0&only2=1.  ;bgas 3t

;sh=7688 & off=80 & xxt=10.&only2=1 ;polariser, dif=11.8 zeta=0.098
;sh=7690 & off=48 & xxt=-10.&only2=1 ;poarliser, dif=9.78 zeta=0.031
;sh=7695 & off=80 & xxt=-20.&only2=1 ;polariser, dif=17.6 zeta=0.069
;sh=7695 & off=84 & xxt=-20.&only2=1 ;polariser, dif=14.8


lam=659.89e-9
;

istata=fltarr(4)
;for j=0,only2 eq 1 ? 1 : 3 do begin
for j=0, 3 do begin
    ang=(45)*!dtor
;    simimgnew,simg,sh=sh,lam=lam,svec=[1,cos(2*ang),sin(2*ang),0],ifr=j+off

    simg=getimgnew(sh,j+off,info=info,/getinfo)*1.0
;    plot,simg(200,300:320),psym=-4,noer=j gt 0,yr=j eq 0 ? [0,0] :!y.crange,col=j+1
ss=size(simg,/dim)
    plot,simg(ss(0)/2,ss(1)/2-10:ss(1)/2+10),psym=-4,noer=j gt 0,yr=j eq 0 ? [0,0] :!y.crange,col=j+1

;imgplot,simg,/cb,zr=[0,4000]

;stop
;simg=simimg_cxrs()
;print,kx,ky,kz

    newdemod,simg,cars,sh=sh,lam=lam,doplot=0,demodtype='basicsm',ix=ix,iy=iy,p=str,ifr=j+off,noinit=j gt 0,mat=mat,kx=kx,ky=ky,kz=kz,slist=slist,dmat=dmat,istat=istat1,/doload,thx=thx,thy=thy;,/cachewrite,/quiet,/cacheread
    istata(j)=istat1
;stop
endfor
print,'w,r,g,b'
print,istata
;stop
nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
for i=0,nx-1 do thv(i,*,0)=thx(i)
for j=0,ny-1 do thv(*,j,1)=thy(j)
;stop
gencarriers2,sh=sh,th=[0,0],/quiet,vth=thv,vkz=vkz,lam=659.89e-9
vkz=vkz + 45./360.
;cref=exp(complex(0,1)*2*!pi*(vkz))
;cars=cars / cref
;stop

;cref=cars(*,*,1)/abs(cars(*,*,1));*exp(complex(0,1)*180*!dtor)
;for j=0,3 do cars(*,*,1+j*2) /= cref

;cref=abs(cars(*,*,1))
;for j=0,1 do cars(*,*,1+j*2)*= cref/abs(cars(*,*,1+j*2))

;stop
;cars(*,*,
;getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts
;contourn2,r
;imgplot,abs(cars(*,*,1)),xsty=1,ysty=1
;contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)



sz=size(cars,/dim)
sel=[456,100]
car1=transpose(reform(cars(sel(0),sel(1),*)))
;stop
mato=mat
car1o=car1
if only2 eq 1 then begin
    idx=[0,1,2,3]               ;indgen(4);+4
    mat=mat(*,idx)
    mat=[[mat],[0,0,0,20]]
    car1=transpose([car1(idx),0])
endif

if only3 eq 1 then begin
;    idx=[0,1,2,3,4,5]               ;indgen(4);+4
    k=1
    idx=[0,1,2,3,4+2*k,5+2*k]               ;indgen(4);+4
    mat=mat(*,idx)
;    mat=[[mat],[0,0,0,20]]
    car1=transpose([car1(idx)])
endif


;car1=transpose(car1(idx))

;stop
la_svd,(mat),w,u,v
wi=1/w   ;                       &  wi(3)=0.
imat=v ## diag_matrix(wi) ## conj(transpose(u))

svec2=imat ## car1


scor = abs(svec2(1)) gt abs(svec2(2)) ? svec2(1)/abs(svec2(1)) : svec2(2)/abs(svec2(2))

;scor=scor * exp(complex(0,1)*180*!dtor)
svec2t=svec2
svec2 = svec2 / scor

print,'scor is',scor
circpol=abs2(svec2(3))/abs(svec2(0))
linpol=sqrt(abs(svec2(1))^2+abs(svec2(2))^2)/abs(svec2(0))
print,'circ pol frac=',circpol
eps=atan(circpol/linpol)*!radeg/2
print,'eps=',eps
print,'pol frac=',linpol

print,'true ang=',xxt

tmp=atan(abs2(svec2(2)),abs2(svec2(1)))*!radeg/2 + str.camangle
;tmp=atan(abs(svec2(2)),abs(svec2(1)))*!radeg/2 + str.camangle
print,'angmsea(t)=',tmp
print,'diff = ',tmp-xxt
angout=tmp
tmp=(atan2(car1(3)) - atan2(car1(1)))/4.*!radeg;+45 + str.camangle
print,'ang simp=',tmp
print,'diff = ',tmp-xxt
mm= ((atan2(svec2[1])*!radeg - atan2(svec2[2])*!radeg)) 

print,'mismatch of angle from 2 s vector is',mm,'deg'

mmb= ((atan2(svec2[1])*!radeg - atan2(svec2[3])*!radeg)) 
print,'doppler phase is',atan2(svec2t[1])*!radeg , atan2(svec2t[2])*!radeg

print,'mismatch of angle from 3 and 1 s vector is',mmb,'deg'

;tmp=(atan2(car1(7)) - atan2(car1(5)))/2.*!radeg
;print,'delta simp=',tmp

car2o = mato ## svec2t

stop

plot,abs(car2o),pos=posarr(2,1,0)
oplot,abs(car1o),col=2
plot,atan2(car2o)*!radeg,pos=posarr(/next),/noer
oplot,atan2(car1o)*!radeg,col=2

stop
end

n=20;15;20
xxt=fltarr(n)
ang=xxt
eps=xxt
mm=xxt
for i=0,n-1 do begin
    qit2,i,xxt1,ang1,eps1,mm1
    xxt(i)=xxt1
    ang(i)=ang1
    eps(i)=eps1
    mm(i)=mm1
endfor
plot,xxt,ang-xxt,pos=posarr(2,2,0)
plot,xxt,eps,pos=posarr(/next),/noer
plot,xxt,mm,pos=posarr(/next),/noer
end
