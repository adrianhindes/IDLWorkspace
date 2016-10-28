pro newdemodflclt,sh, off, only2=only2p, eps=eps,angt=ang,dop1=dop1,dop2=dop2,doplot=doplot,cacheread=cacheread,cachewrite=cachewrite,dop3=dop3,dopc=dopc,dostop=dostop,ang0=ang0,pp=p,str=str,sd=sd,noload=noload,vkz=vkz,lin=lin,inten=inten,ix=ix,iy=iy,plotcar=plotcar,cix=cix,ciy=ciy,only1=only1,cars=cars,istata=istata,demodtype=demodtype,noid2=noid2,db=db,lut=lutpar,multiplier=multiplier,twant=twant,yr=yr
default,only2p,0
default,only1,0
default,demodtype,'sm32013mse';smktest2013mse';basicd'
lut=keyword_set(lutpar) and sh gt 8000
print,'here,lut=',lut

if keyword_set(twant) then begin
   off=frameoftime(sh,twant,db=db)
endif

only2=abs(only2p)
if keyword_set(cacheread) or keyword_set(cachewrite) then begin
    pth=gettstorepath()
    fn=string(pth,'newdemodflclt_',demodtype,only2,only1,sh,off,format='(A,A,A,"_only2_",I0,"_only1_",I0,"_",I0,"_",I0,".hdf")')
if demodtype eq 'sm2013mse' then     fn=string(pth,'newdemodflclt',only2,only1,sh,off,format='(A,A,"_only2_",I0,"_only1_",I0,"_",I0,"_",I0,".hdf")')
;stop
endif


if keyword_set(cacheread) then begin
    dum=file_search(fn,count=cnt)

    if cnt ne 0 then begin
;        restore,file=fn,/verb
        hdfrestoreext,fn,outs
        cars=outs.cars
;        svec2=outs.svec2
        sz=outs.sz
        p=outs.p
        ix=outs.ix
        iy=outs.iy
        istat1=outs.istat1
        if not keyword_set(quiet) then print,'restored'
        goto,ee
        return
    endif
endif


;sh=7479 & off=72;69;62

;sh=7480 & off=72;69;62

;sh=7426 & off=84
;sh=7358 & off=40;polariser 45 degish
;sh=7484 & off=92&xxt=10&only2=1.;polariser 40 degish

;sh=1207 & off=4


lam=659.89e-9
;

istata=fltarr(4)-1

up=only1 eq 1 ? 0 : (only2 eq 1 ? 1 : 3)
if only2p lt 0 then up=3

for j=0,up do begin

;for j=0,3 do begin
;    ang=(45)*!dtor
;    simimgnew,simg,sh=sh,lam=lam,svec=[1,cos(2*ang),sin(2*ang),0],ifr=j+off

;    simg=getimgnew(sh,j+off,info=info,/getinfo)*1.0
;ss=size(simg,/dim)
 ;   plot,simg(ss(0)/2,ss(1)/2-10:ss(1)/2+10),psym=-4,noer=j gt 0,yr=j eq 0 ? [0,0] :!y.crange,col=j+1


;imgplot,simg,/cb,zr=[0,4000]

;stop
;simg=simimg_cxrs()
;print,kx,ky,kz
default,multiplier,1
;stop
    newdemod,simg,cars,sh=sh,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,ifr=j*multiplier+off,noinit=j gt 0,mat=mattmp,kx=kx,ky=ky,kz=kz,slist=slist,dmat=mat,istat=istat1,thx=thx,thy=thy,/doload,p=p,str=str,sd=sd,noload=noload,noid2=noid2,db=db;,/cacheread,/cachewrite;,/cachewrite


istata(j)=istat1
;stop

endfor


if keyword_set(cachewrite) then begin
;        restore,file=fn,/verb
   sz=size(cars,/dim)
;   stop
        outs={cars:cars,sz:sz,thx:thx,thy:thy,ix:ix,iy:iy,istat1:istat1,str:str,p:p}

;        outs={cars:cars,sz:sz,p:p,ix:ix,iy:iy,istat1:istat1}
        hdfsaveext,fn,outs
        if not keyword_set(quiet) then         print,'saved'
endif


ee:


if keyword_set(lut) then begin
   default,yr,sh lt 9500 ? '' : '2014'
   hdfrestoreext,getenv('HOME')+'/idl/lt'+yr+'_'+demodtype+'.hdf',str
   sz=size(str.f,/dim)
endif

if only2 eq 1 and only1 eq 0 then begin
   pp=atan2(cars)
   carsn=cars/abs(cars)
   midp=(carsn(*,*,1)+carsn(*,*,3))/2
   dopc=atan2(midp)*!radeg
;   dopc=(pp(*,*,1)+pp(*,*,3))/2*!radeg
   ang=atan2(cars(*,*,3)/cars(*,*,1))/4*!radeg
   lin=abs(cars(*,*,1))/abs(cars(*,*,0))
   inten=abs(cars(*,*,0))
;   stop

   if keyword_set(lut) then begin
      angt=ang
      dopct=dopc
      for i=0,sz(0)-1 do for j=0,sz(1)-1 do begin
         ang(i,j)=interpol(str.theta,str.g(i,j,*),angt(i,j))

         tvar=interpol(str.f(i,j,*),str.theta,ang(i,j))
         dopc(i,j)=dopct(i,j) - tvar
      endfor
   endif
   

endif
if only1 eq 1 then begin

   dopcrad=dopc*!dtor
   ref=exp(complex(0,1)*dopcrad)
   if istat1 eq 0 then ang=atan2(ref/cars(*,*,1))/2*!radeg
   if istat1 eq 1 then ang=atan2(cars(*,*,3)/ref)/2*!radeg
   lin=abs(cars(*,*,2*istat1+1))/abs(cars(*,*,2*istat1))
   inten=abs(cars(*,*,2*istat1))

   if keyword_set(lut) then begin
      angt=ang
      if istat1 eq 1 then tfunc=str.hplus
      if istat1 eq 0 then tfunc=str.hminus

      for i=0,sz(0)-1 do for j=0,sz(1)-1 do $
         ang(i,j)=interpol(str.theta,tfunc(i,j,*),angt(i,j))
   endif

endif

;hdfrestoreext,'/home/cam112/idl/lt_'+demodtype+'.hdf',str
;sz=size(ang,/dim)
;angi=ang*0
;for i=0,sz(0)-1 do for j=0,sz(1)-1 do begin
;   angi(i,j)=interpol(str.true,str.meas(i,j,*)
;stop
eps=ang*0
dop1=dopc
dop2=dopc
dop3=dopc

if keyword_set(dostop) then stop
;ee:
end
