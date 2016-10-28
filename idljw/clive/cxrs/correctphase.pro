pro correctphase, sh,carscal, carscal5, db=db,shload=shload,thx=thx,thy=thy,pc=pc,kzv=kzv
;;here phase remap
;print,file_search(getenv('HOME')+'/idl/clive/settings/res'+string(sh,format='(I0)')+'.hdf')

sz=size(carscal,/dim)
thv=fltarr(sz(0),sz(1),2)
for i=0,sz(0)-1 do thv(i,*,0)=thx(i)
for j=0,sz(1)-1 do thv(*,j,1)=thy(j)

hdfrestoreext,getenv('HOME')+'/idl/clive/settings/res'+string(shload,format='(I0)')+'.hdf',res

readpatch,sh,str,db=db
readcell,str.cellno,strcell

readancal, shload, xpar
strcell2=strcell
applycal_cxr, strcell2,xpar

;gencarriers2,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=strtmp,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,vth=thv,vkz=kzv,lam=lam,indexlist=ilist0,dmat=dmat,/useindex

;carscal- contrasts and phases of calibration
;carscal2 - fit of calibration i.e. expected at 532nm
;correction- deficit between calibration and fit of calirbation
;carscal3 - contrast and phase expected at 529nm
;carscal4 - phase corrected for deficit
lam=532.0e-9 ;+ 0.3e-9;   + 0.2e-9
gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
s1=kz

gencarriers2,th=[0,0],p=str,str=strcell2,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex


carscal2 = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)

correction=carscal/carscal2

lamplas=529.1e-9 - 0.3e-9 ;05e-9 
lam=lamplas + 0.1e-9 ; 0.1nm shift

gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
s2=kz
gencarriers2,th=[0,0],p=str,str=strcell2,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex

carscal3b = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)

lam=lamplas

gencarriers2,th=[0,0],p=str,str=strcell,/noload,kx=kx,ky=ky,kz=kz,lam=lam,db=db,indexlist=ilist0
s2=kz
gencarriers2,th=[0,0],p=str,str=strcell2,/noload,kx=kx,ky=ky,kz=kzd,lam=lam,db=db,vth=thv,vkzv=kzv,indexlist=ilist0,/useindex

carscal3 = abs(carscal) * exp(complex(0,1)*2*!pi*kzv)


carscal4 = carscal3 * correction
carscal5 = carscal4 * (-1) ; corrected for 180deg phase shift for reflect not transmit
if size(sh,/type) eq 7 then if sh eq 'cxrstest4_tuni_lasertr' then carscal5=carscal4 ; no shift

pc=carscal3b/carscal3

end
