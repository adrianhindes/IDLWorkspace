

pro testit3
common cb2, img,cars,gap,nbin,mat,thx,thy,iz,p,str,sd
sh=476

lam=656e-9
gencarriers2,sh=sh,th=[3*!dtor,0],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,tkz=kz,nkz=nkz,mat=mat,dmat=dmat,lam=lam,kz=kzav1

idx=indgen(4);+4
mat=mat(*,idx)
mat=[[mat],[0,0,0,20]]

sz1=size(mat,/dim)

ntmp=100
phi=linspace(0,!pi,ntmp+1) & phi=phi(1:*)
carsarr=complexarr(sz1(1),ntmp)
svec2arr=complexarr(sz1(0),ntmp)
la_svd,(mat),w,u,v
wi=1/w;                          &  wi(3)=0.
imat=v ## diag_matrix(wi) ## conj(transpose(u))


for j=25,ntmp-1 do begin
svec=transpose([4,2*cos(phi(j)),2*sin(phi(j)),0])
cars=mat ## svec

carstmp=transpose([$
complex(      600.415,  4.50505e-08),$
complex(      597.208, -1.18278e-07),$
complex(      91.5674,     -123.104),$
complex(      600.415,  4.50505e-08),$
;complex(      600.415,  4.50505e-08),$
complex(      46.8836,     -146.086),$
complex(      0.00000,      0.00000)])

;cars=carstmp

carsarr(*,j)=cars


carsm=cars
carsm(*,[1])*=exp(complex(0,1)*2*!pi*0.3)
carsm(*,[3])*=exp(complex(0,1)*2*!pi*0.8)
;carsm(*,[5,7])*=exp(complex(0,1)*2*!pi*0.2)
svec2=imat ## carsm

svec2arr(*,j)=svec2

print,atan2(svec2)*!radeg
;stop

endfor

plotm,transpose(atan2(svec2arr))

stop


lam2=lam+0.1e-9
gencarriers2,sh=sh,th=[3*!dtor,0],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,tkz=kz,nkz=nkz,mat=mat,dmat=dmat,lam=lam2,kz=kzav
;mat=mat(*,idx)
;mat=[[mat],[0,0,0,20]]



la_svd,(mat),w,u,v
wi=1/w;                          &  wi(3)=0.
imat=v ## diag_matrix(wi) ## conj(transpose(u))

svec2=imat ## cars
;print,atan2(svec2)*!radeg
;print,'___'
;print,atan2(cars)*!radeg
;print,'___'
;print,abs(cars)


stop

end


testit3
end
