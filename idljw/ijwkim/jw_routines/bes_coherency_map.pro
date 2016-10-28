function bes_coherency_map, shot, ch1, ch2, trange=trange, subwindow_npts = subwindow_npts, window_npts=window_npts
  default, subwindow_npts, 256L
  default, window_npts, subwindow_npts*20
  
  shot_number = shot

  channel1 = bes_read_data(shot_number, ch1, trange=trange)
  channel2 = bes_read_data(shot_number, ch2, trange=trange)
  
;  avg_number = floor(float(window_npts)/float(subwindow_npts))
  
  window_number = size(channel1.data,/n_elements)/window_npts
  
  reform_channel1 = reform(channel1.data(1:window_number*window_npts),[window_npts,window_number])
  reform_channel2 = reform(channel2.data(1:window_number*window_npts),[window_npts,window_number])
  reform_tvector = reform(channel1.tvector(1:window_number*window_npts),[window_npts,window_number])
  coh_map = dblarr(window_number,subwindow_npts)
  for i = 0L, window_number-1 do begin
    coh_1time = bes_coherency(shot_number,ch1,ch2,ch1_array = reform_channel1(*,i), ch2_array = reform_channel2(*,i),subwindow_npts=subwindow_npts)
    coh_map[i,*] = coh_1time.coherence
    freq = coh_1time.freq
  endfor
  time_vector = dblarr(window_number)
  for i = 0L, window_number-1 do begin
    time_vector[i] = (reform_tvector[0,i]+reform_tvector[window_npts-1,i])/2
  endfor
  
  title = '#' + STRING(shot_number, format='(i0)')
  xtitle = 'Time [sec]'
  ytitle = 'Freq [Hz]'
  ycshade, coh_map, time_vector, freq, $
    xtitle = xtitle, ytitle = ytitle, title = title, ztitle = 'Coherency'
  return, 1
end
  
