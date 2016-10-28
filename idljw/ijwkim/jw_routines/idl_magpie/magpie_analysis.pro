pro magpie_analysis

  a = phys_quantity(2100)

  print, a.location
  
  trange = [0.05, 0.25]
  subwindow_npts = 2048
  b = jw_spectrum(a.tvector, a.dens, a.dens, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  b = jw_spectrum(a.tvector, a.temp, a.temp, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  b = jw_spectrum(a.tvector, a.vplasma, a.vplasma, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)

  b = jw_spectrum(a.tvector, a.isat, a.isat, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
    b = jw_spectrum(a.tvector, a.vfloat, a.vfloat, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  b = jw_spectrum(a.tvector, a.isat_rot, a.isat_rot, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  b = jw_spectrum(a.tvector, a.vfloat_rot, a.vfloat_rot, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  
  a2 = magpie_data('probe_isat',1060)
  trange  = [0.31, 0.33]
  stop
  b = jw_spectrum(a2.tvector, a2.vvector, a2.vvector, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
;  b = jw_spectrum(a.tvector, a.dens, a.dens, trange,/power_plot,/ylog,/xlog,subwindow_npts=subwindow_npts)
;  
;;  c = jw_spectrogram(a.tvector,a.dens,a.temp,/power_plot,num_subwindow_avg = 4)
;;  d = jw_spectrogram(a.tvector,a.dens,a.vplasma,/power_plot,/phase_plot,num_subwindow_avg = 4)
;  b = jw_spectrum(a.tvector, a.dens, a.vplasma, trange,/phase_plot,/coherency_plot,subwindow_npts = subwindow_npts)
;;  d = jw_spectrogram(a.tvector,a.vplasma,a.vplasma,/power_plot,num_subwindow_avg = 4)
;;  e = jw_spectrogram(a.tvector,a.dens,a.vfloat,/power_plot,/phase_plot,num_subwindow_avg = 4)
;  b = jw_spectrum(a.tvector, a.dens, a.vfloat, trange,/phase_plot,/coherency_plot,subwindow_npts = subwindow_npts)


end