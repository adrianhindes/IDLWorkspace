@calches
function f, a, delay
common cbb,cl0,cl1,cl2,cap1,cap2,ctedge
;[vcore,tcore,tcore2,aa0]
vcore=a(0)
tcore=a(1)
tedge=a(3)
;tcore2=a(2)
;tcore3=a(3)
aa0=a(2)
ap0=1-aa0;a(3)
l0=cl0
l1=cl1
l2=cl2
ap1=cap1
ap2=cap2
;tedge=ctedge

forward_function fgaussof

fa0=aa0 * fgaussof(delay,l0,vcore,tcore) 
fp0=ap0 * fgaussof(delay,l0,0,tedge)
fp1=ap1 * fgaussof(delay,l1,0,tedge)
fp2=ap2 * fgaussof(delay,l2,0,tedge)

ftot1=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

;fa0=aa0 * fgaussof(delay,l0,vcore,tcore2) 

;ftot2=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

;fa0=aa0 * fgaussof(delay,l0,vcore,tcore3) 

;ftot3=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

ftot=[ftot1];,ftot2,ftot3]

;print,'called f, a=',a,'delay=',delay,'result=',ftot
;if a(0) ne 1.8 then stop

return,ftot
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

kappa=1.

default,lref,529.0


echarge=1.6e-19
mi=6*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti*1e3/mi)/clight
;vrot in units of 100km/s, ti in units of 1000eV
vrotc=(vrot * 100e3)/clight
dl=(l0-lref)/lref
ii=dcomplex(0,1)
gamma=exp(2*!pi*ii*N* (1+ kappa * (vrotc + dl)) - (!pi*kappa*N)^2 * vth^2)

return,gamma
end




tedge=0.6;01
tcore=1.
vcore=2.*  sqrt(tcore/3.5)



dmax=1500
wthr=1e59 ; 1e3


l0=529.0

l1 = 529.4
l2=530.4

ap0=0.2
ap1=0.;05
ap2=0.;1
aa0=1.

asum=aa0+ap0+ap1+ap2

aa0/=asum
ap0/=asum
ap1/=asum
ap2/=asum

nlam=1001
lam=linspace(-5,5,nlam)+l0



; a0=aa0 * gaussof(lam,l0,vcore,tcore) 
; p0=ap0 * gaussof(lam,l0,0,tedge)
; p1=ap1 * gaussof(lam,l1,0,tedge)
; p2=ap2 * gaussof(lam,l2,0,tedge)

; plot,lam,a0+p0+p1+p2,yr=[0,1]
; oplot,lam,a0,col=2
; oplot,lam,p0,col=3
; oplot,lam,p1,col=4
; oplot,lam,p2,col=5

;retall
par=[vcore,tcore,aa0,tedge]*1d0

delay=linspace(0,5000,151)
ftot=f(par,delay)
;fa0=aa0 * fgaussof(delay,l0,vcore,tcore) 
;fp0=ap0 * fgaussof(delay,l0,0,tedge)
;fp1=ap1 * fgaussof(delay,l1,0,tedge)
;fp2=ap2 * fgaussof(delay,l2,0,tedge)
;
;ftot=fa0+fp0+fp1+fp2


fref=fgaussof(delay,l0,0,0.1) 

plot,delay,abs(ftot)

n1=20
n2=20
del1=(linspace(0,dmax,n1+1))(1:*)
del2=(linspace(0,dmax,n2+1))(1:*)

met1=fltarr(n1,n2)&met2=met1&met3=met1

for i=0,n1-1 do for j=0,n2-1 do begin
;for i=n1/2,n1-1 do for j=n2-1,n2-1 do begin
delay1=del1(i) & delay2=del2(j)
plot,delay,abs(ftot);,title=string(kay1,kay2,sqrt(kay1^2+kay2^2),atan(kay2,kay1)*!radeg)
plot,delay,atan2(ftot/fref),col=3,xsty=4,ysty=4,/noer;,title=string(kay1,kay2,sqrt(kay1^2+kay2^2),atan(kay2,kay1)*!radeg)

oplot,delay1*[1,1],!y.crange,linesty=2,col=2
oplot,delay2*[1,1],!y.crange,linesty=2,col=4

vec=[delay1,delay2]
wt=[1,1]

common cbb,cl0,cl1,cl2,cap1,cap2,ctedge
cl0=l0
cl1=l1
cl2=l2
cap1=ap1
cap2=ap2
ctedge=tedge
scal=[1,1,1,1]*1d-5
calches,par,vec,hes,scal=scal,wt=wt
calches,par,vec,hes2,scal=scal/2,wt=wt
outby=max(abs(hes2/hes-1))
if outby gt 0.05 then begin
    print,'hessian error'
    print,hes/hes2,outby
;    hes*=!values.d_nan


;    stop
;    continue
endif else print, 'hessian status:',outby
eval = float(HQR(ELMHES(hes), /DOUBLE))
;hes(1,2)=hes(2,1)
;hes(0,2)=hes(2,0)
;hes(0,1)=hes(1,0)
;eval=eigenql(hes)
print,'eigenvalues:',eval
if total(eval gt 0) ne 4 then continue
svdc,hes,w,u,v,/double




; print, 'final error overall',sqrt(total(1/w * u(*,2)^2) )

;print,1/(min(w)/max(w)) , 1e-4/hes(1,1),1e-4/hes(2,2)
ihes=invert(hes)
;ihes=pseudoinvtomo(hes,maxcondition=1e5)
ihes0=ihes
ihes=sqrt(ihes)
print,ihes(1,1),ihes(2,2);,ihes(3,3);,max(w)/min(w)
print,sqrt(1/hes(1,1)),sqrt(1/hes(2,2));,sqrt(1/hes(3,3))

met1(i,j)=ihes(1,1)
met2(i,j)=max(w)/min(w)
met3(i,j)=sqrt(1/hes(1,1)) ; ihes(3,3)
met3(i,j)=ihes(3,3)


;stop
if n_elements(ii) ne 0 then begin
aa=''
    if i eq ii and j eq jj then stop; read,'',aa
endif
;stop
endfor


tmp=1/met1
idx=where(finite(tmp) eq 0 ) & tmp(idx)=0. ;or met2 gt wthr

imgplot,tmp,del1,del2,title=string(tcore,vcore,ap0/aa0),/cb,pos=posarr(2,2,0)

dum=max(tmp,imax)
del1b=del1 # replicate(1,n2)
del2b=replicate(1,n1) # del2
pk=[del1b(imax),del2b(imax)]
print,pk

ii=value_locate(del1,pk(0))
jj=  value_locate(del2,pk(1))
print,ii,jj
plots,pk,psym=4,col=2
imgplot,1/met3,del1,del2,/cb,pos=posarr(/next),title='pas cmp',/noer
imgplot,alog10(met2),del1,del2,/cb,pos=posarr(/next),/noer

plot,del2,tmp(*,jj),psym=-4,pos=posarr(/next),/noer

end


