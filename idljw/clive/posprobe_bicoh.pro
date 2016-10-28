;r=fltarr(nsh)
;z=fltarr(nsh)
;for i=0,nsh-1 do begin
;   fppos3,rad(i)+0,th(i)+0.,rdum,zdum&   zdum+=5
;for fork probe
rad=230.
th=0.
fppos3,rad-10,th,r,z

loaddata
mb_cart2flux, r*1e-3,z*1e-3,rho,eta,phi=7.2*!dtor & rho=sqrt(rho)

print, 'rho=',rho

;ballpen
radbp=230
r=1112+radbp-40
z=0.
mb_cart2flux, r*1e-3,z*1e-3,rhobp,etabp,phi=0*!dtor & rhobp=sqrt(rhobp)

print,'rhobp=',rhobp


end
