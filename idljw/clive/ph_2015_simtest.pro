sh='wltesta';8053;46
ifr=100

doplot=0

lam=659.89e-9 ;529e-9


readpatch,sh,p,db=db
readcell,p.cellno,str

simimgnew,imgr,sh=sh,lam=lam,svec=[2,1,1,0],/noload,str=str,p=p

newdemod,imgr,carsr,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,kx=kx,ky=ky,kz=kz
pr=atan2(carsr)

;stop
;imgplot,img
;stop
shr=1615

;img=getimgnew(shr,0,/nosubindex)*1.0

;lam2=659.89e-9
lam2=656.3e-9
;sh2='wltestb'


str2=str
str2.wp2.thicknessmm*=(300+30./360.)/300
;str2.wp3.thicknessmm*=(300+30./360.)/300
p2=p

simimgnew,img,sh=sh,lam=lam2,svec=[2,1,1,0],/noload,str=str2,p=p2;,xytilt=[1.,0.5]

;img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex)*1.0


newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,kx=kx,ky=ky,kz=kz


ia=1
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
jumpimg,paj
jumpimg,pbj


psum=paj+pbj
pdif=paj-pbj

polang=pdif/4*!radeg
dopang=psum/2*!radeg
imgplot,polang,/cb,pal=4,pos=posarr(2,1,0),title='polariz'
imgplot,dopang,/cb,pal=4,pos=posarr(2,1,1),title='dopple',/noer

end

