pro magpie_corr_profile
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;isat = ptrarr(points_num)
;isat_rot = ptrarr(points_num)
;for i = 0, points_num-1 do begin
;  ;;527
;  shot_number = i*3+2170
;  isat[i] = ptr_new(magpie_data('probe_isat',shot_number))
;  isat_rot[i] = ptr_new(magpie_data('probe_isat_rot',shot_number))
;  print, i
;endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

points_num = 36
isat = ptrarr(points_num)
isat_rot = ptrarr(points_num)
for i = 0, points_num-1 do begin
  ;;527
  shot_number = i*3+2170
  isat[i] = ptr_new(magpie_data('probe_isat',shot_number))
  isat_rot[i] = ptr_new(magpie_data('probe_isat_rot',shot_number))
  print, i
endfor

isat_mean = dblarr(points_num)
isat_rot_mean = dblarr(points_num)
isat_std = dblarr(points_num)
isat_rot_std = dblarr(points_num)
isat_location = dblarr(points_num)

freq_filter = [15e3,25e3]
subwindow_npts = 1024L
window_npts = 10L*subwindow_npts

trange = [0.01, 0.29]
isat_cut = select_time((*isat[0]).tvector,(*isat[0]).vvector,trange)
window_number = floor(size(isat_cut.tvector,/n_elements)/window_npts)

corr_map = dblarr(points_num, window_number)
envel_map = dblarr(points_num, window_number)
corr_map_tvector = dblarr(window_number)
for i = 0, 36-1 do begin
  isat_cut = select_time((*isat[i]).tvector,(*isat[i]).vvector,trange)
  isat_rot_cut = select_time((*isat_rot[i]).tvector,(*isat_rot[i]).vvector,trange)
  isat_mean[i] = mean(isat_cut.yvector)
  isat_std[i] = variance(isat_cut.yvector)
  isat_rot_mean[i] = mean(isat_rot_cut.yvector)
  isat_rot_std[i] = variance(isat_rot_cut.yvector)
  isat_location[i] = (*isat[i]).location
  corr_tmp = corr_time(isat_cut.tvector,isat_cut.yvector,isat_rot_cut.yvector,freq_filter = freq_filter,window_npts = window_npts, subwindow_npts=subwindow_npts, fast = 5)
  
  corr_map[i,*] = corr_tmp.xcorr_mean
  envel_map[i,*] = corr_tmp.envel_mean
  print, i
endfor
corr_map_tvector = corr_tmp.tvector

isat_location = findgen(36)*10

ycplot, isat_location, isat_mean, error=isat_std, out_base_id = oid
ycplot, isat_location, isat_rot_mean, error = isat_rot_std, oplot_id = oid
ycplot, isat_location, isat_std, out_base_id = oid
ycplot, isat_location, isat_rot_std, oplot_id = oid

ycshade, -transpose(corr_map), corr_map_tvector, isat_location
ycshade, transpose(envel_map), corr_map_tvector, isat_location
;e = corr_time(d1.tvector, d1.vvector, d2.vvector)

;save, /variables, FILENAME = 'corr_map_mod_on_01.sav'

end