function magpie_coil_field, r, z, coil

I = coil.current
a = coil.radius
h = coil.position

; I is coil current
; a is coil radius
; h is coil z position
; r and z are the field coordinates

k = sqrt(4*a*r/((r+a)^2+(z-h)^2))
Kk = !pi/2.*(1. + k^2/4 + 9*k^4/64.)
Ek = !pi/2.*(1. - k^2/4 - 3*k^4/64.)

mu0=4*!pi*1e-7
q = mu0*I*k/(4*!pi*sqrt(a*r^3))

Br = -q*(z-h)*(Kk - (2-k^2)/(2*(1-k^2))*Ek) 
Bz = q*r*(Kk + (k^2*(r+a)-2*r)/(2*r*(1-k^2))*Ek)

; on axis field - a cross check
Bz0 = mu0*I*a^2/2./(a^2+(z[*,0]-h)^2)^1.5

return,{Br: Br, Bz: Bz, Bz0: Bz0}

end

