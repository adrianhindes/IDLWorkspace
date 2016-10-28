function zeta_to_density, zeta, phi0, Hbeta=Hbeta
  ;
  ; zeta is the measured contrast
  ; phi0 is the group delay
  ; n_e is electron density in m^(-3)
  ; Hbeta flag indicates use Hbeta.  Default is HGamma
  if n_params() ne 2 then stop, 'Please supply zeta and phi0'

  Gamma = -alog(zeta)*2./phi0
  n_e = Gamma_to_density( Gamma, Hbeta=Hbeta )
  
  return, n_e

end