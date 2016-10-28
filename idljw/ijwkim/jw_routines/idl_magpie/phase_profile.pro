pro phase_profile
  points_num = 36

  rotating_probe = ptrarr(points_num)
  
;  degree = dblarr(36)
;  rot_radius = dblarr(36)
;  rot_degree = dblarr(36)
;  rot_x = dblarr(36)
;  rot_y = dblarr(36)
  radius = 2.85
  
  shot_number = 1059
  probe = phys_quantity(shot_number)
  degree = 30
  rot_x = radius*cos((180.-degree)*!pi/180.)
  rot_y = radius*sin((180.-degree)*!pi/180.)+3
  
  rot_radius = sqrt(rot_x^2.0+rot_y^2.0)
  rot_degree = atan(rot_x/rot_y)+!pi/2.
  
  print, probe.location-2.0
  stop

  freq_filter = [10e3,30e3]
  subwindow_npts = 2048L
  window_npts = 10L*subwindow_npts
  
  trange = [0.01, 0.29]
  
  b = jw_spectrum(probe.tvector, probe.isat, probe.isat_rot, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  c = jw_spectrum(probe.tvector, probe.isat, probe.isat_rot, trange,/phase_plot,/coherency_plot,subwindow_npts = subwindow_npts)
  d = jw_spectrum(probe.tvector, probe.vfloat, probe.vfloat_rot, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  e = jw_spectrum(probe.tvector, probe.vfloat, probe.vfloat_rot, trange,/phase_plot,/coherency_plot,subwindow_npts = subwindow_npts)



end