

pro testitr3
common cb33, img,cars,gap,nbin,mat,thx,thy,iz,p,str,sd
;sh=8046
sh=1615 & lam=659.89e-9 ; full sphere/line cal
shf=1615

;simimgnew,img,sh=sh
img=getimgnew(sh,0)*1.


newdemod,img,cars,gap=gap,nbin=nbin,sh=sh,mat=mat,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,indexlist=ilist0,demodtype='real3',lam=lam


nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
for i=0,nx-1 do thv(i,*,0)=thx(i)
for j=0,ny-1 do thv(*,j,1)=thy(j)


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



gencarriers2,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,vth=thv,vkz=kzv,lam=lam,indexlist=ilist0,dmat=dmat,/useindex,tdkz=dkz, kz=kzav


ilist=ilist0
;stop
;dcar=(dmat) ## transpose([1,0,1,0])
;dph=reform(atan2(dcar))

;for i=0,3 do kzv(*,*,i)+=dph(i)/2/!pi ; phase corrected for s1 etc.


jj=[16,22];[28,21]
common cmr, phja

carsc = cars
for i=0,3 do carsc(*,*,i) *= exp(-2*!pi*complex(0,1) * kzv(*,*,i))

;stop
carsc(*,*,2)=0.
carsc(*,*,3)*=abs(carsc(*,*,1))/abs(carsc(*,*,3))

;dmat=removeij(dmat,3,2)
;carsc=carsc(*,*,[0,1,3])
la_svd,(dmat),w,u,v
wi=1/w                          ;&  wi(2)=0.
imat=v ## diag_matrix(wi) ## conj(transpose(u))*20.
svec=complexarr(nx,ny,4)

for i=0,nx-1 do for j=0,ny-1 do begin
;    la_svd,mat,w,u,v

    harm=transpose(reform(carsc(i,j,*)))
    s=imat ## harm


    svec(i,j,*)=s
endfor

 imgplot,atan2(svec(*,*,1))*!radeg,/cb,pos=posarr(2,2,0)
 imgplot,atan2(svec(*,*,2))*!radeg,/cb,pos=posarr(/next),/noer


 imgplot,atan(abs(svec(*,*,2)),abs(svec(*,*,1)))*!radeg,/cb,pos=posarr(/next),/noer
 imgplot,atan(float(svec(*,*,2)),float(svec(*,*,1)))*!radeg,/cb,pos=posarr(/next),/noer

stop

end

testitr3
end
