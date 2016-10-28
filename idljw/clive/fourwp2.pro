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
sz1=size(tens1,/dim)
sz2=size(tens2,/dim) ; tens2 must be 4x4x3
nd2=n_elements(sz1)
; contract 2ndt index of 1 with 1st index of 2
szout=[sz1,3]
tout=complexarr(szout)
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
sz1=size(kay1,/dim) ; k1 2x3x3x3... etc
sz2=size(kay2,/dim) ; k2 must be 2x3
nd2=n_elements(sz1)

szout=[sz1,3]
kout=fltarr(szout)
if nd2 eq 2 then $
for i=0,2 do for k1=0,2 do for k2=0,2 do begin
    kout(i,k1,k2)=kay1(i,k1)+kay2(i,k2)
endfor

if nd2 eq 3 then $
for i=0,2 do for k1=0,2 do for k2=0,2 do for k3=0,2 do begin
    kout(i,k1,k2,k3)=kay1(i,k1,k2)+kay2(i,k3)
;    if i eq 0 then print,kout[i,k1,k2,k3]
endfor

if nd2 eq 4 then $
for i=0,2 do for k1=0,2 do for k2=0,2 do for k3=0,2 do for k4=0,2 do begin
    kout(i,k1,k2,k3,k4)=kay1(i,k1,k2,k3)+kay2(i,k4)
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
tout=tcontract(tens1,tens2)
kout=kouter(kvec1,kvec2)


tout2=tcontract(tout,tens3)
kout2=kouter(kout,kvec3)
mp=matpol(0)
tout3=leftmult(tout2,mp)
tout4=rightmult(tout3,[1,1,1,0])
tout5=reform(tout4(0,*,*,*))
kx=kout2(0,*,*,*)
ky=kout2(1,*,*,*)
kz=kout2(2,*,*,*)
idx=where(abs(tout5) gt 1d-5)
plot,kx(idx),ky(idx),psym=4,xr=[-3,3],yr=[-3,3],/iso
oplot,kx,ky,psym=5,col=2
end
