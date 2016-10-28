

lam=529.1e-9
db='k2'
;Contrast (zeta) correction - using calibration file
shload=88888;9229
sh='cxrstest4_tuni_white_cxrsfilter'
shb=sh+'_black'

shc='cxrstest4_tuni_lasertr'
shcb=shc+'_black'

calblack=getimgnew(shc,0,db=db)*1.
cal=getimgnew(shcb,0,db=db)*1.

cal=cal-calblack

imglight=getimgnew(sh,0,db=db)*1.0
imgdark=getimgnew(shb,0,db=db)*1.0


imglight-=imgdark

sz=size(imglight,/dim)
img=imglight-imgdark


demodtype='basicd46b'
newdemod, cal,carscal,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy;,/doplot
;stop

sz=size(carscal,/dim)
thv=fltarr(sz(0),sz(1),2)
for i=0,sz(0)-1 do thv(i,*,0)=thx(i)
for j=0,sz(1)-1 do thv(*,j,1)=thy(j)

;,/doplot
for i=0,4 do if i ne 1 then carscal(*,*,i)=carscal(*,*,i)/carscal(*,*,1)



;;here phase remap
print,file_search(getenv('HOME')+'/idl/clive/settings/res'+string(shload,format='(G0)')+'.hdf')
hdfrestoreext,getenv('HOME')+'/idl/clive/settings/res'+string(shload,format='(G0)')+'.hdf',res

readpatch,sh,str,db=db
readcell,str.cellno,strcell

readancal, shload, xpar
strcell2=strcell
applycal_cxr, strcell2,xpar

lam=532.0e-9 ;+ 0.3e-9;   + 0.2e-9
gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
s1=kz

gencarriers2,th=[0,0],p=str,str=strcell2,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex


carscal2 = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)

correction=carscal/carscal2
;stop
lamplas=529.1e-9 - 0.3e-9 ;05e-9 

lam=lamplas

gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
s2=kz
gencarriers2,th=[0,0],p=str,str=strcell2,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex

carscal3 = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)


carscal4 = carscal3 * correction
carscal5 = carscal4 ;* (-1) ; corrected for 180deg phase shift for reflect not transmit
;stop

newdemod,img,cars,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy;,/doplot
;stop
for i=0,4 do if i ne 1 then cars(*,*,i)=cars(*,*,i)/cars(*,*,1)
sz=size(cars,/dim)
thv=fltarr(sz(0),sz(1),2)
for i=0,sz(0)-1 do thv(i,*,0)=thx(i)
for j=0,sz(1)-1 do thv(*,j,1)=thy(j)

cars = cars / (carscal5)

;ns=2
;kern=fltarr(ns,ns,1) + 1./ (ns*ns)
;for i=0,4 do cars(*,*,i)=convol(cars(*,*,i),kern) ; smooth it 

; now do smooth

;pc=carscal3b/carscal3

;;Output
phase = atan2(cars)
;phase=atan2(carscal3/carscal2)

contrast = abs(cars)
;
ee:

;mkfig,'~/figmain4.eps',xsize=14,ysize=10,font_size=8
jj=[0,2,4]
;!p.multi=[0,2,5]
erase
do3=0

for k=0,2 do begin
if do3 eq 1 then pos1=posarr(3,3,3*k) else pos1=posarr(2,3,2*k)
  imgplot,contrast(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),zr=[0.,1.2],pos=pos1,/noer,offx=1.

if do3 eq 1 then pos1=posarr(3,3,3*k+1) else pos1=posarr(2,3,2*k+1)
  imgplot,phase(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),pal=-2,pos=pos1,/noer,offx=1
if do3 eq 1 then $
  imgplot,dl(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),pal=-2,pos=posarr(3,3,3*k+2),/noer,offx=1

end
endfig,/gs,/jp

carswhite=cars
save,carswhite,file='~/idl/clive/settings/carswhite.sav',/verb
stop

end
