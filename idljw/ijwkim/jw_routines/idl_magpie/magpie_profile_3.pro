pro magpie_profile_3

points_num = 19

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

;isat_rot = ptrarr(points_num)
;pmt = ptrarr(points_num)
for i = 0, points_num-1 do begin
  shot_number = i*3+4089;2720;2777
  probe_ax[i] = ptr_new(phys_quantity(shot_number, discharge_time = 0.5))
;  print, i
endfor

points_num2 = 41
probe_1d = ptrarr(points_num2)
for i = 0, points_num2-1 do begin
  shot_number = i*3+2047;638;639;2047
  probe_1d[i] = ptr_new(phys_quantity(shot_number))
;  print, i
endfor

print, 'done'

;isat[0] = ptr_new(magpie_data('probe_isat',1007))
;pmt[0] = ptr_new(magpie_data('single_pmt',1007))
;isat[1] = ptr_new(magpie_data('probe_isat',1376))
;pmt[1] = ptr_new(magpie_data('single_pmt',1376))
;isat[2] = ptr_new(magpie_data('probe_isat',1499))
;pmt[2] = ptr_new(magpie_data('single_pmt',1499))
;isat[3] = ptr_new(magpie_data('probe_isat',1622))
;pmt[3] = ptr_new(magpie_data('single_pmt',1622))
;isat[4] = ptr_new(magpie_data('probe_isat',1745))
;pmt[4] = ptr_new(magpie_data('single_pmt',1745))

temp_ax_mean = dblarr(points_num)
dens_ax_mean = dblarr(points_num)
isat_ax_mean = dblarr(points_num)
temp_ax_std = dblarr(points_num)
dens_ax_std = dblarr(points_num)
isat_ax_std = dblarr(points_num)

temp_1d_mean = dblarr(points_num2)
dens_1d_mean = dblarr(points_num2)
isat_1d_mean = dblarr(points_num2)
temp_1d_std = dblarr(points_num2)
dens_1d_std = dblarr(points_num2)
isat_1d_std = dblarr(points_num2)

probe_ax_location = dblarr(points_num)

probe_1d_location = dblarr(points_num2)

;freq_filter = [10e3,50e3]
;subwindow_npts = 2048L
;window_npts = 4L*subwindow_npts

trange = [0.01, 0.29]

background1 = [0.5*1.1, 0.5*1.19]
;isat_cut = select_time((*isat[0]).tvector,(*isat[0]).vvector,trange)
;window_number = floor(size(isat_cut.tvector,/n_elements)/window_npts)
temp = magpie_data('probe_temp',shot_number)
radius = 2.75
for i = 0, points_num-1 do begin
  temp_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,trange)
  dens_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,trange)
  isat_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).isat,trange)
  
  temp_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,background1)
  dens_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,background1)
  isat_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).isat,background1)
  
  temp_ax_mean[i] = (mean(temp_ax_cut.yvector)-mean(temp_ax_back.yvector))
  temp_ax_std[i] = variance(temp_ax_cut.yvector)
  dens_ax_mean[i] = (mean(dens_ax_cut.yvector)-mean(dens_ax_back.yvector))
  dens_ax_std[i] = variance(dens_ax_cut.yvector)
  isat_ax_mean[i] = (mean(isat_ax_cut.yvector)-mean(isat_ax_back.yvector))
  isat_ax_std[i] = variance(isat_ax_cut.yvector)
;  pmt_mean[i] = mean(pmt_cut.yvector)
;  pmt_std[i] = variance(pmt_cut.yvector)
  probe_ax_location[i] = sqrt((radius*cos((180.-(90.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(90.-10.*i))*!pi/180.)+3)^2.)
;  probe_ax_location[i] = sqrt((radius*cos((10.*i)*!pi/180.))^2.+(radius*sin((10.*i)*!pi/180.)+3)^2.)
endfor


background2 = [0.3*1.1,0.3*1.19]
for i = 0, points_num2-1 do begin
  temp_1d_cut = select_time((*probe_1d[i]).tvector,(*probe_1d[i]).temp,trange)
  dens_1d_cut = select_time((*probe_1d[i]).tvector,(*probe_1d[i]).dens,trange)
  isat_1d_cut = select_time((*probe_1d[i]).tvector,(*probe_1d[i]).isat,trange)
  
  temp_1d_back = select_time((*probe_1d[i]).tvector,(*probe_1d[i]).temp,background2)
  dens_1d_back = select_time((*probe_1d[i]).tvector,(*probe_1d[i]).dens,background2)
  isat_1d_back = select_time((*probe_1d[i]).tvector,(*probe_1d[i]).isat,background2)
  
  temp_1d_mean[i] = (mean(temp_1d_cut.yvector)-mean(temp_1d_back.yvector))-3+!PI*(0.10E-3)^2.0
  
  temp_1d_std[i] = variance(temp_1d_cut.yvector)
  dens_1d_mean[i] = (mean(dens_1d_cut.yvector)-mean(dens_1d_back.yvector))
  dens_1d_std[i] = variance(dens_1d_cut.yvector)
  isat_1d_mean[i] = (mean(isat_1d_cut.yvector)-mean(isat_1d_back.yvector))
  isat_1d_std[i] = variance(isat_1d_cut.yvector)
;  pmt_mean[i] = mean(pmt_cut.yvector)
;  pmt_std[i] = variance(pmt_cut.yvector)
  probe_1d_location[i] = (*probe_1d[i]).location-2.25
endfor

ycplot, probe_1D_location, temp_1d_mean, error=temp_1d_std, out_base_id = oid1
stop
ycplot, probe_ax_location, temp_ax_mean, error=temp_ax_std, oplot_id = oid1
stop
ycplot, probe_1D_location, dens_1d_mean, error=dens_1d_std, out_base_id = oid1
stop
ycplot, probe_ax_location, dens_ax_mean, error=dens_ax_std, oplot_id = oid1
stop
ycplot, probe_1D_location, isat_1d_mean, error=isat_1d_std, out_base_id = oid1
stop
ycplot, probe_ax_location, isat_ax_mean, error=isat_ax_std, oplot_id = oid1


;ycplot, isat1_location ,temp1_mean
;ycplot, isat1_location, dens1_mean
stop

end