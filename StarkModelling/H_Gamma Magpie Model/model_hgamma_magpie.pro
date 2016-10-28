pro model_Hgamma_MAGPIE

default, phi, range(0.,1e4,100.)*2*!pi
path = 'C:\Users\adria\IDLWorkspace85\Default\StarkModelling\Modelling'


n_e = range(5, 25., 5., /exact)*1e18
T_atom = range(0.,1200, 50.,/exact) ; temperature in Kelvin
T_atom_ev = T_atom/11604. ;temperature in eV

stop

; Fix the delay, look at inferred density, ignoring atom temperature effects
waves = 4000
phi0 = 2*!pi*waves

n_e = range(5, 30., 1., /exact)*1e18
n_e_approx = fltarr(n_elements(n_e), n_elements(T_atom))
n_e_contrast = lorentzian_zeta(phi0, n_e)

for i=0, n_elements(T_atom)-1 do begin &$
;n_e_invert = zeta_to_density(n_e_contrast, phi0)
;T_contrast = thermal_zeta(delay=phi0, temperature = T_atom_eV[i], a=1) &$
  ;n_e_APPROX[*,i] = (zeta_to_density(n_e_contrast*T_contrast, phi0)-n_e)/n_e &$
end


  rgb = 4
  title = 'Percent error for optical delay '+strtrim(waves,2)+' waves'
  levels = range(0.,25,1,/exact)
  cc = contour(n_e_approx*100,n_e, T_atom, c_value=levels,/fill, font_size=14, $
    xtitl='Electron density', ytitl='Hydrogen temperature K',dim=[1200,800],position=[0.15,0.1,0.82,0.9], rgb_table=rgb,$
    TITLE= title)

  cb1 = COLORBAR(TITLE='Percent error', target=cc, $
    ORIENTATION=1,  POSITION=[0.92, 0.1, 0.97, 0.9], font_size=12, border=1, taper=0)

;  cc.save, path+title+'.png',/transp

stop

waves = 2000+indgen(4)*1000
n_e_contrast = fltarr(n_elements(n_e),n_elements(waves))
for i=0, n_elements(waves)-1 do  n_e_contrast[*,i] = lorentzian_zeta(2*!pi*waves[i], n_e)

title = 'Contrast versus density'
p0 = plot(n_e,n_e_contrast[*,0],xtitle='Electron density $(m^{-3})$', title=title, $
    ytitle='Contrast',yrange=[0.4,1.],/ystyle,Name = '2000 waves'); ,/ylog)
  p1 = plot(n_e,n_e_contrast[*,1], col='r',/overplot,Name = '3000 waves')
  p2 = plot(n_e,n_e_contrast[*,2], col='b',/overplot,Name = '4000 waves')
  p3 = plot(n_e,n_e_contrast[*,3], col='green',/overplot,Name = '5000 waves')
T_contrast = thermal_zeta(delay=phi0, temperature = 1000./11604., a=1)
p01 =  plot(n_e,n_e_contrast[*,0]*T_contrast, col='black',/overplot,linestyle = '--' )
p02 =  plot(n_e,n_e_contrast[*,1]*T_contrast, col='red',/overplot,linestyle = '--' )
p03 =  plot(n_e,n_e_contrast[*,2]*T_contrast, col='blue',/overplot,linestyle = '--' )
p04 =  plot(n_e,n_e_contrast[*,3]*T_contrast, col='green',/overplot,linestyle = '--' )


leg = LEGEND(TARGET=[p0,p1,p2,p3], POSITION=[0.8,0.85], /AUTO_TEXT_COLOR)

  p0.save, path+title+'.png',/transp


stop

device,decomp=0
tek_color
!p.multi=[0,2,1]
Gamma = density_to_Gamma( n_e )
 
plot, phi/2/!pi, lorentzian_zeta(phi, n_e[0]), /ylog, yr=[0.4,1.],/yst
for i=1, n_elements(n_e)-1 do oplot, phi/2/!pi, lorentzian_zeta(phi, Gamma[i]), col=i+1

plot, phi/2/!pi, thermal_zeta(delay=phi, temperature = T_atom_eV[5], a=1), /ylog
for i=1, n_elements(T_atom_eV)-1 do oplot, phi/2/!pi, thermal_zeta(delay=phi, temperature = T_atom_eV[i], a=1), col=i+1

; overplot the contrast when including atom temperature of 1000K

T_contrast = thermal_zeta(delay=phi, temperature = 0.1, a=1)
plot, phi/2/!pi, lorentzian_zeta(phi, n_e[0]), /ylog, yr=[0.4,1.],/yst
for i=1, n_elements(n_e)-1 do oplot, phi/2/!pi, lorentzian_zeta(phi, Gamma[i]), col=i+1
for i=1, n_elements(n_e)-1 do oplot, phi/2/!pi, lorentzian_zeta(phi, Gamma[i])*T_contrast, col=i+1, linesty=2



end
