function fcalc,delay=delay,l0=l0,vcore=vcore,tcore=tcore,tedge=tedge,l1=l1,l2=l2,aa0=aa0,ap0=ap0,ap1=ap1,ap2=ap2

forward_function fgaussof

fa0=aa0 * fgaussof(delay,l0,vcore,tcore) 
fp0=ap0 * fgaussof(delay,l0,0,tedge)
fp1=ap1 * fgaussof(delay,l1,0,tedge)
fp2=ap2 * fgaussof(delay,l2,0,tedge)

ftot=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

return,ftot
end

pro calcsens, delay, csq,l0=l0,vcore=vcore,tcore=tcore,tedge=tedge,l1=l1,l2=l2,aa0=aa0,ap0=ap0,ap1=ap1,ap2=ap2



nn=4
csq=fltarr(nn)
mat=fltarr(nn,nn)
for i=0,nn-1 do begin
for j=0,nn-1 do begin
    for jj=0,n_elements(tcore)-1 do begin
    vcore1=vcore
    tcore1=tcore(jj)
    tedge1=tedge
    aa01=aa0
    ap01=ap0
    ap11=ap1
    ap21=ap2


    f0=fcalc(delay=delay,l0=l0,vcore=vcore,tcore=tcore1,tedge=tedge,l1=l1,l2=l2,aa0=aa0,ap0=ap0,ap1=ap1,ap2=ap2)


    fac=1.1

    if i eq 0 then vcore1*=fac
    if i eq 1 then tcore1*=fac
    if i eq 4 then tedge1*=fac
;    if i eq 2 then aa01*=fac
;    if i eq 3 then ap01*=fac
    if i eq 2 then aa01+=(fac-1)
    if i eq 3 then ap01+=(fac-1)
    if i eq 5 then ap11*=fac
    if i eq 6 then ap21*=fac
    
    if i ne j then begin
        if j eq 0 then vcore1*=fac
        if j eq 1 then tcore1*=fac
        if j eq 4 then tedge1*=fac
        if j eq 2 then aa01+=(fac-1)
        if j eq 3 then ap01+=(fac-1)
;    if j eq 2 then aa01*=fac
;    if j eq 3 then ap01*=fac
        if j eq 5 then ap11*=fac
        if j eq 6 then ap21*=fac
        
    endif

    f1=fcalc(delay=delay,l0=l0,vcore=vcore1,tcore=tcore1,tedge=tedge1,l1=l1,l2=l2,aa0=aa01,ap0=ap01,ap1=ap11,ap2=ap21)

    f1=fcalc(delay=delay,l0=l0,vcore=vcore1,tcore=tcore1,tedge=tedge1,l1=l1,l2=l2,aa0=aa01,ap0=ap01,ap1=ap11,ap2=ap21)

    mat(i,j)+=total(abs(f1-f0)^2)


endfor
endfor

endfor

;imat=invert(mat)
;csq=sqrt(diag_matrix(imat))


hes=mat
for i=0,nn-1 do for j=0,nn-1 do hes(i,j)=mat(i,j)-mat(i,i)-mat(j,j)
for i=0,nn-1 do hes(i,i)=2*mat(i,i)

svdc,hes,w,u,v
print,'w=',w/max(w)
csq=[mat(2,2)/mat(1,1),mat(1,1),mat(2,2)]
stop

;csq1=1/sqrt(csq/fac^2)

end





function gaussof,lam,l0,vrot,ti



echarge=1.6e-19
mi=6*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti/mi)/clight
scal=4e4/clight

vel=(lam-l0)/l0

val=exp(-(vel-vrot/clight)^2 / vth^2) / (vth/scal)
return,val
end

function fgaussof,N,l0,vrot,ti,lref=lref

kappa=1.11

default,lref,529.0


echarge=1.6e-19
mi=6*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti/mi)/clight

vrotc=vrot/clight
dl=(l0-lref)/lref
ii=complex(0,1)
gamma=exp(2*!pi*ii*N* (1+ kappa * (vrotc + dl)) - (!pi*kappa*N)^2 * vth^2)

return,gamma
end




tedge=50.
tcore=2000.
vcore=100e3

l0=529.0

l1 = 529.4
l2=530.4

ap0=1.
ap1=0.;05
ap2=0.;1
aa0=3.


nlam=1001
lam=linspace(-5,5,nlam)+l0



a0=aa0 * gaussof(lam,l0,vcore,tcore) 
p0=ap0 * gaussof(lam,l0,0,tedge)
p1=ap1 * gaussof(lam,l1,0,tedge)
p2=ap2 * gaussof(lam,l2,0,tedge)

plot,lam,a0+p0+p1+p2,yr=[0,1]
oplot,lam,a0,col=2
oplot,lam,p0,col=3
oplot,lam,p1,col=4
oplot,lam,p2,col=5


delay=linspace(0,5000,151)
fa0=aa0 * fgaussof(delay,l0,vcore,tcore) 
fp0=ap0 * fgaussof(delay,l0,0,tedge)
fp1=ap1 * fgaussof(delay,l1,0,tedge)
fp2=ap2 * fgaussof(delay,l2,0,tedge)

ftot=fa0+fp0+fp1+fp2

plot,delay,abs(ftot)

cbbo,n_e=n_e,n_o=n_o,lambda=529e-9

;
;d1= opd(0,0,par={crystal:'bbo',thickness:2e-3,facetilt:45.*!dtor,lambda:529.e-9},delta0=0.)/2/!pi
;d2= opd(0,0,par={crystal:'bbo',thickness:7.5e-3,facetilt:45.*!dtor,lambda:529.e-9},delta0=0.)/2/!pi
;oplot,d1*[1,1],!y.crange,linesty=2,col=2
;oplot,d2*[1,1],!y.crange,linesty=2,col=4
;oplot,(d1+d2)*[1,1],!y.crange,linesty=2,col=3
;oplot,abs(d1-d2)*[1,1],!y.crange,linesty=2,col=5

;-1 =  savart
;1=bbo
;2=ln
cdb=[$
[1,6.,45],$
[1,5.,30],$
[1,7.5,35],$
[1,5,45],$
[1,4,45],$
[1,3,45],$
[-1,2,45],$
[-1,2.5,45],$
[2,1.,45],$
[-2,2,45],$
[1,2.2,0],$
[1,1.0,0],$
[1,2.0,0],$
[2,0.6,0],$
[2,2.0,0]]

n=n_elements(cdb(0,*))
for i=0,n-1 do begin
if cdb(0,i) ne 1 then continue
if cdb(2,i) eq 0 then continue

for j=i,n-1 do begin
if cdb(0,j) ne 1 then continue
if cdb(2,j) eq 0 then continue


cprop2,cdb(*,i),delay1,kay1
;print,cdb(0,i),cdb(1,i),cdb(2,i),delay,kay

cprop2,cdb(*,j),delay2,kay2
print,'i=',i,'j=',j
print,cdb(0,i),cdb(1,i),cdb(2,i),cdb(0,j),cdb(1,j),cdb(2,j)
print,delay1,delay2,delay1+delay2,delay1-delay2
print,kay1,kay2,sqrt(kay1^2+kay2^2),atan(kay2,kay1)*!radeg
print,'____'

;delay2=0.

;delay1=358.&delay2=0.


plot,delay,abs(ftot),title=string(kay1,kay2,sqrt(kay1^2+kay2^2),atan(kay2,kay1)*!radeg)
oplot,delay1*[1,1],!y.crange,linesty=2,col=2
oplot,delay2*[1,1],!y.crange,linesty=2,col=4
oplot,(delay1+delay2)*[1,1],!y.crange,linesty=2,col=3
oplot,abs(delay1-delay2)*[1,1],!y.crange,linesty=2,col=5

vec=[0,delay1,delay2,delay1+delay2,delay1-delay2]
;vec=[delay1]


calcsens,vec,sens,l0=l0,vcore=vcore,tcore=[500.],tedge=tedge,l1=l1,l2=l2,aa0=aa0,ap0=ap0,ap1=ap1,ap2=ap2


print,sens





aa=''&read,'',aa


endfor


endfor




end


