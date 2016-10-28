pro model_brightness_noise
  nrad = 500 ;no. radial zones which everything is defined by
  nimpacts = 1000 ;No. impact parameters, should be greater than nrad otherwise losing information

  r = findgen(nrad)/float(nrad) ; radius for generator functions of n_e, T_atom and I, equivalent to radial position

 
  I =[1000,2500,5000,10000]
  epsilon_array = fltarr(nrad,4)
  retreived_e_array = fltarr(nrad,4)
  
  for x = 0, 3 do epsilon_array[*,x] = $
    fix((I[x]*abs(0.95*cos((r)/float(0.65))))>1) ; emissivity profile in photon counts
  
  n_e = 1.2E20*0.45*cos(r*!pi/2)+5E19 ;generate electron density distribution (Cosine wave)
  T_atom = 0.1 ;fix temp
  

  L = response(nimpacts, nrad) ;Radon projection matrix
  invL = svdinverse(nimpacts, nrad, L)
  
  
  for x = 0, n_elements(I)-1 do begin &$
  epsilon = abs(0.95*cos((r)/float(0.65))) ; emissivity profile in photon counts
  epsilon = fix((epsilon*I[x])>1) ;can't have less than zero photon or non-integer counts
  
  waves = 7000 &$
  doppler = doppler_broadening(T_atom,waves) &$
  stark = stark_broadening(n_e,waves) &$
  
  I_0 = epsilon ## L &$ 
  I_0_noise = add_poisson_noise_image(I_0) &$ 

  genzeta = doppler * stark &$
  ;project zeta to get fringe contrast, add brightness weighting (with noise)
  Iz = I_0_noise * (genzeta ## L) &$

  ;Now generate interferograms at phase steps of kx = 0 and  pi, assume particularly phi = 0
  S_0 = signal(0,I_0_noise,Iz,0) &$ ;S0 = I + a
  S_1 = signal(0,I_0_noise,Iz,!pi) &$ ;S1 = I - a
   
  ;Retreive measured brightness
  brightness = 0.5*(S_0 + S_1) 
  retreived_e_array[*,x] = invL ## brightness
  end
  
  ;Inversion plots
  title= 'Generated Emissivity Profiles'
  e0 = plot(epsilon_array[*,0],title=title,thick=2 $
  ,xtitle='Radial Zones',ytitle='Photons',name='1000 Photons',col='crimson')
  e1 = plot(epsilon_array[*,1],thick=2,name='2500 Photons',/overplot,col='red')
  e2 = plot(epsilon_array[*,2],thick=2,name='5000 Photons',/overplot,col='orange')
  e3 = plot(epsilon_array[*,3],thick=2,name='10000 Photons',/overplot,col='gold')
  leg = legend(target=[e0,e1,e2,e3],/auto_text_color)
  
  title= 'Retreived Emissivity Profiles'
  e4 = plot(retreived_e_array[*,0],title=title,thick=2 $
  ,xtitle='Radial Zones',ytitle='Photons',name='1000 Photons',col='crimson')
  e5 = plot(retreived_e_array[*,1],thick=2,name='2500 Photons',/overplot,col='red')
  e6 = plot(retreived_e_array[*,2],thick=2,name='5000 Photons',/overplot,col='orange')
  e7 =plot(retreived_e_array[*,3],thick=2,name='10000 Photons',/overplot,col='gold')
  leg = legend(target=[e4,e5,e6,e7],/auto_text_color)
  
  error_array = fltarr(4)
  for x = 0, 3 do error_array[x] = rms(retreived_e_array[*,x],epsilon_array[*,x])
 
  title= 'Error in Retreived Emissivity Profiles'
  e8 = scatterplot([1000,2500,5000,10000],error_array,title=title $
    ,xtitle='Photons',ytitle='Normalized Root Mean Square')

stop
  
 ; p0 = plot(brightness_array[0,*],title='Simulated Measured Brightness', $
   ; xtitle='Impact Parameter',ytitle='Brightness (Photon Counts)',thick=2,name='$\epsilon \leq$ 1000 Photons',col='crimson')
  ;p1 = plot(brightness_array[1,*],thick=2,/overplot,name='$\epsilon \leq$ 2500 Photons',col='red')
  ;p2 = plot(brightness_array[2,*],thick=2,/overplot,name='$\epsilon \leq$ 5000 Photons',col='orange')
  ;p3 = plot(brightness_array[3,*],thick=2,/overplot,name='$\epsilon \leq$ 10000 Photons',col='gold')
  
  ;leg = legend(target=[p0,p1,p2,p3],/auto_text_color)
end