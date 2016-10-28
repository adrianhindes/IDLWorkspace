
function brems_emiss, dste, dsne, dssys

; Convert density to [cm^-3]
  nel_cm3 = 1e-6 * dsne.nel

; Calculate bremstralung emissivity [ph/s/cm^3]

  cbrems = 9.587e-14
  gaunt0 = 0.0821
  gaunt1 = 0.6183

  ebrems = cbrems * nel_cm3^2 * dssys.zeff * (gaunt1 * alog(dste.te) - gaunt0) / $
                 (4. * !Pi * sqrt(dste.te))

; Convert emissivity to  [ph/s/cm^3]
  ebrems = 1e6 * ebrems

  dssys = create_struct(dssys, 'ebrems', ebrems)

  return, dssys

end

