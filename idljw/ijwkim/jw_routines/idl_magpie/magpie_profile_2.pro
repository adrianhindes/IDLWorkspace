pro magpie_profile_2

;shot_number = 15
;d1 = magpie_data('probe_isat', shot_number)
;d2 = magpie_data('probe_float', shot_number)
;d3 = magpie_data('single_pmt', shot_number)
;
;ycplot, d3.tvector, d3.vvector
;
;
;trange = [0.10, 0.9]
;subwindow_npts = 4096
;a = jw_spectrum(d1.tvector, d1.vvector, d1.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
;b = jw_spectrum(d2.tvector, d2.vvector, d2.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
;c = jw_spectrum(d3.tvector, d3.vvector, d3.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
;c = jw_spectrum(d1.tvector, d1.vvector, d2.vvector, trange,/power_plot,/phase_plot,/coherency_plot,subwindow_npts = subwindow_npts)
;d = jw_spectrogram(d1.tvector, d1.vvector, d2.vvector,/power_plot,/phase_plot,subwindow_npts = 512,num_subwindow_avg = 80)
;
;e = corr_time(d1.tvector, d1.vvector, d2.vvector)
points_num = 36

isat_rot = ptrarr(points_num)
vfloat_rot = ptrarr(points_num)

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
  shot_number = i*3+529
  isat_rot[i] = ptr_new(magpie_data('probe_isat_rot',shot_number))
  vfloat_rot[i] = ptr_new(magpie_data('probe_vfloat_rot',shot_number))
  print, i
endfor

points_num2 = 41
isat1 = ptrarr(points_num2)
vfloat1 = ptrarr(points_num2)
vplus1 = ptrarr(points_num2)
for i = 0, points_num2-1 do begin
  shot_number = i*3+1007;639;2047
  isat1[i] = ptr_new(magpie_data('probe_isat',shot_number))
  vfloat1[i] = ptr_new(magpie_data('probe_vfloat',shot_number))
  vplus1[i] = ptr_new(magpie_data('probe_vplus',shot_number))
  print, i
endfor

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

isat_rot_mean = dblarr(points_num)
vfloat_rot_mean = dblarr(points_num)
isat_rot_std = dblarr(points_num)
vfloat_rot_std = dblarr(points_num)
isat_rot_location = dblarr(points_num)

isat1_mean = dblarr(points_num2)
vfloat1_mean = dblarr(points_num2)
vplus1_mean = dblarr(points_num2)
temp1_mean = dblarr(points_num2)
dens1_mean = dblarr(points_num2)

isat1_std = dblarr(points_num2)
vfloat1_std = dblarr(points_num2)
vplus1_std = dblarr(points_num2)
temp1_std = dblarr(points_num2)
dens1_std = dblarr(points_num2)

isat1_location = dblarr(points_num2)

;freq_filter = [10e3,50e3]
;subwindow_npts = 2048L
;window_npts = 4L*subwindow_npts

trange = [0.01, 0.29]

background = [0.3*1.05, 0.3*1.19]
;isat_cut = select_time((*isat[0]).tvector,(*isat[0]).vvector,trange)
;window_number = floor(size(isat_cut.tvector,/n_elements)/window_npts)

stop

radius = 2.85
for i = 0, points_num-1 do begin
  isat_rot_cut = select_time((*isat_rot[i]).tvector,(*isat_rot[i]).vvector,trange)
  vfloat_rot_cut = select_time((*vfloat_rot[i]).tvector,(*vfloat_rot[i]).vvector,trange)
  isat_rot_back = select_time((*isat_rot[i]).tvector,(*isat_rot[i]).vvector,background)
  vfloat_rot_back = select_time((*vfloat_rot[i]).tvector,(*vfloat_rot[i]).vvector,background)
  
  isat_rot_mean[i] = (mean(isat_rot_cut.yvector)-mean(isat_rot_back.yvector)) /400.
  isat_rot_std[i] = variance(isat_rot_cut.yvector)/400.
  vfloat_rot_mean[i] = (mean(vfloat_rot_cut.yvector)-mean(vfloat_rot_back.yvector)) /5.*1003./3.
  vfloat_rot_std[i] = variance(vfloat_rot_cut.yvector)/5.*1003./3.
;  pmt_mean[i] = mean(pmt_cut.yvector)
;  pmt_std[i] = variance(pmt_cut.yvector)
  isat_rot_location[i] = sqrt((radius*cos((180.-(270.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(270.-10.*i))*!pi/180.)+3)^2.)
  print, mean(isat_rot_back.yvector)
endfor

stop

for i = 0, points_num2-1 do begin
  isat1_cut = select_time((*isat1[i]).tvector,(*isat1[i]).vvector,trange)
  isat1_back = select_time((*isat1[i]).tvector,(*isat1[i]).vvector,background)
  vfloat1_cut = select_time((*vfloat1[i]).tvector,(*vfloat1[i]).vvector,trange)
  vfloat1_back = select_time((*vfloat1[i]).tvector,(*vfloat1[i]).vvector,background)
  vplus1_cut = select_time((*vplus1[i]).tvector,(*vplus1[i]).vvector,trange)
  vplus1_back = select_time((*vplus1[i]).tvector,(*vplus1[i]).vvector,background)
  
  isat1_mean[i] = (mean(isat1_cut.yvector)-mean(isat1_back.yvector)) /200.
  isat1_std[i] = variance(isat1_cut.yvector)/200.
  vfloat1_mean[i] = (mean(vfloat1_cut.yvector)-mean(vfloat1_back.yvector)) /5.*1003./3.
  vfloat1_std[i] = variance(vfloat1_cut.yvector)/5.*1003./3.
  vplus1_mean[i] = (mean(vplus1_cut.yvector)-mean(vplus1_back.yvector)) /5.*1003./3.
  vplus1_std[i] = variance(vplus1_cut.yvector)/5.*1003./3.
  temp1_mean[i] = abs((vfloat1_mean[i]-vplus1_mean[i])/alog(2)*11604)
  dens1_mean[i] = isat1_mean[i]/area_isat/e_charge/cspeed_tmp/sqrt(temp1_mean[i])  
  
;  pmt_mean[i] = mean(pmt_cut.yvector)
;  pmt_std[i] = variance(pmt_cut.yvector)
  isat1_location[i] = abs((*isat1[i]).location-2.0)
  print, mean(isat1_back.yvector)
endfor

ycplot, isat_rot_location, isat_rot_mean/area_isat_rot, error=isat_rot_std, out_base_id = oid1
ycplot, isat1_location, isat1_mean/area_isat, error = isat1_std, oplot_id = oid1
;ycplot, isat_location, pmt_mean, error = =pmt_std, oplot_id = oid
ycplot, isat_rot_location, vfloat_rot_mean, error = vfloat_rot_std, out_base_id = oid2
ycplot, isat1_location, vfloat1_mean, error = vfloat1_std, oplot_id = oid2

ycplot, isat1_location ,temp1_mean
ycplot, isat1_location, dens1_mean
stop

end