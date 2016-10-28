pro T_profile
  points_num = 41

  p_vfloat = ptrarr(points_num)
  p_vplus = ptrarr(points_num)
  for i = 0, points_num-1 do begin
    shot_number = i*3+181
    p_vfloat[i] = ptr_new(magpie_data('probe_vfloat',shot_number))
    p_vplus[i] = ptr_new(magpie_data('probe_vplus',shot_number))
    print, i
  endfor

vfloat_mean = dblarr(points_num)
vplus_mean = dblarr(points_num)
vfloat_std = dblarr(points_num)
vplus_std = dblarr(points_num)
t_mean = dblarr(points_num)
t_location = dblarr(points_num)

trange = [0.01, 0.09]

e_charge = 1.602E-19
boltzmann = 8.617E-5
for i = 0, points_num-1 do begin
  if i le 19 then begin
    gain=1003./3./100.  
  endif else begin
    gain=1003./3./50.
  endelse
  
  vfloat_cut = select_time((*p_vfloat[i]).tvector,(*p_vfloat[i]).vvector,trange)
  vplus_cut = select_time((*p_vplus[i]).tvector,(*p_vplus[i]).vvector,trange)
  t_mean[i] = mean((vplus_cut.yvector-vfloat_cut.yvector)/alog(2))*gain
  t_location[i] = (*p_vfloat[i]).location
  print, i
endfor

stop

ycplot, t_location, t_mean, out_base_id = oid1

end