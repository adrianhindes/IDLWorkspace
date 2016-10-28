pro magpie_profile_radial_avg

  points_num = 18 ;18*3 (3 measurements per angle), total 54 measurements

  probe_ax = ptrarr(points_num)

  area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
  area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0

  e_charge = -1.602177E-19
  atomic_mass = 1.660539E-27
  m_i = 39.948*atomic_mass
  boltzmann_si = 1.380648E-23
  boltzmann_ev = 8.617332E-5
  charge_state = 1

  ionize_0_1_temp = [1.723E-01, 4.308E-01, 8.617E-01, 1.723E+00, 4.308E+00, 8.617E+00, 1.723E+01, 4.308E+01, 8.617E+01, 1.723E+02, 4.308E+02, 8.617E+02]
  ionize_0_1 = [1.000E-36, 1.230E-23, 1.782E-15, 2.426E-11, 7.985E-09, 5.440E-08, 1.382E-07, 2.355E-07, 2.803E-07, 3.247E-07, 5.391E-07, 8.127E-07]

  cspeed_tmp = sqrt(boltzmann_si*charge_state/m_i)
  setNum =  2;1 2 or 3
  start_shot = 7106
  for i = 0, points_num-1 do begin
    shot_number = i*setNum+start_shot
    probe_ax[i] = ptr_new(phys_quantity(shot_number))
  endfor


  print, 'done'


  temp_ax_mean = dblarr(points_num)
  dens_ax_mean = dblarr(points_num)
  vplasma_ax_mean = dblarr(points_num)
  temp_ax_std = dblarr(points_num)
  dens_ax_std = dblarr(points_num)
  vplasma_ax_std = dblarr(points_num)

  probe_ax_location = dblarr(points_num)


  trange = [0.05, 0.09]

  background = [0.11,0.12]

  radius = 2.75
  for i = 0, points_num-1 do begin
    temp_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,trange)
    dens_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,trange)
    vplasma_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,trange)
    isat_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).isat,trange)
    temp_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,background)
    ;dens_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,background)
    vplasma_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,background)

    temp_ax_mean[i] = (mean(temp_ax_cut.yvector)-mean(temp_ax_back.yvector))
    ;temp_ax_std[i] = stddev(temp_ax_cut.yvector)
    dens_ax_mean[i] = (mean(dens_ax_cut.yvector));-mean(dens_ax_back.yvector))
    ;dens_ax_std[i] = stddev(dens_ax_cut.yvector)
    vplasma_ax_mean[i] = (mean(vplasma_ax_cut.yvector)-mean(vplasma_ax_back.yvector))
    ;vplasma_ax_std[i] = stddev(vplasma_ax_cut.yvector)

    ;probe_ax_location[i] = 64.7+2.5*i
    ;probe_ax_location[i] = sqrt((radius*cos((180.-(90.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(90.-10.*i))*!pi/180.)+3)^2.)
  endfor

  ;First set of axial experiments, started pointing down and rotated clockwise
  ;probe_ax_location=[270,290,310,330,350,10,30,50,70,90,110,130,150,170,190,210,230,250] (Actual)
  ;so shift data
  shiftVal = -5
  temp_ax_mean = shift(temp_ax_mean, shiftVal)
  dens_ax_mean = shift(dens_ax_mean, shiftVal)
  vplasma_ax_mean = shift(vplasma_ax_mean, shiftVal)
  probe_ax_location=[10,30,50,70,90,110,130,150,170,190,210,230,250,270,290,310,330,350]
  stop
  xlab='Degrees'

  ycplot, probe_ax_location, temp_ax_mean, oplot_id = oid1, title='Temperature',xtitle=xlab,ytitle='Temperature (eV)'

  ycplot, probe_ax_location, dens_ax_mean, oplot_id = oid1, title='Density',xtitle=xlab,ytitle='Density (m^(-3))'

  ycplot, probe_ax_location, vplasma_ax_mean, oplot_id = oid1, title = 'Plasma Potential',xtitle=xlab,ytitle='Voltage (V)'


  ;ycplot, vplasma1_location ,temp1_mean
  ;ycplot, vplasma1_location, dens1_mean
  stop

end