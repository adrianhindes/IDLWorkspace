pro getdat,sh,shr,img

       img=getimgnew(sh,0)*1.0
       for fr=1,15 do img+=getimgnew(sh,fr,db=db)*1.0
       img/=16.
       
       imgr=getimgnew(shr,0)*1.0
       for fr=1,15 do imgr+=getimgnew(shr,fr,db=db)*1.0
       imgr/=16.
       img0=img
       img=img-imgr
       imgm=median(img,5)
       mn=mean(img)
       std=stdev(img)
       fac=2
       
       idx=where(imgm ge mn + std*fac or imgm le mn-std*fac)
       if idx(0) ne -1 then imgm(idx)=mn
       
       imgdif=(img-imgm)/imgm

;   idx=where(img ge mn + std*fac or img le mn-std*fac)
       idx=where(imgdif ge 2 or imgdif le -2)
       img(idx)=imgm(idx)


       
    end

pro getdif, pdif,psum,method=method



sh0=8052;3;46
ifr0=155
;sh=1615,returned
;ifr=0
;sh=1604 ; hor pol, in korea
;ifr=18


;shr=1605 ; vert pol, in korea
;ifrr=18


;sh=1612 ; hor pol,returned
;ifr=0

;shr=1604 ; vert hor, in korea
;ifrr=18


;shr=1614 ; vert pol, returned
;ifrr=0


sh=1623 & ifr=0 &lam= 650.65e-9
shr=1624 & ifrr=0 &lamr= 653.28e-9
shz = 1626
doplot=1

;img=getimgnew(sh0,ifr0,info=info,/getinfo,/nostop,/nosubindex,str=str,/getflc)*1.0

;roi2=[str.roil,    str.roir,    str.roib,    str.roit]
if n_elements(roi2) ne 0 then dum=temporary(roi2)
img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str,/getflc,roi=roi2)*1.0
imgr=getimgnew(shr,ifrr,/nosubindex,roi=roi2,str=strr,/getflc)*1.0


if method eq 'exp' then begin
getdat,sh,shz,img
getdat,shr,shz,imgr
endif
if method eq 'sim' then begin
simimgnew,img,sh=sh,lam=lam,svec=[2,1,1,0]
simimgnew,imgr,sh=shr,lam=lamr,svec=[2,1,1,0]
endif



newdemod,imgr,carsr,sh=shr,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/no2load
pr=atan2(carsr)

newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz,/no2load


ia=1
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
;jumpimgh,paj
;jumpimgh,pbj

psum=paj+pbj
pdif=paj-pbj

imgplot,pdif,/cb,pal=-2


end

getdif,pexp,sexp,method='exp'
getdif,psim,ssim,method='sim'
ix=300
plot,psim(ix,*)
oplot,pexp(ix,*),col=2
stop
;can match slope of doppler ase well...
plot,sexp(*,250)
 oplot,ssim(*,250),col=2
 


end
