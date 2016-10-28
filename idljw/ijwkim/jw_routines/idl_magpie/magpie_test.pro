pro magpie_test

shot_number = 30
d1 = magpie_data('probe_isat', shot_number)
d2 = magpie_data('probe_float', shot_number)
d3 = magpie_data('single_pmt', shot_number)

ycplot, d1.tvector, d1.vvector


trange = [0.10, 0.9]
subwindow_npts = 4096
a = jw_spectrum(d1.tvector, d1.vvector, d1.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
b = jw_spectrum(d2.tvector, d2.vvector, d2.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
c = jw_spectrum(d3.tvector, d3.vvector, d3.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
c = jw_spectrum(d1.tvector, d1.vvector, d2.vvector, trange,/power_plot,/phase_plot,/coherency_plot,subwindow_npts = subwindow_npts)
d = jw_spectrogram(d1.tvector, d1.vvector, d2.vvector,/power_plot,/phase_plot,subwindow_npts = 512,num_subwindow_avg = 80)

;e = corr_time(d1.tvector, d1.vvector, d2.vvector)

end