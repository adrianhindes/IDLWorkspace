function obtain_measurements, delay1, delay2, L, invL, epsilon, n_e, T_atom,seednum
  
default,seed,seednum

wavesa = delay1
wavesb = delay2

doppler_a = doppler_broadening(T_atom,wavesa)
stark_a = stark_broadening(n_e,wavesa)

doppler_b = doppler_broadening(T_atom,wavesb)
stark_b = stark_broadening(n_e,wavesb)

I_0 = (epsilon ## L)  ;projected emissivity = brightness (I_0), added poisson noise

;Calculate ideal fringe contrast without noise
genzeta_a = doppler_a * stark_a
genzeta_b = doppler_b * stark_b

;make noisy brightness weighted fringe measurements
Iz_a = (epsilon * genzeta_a) ## L
Iz_b = (epsilon * genzeta_b) ## L

;Now generate interferograms at phase steps of kx = 0 and  pi, assume particularly phi = 0
S_0a = add_poisson_noise_image(signal(I_0,Iz_a,0),seed) ;S0 = I + a
S_1a = add_poisson_noise_image(signal(I_0,Iz_a,!pi),seed) ;S1 = I - a

S_0b = add_poisson_noise_image(signal(I_0,Iz_b,0),seed+1) ;S0 = I + a
S_1b = add_poisson_noise_image(signal(I_0,Iz_b,!pi),seed+1) ;S1 = I - a

sIa = 0.5*(S_0a + S_1a) 
sAa = 0.5*(S_0a - S_1a)


sIb = 0.5*(S_0b + S_1b)
sAb = 0.5*(S_0b - S_1b)

;Invert retreived I and Izeta to get fringe contrast
signalzeta_a = (invL ## sAa)/(invl ## sIa)
signalzeta_b = (invL ## sAb)/(invl ## sIb)


phi0_a = 2*!pi*wavesa
phi0_b = 2*!pi*wavesb

Tca = t_char(phi0_a)
Tcb = t_char(phi0_b)

lnz_a = alog(signalzeta_a)
lnz_b = alog(signalzeta_b)

signal_epsilon = invL ## sIa

temp = -1*(-1*(Tca*Tcb*phi0_b*lnz_a)+(Tca*Tcb*phi0_a*lnz_b))/(Tca*phi0_a - Tcb*phi0_b)

gamma = -2*(Tca*lnz_a - Tcb*lnz_b)/(Tca*phi0_a - Tcb*phi0_b)

density = gamma_to_density(gamma)

result_array_size = n_elements(density)

result_array = fltarr(3,result_array_size)
;result_array[0,*] = signalzeta_a
;result_array[1,*] = signalzeta_b
result_array[0,*] = signal_epsilon
result_array[1,*] = temp
result_array[2,*] = density

return,result_array


end