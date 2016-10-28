pro probe_spectrum
  trange = [0.06, 0.08]
;  frng=[20e3,40e3]
;  shot_number= 86418
;  shot_number = 82766
;  shot_number = 88476
;  shot_number = 82781
;  shot_number = 82834
;  shot_number = 86415
;  shot_number = 88533
;  shot_number = 86428
;  shot_number = 87837
;  shot_number = 82834
;  shot_number = 82793
;  shot_number = 87846
;  shot_number = 87776
  shot_number = 87770
;  sh = [87842, 87846, 87860, 87884]
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'vplasma',y=y2,tw=trange)
  c = getpar(shot_number,'mirnov',y=y3,tw=trange)
  
  subwindow_npts = 1024
    
;  ref = select_time(y1.t,y1.v,trange)
;  other = select_time(y2.t,y2.v,trange)
  
;  print, n_elements(ref.tvector)
;  print, n_elements(other.yvector)
  
;  dt = ref.tv[1]-ref.tv[0]
;  fs = 1.0/dt
;  df = 1.0/(n_elements(ref.tv)*dt)
;  freq_vector = (dindgen(fs/df)-floor(fs/df/2))*df
;
;  high_pass = frng[0]/(fs/2)
;  low_pass = frng[1]/(fs/2)
;  
;  ref_y_reform = JW_BANDPASS(ref.yv, high_pass, low_pass , BUTTERWORTH=20.0)
;  other_y_reform = JW_BANDPASS(other.yv, high_pass, low_pass , BUTTERWORTH=20.0)
  
;  a = jw_spectrum(ref.tvector, ref.yvector, other.yvector, /power_plot)
  ycplot, y1.t, y1.v;, out_base_id=oid
  ycplot, y2.t, y2.v;, oplot_id = oid
;  c = jw_spectrum(y1.t, y1.v, y2.v, trange,/coherency_plot,subwindow_npts = 2048)

;  freq_filter = [0.0, 500.0e3]
  
  g = jw_spectrogram(y1.t, y1.v, y1.v, /power_plot,num_subwindow_avg = 20)
  g = jw_spectrogram(y2.t, y2.v, y2.v, /power_plot,num_subwindow_avg = 20)
  g = jw_spectrogram(y1.t, y1.v, y2.v, /power_plot,num_subwindow_avg = 20)
  
  stop


  d = jw_spectrum(y1.t, y2.v, y2.v, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  e = jw_spectrum(y1.t, y1.v, y1.v, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts)
  f = jw_spectrum(y1.t, y1.v, y2.v, trange,/coherency_plot,subwindow_npts = subwindow_npts)
  f = jw_spectrum(y1.t, y1.v, y1.v, trange,/power_plot,/ylog,subwindow_npts = subwindow_npts,/envelope1,/envelope2,envelope_freq = [50.0e3, 120.0e3])
  f = jw_spectrum(y1.t, y1.v, y2.v, trange,/coherency_plot,/phase_plot,subwindow_npts = subwindow_npts,/envelope1,envelope_freq = [50.0e3, 120.0e3])
;  e = jw_spectrum(y1.t, y1.v, y2.v, trange,/phase_plot,subwindow_npts = 256)
  
;  stop
  
;  ycplot, phs_jump(e.phase(where(e.freq gt 0)))
  
;  f = jw_spectrogram(y1.t, y1.v, y2.v, /power_plot,/phase_plot,num_subwindow_avg = 20)

  
;  g = phase_align(e.freq, e.phase)
  
;  ycplot, g.freq, g.phase, out_base_id = oid
;  ycplot, g.freq, g.phase_smooth, oplot_id = oid
  
;  ycplot, e.freq[where(e.freq ge 0)], e.phase[where(e.freq ge 0)]
;  
;  pos_freq = e.freq[where(e.freq ge 0)]
;  
;  temp_phase01 = e.phase[where(e.freq ge 0 and e.freq lt 50.0*10^3)]
;  temp_phase02 = e.phase[where(e.freq ge 50.0*10^3 and e.freq lt 150.0*10^3)]
;  for i = 0L, n_elements(temp_phase02)-1 do begin
;    if (temp_phase02[i] lt 0.0) then begin
;      temp_phase02[i] = temp_phase02[i]+!PI*2.0
;    endif
;  endfor
;  temp_phase03 = e.phase[where(e.freq ge 150.0*10^3)]+!PI*2
;  
;  phase_jump = [temp_phase01, temp_phase02, temp_phase03]
;  
;  ycplot, e.freq[where(e.freq ge 0)], phase_jump, out_base_id = oid
;  
;  phase_jump_smooth = smooth(phase_jump,20)
;  
;  ycplot, e.freq[where(e.freq ge 0)], phase_jump_smooth, oplot_id = oid
;  
;  pick_up_size = 0.3
;  print, phase_jump_smooth(where(pos_freq ge (100.0-pick_up_size)*10^3 and pos_freq lt (100.0+pick_up_size)*10^3))
  
  
  
;  print, min(freq_vector), max(freq_vector)
  
;  ycplot, ref.tv, ref.yv
;  ycplot, ref.tv, ref_y_reform
  
end
