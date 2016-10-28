@cutimg
function ir, vec
n=n_elements(vec)
rv=complexarr(n/2)
;for i=0,n/2-1 do rv(i)=vec(2*i)*exp(complex(0,1)*vec(2*i+1))
for i=0,n/2-1 do rv(i)=complex(vec(2*i),vec(2*i+1))
return,rv
end

function ri, vec,xp
n=n_elements(xp)
rv=fltarr(n)
for i=0,n-1 do rv(i)= xp(i) mod 2 eq 0 ? float(vec(i)) : imaginary(vec(i))
;for i=0,n-1 do rv(i)= xp(i) mod 2 eq 0 ? abs(vec(i)) : atan2(vec(i))
return,rv

end

function fgaussof,N, vrot,ti,pder1=pder1,pder2=pder2
common cbkappa, kappa
;kappa=1.

;default,lref,529.0


echarge=1.6e-19
mi=12*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti*1e3/mi)/clight
;dvthdti = (20 * sqrt(5) *  sqrt( (echarge * ti)/mi))/clight
dvthdti=1/clight * 0.5 / sqrt(2*echarge*ti*1e3/mi) * 2*echarge*1e3/mi


;vrot in units of 100km/s, ti in units of 1000eV
vrotc=(vrot * 100e3)/clight
dvrotcdvrot = 100e3/clight
;dl=(l0-lref)/lref
ii=dcomplex(0,1)
;gamma=exp(2*!pi*ii*N* (1+ kappa * (vrotc )) - (!pi*kappa*N)^2 * vth^2)
kappap=kappa
gamma=exp(2*!pi*ii*N* ( -kappap * (vrotc )) - (!pi*kappap*N)^2 * vth^2)


pder1 = -2 *gamma* ii* kappa *N *!pi * dvrotcdvrot
pder2 = -2 *gamma* kappa^2 * N^2 * !pi^2 * vth * dvthdti
;stop
return,gamma
end


function mymgaussfit, xp, a
;here doubel guass

;x - delays [ replicate twice]
;y - real then imaginary part
common cbmgf2, xtrue2,cohwhite
;n=n_elements(x)
;n2=n/2
x=xtrue2(xp)
cohwhitesub=cohwhite(xp)
tmp=fgaussof(x,a[1],a[2],pder1=pder2,pder2=pder3)
a4=a[3]
a5=a[4]
a6=a[5]

tmp2=fgaussof(x,a5,a6,pder1=pder6,pder2=pder7)


a3=0
pder1=tmp * exp(complex(0,1)*a3) - cohwhitesub

;pder4=tmp * a[0] * exp(complex(0,1)*a3) * complex(0,1)

f=a[0]*exp(complex(0,1)*a3)*tmp + (1-a[0]-a4) * cohwhitesub + $
  a4 * tmp2

pder2 *= a[0] * exp(complex(0,1)*a3)
pder3 *= a[0] * exp(complex(0,1)*a3)

pder5=tmp2 - cohwhitesub
pder6 *= a4
pder7 *= a4

pder=transpose([[ri(f,xp)],[ri(pder1,xp)],[ri(pder2,xp)],$
                [ri(pder3,xp)],$
;                [ri(pder4,xp)],$
                [ri(pder5,xp)],[ri(pder6,xp)],$
                [ri(pder7,xp)]])


return,pder
end


;goto,ttt

;goto,ee1
;pro qitmy3b
;sh=9240&ifr=3.16&ifrdark=3.12
;sh=9229&ifr=1.541&ifrdark=1.501
;sh=9211&ifr=3.54&ifrdark=3.50
;sh=9211&ifr=2.54&ifrdark=2.50
;sh=10402&ifr=7.89 & ifrdark=8.01 & ifrdark2=-0.04;12.0 ; -0.5

sh=10643 & ifr=[2.52] & ifrdark = [2.50] & ifrdark2=-0.04


shload=sh;10402

;9206;86
;sh=shload
;sh=9213

;ifr=1.021
;ifrdark=0.46;0.981;0.981

lam=529.1e-9

;Contrast (zeta) correction - using calibration file
db='cnewl'
calblack=getimgnew(sh,0,db='calbgnewl')*1.
cal=getimgnew(sh,0,db='calnewl')*1.

cal=cal-calblack

calimg0=cal&sz=size(cal,/dim)
for i=0,sz(1)-1 do cal(*,i)=median(calimg0(*,i),5)



for i=0,n_elements(ifr)-1 do begin&dum=getimgnew(sh,twant=ifr(i),db=db ,str=str )*1.0&imglight=i eq 0 ? dum : imglight+dum&end 

imglight/= n_elements(ifr)


for i=0,n_elements(ifr)-1 do begin&dum=getimgnew(sh,twant=ifrdark(i),db=db ,str=str )*1.0&imgdark=i eq 0 ? dum : imgdark+dum&end 
imgdark/= n_elements(ifrdark)


imgdark2 = getimgnew(sh,twant=ifrdark2,db=db ,str=str )*1.0

imglight-=imgdark2
imgdark-=imgdark2
print,total(imglight)
print,total(imgdark)

;Shot dark correction

img0=imglight&sz=size(imglight,/dim)
for i=0,sz(1)-1 do imglight(*,i)=median(img0(*,i),5)
;idx=where(imglight gt 2000)
;if idx(0) ne -1 then imglight(idx)=0.

img0=imgdark&sz=size(imgdark,/dim)
for i=0,sz(1)-1 do imgdark(*,i)=median(img0(*,i),5)
;idx=where(imgdark gt 2000)
;if idx(0) ne -1 then imgdark(idx)=0.


img=(imglight-imgdark)>0


;img=imglight;dark;light;dark;light;dark;dark;light                    ;imgdark ; pass+act
;goto,nopl
imgplot,imglight,pos=posarr(2,2,0),zr=[0,200],title=string(sh,ifr(0),format='("#",I0,"@t=",G0,"s")'),/cb
imgplot,imgdark,pos=posarr(/next),zr=[0,200],/noer,title=string(sh,ifrdark(0),format='("#",I0,"@t=",G0,"s")'),/cb
imgplot,img,pos=posarr(/next),/noer,zr=[0,200],title='difference',/cb
nopl:


;cutimg, cal, calcut,str=str

stop

;demodtype='basicd46b'
demodtype='basicqcell'
newdemod, cal,carscal,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,doplot=0
;stop
icar=3

carscal(*,*,icar) = carscal(*,*,icar)/carscal(*,*,0)*2

calccut,abs(carscal(*,*,0)),px,py,nnx,nny,/doplot
stop
carscalcut=complexarr(nnx,nny,8)
for i=0,1 do begin
   cutimg,carscal(*,*,i*icar),px,py,dum
   if i eq 0 then dum = dum*0 + 1 ; fill with 1's for intensity calibration
   for j=0,3 do carscalcut(*,*,2*j+i) = dum(*,*,j)
endfor

sz=size(carscal,/dim)
thv=fltarr(sz(0),sz(1),2)
for i=0,sz(0)-1 do thv(i,*,0)=thx(i)
for j=0,sz(1)-1 do thv(*,j,1)=thy(j)

;,/doplot
;for i=0,4 do if i ne 1 then carscal(*,*,i)=carscal(*,*,i)/carscal(*,*,1)


ee1:

;;here phase remap
;print,file_search(getenv('HOME')+'/idl/clive/settings/res'+string(sh,format='(I0)')+'.hdf')
;hdfrestoreext,getenv('HOME')+'/idl/clive/settings/res'+string(shload,format='(I0)')+'.hdf',res

readpatch,sh,str,db=db
readcell,str.cellno,strcell

;readancal, shload, xpar
;strcell2=strcell
;applycal_cxr, strcell2,xpar

;carscal- contrasts and phases of calibration
;carscal2 - fit of calibration i.e. expected at 532nm
;correction- deficit between calibration and fit of calirbation
;carscal3 - contrast and phase expected at 529nm
;carscal4 - phase corrected for deficit


 lam=532.0e-9 ;+ 0.3e-9;   + 0.2e-9
 gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
 s1=kz

 gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex


t=[ [0.7,1.1],$
    [1.5,2.8] ] * 1e-3

t=rotate(t,1) ; 270eg

;t=rotate(t,7) ; flip vert
t=reform(t,4)

kzoff=fltarr(4)

for j=0,3 do begin
   par={thickness:t(j)*2, crystal:'bbo',facetilt:0,lambda:lam}
   kzoff(j)=opd(0,0,par=par)/2/!pi
endfor

kz=fltarr(8) & for i=0,3 do kz(2*i+1) = kzoff(i)


kz1=kzv(*,*,icar)
cutimg,kz1,px,py,kz1cut

kzcut=fltarr(nnx,nny,8)
for i=0,3 do kzcut(*,*,2*i+1) = kz1cut(*,*,i) + kzoff(i)


;; carscal2 = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)

;; correction=carscal/carscal2

;; lamplas=529.1e-9 - 0.3e-9 ;05e-9 
;; lam=lamplas + 0.1e-9 ; 0.1nm shift

;; gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
;; s2=kz
;; gencarriers2,th=[0,0],p=str,str=strcell2,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex

;; carscal3b = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)

;; lam=lamplas

;; gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
;; s2=kz
;; gencarriers2,th=[0,0],p=str,str=strcell2,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex

;; carscal3 = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)


;; carscal4 = carscal3 * correction
;; carscal5 = carscal4 * (-1) ; corrected for 180deg phase shift for reflect not transmit
;stop

carscal5=carscal

newdemod,img,cars,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy;,/doplot
;stop
;for i=0,4 do if i ne 1 then cars(*,*,i)=cars(*,*,i)/cars(*,*,1)
cars(*,*,icar)=cars(*,*,icar)/cars(*,*,0)*2

stop
carscut=complexarr(nnx,nny,8)
for i=0,1 do begin
   cutimg,cars(*,*,i*icar),px,py,dum
   for j=0,3 do carscut(*,*,2*j+i) = dum(*,*,j)
endfor


;sz=size(cars,/dim)
;thv=fltarr(sz(0),sz(1),2)
;for i=0,sz(0)-1 do thv(i,*,0)=thx(i)
;for j=0,sz(1)-1 do thv(*,j,1)=thy(j)

;stop
;stop
;cars = cars / ( carscalphase/abs(carscalphase) )
carscut = carscut / (carscalcut) 

nsx=11
nsy=3;*4

kern=fltarr(nsx,nsy,1) + 1./ (nsx*nsy)
for i=0,7 do carscut(*,*,i)=convol(carscut(*,*,i),kern) ; smooth it 

; now do smooth

;pc=carscal3b/carscal3

;;Output
phase = atan2(carscut)
;phase=atan2(carscal3/carscal2)

;dl = phase/atan2(pc)* 0.1 / 529. * 3e8 / 100000.  ;(imaginary(cars),real_part(cars))
contrast = abs(carscut)
;
ee:

;mkfig,'~/figmain4.eps',xsize=14,ysize=10,font_size=8
jj=[1,3,5,7]
;!p.multi=[0,2,5]
erase
do3=1

for k=0,3 do begin
 pos1=posarr(3,4,3*k) 
  imgplot,contrast(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),zr=[0.,1.2],pos=pos1,/noer,offx=1.

 pos1=posarr(3,4,3*k+1)
  imgplot,phase(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),pal=-2,pos=pos1,/noer,offx=1

 pos1=posarr(3,4,3*k+2)

  imgplot,contrast(*,*,jj(k)-1),xsty=1,ysty=1,/cb,title=kz(jj(k)),pos=pos1,/noer,offx=1

end
endfig,/gs,/jp
stop


common cbkappa, kappa
ccrystal, {crystal:'bbo',lambda:529.1e-9,facetilt:0,thickness:1e-3},kappa=kappa
;goto,bbb
;stop
ttt:


;restore,file='~/idl/clive/settings/aparact1.sav',/verb
;restore,file='~/idl/clive/settings/aparbg1.sav',/verb;
;
;restore,file='~/idl/clive/settings/carswhite.sav',/verb
;dum=carswhite
;carswhite1=dum
;common cbmgf2, xtrue2,cohwhite

sz=[nnx,nny]
dy=sz(1)/2
;dx=40
;dy=29
np=10
gap=sz(0)/(np+1)

xp=gap/2 + findgen(np)*gap
apar=fltarr(sz(0),sz(1),6)
carsfit=cars*0
carsfit0=carsfit

for iplot=0,np-1 do begin
; for dx=0,sz(0)-1 do for dy=0,sz(1)-1 do begin


dx=xp(iplot) ; sz(0)/2;*0.5
;; ;dx=xp(2);sz(0)/2
dy=sz(1) * 0.5

 del=[reform(kzcut(dx,dy,jj(0:3))),0]
;; cohwhite1=[reform(carswhite1(dx,dy,jj(0:2))),1]
;; ;a=[1.,dl(dx,dy,jj(1)),1.,0.]
;; a1=reform(aparbg(dx,dy,0:2))
;; i1=intbg(dx,dy)
;; a2=reform(aparact(dx,dy,0:2))
;; i2=intact(dx,dy)
;; a=[a1,a2]
;; is=i1+i2
;; a(0)=a1(0) * i1/is
;; a(3)=i2/is

;; ;a(0)=a0/2
;; ;a(3)=a0/2
;; ;stop
;; ;a=[1.,0,2.,0.]
 nn=10
 del2=reform(transpose([[del],[del]]),nn)
;; xtrue2=del2
;; cohwhite=reform(transpose([[cohwhite1],[cohwhite1]]),nn)
 x=findgen(nn)
;; ystart=(mymgaussfit(x,a))(0,*)

 y=[(reform(carscut(dx,dy,jj(0:3)))),1]
 y2c=reform(transpose([[y],[y]]),nn)
 y2=ri(y2c,x)

;; dy2=reform(transpose([[abs(y)*0+1],[1/abs(y)]]),nn)
;; dy2=dy2*0+1


;; ;y2=dum(0,*)+randomu(sd,6)*0.1

;; ;pp=0
;; ;a0=mymgaussfit(pp,a)
;; ;xmach=1e-3
;; ;print,((mymgaussfit(pp,a+[1,0,0,0,0,0]*xmach))(0)-a0(0))/xmach,a0(1)
;; ;print,((mymgaussfit(pp,a+[0,1,0,0,0,0]*xmach))(0)-a0(0))/xmach,a0(2)
;; ;print,((mymgaussfit(pp,a+[0,0,1,0,0,0]*xmach))(0)-a0(0))/xmach,a0(3)
;; ;print,((mymgaussfit(pp,a+[0,0,0,1,0,0]*xmach))(0)-a0(0))/xmach,a0(4)
;; ;print,((mymgaussfit(pp,a+[0,0,0,0,1,0]*xmach))(0)-a0(0))/xmach,a0(5)
;; ;print,((mymgaussfit(pp,a+[0,0,0,0,0,1]*xmach))(0)-a0(0))/xmach,a0(6)

;; ;stop
;; ;ystart=(mygaussfit(x,a))(0,*)
;; ainit=a
;; yfit = LMFIT( x, y2, A , CHISQ=chisq , CONVERGENCE=convergence , FUNCTION_NAME='mymgaussfit', ITER=iter, SIGMA=sigma ,itmax=1000,/double,fita=[1,0,0,1,1,1]);,measure_errors=dy2)
;; apar(dx,dy,*)=a
;; carsfit(dx,dy,jj)=(ir(yfit))(0:2)
;; carsfit0(dx,dy,jj)=(ir(ystart))(0:2)

;print,'a=',a
;goto,nop

plot,del^2,alog10(abs(ir(y2))),yr=[-2,0],pos=posarr(2,1,0),title=string(dx,dy),psym=4
;oplot,del^2,alog10(abs(ir(ystart))),col=2,psym=4
;oplot,del^2,alog10(abs(ir(yfit))),col=3,psym=4

plot,del,(atan2(ir(y2))),pos=posarr(/next),/noer,yr=[-!pi,!pi],psym=4
;oplot,del,(atan2(ir(ystart))),col=2,psym=4
;oplot,del,(atan2(ir(yfit))),col=3,psym=4
nop:
print,dx,dy,sz(0),sz(1)
stop
endfor


phasefit = atan2(carsfit)
;phase=atan2(carscal3/carscal2)

contrastfit = abs(carsfit)
;

;aparbg=apar
;save,aparbg,file='~/idl/clive/settings/aparbg1.sav',/verb

;gam=

bbb:
contrastw=abs(carsfit0)
phasew=atan2(carsfit0)
;cursor,dx,dy,/down


;dx=sz(0)/2
dy=sz(1) * 0.5;/2
;dx=40
;dy=29
np=5
gap=sz(0)/(np+1)

xp=gap/2 + findgen(np)*gap

for iplot=0,np-1 do begin
;print,dx,dy
;if !mouse.button eq 4 then stop
;inz=where(kz ne 0)
;inz=inz(sort(kz(inz)))
dx=xp(iplot)
inz=jj
;mkfig,'~/pl'+string(iplot,format='(I0)')+'.eps',xsize=7,ysize=6,font_size=6
;plot,abs(kzv(dx,dy,inz)),contrast(dx,dy,inz),psym=-4,pos=posarr(2,1,0)
plot,abs(kzv(dx,dy,inz))^2,alog10(contrast(dx,dy,inz)),psym=-4,pos=posarr(2,1,0,cnx=0.1,cny=0.1,fx=0.5),title=string(dx,dy,format='("x=",I0," y=",I0)'),xtitle='N^2',ytitle='Log_10 zeta'
oplot,abs(kzv(dx,dy,inz))^2,alog10(contrastfit(dx,dy,inz)),col=3
oplot,abs(kzv(dx,dy,inz))^2,alog10(contrastw(dx,dy,inz)),col=2
plot,kzv(dx,dy,inz),phase(dx,dy,inz),psym=-4,pos=posarr(/next),/noer,yr=[-1,1]*!pi,xtitle='N',ytitle='phase (rad)'
oplot,kzv(dx,dy,inz),phasefit(dx,dy,inz),col=3
oplot,kzv(dx,dy,inz),phasew(dx,dy,inz),col=2
plots,[0,0],psym=5,col=4
endfig,/gs,/jp
stop
;cursor,dx,dy,/down
endfor
plot,apar(*,sz(1)/2,5),yr=[0,2]
oplot,aparact(*,sz(1)/2,2),col=2 

;goto,ee
stop
end

;qitmy3b
;end
