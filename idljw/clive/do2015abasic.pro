pro do2015abasic,sh,ifr,circ,r1,z1,cslice,time,remember=remember,l0=l0,dl=dl

;@getslopeg

  ia=1
  ib=3
  ic=2

db='k' & shref=sh & ifrref=0 & dbref='kcal' & calib_offset=0 & psumsim_off=2*!pi ; -56.*!dtor+90*!dtor

if sh ge 13493 and sh le 99999 then shref=13492

filter=0
default,l0,660.9;7
default,dl,-0.8;1.0
ang=7*!dtor
;l0=661.0
demodtyper='basicnofull2r'
demodtype='basicnofull2b'
refmethod='yes'

 psgn=-1.
psgn2=1.

lam=659.89e-9

doplot=0
cacheread=0
cachewrite=1

common cbremember, imgref, carsr,psumsim, rarr,zarr
imgref=getimgnew(shref,ifrref,db=dbref)
if not keyword_set(remember) then    newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=dbref,lam=lam,doplot=doplot,demodtype=demodtyper,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,doload=0,cachewrite=cachewrite,cacheread=cacheread;,/onlyplot

;stop
img=getimgnew(sh,ifr,db=db,filter=filter,str=str)

time=str.t0 + ifr * str.dt
      newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz,doload=0,cachewrite=cachewrite,cacheread=cacheread

;stop
;
sz=size(cars,/dim)
carsr2 = carsr / abs(carsr)

denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))

pa=atan2(cars(*,*,ia)/carsr(*,*,ia))
pb=atan2(cars(*,*,ib)/carsr(*,*,ib))
;stop

;jumpimg,pa
;jumpimg,pb

psum=(pa+psgn*pb)/2.
if not keyword_set(remember) then getslopeg, l0,dl, d1,d2, ph=psumsim,which='displacer',ang=ang

pdif=psgn2*(pa-psgn*pb)/4. - calib_offset

if not keyword_set(remember) then getptsnew,pts=pts,str=str,ix=ix,iy=iy,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang1,plane=1

z1=zarr(sz(0)/2,*)
iz0=value_locate(z1,20);sz(1)/2
;
r1=rarr(*,iz0)



pref=-psumsim
pcar=exp(complex(0,1)*pref)
   numer=        abs2(cars(*,*,ic)/carsr2(*,*,ic)/pcar)
circ=0.5*!radeg*atan($
     numer,denom)
cslice=circ(*,iz0)
end


pro proc_shot, sh,l0=l0,dl=dl,nmax=nmax,noff=noff
default,noff,0


  str='rm /dataext/MSE_2015_PRC_DATA/*'+string(sh,format='(I0)')+'*'
   print,str
;   stop
   spawn,str


d=getimgnew(sh,-1,info=info,/getinfo,/noxbin)
db='k'
;stop
n=info.num_images
if keyword_set(nmax) then n=nmax


tree='mse_2015_prc'
mdsedit, tree, sh, status=status, /quiet
if status ne 0  then begin
   mdstcl,'set tree '+tree
   mdstcl,'create pulse '+strtrim(sh,2)
   mdstcl,'edit '+tree+' /shot='+strtrim(sh, 2), status=status,/quiet

endif

node='ANGLE'
  mdstcl, 'add node '+node+' /usage=signal',/quiet

t=fltarr(n)

for i=0,n-1 do begin
   do2015abasic, sh, i+noff, circ, r1, z1,cslice,time,remember=i gt 0,l0=l0,dl=dl
   t(i)=time
   if i eq 0 then begin
      sz=size(circ,/dim)
      circs=fltarr(sz(0),sz(1),n)
      circslice=fltarr(sz(0),n)
   endif
   circs(*,*,i)=circ
   circslice(*,i)=cslice
   put_image_seg, node, circ, time
   print,i,n
endfor
putaddnode2d, 'ANGLESLICE',circslice, t, r1
mdswrite, tree, sh
mdsclose


end

