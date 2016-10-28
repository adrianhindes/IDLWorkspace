
pro newmakeefitnl,ix2=ix2,iy2=iy2,angexp=angexp,str=p,tw=tw,inperr=inperr,drcm=drcm,wt=wt,dir=dir,moddir=dirmod,norun=norun,res=res,rrng=rrng,doplot=doplot,dobeam2=dobeam2,invang=invang,dzcm=dzcm,nz=nz,distback=distback,mixfactor=mixfactor
default,wt,1

default,drcm,3.
default,dzcm,0
default,nz,1

sh=p.sh

default,inperr,0.

;, sh=sh,tw=tw,res=res,inperr=inperr,trueerr=trueerr,run=run,nostop=nostop,kff=kff,kpp=kpp,wt=wt,refi0=refi0,refsh=refsh,coff=coff,nocalc=nocalc,lookimg=lookimg,_extra=_extra
;default,inperr,1.
;default,wt,1.
;cmpmseefit_calc,rix2=rix2,ph1=ph1,iy12=iy12,rpr=rpr,iy11=iy11,ang2r=ang2r,$
;  tgam=tgam,ix12=ix12,zpr=zpr,rxs=rxs,rys=rys,sz=sz,ix11=ix11,ngam=ngam,dir1=di;r,idxarr=idxarr,$
;  ixa1=ix1,iya1=iy1,ixa2=ix2,iya2=iy2,$
; sh=sh,tw=tw,trueerr=trueerr,refi0=refi0,refsh=refsh,coff=coff,nocalc=nocalc,re;s=res


;plot,rix2,ph1(*,iy12),yr=[-15,5]





mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=dobeam2,distback=distback,mixfactor=mixfactor ;,/plane
sz=size(r,/dim)
iz0=value_locate(z(sz(0)/2,*),0)
r1=r(*,iz0)
z1=z(sz(0)/2,*)

igood=where(finite(angexp(*,iz0)) eq 1)
default,rrng,[min(r1(igood)),max(r1(igood))<220.]
ngam1=floor((rrng(1)-rrng(0))/(drcm))+1;!!!!
drcm2=(rrng(1)-rrng(0)) / (ngam1-1)

rwant1=rrng(0)+drcm2 * findgen(ngam1) 
;rwant1+= (rrng(1) - max(rwant1))/2. ; centre

default,zrng,(nz-1.)/2.*[-1,1]*dzcm
zwant1=nz gt 1 ? linspace(zrng(0),zrng(1),nz) : zrng(0)
ngam=ngam1*nz
rwant=fltarr(ngam)
zwant=rwant
for i=0,nz-1 do begin
   rwant(ngam1*i:ngam1*(i+1)-1)=rwant1
   zwant(ngam1*i:ngam1*(i+1)-1)=zwant1(i)
endfor

ix=interpol(findgen(n_elements(r1)),r1,rwant)
iy=interpol(findgen(n_elements(z1)),z1,zwant)



;angexpwant=interpol(angexp(*,iz0),r1,rwant)
angexpwant=interpolate(angexp,ix,iy)

if keyword_set(doplot) then begin
   plot,rwant,angexpwant,psym=4
   oplot,r1,angexp(*,iz0)
endif

tgamma=tan(angexpwant*!dtor) + inperr*!dtor
sgamma=replicate(1*!dtor,ngam)
fwtgam=replicate(wt,ngam)
rrrgam=rwant/100.
zzzgam=zwant/100. ;rwant*0.
sgn=keyword_set(invang) ? -1 : 1
aa3gam=interpolate(-rys(*,*,0),ix,iy)*sgn
aa4gam=interpolate(-rys(*,*,2),ix,iy)*sgn
aa2gam=interpolate(-rys(*,*,1),ix,iy)*sgn
aa1gam=interpolate(rxs(*,*,2),ix,iy)
;aa3gam=interpol(-rys(*,iz0,0),r1,rwant)*sgn
;aa4gam=interpol(-rys(*,iz0,2),r1,rwant)*sgn
;aa2gam=interpol(-rys(*,iz0,1),r1,rwant)*sgn
;aa1gam=interpol(rxs(*,iz0,2),r1,rwant)
aa5gam=replicate(0,ngam)
aa6gam=replicate(0,ngam)
res={tgamma:tgamma,rrrgam:rrrgam,zzzgam:zzzgam,aa3gam:aa3gam,aa4gam:aa4gam,aa2gam:aa2gam,aa1gam:aa1gam,aa5gam:aa5gam,aa6gam:aa6gam}

if keyword_set(norun) then return

fspec=string(sh,tw*1000,format='(I6.6,".",I6.6)')

ino=where(finite(tgamma) eq 0)
if ino(0) ne -1 then begin
    tgamma(ino)=0.
    fwtgam(ino)=0.
 endif
default,dirmod,''
default,dir,'/home/cam112/ikstar/my2/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod

;'/home/cam112/idl'
fil=dir+'/msenl_'+fspec
openw,lun,fil,/get_lun
printf,lun,'&INS'
fmt=string('(',ngam-1,'(G0,","),G0)',format='(A,I0,A)')
printf,lun,'TGAMMA ='+string(tgamma,format=fmt)
printf,lun,'SGAMMA ='+string(sgamma,format=fmt)
printf,lun,'FWTGAM =',string(fwtgam,format=fmt)
printf,lun,'RRRGAM =',string(rrrgam,format=fmt)
printf,lun,'ZZZGAM =',string(zzzgam,format=fmt)
printf,lun,'AA1GAM =',string(aa1gam,format=fmt)
printf,lun,'AA2GAM =',string(aa2gam,format=fmt)
printf,lun,'AA3GAM =',string(aa3gam,format=fmt)
printf,lun,'AA4GAM =',string(aa4gam,format=fmt)
printf,lun,'AA5GAM =',string(aa5gam,format=fmt)
printf,lun,'AA6GAM =',string(aa6gam,format=fmt)
printf,lun,' IPLOTS = 1'
printf,lun,' KDOMSE = 1'
printf,lun,' /'
printf,lun,'shot ',sh,'time ',tw,'idxarr',0
close,lun
free_lun,lun
print,'wrote namelist to',fil
;stop
end
