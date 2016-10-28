pro check_profile_rad

points_num =25
tmp = 0
first_shot = 4994;5570;4913;5480;5405;5369;5294;5219;4994;4913;4913;4838;4763;4688;4370;4526;4445;4370;4295;4232;4160;4088;4031
probe_rad = ptrarr(points_num)

area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
e_charge = -1.602177E-19
atomic_mass = 1.660539E-27
m_i = 39.948*atomic_mass
boltzmann_si = 1.380648E-23
boltzmann_ev = 8.617332E-580
charge_state = 1

ionize_0_1_temp = [1.723E-01, 4.308E-01, 8.617E-01, 1.723E+00, 4.308E+00, 8.617E+00, 1.723E+01, 4.308E+01, 8.617E+01, 1.723E+02, 4.308E+02, 8.617E+02]
ionize_0_1 = [1.000E-36, 1.230E-23, 1.782E-15, 2.426E-11, 7.985E-09, 5.440E-08, 1.382E-07, 2.355E-07, 2.803E-07, 3.247E-07, 5.391E-07, 8.127E-07]

cspeed_tmp = sqrt(boltzmann_si*charge_state/m_i)

;vplasma_rot = ptrarr(points_num)
;pmt = ptrarr(points_num)
for i = 0, points_num-1 do begin
  shot_number = i*3+first_shot+tmp;2939;2911;2857;2720;2777
;  if i gt 24 then begin
;    shot_number = 4607 + 3*(i-25)+tmp
;  endif 
;  if shot_number gt 3976 then begin
;    shot_number = (i-12)*3+4031
;  endif
;  if shot_number gt 4015 then begin
;    shot_number = (i-14)*3+4022
;  endif
  probe_rad[i] = ptr_new(phys_quantity(shot_number,discharge_time = 0.5))
;  print, shot_number
endfor

;points_num2 = 41
;probe_1d = ptrarr(points_num2)
;for i = 0, points_num2-1 do begin
;  shot_number = i*3+639;639;2047
;  probe_1d[i] = ptr_new(phys_quantity(shot_number))
;;  print, i
;endfor

print, 'done'
isat_rad_mean = dblarr(points_num)
vfloat_rad_mean = dblarr(points_num)
vplus_rad_mean = dblarr(points_num)
temp_rad_mean = dblarr(points_num)
dens_rad_mean = dblarr(points_num)
vplasma_rad_mean = dblarr(points_num)

isat_rad_std = dblarr(points_num)
vfloat_rad_std = dblarr(points_num)
vplus_rad_std = dblarr(points_num)
temp_rad_std = dblarr(points_num)
dens_rad_std = dblarr(points_num)
vplasma_rad_std = dblarr(points_num)

probe_rad_location = dblarr(points_num)


;freq_filter = [10e3,50e3]
;subwindow_npts = 2048L
;window_npts = 4L*subwindow_npts

trange = [0.38, 0.4]

background = [0.5*1.05, 0.5*1.19]
;vplasma_cut = select_time((*vplasma[0]).tvector,(*vplasma[0]).vvector,trange)
;window_number = floor(size(vplasma_cut.tvector,/n_elements)/window_npts)

radius = 3.04232
for i = 0, points_num-1 do begin
  isat_rad_cut = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).isat,trange)
  vfloat_rad_cut = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).vfloat,trange)
  vplus_rad_cut = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).vplus,trange)
  temp_rad_cut = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).temp,trange)
  dens_rad_cut = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).dens,trange)
  vplasma_rad_cut = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).vplasma,trange)
  
  isat_rad_back = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).isat,background)
  vfloat_rad_back = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).vfloat,background)
  vplus_rad_back = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).vplus,background)
  temp_rad_back = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).temp,background)
  dens_rad_back = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).dens,background)
  vplasma_rad_back = select_time((*probe_rad[i]).tvector,(*probe_rad[i]).vplasma,background)
  
  isat_rad_mean[i] = (mean(isat_rad_cut.yvector)-mean(isat_rad_back.yvector))
  isat_rad_std[i] = sqrt(variance(isat_rad_cut.yvector))
  vfloat_rad_mean[i] = (mean(vfloat_rad_cut.yvector)-mean(vfloat_rad_back.yvector))
  vfloat_rad_std[i] = sqrt(variance(vfloat_rad_cut.yvector))
  vplus_rad_mean[i] = (mean(vplus_rad_cut.yvector)-mean(vplus_rad_back.yvector))
  vplus_rad_std[i] = sqrt(variance(vplus_rad_cut.yvector))
  
  temp_rad_mean[i] = (mean(temp_rad_cut.yvector)-mean(temp_rad_back.yvector))
  temp_rad_std[i] = sqrt(variance(temp_rad_cut.yvector))
  dens_rad_mean[i] = (mean(dens_rad_cut.yvector)-mean(dens_rad_back.yvector))
  dens_rad_std[i] = sqrt(variance(dens_rad_cut.yvector))
  vplasma_rad_mean[i] = (mean(vplasma_rad_cut.yvector)-mean(vplasma_rad_back.yvector))
  vplasma_rad_std[i] = sqrt(variance(vplasma_rad_cut.yvector))
;  pmt_mean[i] = mean(pmt_cut.yvector)
;  pmt_std[i] = variance(pmt_cut.yvector)4913
;  probe_rad_location[i] = 77.2+2.5*i
  probe_rad_location[i] = sqrt((radius*cos((180.-(90.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(90.-10.*i))*!pi/180.)+3)^2.)
  
  fine_shot = 13
  if first_shot gt 4232 then begin
    fine_shot = 12
  endif
  if i ge fine_shot+1 then begin
  probe_rad_location[i] = sqrt((radius*cos((180.-(-30.-5.*(i-fine_shot)))*!pi/180.))^2.+(radius*sin((180.-(-30.-5.*(i-fine_shot)))*!pi/180.)+3)^2.)
  endif
  
;  probe_rad_location[i] = sqrt((radius*cos((180.-(90.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(90.-10.*i))*!pi/180.)+3)^2.)
endfor

ycplot, probe_rad_location, isat_rad_mean, error=isat_rad_std, oplot_id = oid1, xtitle = 'location', ytitle = 'Isat'
ycplot, probe_rad_location, vfloat_rad_mean, error=vfloat_rad_std, oplot_id = oid1, xtitle = 'location', ytitle = 'Vfloat'
ycplot, probe_rad_location, vplus_rad_mean, error=vplus_rad_std, oplot_id = oid1, xtitle = 'location', ytitle = 'Vplus'

ycplot, probe_rad_location, temp_rad_mean, error=temp_rad_std, oplot_id = oid1, xtitle = 'location', ytitle = 'Temperature'
ycplot, probe_rad_location, dens_rad_mean, error=dens_rad_std, oplot_id = oid1, xtitle = 'location', ytitle = 'Density'
ycplot, probe_rad_location, vplasma_rad_mean, error=vplasma_rad_std, oplot_id = oid1, xtitle = 'location', ytitle = 'Vplasma'


;ycplot, vplasma1_location ,temp1_mean
;ycplot, vplasma1_location, dens1_mean

end