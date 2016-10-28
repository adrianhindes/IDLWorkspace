pro model_delay_retreival

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
T_atom = 0.3*(cos((r/0.4)))+0.25 ; atom temperatures (Cosine), high centre low wings

n = 5 ; number of different delays
waves_initial = 3000 ;starting delay
waves = waves_initial+indgen(n)*1000 ;range of delay measurement


results = fltarr(3,nrad)

contrast_obtained = fltarr(n,nrad)
temp_obtained = fltarr(n,nrad)
n_e_obtained = fltarr(n, nrad)
;n-1 = no. different wave delay combinations with initial value
for i = 1, n-1 do begin
 results = obtain_measurements(waves_initial, waves[i], L, invL, epsilon, n_e, T_atom) &$
 contrast_obtained[i,*] = results[0,*] &$ ;data starts in 2nd column ie x_obtained[1,*]
 temp_obtained[i,*] = results[1,*] &$
 n_e_obtained[i,*] = results[2,*] &$
end 
title = 'Retrieved Contrast'
p0 = plot(contrast_obtained[1,*],xtitle='Radial Zone', title=title, $
  ytitle='Contrast',yrange=[0,1.],/ystyle,Name = '3000 & 4000 waves')
p1 = plot(contrast_obtained[2,*], col='r',/overplot,Name = '3000 & 5000 waves')
p2 = plot(contrast_obtained[3,*], col='b',/overplot,Name = '3000 & 6000 waves')
p3 = plot(contrast_obtained[4,*], col='green',/overplot,Name = '3000 & 7000 waves')
leg = LEGEND(TARGET=[p0,p1,p2,p3], POSITION=[0.8,0.55], /AUTO_TEXT_COLOR)

title = 'Retrieved Temperature'
pi = plot(T_atom,xtitle='Radial Zone', title=title, $
  ytitle='Temperature (eV)',/ystyle,Name = 'Generated Data')
p0 = plot(temp_obtained[1,*], col='r',/overplot,Name = '3000 & 4000 waves')
p1 = plot(temp_obtained[2,*], col='b',/overplot,Name = '3000 & 5000 waves')
p2 = plot(temp_obtained[3,*], col='green',/overplot,Name = '3000 & 6000 waves')
p3 = plot(temp_obtained[4,*], col='purple',/overplot,Name = '3000 & 7000 waves')
leg = LEGEND(TARGET=[pi,p0,p1,p2,p3], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

title = 'Retrieved Density'
pi = plot(n_e,xtitle='Radial Zone', title=title, $
  ytitle='Electron density $(m^{-3})$',/ystyle,Name = 'Generated Data')
p0 = plot(n_e_obtained[1,*], col='r',/overplot,Name = '3000 & 4000 waves')
p1 = plot(n_e_obtained[2,*], col='b',/overplot,Name = '3000 & 5000 waves')
p2 = plot(n_e_obtained[3,*], col='green',/overplot,Name = '3000 & 6000 waves')
p3 = plot(n_e_obtained[4,*], col='purple',/overplot,Name = '3000 & 7000 waves')
leg = LEGEND(TARGET=[pi,p0,p1,p2,p3], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)
stop

end