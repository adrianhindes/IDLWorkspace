function Lorentzian_zeta, phi0, n_e, Hbeta=Hbeta
  ;
  ; phi0 is the group delay
  ; n_e is electron density in m^(-3)
  ; Hbeta flag indicates use Hbeta.  Default is HGamma

  gamma = density_to_gamma(n_e, Hbeta=Hbeta)

  return, exp(-double(phi0*gamma)/2.)
  
end