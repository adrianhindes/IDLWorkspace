function full_broadening, temp, n_e, phase

L_Gamma = density_to_gamma(n_e) ;Lorentzian Gamma variable
T_c = t_char(phase) ;characteristic temperature

zeta = exp(-temp/(T_c))* exp((-L_Gamma*(phase))/2.)

return,zeta

end 