pro mapgie_profile_axial

points_num = 9 ;3 repeats per location
start_shot = 7216
tmp = 0

isat_1 = ptrarr(points_num)
isat_2 = ptrarr(points_num)

area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0

setNum = 1 ;2 or 3

for i = 0, points_num-1 do begin
 shot_number = i*setNum+start_shot 
 probe_ax[i] = ptr_new(phys_quantity(shot_number))
endfor


;Create arrays
  temp_ax_mean = dblarr(points_num)
  dens_ax_mean = dblarr(points_num)
  vplasma_ax_mean = dblarr(points_num)


trange = [0.005, 0.45]
background = [0.51, 0.55]


for i = 0, points_num-1 do begin
  isat_1_cut = select_time((*isat_1[i]).tvector,(*isat_1[i]).vvector,trange)
  isat_2_cut = select_time((*isat_2[i]).tvector,(*isat_2[i]).vvector,trange)
  
  isat_1_back = select_time((*isat_1[i]).tvector,(*isat_1[i]).vvector,background)
  isat_2_back = select_time((*isat_2[i]).tvector,(*isat_2[i]).vvector,background)

  isat_1_mean[i] = mean(isat_1_cut.yvector) - mean(isat_1_back.yvector)

  isat_2_mean[i] = mean(isat_2_cut.yvector) - mean(isat_2_back.yvector)
  
  ratio_mean[i] = isat_1_mean[i]/isat_2_mean[i]

endfor

ycplot, probe_ax_location, isat_1_mean, out_base_id = oid

ycplot, probe_ax_location, isat_2_mean, oplot_id = oid

ycplot, probe_ax_location, ratio_mean

ycplot, probe_ax_location, alog(ratio_mean)

end
