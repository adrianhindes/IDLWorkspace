function stark_broadening_lambda, density
  lambda0 = 434.0466  ;(nm)
  fwhm = .0497*(density*1e-20)^(2./3.) ;(nm)
  
  return,fwhm
  
  end