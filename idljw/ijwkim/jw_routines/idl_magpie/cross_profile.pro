pro cross_profile
  points_num = 36

  rotating_probe = ptrarr(points_num)
  
  degree = dblarr(36)
  rot_radius = dblarr(36)
  rot_degree = dblarr(36)
  rot_x = dblarr(36)
  rot_y = dblarr(36)
  radius = 2.85
  
  for i = 0, points_num-1 do begin
    shot_number = i*3+527
    rotating_probe[i] = ptr_new(phys_quantity(shot_number))
    
    degree[i] = 270.-10.*i
    rot_x[i] = radius*cos((180.-degree[i])*!pi/180.)
    rot_y[i] = radius*sin((180.-degree[i])*!pi/180.)+3
    print, i
  endfor
  
  rot_radius = sqrt(rot_x^2.0+rot_y^2.0)
  rot_degree = atan(rot_x/rot_y)+!pi/2.

  freq_filter = [10e3,30e3]
  subwindow_npts = 1024L
  window_npts = 10L*subwindow_npts

  trange = [0.01, 0.29]
  window_number = floor((trange[1]-trange[0])/1.E-6/window_npts)

  corr_map = dblarr(points_num, window_number)
  envel_map = dblarr(points_num, window_number)
  corr_map_tvector = dblarr(window_number)
  
  time_lag = dblarr(points_num)
  
  corr_tmp = ptrarr(points_num)
  for i = 0, points_num-1 do begin
    isat_cut = select_time((*rotating_probe[i]).tvector,(*rotating_probe[i]).isat,trange)
    isat_rot_cut = select_time((*rotating_probe[i]).tvector,(*rotating_probe[i]).isat_rot,trange)
    vfloat_cut = select_time((*rotating_probe[i]).tvector,(*rotating_probe[i]).vfloat,trange)
    vfloat_rot_cut = select_time((*rotating_probe[i]).tvector,(*rotating_probe[i]).vfloat_rot,trange)
;    isat_mean[i] = mean(isat_cut.yvector)
;    isat_std[i] = variance(isat_cut.yvector)
;    pmt_mean[i] = mean(pmt_cut.yvector)
;    pmt_std[i] = variance(pmt_cut.yvector)
;    isat_location[i] = (*isat[i]).location
    corr_tmp[i] = ptr_new(corr_time(isat_cut.tvector,isat_cut.yvector,isat_rot_cut.yvector, $
      freq_filter = freq_filter,window_npts = window_npts, subwindow_npts=subwindow_npts,fast = 5) ) 
    corr_map[i,*] = (*corr_tmp[i]).xcorr_mean
    envel_map[i,*] = (*corr_tmp[i]).envel_mean
;    stop
;    stop
    
    a = max(mean((*corr_tmp[i]).xcorr,dimension=1),index)
    time_lag[i] = (*corr_tmp[i]).lag[index]
    print, i
  endfor
  
  stop
  corr_map_tvector = (*corr_tmp[0]).tvector

  isat_location = findgen(36)*10
; ycplot, isat_location, isat_mean, error=isat_std, out_base_id = oid
; ycplot, isat_location, pmt_mean, error = pmt_std, oplot_id = oid
; ycplot, isat_location, isat_std, out_base_id = oid
; ycplot, isat_location, pmt_std, oplot_id = oid
  ycshade, transpose(corr_map), corr_map_tvector, isat_location
  ycshade, transpose(envel_map), corr_map_tvector, isat_location
  
  stop

;  ycplot, 
;  ycshade, transpose(corr_map), corr_map_tvector, rot_degree
;  ycshade, transpose(envel_map), corr_map_tvector, rot_degree
end