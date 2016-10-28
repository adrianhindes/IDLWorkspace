; Make Correlation Map
; EX) asdf = corr_long(9286, '2-10', trange = [5.0, 6.0])

function corr_long, shot, ch, trange=trange, subwindow_npts=subwindow_npts, window_npts=window_npts, freq_filter = freq_filter
  default, subwindow_npts, 1024L
  default, window_npts, subwindow_npts*10
  default, freq_filter, [0.1, 0.2]
  time_range = trange[1]-trange[0]
  ;  loop_size = floor(time_range/time_size)

  shot_number = shot
  ch_number = STRSPLIT(ch,'-',/EXTRACT)

  ;;;;;
  ch_num = strarr(16)
  For i=1L, 16 do begin
    if (i GE 10) then begin
      ch_num[i-1] = strjoin([string(ch_number[0],FORMAT='(I01)'), '-', string(i,FORMAT='(I02)')])
    endif else begin
      ch_num[i-1] = strjoin([string(ch_number[0],FORMAT='(I01)'), '-', string(i,FORMAT='(I01)')])
    endelse
  Endfor
  
  channel_data = ptrarr(16)
  
  For i=0L, 16L-1L do begin
    channel_data[i] = ptr_new(bes_read_data(shot_number, ch_num[i], trange=trange))
  Endfor

  window_number = size((*channel_data[0]).data,/n_elements)/window_npts
  ;  tvector = [trange[0]+time_size:trange[1]:time_size]
  corr_map = dblarr(window_number,16)
  corr_length_gauss = dblarr(window_number)
  corr_length_exp = dblarr(window_number)
  time_vector = dblarr(window_number)
 

  reform_channel = dblarr(16,window_npts,window_number)
  For i=0L, 16L-1L do begin
    reform_channel[i,*,*] = reform((*channel_data[i]).data(1:window_number*window_npts),[window_npts,window_number])
  Endfor
  reform_tvector = reform((*channel_data[0]).tvector(1:window_number*window_npts),[window_npts,window_number])

  for i = 0L, window_number-1 do begin
    time_vector[i] = (reform_tvector[0,i]+reform_tvector[window_npts-1,i])/2
  endfor
  ;;;;;
  
  pos_data = bes_read_position(shot_number)
  corr_position = dblarr(16)
  for i = 0L, 15L do begin
    corr_position[i] = sqrt((pos_data.data[ch_number[0]-1,i,0]-pos_data.data[ch_number[0]-1,ch_number[1]-1,0])^2 + (pos_data.data[ch_number[0]-1,i,1]-pos_data.data[ch_number[0]-1,ch_number[1]-1,1])^2)
  endfor
  
  
  
  xcorr = ptrarr(16)

  corr_map = dblarr(window_number,16)
  corr_length_gauss = dblarr(window_number)
  corr_length_exp = dblarr(window_number)
  for i = 0L, window_number-1 do begin
    print, window_number, ':', i
    ch_array = dblarr(16,window_npts)
    for j = 0L, 16-1 do begin
      ch_array[j,*] = reform_channel[j,*,i]
    endfor
    
    corr_value = dblarr(16)
    corr_value_std = dblarr(16)
    corr_value_en = dblarr(16)
    corr_value_en_std = dblarr(16)
    
    for j = 0L, 15L do begin
      xcorr[j] = ptr_new(jw_bes_xcorr(shot_number,ch,ch_num[j],ch1_array=ch_array[ch_number[1]-1,*],ch2_array=ch_array[j,*],freq_filter=freq_filter,subwindow_npts=subwindow_npts))

      corr_value[j] = (*xcorr[j]).corr_value[0]
      corr_value_std[j] = (*xcorr[j]).corr_std[0] ;/sqrt((*xcorr[i,j]).subwindow_number)
      corr_value_en[j] = (*xcorr[j]).corr_value[1]
      corr_value_en_std[j] = (*xcorr[j]).corr_std[1] ;/sqrt((*xcorr[i,j]).subwindow_number)
    endfor
    
    subwin_number = (*xcorr[0]).subwindow_number
    expr = 'p[1]*exp(-x^2/2/p[0]^2)'
    start = [1.0, 0.5]
    rerr = corr_value_std/sqrt(subwin_number)
    result= mpfitexpr(expr,corr_position, corr_value,rerr, start)

    expr2 = 'p[1]*exp(-abs(x)/p[0])'
    start = [1.0, 0.5]
    rerr = corr_value_std/sqrt(subwin_number)
    result2= mpfitexpr(expr2, corr_position, corr_value,rerr, start)
    
;    corr_map[i,*,0] = corr_value
    corr_map[i,*] = corr_value
    corr_length_gauss[i] = abs(result[0])
    corr_length_exp[i] = abs(result2[0])
  endfor
  
  xvector = corr_position
  title = '#' + STRING(shot_number, format='(i0)')
  xtitle = 'Time [sec]'
  ytitle = 'Distance [cm]'
;  ycshade, corr_map, time_vector, xvector, xtitle = xtitle, ytitle = ytitle, title = title, ztitle = 'Corr Value'
  ycshade, corr_map

  ycplot, time_vector, corr_length_gauss, xtitle='Time [sec]', ytitle='Correlation Length [cm]'
  ycplot, time_vector, corr_length_exp, xtitle='Time [sec]', ytitle='Correlation Length [cm]'

  SAVE, /VARIABLES, FILENAME =  strjoin(['/home/ijwkim/IDL/BES_data_analysis/long_corr_shot', string(shot_number,FORMAT='(I05)'), '.sav'])

  result = CREATE_STRUCT('tvector', time_vector, 'xvector', xvector, 'corr_map',corr_map,'corr_length_gauss',corr_length_gauss,'corr_length_exp',corr_length_exp)
  return, result
end