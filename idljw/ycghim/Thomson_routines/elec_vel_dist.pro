; This function plots the non-relativisitic and relativistic distributions of electrons for Maxwellian

PRO elec_vel_dist

; defince constant (all in SI units)
  m0 = 9.11*10^(-31.) ;electron rest mass in [kg]
  kb = 1.38*10^(-23.) ;Boltzmann constant in [J/K]
  c = 3.00*10^(8.0)   ;speed of light in [m/s]
  e = 1.60*10^(-19.)  ;elementary charge in [C]

; Temperatures of electrons to check in [eV]
  Te_eV = [10.0, 100.0, 500.0, 1000.0, 5000.0, 10000.0, 5000.0] ;electron temperature in [eV]
  
; Change the unit of temperature to [J]
  Te_J = Te_eV * e

; Set the fulid velocity of electrons in [m/s]
  U0 = 0.0 ;U0 = 0.0 m/s means that we will have non-shifted Maxwellian distribution function for electrons

; For the plot: x-axis is the velocity, and y-axis is the probability density function
  vel_npts = 1000  ;number of points for the domain, i.e., velocity
  vel_min = -1.0*c ;minimum velocity is the -c for the domain
  vel_max = 1.0*c  ;maximum velocity if the +c for the domain
  vel = findgen(vel_npts)*(vel_max - vel_min)/(vel_npts-1) + vel_min ;velocity in [m/s]
  norm_vel = vel/c ;normalized velocity by c

; Calculate the non-relativistic electron velocity distibution function
  fvel = FLTARR(N_ELEMENTS(Te_J), vel_npts)
  for i = 0, N_ELEMENTS(Te_J)-1 do begin
    fvel[i, *] = (m0/(2.0*!pi*Te_J[i]))^(3.0/2.0)*exp(-m0*(vel-U0)^2.0/(2.0*Te_J[i]))
  endfor

; Calculate the relativistic electron velocity distribution function
  alpha = m0*c^2.0/(2.0*Te_J)
  beta = vel/c
  gamma = 1.0/sqrt(1.0-beta^2.0)
  fbeta = FLTARR(N_ELEMENTS(Te_J), vel_npts)
  for i = 0, N_ELEMENTS(Te_J) - 1 do begin
    fbeta[i, *] = alpha[i]/(2.0*!pi*beselk(2.0*alpha[i], 2))*gamma^5.0*exp(-2.0*gamma*alpha[i])
  endfor

  loadct, 5
  safe_colors, /first
  
  window, /free
  plot, vel/c, fvel[0, *], /nodata, /ylog, xstyle=1, col = 1, $
        title = 'Nonrelativistic electron distribution', xtitle = 'velocity [normalized to c]', ytitle = 'PDF'
  for i=0, N_ELEMENTS(Te_J)-1 do oplot, vel/c, fvel[i, *], col=i+1

;  window, /free
;  plot, vel/c, fbeta[0, *], /nodata, /ylog, xstyle=1, col = 1, $
;        title = 'Relativistic electron distribution', xtitle = 'velocity [normalized to c]', ytitle = 'PDF'
;  for i=0, N_ELEMENTS(Te_J)-1 do oplot, vel/c, fbeta[i, *], col=i+1

  



stop


END
