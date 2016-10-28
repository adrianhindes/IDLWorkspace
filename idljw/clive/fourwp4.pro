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


function tcontract,tens1,tens2,ndim=ndim
sz1=size(tens1,/dim) ; e.g. 4x4xn
sz2=size(tens2,/dim) ; e.g. 4.4x3

if ndim eq 0 then szout=[sz1(0)*sz2(0)]
if ndim eq 1 then szout=[sz1(0),sz1(1),sz1(2)*sz2(2)]
if ndim eq 2 then szout=[sz1(0),sz1(1),sz1(2),sz1(3)*sz2(3)]

tout=complexarr(szout)

if ndim eq 1 then for i=0,sz1(0)-1 do $
  tout(i,*,*) = reform( tens1(i,*,*) ## tens2(i,*,*) )



for k1=0,sz1(1)-1 do for k2=0,sz2(1)-1 do 
    tout(i,k1*sz2(1)+k2)=foper( tens1(i,k1), kay2(i,k2) )
endfor
k1=0,

if nd2 eq 3 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do begin
    tout(i,j,k1,k2)=total(tens1(i,*,k1)*tens2(*,j,k2))
endfor
if nd2 eq 4 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do begin
    tout(i,j,k1,k2,k3)=total(tens1(i,*,k1,k2)*tens2(*,j,k3))
endfor
if nd2 eq 5 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do for k4=0,2 do begin
    tout(i,j,k1,k2,k3,k4)=total(tens1(i,*,k1,k2,k3)*tens2(*,j,k4))
endfor
return,tout
end

function kouter,kay1,kay2
sz1=size(kay1,/dim) ; k1 3zxn
sz2=size(kay2,/dim) ; k2 must be 3zx3

szout=[sz1,(0),sz1(1)*sz2(1)]
kout=complexarr(szout)
for i=0,sz1(0)-1 do for k1=0,sz1(1)-1 do for k2=0,sz2(1)-1 do begin
    kout(i,k1*sz2(1)+k2)=kay1(i,k1)+kay2(i,k2)
endfor

return,kout
end


function leftmult,tensmat,regmat;regmat is on left
sz1=size(tensmat,/dim) ; k1 4x4x3... etc
sz2=size(regmat,/dim) ; k2 4x4
nd2=n_elements(sz1)
szout=sz1
tensmult=tensmat*0

if nd2 eq 2 then $
for i=0,3 do for j=0,3 do $
    tensmult(i,j)=total(regmat(*,i) * tensmat(j,*))


if nd2 eq 3 then $
for i=0,3 do for j=0,3 do for k1=0,2 do $
    tensmult(i,j,k1)=total(regmat(*,i) * tensmat(j,*,k1))


if nd2 eq 4 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do $
    tensmult(i,j,k1,k2)=total(regmat(*,i) * tensmat(j,*,k1,k2))

if nd2 eq 5 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do $
    tensmult(i,j,k1,k2,k3)=total(regmat(*,i) * tensmat(j,*,k1,k2,k3))

if nd2 eq 6 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do for k4=0,2 do $
    tensmult(i,j,k1,k2,k3,k4)=total(regmat(*,i) * tensmat(j,*,k1,k2,k3,k4))


return,tensmult
end


function rightmult,tensmat,vec;regmat is on left
sz1=size(tensmat,/dim) ; k1 4x4x3... etc
sz2=size(vec,/dim) ; k2 4
nd2=n_elements(sz1)

szout=sz1
tensmult=complexarr([4,sz1(2:*)])

if nd2 eq 2 then $
for i=0,3 do $
    tensmult(i)=total(tensmat(i,*) * vec)

if nd2 eq 3 then $
for i=0,3 do for k1=0,2 do $
    tensmult(i,k1)=total(tensmat(i,*,k1) * vec)

if nd2 eq 4 then $
for i=0,3 do for k1=0,2 do for k2=0,2 do $
    tensmult(i,k1,k2)=total(tensmat(i,*,k1,k2) * vec)

if nd2 eq 5 then $
for i=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do $
    tensmult(i,k1,k2,k3)=total(tensmat(i,*,k1,k2,k3) * vec)

if nd2 eq 6 then $
for i=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do for k4=0,2 do $
    tensmult(i,k1,k2,k3,k4)=total(tensmat(i,*,k1,k2,k3,k4) * vec)

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
tens0=fourwp(!pi/4,0.25,0.,kvecxy=kvec0)
tens1=fourwp(0,1000.,1,kvecxy=kvec1)
tens2=fourwp(!pi/4,707,0.707,kvecxy=kvec2)
tens3=fourwp(-!pi/4,707,0.707,kvecxy=kvec3)

tout=tcontract(tcontract(tcontract(tens0,tens1),tens2),tens3)

kout=kouter(kouter(kouter(kvec0,kvec1),kvec2),kvec3)
mp=matpol(0)
tout=leftmult(tout,mp)
tout=rightmult(tout,[1,0,0,1])
tout=reform(tout(0,*,*,*,*))


kx=kout(0,*,*,*,*)
ky=kout(1,*,*,*,*)
kz=kout(2,*,*,*,*)

tout=exp(complex(0,1) * 2*!pi*kz) * tout

idx=where(abs(tout) gt 1d-5)
plot,kx(idx),ky(idx),psym=4,xr=[-3,3],yr=[-3,3],/iso,symsize=2
oplot,kx,ky,psym=5,col=2


nterm=n_elements(idx)
for i=0,nterm-1 do print,kz(idx(i)),tout(idx(i)),kx(idx(i)),ky(idx(i))
;kx1=linspace(0,

end
