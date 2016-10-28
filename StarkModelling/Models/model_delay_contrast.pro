pro model_delay_contrast

;n_e = exp(-((r)^2./(float(0.4))^2.)) ;generate electron densities (Gaussian)
n_e = [1E21,5E20,3E20,1E20,5E19,3E19,1E19] ;fix n_e's
T_atom = [0.01,0.03,0.05,0.1,0.3,0.5,1] ;fix temps

delays = indgen(50000, start = 1,/ul64)

dopplerContrast = fltarr(n_elements(delays),7)
starkContrast = fltarr(n_elements(delays),7)

for i = 0, 6 do dopplerContrast[*,i] = doppler_broadening(T_atom[i],delays)
title = 'Delays versus Contrast (Doppler Only)'
p0 = plot(delays,dopplerContrast[*,0],xtitle='Delays (waves)', title=title, $
  ytitle='Contrast',/ystyle,Name = '0.01eV')
p1 = plot(delays,dopplerContrast[*,1], col='r',/overplot,Name = '0.03eV')
p2 = plot(delays,dopplerContrast[*,2], col='b',/overplot,Name = '0.05eV')
p3 = plot(delays,dopplerContrast[*,3], col='green',/overplot,Name = '0.1eV')
p4 = plot(delays,dopplerContrast[*,4], col='purple',/overplot,Name = '0.3eV')
p5 = plot(delays,dopplerContrast[*,5], col='cadet_blue',/overplot,Name = '0.5eV')
p6 = plot(delays,dopplerContrast[*,6], col='crimson',/overplot,Name = '1eV')
leg = LEGEND(TARGET=[p0,p1,p2,p3,p4,p5,p6], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)


for i = 0, 6 do starkContrast[*,i] =  stark_broadening(n_e[i],delays)
title = 'Delays versus Contrast (Stark Only)'
p0 = plot(delays,starkContrast[*,0],xtitle='Delays (waves)', title=title, $
  ytitle='Contrast',/ystyle,Name = '1E21')
p1 = plot(delays,starkContrast[*,1], col='r',/overplot,Name = '5E20')
p2 = plot(delays,starkContrast[*,2], col='b',/overplot,Name = '3E20')
p3 = plot(delays,starkContrast[*,3], col='green',/overplot,Name = '1E20')
p4 = plot(delays,starkContrast[*,4], col='purple',/overplot,Name = '5E19')
p5 = plot(delays,starkContrast[*,5], col='cadet_blue',/overplot,Name = '3E19')
p6 = plot(delays,starkContrast[*,6], col='crimson',/overplot,Name = '1E19')
leg = LEGEND(TARGET=[p0,p1,p2,p3,p4,p5,p6], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

title = 'Delays versus Contrast (Stark and Doppler Comparison)'
d0 = plot(delays,dopplerContrast[*,0],xtitle='Delays (waves)', title=title, $
  ytitle='Contrast',/ystyle,Name = '0.01eV',thick=2,col='goldenrod'$
  ,xrange = [1,5E4],yrange=[0,1],/no_toolbar,dimensions=[800,600],margin=[0.1,0.1,0.2,0.1])
d1 = plot(delays,dopplerContrast[*,1], col='orange',/overplot,Name = '0.03eV',thick=2)
d2 = plot(delays,dopplerContrast[*,2], col='orange_red',/overplot,Name = '0.05eV',thick=2)
d3 = plot(delays,dopplerContrast[*,3], col='red',/overplot,Name = '0.1eV',thick=2)
d4 = plot(delays,dopplerContrast[*,4], col='maroon',/overplot,Name = '0.3eV',thick=2)
d5 = plot(delays,dopplerContrast[*,5], col='firebrick',/overplot,Name = '0.5eV',thick=2)
d6 = plot(delays,dopplerContrast[*,6], col='crimson',/overplot,Name = '1eV',thick=2)

s0 = plot(delays,starkContrast[*,0],/overplot,Name = '1E21',linestyle='--',thick=2)
s1 = plot(delays,starkContrast[*,1], col='midnight_blue',/overplot,Name = '5E20',linestyle='--',thick=2)
s2 = plot(delays,starkContrast[*,2], col='dark_blue',/overplot,Name = '3E20',linestyle='--',thick=2)
s3 = plot(delays,starkContrast[*,3], col='cadet_blue',/overplot,Name = '1E20',linestyle='--',thick=2)
s4 = plot(delays,starkContrast[*,4], col='dark_slate_blue',/overplot,Name = '5E19',linestyle='--',thick=2)
s5 = plot(delays,starkContrast[*,5], col='blue',/overplot,Name = '3E19',linestyle='--',thick=2)
s6 = plot(delays,starkContrast[*,6], col='dark_turquoise',/overplot,Name = '1E19',linestyle='--',thick=2)

leg1 = LEGEND(TARGET=[d0,d1,d2,d3,d4,d5,d6], POSITION=[0.98,0.85], /AUTO_TEXT_COLOR)
leg2 = LEGEND(TARGET=[s0,s1,s2,s3,s4,s5,s6], POSITION=[0.97,0.45], /AUTO_TEXT_COLOR)

title = 'Delays vs Contrast at $0.1$ eV and $1\times 10^{19}m^{-3}$
p0 = plot(delays,starkContrast[*,6],col='blue',name='Stark Broadening',thick=2, $
  xtitle='Delays',ytitle='Contrast',title=title)
p1 = plot(delays,dopplerContrast[*,3],col='red',name='Doppler Broadening',thick=2,/overplot)
p2 = plot(delays,(starkContrast[*,6] * dopplerContrast[*,3]),col='purple',name='Combined Broadening',thick=2,/overplot,linestyle='--')
leg = LEGEND(TARGET=[p0,p1,p2], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

stop


setTemp = T_atom[3]
fullContrast = fltarr(n_elements(delays),7)
for i = 0, 6 do fullContrast[*,i] = full_broadening(setTemp,n_e[i],delays)


title = 'Delays versus Contrast (Full Broadening) at ~0.1eV'
p0 = plot(delays,fullContrast[*,0],xtitle='Delays (waves)', title=title, $
  ytitle='Contrast',/ystyle,Name = '1E21')
p1 = plot(delays,fullContrast[*,1], col='r',/overplot,Name = '5E20')
p2 = plot(delays,fullContrast[*,2], col='b',/overplot,Name = '3E20')
p3 = plot(delays,fullContrast[*,3], col='green',/overplot,Name = '1E20')
p4 = plot(delays,fullContrast[*,4], col='purple',/overplot,Name = '5E19')
p5 = plot(delays,fullContrast[*,5], col='cadet_blue',/overplot,Name = '3E19')
p6 = plot(delays,fullContrast[*,6], col='crimson',/overplot,Name = '1E19')
leg = LEGEND(TARGET=[p0,p1,p2,p3,p4,p5,p6], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

stop

end