;sh=90&db='m'
;sh=22
db='m2'
;sharr=intspace(32,40)
sharr=[1,3,5,7,2,4,6,8,9]+40;500
;sharr=[1,3,5,7,2,4,6,8,9]+50;600
;sharr=[1,3,5,7,2,4,6,8,9]+60;400

sharr=[1,3,5,7,2,4,6,8,9]-1 + 568;41;118;210;54;63;154;72;400
sharr=[1,3,5,7,2,4,6,8,9]-1 + 648;1--Ljz mp fo;ter ;41;118;210;54;63;154;72;400
sharr=[1,3,5,7,2,4,6,8,9]-1 + 657;1--Ljz mp fo;ter ;41;118;210;54;63;154;72;400
sharr=sharr(0:7)
nsh=n_elements(sharr)
nfr=nsh & iref=0


kern=fltarr(4*4,4)+1./16./4.

for i=0,nfr-1 do begin
sh=sharr(i)
d=getimgnew(sh,0,db=db)
;stop

;pro newdemod, img,cars, nbin=nb,gap=id2,sh=sh,mat=mat,thx=thx,thy=thy,$
;iz=iz,p=p,str=str,sd=sd,doplot=doplot,demodtype=demodtype,frac=frac,$
;indexlist=indexlist,lam=lam,ixo=ixo,iyo=iyo,ifr=ifr,noinit=noinit,slist=slist,$
;stat=stat,quiet=quiet,dmat=dmat,kx=kx,ky=ky,kz=kza,istat=istat,doload=doload,$
;cacheread=cacheread,cachewrite=cachewrite,noload=noload,noid2=noid2,db=db,onlyp;lot=onlyplot,svec=svec,ordermag=ordermag
newdemod,d,cars,doplot=0,db=db,sh=sh,lam=488e-9,demodtype='magpie2'
;stop
s=cars(*,*,1)
sz=size(s,/dim)
if i eq 0 then begin
   ss=complexarr(sz(0),sz(1),nfr)
   dcs=fltarr(sz(0),sz(1),nfr)
endif
ss(*,*,i)=s
dcs(*,*,i)=convol(cars(*,*,0),kern)

endfor


pd=fltarr(sz(0),sz(1),nfr)
zd=pd
for i=0,nfr-1 do begin
   carquot=ss(*,*,i)/ss(*,*,iref)
   carquot=convol(carquot,kern)
   pd(*,*,i) = atan2(carquot)
   zd(*,*,i) = alog10(abs(carquot))
;pd=shift(pd,0,0,4)
endfor

sz=size(dcs,/dim)
nx=sz(0);512
ny=sz(1);*1.5;63

pd1=reform(pd(*,ny/2,*))
zd1=reform(zd(*,ny/2,*))
pdm=total(pd1,2)/nfr
zdm=total(zd1,2)/nfr
pd2=pd1
zd2=zd1

for i=0,3 do begin
av=(pd1(*,i)+pd1(*,i+4))/2.
pd2(*,i)-=av
pd2(*,i+4)-=av
endfor

for i=0,3 do begin
av=(zd1(*,i)+zd1(*,i+4))/2.
zd2(*,i)-=av
zd2(*,i+4)-=av
endfor


;for i=0,nx-1 do pd2(i,*)-=pdm(i)

xx=(reform(dcs(*,ny/2,*)))
xxm1=max(xx,dimension=1,/nan)
xx1=xx & for i=0,nfr-1 do xx1(*,i)/=xxm1(i)
;xxm=max(xx,dimension=2)
xxm=total(xx1,2)/nfr
xx2=xx1 & for i=0,nx-1 do xx2(i,*)/=xxm(i)

wset2,0
imgplot,xx2-1,pal=-2,/cb

wset2,1
imgplot,pd2,pal=-2,/cb,zr=[-0.03,0.03]

wset2,2
imgplot,zd2,pal=-2,/cb

ii=where(finite(dcs) eq 0)
dcs(ii)=0.
wset2,3
plot,totaldim(dcs,[1,1,0])


end
