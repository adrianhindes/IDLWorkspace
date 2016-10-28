function Power, a, p
return, a^p
end

function fourwp, r,d,k,kvecxyz=kvecxyz
Pi=!pi


mat0=$
[[$
Sqrt(2*Pi),$
0,$
0,$
0],$
[$
0,$
Sqrt(2*Pi)*Power(Cos(2*r),2),$
Sqrt(Pi/2.)*Sin(4*r),$
0],$
[$
0,$
Sqrt(Pi/2.)*Sin(4*r),$
Sqrt(2*Pi)*Power(Sin(2*r),2),$
0],$
[$
0,$
0,$
0,$
0]]
matp=[$
[$
0,$
0,$
0,$
0],$
[$
0,$
Sqrt(Pi/2.)*Power(Sin(2*r),2),$
-(Sqrt(Pi/2.)*Sin(4*r))/2.,$
Complex(0,1)*Sqrt(2*Pi)*Cos(r)*Sin(r)],$
[$
0,$
-(Sqrt(Pi/2.)*Sin(4*r))/2.,$
Sqrt(Pi/2.)*Power(Cos(2*r),2),$
Complex(0,-1)*Sqrt(Pi/2.)*Cos(2*r)],$
[$
0,$
Complex(0,-1)*Sqrt(2*Pi)*Cos(r)*Sin(r),$
Complex(0,1)*Sqrt(Pi/2.)*Cos(2*r),$
Sqrt(Pi/2.)]]

matn=conj(matp)


kvec=[0,1,-1]*k
kvecx=kvec * cos(r)
kvecy=kvec * sin(r)
kvecz=[0,1,-1]*d
kvecxyz=transpose([[kvecx],[kvecy],[kvecz]])
tens=complexarr(4,4,3)
tens(*,*,0)=mat0
tens(*,*,1)=matp
tens(*,*,2)=matn
return,tens
end

function tcontract,tens1,tens2
sz1=size(tens1,/dim) ; 4x4;n
sz2=size(tens2,/dim) ; 4x4;m .e.g. 3
n1=sz1(2)
n2=sz2(2)
n=n1*n2
szout=sz1 & szout(2)=n
tout=complexarr(szout)
for i=0,3 do for j=0,3 do for k1=0,n1-1 do for k2=0,n2-1 do begin
    tout(i,j,k1*n2 + k2)=total(tens1(i,*,k1)*tens2(*,j,k2))
endfor
return,tout
end

function kouter,kay1,kay2
sz1=size(kay1,/dim)
sz2=size(kay2,/dim)
n1=sz1(1)
n2=sz2(1)
n=n1*n2
szout=sz1 & szout(1)=n
kout=fltarr(szout)
for i=0,2 do for k1=0,2 do for k2=0,2 do begin
    kout(i,k1*n2+k2)=kay1(i,k1)+kay2(i,k2)
endfor

return,kout
end


function leftmult,tensmat,regmat
sz1=size(tensmat,/dim) 
sz2=size(regmat,/dim) 
nd2=n_elements(sz1)
n1=sz1(2)
szout=sz1
tensmult=tensmat*0

for i=0,3 do for j=0,3 do for k1=0,n1-1 do $
    tensmult(i,j,k1)=total(regmat(*,i) * tensmat(j,*,k1))

return,tensmult
end


function rightmult,tensmat,vec
sz1=size(tensmat,/dim) 
sz2=size(vec,/dim) 
n1=sz1(2)
szout=sz1
tensmult=complexarr([4,sz1(2)])

for i=0,3 do for k1=0,n1-1 do $
    tensmult(i,k1)=total(tensmat(i,*,k1) * vec)
return,tensmult
end

function matpol, r
matpol=$
[[$
0.5,$
Cos(2*r)/2.,$
Sin(2*r)/2.,$
0],$
[$
Cos(2*r)/2.,$
Power(Cos(2*r),2)/2.,$
(Cos(2*r)*Sin(2*r))/2.,$
0],$
[$
Sin(2*r)/2.,$
(Cos(2*r)*Sin(2*r))/2.,$
Power(Sin(2*r),2)/2.,$
0],$
[$
0,$
0,$
0,$
0]]
return,matpol
end

;test
tens0=fourwp(0,0.25,0.,kvecxy=kvec0)
tens1=fourwp(0,1.,1,kvecxy=kvec1)
tens2=fourwp(!pi/4,.707,0.707,kvecxy=kvec2)
tens3=fourwp(-!pi/4,.707,0.707,kvecxy=kvec3)

tout=tcontract(tcontract(tcontract(tens0,tens1),tens2),tens3)


kout=kouter(kvec0,kvec1)
kout=kouter(kout,kvec2)
kout=kouter(kout,kvec3)

mp=matpol(0)
tout3=leftmult(tout,mp)
tout4=rightmult(tout3,[1,1,1,0])
tout5=reform(tout4(0,*))
kx=kout(0,*)
ky=kout(1,*)
kz=kout(2,*)
idx=where(abs(tout5) gt 1d-5)
plot,kx(idx),ky(idx),psym=4,xr=[-3,3],yr=[-3,3],/iso
oplot,kx,ky,psym=5,col=2
end
