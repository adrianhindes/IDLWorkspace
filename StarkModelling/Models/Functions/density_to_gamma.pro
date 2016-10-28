function density_to_Gamma, n_e, Hbeta=Hbeta
;
; n_e is in units m^(-3)
;

if keyword_set(Hbeta) then begin
  
end else begin  ;assume Hgamma
  lambda0 = 434.0466  ;(nm)
  fwhm = .0497*(n_e*1e-20)^(2./3.) ;(nm)
  Gamma = fwhm/lambda0
end

return, Gamma

end
