function stark_broadening, n_e, waves

phase = 2*!pi*waves

L_Gamma = density_to_gamma(n_e) ;Lorentzian Gamma variable

sBroadening = exp((-L_Gamma*(phase))/2.) ;fringe contrast from Stark contribution

return, sBroadening

end