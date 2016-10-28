
pro testit2

sh=1615


common cb2, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd

img=getimgnew(sh)*1.0

newdemod, img,cars, nbin=nb,gap=id2,sh=sh,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,demodtype='real'

print,'hey'
;stop
genmat3, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav,$
  vkz=kzv

nx=n_elements(thx)
ny=n_elements(thy)




carsim=complexarr(nx,ny,4)
svec=transpose([1,1,0,0])

for i=0,nx-1 do for j=0,ny-1 do begin
;    la_svd,mat,w,u,v

    tmpmat=mat2(*,*,i,j)
    carsim(i,j,*) = tmpmat ## svec
endfor


;svec=complexarr(nx,ny,4)
;delarr=fltarr(nx,ny)
;for i=0,nx-1 do for j=0,ny-1 do begin


;stop
end
