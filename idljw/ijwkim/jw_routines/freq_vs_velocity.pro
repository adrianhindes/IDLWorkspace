pro freq_vs_velocity

  position = dblarr(4)
  position[0] = 210
  position[1] = 220
  position[2] = 230
  position[3] = 240
  
  trange = [0.07, 0.09]
  mode = 'vfloat'

  shot_number = 86427
;  trange = [0.02, 0.04]
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange)
  d1 = select_time(y1.t,y1.v,trange)
  d2 = select_time(y2.t,y2.v,trange)
  
  dt = d1.tvector[1]-d1.tvector[0]
  spectrum_result2 = jw_spectrum(d1.tvector, d1.yvector, d2.yvector, trange, subwindow_npts = 1024)
;  spectrum_result = jw_spectrogram(d1.tvector, d1.yvector, d2.yvector,subwindow_npts = 32,num_subwindow_avg = 256)
  
;  pos_freq = spectrum_result.freq[where(spectrum_result.freq ge 0)]
  fs = 1.0/dt
  df = 1.0/(32*dt)
  freq_vector = (dindgen(fs/df)-floor(fs/df/2))*df
  pos_freq = freq_vector(where(freq_vector ge 0))
  freq_vector = dblarr(n_elements(pos_freq)-1)
  cctd_result = ptrarr(n_elements(pos_freq)-1)
  for i = 0, n_elements(pos_freq)-2 do begin
    print, string(n_elements(pos_freq)-2), ' : ', i
    freq_vector[i] = (pos_freq[i+1]+pos_freq[i])/2
    frng = [pos_freq[i], pos_freq[i+1]]
    
    subwindow_npts = 512
    window_number = floor(n_elements(d1.tvector)/subwindow_npts)
    cctd_result[i] = ptr_new(cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = 120.0,subwindow_npts = subwindow_npts, window_npts = 512*window_number))
  endfor
  
;  time_vector = (*cctd_result[0]).tvector
  
  t = 0
;  freq_velocity = dblarr(n_elements(time_vector),n_elements(pos_freq)-1)
  freq_velocity = dblarr(n_elements(pos_freq)-1)
  for i = 0, n_elements(pos_freq)-2 do begin
    freq_velocity[i] = (*cctd_result[i]).velocity
  endfor
  coherency_spec = spectrum_result2.coherency[where(spectrum_result2.freq ge 0)]
  pos_freq2 = spectrum_result2.freq[where(spectrum_result2.freq ge 0)]
  ycplot, freq_vector, freq_velocity;, out_base_id = oid
  ycplot, pos_freq2, coherency_spec;, oplot_id = oid

end