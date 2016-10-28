pro model_contrast_parameters

 
  ;n_e = exp(-((r)^2./(float(0.4))^2.)) ;generate electron densities (Gaussian)
  n_e = 1E20*0.65*cos(r*!pi/2.) ;generate electron density distribution (Cosine wave)
  ;T_atom = -0.05*signum(cos((r/0.2)-400))+0.04 ;generate atom temperatures (Square wave)
  T_atom = 0.50*(cos((r/0.4)))+0.5 ; atom temperatures (Cosine), high centre low wings

  n = 5 ; number of different delays
  waves_initial = 2000 ;starting delay
  waves = waves_initial+indgen(n)*2000 ;range of delay measurement


density_contrast = fltarr(n_elements(n_e),n_elements(waves))

for i = 0, n_elements(waves)-1 do density_contrast[*,i] = stark_broadening(n_e,2*!pi*waves[i])

title = 'Contrast versus density (Stark Only)'
p0 = plot(n_e,density_contrast[*,0],xtitle='Electron density $(m^{-3})$', title=title, $
  ytitle='Contrast',yrange=[0,1.],/ystyle,Name = '2000 waves')
p1 = plot(n_e,density_contrast[*,1], col='r',/overplot,Name = '4000 waves')
p2 = plot(n_e,density_contrast[*,2], col='b',/overplot,Name = '6000 waves')
p3 = plot(n_e,density_contrast[*,3], col='green',/overplot,Name = '8000 waves')
p4 = plot(n_e,density_contrast[*,4], col='purple',/overplot,Name = '10000 waves')

leg = LEGEND(TARGET=[p0,p1,p2,p3,p4], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

temp_contrast = fltarr(n_elements(T_atom),n_elements(waves))

for i = 0, n_elements(waves)-1 do temp_contrast[*,i] = doppler_broadening(n_e,2*!pi*waves[i])

title = 'Contrast versus Temperature (Doppler Only)'
p0 = plot(t_atom,temp_contrast[*,0],xtitle='Temperature (eV)', title=title, $
  ytitle='Contrast',yrange=[0,1.],/ystyle,Name = '2000 waves')
p1 = plot(t_atom,temp_contrast[*,1], col='r',/overplot,Name = '4000 waves')
p2 = plot(t_atom,temp_contrast[*,2], col='b',/overplot,Name = '6000 waves')
p3 = plot(t_atom,temp_contrast[*,3], col='green',/overplot,Name = '8000 waves')
p4 = plot(t_atom,temp_contrast[*,4], col='purple',/overplot,Name = '10000 waves')

leg = LEGEND(TARGET=[p0,p1,p2,p3,p4], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

total_broadening_contrast = fltarr(n_elements(T_atom),n_elements(waves))

for i = 0, n_elements(waves)-1 do total_broadening_contrast[*,i] = full_broadening(T_atom,n_e,2*!pi*waves[i])

title = 'Contrast versus Density (Full Broadening)'
p0 = plot(n_e,total_broadening_contrast[*,0],xtitle='Electron density $(m^{-3})$', title=title, $
  ytitle='Contrast',yrange=[0,1.],/ystyle,Name = '2000 waves')
p1 = plot(n_e,total_broadening_contrast[*,1], col='r',/overplot,Name = '4000 waves')
p2 = plot(n_e,total_broadening_contrast[*,2], col='b',/overplot,Name = '6000 waves')
p3 = plot(n_e,total_broadening_contrast[*,3], col='green',/overplot,Name = '8000 waves')
p4 = plot(n_e,total_broadening_contrast[*,4], col='purple',/overplot,Name = '10000 waves')

leg = LEGEND(TARGET=[p0,p1,p2,p3,p4], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

title = 'Contrast versus Temperature (Full Broadening)'
p0 = plot(t_atom,total_broadening_contrast[*,0],xtitle='Temperature (eV)', title=title, $
  ytitle='Contrast',yrange=[0,1.],/ystyle,Name = '2000 waves')
p1 = plot(t_atom,total_broadening_contrast[*,1], col='r',/overplot,Name = '4000 waves')
p2 = plot(t_atom,total_broadening_contrast[*,2], col='b',/overplot,Name = '6000 waves')
p3 = plot(t_atom,total_broadening_contrast[*,3], col='green',/overplot,Name = '8000 waves')
p4 = plot(t_atom,total_broadening_contrast[*,4], col='purple',/overplot,Name = '10000 waves')

leg = LEGEND(TARGET=[p0,p1,p2,p3,p4], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

end
