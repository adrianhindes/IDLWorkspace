pro flow_profile

points_num = 19
start_shot = 5846; 6701;6644;6587;6530;6473;6416;6359;6302;6245;6188;6131;6074     ;6017;5960;5960 ;5846;3796;3796;3737   ;3620;3324;2939;2911;2857;2720;2777
tmp = 0

isat_1 = ptrarr(points_num)
isat_2 = ptrarr(points_num)

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

;vplasma_rot = ptrarr(points_num)
;pmt = ptrarr(points_num)
for i = 0, points_num-1 do begin
  shot_number = i*3+start_shot+tmp
;  if shot_number ge 3832 and shot_number le 3837 then begin
;    shot_number = shot_number + 18
;  endif 
;  if shot_number ge 3796 and shot_number le 3813 then begin
;    shot_number = shot_number + 60
;  endif 
;  probe_ax[i] = ptr_new(phys_quantity(shot_number))
  isat_1[i] = ptr_new(magpie_data('probe_isat_rot',shot_number))
  isat_2[i] = ptr_new(magpie_data('probe_vfloat_rot',shot_number))
endfor

;points_num2 = 41
;probe_1d = ptrarr(points_num2)
;for i = 0, points_num2-1 do begin
;  shot_number = i*3+639;639;2047
;  probe_1d[i] = ptr_new(phys_quantity(shot_number))
;;  print, i
;endfor

print, 'done'


isat_1_mean = dblarr(points_num)
isat_2_mean = dblarr(points_num)
ratio_mean = dblarr(points_num)

probe_ax_location = dblarr(points_num)

max_value = dblarr(points_num)
max_lag = dblarr(points_num)


;freq_filter = [10e3,50e3]
;subwindow_npts = 2048L
;window_npts = 4L*subwindow_npts

trange = [0.15, 0.25]
background = [0.3*1.05, 0.3*1.19]
;vplasma_cut = select_time((*vplasma[0]).tvector,(*vplasma[0]).vvector,trange)
;window_number = floor(size(vplasma_cut.tvector,/n_elements)/window_npts)

radius = 3.0
for i = 0, points_num-1 do begin
  isat_1_cut = select_time((*isat_1[i]).tvector,(*isat_1[i]).vvector,trange)
  isat_2_cut = select_time((*isat_2[i]).tvector,(*isat_2[i]).vvector,trange)
  
  isat_1_back = select_time((*isat_1[i]).tvector,(*isat_1[i]).vvector,background)
  isat_2_back = select_time((*isat_2[i]).tvector,(*isat_2[i]).vvector,background)
;  temp_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,trange)
;  dens_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,trange)
;  vplasma_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,trange)
;  
;  temp_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,background)
;  dens_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,background)
;  vplasma_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,background)
;  
  isat_1_mean[i] = mean(isat_1_cut.yvector) - mean(isat_1_back.yvector)
;  temp_ax_std[i] = variance(temp_ax_cut.yvector)
  isat_2_mean[i] = mean(isat_2_cut.yvector) - mean(isat_2_back.yvector)
  
  ratio_mean[i] = isat_1_mean[i]/isat_2_mean[i]
;  dens_ax_std[i] = variance(dens_ax_cut.yvector)
;  vplasma_ax_mean[i] = mean(vplasma_ax_cut.yvector)
;  vplasma_ax_std[i] = variance(vplasma_ax_cut.yvector)
;  pmt_mean[i] = mean(pmt_cut.yvector)
;  pmt_std[i] = variance(pmt_cut.yvector)

;  mach_corr = corr_time(isat_1_cut.tvector, isat_1_cut.yvector, isat_2_cut.yvector)
;  max_value[i] = max(mach_corr.xcorr[2,*],lag)
;  max_lag[i] = lag
;  probe_ax_location[i] = 69.7+2.5*i
  probe_ax_location[i] = sqrt((radius*cos((180.-(90.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(90.-10.*i))*!pi/180.)+3)^2.)
;  probe_ax_location[i] = sqrt((radius*cos((180.-(90.-10.*i))*!pi/180.))^2.+(radius*sin((180.-(90.-10.*i))*!pi/180.)+3)^2.)
endfor

ycplot, probe_ax_location, isat_1_mean, out_base_id = oid

ycplot, probe_ax_location, isat_2_mean, oplot_id = oid

ycplot, probe_ax_location, ratio_mean

ycplot, probe_ax_location, alog(ratio_mean)


;ycplot, vplasma1_location ,temp1_mean
;ycplot, vplasma1_location, dens1_mean

end
