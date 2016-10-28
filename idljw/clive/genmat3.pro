pro genmat3, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav

nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
for i=0,nx-1 do thv(i,*,0)=thx(i)
for j=0,ny-1 do thv(*,j,1)=thy(j)

gencarriers,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,vth=thv,vkz=kzv


end
