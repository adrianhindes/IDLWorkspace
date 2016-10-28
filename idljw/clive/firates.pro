; from nrl plasma forumulary::::
; download from web:::

;for ions, prime is the main ion species (slowing down on it) and not
;prime is the fast particle

nip = 1e12
eps = linspace(100,10000,100)
mu=6
mup=1
tip = 20 & opl=0
;tip = 1.5e3 & opl=1
ni = nip / 1e4

te = tip

littlelam = 23 - alog( (mu+mup) / (mu*tip + mu*eps) * (ni/eps + nip/tip)^0.5)

nuii=$
1.8e-7 * nip * littlelam * (eps^(-1.5)*mu^0.5/mup^0.5 -1.1*(mu+mup)/mu/mup * (mup/tip)^(0.5)*(1./eps) * exp(-mup * eps / mu / tip) )
;print,(eps^(-1.5)*mu^0.5/mup^0.5 -1.1*(mu+mup)/mu/mup * (mup/tip)^(0.5)*(1./eps) * exp(-mup * eps / mu / tip) )
;retall


;for electrons, there is no prime
t = te
n_e = nip ; electron density ion density

lamei = 24 - alog(n_e^0.5 * 1./te)
lamie=lamei

nusie1 = 1.6e-9 * 1./mu * t^(-1.5)
nuperpie1 = 3.2e-9 * 1./mu * t^(-0.5) * 1./eps
nuparie1 = 1.6e-9 * 1./mu * t^(-0.5) * 1./eps

nuie = (2 * nusie1 - nuperpie1 - nuparie1) * n_e * lamie

print,'nuii=',nuii
print,'nuie=',nuie

if opl eq 0 then plot,eps,nuii,/xlog,yr=[0,2000] else oplot,eps,nuii
oplot,eps,nuie,col=2

;plot,alog10(eps),alog10(nuii)
;cursor,dx1,dy1,/down
;cursor,dx2,dy2,/down
;print,(dy2-dy1)/(dx2-dx1)

;eps0=6.954063e-12
;print,4 * 1.6d-19 ^4 * 20. * 1d18 / 4/!pi/eps0^2/1.67d-27^2/(400000.)^3
;nuei=4.2e-9 * ni * lamei * (eps^(-1.5)/mu - 8.9e4 * (mu/t) * 1./eps * exp(-1836*mu*eps/t))
end

