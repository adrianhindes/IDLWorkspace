pro getc, la, car1
sh=63
dbtrue='kcal2015tt'
;la=656.89e-9


simimgnew,img,sh=sh,db=dbtrue,lam=la,svec=[2.2,1,1,.2];,/angdeptilt
db='kcal2015'
doplot=0
demodtype='basicnofull2'
newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,thx=thx,thy=thy;,/doload;,/cachewrite,/cacheread



nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
thv(*,*,0) = thx # replicate(1,ny)
thv(*,*,1) = replicate(1,nx) # thy

gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=la,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzv

car1=cars(*,*,2)

end


getc,656.3e-9,ca
getc,656.5e-9,cb
p=atan2(cb/ca)

imgplot,p,/cb
end


