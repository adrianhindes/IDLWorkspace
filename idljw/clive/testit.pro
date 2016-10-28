

pro testit
common cb2, img,cars,gap,nbin,mat,thx,thy,iz,p,str,sd
sh=8046
lam=659.89e-9
simimgnew,img,sh=sh,lam=lam-0.5e-9
newdemod,img,cars,gap=gap,nbin=nbin,sh=sh,mat=mat,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,lam=lam;,/doplot


nx=n_elements(thx)
ny=n_elements(thy)

iztmp=iz
iztmp(0)+=30
iztmp(1)+=30
car1=cars(iztmp(0),iztmp(1),*)



gencarriers,sh=sh,th=[thx(iztmp(0)),thy(iztmp(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,lam=lam

stop


 genmat2, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav,lam=lam


svec=complexarr(nx,ny,4)
delarr=fltarr(nx,ny)
for i=0,nx-1 do for j=0,ny-1 do begin
;    la_svd,mat,w,u,v
    la_svd,mat2(*,*,i,j),w,u,v
    wi=1/w                      ;&  wi(2)=0.
    imat=v ## diag_matrix(wi) ## conj(transpose(u))*20.
    harm=transpose(reform(cars(i,j,*)))

    tmp=kza(*,*,i,j)
    inz=where(tmp ne 0)
    mkz=median(tmp(inz))

    iharm=imat ## harm
    kappa=1.0
    del1=atan2(iharm(1)) /2/!pi / mkz / kappa
    del2=atan2(iharm(2)) /2/!pi / mkz / kappa

;    delw=(del1*abs(iharm(1)) + del2 * abs(iharm(2))) / (abs(iharm(1))+abs(iharm(2)))
    delw=del2
    delarr(i,j)=delw
    
    pcor2=abs(kzaav(*,i,j))*delw*kappa*(1)
    harm=harm * exp(-2*!pi*complex(0,1)*pcor2)

    s=imat ## harm
    if i eq 50 and j eq 70 then stop


    svec(i,j,*)=s
endfor

;print,kza(*,*,iztmp(0),iztmp(1))-kz0


print,svec(iztmp(0),iztmp(1),*)

 imgplot,atan2(svec(*,*,1))*!radeg,/cb,pal=-2,pos=posarr(2,2,0)


; imgplot,atan(abs(svec(*,*,2)),abs(svec(*,*,1)))*!radeg,/cb,pal=-2,pos=posarr(/next),/noer

 imgplot,atan(float(svec(*,*,2)),float(svec(*,*,1)))*!radeg,/cb,pal=-2,pos=posarr(/next),/noer

 imgplot,delarr*656.1,/cb,pal=-2,pos=posarr(/next),/noer



;print,mat
;print,' '
;print,mat2(*,*,iz(0),iz(1))


;stop
end
