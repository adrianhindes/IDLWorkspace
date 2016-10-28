pro model_chosen_delays_retreival,no_noise=no_noise,interpol=interpol,seed
default,seed,1

nrad = 15 ;no. radial zones which everything is defined by
nimpacts = 100 ;No. impact parameters, should be greater than nrad otherwise losing information

r = findgen(nrad)/float(nrad) ; radius for generator functions of n_e, T_atom and I, equivalent to radial position

L = response(nimpacts, nrad) ;Radon projection matrix


;invL = svdinverse(nimpacts, nrad, (L)) ;Calculate Backprojection matrix,takes long computation time for loarge nrad&nimpacts
invL = svdinverse(nrad,nimpacts, transpose(L))

epsilon = abs(0.95*cos((r)/float(0.65))) ; emissivity profile in photon counts
epsilon = fix((epsilon*5000)>1) ;can't have less than zero photon or non-integer counts
n_e = double(2.2E19*0.45*cos(r*!pi/2)) ;generate electron density distribution (Cosine wave)

t = fltarr(nrad)
t[*]=0.1
T_atom = t ;set T_atom to be constant (according to John this is legit)
;.1 .2 eV
;5E19,1E20

wavesa = double(1000)
wavesb = double(10000)

doppler_a = doppler_broadening(T_atom,wavesa)
stark_a = stark_broadening(n_e,wavesa)

doppler_b = doppler_broadening(T_atom,wavesb)
stark_b = stark_broadening(n_e,wavesb)

I_0 = epsilon ## L ;projected emissivity = brightness (I_0),


;Inversion plots
;p2 = plot(invL ## I_0_noise,name='Retreived Emissivity',thick=1,col='red',xtitle='Radial Zones',ytitle='Photon Counts')
;p1 = plot(epsilon,/overplot,title='Generated and Retrieved Emissivity Profile',thick=2,name='Generated Data')
;leg = legend(target=[p1,p2],/auto_text_color)
;p3 = plot(I_0_noise,xtitle = 'Impact Parameter',ytitle='Photon Counts',title='Simulated Measured Brightness',thick=2)


;Calculate zeta
genzeta_a = doppler_a * stark_a
genzeta_b = doppler_b * stark_b

;project zeta to get fringe contrast, add brightness weighting (with noise)
Iz_a = (epsilon * genzeta_a) ## L
Iz_b = (epsilon * genzeta_b) ## L


;Now generate interferograms at phase steps of kx = 0 and  pi, assume particularly phi = 0
if keyword_set(no_noise) then begin
  S_0a = (signal(I_0,Iz_a,0)) ;S0 = I + a
  S_1a = (signal(I_0,Iz_a,!pi)) ;S1 = I - a

  S_0b = (signal(I_0,Iz_b,0)) ;S0 = I + a
  S_1b = (signal(I_0,Iz_b,!pi)) ;S1 = I - a
end else begin
S_0a = add_poisson_noise_image(signal(I_0,Iz_a,0),seed) ;S0 = I + a
S_1a = add_poisson_noise_image(signal(I_0,Iz_a,!pi),seed) ;S1 = I - a

S_0b = add_poisson_noise_image(signal(I_0,Iz_b,0),seed) ;S0 = I + a
S_1b = add_poisson_noise_image(signal(I_0,Iz_b,!pi),seed) ;S1 = I - a
end

;plot,S_0
;oplot,S_1
;oplot,S_2
;A = Izeta
;sA = sqrt((S_1 - sI)^2 + (S_2 - sI)^2)
;sphi = atan((S_1/S_0) -1)

sI_a = (S_0a + S_1a)/2. ;Recovery here is fine
sA_a = (S_0a - S_1a)/2.


sI_b = 0.5*(S_0b + S_1b)
sA_b = 0.5*(S_0b - S_1b)



;Invert retreived I and Izeta to get fringe contrast
;Issues with noise amplification
signalzeta_a = (invL ## sA_a)/(invL ## sI_a)
signalzeta_b = (invL ## sA_b)/(invL ## sI_b)




phi0_a = 2*!pi*wavesa
phi0_b = 2*!pi*wavesb

Tca = t_char(phi0_a)
Tcb = t_char(phi0_b)

lnz_a = alog(signalzeta_a)
lnz_b = alog(signalzeta_b)

signal_epsilon = invL ## sI_a

temp = -1*(-1*(Tca*Tcb*phi0_b*lnz_a)+(Tca*Tcb*phi0_a*lnz_b))/(Tca*phi0_a - Tcb*phi0_b)

gamma = -2*(Tca*lnz_a - Tcb*lnz_b)/(Tca*phi0_a - Tcb*phi0_b)

density = gamma_to_density(gamma)

if keyword_set(interpol) then begin
;Fix missing measurements (NAN values)
;Use inbuilt interpolation function to fill in values

good_temp = Where(finite(temp), n_good_temp, complement = temp_missing, ncomplement = n_temp_missing)
if n_temp_missing gt 0 then temp[temp_missing] $
  = interpol(temp[good_temp], good_temp, temp_missing)

good_density = where(finite(density),n_good_density, complement=density_missing, ncomplement = n_density_missing)
if n_density_missing gt 0 then density[density_missing] $
  = interpol(density[good_density], good_density, density_missing)

good_epsilon = where(finite(signal_epsilon),n_good_epsilon, complement=epsilon_missing, ncomplement = n_epsilon_missing)
if n_epsilon_missing gt 0 then signal_epsilon[epsilon_missing] $
  = interpol(signal_epsilon[good_epsilon], good_epsilon, epsilon_missing)
end

temp_error = error(temp,T_atom)
density_error = error(density,n_e)
epsilon_error = error(signal_epsilon,epsilon)

;Plot Contrasts

title='Fringe Contrast'
p1 = plot(signalzeta_a,name='Retreived from 3000 Waves',col='orange',thick=2,xtitle='Radial Zones',ytitle='Contrast',title=title)
p2 = plot(signalzeta_b,/overplot,name='Retreived from 10000 Waves',col='dodger_blue',thick=2)
p3 = plot(genzeta_a,col='red',name='Theoretical at 3000 Waves',linestyle='--',/overplot)
p4 = plot(genzeta_b,/overplot,name='Theoretical at 10000 Waves',col='blue',linestyle='--')
leg = legend(target=[p1,p2,p3,p4],/auto_text_color,position=[0.8,0.8])
stop

;Plot Signals
title = 'Simulated Signals
s0 = plot(S_0a,xtitle='Impact Parameter',ytitle='Photon Count',col='red',name='3000, kx = 0',title=title,thick=2)
s1 = plot(S_1a,/overplot,col='orange',name='3000, kx=$\pi$')
s2 = plot(S_0b,col='blue',name='10000, kx = 0',title=title,thick=2,/overplot)
s3 = plot(S_1b,/overplot,col='dodger_blue',name='10000, kx=$\pi$',thick=2)
leg = legend(target=[s0,s1,s2,s3],/auto_text_color,position=[0.7,0.7])

stop

;Data recovery and error
;Recovered Temp Plot
title = 'Recovered Temperature'
tplot = plot(T_atom, title=title,Name = 'Generated Data',linestyle='--')
tplot2 = plot(temp,col='r',/overplot,Name = 'Recovered Temp',xtitle='Radial Zone',ytitle='Atom Temperature (eV)')
leg = LEGEND(TARGET=[tplot,tplot2], /AUTO_TEXT_COLOR)


;Recovered Density Plot
title = 'Recovered Density'
dplot = plot(density,col='r',Name = 'Recovered Density',xtitle='Radial Zone',ytitle='Density',title=title)
dplot2 = plot(n_e,/overplot,Name = 'Generated Data',linestyle='--')
leg = LEGEND(TARGET=[dplot,dplot2], /AUTO_TEXT_COLOR)


;Recovered epsilon plot
title = 'Recovered Emissivity'
cplot2 = plot(signal_epsilon,col='r',Name = 'Recovered Emissivity',xtitle='Radial Zone',ytitle='Emissivity')
cplot = plot(epsilon, title=title,Name = 'Generated Emissivity',linestyle='--',/overplot)
leg = LEGEND(TARGET=[cplot,cplot2], /AUTO_TEXT_COLOR)

stop

TempErrorPlot = plot(temp_error, xtitle ='Radial Zone',ytitle='Percent Error',title='Temperature Error')

DensityErrorPlot = plot(density_error, xtitle='Radial Zone',ytitle='Percent Error',title='Density Error')

EmmisivityErrorPlot = plot(epsilon_error, xtitle='Radial Zone',ytitle='Percent Error',title='Emissivity Error')


stop



end