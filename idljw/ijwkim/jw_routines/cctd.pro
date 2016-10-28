
function cctd, tvector, ch1_array = ch1_array, ch2_array=ch2_array, distance = distance, $
 trange=trange, freq_filter = freq_filter, subwindow_npts = subwindow_npts,window_npts=window_npts, cross_plot=cross_plot, envel_plot=envel_plot
 
  default, subwindow_npts, 256L
  default, freq_filter, [0, 500e3]
  default, window_npts, subwindow_npts*32
  default, distance, 120.0 ;[mm]
  default, cross_plot, 0
  default, envel_plot, 0
  
  d1 = select_time(tvector,ch1_array,trange)
  d2 = select_time(tvector,ch2_array,trange)
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
  xcorr_mean = dblarr(window_number,2*subwindow_npts-1)
  envel_mean = dblarr(window_number,2*subwindow_npts-1) ;/sqrt((*xcorr[i,j]).subwindow_number)
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
    
    xcorr[i] = ptr_new(jw_bes_xcorr(ch1_array=reform_channel[0,*,i],ch2_array=reform_channel[1,*,i],freq_filter=freq_filter,subwindow_npts=subwindow_npts,dt=dt))
    
    lag = (*xcorr[i]).lag
    xcorr_mean[i,*] = (*xcorr[i]).xcorr_mean
    envel_mean[i,*] = (*xcorr[i]).envel_mean
    subwin_number = (*xcorr[i]).subwindow_number
  endfor
  
  
;;;;;;;;;;;;;; get group velocity ;;;;;;;;;;;;;;;;;;;;;
  
  ab = 25
  find_index = lindgen(2*ab+1)-ab+floor(n_elements(lag)/2)
  cctd_vel = dblarr(window_number)
  max_envel_value = dblarr(window_number)
  envel_delay = dblarr(window_number)
  for i = 0L, window_number-1 do begin
;    quad = 'p[2]*(x-p[0])^2+p[1]'
;    start = [lag[max_index], max_envel, -10.0]
;;    rerr = corr_var_en_norm_sum/sqrt(subwin_number)
;    result= mpfitexpr(quad,lag[fit_index]*10.0^6.0, envel_mean[i,fit_index],dblarr(n_elements(fit_index))+0.1,  start)
;    ycplot, lag, 10.0^6.0*result[2]*(lag-result[0])^2+result[1], oplot_id = oid
    max_envel = max(envel_mean[i,find_index],max_index)
    index_size = 1
    max_index = max_index+floor(n_elements(lag)/2)-ab
    fit_index = lindgen(index_size*2+1)-index_size+max_index
    fit_lag = lag[fit_index]
    x_value = [[fit_lag[0]^2, fit_lag[0], 1],[fit_lag[1]^2, fit_lag[1], 1],[fit_lag[2]^2, fit_lag[2], 1]]
    y_value = envel_mean[i,[max_index-1, max_index, max_index+1]]
    solv = la_linear_equation(x_value, y_value)
;    print, solv

    x_plot = (findgen(6001)-3000)*0.00000001
    y=solv[0]*x_plot^2+solv[1]*x_plot+solv[2]

    if envel_plot eq 1 then begin
      ycplot, lag, xcorr_mean[i,*], out_base_id = oid
      ycplot, lag, envel_mean[i,*], oplot_id = oid
      ycplot, x_plot, y, oplot_id = oid
    endif
    
;    print, -solv[1]/(2*solv[0])
    cctd_vel[i] = distance/1000.0/(-solv[1]/(2*solv[0]))
    envel_delay[i] = (-solv[1]/(2*solv[0]))
    max_envel_value[i] = max_envel
  endfor
  
;;;;;;;;;;;;;; get phase velocity ;;;;;;;;;;;;;;;;;;;;;  
  
  
  find_index = lindgen(2*ab+1)-ab+floor(n_elements(lag)/2)
  cctd_vel_phase = dblarr(window_number)
  xcorr_delay = dblarr(window_number)
  max_xcorr_value = dblarr(window_number)
  for i = 0L, window_number-1 do begin
    max_xcorr = max(xcorr_mean[i,find_index],max_index)
    index_size = 1
    max_index = max_index+floor(n_elements(lag)/2)-ab
    fit_index = lindgen(index_size*2+1)-index_size+max_index
    fit_lag = lag[fit_index]
    x_value = [[fit_lag[0]^2, fit_lag[0], 1],[fit_lag[1]^2, fit_lag[1], 1],[fit_lag[2]^2, fit_lag[2], 1]]
    y_value = xcorr_mean[i,[max_index-1, max_index, max_index+1]]
    solv = la_linear_equation(x_value, y_value)
;    print, solv

    x_plot = (findgen(6001)-3000)*0.00000001
    y=solv[0]*x_plot^2+solv[1]*x_plot+solv[2]

    if cross_plot eq 1 then begin
      ycplot, lag, xcorr_mean[i,*], out_base_id = oid
      ycplot, lag, envel_mean[i,*], oplot_id = oid
      ycplot, x_plot, y, oplot_id = oid
    endif
    
;    print, -solv[1]/(2*solv[0])
    cctd_vel_phase[i] = distance/1000.0/(-solv[1]/(2*solv[0]))
    xcorr_delay[i] = (-solv[1]/(2*solv[0]))
    max_xcorr_value[i] = max_xcorr
  endfor
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  
  result = CREATE_STRUCT('tvector', time_vector, 'xcorr', xcorr_mean, 'envel', envel_mean, 'win_number', window_number, $
    'velocity', cctd_vel, 'max_envel', max_envel_value, 'envel_delay', envel_delay, 'subwin_number', subwin_number, 'phase_velocity', cctd_vel_phase, 'max_xcorr', $
     max_xcorr_value, 'xcorr_delay', xcorr_delay, 'lag', lag)
  return, result
end
