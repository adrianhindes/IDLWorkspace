pro magpie_profile_6

points_num = 19
tmp = 0
start_shot = 3448
probe_ax = ptrarr(points_num)

area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0

e_charge = -!const.e
atomic_mass = 1.660539E-27
m_i = 39.948*atomic_mass
boltzmann_si = !const.k
boltzmann_ev = 8.617332E-5
charge_state = 13064

ionize_0_1_temp = [1.723E-01, 4.308E-01, 8.617E-01, 1.723E+00, 4.308E+00, 8.617E+00, 1.723E+01, 4.308E+01, 8.617E+01, 1.723E+02, 4.308E+02, 8.617E+02]
ionize_0_1 = [1.000E-36, 1.230E-23, 1.782E-15, 2.426E-11, 7.985E-09, 5.440E-08, 1.382E-07, 2.355E-07, 2.803E-07, 3.247E-07, 5.391E-07, 8.127E-07]

cspeed_tmp = sqrt(boltzmann_si*charge_state/m_i)

;vplasma_rot = ptrarr(points_num)
;pmt = ptrarr(points_num)
for i = 0, points_num-1 do begin
  shot_number = i*3+start_shot+tmp;3505;3620;3324;2939;2911;2857;2720;2777
  probe_ax[i] = ptr_new(phys_quantity(shot_number))
;  print, i
endfor

;points_num2 = 41
;probe_1d = ptrarr(points_num2)
;for i = 0, points_num2-1 do begin
;  shot_number = i*3+639;639;2047
;  probe_1d[i] = ptr_new(phys_quantity(shot_number))
;;  print, i
;endfor

print, 'done'

;vplasma[0] = ptr_new(magpie_data('probe_vplasma',1007))
;pmt[0] = ptr_new(magpie_data('single_pmt',1007))
;vplasma[1] = ptr_new(magpie_data('probe_vplasma',1376))
;pmt[1] = ptr_new(magpie_data('single_pmt',1376))
;vplasma[2] = ptr_new(magpie_data('probe_vplasma',1499))
;pmt[2] = ptr_new(magpie_data('single_pmt',1499))3881
;vplasma[3] = ptr_new(magpie_data('probe_vplasma',1622))
;pmt[3] = ptr_new(magpie_data('single_pmt',1622))
;vplasma[4] = ptr_new(magpie_data('probe_vplasma',1745))
;pmt[4] = ptr_new(magpie_data('single_pmt',1745))

temp_ax_mean = dblarr(points_num)
dens_ax_mean = dblarr(points_num)
vplasma_ax_mean = dblarr(points_num)
temp_ax_std = dblarr(points_num)
dens_ax_std = dblarr(points_num)
vplasma_ax_std = dblarr(points_num)

probe_ax_location = dblarr(points_num)


;freq_filter = [10e3,50e3]
;subwindow_npts = 2048L
;window_npts = 4L*subwindow_npts

trange = [0.15, 0.25]

background = [0.3*1.05, 0.3*1.19]
;vplasma_cut = select_time((*vplasma[0]).tvector,(*vplasma[0]).vvector,trange)
;window_number = floor(size(vplasma_cut.tvector,/n_elements)/window_npts)

radius = 3.0
for i = 0, points_num-1 do begin
  temp_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,trange)
  dens_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,trange)
  vplasma_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,trange)
  
  temp_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,background)
  dens_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,background)
  vplasma_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,background)
  
  temp_ax_mean[i] = mean(temp_ax_cut.yvector)
  temp_ax_std[i] = sqrt(variance(temp_ax_cut.yvector))
  dens_ax_mean[i] = mean(dens_ax_cut.yvector)
  dens_ax_std[i] = sqrt(variance(dens_ax_cut.yvector))
  vplasma_ax_mean[i] = mean(vplasma_ax_cut.yvector)
  vplasma_ax_std[i] = sqrt(variance(vplasma_ax_cut.yvector))
;  pmt_mean[i] = mean(pmt_cut.yvector)
;  pmt_std[i] = variance(pmt_cut.yvector)
;  probe_ax_location[i] = 77.2+2.5*i
  probe_ax_location[i] = sqrt((radius*cos((180.-(90.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(90.-10.*i))*!pi/180.)+3)^2.)
endfor

ycplot, probe_ax_location, temp_ax_mean, error=temp_ax_std, oplot_id = oid1

ycplot, probe_ax_location, dens_ax_mean, error=dens_ax_std, oplot_id = oid1

ycplot, probe_ax_location, vplasma_ax_mean, error=vplasma_ax_std, oplot_id = oid1


;ycplot, vplasma1_location ,temp1_mean
;ycplot, vplasma1_location, dens1_mean
stop

end