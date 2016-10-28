pro velocity_profile
  
  position = dblarr(4)
  position[0] = 210
  position[1] = 220
  position[2] = 230
  position[3] = 240
  
  trange = [0.07, 0.09]
  frng=[100e3,200e3]
;  mode = 'vfloat'
  mode = 'vplasma'
  
  ;  86418, 86427, 86428, 86429
  
  eb = potential_profile(mode = mode,trange=trange)
  
  cctd_result = ptrarr(4)
  spectrum_result = ptrarr(4)
  
  shot_number = 86418
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange)
  cctd_result[0] = ptr_new(cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = 120.0))
  d1 = select_time(y1.t,y1.v,trange)
  d2 = select_time(y2.t,y2.v,trange)
  spectrum_result[0] = ptr_new(jw_spectrogram(d1.tvector, d1.yvector, d2.yvector, subwindow_npts = 512, num_subwindow_avg = 4))
  
  
  shot_number = 86427
;  trange = [0.02, 0.04]
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange)
  cctd_result[1] = ptr_new(cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = 120.0))
  d1 = select_time(y1.t,y1.v,trange)
  d2 = select_time(y2.t,y2.v,trange)
  spectrum_result[1] = ptr_new(jw_spectrogram(d1.tvector, d1.yvector, d2.yvector,subwindow_npts = 512,num_subwindow_avg = 4))
  
  shot_number = 86428
;  trange = [0.02, 0.04]
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange)
  cctd_result[2] = ptr_new(cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = 120.0))
  d1 = select_time(y1.t,y1.v,trange)
  d2 = select_time(y2.t,y2.v,trange)
  spectrum_result[2] = ptr_new(jw_spectrogram(d1.tvector, d1.yvector, d2.yvector,subwindow_npts = 512,num_subwindow_avg = 4))
  
  shot_number = 86429
;  trange = [0.02, 0.04]
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange)
  cctd_result[3] = ptr_new(cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = 120.0))
  d1 = select_time(y1.t,y1.v,trange)
  d2 = select_time(y2.t,y2.v,trange)
  spectrum_result[3] = ptr_new(jw_spectrogram(d1.tvector, d1.yvector, d2.yvector,subwindow_npts = 512,num_subwindow_avg = 4))
  
  t = 0
  cctd_vel = dblarr(4)
  for i = 0L, 4-1 do begin
     cctd_vel[i] = (*cctd_result[i]).velocity[t]
  endfor
  
  cctd_corr = dblarr(4)
  for i = 0L, 4-1 do begin
     cctd_corr[i] = (*cctd_result[i]).max_envel[t]
  endfor
  
  phase_vel = dblarr(4)
  select_freq = 100.0*10.0^3.0 ;[hz]
  distance = 120.0*0.001 ;[m]
  for i = 0L, 4-1 do begin
     get_phase = phase_align((*spectrum_result[i]).freq, (*spectrum_result[i]).phase[t,*])
     phase_vel[i] = 2*!pi*select_freq/get_phase.phase_value*distance
  endfor

  ycplot, position, cctd_vel, title = strjoin([string((*cctd_result[0]).tvector[t],format='(d0.6)') , ' sec']), out_base_id = oid
  
  ycplot, position, phase_vel, oplot_id = oid
  
  ycplot, eb.position[*,t], eb.velocity[*,t], oplot_id = oid; , title = strjoin([string(eb.time_vector[t],format='(d0.6)') , ' sec'])
  
  ycplot, position, cctd_corr

end