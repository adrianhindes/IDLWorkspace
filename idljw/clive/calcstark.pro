function lorentz, x, x0,gamma
;gamma is fwhm
f = 1/!pi * 0.5 * gamma / ((x-x0)^2 + (0.5*gamma)^2) / 4886.
return,f
end


function gaussfwhm, lam, l0, fwhm

sigma=fwhm / 2.3548


val=1/sigma/sqrt(2*!pi) * exp(-(lam-l0)^2 / (2*sigma^2) ) * (lam(1)-lam(0))
return,val

end



function gauss,lam,l0,tempk

ti = tempk / 10000.



echarge=1.6e-19
mi=1*1.67262158e-27;hydrogen
clight=3e8

vth=sqrt(2 * echarge * ti/mi)/clight


vel=(lam-l0)/l0
vrot=0.
scal=1/4e6
val=exp(-(vel-vrot/clight)^2 / vth^2) / (vth/scal)
return,val
end


l0=486.
tg = 1100.
amu=1.
n_e=1.3e13
nl=5001
lam=linspace(-0.5,0.5,nl)

lam2=lam/l0

dld = 7.16e-7 * l0 * (tg / amu)^0.5
dls = 2e-11 * (n_e)^(2./3.)

dld=1.5e-2;.02
dls=.5e-2;.01

;f=gauss(lam+486,486,tg)

f=gaussfwhm(lam+486,486,dld)
f2=lorentz(lam,0,dls)
fc=convol(f,f2,/center,/edge_zero)
plot,lam,f,pos=posarr(2,1,0),xr=[-.1,.1]/4;,/ylog
oplot,lam,f2
oplot,lam,f2/max(f2)*max(f),linesty=2
oplot,lam,fc,col=2

s=abs(fft(f))
s2=abs(fft(f2))
sc=abs(fft(fc))
s=s/s(0)
s2=s2/s2(0)
sc=sc/sc(0)

en=fft_t_to_f(lam2)
plot,en,s,pos=posarr(/next),/noer,xr=[0,40000]
oplot,en,s2
oplot,en,sc,col=2

par={crystal:'linbo3',facetilt:0,thickness:20e-3,lambda:434e-9}
par={crystal:'bbo',facetilt:45,thickness:6e-3,lambda:434e-9}
dum=opd(0,0,par=par,kappa=kappa)/2/!pi     
print,dum*kappa
print,dld,dls
end
