pro magpie_single_pmt
shot_number = 55
d1 = magpie_data('probe_isat', shot_number)
d2 = magpie_data('probe_float', shot_number)
d3 = magpie_data('single_pmt', shot_number)

ycplot, d1.tvector, d1.vvector

trange = [0.00, 1.0]
subwindow_npts = 4096
a = jw_spectrum(d1.tvector, d1.vvector, d1.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
b = jw_spectrum(d2.tvector, d2.vvector, d2.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
c = jw_spectrum(d3.tvector, d3.vvector, d3.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
;d = jw_spectrogram(d1.tvector, d1.vvector, d2.vvector, /power_plot,num_subwindow_avg = 20)


isat = ptrarr(41)
pmt = ptrarr(41)
for i = 0, 40 do begin
  shot_number = i*2+95
  isat[i] = ptr_new(magpie_data('probe_isat',shot_number))
  pmt[i] = ptr_new(magpie_data('single_pmt',shot_number))
  print, i
endfor

isat_mean = dblarr(41)
pmt_mean = dblarr(41)
isat_std = dblarr(41)
pmt_std = dblarr(41)
isat_location = dblarr(41)

for i = 0, 40 do begin
  isat_cut = select_time((*isat[i]).tvector,(*isat[i]).vvector,trange)
  pmt_cut = select_time((*pmt[i]).tvector,(*pmt[i]).vvector,trange)
  isat_mean[i] = mean(isat_cut.yvector)
  isat_std[i] = variance(isat_cut.yvector)
  pmt_mean[i] = mean(pmt_cut.yvector)
  pmt_std[i] = variance(pmt_cut.yvector)
  isat_location[i] = (*isat[i]).location
endfor

stop

ycplot, isat_location, isat_mean, error=isat_std, out_base_id = oid
ycplot, isat_location, pmt_mean, error = pmt_std, oplot_id = oid
ycplot, isat_location, isat_std, out_base_id = oid
ycplot, isat_location, pmt_std, oplot_id = oid
;e = corr_time(d1.tvector, d.vvector, d2.vvector)

end