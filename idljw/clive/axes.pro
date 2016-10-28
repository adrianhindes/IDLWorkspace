function rotd,th,ix
if ix eq 2 then begin&i1=0&i2=1&end
if ix eq 1 then begin&i1=0&i2=2&end
if ix eq 0 then begin&i1=1&i2=2&end
mat=identity(3)
mat(i1,i1)=cos(th)
mat(i1,i2)=sin(th)
mat(i2,i1)=-sin(th)
mat(i2,i2)=cos(th)
return,mat
end

function a1,th,phi
;th=20*!dtor
;phi=1*!dtor


a1=rotd(phi,2) ## rotd(th,1) ## transpose([1,0,0])
a2=rotd(phi,2) ## rotd(th,1) ## transpose([0,1,0])
a3=rotd(phi,2) ## rotd(th,1) ## transpose([0,0,1])
pol = [1,0,0]
ang=0*!dtor
pol = [cos(ang),sin(ang),0]


w2=a2 * total(pol*a2)
w1=a1 *  total(pol*a1)

wt=w1+w2
wt=wt/sqrt(total(wt^2))
ang=atan($
          total(pol*a2),$
          total(pol*a1))*!radeg


;print,ang
mat0=fltarr(3,3)
nne=1.4
nno=1.5
mat0(0,0)=nne^2
mat0(1,1)=nno^2
mat0(2,2)=nno^2
mat=mat0
;mat=rotd(!pi/4,0) ## mat0
trb=rotd(-!pi/4,1)
mat=transpose(trb) ## mat0 ## trb


tr=[a1,a2]

mat2=transpose(tr) ## mat ## tr
svdc,mat2,w,u,v
uu=u
if w(0) gt w(1) then begin
    uu(1,*)=u(0,*)
    uu(0,*)=u(1,*)
    u=uu
    w=reverse(w)
endif

    
;c1=u(0,*) 
c1=u(0,*) 

v1 = c1(0) * a1 + c1(1) * a2
v1=v1/v1(0) * abs(v1(0)) ; make sure x compoent is positive because that is the one originally define in pol=[1,0,0] for example
zhat=[0,0,1]
v1p=crossp(v1,zhat)
q=total(wt * v1p)
sgn=q/abs(q)
;rv=asin(total(wt * v1) * sgn)
;stop
rv=acos(total(wt*v1))*sgn
;print,v1(0),v1(1),v1(2),wt(0),wt(1),wt(2),rv
;stop
return,rv
end

function a2,th,phi
sz=size(th,/dim)
nd=size(th,/n_dim)
if nd eq 1 then begin
    arr=fltarr(sz(0) )
    for i=0,sz(0)-1 do arr(i)=a1(th(i),phi(i))
endif


if nd eq 2 then begin
    arr=fltarr(sz(0),sz(1))
    for i=0,sz(0)-1 do for j=0,sz(1)-1 do arr(i,j)=a1(th(i,j),phi(i,j))
endif

return,arr


end

n=7
mx=10.*!dtor
thx1=linspace(-mx,mx,n)
thy1=thx1
thx2=thx1 # replicate(1,n)
thy2=replicate(1,n) # thy1
th2=sqrt(thx2^2+thy2^2)
phi2=atan(thy2,thx2)

z=a2(th2,phi2)
contourn2,z,/cb,pal=-2
end
