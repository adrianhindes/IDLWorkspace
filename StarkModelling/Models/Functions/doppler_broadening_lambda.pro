function doppler_broadening_lambda, temp

;Assuming Hgamma

A_rel = 1 ;Hydrogen (1 proton = 1 relative atomic mass)

lambda0 = 434.0466  ;(nm)

broadening = 7.716E-6 * lambda0 * sqrt((temp/A_rel))

return,broadening

end