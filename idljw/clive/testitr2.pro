

pro testitr2
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
    


nx=n_elements(thx)
ny=n_elements(thy)

mul=1
nx2=nx/mul
ny2=ny/mul
isubx=indgen(nx2)*mul
isuby=indgen(ny2)*mul
iz2=[value_locate(isubx,iz(0)),value_locate(isuby,iz(1))]
thx2=thx(isubx)
thy2=thy(isuby)

thv=fltarr(nx2,ny2,2)
for i=0,nx2-1 do thv(i,*,0)=thx2(i)
for j=0,ny2-1 do thv(*,j,1)=thy2(j)


;stop

gencarriers,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,indexlist=ilist0,/useindex,lam=lam,vth=thv,vkz=kzv


ph=atan2(cars(*,*,1))
jumpimg,ph
ph -= fix(ph(iz(0),iz(1)))

phsim=kzv(*,*,1)
phsim -= fix(phsim(iz(0),iz(1)))




ph=ph/2/!pi
imgplot,ph,pos=posarr(3,1,0),/cb
imgplot,phsim,pos=posarr(/next),/cb,/noer
imgplot,ph-phsim,pos=posarr(/next),/cb,/noer
stop
end
testitr2
end
