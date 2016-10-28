
function fgaussof,N, vrot,ti,pder1=pder1,pder2=pder2
common cbkappa, kappa
;kappa=1.

;default,lref,529.0


echarge=1.6e-19
mi=12*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti*1e3/mi)/clight
;dvthdti = (20 * sqrt(5) *  sqrt( (echarge * ti)/mi))/clight
dvthdti=1/clight * 0.5 / sqrt(2*echarge*ti*1e3/mi) * 2*echarge*1e3/mi


;vrot in units of 100km/s, ti in units of 1000eV
vrotc=(vrot * 100e3)/clight
dvrotcdvrot = 100e3/clight
;dl=(l0-lref)/lref
ii=dcomplex(0,1)
;gamma=exp(2*!pi*ii*N* (1+ kappa * (vrotc )) - (!pi*kappa*N)^2 * vth^2)
kappap=kappa
gamma=exp(2*!pi*ii*N* ( -kappap * (vrotc )) - (!pi*kappap*N)^2 * vth^2)


pder1 = -2 *gamma* ii* kappa *N *!pi * dvrotcdvrot
pder2 = -2 *gamma* kappa^2 * N^2 * !pi^2 * vth * dvthdti
;stop
return,gamma
end
