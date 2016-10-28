@calches
function f, a, delay

common cbb,cl0,cl1,cl2,cap1,cap2,ctedge,ctemp1
;[vcore,tcore,tcore2,aa0]
vcore=a(0)
tcore=a(1)
lr=a(2)
lr2=a(3)
;; tedge=a(3)
;; vcore2=a(4)
;; tcore2=a(5)
;; vcore3=a(6)
;; tcore3=a(7)
;; ap1 = a(8)
;; aa0_2=a(9)
;; aa0_3=a(10)
;; tedge_2=a(11)
;; tedge_3=a(12)
;; ap1_2 = a(13)
;; ap1_3 = a(14)



;ap0=1-aa0 - ap1;a(3)
;ap0_2=1-aa0_2 - ap1_2;a(3)
;ap0_3=1-aa0_3 - ap1_3;a(3)


l0=cl0
l1=cl1
l2=cl2
;l2=cl2
;ap1=cap1
;ap2=cap2
;tedge=ctedge

forward_function fgaussof


;fp1=ap1 * fgaussof(delay,l1,0,tedge)
;fp2=ap2 * fgaussof(delay,l2,0,tedge)
fa0=lr * fgaussof(delay,l0,vcore,tcore) 
fp0=(1-lr-lr2) * fgaussof(delay,l1,vcore,tcore)
fha=lr2 *  fgaussof(delay,l2,0,0.0001)

;    endif
ftottmp=(fa0+fp0+fha)               ;/(aa0+ap0+ap1)
ftot=ftottmp    
;    if kk gt 0 then ftot=[ftot,ftottmp] else ftot=ftottmp
;endfor

;print,'called f, a=',a,'delay=',delay,'result=',ftot
;if a(0) ne 1.8 then stop
;stop
return,ftot
end



function gaussof,lam,l0,vrot,ti



echarge=1.6e-19
mi=12*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti/mi)/clight
scal=4e4/clight

vel=(lam-l0)/l0

val=exp(-(vel-vrot/clight)^2 / vth^2) / (vth/scal)
return,val
end

function fgaussof,N,l0,vrot,ti,lref=lref

kappa=1.

default,lref,658.0;7.7;88;7;529.0


echarge=1.6e-19
mi=12*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti*10./mi)/clight
;nononovrot in units of 100km/s, ti in units of 1000eV
;vrot in 1km/s
;ti in eV
vrotc=(vrot * 1e5)/clight
dl=(l0-lref)/lref
ii=dcomplex(0,1)
gamma=exp(2*!pi*ii*N* (1*0+ kappa * (vrotc + dl)) - (!pi*kappa*N)^2 * vth^2)

return,gamma
end


;goto,eeee

;tedge=0.5 
;tcore=3.5 & w1=3.
;tcore2=1.0 & w2=1.
;tcore3=0.7 & w3=1.

tcore=2. ;& w1=1.
;tcore2=2.5 & w2=1.
;tcore3=1.7 & w3=1.

;tcore=2.5 & w1=10.
;tcore2=1.7 & w2=1.
;tcore3=1.5 & w3=1.
vcore=0.0 ;* sqrt(tcore/2.5)
;vcore2=vcore*sqrt(tcore2/tcore)
;vcore3=vcore*sqrt(tcore3/tcore)



dmax=1000
wthr=1e59 ; 1e3


l0=657.7

;l1 = 529.4
l1=658.3

l2 = 656.3 ; halpha

lr=0.65
lr2=0.1

;temp1 = 40;20; width of filter


;ap0=0.2
;ap1=0.2
;ap2=0.;1
;aa0=1.

;ff=2.
;ap0=0.17
;ap1=0.35*ff
;ap2=0.;1
;aa0=(1-.17-.35)

;ap0_2=0.17
;ap1_2=0.28*ff
;aa0_2=(1-.17-.28)

;ap0_3=0.19
;ap1_3=0.2*ff
;aa0_3=(1-.19-.2)


;asum=aa0+ap0+ap1+ap2

;aa0/=asum
;ap0/=asum
;ap1/=asum
;ap2/=asum

;asum=aa0_2+ap0_2+ap1_2+ap2

;aa0_2/=asum
;ap0_2/=asum
;ap1_2/=asum


;asum=aa0_3+ap0_3+ap1_3+ap2

;aa0_3/=asum
;ap0_3/=asum
;ap1_3/=asum



delay=linspace(0,7000,151) & nd=n_elements(delay)
par=[vcore,tcore,lr,lr2] ;,tedge,vcore2,tcore2,vcore3,tcore3, ap1,aa0_2,aa0_2,tedge,tedge,ap1_2,ap1_3]*1d0
common cbb,cl0,cl1,cl2
cl0=l0
cl1=l1
cl2=l2
;cl2=l2
;ctemp1=temp1
;cap1=ap1
;cap2=ap2
;ctedge=tedge


ftot=f(par,delay)
plot,delay,abs(ftot),pos=posarr(2,1,0)

;fref=fgaussof(delay,(l0*lr + l1*(1-lr)),0,0.1) 
fcal=ftot
plot,delay,atan2(fcal)*!radeg,pos=posarr(/next),/noer
;stop


;plot,delay,abs(ftot(0:nd-1))
;oplot,delay,abs(ftot(nd:2*nd-1)),col=2

dinc=50.;*sqrt(2)
dmax=4000.;*sqrt(2)
nn=dmax/dinc
cmax=10000&cnt=0
ndel=4
npar=n_elements(par)
iarr=fltarr(ndel+1,cmax)
;xx=1

;dinc=50*(1+findgen(nn))
;dinc=[358,$;3+6
;      238,$;4+6
;      477,$;4
;      596];5
;nn=4
for i1=0,nn-1 do for i2=0,nn-1  do begin ;i1+xx,nn do for i3=i2+x;x,nn do for i4=i3+xx,nn do begin
    iarr(0,cnt)=i1
    iarr(1,cnt)=i2
    iarr(2,cnt)=i1+i2
    iarr(3,cnt)=abs(i1-i2)

    cnt=cnt+1
endfor
ncnt=cnt
iarr=iarr(*,0:ncnt-1)

;npar=n_elements(par)
npar=4
met=fltarr(ncnt,npar)

for cnt=0,ncnt-1 do begin

;for i=n1/2,n1-1 do for j=n2-1,n2-1 do begin

;delay1=4100.;dinc[iarr(0,cnt)]
;delay2=550.*2;dinc[iarr(1,cnt)]
delay1=dinc*iarr(0,cnt)
delay2=dinc*iarr(1,cnt)
delay3=delay1+delay2
delay4=abs(delay1-delay2)

;i3=iarr(4,cnt)
;if i3 eq 0 then begin
    ww1=.5&ww2=.5&ww3=.25&ww4=.25
;endif else begin
;ww1=0&ww2=.706&ww3=.353&ww4=.353
;endelse



plot,delay,abs(ftot(0:nd-1));,xr=[0,1000]
;oplot,delay,abs(ftot(nd:2*nd-1)),col=2
;oplot,delay,abs(ftot(2*nd:3*nd-1)),col=3

oplot,delay1*[1,1],!y.crange,linesty=2,col=2
oplot,delay2*[1,1],!y.crange,linesty=2,col=4
oplot,delay3*[1,1],!y.crange,linesty=2,col=4
oplot,delay4*[1,1],!y.crange,linesty=2,col=4

vec=[delay1,delay2,delay3,delay4]
;wt=replicate(1.,12)
wta=[ww1,ww2,ww3,ww4]
wt=wta
;wt=[wta,wta,wta]
;stop
;scal=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]*1d-5
scal=[1,2.,1.,1.]*1d-5

calches,par,vec,hes,scal=scal,wt=wt
calches,par,vec,hes2,scal=scal/2,wt=wt
rat=hes2/hes
idx=where(abs(hes2) lt 1e-4)
if idx(0) ne -1 then rat(idx)=1.
outby=max(abs(rat-1))
if outby gt 0.05 then begin
    print,'hessian error',outby
;    print,hes/hes2,outby
;    hes*=!values.d_nan


;    stop
;    continue
endif ;else print, 'hessian status:',outby
eval = float(HQR(ELMHES(hes), /DOUBLE))
;hes(1,2)=hes(2,1)
;hes(0,2)=hes(2,0)
;hes(0,1)=hes(1,0)
;eval=eigenql(hes)
print,'eigenvalues:',eval

;if total(eval gt 0) ne npar then continue
;svdc,hes,w,u,v,/double
ihes0=invert(hes)
ihes=sqrt(ihes0)
dihes=diag_matrix(ihes)
met(cnt,*)=dihes
print,'errors','dv=',dihes(0),'dt=',dihes(1),'drat=',dihes(2),'drat2=',dihes(3)


;stop





if n_elements(imax) ne 0 then begin
    aa=''
    if cnt eq imax then stop    ; read,'',aa
endif


endfor

cmb=1/met(*,0)
ift=where(finite(cmb))
dum=max(cmb(ift),imax) & imax=ift(imax)

stop

eeee:
ift=where(finite(1/met(*,1))) & s1=max(1/met(ift,1))
ift=where(finite(1/met(*,5))) & s2=max(1/met(ift,5))
ift=where(finite(1/met(*,7))) & s3=max(1/met(ift,7))

fff=0.3e-1
s1=1/par(1)*fff
s2=1/par(5)*fff
s3=1/par(7)*fff
plot,1/s1/met(*,1),yr=[0,3],xtitle='config #',ytitle='inverse error'
oplot,1/s2/met(*,5),col=2
oplot,1/s3/met(*,7),col=3


cmb=w1/met(*,1)/s1+w2/met(*,5)/s2+w3/met(*,7)/s3
cmb=3*cmb/(w1+w2+w3)
oplot,cmb,col=4
ift=where(finite(cmb))
dum=max(cmb(ift),imax) & imax=ift(imax)
plots,imax,cmb(imax),psym=4,col=4
print,dinc[iarr(*,imax)]
;legend,['tcore (3.5kV)','tcore2 (1kV)','sum'],textcol=[1,2,4],/right,box=0


end


