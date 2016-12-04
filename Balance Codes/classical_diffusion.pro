function classical_diffusion, b, te, ti, n_i, del_ni, mi


;Thermal Velocities
vti=sqrt(2*!const.e*ti/mi) ;ion thermal vel
vte = sqrt(2*!const.e*te/!const.me)

;Collisional Cross Sections
sigma_H =100 * (1d-10)^2; for hydrogen
sigma_Ar = 50 * (1d-9)^2 ;cross section argon

;Collisions --------------
;-------------------------------------------

loglam=20. ;coulomb collisions
loglamei=loglam
b_calc = 0.01
mi=1.67d-27*40 ;Argon ion mass
;Ions -----------------
nuii=n_i*!const.e^4 * loglam / 4 / !pi / !const.eps0^2 / mi^2 / vti^3 ;ion ion collision frequency

fgyro_i = 1.52e3 * (1.6e-27/mi) * (b*10000.)
;print,'Ion Gyrofrequency = ',fgyro_i

rgyro_i=vti / (2*!pi*fgyro_i)
;print,'Ion Larmor Radius=',rgyro_i,'m'

nunew = n_i * sigma_Ar * vti ;CX from neutral perspective
;print,'Neutral CX Frequency = ',nunew
mfpcx = vti / nunew
;print,'Mean Free Path Ion CX ',mfpcx

tau_cx_i = 1/nunew

;Electrons ---------------

fgyro_e = 2.8e6 * (b_calc*10000.)
;print,'Electron Gyrofrequency = ',fgyro_e

rgyro_e= vte / (2*!pi*fgyro_e)
;print,'Electron Larmor Radius=',rgyro_e,'m'

nuee= n_i*!const.e^4 * loglam / 4 / !pi / !const.eps0^2 / !const.me^2 / vte^3
;print,'EE Collision frequency = ',nuee
mfpee= vte / nuee
;print,'Mean Free Path EE Collisions=',mfpee

nuei =  2.5e-4 * n_i/1e6 * loglamei * sqrt(1.6e-27/mi) / ti^0.5 / ti ;(e -> ion collision)
;print,'EI Collision frequency = ',nuei
mfpei= vte / nuei
;print,'Mean Free Path EI Collisions= ',mfpei

nueneutral = n_i * sigma_Ar * vte
;print,'EN Collision Frequency = ',nueneutral
mfpen = vte / nueneutral
;print,'Mean Free Path EN Collisions= ',mfpen

nuetotal = nueneutral + nuee + nuei ;add up electron relevant collision frequencies
tau_e = 1/nuetotal

;Diffusion --------------------
D_i = !const.e*ti/(mi*nunew)
D_e = !const.e*te/(mi*nuetotal)
Mob_i = !const.e/(mi*nunew)
Mob_e = !const.e/(mi*nuetotal)

;print,'Ion Diffusion Coefficient = ',D_i
;print,'Electron Diffusion Coefficient = ',D_e
;
;print,'Ion Mobility Coefficient = ',Mob_i
;print,'Electron Mobility Coefficient = ',Mob_e

D_perp_i = D_i/(1+fgyro_i^2*tau_cx_i^2)
D_perp_e = D_e/(1+fgyro_e^2*tau_e^2)

Mob_perp_i = Mob_i/(1+fgyro_i^2*tau_cx_i^2)
Mob_perp_e = Mob_e/(1+fgyro_i^2*tau_cx_i^2)

;print,'Perpendicular Ion Diffusion = ',D_perp_i
;print,'Perpendicular Electron Diffusion = ',D_perp_e

;print,'Perpendicular Ion Mobility = ',Mob_perp_i
;print,'Perpendicular Electron Mobility = ',Mob_perp_e

;Ambipolar Diffusion --------------------------
AmbiE = (del_ni*(D_i - D_e))/(n_i*(Mob_i + Mob_e))
;print,"Ambipolar Electric Field = ",AmbiE

exb = AmbiE/0.01
;print,"ExB = ",exb
;
;mobNE_i = Mob_i*n_i*AmbiE
;d_deln_i = D_i*del_ni
;
;mobNE_e = Mob_e*n_i*AmbiE
;d_deln_e = D_e*del_ni
;
;nvflux_i = mobNE_i - d_deln_i
;nvflux_e = -mobNE_e -d_deln_e

PerpAmbiE = (del_ni*(D_perp_i - D_perp_e))/(n_i*(Mob_perp_i + Mob_perp_e))

D_a = (mob_i*D_e+mob_e*D_i)/(mob_i +mob_e)

;Cross field velocity -----------------------
v_perp_i = Mob_perp_i*AmbiE - D_perp_i*(del_ni/n_i)

v_perp_e = -Mob_perp_e*AmbiE - D_perp_e*(del_ni/n_i)

;print,'Ion Cross Field Velocity = ',v_perp_i
;print,'Electron Cross Field Velocity = ',v_perp_e

;Cross Field Flux
perp_mobNE_i = Mob_perp_i*n_i*PerpAmbiE
perp_d_deln_i = D_perp_i*del_ni

perp_nvflux_i = perp_mobNE_i - perp_d_deln_i

perp_mobNE_e = Mob_perp_e*n_i*PerpAmbiE
perp_d_deln_e = D_perp_e*del_ni

perp_nvflux_e = perp_mobNE_e - perp_d_deln_e

;print,"NV Ion Flux = ",perp_nvflux_i
;print,"NV Electron Flux = ",perp_nvflux_e

return, perp_nvflux_i + perp_nvflux_e

end