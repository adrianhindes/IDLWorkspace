; Make Correlation Map
; EX) asdf = corr_ex(9286, 1, trange = [5.0, 6.0])

function corr_ex, shot, ch, trange=trange, subwindow_npts=subwindow_npts, window_npts=window_npts, overwindow=overwindow
  default, subwindow_npts, 512L
  default, window_npts, subwindow_npts*10
  default, overwindow, 2
  time_range = trange[1]-trange[0]
;  loop_size = floor(time_range/time_size)
  
  shot_number = shot
  ch_number = ch
 
  ;;;;;
  ch_num = strarr(4)
  For i=0L, 4-1 do begin
      if (ch GE 10) then begin
        ch_num[i] = strjoin([string(i+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I02)')])
      endif else begin
        ch_num[i] = strjoin([string(i+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I01)')])
      endelse
  Endfor
  
  channel1 = bes_read_data(shot_number, ch_num[0], trange=trange)
  channel2 = bes_read_data(shot_number, ch_num[1], trange=trange)
  channel3 = bes_read_data(shot_number, ch_num[2], trange=trange)
  channel4 = bes_read_data(shot_number, ch_num[3], trange=trange)
;  avg_number = floor(float(window_npts)/float(subwindow_npts))

  window_number = size(channel1.data,/n_elements)/window_npts
  ;  tvector = [trange[0]+time_size:trange[1]:time_size]
  corr_map = dblarr(window_number,7)
  corr_length_gauss = dblarr(window_number)
  corr_length_exp = dblarr(window_number)
  time_vector = dblarr(window_number)

  reform_channel = dblarr(4,window_npts,window_number)
  reform_channel[0,*,*] = reform(channel1.data(1:window_number*window_npts),[window_npts,window_number])
  reform_channel[1,*,*] = reform(channel2.data(1:window_number*window_npts),[window_npts,window_number])
  reform_channel[2,*,*] = reform(channel3.data(1:window_number*window_npts),[window_npts,window_number])
  reform_channel[3,*,*] = reform(channel4.data(1:window_number*window_npts),[window_npts,window_number])
  reform_tvector = reform(channel1.tvector(1:window_number*window_npts),[window_npts,window_number])
  
;  for i = 0L, window_number-1 do begin
;    coh_1time = bes_coherency(9127,ch1,ch2,ch1_array = reform_channel1(*,i), ch2_array = reform_channel2(*,i),subwindow_npts=subwindow_npts)
;    coh_map[i,*] = coh_1time.coherence
;    freq = coh_1time.freq
;  endfor

  for i = 0L, window_number-1 do begin
    time_vector[i] = (reform_tvector[0,i]+reform_tvector[window_npts-1,i])/2
  endfor
  ;;;;;
  for i = 0L, window_number-1 do begin
    print, window_number, ':', i
    array_sum = dblarr(4,window_npts)
    for j = 0L, 4-1 do begin
      array_sum[j,*] = reform_channel[j,*,i]
    endfor
    corr_step = corr_measure(shot_number,ch_number,ch_array = array_sum,subwindow_npts=subwindow_npts)
    corr_map[i,*] = corr_step.corr_value
    corr_length_gauss[i] = corr_step.corr_length_gauss
    corr_length_exp[i] = corr_step.corr_length_exp
  endfor
;  for i = 0L,loop_size-1 do begin
;    print, loop_size, ':', i
;    trange01 = trange[0]+i*time_size
;    trange02 = trange[0]+(i+1)*time_size
;    corr_step = corr_measure(shot_number,ch_number,trange=[trange01,trange02])
;    corr_map[i,*] = corr_step.corr_value
;    corr_length_gauss[i] = corr_step.corr_length_gauss
;    corr_length_exp[i] = corr_step.corr_length_exp
;  endfor
  
;  stop
  xvector = corr_step.position
  title = '#' + STRING(shot_number, format='(i0)')
  xtitle = 'Time [sec]'
  ytitle = 'Distance [cm]'
  ycshade, corr_map, time_vector, xvector, $
    xtitle = xtitle, ytitle = ytitle, title = title, ztitle = 'Corr Value'
  
  ycplot, time_vector, corr_length_gauss, xtitle='Time [sec]', ytitle='Correlation Length [cm]'
  ycplot, time_vector, corr_length_exp, xtitle='Time [sec]', ytitle='Correlation Length [cm]'
  
  SAVE, /VARIABLES, FILENAME =  strjoin(['/home/ijwkim/IDL/BES_data_analysis/pol_corr_shot', string(shot_number,FORMAT='(I05)'), '.sav'])

  result = CREATE_STRUCT('tvector', time_vector, 'xvector', xvector, 'corr_map',corr_map,'corr_length_gauss',corr_length_gauss,'corr_length_exp',corr_length_exp)
  return, result
end