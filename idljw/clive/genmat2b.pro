pro genmat2b, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav,indexlist=indexlist,useindex=useindex,lam=lam



;gencarriers2,th=th,sh=sh,mat=a2,dmat=da2,tdkz=dkzlist,kx=kxlist,ky=kylist,kz=kzavlist,tkz=kzlist,nkz=nkz,dkx=dkx,dky=dky,quiet=quiet,p=p,str=str,noload=noload,toutlist=toutlist,vth=thv,indexlist=indexlist,vkzv=kzv,lam=lam,frac=frac,fudgethick=fudgethick


gencarriers2,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,indexlist=indexlist,useindex=useindex,lam=lam
;kz0=kz

;print,mat ## transpose([1,1,0,0])/19.7
;print,transpose(reform(car1))

nx=n_elements(thx)
ny=n_elements(thy)

;stop

nidx=n_elements(kx)

sz=size(kz,/dim)
nxn=nx/5
nyn=ny/5
kzs=fltarr(sz(0),sz(1),nxn,nyn)
kza=fltarr(sz(0),sz(1),nx,ny)
thxs=interpol(thx,linspace(0,1,nx),linspace(0,1,nxn))
thys=interpol(thy,linspace(0,1,ny),linspace(0,1,nyn))

ixtmp=linspace(0,nxn-1,nx)
iytmp=linspace(0,nyn-1,ny)

for i=0,nxn-1 do for j=0,nyn-1 do begin
    gencarriers,sh=sh,th=[thxs(i),thys(j)],p=p,str=str,/noload,/quiet,tkz=kz,indexlist=indexlist,useindex=useindex,lam=lam
    kzs(*,*,i,j)=kz
;    print,i,j,nxn,nyn
endfor

for i=0,sz(0)-1 do for j=0,sz(1)-1 do begin
    kza(i,j,*,*)=interpolate(kzs(i,j,*,*),ixtmp,iytmp,/grid,cubic=-0.5)
;    print,i,j,sz
endfor

kzaav=fltarr(nidx,nx,ny)
for i=0,nidx-1 do $
  kzaav(i,*,*)=total(kza(i,0:nkz(i)-1,*,*),2)/nkz(i)


mat2=complexarr(4,nidx,nx,ny)
for i=0,nidx-1 do begin
    nf=nkz(i)
    for j=0,nf-1 do begin
        tmp=reform(exp(2*!pi*complex(0,1)*abs(kza(i,j,*,*)))) ; a(i,j,iz(0),iz(1)))))
                                ;matrix multiply
        for k=0,3 do  mat2(k,i,*,*)+=toutlist(0,k,i,j) * tmp
    endfor
endfor

end ; genmat2
