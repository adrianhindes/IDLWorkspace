

pro testitr
common cb2, img,cars,gap,nbin,mat,thx,thy,iz,p,str,sd
;sh=8046
sh=1615 & lam=659.89e-9 ; full sphere/line cal
shf=1615

;simimgnew,img,sh=sh
img=getimgnew(sh,0)*1.


newdemod,img,cars,gap=gap,nbin=nbin,sh=sh,mat=mat,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,indexlist=ilist0,demodtype='real3',lam=lam


nx=n_elements(thx)
ny=n_elements(thy)

iztmp=iz
iztmp(0)+=30
iztmp(1)+=30
car1=cars(iztmp(0),iztmp(1),*)


readancal, shf, xpar
applycal, str, xpar

hdfrestoreext,getenv('HOME')+'/idl/clive/settings/res'+string(sh,format='(I0)')+'.hdf',res

jj=[16,22];[28,21]
for k=0,1 do begin
    j=jj(k)
    r=res.(k)
    ii=(where(ilist0 eq j))(0)
    cars(*,*,ii) = cars(*,*,ii) * exp(complex(0,1)* 2 * !pi * r)
endfor
    
;stop

gencarriers,sh=sh,th=[thx(iztmp(0)),thy(iztmp(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,indexlist=ilist0,/useindex,lam=lam




 genmat2, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav, indexlist=ilist0,/useindex,lam=lam


cars(*,*,2)=0.
svec=complexarr(nx,ny,4)
delarr=fltarr(nx,ny)
carsim=cars*0.
for i=0,nx-1 do for j=0,ny-1 do begin
;    la_svd,mat,w,u,v
    la_svd,mat2(*,*,i,j),w,u,v

    carsim(i,j,*) = mat2(*,*,i,j) # [1,1,0,0]

    wi=1/w                      ;&  wi(2)=0.
    imat=v ## diag_matrix(wi) ## conj(transpose(u))*20.
    harm=transpose(reform(cars(i,j,*)))

    tmp=kza(*,*,i,j)
    inz=where(tmp ne 0)
    mkz=mean(tmp(inz))

    iharm=imat ## harm
    kappa=1.0
    del1=atan2(iharm(1)) /2/!pi / mkz / kappa
    del2=atan2(iharm(2)) /2/!pi / mkz / kappa

;    delw=(del1*abs(iharm(1)) + del2 * abs(iharm(2))) / (abs(iharm(1))+abs(iharm(2)))
    delw=del1

    delarr(i,j)=delw
    
    pcor2=abs(kzaav(*,i,j))*delw*kappa*(1)
    harm=harm * exp(-2*!pi*complex(0,1)*pcor2)
;    stop

    s=imat ## harm


    svec(i,j,*)=s
endfor



ph=atan2(cars(*,*,1))
jumpimg,ph
ph -= fix(ph(iz(0),iz(1)))

phsim=atan2(carsim(*,*,1))
jumpimg,phsim
phsim -= fix(phsim(iz(0),iz(1)))

imgplot,ph,pos=posarr(2,1,0),/cb
imgplot,phsim,pos=posarr(/next),/noer,/cb

;stop

;print,kza(*,*,iztmp(0),iztmp(1))-kz0


print,svec(iztmp(0),iztmp(1),*)

 imgplot,atan2(svec(*,*,1))*!radeg,/cb,pos=posarr(2,2,0)
 imgplot,atan2(svec(*,*,2))*!radeg,/cb,pos=posarr(/next),/noer


; imgplot,atan(abs(svec(*,*,2)),abs(svec(*,*,1)))*!radeg,/cb,pal=-2,pos=posarr(/next),/noer

 imgplot,atan(abs(svec(*,*,2)),abs(svec(*,*,1)))*!radeg,/cb,pos=posarr(/next),/noer

 imgplot,delarr*656.1,/cb,pos=posarr(/next),/noer
stop


;print,mat
;print,' '
;print,mat2(*,*,iz(0),iz(1))


stop
end
testitr
end
