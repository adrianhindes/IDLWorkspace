lam=[681.5,643.3,608.5 , 581.0]*1e-9 ;wavelemgths measured roughtly
en=8.5 ; initial order **nb** I think this should be an integer but that doens't work because offset is aorund a half
nwav=[-0.5,0,0.5, 1] + en ; number of waves corr to rel to initial order
n=n_elements(lam)
b=fltarr(n)
for i=0,n-1 do begin
    cquartz,n_e=n_e,n_o=n_o,lambda=lam(i)
    b(i)=n_e-n_o
endfor

x = b/lam

plot,x,nwav,psym=4,xr=[0,max(x)] ; n vs B/lam gives L should be through zero, can test whether offset is good
c=linfit(x,nwav)
xx=linspace(0,max(x),100)
yy=xx*c(1) + c(0)
oplot,xx,yy,col=2 ; linear fit

lq=660.2e-9 ; wavelength of spectral lamp going through MSE filter
cquartz,n_e=n_e,n_o=n_o,lambda=lq
xxb=(n_e-n_o)/lq
yyb=xxb*c(1) + c(0) ; this is the order corr. to that

print,yyb

lp=642.2e-9 ; this is the wavelength determiend by clive considering the Ne calibration lines.
cquartz,n_e=n_e,n_o=n_o,lambda=lp
xxp=(n_e-n_o)/lp
nwavp=8.5 ; clive considers this to be 8.5 waves because it maches up with the order calculation bpreviously
cp=nwavp/xxp ; this is like the 'length' more accurately

yyb2=xxb * cp
print,yyb2 ; this is the delay at the mse wavelength more accurately



end
