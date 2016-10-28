function corr_time, tvector, ch1_array, ch2_array, $
      trange=trange, freq_filter = freq_filter, subwindow_npts = subwindow_npts, window_npts=window_npts, fast = fast
 
  default, subwindow_npts, 1024L
  default, freq_filter, [0, 500e3]
  default, window_npts, subwindow_npts*4
  final_index = n_elements(tvector)-1
  default, trange, [tvector[0], tvector[final_index]]
  default, fast, 2.0
  
  
  d1 = jw_select_time(tvector,ch1_array,trange)
  d2 = jw_select_time(tvector,ch2_array,trange)
  tvector = d1.tvector
  ch1_array = d1.yvector
  ch2_array = d2.yvector
  
  dt = tvector[1]-tvector[0]
  
;  print, 'dt = ', dt
  
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
  xcorr_mean = dblarr(window_number,2*floor(subwindow_npts/fast)-1)
  envel_mean = dblarr(window_number,2*floor(subwindow_npts/fast)-1) ;/sqrt((*xcorr[i,j]).subwindow_number)
  time_vector = dblarr(window_number)

  reform_channel = dblarr(2,window_npts,window_number)
  reform_channel[0,*,*] = reform(s1(1:window_number*window_npts),[window_npts,window_number])
  reform_channel[1,*,*] = reform(s2(1:window_number*window_npts),[window_npts,window_number])
  reform_tvector = reform(tvector(1:window_number*window_npts),[window_npts,window_number])
    
  for i = 0L, window_number-1 do begin
    time_vector[i] = (reform_tvector[0,i]+reform_tvector[window_npts-1,i])/2
  endfor
  ;;;;;
  xcorr = ptrarr(window_number)
  for i = 0L, window_number-1 do begin
;    print, window_number, ':', i
;    corr_step = corr_measure(shot_number,ch_number,ch_array = array_sum,subwindow_npts=subwindow_npts)
;    corr_map[i,*] = corr_step.corr_value
;    corr_length_gauss[i] = corr_step.corr_length_gauss
;    corr_length_exp[i] = corr_step.corr_length_exp
    
    xcorr[i] = ptr_new(jw_bes_xcorr(ch1_array=reform_channel[0,*,i],ch2_array=reform_channel[1,*,i],freq_filter=freq_filter,subwindow_npts=subwindow_npts,dt=dt,fast=fast))
    lag = (*xcorr[i]).lag
    xcorr_mean[i,*] = (*xcorr[i]).xcorr_mean
    envel_mean[i,*] = (*xcorr[i]).envel_mean
    subwin_number = (*xcorr[i]).subwindow_number
  endfor
;  ycplot, lag, xcorr_mean[1,*], out_base_id = oid
;  ycplot, lag, envel_mean[1,*], oplot_id = oid
;  print, xcorr_mean[*,where(lag eq 0.0)]

  envel_result = envel_mean[*,where(lag eq 0.0)]
  
  
  result = CREATE_STRUCT('tvector', time_vector,'lag',lag,'envel',envel_mean, 'xcorr',xcorr_mean $
    ,'envel_mean', envel_mean[*,where(lag eq 0.0)], 'xcorr_mean', xcorr_mean[*,where(lag eq 0.0)])
  return, result
end
  
  
  