function Gamma_to_density, Gamma, Hbeta=Hbeta
  ;
  ; n_e is in units m^(-3)
  ; Gamma is the FWHM normalized to centre wavelength
  ;

  if keyword_set(Hbeta) then begin

  end else begin  ;assume Hgamma
    lambda0 = 434.0466  ;(nm)
    fwhm = Gamma * lambda0
    n_e = (fwhm/.0497)^1.5*1e20
  end

  return, n_e

end
