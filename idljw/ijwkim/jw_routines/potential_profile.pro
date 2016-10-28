function potential_profile, subwindow_npts = subwindow_npts, window_npts = window_npts, distance = distance, trange = trange, mode = mode

  default, subwindow_npts, 128L
  default, window_npts, subwindow_npts*8
;  default, distance, 120.0 ;[mm]
  default, trange, [0.02, 0.04] ;[sec]
  default, mode, 'vplasma'
  
;  86418, 86427, 86428, 86429
  
  start_shot = 86410
  end_shot = 86415
  first_location = 230.0
  each_distance = 10.0

;;;;;;;;;;;;;;;;;;;;;;;;;;
  a = getpar(start_shot,mode,y=y1,tw=trange)
  b = select_time(y1.t,y1.v,trange)
  
  window_number = floor(size(b.tvector,/n_elements)/window_npts)
  time_vector = dblarr(window_number)
  s1 = dblarr(end_shot-start_shot+1,2,window_npts,window_number)
  
  for i = 0, 5L do begin
    shot_number = start_shot+i
    a = getpar(shot_number,mode,y=y1,tw=trange)

    b = select_time(y1.t,y1.v,trange)
    s1[i,0,*,*] = reform(b.yvector(1:window_number*window_npts),[window_npts,window_number])
    s1[i,1,*,*] = reform(b.tvector(1:window_number*window_npts),[window_npts,window_number])
  endfor
  
  for i = 0L, window_number-1 do begin
    time_vector[i] = (s1[0,1,0,i]+s1[0,1,window_npts-1,i])/2
  endfor
  
;  potential_map = dblarr(n_elements((*xcorr[0]).tvector),6)
  
  location = dblarr(end_shot-start_shot+1)
  for i = 0, 5L do begin
;    potential_map[*,i] = (*xcorr[i]).yvector
    location[i] = first_location-each_distance*i
  endfor
;  a = dindgen(n_elements((*xcorr[0]).v))
;  ycplot, (*xcorr[0]).tvector, (*xcorr[0]).yvector
  
  mean_value = dblarr(end_shot-start_shot+1,window_number)
  for i = 0, 5L do begin
    for j = 0, window_number-1 do begin
      mean_value[i,j] = mean(s1[i,0,*,j])
    endfor
  endfor

  ycplot, location ,mean_value[*,3]
  
  eb_position = dblarr(end_shot-start_shot,window_number)
  eb_velocity = dblarr(end_shot-start_shot,window_number)
  
  for i =0,4L do begin
    eb_position[i,*] = location[i]+(location[i]-location[i+1])/2
    e_field = (mean_value[i,*]-mean_value[i+1,*])/(10.0/1000.0)
    eb_velocity[i,*] = e_field/0.5
  endfor
  
;;;;;;;;;;  
  

;  ycshade, potential_map
  
  result = CREATE_STRUCT('position', eb_position, 'velocity', eb_velocity, 'time_vector', time_vector)
  return, result
end