function f, a, delay
common cbb,cl0,cl1,cl2,cap1,cap2,ctedge
;[vcore,tcore,tcore2,aa0]
vcore=a(0)
tcore=a(1)
tcore2=a(2)
tcore3=a(3)
aa0=a(4)
ap0=1-aa0;a(3)
l0=cl0
l1=cl1
l2=cl2
ap1=cap1
ap2=cap2
tedge=ctedge

forward_function fgaussof

fa0=aa0 * fgaussof(delay,l0,vcore,tcore) 
fp0=ap0 * fgaussof(delay,l0,0,tedge)
fp1=ap1 * fgaussof(delay,l1,0,tedge)
fp2=ap2 * fgaussof(delay,l2,0,tedge)

ftot1=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

fa0=aa0 * fgaussof(delay,l0,vcore,tcore2) 

ftot2=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

fa0=aa0 * fgaussof(delay,l0,vcore,tcore3) 

ftot3=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

ftot=[ftot1,ftot2,ftot3]


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

vth=sqrt(2 * echarge * ti/mi)/clight

vrotc=vrot/clight
dl=(l0-lref)/lref
ii=complex(0,1)
gamma=exp(2*!pi*ii*N* (1+ kappa * (vrotc + dl)) - (!pi*kappa*N)^2 * vth^2)

return,gamma
end




tedge=50.
tcore=2000.
tcore2=1000.
tcore3=500.
vcore=100e3

l0=529.0

l1 = 529.4
l2=530.4

ap0=1.
ap1=0.;0.05
ap2=0.;1
aa0=3.

asum=aa0+ap0+ap1+ap2

aa0/=asum
ap0/=asum
ap1/=asum
ap2/=asum

nlam=1001
lam=linspace(-5,5,nlam)+l0



a0=aa0 * gaussof(lam,l0,vcore,tcore) 
p0=ap0 * gaussof(lam,l0,0,tedge)
p1=ap1 * gaussof(lam,l1,0,tedge)
p2=ap2 * gaussof(lam,l2,0,tedge)
;mkfig,'~/jaw_spec.eps',xsize=12,ysize=11,font_size=9
plot,lam,a0+p0+p1+p2+0.02,yr=[0,.3],xr=[528,531],xsty=1,thick=2
oplot,lam,a0,col=2,thick=2
oplot,lam,p0,col=3,thick=2,linesty=1
oplot,lam,p1,col=4,thick=2,linesty=1
oplot,lam,p2,col=5,thick=2,linesty=1
;endfig,/gs,/jp
;stop

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

;cprop2,cdb(*,n-2),delay,kay,kappa=kappa&print,delay,kay,kappa
;cprop2,cdb(*,n-1),delay,kay,kappa=kappa&print,delay,kay,kappa
;retall
for i=0,n-1 do begin
if cdb(0,i) ne 1 then continue
if cdb(2,i) eq 0 then continue

for j=i,n-1 do begin
if cdb(0,j) ne 1 then continue
if cdb(2,j) eq 0 then continue


cprop2,cdb(*,i),delay1,kay1,kappa=kappa1 & delay1*=kappa1
;print,cdb(0,i),cdb(1,i),cdb(2,i),delay,kay

cprop2,cdb(*,j),delay2,kay2,kappa=kappa2 & delay2*=kappa2
print,'i=',i,'j=',j
;kay root 2
kay2=kay2*sqrt(2)
;print,'kappa1=',kappa1,'kappa2=',kappa2
print,cdb(0,i),cdb(1,i),cdb(2,i),cdb(0,j),cdb(1,j),cdb(2,j)
print,delay1,delay2,delay1+delay2,delay1-delay2
print,kay1,kay2,sqrt(kay1^2+kay2^2),atan(kay2,kay1)*!radeg
print,'____'

;delay2=0.

;delay1=600.*8/14*0.5&delay2=800*8/14*0.5
; 62101.2      36112.8      93135.7      333.426
;delay1=600.*8/14&delay2=800*8/14
;12515.2      9588.70      16268.6. 52
;delay1=600.&delay2=800.
;   65411.4      15908.6      10195.0, 178


if i eq 0 and j eq 4 then mkfig,'~/jaw_fts1.eps',xsize=11,ysize=7,font_size=8
plot,delay,abs(ftot),title=string(kay1,kay2,sqrt(kay1^2+kay2^2),atan(kay2,kay1)*!radeg),xtitle='group delay (waves)',ytitle='contrast'
oplot,delay1*[1,1],!y.crange,linesty=2,col=2
oplot,delay2*[1,1],!y.crange,linesty=2,col=4
oplot,(delay1+delay2)*[1,1],!y.crange,linesty=2,col=3
oplot,abs(delay1-delay2)*[1,1],!y.crange,linesty=2,col=5

if i eq 0 and j eq 4 then begin
    endfig,/gs,/jp
    stop
endif
vec=[delay1,delay2,delay1+delay2,delay1-delay2]
wt=[2,2,1,1,2,2,1,1,2,2,1,1]
;vec=[delay1]

common cbb,cl0,cl1,cl2,cap1,cap2,ctedge
cl0=l0
cl1=l1
cl2=l2
cap1=ap1
cap2=ap2
ctedge=tedge
par=[vcore,tcore,tcore2,tcore3,aa0]
calches,par,vec,hes,scal=par*0.01,wt=wt

svdc,hes,w,u,v
;print,1/(min(w)/max(w)) , 1e-4/hes(1,1),1e-4/hes(2,2)
ihes=invert(hes)
print,ihes(1,1),ihes(2,2),ihes(3,3),max(w)/min(w)

;calcsens,vec,sens,l0=l0,vcore=vcore,tcore=[500.],tedge=tedge,l1=l1,l2=l2,aa0=aa0,ap0=ap0,ap1=ap1,ap2=ap2


;print,sens

;stop



;aa=''&read,'',aa


endfor


endfor




end


