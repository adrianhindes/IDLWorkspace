pro test_signal
;; 21/03/2016
;  previous = phys_quantity(434,'probe_isat')
  previous = magpie_data('probe_isat',240)
  print, previous.location
  
  trange = [0.01,0.09]
;  spec_dens1 = jw_spectrum(previous.tvector,previous.dens,previous.dens,trange,/power_plot,subwindow_npts=1024,/ylog)
;  spec_isat1 = jw_spectrum(previous.tvector,previous.isat,previous.isat,trange,/power_plot,subwindow_npts=1024,/ylog)
  spec_isat1 = jw_spectrum(previous.tvector,previous.vvector/50,previous.vvector/50,trange,/power_plot,subwindow_npts=1024,/ylog)
  ycplot, previous.tvector, previous.vvector
  
  
  trange = [0.01,0.09]

;  now = phys_quantity(1890, discharge_time=0.1)
;  print, now.location
;  
;  spec_dens2 = jw_spectrum(now.tvector,now.dens,now.dens,trange,/power_plot,subwindow_npts=1024,/ylog)
;  spec_isat2 = jw_spectrum(now.tvector,now.isat,now.isat,trange,/power_plot,subwindow_npts=1024,/ylog)
;  spec_isat_rot2 = jw_spectrum(now.tvector,now.isat_rot,now.isat_rot,trange,/power_plot,subwindow_npts=1024,/ylog)
;
;  
;  now2 = phys_quantity(1891, discharge_time=0.1)
;  spec_isat3 = jw_spectrum(now2.tvector,now2.isat,now2.isat,trange,/power_plot,subwindow_npts=1024,/ylog)
;;  spec_isat3_2 = jw_spectrum(now2.tvector,now2.vfloat_rot/50.*5./1003.*3.,now2.vfloat_rot/50.*5./1003.*3.,trange,/power_plot,subwindow_npts=1024,/ylog)
;  spec_isat_rot3 = jw_spectrum(now2.tvector,now2.isat_rot,now2.isat_rot,trange,/power_plot,subwindow_npts=1024,/ylog)
;  
  now3 = phys_quantity(1050, discharge_time=0.1)
  print, now3.location
  spec_isat4 = jw_spectrum(now3.tvector,now3.isat,now3.isat,trange,/power_plot,subwindow_npts=1024,/ylog)
;  spec_isat3_2 = jw_spectrum(now2.tvector,now2.vfloat_rot/50.*5./1003.*3.,now2.vfloat_rot/50.*5./1003.*3.,trange,/power_plot,subwindow_npts=1024,/ylog)
  spec_isat_rot4 = jw_spectrum(now3.tvector,now3.isat_rot,now3.isat_rot,trange,/power_plot,subwindow_npts=1024,/ylog)
  
  spec_te = jw_spectrum(now3.tvector,now3.temp,now3.temp,trange,/power_plot,subwindow_npts=1024,/ylog)
  spec_te = jw_spectrum(now3.tvector,now3.vplus,now3.vplus,trange,/power_plot,subwindow_npts=1024,/ylog)
  
;   ycplot, spec_isat2.freq ,spec_isat2.power, out_base_id = oid, /ylog
;;  ycplot, spec_isat_rot2.freq ,spec_isat_rot2.power, oplot_id = oid, /ylog
;   ycplot, spec_isat3.freq ,spec_isat3.power, oplot_id = oid, /ylog
   ycplot, spec_isat4.freq ,spec_isat4.power, out_base_id = oid, /ylog
   ycplot, spec_isat4.freq ,spec_isat_rot4.power, oplot_id = oid, /ylog
   
;  ycplot, spec_isat_rot3.freq ,spec_isat3_2.power, oplot_id = oid, /ylog
;  ycplot, spec_isat_rot3.freq ,spec_isat_rot3.power, oplot_id = oid, /ylog
;  ycplot, spec_isat1.freq ,spec_isat1.power, oplot_id = oid, /ylog

  spec5 = jw_spectrum(now3.tvector,now3.isat,now3.isat_rot,trange,/phase_plot,/coherency_plot,subwindow_npts=1024)
end