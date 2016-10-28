
function jw_corr_measure, tvector,ch1_array = ch1_array,ch2_array=ch2_array,$
 trange=trange, freq_filter = freq_filter, subwindow_npts = subwindow_npts,window_npts=window_npts, plot=plot
 
  default, subwindow_npts, 1024L
  default, freq_filter, [0, 500e3]
  default, window_npts, subwindow_npts*5
  
  dt = tvector[1]-tvector[0]
  fs = 1.0/dt
  df = 1.0/(n_elements(tvector)*dt)
  freq_vector = (dindgen(fs/df)-floor(fs/df/2))*df

  high_pass = freq_filter[0]/(fs/2)
  low_pass = freq_filter[1]/(fs/2)
  
;  print, high_pass
;  print, low_pass

  s1 = JW_BANDPASS(ch1_array, high_pass, low_pass)
  s2 = JW_BANDPASS(ch2_array, high_pass, low_pass)
  
  window_number = floor(size(tvector,/n_elements)/window_npts)
  ;  tvector = [trange[0]+time_size:trange[1]:time_size]
  corr_value = dblarr(window_number)
  corr_value_std = dblarr(window_number) ;/sqrt((*xcorr[i,j]).subwindow_number)
  corr_value_en = dblarr(window_number)
  corr_value_en_std = dblarr(window_number) ;/sqrt((*xcorr[i,j]).subwindow_number)
  time_vector = dblarr(window_number)

  reform_channel = dblarr(2,window_npts,window_number)
  reform_channel[0,*,*] = reform(s1(1:window_number*window_npts),[window_npts,window_number])
  reform_channel[1,*,*] = reform(s2(1:window_number*window_npts),[window_npts,window_number])
  reform_tvector = reform(tvector(1:window_number*window_npts),[window_npts,window_number])
  
  
  
  for i = 0L, window_number-1 do begin
    time_vector[i] = (reform_tvector[0,i]+reform_tvector[window_npts-1,i])/2
  endfor
  ;;;;;
  for i = 0L, window_number-1 do begin
    print, window_number, ':', i
;    corr_step = corr_measure(shot_number,ch_number,ch_array = array_sum,subwindow_npts=subwindow_npts)
;    corr_map[i,*] = corr_step.corr_value
;    corr_length_gauss[i] = corr_step.corr_length_gauss
;    corr_length_exp[i] = corr_step.corr_length_exp
    
    xcorr = ptr_new(jw_bes_xcorr(ch1_array=reform_channel[0,*,i],ch2_array=reform_channel[1,*,i],freq_filter=freq_filter,subwindow_npts=subwindow_npts))
    corr_value[i] = (*xcorr).corr_value[0]
    corr_value_std[i] = (*xcorr).corr_std[0] ;/sqrt((*xcorr[i,j]).subwindow_number)
    corr_value_en[i] = (*xcorr).corr_value[1]
    corr_value_en_std[i] = (*xcorr).corr_std[1] ;/sqrt((*xcorr[i,j]).subwindow_number)
    subwin_number = (*xcorr).subwindow_number
  endfor
  
  
  result = CREATE_STRUCT('tvector', time_vector, 'corr', corr_value, 'corr_std', corr_value_std, 'corr_en', corr_value_en, 'corr_en_std', corr_value_en_std)
  return, result
end
