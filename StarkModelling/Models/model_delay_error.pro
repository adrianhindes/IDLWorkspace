pro model_delay_error

  nrad = 500 ;no. radial zones which everything is defined by
  nimpacts = 1000 ;No. impact parameters, should be greater than nrad otherwise losing information

  r = findgen(nrad)/float(nrad) ; radius for generator functions of n_e, T_atom and I, equivalent to radial position

  L = response(nimpacts, nrad) ;Radon projection matrix
  invL = svdinverse(nimpacts, nrad, L) ;Backprojection matrix

  epsilon = abs(0.95*cos((r)/float(0.65))) ; emissivity profile in photon counts
  epsilon = fix((epsilon*10000)>1) ;can't have less than zero photon or non-integer counts

  ;n_e = exp(-((r)^2./(float(0.4))^2.)) ;generate electron densities (Gaussian)
  n_e = 1E20*0.65*cos(r*!pi/2.) ;generate electron density distribution (Cosine wave)
  ;T_atom = -0.05*signum(cos((r/0.2)-400))+0.04 ;generate atom temperatures (Square wave)
  T_atom = 0.05*(cos((r/0.3)))+0.05 ; atom temperatures (Cosine), high centre low wings, 0.1eV
  
  
  
  n = 20 ; number of different delays
  waves_initial = 3000 ;starting delay
  waves = waves_initial+indgen(n)*500 ;range of delay measurement
  wavediff = fltarr(n-1)
  for i = 1, n-1 do wavediff[i-1] = waves[i] - waves_initial

  mean_delay = (waves_initial + max(waves))/2.
  
  zeta_initial = full_broadening(T_atom,n_e,waves_initial)

  results = fltarr(3,nrad)

  err_contrast_obtained = fltarr(n,nrad)
  err_temp_obtained = fltarr(n,nrad)
  err_n_e_obtained = fltarr(n,nrad)
  
  ;n-1 = no. different wave delay combinations with initial value
  ;Process data, looping through delay combinations
  for i = 1, n-1 do begin
    results = obtain_measurements(waves_initial, waves[i], L, invL, epsilon, n_e, T_atom) &$ ;Get measurements here
      err_contrast_obtained[i,*] = 0.5*((error(results[0,*],zeta_initial)) + $
        (error(results[1,*],full_broadening(T_atom,n_e,waves[i])))) &$ 
      err_temp_obtained[i,*] = error(results[2,*],T_atom) &$
      err_n_e_obtained[i,*] = error(results[3,*],n_e) &$
    end

  
mean_error_contrast = fltarr(n-1)
mean_error_density = fltarr(n-1)
mean_error_temp = fltarr(n-1)

for i = 0, n-2 do mean_error_contrast[i] = mean(err_contrast_obtained[i+1,*],/NAN)
for i = 0, n-2 do mean_error_density[i] = mean(err_n_e_obtained[i+1,*],/NAN) 
for i = 0, n-2 do mean_error_temp[i] = mean(err_temp_obtained[i+1,*],/NAN)

title = 'Mean Error in Measurement Retreival'
err_contrast = plot(wavediff,mean_error_contrast,title=title, $
  xtitle='Chosen Wave Delay Difference (Waves)',ytitle = '% Error',yrange=[0,100],col='green',name='Contrast Error')

err_density = plot(wavediff,mean_error_density,title=title, $
    xtitle='Chosen Wave Delay Difference (Waves)',ytitle = '% Error',/overplot,col='blue',name='Density Error')
    
err_temp = plot(wavediff,mean_error_temp,title=title, $
    xtitle='Chosen Wave Delay Difference (Waves)',ytitle = '% Error',/overplot,col='red',name='Temperature Error')
 leg = LEGEND(TARGET=[err_contrast,err_density,err_temp], POSITION=[0.8,0.55], /AUTO_TEXT_COLOR)   
    
    
    
stop
title = 'Retrieved Contrast'
p0 = plot(err_contrast_obtained[1,*],xtitle='Radial Zone', title=title, $
  ytitle='% Error',yrange=[0,100],/ystyle,Name = '3000 & 4000 waves')
p1 = plot(err_contrast_obtained[2,*], col='r',/overplot,Name = '3000 & 5000 waves')
p2 = plot(err_contrast_obtained[3,*], col='b',/overplot,Name = '3000 & 6000 waves')
p3 = plot(err_contrast_obtained[4,*], col='green',/overplot,Name = '3000 & 7000 waves')
leg = LEGEND(TARGET=[p0,p1,p2,p3], POSITION=[0.8,0.55], /AUTO_TEXT_COLOR)

title = 'Retrieved Temperature'
p0 = plot(err_temp_obtained[1,*],xtitle='Radial Zone', title=title, $
  ytitle='% Error',yrange=[0,100], col='r',Name = '3000 & 4000 waves')
p1 = plot(err_temp_obtained[2,*], col='b',/overplot,Name = '3000 & 5000 waves')
p2 = plot(err_temp_obtained[3,*], col='green',/overplot,Name = '3000 & 6000 waves')
p3 = plot(err_temp_obtained[4,*], col='purple',/overplot,Name = '3000 & 7000 waves')
leg = LEGEND(TARGET=[p0,p1,p2,p3], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

title = 'Retrieved Density'
p0 = plot(err_n_e_obtained[1,*],title=title, $
  ytitle='% Error',yrange=[0,100], col='r',Name = '3000 & 4000 waves')
p1 = plot(err_n_e_obtained[2,*], col='b',/overplot,Name = '3000 & 5000 waves')
p2 = plot(err_n_e_obtained[3,*], col='green',/overplot,Name = '3000 & 6000 waves')
p3 = plot(err_n_e_obtained[4,*], col='purple',/overplot,Name = '3000 & 7000 waves')
leg = LEGEND(TARGET=[p0,p1,p2,p3], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)
stop
end