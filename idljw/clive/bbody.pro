function emiss, lamnm, temp=temp
lam=lamnm*1e-9
clight=3d8
hplank=6.62606957d-34
kbolt=1.3806488d-23
nu = clight/lam
;inten = 2*hplank * nu^3 / clight^2 * 1. / (exp(hplank*nu / (kbolt*temp) ) - 1.)
;radiance in J/s/m^2/str / (Hz)
;inten = inten * clight / lam^2 / 1d9 ; radiance in J/s/m^2/str/nm
inten = 2 * hplank * clight^2 / lam^5 * 1/(exp(hplank*nu / (kbolt*temp) ) - 1.) ; radiance in J/s/m^2/str / m
inten=inten / 1e9 ; per nm
photon = inten / (hplank * nu)
;radiance in photons/s/m^2/str
return,photon
end

lrng=10;600;10.
lwid=1.
l0=656.
nl=101
lam=linspace(-1,1,nl)*lrng/2 + l0

filt=exp(-(lam-l0)^2 / lwid^2)

bbody=emiss(lam,temp=1.35e3)

;f/2 = antle 1/4radians
etendue = 6.5d-6^2 * !pi * (1/4.)^2 ; 1pix
exp_time = 1.
bbody=bbody * etendue * exp_time
plot,lam,filt
plot,lam,bbody,col=2,/noer



end

