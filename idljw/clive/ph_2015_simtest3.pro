pro getp, p, q
sh='1';8053;46
db='t5sb'
ifr=0

doplot=1

lam=659.89e-9 ;529e-9


readpatch,sh,p,db=db
readcell,p.cellno,str

simimgnew,imgr,sh=sh,db=db,lam=lam,svec=[3,1,1,1],/noload,str=str,p=p,angdeptilt=q


newdemod,imgr,cars,sh=sh,db=db,lam=lam,doplot=doplot,demodtype='basicfullt',ix=ix,iy=iy,kx=kx,ky=ky,kz=kz
if q eq 1 then stop
newdemod,imgr,carsr,sh=sh,db=db,lam=lam,doplot=doplot,demodtype='basicfullt0',ix=ix,iy=iy,kx=kx,ky=ky,kz=kz
;stop


ia=1
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
;jumpimg,paj
;jumpimg,pbj


psum=paj+pbj
pdif=paj-pbj

polang=pdif/4*!radeg
dopang=psum/2*!radeg
sz=size(polang,/dim)
imgplot,polang,/cb,pal=4,pos=posarr(2,1,0),title='polariz'
imgplot,dopang,/cb,pal=4,pos=posarr(2,1,1),title='dopple',/noer
p=polang(*,sz(1)/2)
stop
end

getp,a,1
getp,b,0

plot,a
oplot,b,col=2
end
