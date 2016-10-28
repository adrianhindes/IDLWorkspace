pro magpie_profile
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
points_num = 41

isat = ptrarr(points_num)
pmt = ptrarr(points_num)
for i = 0, points_num-1 do begin
  shot_number = i*2+12
  isat[i] = ptr_new(magpie_data('probe_isat_rot',shot_number))
  pmt[i] = ptr_new(magpie_data('probe_vfloat_rot',shot_number))
  print, i
endfor

isat_mean = dblarr(points_num)
float_mean = dblarr(points_num)
pmt_mean = dblarr(points_num)
isat_std = dblarr(points_num)
float_std = dblarr(points_num)
pmt_std = dblarr(points_num)
isat_location = dblarr(points_num)

freq_filter = [10e3,50e3]
subwindow_npts = 2048L
window_npts = 4L*subwindow_npts

trange = [0.1, 0.9]
;isat_cut = select_time((*isat[0]).tvector,(*isat[0]).vvector,trange)
;window_number = floor(size(isat_cut.tvector,/n_elements)/window_npts)

for i = 0, points_num-1 do begin
  isat_cut = select_time((*isat[i]).tvector,(*isat[i]).vvector,trange)
  pmt_cut = select_time((*pmt[i]).tvector,(*pmt[i]).vvector,trange)
  isat_mean[i] = mean(isat_cut.yvector)
  isat_std[i] = variance(isat_cut.yvector)
  float_mean[i] = mean(pmt_cut.yvector)
  float_std[i] = variance(pmt_cut.yvector)
  pmt_mean[i] = mean(pmt_cut.yvector)
  pmt_std[i] = variance(pmt_cut.yvector)
  isat_location[i] = (*isat[i]).location

  print, i
endfor

ycplot, isat_location, isat_mean, error=isat_std, out_base_id = oid1
;ycplot, isat_location, pmt_mean, error = pmt_std, oplot_id = oid
ycplot, isat_location, float_mean, error = float_std, out_base_id = oid2
ycplot, isat_location, isat_std, out_base_id = oid3 
;ycplot, isat_location, pmt_std, oplot_id = oid

;isat = ptrarr(points_num)
;pmt = ptrarr(points_num)
for i = 0, points_num-1 do begin
  shot_number = i*2+95
  isat[i] = ptr_new(magpie_data('probe_isat',shot_number))
  pmt[i] = ptr_new(magpie_data('single_pmt',shot_number))
  print, i
endfor

isat_mean = dblarr(points_num)
float_mean = dblarr(points_num)
pmt_mean = dblarr(points_num)
isat_std = dblarr(points_num)
float_std = dblarr(points_num)
pmt_std = dblarr(points_num)
isat_location = dblarr(points_num)

freq_filter = [10e3,50e3]
subwindow_npts = 2048L
window_npts = 4L*subwindow_npts

trange = [0.1, 0.9]
;isat_cut = select_time((*isat[0]).tvector,(*isat[0]).vvector,trange)
;window_number = floor(size(isat_cut.tvector,/n_elements)/window_npts)

stop
for i = 0, points_num-1 do begin
  isat_cut = select_time((*isat[i]).tvector,(*isat[i]).vvector,trange)
  pmt_cut = select_time((*pmt[i]).tvector,(*pmt[i]).vvector,trange)
  isat_mean[i] = mean(isat_cut.yvector)
  isat_std[i] = variance(isat_cut.yvector)
  float_mean[i] = mean(pmt_cut.yvector)
  float_std[i] = variance(pmt_cut.yvector)
  pmt_mean[i] = mean(pmt_cut.yvector)
  pmt_std[i] = variance(pmt_cut.yvector)
  isat_location[i] = (*isat[i]).location

  print, i
endfor

ycplot, isat_location, isat_mean, error=isat_std, oplot_id = oid1
;ycplot, isat_location, pmt_mean, error = pmt_std, oplot_id = oid
ycplot, isat_location, float_mean, error = float_std, oplot_id = oid2
ycplot, isat_location, isat_std, oplot_id = oid3 

end