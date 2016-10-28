function magpie_coil_field, rr, zz, coil

  I = coil.current
  aa = coil.radius
  hh = coil.position

  ; I is coil current
  ; a is coil radius
  ; h is coil z position
  ; r and z are the field coordinates

  ;convert all these quantities to meters so that the permiability is in the correct units
  r=abs(rr/100.0)
  z=zz/100
  a=aa/100.0
  h=hh/100.0


  k = sqrt(4.0*a*r/((r+a)^2.0+(z-h)^2.0))
  Kk = !pi/2.*(1. + k^2.0/4.0 + 9*k^4.0/64.) ;elliptical functions
  Ek = !pi/2.*(1. - k^2.0/4.0 - 3*k^4.0/64.) ;elliptical functions

  mu0=4.0*!pi*1e-7
  q = mu0*I*k/(4.0*!pi*sqrt(a*r^3.0))

  Br = -q*(z-h)*(Kk - (2.0-k^2)/(2.0*(1-k^2))*Ek)
  Bz = q*r*(Kk + (k^2.0*(r+a)-2.0*r)/(2.0*r*(1-k^2.0))*Ek)

  ; on axis field - a cross check
  Bz0 = mu0*I*a^2.0/2.0/(a^2.0+(z[*,0]-h)^2.0)^1.5

  return,{Br: Br, Bz: Bz, Bz0: Bz0}
end