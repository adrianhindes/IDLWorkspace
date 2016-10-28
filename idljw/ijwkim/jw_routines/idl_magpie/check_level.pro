pro check_level
   set_mag = magpie_data('probe_isat',310)
   set_volt = magpie_data('probe_isat',50)
   print, set_mag.location
   print, set_volt.location
   
   set_mag_background = select_time(set_mag.tvector,set_mag.vvector,[0.102,0.108])
   
   set_mag_mean = mean(set_mag_background.yvector)
   
   ycplot, set_mag.tvector, set_mag.vvector
   ycplot, set_mag.tvector, set_mag_mean-set_mag.vvector*1
   ycplot, set_volt.tvector, set_volt.vvector/50.
   
   stop
   spec_1 = jw_spectrum(set_mag.tvector,set_mag_mean-set_mag.vvector*1.,set_mag_mean-set_mag.vvector*1.,[0.01,0.09],/power_plot,subwindow_npts=1024,/ylog)
   spec_2 = jw_spectrum(set_volt.tvector,set_volt.vvector/50.,set_volt.vvector/50.,[0.01,0.09],/power_plot,subwindow_npts=1024,/ylog)
   
;   b = select_time(a.tvector,a.vvector,[0.01,0.09])
end