function opd,thx,thy,par=par,delta0=delta0,kappa=kappa,k0=k0

if par.thickness lt 0 then begin
    kappa=1.
    k0=0.
    return, (thx*0 - par.thickness*1000)*2*!pi ; negative make fixed wp
endif

;xc,yc,d,thickness=thickness,f2=f2,lambda=lambda,theta=theta,n_e=n_e,n_o=n_o,delta0=delta0,crystal=crystal

;default,lambda,656.e-9
;default,crystal,'bbo'
;if crystal eq 'bbo' then cbbo,n_e=n_e,n_o=n_o,lambda=lambda
;if crystal eq 'quartz' then cquartz,n_e=n_e,n_o=n_o,lambda=lambda

ccrystal,par,n_e,n_o,kappa=kappa

default,delta0,0.
;,i=i,doff=doff
;x=sqrt(xc^2+yc^2)

delta=atan(thy,thx)-delta0
alpha = sqrt(thx^2+thy^2)
theta=par.facetilt
n_i=1.

; theta is the angle of the crystal axis wrt the waveplate surface (zero is a standard waveplate)
; alpha and delta are the incident angle and the azimuth

; allow to override the refractive indices - e.g. in case of temperature dependence

Denom = (n_e^2*sin(theta)^2+n_o^2*cos(theta)^2)
a1 = sqrt(n_o^2-n_i^2*sin(alpha)^2)
a2 = n_i*(n_o^2-n_e^2)*sin(theta)*cos(theta)*cos(delta)*sin(alpha)/Denom
a3 = -n_o*sqrt(n_e^2*(n_e^2*sin(theta)^2+n_o^2*cos(theta)^2)-(n_e^2-(n_e^2-n_o^2)*cos(theta)^2*sin(delta)^2)*n_i^2*sin(alpha)^2)/Denom
d = par.thickness/par.lambda*(a1+a2+a3)*2*!pi


k0=(par.thickness *cos(theta)* n_i* (-n_e^2 + n_o^2)* sin($
  theta))/(par.lambda* (cos(theta)^2* n_o^2 + n_e^2 *sin(theta)^2)) ; in fringes per radian

return,d
end
