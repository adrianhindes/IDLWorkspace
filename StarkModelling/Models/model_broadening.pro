pro model_broadening

nrad = 500 ;no. radial zones which everything is defined by
r = findgen(nrad)/float(nrad) ; radius for generator functions of n_e, T_atom and I, equivalent to radial position

waves = 10000 ;fix delay
delay = 2*!pi*waves

e_scales = [1E21,5E20,1E20,5E19,1E19] ;fix n_e's
t_scales = [0.01,0.05,0.1,0.5,1] ;fix temps

;Generate varying density and temperature distributions
;T_atom = -0.05*signum(cos((r/0.2)-400))+0.04 ;generate atom temperatures (Square wave)

nvar = n_elements(e_scales) ;no. varying ranges

densities = fltarr(nvar,nrad)
temps = fltarr(nvar,nrad)

;generate electron density distributions (Cosine wave)
for i = 0, nvar-1 do densities[i,*] = e_scales[i]*0.65*cos(r*!pi/2.)
; atom temperatures (Cosine)
for i = 0, nvar-1 do temps[i,*] = t_scales[i]*(cos((r/0.4)))+t_scales[i]

;Generate varying contrasts according to broadening equations, seperate broadening.

doppler = fltarr(nvar,nrad)
stark = fltarr(nvar,nrad)

for i = 0, nvar-1 do stark[i,*] = stark_broadening(densities[i,*],delay)
for i = 0, nvar-1 do doppler[i,*] = doppler_broadening(temps[i,*],delay)

d_colours = ['tan','tomato','orange','red','crimson']
s_colours = ['light_blue','sky_blue','blue','navy','midnight_blue']

e_names = ['1E21','5E20','1E20','5E19','1E19']
t_names = ['0.01eV','0.05eV','0.1eV','0.5eV','1eV'] 


;Generate plot
title = 'Spectral Broadening'+string(waves)+' Waves'
p0 = plot(stark[0,*],xtitle = 'Radial Zone', ytitle = 'Contrast', $
  col=s_colours[0],name=e_names[0],thick=2,title=title)
p1 = plot(stark[1,*],col=s_colours[1],name=e_names[1],/overplot,thick=2)
p2 = plot(stark[2,*],col=s_colours[2],name=e_names[2],/overplot,thick=2)
p3 = plot(stark[3,*],col=s_colours[3],name=e_names[3],/overplot,thick=2)
p4 = plot(stark[4,*],col=s_colours[4],name=e_names[4],/overplot,thick=2)

p5 = plot(doppler[0,*],col=d_colours[0],name=t_names[0],/overplot,thick=2,linestyle='--')
p6 = plot(doppler[1,*],col=d_colours[1],name=t_names[1],/overplot,thick=2,linestyle='--')
p7 = plot(doppler[2,*],col=d_colours[2],name=t_names[2],/overplot,thick=2,linestyle='--')
p8 = plot(doppler[3,*],col=d_colours[3],name=t_names[3],/overplot,thick=2,linestyle='--')
p9 = plot(doppler[4,*],col=d_colours[4],name=t_names[4],/overplot,thick=2,linestyle='--')


leg = legend(target=[p0,p1,p2,p3,p4,p5,p6,p7,p8,p9],POSITION=[0.1,0.3],/Auto_text_color)




  ;for i = 1, nvar-1 do s_plot = plot(stark[i,*],col=s_colours[i],/overplot,name=e_names[i]) &$
  ;for i = 0, nvar-1 do d_plot = plot(doppler[i,*],col=d_colours[i],/overplot,name=t_names[i]) &$


stop


end