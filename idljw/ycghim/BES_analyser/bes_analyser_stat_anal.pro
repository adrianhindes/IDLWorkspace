;===================================================================================
;
; This file contains following functions and procedures to perform
;  statistical analyses on MAST BES data.
;
;  0) yc_correlate
;    --> modified version IDL c_correlate
;
;  0.5) perform_spike_remover
;     --> remover the spikes (i.e. neutron peaks) from the BES data
;
;  1) calc_rms_over_dc
;     --> calculate the time evolutin of rms/dc of BES data
;
;  2) make_BES_animation
;     --> creates the BES animation
;
;  3) prep_to_perform_stat
;     --> prepares signals to calculate spectrum or spesctrogram
;
;  4) perform_idl_fft
;     --> performs FFT on input signals.  This is an IDL version of perform_cuda_fft.
;
;  5) perform_idl_temp_corr
;     --> performs temporal correlation on input signals. This is an IDL version of perform_cuda_temp_corr.
;
;  6) perform_spa_temp_corr
;     --> performs spatio-temporal correlation of BES signals.
;
;  7) perform_spa_spa_corr
;     --> performs spatio-spatio corerlation of BES signals
;
;  8) perform_vel_time_evol
;     --> performs to calcualte time evolution of velocity
;
;
;===================================================================================


;===================================================================================
; This function computes the cross-correlation of data x and y
; This function is a modified version IDL c_correlate
;===================================================================================
;  The function parameters:
;    1) x: same as x input for c_correlate
;    2) y: same as y input for c_correlate
;    3) lag: same as inx input for c_correlate
;    4) covariace: same as covariacen input for c_correlate
;===================================================================================
;  Return:
;   Return values are same as c_correlate
;===================================================================================
; Modifiction of c_correlate
;   If provided x and/or y are constants with covariacen keyword set to zero, then
;      normalisation factor becomes zero which results in NaN of the correlation value.
;   So, if provided x and/or y are costants, then correlation value is forced to be zero.
;===================================================================================
function yc_correlate, x, y, lag, covariance = covariance

; if covariance is to be calculated, then normalising problem does not occur.
 if keyword_set(covariance) then begin
   cc = c_correlate(x, y, lag, cov = 1)
 ;so far, the calcualte data_out is the same algorithm as the IDL c_correlate, however it produces 'baised' correlations.
 ;thus, I am correcting the value such the values are not biased.
 ;For further details, see Random Data by Bendat and Piersol 4th ed. p. 405.
   nx = n_elements(x)
   cc = cc * nx / (nx - abs(lag))
   return, cc 
 endif

; check whether RMS values of x or y are zero or not.
  temp_x = reform(x)
  temp_y = reform(y)
  mean_x = total(temp_x)/n_elements(temp_x)
  mean_y = total(temp_y)/n_elements(temp_y)
  RMS_x = total((temp_x - mean_x)^2.0)
  RMS_y = total((temp_y - mean_y)^2.0)

  if ( (RMS_x eq 0.0) or (RMS_y eq 0.0) ) then begin
    result_vector = fltarr(n_elements(lag))
    result_vector[*] = 0.0
    return, result_vector
  endif else begin
    cc = c_correlate(x, y, lag)
  ;so far, the calcualte data_out is the same algorithm as the IDL c_correlate, however it produces 'baised' correlations.
  ;thus, I am correcting the value such the values are not biased.
  ;For further details, see Random Data by Bendat and Piersol 4th ed. p. 405.
    nx = n_elements(x)
    cc = cc * nx / (nx - abs(lag))
    return, cc 
  endelse

end


function perform_spike_remover, signal, thresh

; Save original signal
  fsignal = reform(signal)

  if thresh le 0.0 then $
    return, fsignal

  debug = 0

; Radiation 'spike' filter based on RMKI algorithm coded in 'mast_filter.pro'
; written as subroutine by ARF on 17.01.12

; Differentiate signal
  diff = deriv(fsignal)

; Number of filtered pulses
  n_pulses = 0

; One point where diff > thresh, one mid-point and either of next two with diff < -thresh
  ind = where((diff ge thresh) and ((shift(diff, -2) lt -thresh) or (shift(diff, -3) lt -thresh)), count)

  if count gt 0 then begin

    if debug then begin
      window, 0
      plot, diff[ind[0]-5:ind[0]+5], yr=[-.6, .6]
      for i=1, n_elements(ind)-1 do $
        oplot, diff[ind[i]-5:ind[i]+5]
    endif

    if (ind[0] ge 0) then begin

      indind = where(ind < n_elements(diff)-6)

; Replace points 1 and 2 with point just before spike and 3 and 4 with point after

      if (indind[0] ge 0) then begin
        ind = ind[indind]
        fsignal[ind+1] = fsignal[ind]
        fsignal[ind+2] = fsignal[ind]
        fsignal[ind+3] = fsignal[ind+5]
        fsignal[ind+4] = fsignal[ind+5]
        n_pulses = n_pulses+n_elements(ind)
      endif

    endif

    if debug then begin
      window, 1
      plot, fsignal[ind[0]-5:ind[0]+5], yr=[-2., 0.]
      for i=1, n_elements(ind)-1 do $
        oplot, fsignal[ind[i]-5:ind[i]+5]
      for i=0, n_elements(ind)-1 do $
        oplot, signal[ind[i]-5:ind[i]+5]
    endif

  endif

  if debug then stop

; One point where diff > thresh and either of next two where diff < -thresh
  ind = where((diff ge thresh) and ((shift(diff, -1) lt -thresh) or (shift(diff, -2) lt -thresh)), count)

  if count gt 0 then begin

    if debug then begin
      window, 0
      plot, diff[ind[0]-5:ind[0]+5], yr=[-.6, .6]
      for i=0, n_elements(ind)-1 do $
        oplot, diff[ind[i]-5:ind[i]+5]
    endif

    if (ind[0] ge 0) then begin

      indind = where(ind < n_elements(diff)-6)

; Replace points 1 with point just before spike and 2 and 3 with point after

      if (indind[0] ge 0) then begin
        ind = ind[indind]
        fsignal[ind+1] = fsignal[ind]
        fsignal[ind+2] = fsignal[ind+4]
        fsignal[ind+3] = fsignal[ind+4]
        n_pulses = n_pulses+n_elements(ind)
      endif

    endif

    if debug then begin
      window, 1
      plot, fsignal[ind[0]-5:ind[0]+5], yr=[-2., 0.]
      for i=1, n_elements(ind)-1 do $
        oplot, fsignal[ind[i]-5:ind[i]+5]
      for i=0, n_elements(ind)-1 do $
        oplot, signal[ind[i]-5:ind[i]+5]
    endif

  endif

  if debug then stop

  return, fsignal


end




;===================================================================================
; This function computes the time evolution fo RMS/DC of BES data.
; This function is performed on IDL.
;===================================================================================
; The function parameters:
;   1) in_time: <1D array floating> contains the time vector for the input data
;   2) in_data: <1D array floating> contains the input data to be analysed.
;   3) in_dt: <floating> contains the time step of the input data in [sec].
;   4) in_avg_nt: <long> contains the number of time points to average the data.
;   5) in_BES_ch: <int> The BES channel number
;   6) subtract_DC: <1 or 0>  If 1, then RMS is calculated with DC values removed.
;                             If 0, then RMS is calculated without DC values removed.
;   7) DC_freq_filter: <floating> contains the non-zero frequency in [kHz] which is the
;                                 high frequency part of Low Pass Filter.  Low frequency 
;                                 part is always 0.0 kHz. 
;                      Note: If this is not set, then DC values will be calculated using
;                            avg_nt.
;                            If this is set, then DC values will be calculated by performing
;                            low pass filter.
;   8) RMS_freq_filter: <two-element 1D array floating> contains the low and high frequencies
;                       to be filtered in [kHz].
;   9) write_status: <1 or 0> If the IDL message box is ON, then 1. Otherwise 0.
;  10) ID_msg_box: <long> ID of the text box to write the current calculation status to a user.
;===================================================================================
; Return value:
;   'result' is a structure containing {erc, errmsg, tvector, dvector}
;         result.erc: <integer> error number.
;                     If 0, then no error.
;                     If not 0, then error occured during the calculation.
;         result.errmsg: <string> error
;         result.tvector: <1D array floating> contains the time vector
;         result.dvector: <1D array floating> contains the resultant vector
;===================================================================================
; <Calculation procedure>
;
;  1. Calculating DC values of the data.
;     1) If DC_freq_filter is specified.
;        Perform Low Pass Filter to get DC values.
;        In this case, the time step is same as the time step (dt) of th in_time.
;     2) If DC_freq_filter is NOT specified.
;        DC values are calcualted by averaging the data over avg_nt.
;        In this case, the time step of DC values is no longer same as the time step (dt) of in_time.
;        The time step will become dt * avg_nt.
;
;  2. Calculating RMS value of the data.
;     RMS values are calcualted using only fluctuating components of the data.
;     (i.e. the input data will be subtracted by the DC values to calculate RMS values.)
;     The fluctuating signals will be filtered by RMS_freq_filter if it is specified.
;     The number of points to be averaged is specified as avg_nt.
;
;
;===================================================================================
function calc_rms_over_dc, in_time, in_data, in_dt, in_avg_nt, in_BES_ch, $
                           subtract_DC = in_subtract_DC, $
                           DC_freq_filter = in_DC_freq_filter, $
                           RMS_freq_filter = in_RMS_freq_filter, $
                           write_status = in_ID_msg_box_ON, $
                           ID_msg_box = ID_msg_box

; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}

; keyword check
  if keyword_set(in_DC_freq_filter) then begin
    perform_lpf = 1
    DC_freq_filter = [0.0, in_DC_freq_filter]	; in [kHz]
  endif else begin
    perform_lpf = 0
  endelse

  if keyword_set(in_RMS_freq_filter) then begin
    perform_bpf = 1
    RMS_freq_filter = in_RMS_freq_filter	;in [kHz]
  endif else begin
    perform_bpf = 0
  endelse

  if keyword_set(in_subtract_DC) then $
    subtract_DC = 1 $
  else $
    subtract_DC = 0

  if keyword_set(in_ID_msg_box_ON) then $
    write_status = 1 $
  else $
    write_status = 0

; prepare the data so that the analysis can be performe by array-oriented calculation.
  in_total_nt = n_elements(in_time)
  if in_total_nt ne n_elements(in_data) then begin
    result.erc = 200
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  out_nt = long(in_total_nt/in_avg_nt)
  if out_nt lt 5 then begin
    result.erc = 201
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  temp_in_data = fltarr(out_nt, in_avg_nt)
  temp_in_time = fltarr(out_nt, in_avg_nt)
  for i = 0l, out_nt - 1 do begin
    temp_in_data[i, *] = in_data[i*in_avg_nt:(i+1)*in_avg_nt-1]
    temp_in_time[i, *] = in_time[i*in_avg_nt:(i+1)*in_avg_nt-1]
  endfor
  out_time = total(temp_in_time, 2)
  out_time = out_time/in_avg_nt

; calculation starts.
  if write_status then begin
    widget_control, ID_msg_box, set_value = '', /append
    msg_str = '<Calculating RMS/DC starts for BES Ch. ' + string(in_BES_ch, format='(i0)') + '>'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

; Calcualte the time evolution of DC values of the input data.
  if write_status then begin
    msg_str = '  DC values are being calculated by '
    if perform_lpf then begin
      msg_str = msg_str + 'Low Pass Filtering: [' + string(DC_freq_filter[0], format='(f0.1)') + ', ' + $
                string(DC_freq_filter[1], format='(f0.1)') + '] kHz...'
    endif else begin
      msg_str = msg_str + 'averaging over ' + string(in_avg_nt, format='(i0)') + ' time points...'
    endelse
    widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
  endif

  if perform_lpf then begin	;calculate DC values by performing Low Pass Filter.
    filter_result = freq_filter_signal(in_data, DC_freq_filter[0], DC_freq_filter[1], in_dt)
    dc_data = filter_result.filtered_signal	;note: keep the zeroed values dueing the filtering as
                                                ;      I need to keep the number of data points for now.
    dc_data_inx_nonzero_begin = filter_result.inx_nonzero_begin
    dc_data_inx_nonzero_end = filter_result.inx_nonzero_end
  endif else begin		;calculate DC values by averaging the data points.
    dc_data = total(temp_in_data, 2)
    dc_data = dc_data/in_avg_nt
  endelse
  dc_data_nt = n_elements(dc_data)

  if write_status then begin
    widget_control, ID_msg_box, set_value = 'DONE!', /append
  endif

; Calculate the time evolution of RMS values of the input data
  if write_status then begin
    msg_str = '  RMS values are being calculated...'
    widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
  endif

; first, frequency filter the signal
  if perform_bpf then begin
    filter_result = freq_filter_signal(in_data, RMS_freq_filter[0], RMS_freq_filter[1], in_dt)
    bpf_data = filter_result.filtered_signal	;note: keep the zeroed values dueing the filtering as
                                                ;      I need to keep the number of data points for now
    bpf_data_inx_nonzero_begin = filter_result.inx_nonzero_begin
    bpf_data_inx_nonzero_end = filter_result.inx_nonzero_end
  endif
  temp_bpf_data = fltarr(out_nt, in_avg_nt)
  for i = 0l, out_nt - 1 do begin
    temp_bpf_data[i, *] = bpf_data[i*in_avg_nt:(i+1)*in_avg_nt-1]
  endfor

; second, subtract the mean values from the original signal if in_subtract_DC is set.
  if perform_lpf then begin	;number of elements in in_data and dc_data are the same for this case.
    temp_rms_data = fltarr(out_nt, in_avg_nt)
    temp_dc_data = fltarr(out_nt, in_avg_nt)
    for i = 0l, out_nt - 1 do begin
      temp_dc_data[i, *] = dc_data[i*in_avg_nt:(i+1)*in_avg_nt-1]
    endfor
    if in_subtract_DC then $
      temp_rms_data = temp_bpf_data - temp_dc_data $
    else $
      temp_rms_data = temp_bpf_data
    dc_data = fltarr(out_nt)
    dc_data = total(temp_dc_data, 2)
    dc_data = dc_data/in_avg_nt
  endif else begin		;number of elemenst in in_data and dc_data are different for this case.
    temp_rms_data = fltarr(out_nt, in_avg_nt)
    if in_subtract_DC then begin
      for i = 0l, out_nt - 1 do begin
        temp_rms_data[i, *] = temp_bpf_data[i, *] - dc_data[i]
      endfor
    endif else begin
      temp_rms_data = temp_bpf_data
    endelse
  endelse

; now, calculate the RMS values
  rms_data = total(temp_rms_data*temp_rms_data, 2)
  rms_data = rms_data/in_avg_nt
  rms_data = sqrt(rms_data)
 
  if write_status then begin
    widget_control, ID_msg_box, set_value = 'DONE!', /append
  endif

; output data
  out_data = rms_data/dc_data

  end_time = systime(1)
  if write_status then begin
    msg_str = '  Elapsed time: ' + string(end_time - start_time, format='(f0.3)') + ' [sec].'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

  result = create_struct(result, 'time', out_time, 'data', out_data)

  return, result

end


;===================================================================================
; This function creates BES animation
; This function is performed on IDL.
;===================================================================================
; The function parameters:
;   1) in_data: <2D array floating> i.e. in_data[nch, ntime]
;               This is a raw BES data contrcuted in 2D array.
;   2) in_time: <1D array floating> contains the time vector for in_data
;   3) in_dt: <floating> contains the time step of the input data in [sec]
;   4) in_pos: <2D array floatgin> i.e. in_pos[nch, 2] in [cm]
;              This contains the channel position for each BES channel.
;              in_pos[*, 0] --> contains the radial (Major radius) position
;              in_por[*, 1] --> contains the poloidal position
;   5) in_time_range: <two-element 1D array floating> in [sec]
;                     This contains the time range to generate the BES animation.
;                     in_time_range[0] --> start time of animation
;                     in_time_range[1] --> end time of animation
;   6) factor_inc_spa_pts: <integer>
;                          This contains the factor to increase the spatial resolution
;                          of BES singal.  
;                          Spatial resolution is increased by performing spatial interpolation.
;   7) freq_filter: <two-element 1D array floatin> in [kHz]
;                   This contains the frequency filtering range for a raw BES signal.
;                   freq_filter[0] --> lower cutoff of the frequency
;                   freq_filter[1] --> higher cutoff of the frequency
;   8) play_type: <0, 1, or 2>	If 0, then play n(t)
;                               If 1, then play n1(t)
;                               If 2, then play n1(t)/n0(t)  
;   9) by_time_avg_for_DC: <1 or 0> If 1, then DC value is calculated by time-averaging.
;                          Note: If this keyword is set, then by_LPF_for_DC keyword must be zero, 
;                                and vice versa.
;  10) avg_nt: <long> contains the number of time points to average the data.
;  11) by_LPF_for_DC: <1 or 0> If 1, then DC value is calculated by Low Pass Filter.
;                              Note: If this keyword is set, then by_time_avg_for_DC keyword must be zero, 
;                                     and vice versa.
;  12) DC_freq_filter_high: <floating> contains the non-zero frequency in [kHz] which is the
;                                      high frequency part of Low Pass Filter.  Low frequency 
;                                      part is always 0.0 kHz.
;  13) normalize: <1 or 0> If 1, then BES signal is normalized.
;                          If 0, then BES signal is not normalized.
;  14) norm_by_own_ch: <1 or 0> If 1, then each channel of BES channels are normalized by 
;                                     a maximum of its own channel.
;                               Note: If this is set, then norm_by_all_ch must not be set,
;                                     and vice versa.
;  15) norm_by_all_ch: <1 or 0> If 1, then each channel of BES channels are normalized by 
;                                     a maximum of all channels (i.e. global maximum).
;                               Note: If this is set, then norm_by_own_ch must not be set,
;                                     and vice versa.
;  16) write_status: <1 or 0> If the IDL message box is ON, then 1. Otherwise 0.
;  17) ID_msg_box: <long> ID of the text box to write the current calculation status to a user.
;===================================================================================
; Return value:
;   'result' is a structure containing {erc, errmsg, dvector, xvector, yvector, tvector}
;         result.erc: <integer> error number.
;                     If 0, then no error.
;                     If not 0, then error occured during the calculation.
;         result.errmsg: <string> error
;         result.dvector: <3D array floating> contains the resultant vector
;         result.xvector: <1D array floating> contains the x-axis vector
;         result.yvector: <1D array floating> contains the y-axis vector
;         result.tvector: <1D array floating> contains the time vector
;===================================================================================
; <Calculation procedure>
;  1. Extract the BES signal from in_time_range[0] to in_time_range[1] --> BES_1
;  2. Calculate the DC components of BES_1 if necessary (i.e. if play_type ne 0.) --> BES_DC
;  3. Freqeuency Filter the BES_1 --> BES_2
;  4. If play_type = 0 --> BES_3 = BES_2			i.e. play n(t)
;     If play_type = 1 --> BES_3 = BES_2 - BES_DC		i.e. play n1(t)
;     If play_type = 2 --> BES_3 = (BES_2 - BES_DC)/BES_DC	i.e. play n1(t)/n0(t)
;  5. Normlize BES_3 if normalize in set --> BES_4
;  6. Perform spatial interpolatoin on BES_4 --> BES_result
;===================================================================================
function make_BES_animation, in_data, in_time, in_dt, in_pos, in_time_range, $
                             factor_inc_spa_pts = in_factor_inc_spa_pts, $
                             freq_filter = in_freq_filter, $
                             play_type = in_play_type, $
                             by_time_avg_for_DC = in_by_time_avg_for_DC, $
                             avg_nt = in_avg_nt, $
                             by_LPF_for_DC = in_by_LPF_for_DC, $
                             DC_freq_filter_high = in_DC_freq_filter_high, $
                             normalize = in_normalize, $
                             norm_by_own_ch = in_norm_by_own_ch, $
                             norm_by_all_ch = in_norm_by_all_ch, $
                             write_status = in_ID_msg_box_ON, $
                             ID_msg_box = ID_msg_box

; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}

; check the function parameters
  if( size(in_data, /n_dim) ne 2 ) then begin
    result.erc = 259
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  dim = size(in_data, /dim)
  nch = dim[0]
  ntime = dim[1]
  nch_R = 8
  nch_Z = 4

  if ( size(in_time, /dim) ne ntime ) then begin
    result.erc = 259
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  if( size(in_pos, /n_dim) ne 2 ) then begin
    result.erc = 259
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  dim = size(in_pos, /dim)
  if (dim[0] ne nch) then begin
    result.erc = 259
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  if (dim[1] ne 2) then begin
    result.erc = 259
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  if( size(in_time_range, /dim) ne 2) then begin
    result.erc = 259
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  if keyword_set(in_factor_inc_spa_pts) then begin
    perform_inc_spa_pts = 1
    factor_inc_spa_pts = fix(in_factor_inc_spa_pts)
  endif else begin
    perform_inc_spa_pts = 0
  endelse 

  if keyword_set(in_freq_filter) then begin
    perform_bpf = 1
    freq_filter = in_freq_filter
  endif else begin
    perform_bpf = 0
  endelse

  if keyword_set(in_play_type) then $
    play_type = in_play_type $
  else $
    play_type = 0

  if keyword_set(in_by_time_avg_for_DC) then $
    by_time_avg_for_DC = 1 $
  else $
    by_time_avg_for_DC = 0

  if keyword_set(in_avg_nt) then $
    avg_nt = in_avg_nt $
  else $
    avg_nt = 0

  if keyword_set(in_by_LPF_for_DC) then $
    by_LPF_for_DC = 1 $
  else $
    by_LPF_for_DC = 0

  if keyword_set(in_DC_freq_filter_high) then $
    DC_freq_filter_high = in_DC_freq_filter_high $
  else $
    DC_freq_filter_high = 0.0

  if play_type ne 0 then begin
    if ( (by_time_avg_for_DC eq 0) and (by_LPF_for_DC eq 0) ) then begin
      result.erc = 259
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif else if ( (by_time_avg_for_DC eq 1) and (by_LPF_for_DC eq 1) ) then begin
      result.erc = 259
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif 

    if ( (by_time_avg_for_DC eq 1) and (avg_nt eq 0) ) then begin
      result.erc = 259
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif 

    if ( (by_LPF_for_DC eq 1) and (DC_freq_filter_high eq 0.0) ) then begin
      result.erc = 259
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endif

  if keyword_set(in_normalize) then $
    perform_norm = 1 $
  else $
    perform_norm = 0

  if keyword_set(in_norm_by_own_ch) then $
    norm_by_own_ch = 1 $
  else $
    norm_by_own_ch = 0

  if keyword_set(in_norm_by_all_ch) then $
    norm_by_all_ch = 1 $
  else $
    norm_by_all_ch = 0

  if perform_norm eq 1 then begin
    if ( (norm_by_own_ch eq 0) and (norm_by_all_ch eq 0) ) then begin
      result.erc = 259
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif else if ( (norm_by_own_ch eq 1) and (norm_by_all_ch eq 1) ) then begin
      result.erc = 259
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif 
  endif

  if keyword_set(in_ID_msg_box_ON) then $
    write_status = 1 $
  else $
    write_status = 0

; <Calculation procedure>
;  1. Extract the BES signal from in_time_range[0] to in_time_range[1] --> BES_1
;  2. Calculate the DC components of BES_1 if necessary (i.e. if play_type ne 0.) --> BES_DC
;  3. Freqeuency Filter the BES_1 --> BES_2
;  4. If play_type = 0 --> BES_3 = BES_2			i.e. play n(t)
;     If play_type = 1 --> BES_3 = BES_2 - BES_DC		i.e. play n1(t)
;     If play_type = 2 --> BES_3 = (BES_2 - BES_DC)/BES_DC	i.e. play n1(t)/n0(t)
;  5. Normlize BES_3 if normalize in set --> BES_4
;  6. Perform spatial interpolatoin on BES_4 --> BES_result

  if write_status then begin
    widget_control, ID_msg_box, set_value = '', /append
    msg_str = '<Generating BES Animation starts>'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

; The first step start: extracting BES signal from in_time_range[0] to in_time_range[1] --> BES_1
  if write_status then begin
    widget_control, ID_msg_box, set_value = '  Extracting the selected time region: ', /append, /no_newline
  endif
  inx_tstart = where(in_time ge in_time_range[0], count)
  if count le 0 then $
    inx_tstart = 0 $
  else $
    inx_tstart = inx_tstart[0]
  inx_tend = where(in_time ge in_time_range[1], count)
  if count le 0 then $
    inx_tend = n_elements(in_time) - 1 $
  else $
    inx_tend = inx_tend[0]
  if write_status then begin
    msg_str = '[' + string(in_time[inx_tstart]*1e3, format='(f0.4)') + ', ' + $
                    string(in_time[inx_tend]*1e3, format='(f0.4)') + '] msec...'
    widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
  endif

  out_ntime = inx_tend - inx_tstart + 1
  out_BES_data = fltarr(nch_R, nch_Z, out_ntime)
  x_pos = fltarr(nch_R)
  y_pos = fltarr(nch_Z)
  for i = 0, nch - 1 do begin
    out_BES_data[(nch_R-1)-(i mod nch_R), fix(i/nch_R), *] = in_data[i, inx_tstart:inx_tend]
    if fix(i/nch_R) eq 0 then begin
      x_pos[nch_R-1-i] = in_pos[i, 0]
    endif
    if (i mod nch_R) eq 0 then begin
      y_pos[fix(i/nch_R)] = in_pos[i, 1] 
    endif
  endfor
  out_time = in_time[inx_tstart:inx_tend]

  if write_status then begin
    widget_control, ID_msg_box, set_value = 'DONE!', /append
  endif

; Second, calculate the DC components for each channel if play_type ne 0.
  BES_DC = fltarr(nch_R, nch_Z, out_ntime)
  BES_DC_inx_nonzero_begin = fltarr(nch_R, nch_Z)
  BES_DC_inx_nonzero_begin[*, *] = 0.0
  BES_DC_inx_nonzero_end = fltarr(nch_R, nch_Z)
  BES_DC_inx_nonzero_end[*, *] = out_ntime - 1
  if play_type ne 0 then begin
    if write_status then begin
      widget_control, ID_msg_box, set_value = '  Calculating n0(t) for each channel...', /append, /no_newline
    endif
    if by_time_avg_for_DC then begin
    ; calculate BES_DC by time averaging
      for i = 0, nch_R-1 do begin
        for j = 0, nch_Z-1 do begin
          if avg_nt gt out_ntime then $
            avg_nt = out_ntime
          count = 0
          repeat begin
            BES_DC[i, j, count*avg_nt:(count+1)*avg_nt-1] = total(out_BES_data[i, j, count*avg_nt:(count+1)*avg_nt-1])/avg_nt
            count = count + 1
          endrep until ( (count + 1) * avg_nt ge out_ntime )
          if count * avg_nt lt out_ntime then begin
            BES_DC[i, j, count*avg_nt:(out_ntime-1)] = total(out_BES_data[i, j, count*avg_nt:(out_ntime-1)])/(out_ntime - count*avg_nt)
          endif
        endfor
      endfor
    endif else begin
    ; calculate BES_DC by LPF
      for i = 0, nch_R-1 do begin
        for j = 0, nch_Z-1 do begin
          filter_result = freq_filter_signal(reform(out_BES_data[i, j, *]), 0.0, DC_freq_filter_high, in_dt)
          BES_DC[i, j, *] = filter_result.filtered_signal
          BES_DC_inx_nonzero_begin[i, j] = filter_result.inx_nonzero_begin
          BES_DC_inx_nonzero_end[i, j] = filter_result.inx_nonzero_end
        endfor
      endfor
    endelse
    if write_status then begin
      widget_control, ID_msg_box, set_value = 'DONE!', /append
    endif
  endif else begin
    BES_DC[*, *, *] = 0.0
  endelse


; Thrid, frequency filter the BES signal if perform_bpf is set
  out_BES_data_inx_nonzero_begin = fltarr(nch_R, nch_Z)
  out_BES_data_inx_nonzero_begin[*, *] = 0.0
  out_BES_data_inx_nonzero_end = fltarr(nch_R, nch_Z)
  out_BES_data_inx_nonzero_end[*, *] = out_ntime - 1
  if perform_bpf eq 1 then begin
    if write_status then begin
      widget_control, ID_msg_box, set_value = '  Freq. filtering n(t) for each channel...', /append, /no_newline
    endif
    for i = 0, nch_R-1 do begin
      for j = 0, nch_Z-1 do begin
        filter_result = freq_filter_signal(reform(out_BES_data[i, j, *]), freq_filter[0], freq_filter[1], in_dt)
        out_BES_data[i, j, *] = filter_result.filtered_signal
        out_BES_data_inx_nonzero_begin[i, j] = filter_result.inx_nonzero_begin
        out_BES_data_inx_nonzero_end[i, j] = filter_result.inx_nonzero_end
      endfor
    endfor
    if write_status then begin
      widget_control, ID_msg_box, set_value = 'DONE!', /append
    endif
  endif

; now, extract out_BES_data, BES_DC and out_time where non-zero values exist
  out_BES_data_inx_nonzero_begin_max = max(out_BES_data_inx_nonzero_begin)
  out_BES_data_inx_nonzero_end_min = min(out_BES_data_inx_nonzero_end)
  BES_DC_inx_nonzero_begin_max = max(BES_DC_inx_nonzero_begin)
  BES_DC_inx_nonzero_end_min = min(BES_DC_inx_nonzero_end)
  start_inx = max([out_BES_data_inx_nonzero_begin_max, BES_DC_inx_nonzero_begin_max])
  end_inx = min([out_BES_data_inx_nonzero_end_min, BES_DC_inx_nonzero_end_min])

  temp_out_BES_data = fltarr(nch_R, nch_Z, end_inx-start_inx+1)
  temp_BES_DC = fltarr(nch_R, nch_Z, end_inx-start_inx+1)
  temp_out_BES_data[*, *, *] = temporary(out_BES_data[*, *, start_inx:end_inx])
  temp_BES_DC[*, *, *] = temporary(BES_DC[*, *, start_inx:end_inx])
  out_BES_data = temporary(temp_out_BES_data)
  BES_DC = temporary(temp_BES_DC)
  out_time = temporary(out_time[start_inx:end_inx])
  out_ntime = n_elements(out_time)

; Fourth, generate movie signal of 
;             n(t) 		if play_type = 0
;             n1(t) 		if play_type = 1
;             n1(t)/n0(t) 	if play_type = 2
  out_BES_data = out_BES_data - BES_DC
  if play_type eq 2 then begin
    out_BES_data = out_BES_data/BES_DC
  endif


; Fifth, normalize the out_BES_data if normalize is set.
  if perform_norm eq 1 then begin
    if write_status then begin
      widget_control, ID_msg_box, set_value = '  Normalizing data...', /append, /no_newline
    endif
    if norm_by_own_ch eq 1 then begin
      temp_max = max(out_BES_data, dimension=3, /abs, /nan)
      temp_max = abs(temp_max)
      for i = 0, nch_R-1 do $
        for j = 0, nch_Z-1 do $
          out_BES_data[i, j, *] = out_BES_data[i, j, *]/temp_max[i, j]
    endif else begin
      temp_max = max(out_BES_data, /abs, /nan)
      temp_max = abs(temp_max[0])
      out_BES_data = out_BES_data/temp_max
    endelse
    if write_status then begin
      widget_control, ID_msg_box, set_value = 'DONE!', /append
    endif
  endif

; Finally, perform the spatial interpolation to increase the spatial resolution
  out_x = x_pos
  out_y = y_pos
  if perform_inc_spa_pts eq 1 then begin
    if write_status then begin
      widget_control, ID_msg_box, set_value = '  Increasing spatial resolution...', /append, /no_newline
    endif
    old_x = temporary(out_x)
    old_nx = n_elements(old_x)
    max_x = max(old_x, min = min_x, /nan)
    new_nx = nch_R * factor_inc_spa_pts
    out_x = findgen(new_nx) * (max_x - min_x)/(new_nx-1) + min_x
    inx_x = (old_nx-1)/(max_x-min_x) * out_x - (old_nx-1)*min_x/(max_x-min_x)

    old_y = temporary(out_y)
    old_ny = n_elements(old_y)
    max_y = max(old_y, min = min_y, /nan)
    new_ny = nch_Z * factor_inc_spa_pts
    out_y = findgen(new_ny) * (max_y - min_y)/(new_ny-1) + min_y
    inx_y = (old_ny-1)/(max_y-min_y) * out_y - (old_ny-1)*min_y/(max_y-min_y)

    new_BES_data = fltarr(new_nx, new_ny, out_ntime)

    inx_time = lindgen(out_ntime)
    for i =0l, out_ntime - 1 do $
      new_BES_data[*, *, i] = interpolate(reform(out_BES_data[*, *, i]), inx_x, inx_y, /grid, cubic = -0.5)
;    new_BES_data = interpolate(out_BES_data, inx_x, inx_y, inx_time, /grid, cubic=-0.5)

    out_BES_data = fltarr(new_nx, new_ny, out_ntime)
    out_BES_data = temporary(new_BES_data)
    if write_status then begin
      widget_control, ID_msg_box, set_value = 'DONE!', /append
    endif
  endif

  end_time = systime(1)
  if write_status then begin
    msg_str = '  Elapsed time: ' + string(end_time - start_time, format='(f0.3)') + ' [sec].'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif


  result = create_struct(result, 'dvector', out_BES_data, 'xvector', out_x, 'yvector', out_y, 'tvector', out_time)

  return, result

end



;===================================================================================
; This function prepares the data to be ready for calculating spectrum or spectrogram
; This function is performed on IDL.
;===================================================================================
; The function parameters:
;  1) in_data: <2D floating array> Input signals for the calculation
;              in_data[nch, ntime]
;  2) in_time: <1D floating array> time array for in_data1 and in_data2.
;  3) in_dt: <floating> contains the time step of the input data in [sec]
;  4) num_sel_time_range: <long> contains the number of selected time ranges
;                            Note: if this is zero, then it means that the calculation is performed
;                                  using the full ranges of in_data1 and in_data2, then
;                                  the input to sel_time_range is simply ignored.
;  5) sel_time_range:<2D floating array> contains the selected time range for the calculation.
;                     Note: in_sel_time_range[in_num_sel_time_range, 2]
;                           --> in_sel_time_range[i, 0]: for the start time of ith region
;                           --> in_sel_time_range[i, 1]: for the end time of ith region
;  6) freq_filter: <two-element vector>: contains the frequency filtering range in [kHz]
;                                        --> freq_filter[0] for lower cutoff
;                                        --> freq_filter[1] for higher cutoff
;  7) num_pts_per_subwindow: <long> contains the number of points within a sub-time window.
;                                   --> This sub-time window becomes a bin.
;                                   --> This number is related to the frequency resolution.
;                                       i.e. The frequency resolution is 1.0/(num_pts_per_subwindow*in_dt)
;                            Note: This number may be changed during this function so that 
;                                  multiple selected time ranges can be fit.
;  8) num_bins_to_average: <long> continas the number of bins to be averaged for the calculation.
;                                  --> This number is related to the time resolution of the spectrogram.
;                                  --> If spectrum is to be calculated, then this number must be equal to 
;                                      the total number of available sub-time windows.  
;                                      Thus, this number may be changed if spectrum is to be calculated.
;                                      In fact, this number will simply be ignored if spectrum is to be calculated,
;                                      and a proper num_bins_to_average will be generated.
;  9) overlap: <floating> contains the fraction (from 0.0 to 0.9) to be overlaped between
;                         neiggboring sub-time windows.
;                         --> If in_num_sel_time_range is greater 1, then this number will be set to 0.0
; 10) spectrogram: <0 or 1> contains whether this is for the calculation of spectrum (0) or spectrogram (1).
;                         --> If spectrogram is selected, then sel_time_range will be irrelavant.
; 11) remove_large_structure: <0 or 1> If this is 1, then large structures (i.e. MHD modes) are removed by
;                                      averaging the signal spatially.
; 12) data_for_removal: <2D floating array> [32, ntime]
;                       Contains BES signals for all the 32 channels.
; 13) norm_by_DC: <0 or 1> If 1, then signals are normalized by its DC values.
;                          If 0, then signals are not normalized.
; 14) write_status: <1 or 0> If the IDL message box is ON, then 1. Otherwise 0.
; 15) ID_msg_box: <long> ID of the text box to write the current calculation status to a user.
;===================================================================================
; Return value:
;   'result' is a structure containing {erc, errmsg, $
;                                       out_data1, out_data2, $
;                                       out_num_pts_per_subwindow, $
;                                       out_num_bins_to_average, $
;                                       out_overlap}
;         result.erc: <integer> error number.
;                     If 0, then no error.
;                     If not 0, then error occured during the calculation.
;         result.errmsg: <string> error
;         result.out_data: <2D floating array> reconstructed in_data for the calculation
;         result.out_time: <1D floating array> reconstructed time array
;         result.out_sel_time_range: <2D floating array> reconstructed selected time ranges
;         result.out_num_pts_per_subwindow: <long> actual number of points per sub-time windows 
;                                           to be used for the calculation
;         result.out_num_bins_to_average: <long> actual number of bins to be averaged 
;                                         for the calculation
;         result.out_overlap: <floating> actual fraction of overlapping to be used for the calculation
;===================================================================================
; <Calculation procedure>
;  1. See my research note p.39 on 6th. May. 2011
;===================================================================================
function prep_to_perform_stat, in_data, in_time, in_dt, $
                               num_sel_time_range = in_num_sel_time_range, $
                               sel_time_range = in_sel_time_range, $
                               freq_filter = in_freq_filter, $
                               num_pts_per_subwindow = in_num_pts_per_subwindow, $
                               num_bins_to_average = in_num_bins_to_average, $
                               overlap = in_overlap, $
                               spectrogram = in_spectrogram, $
                               remove_large_structure = in_remove_large_structure, $
                               data_for_removal = in_data_for_removal, $
                               norm_by_DC = in_norm_by_DC, $
                               write_status = in_ID_msg_box_ON, $
                               ID_msg_box = ID_msg_box, $
                               spike_remover = in_spike_remover

; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}

; parameter check
  n_dim = size(in_data, /n_dim)
  dim = size(in_data, /dim)
  if n_dim ne 2 then begin
    result.erc = 301
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  nch = dim[0]
  ndata = dim[1]

  if( ndata ne n_elements(in_time) ) then begin
    result.erc = 301
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  if keyword_set(in_num_sel_time_range) then $
    num_sel_time_range = in_num_sel_time_range $
  else $
    num_sel_time_range = 0

  if keyword_set(in_sel_time_range) then begin
    sel_time_range = in_sel_time_range
  endif else begin
    sel_time_range = fltarr(1, 2)
  endelse

  if keyword_set(in_freq_filter) then begin
    perform_bpf = 1
    freq_filter = in_freq_filter
    if n_elements(freq_filter) ne 2 then begin
      result.erc = 301
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endif else begin
    perform_bpf = 0
  endelse

  if keyword_set(in_num_pts_per_subwindow) then $
    num_pts_per_subwindow = in_num_pts_per_subwindow $
  else $
    num_pts_per_subwindow = 16384l

  if keyword_set(in_num_bins_to_average) then $
    num_bins_to_average = in_num_bins_to_average $
  else $
    num_bins_to_average = 10l

  if keyword_set(in_overlap) then $
    overlap = in_overlap $
  else $
    overlap = 0.0

  if keyword_set(in_spectrogram) then $
    calc_spectrogram = 1 $	; prepare data for calculating spectrogram
  else $
    calc_spectrogram = 0	; prepare data for calculating spectrum

  if keyword_set(in_remove_large_structure) then begin
    remove_large_structure = 1
    data_for_removal = in_data_for_removal
  endif else $
    remove_large_structure = 0

  if keyword_set(in_norm_by_DC) then $
    norm_by_DC = 1 $
  else $
    norm_by_DC = 0

  if keyword_set(in_ID_msg_box_ON) then $
    write_status = 1 $
  else $
    write_status = 0

  if keyword_set(in_spike_remover) then $
     spike_remover = in_spike_remover $
  else $
    spike_remover = 0.0


; starting to prepare the signals for the calculation of spectrum of spectrogram
  if write_status then begin
    widget_control, ID_msg_box, set_value = '', /append
    msg_str = '<Preparing data for statistical analysis>'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

  if spike_remover gt 0.0 then begin
    if write_status then begin
      msg_str = '  Removing spikes with dV=' + string(spike_remover, format = '(f0.2)') + '...'
      widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
    endif
    for i = 0, nch - 1 do $
      in_data[i, *] = perform_spike_remover(in_data[i, *], spike_remover)
    if write_status then begin
      msg_str = 'DONE!'
      widget_control, ID_msg_box, set_value = msg_str, /append
    endif
  endif

  if remove_large_structure eq 1 then begin
    if write_status then begin
      msg_str = '  Removing Large Structures...'
      widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
    endif
    dim_data_for_removal = size(data_for_removal, /dim)
    avg_signal = total(data_for_removal, 1)/dim_data_for_removal[0]
    for i = 0, nch - 1 do $
      in_data[i, *] = in_data[i, *] - avg_signal
    if write_status then begin
      msg_str = 'DONE!'
      widget_control, ID_msg_box, set_value = msg_str, /append
    endif
  endif

; First, filter the signal
  if write_status then begin
    msg_str = '  Freq. Filtering signals...'
    widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
  endif

  if perform_bpf eq 1 then begin
    for i = 0, nch - 1 do begin
      filter_result = freq_filter_signal(reform(in_data[i, *]), freq_filter[0], freq_filter[1], in_dt)
      if i eq 0 then begin
        inx_nonzero_begin = filter_result.inx_nonzero_begin
        inx_nonzero_end = filter_result.inx_nonzero_end
        data = fltarr(nch, inx_nonzero_end - inx_nonzero_begin + 1)
        data_to_calc_DC = fltarr(nch, inx_nonzero_end - inx_nonzero_begin + 1)
        time = temporary(in_time[inx_nonzero_begin:inx_nonzero_end])
      endif
      data[i, *] = temporary(filter_result.filtered_signal[inx_nonzero_begin:inx_nonzero_end])
      data_to_calc_DC[i, *] = in_data[i, inx_nonzero_begin:inx_nonzero_end]
    endfor
  endif else begin
    time = in_time
    data = in_data
    data_to_calc_DC = in_data
  endelse

  if write_status then begin
    msg_str = 'DONE!'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

; Now, 1D arrays of time, and 2D array of data are ready.
  ndata = n_elements(time)
  tmin = time[0]
  tmax = time[ndata-1]

; check and recalculate the input parameters if necessary
  if write_status then begin
    msg_str = '  Check input parameters...'
    widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
  endif

; setting num_sel_time_range
  if ( (calc_spectrogram eq 1) or (num_sel_time_range eq 0) ) then begin
    num_sel_time_range = 1
    sel_time_range = fltarr(1, 2)
    sel_time_range[0, *] = [tmin, tmax]
  endif

  if size(sel_time_range, /n_dim) ne 2 then begin
    result.erc = 301
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  dim = size(sel_time_range, /dim)
  if dim[0] ne num_sel_time_range then begin
    result.erc = 301
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

; find indices for the sel_time_range
  inx_time_range = lonarr(num_sel_time_range, 2)
  for i = 0, num_sel_time_range - 1 do begin
    temp_trange = reform(sel_time_range[i, *])
  ; check the start time
    inx_start = where(time le temp_trange[0], count)
    if count le 0 then begin
    ; sel_time_range[i, 0] is smaller than tmin, thus correct sel_time_range[i, 0]
      inx_start = 0
      sel_time_range[i, 0] = time[inx_start]
    endif else if count ge ndata then begin
    ; sel_time_range[i, 0] is greater than tmax, thus this time range needs to be removed.
    ; set inx_start to -1, and remove time range where inx_start is less than 0 later.
      inx_start = -1
    endif else begin
      inx_start = inx_start[n_elements(inx_start)-1]
      sel_time_range[i, 0] = time[inx_start]
    endelse
  ; check the end time
    inx_end = where(time le temp_trange[1], count)
    if count le 0 then begin
    ; sel_time_range[i, 1] is smaller than tmin, thus time time range needs to be removed.
    ; set inx_end to -1, and remove time range wehre inx_end is less than 0 later.
      inx_end = -1
    endif else if count ge ndata then begin
    ; sel_time_range[i, 1] is greater than tmax, thus correct sel_time_range[i, 1]
      inx_end = ndata - 1
      sel_time_range[i, 1] = time[inx_end]
    endif else begin
      inx_end = inx_end[n_elements(inx_end)-1]
      sel_time_range[i, 1] = time[inx_end]
    endelse
  ; save the inx_start and inx_end
    inx_time_range[i, *] = [inx_start, inx_end]
  endfor
; find where inx_start or inx_end is less than 0
  valid_inx = 0
  count = 0
  for i = 0, num_sel_time_range - 1 do begin
    if ( (inx_time_range[i, 0] ge 0) and (inx_time_range[i, 1] ge 0) ) then begin
      valid_inx = [valid_inx, i]
      count = count + 1
    endif
  endfor
  if count lt 1 then begin
    if write_status then begin
      msg_str = 'FAILED!'
      widget_control, ID_msg_box, set_value = msg_str, /append
    endif
    result.erc = 303
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  valid_inx = valid_inx[1:n_elements(valid_inx)-1]
  num_sel_time_range = n_elements(valid_inx)
  sel_time_range = temporary(sel_time_range[valid_inx, *])
  inx_time_range = temporary(inx_time_range[valid_inx, *])

; sort the sel_time_range in ascending order
  inx_sort = sort(reform(sel_time_range[*, 0]))
  sel_time_range = sel_time_range[inx_sort, *]
  inx_time_range = inx_time_range[inx_sort, *]

; setting overlap
  if num_sel_time_range gt 1 then $
    overlap = 0.0

; check the number of data points in the shortest selected time-range window
  for i = 0, num_sel_time_range - 1 do begin
    if i eq 0 then begin
      min_ndata_per_subwindow = inx_time_range[i, 1] - inx_time_range[i, 0] + 1
    endif
    temp_min = inx_time_range[i, 1] - inx_time_range[i, 0] + 1
    min_ndata_per_subwindow = min_ndata_per_subwindow < temp_min
  endfor

; set the num_pts_per_subwindow
  num_pts_per_subwindow = num_pts_per_subwindow < min_ndata_per_subwindow

; calculate number of bins that can be fit into the selected time regions with the overlap fraction
  allowed_num_bins = 0l
  inx_subwindow = [0, 0]
  step_size = long(num_pts_per_subwindow * (1.0 - overlap))
  for i = 0, num_sel_time_range - 1 do begin
    temp_num_pts = inx_time_range[i, 1] - inx_time_range[i, 0] + 1
    inx_a = inx_time_range[i, 0]
    while ( (inx_a + num_pts_per_subwindow-1) le inx_time_range[i, 1] ) do begin
      allowed_num_bins = allowed_num_bins + 1
      temp_inx_subwindow = [inx_a, inx_a+num_pts_per_subwindow-1]
      inx_subwindow = [[inx_subwindow], [temp_inx_subwindow]]
      inx_a = inx_a + step_size
    endwhile
  endfor
  inx_subwindow = transpose(inx_subwindow)
  dim = size(inx_subwindow, /dim)
  inx_subwindow = inx_subwindow[1:dim[0]-1, *]

  if calc_spectrogram eq 0 then begin
    num_bins_to_average = allowed_num_bins
  endif else begin
    least_num_time_pts_for_spectrogram = 5
    if num_bins_to_average gt allowed_num_bins/least_num_time_pts_for_spectrogram then begin
      if write_status then begin
        msg_str = 'FAILED!'
        widget_control, ID_msg_box, set_value = msg_str, /append
      endif
      result.erc = 304
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

  if write_status then begin
    msg_str = 'DONE!'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

  if write_status then begin
    msg_str = '  Input parameters are set to as'
    widget_control, ID_msg_box, set_value = msg_str, /append
    msg_str = '    Overlap Fraction: ' + string(overlap, format='(f0.1)') + string(10b) + $
              '    # of pts per subwindow: ' + string(num_pts_per_subwindow, format='(i0)') + string(10b) + $
              '    # of bins for avg: ' + string(num_bins_to_average, format='(i0)') + string(10b) + $
              '    # of selected trange: ' + string(num_sel_time_range, format='(i0)')
    for i = 0, num_sel_time_range - 1 do begin
      msg_str = msg_str + string(10b) + '    ' + $
                string(i+1, format='(i2)') + ': [' + $
                string(sel_time_range[i, 0]*1e3, format='(f0.4)') + ', ' + $
                string(sel_time_range[i, 1]*1e3, format='(f0.4)') + '] msec'
    endfor
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

; create data array
  if write_status then begin
    msg_str = '  Creating data array for the calculation...'
    widget_control, ID_msg_box, set_value = msg_str, /append, /no_newline
  endif

  if num_sel_time_range gt 1 then begin
    out_data = fltarr(nch, num_bins_to_average*num_pts_per_subwindow)
    out_time = fltarr(num_bins_to_average*num_pts_per_subwindow)
    temp_DC = fltarr(nch)
    for i = 0l, num_bins_to_average - 1 do begin
      if norm_by_DC eq 1 then begin
        temp_DC[*] = total(data_to_calc_DC[*, inx_subwindow[i, 0]:inx_subwindow[i, 1]], 2)/(inx_subwindow[i, 1]-inx_subwindow[i, 0]+1)
      endif else begin
        temp_DC[*] = 1.0
      endelse
      for j = 0l, nch - 1 do $
        out_data[j, i*num_pts_per_subwindow:(i+1)*num_pts_per_subwindow-1] = data[j, inx_subwindow[i, 0]:inx_subwindow[i, 1]]/temp_DC[j]
      out_time[i*num_pts_per_subwindow:(i+1)*num_pts_per_subwindow-1] = time[inx_subwindow[i, 0]:inx_subwindow[i, 1]]
    endfor
  endif else begin
    temp_DC = fltarr(nch)
    if norm_by_DC eq 1 then begin
      temp_DC[*] = total(data_to_calc_DC[*, inx_time_range[0, 0]:inx_time_range[0, 1]], 2)/(inx_time_range[0, 1]-inx_time_range[0, 0]+1)
    endif else begin
      temp_DC[*] = 1.0
    endelse
    out_data = data[*, inx_time_range[0, 0]:inx_time_range[0, 1]]
    for j = 0l, nch - 1 do $
      out_data[j, *] = out_data[j, *]/temp_DC[j]
    out_time = time[inx_time_range[0, 0]:inx_time_range[0, 1]]
  endelse

  if write_status then begin
    msg_str = 'DONE!'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif

  end_time = systime(1)
  if write_status then begin
    msg_str = '  Elapsed time: ' + string(end_time - start_time, format='(f0.3)') + ' [sec].'
    widget_control, ID_msg_box, set_value = msg_str, /append
  endif


  result = create_struct(result, 'out_data', out_data, 'out_time', out_time, $
                                 'out_sel_time_range', sel_time_range, $
                                 'out_num_pts_per_subwindow', num_pts_per_subwindow, $
                                 'out_num_bins_to_average', num_bins_to_average, $
                                 'out_overlap', overlap)

  return, result

end


;==================================================================================
; This function performs FFT using IDL
; This is an IDL version of perform_cuda_fft.
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;   2) in_data1: <1D floating array> signal 1 to be FFTed.
;   3) in_data2: <1D floating array> signal 2 to be FFTed.
;   4) in_num_pts_per_subwindow: <long> contains the number points per sub-time window
;   5) in_num_bins_to_avg: <long> contains the number of bins to be averaged
;   6) in_overlap: <floating> contains a fraction to be overlapped between neighboring
;                             sub-time windows
;   7) in_use_hanning: <1 or 0> If 1, then apply hanning window on each sub-time window.
;                               If 0, then do not apply hanning window.
;   8) in_auto: <1 or 0> If 1, then auto-spectrum or auto-spectrogram
;                        If 0, then cross-spectrum or cross-spectrogram.
;   9) coh: <1 or 0> If this is 1, then calculate the coherency
;===================================================================================
; Return value:
;   1) result: <structure> : {erc, errmsg,
;              result.erc: <int> contains the error number
;              result.errmsg: <string> contains the error message
;              result.power: <1D (spectrum) or 2D (spectrogram) floating array> contains the power info
;              result.phase: <1D (spectrum) or 2D (spectrogram) floating array> contains the phase info
;              result.out_time_pts: <long> number of time points for the output.
;                                   For spectrum, this number should be 1.
;              result.out_total_num_bins: <long> total number of sub-time window that has been actually used
;                                                to perform FFT.
;                                                This number must be cross-checked.
;              result.out_num_fft_pts_per_subwindow: <long> contains the number of points in frequency domain
;                                                           per each time window.
;===================================================================================
function perform_idl_fft, info, $
                          in_data1, in_data2, in_num_pts_per_subwindow, in_num_bins_to_avg, $
                          in_overlap, in_use_hanning, in_auto, coh = coh

; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}

; retrieve the necessary data from info
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '', /append
    widget_control, widget_text_id, set_value = '<Performing FFT on IDL>', /append
  endif

; preparing FFT: check overlap and hanning window
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Preparing data...', /append, /no_newline
  endif

; calculate available number of subwindow
  ndata = long(n_elements(in_data1))
  available_num_bins = 0l
  inx_start = 0l
  f_step_size = in_num_pts_per_subwindow * (1.0 - in_overlap)
  step_size = long(f_step_size)
  repeat begin
    inx_start = available_num_bins * step_size
    available_num_bins = available_num_bins + 1
  endrep until ( (inx_start + in_num_pts_per_subwindow) gt ndata )
  available_num_bins = available_num_bins - 1

; reconstruct input data into 2D to make the calculation easier
  data1 = fltarr(available_num_bins, in_num_pts_per_subwindow)
  inx_start = 0l
  for i = 0l, available_num_bins - 1 do begin
    inx_start = i * step_size
    data1[i, *] = in_data1[inx_start:inx_start+in_num_pts_per_subwindow-1]
  endfor

  if in_auto ne 1 then begin
    data2 = fltarr(available_num_bins, in_num_pts_per_subwindow)
    inx_start = 0l
    for i = 0l, available_num_bins - 1 do begin
      inx_start = i * step_size
      data2[i, *] = in_data2[inx_start:inx_start+in_num_pts_per_subwindow-1]
    endfor
  endif


; perform hanning window if necessary
  if in_use_hanning eq 1 then begin
    han = hanning(in_num_pts_per_subwindow)
    for i = 0l, available_num_bins - 1 do begin
      data1[i, *] = reform(data1[i, *]) * han
    endfor
    if in_auto ne 1 then begin
      for i = 0l, available_num_bins - 1 do begin
        data2[i, *] = reform(data2[i, *]) * han
      endfor
    endif
  endif

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; perform FFT
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Performing FFT...', /append, /no_newline
  endif

  fft_data1 = fft(data1, dimension = 2)
  if in_auto eq 1 then $
    fft_data2 = fft_data1 $
  else $
    fft_data2 = fft(data2, dimension = 2)
  conj_fft_data2 = conj(fft_data2)

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; bin-averaging
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Bin-averaging...', /append, /no_newline
  endif  

  out_num_bins = long(available_num_bins/in_num_bins_to_avg)
  out_spec = complexarr(out_num_bins, in_num_pts_per_subwindow)
  temp_out_spec = fft_data1 * conj_fft_data2
  for i = 0l, out_num_bins - 1 do begin
    out_spec[i, *] = total(temp_out_spec[i*in_num_bins_to_avg:(i+1)*in_num_bins_to_avg-1, *], 1)/in_num_bins_to_avg
  endfor
  out_power = abs(out_spec)
  out_phase = atan(out_spec, /phase)

  if keyword_set(coh) then begin
    power1 = fltarr(out_num_bins, in_num_pts_per_subwindow)
    power2 = fltarr(out_num_bins, in_num_pts_per_subwindow)
    for i = 0l, out_num_bins - 1 do begin
      temp1 = reform(fft_data1[i*in_num_bins_to_avg:(i+1)*in_num_bins_to_avg-1, *])
      temp2 = reform(fft_data2[i*in_num_bins_to_avg:(i+1)*in_num_bins_to_avg-1, *])
      power1[i, *] = abs(total(temp1*conj(temp1), 1))/in_num_bins_to_avg
      power2[i, *] = abs(total(temp2*conj(temp2), 1))/in_num_bins_to_avg
    endfor
    power12 = out_power * out_power
    out_power = sqrt(power12/(power1*power2))
  endif

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

  out_time_pts = out_num_bins
  out_total_num_bins = available_num_bins
  out_num_fft_pts_per_subwindow = floor(in_num_pts_per_subwindow/2.0) + 1l
  power = out_power[*, 0l:out_num_fft_pts_per_subwindow-1]
  phase = out_phase[*, 0l:out_num_fft_pts_per_subwindow-1]

; print out some info
  if msg_box_on then begin
    msg_str = '    Number of time points: ' + string(out_time_pts, format='(i0)') + string(10b) + $
              '    Total number of created bin: ' + string(out_total_num_bins, format='(i0)') + string(10b) + $
              '    Number of points in freq. domain: ' + string(out_num_fft_pts_per_subwindow, format='(i0)')
    widget_control, widget_text_id, set_value = msg_str, /append
  endif

; construct result structure
  result = create_struct(result, 'out_time_pts', out_time_pts, $
                                 'out_total_num_bins', out_total_num_bins, $
                                 'out_num_fft_pts_per_subwindow', out_num_fft_pts_per_subwindow, $
                                 'power', power, $
                                 'phase', phase)


; end the timer
  end_time = systime(1)

  if msg_box_on then begin
    msg_str = '  Elapsed time: ' + string(end_time - start_time, format='(f0.3)') + ' [sec].'
    widget_control, widget_text_id, set_value = msg_str, /append
  endif

  return, result

end



;==================================================================================
; This function performs temporal correlation uinsg IDL routines.
; This is an IDL version of perform_cuda_temp_corr.
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;   2) in_data1: <1D floating array> signal 1 to be FFTed.
;   3) in_data2: <1D floating array> signal 2 to be FFTed.
;   4) in_num_pts_per_subwindow: <long> contains the number points per sub-time window
;   5) in_num_bins_to_avg: <long> contains the number of bins to be averaged
;   6) in_overlap: <floating> contains a fraction to be overlapped between neighboring
;                             sub-time windows
;   7) in_use_hanning: <1 or 0> If 1, then apply hanning window on each sub-time window.
;                               If 0, then do not apply hanning window.
;   8) cov: <1 or 0> If this is 1, then calculate the covariance (not normalized)
;===================================================================================
; Return value:
;   1) result: <structure> : {erc, errmsg,
;              result.erc: <int> contains the error number
;              result.errmsg: <string> contains the error message
;              result.corr: <1D (spectrum) or 2D (spectrogram) floating array> contains the temporal correlation
;              result.out_time_pts: <long> number of time points for the output.
;                                   For spectrum, this number should be 1.
;              result.out_total_num_bins: <long> total number of sub-time window that has been actually used
;                                                to perform temporal correlation.
;                                                This number must be cross-checked.
;              result.out_num_corr_pts_per_subwindow: <long> contains the number of points in time-delay domain
;                                                            per each time window.
;===================================================================================
function perform_idl_temp_corr, info, $
                                in_data1, in_data2, in_num_pts_per_subwindow, in_num_bins_to_avg, $
                                in_overlap, in_use_hanning, cov = cov


; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}
; keyword check
  if keyword_set(cov) then $
    cov = 1 $
  else $
    cov = 0

; retrieve the necessary data from info
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '', /append
    widget_control, widget_text_id, set_value = '<Performing temp. corr. on IDL>', /append
  endif

; preparing temporal correlation: check overlap and hanning window
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Preparing data...', /append, /no_newline
  endif

; calculate available number of subwindow
  ndata = long(n_elements(in_data1))
  available_num_bins = 0l
  inx_start = 0l
  f_step_size = in_num_pts_per_subwindow * (1.0 - in_overlap)
  step_size = long(f_step_size)
  repeat begin
    inx_start = available_num_bins * step_size
    available_num_bins = available_num_bins + 1
  endrep until ( (inx_start + in_num_pts_per_subwindow) gt ndata )
  available_num_bins = available_num_bins - 1

; reconstruct input data into 2D to make the calculation easier
  data1 = fltarr(available_num_bins, in_num_pts_per_subwindow)
  data2 = fltarr(available_num_bins, in_num_pts_per_subwindow)
  inx_start = 0l
  for i = 0l, available_num_bins - 1 do begin
    inx_start = i * step_size
    data1[i, *] = in_data1[inx_start:inx_start+in_num_pts_per_subwindow-1]
    data2[i, *] = in_data2[inx_start:inx_start+in_num_pts_per_subwindow-1]
  endfor

; perform hanning window if necessary
  if in_use_hanning eq 1 then begin
    han = hanning(in_num_pts_per_subwindow)
    for i = 0l, available_num_bins - 1 do begin
      data1[i, *] = reform(data1[i, *]) * han
      data2[i, *] = reform(data2[i, *]) * han
    endfor
  endif

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; Calculate temporal correlation
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Performing temp. corr...', /append, /no_newline
  endif

  lag_end = in_num_pts_per_subwindow - 1
  inx_lag = [lindgen(lag_end-1)-(lag_end-1), lindgen(lag_end)]
  temp_corr = fltarr(available_num_bins, n_elements(inx_lag))
  for i = 0l, available_num_bins - 1 do begin
    temp_data1 = reform(data1[i, *])
    temp_data2 = reform(data2[i, *])
    temp_corr[i, *] = yc_correlate(temp_data1, temp_data2, inx_lag, cov = cov)
  endfor

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; bin-averaging
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Bin-averaging...', /append, /no_newline
  endif  

  out_num_bins = long(available_num_bins/in_num_bins_to_avg)
  out_corr = fltarr(out_num_bins, n_elements(inx_lag))
  for i = 0l, out_num_bins - 1 do begin
    out_corr[i, *] = total(temp_corr[i*in_num_bins_to_avg:(i+1)*in_num_bins_to_avg-1, *], 1)/in_num_bins_to_avg
  endfor

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

  out_time_pts = out_num_bins
  out_total_num_bins = available_num_bins
  out_num_corr_pts_per_subwindow = n_elements(inx_lag)

; print out some info
  if msg_box_on then begin
    msg_str = '    Number of time points: ' + string(out_time_pts, format='(i0)') + string(10b) + $
              '    Total number of created bin: ' + string(out_total_num_bins, format='(i0)') + string(10b) + $
              '    Number of points tau domain: ' + string(out_num_corr_pts_per_subwindow, format='(i0)')
    widget_control, widget_text_id, set_value = msg_str, /append
  endif


; construct result structure
  result = create_struct(result, 'out_time_pts', out_time_pts, $
                                 'out_total_num_bins', out_total_num_bins, $
                                 'out_num_corr_pts_per_subwindow', out_num_corr_pts_per_subwindow, $
                                 'corr', out_corr)

; end the timer
  end_time = systime(1)

  if msg_box_on then begin
    msg_str = '  Elapsed time: ' + string(end_time - start_time, format='(f0.3)') + ' [sec].'
    widget_control, widget_text_id, set_value = msg_str, /append
  endif

  return, result

end




;==================================================================================
; This function performs temporal correlation uinsg IDL routines.
; This is an IDL version of perform_cuda_temp_corr.
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;   2) in_data: <2D floating array> signals to be correlated [nch, ntime]
;   3) in_dt: <floating> time resolution of in_data in [sec]
;   4) in_time: <1d floating array> time vector for in_data
;   5) signal_ch: <1D integer array> contains the channel numbers of BES for correlation
;   6) num_pts_per_subwindow: <long> contains the number points per sub-time window
;   7) num_bins_to_avg: <long> contains the number of bins to be averaged
;   8) overlap: <floating> contains a fraction to be overlapped between neighboring
;                          sub-time windows
;   9) use_hanning: <1 or 0> If 1, then apply hanning window on each sub-time window.
;                            If 0, then do not apply hanning window.
;  10) calc_covariance: <1 or 0> If this is 1, then calculate the covariance (not normalized)
;  11) calc_fcn_time: <1 or 0> if 1, then calcualte the correlation as a function of time as well.
;  12) calc_pol_spa: <1 or 0> If 1, then spatial direction is poloidal
;                             If 0, then spatial direction is radial
;  13) convert_temp_to_spa: <1 or 0> If 1, and in_calc_pol_spa = 1, then convert the time-delay to toroidal spatial direction
;  14) use_cxrs_data: <1 or 0> if 1, then uses CXRS v_tor data to convert time-delay to toroidal spatial direction
;  15) use_ss_cxrs: <1 or 0> if 1, then use SS CXRS data to convert time-delay to toroidal spatial direction
;                            if 0, htne use SW CXRS data to convert time-delay to toroidal spatial direction
;  16) manual_vtor: <floating> contains the toroidal velocity in [km/s].
;                              This is used to convert time-delay to spatial direction if in_use_cxrs_data = 0
;  17) factor_inc_spa_pts: <integer> contains the factor to increase the spatial (poloidal or radial) resolution
;  18) use_IDL_CUDA: <integer> if 1, then use IDL to calculat correlation
;                              if 2, then use CUDA to calculate correlation
;===================================================================================
; Return value:
;   1) result: <structure> : 
;              result.erc: <int> contains the error number
;              result.errmsg: <string> contains the error message
;              result.spa_temp_corr: <2D or 3D> correlation
;                                    1st dimension: x-axis: time-delay or converted spatial direction (toroidal direction)
;                                    2nd dimension: y-axis: poloidal or radial spatial direction
;                                    3rd dimension (only for 3D): t-axis: time 
;              result.tau_vector: <1D> x-axis
;              result.spa_vector: <1D> y-axis
;              result.time_vector: <1D> t-axis
;===================================================================================
function perform_spa_temp_corr, info, in_data, in_dt, in_time, signal_ch, $
                                num_pts_per_subwindow, num_bins_to_average, overlap, $
                                use_hanning, calc_covariance, calc_fcn_time, $
                                calc_pol_spa, convert_temp_to_spa, use_cxrs_data, $
                                use_ss_cxrs, manual_vtor, factor_inc_spa_pts, use_IDL_CUDA


; define the result structure
  result = {erc:0, $
            errmsg:''}

; retrieve the necessary data from info
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

; construct y-axis
  nch = n_elements(signal_ch)
  if calc_pol_spa eq 1 then begin
  ;spatial direction is poloidal
    position = fix((signal_ch-1)/8)
    inx_sort = sort(position)
    spa_vector = 0.02 * position[inx_sort]	;in [m]
  endif else begin
  ;spatial directio is radial
    position = fix((signal_ch-1) mod 8)
    inx_sort = reverse(sort(position))
    spa_vector = 0.02 * (7.0-position[inx_sort]) ;in [m]
  endelse

; calculate the spatio-temporal correlation
  in_data1 = reform(in_data[inx_sort[0], *])
  for i = 0, nch - 1 do begin
    if msg_box_on eq 1 then begin
      str = string(10b) + 'Temporal Correlation between Ch. ' + string(signal_ch[inx_sort[0]], format='(i0)') + ' and ' + $
            string(signal_ch[inx_sort[i]], format='(i0)') + '.'
      widget_control, widget_text_id, set_value = str, /append
    endif
    if i eq 0 then auto = 1 else auto = 0

    in_data2 = reform(in_data[inx_sort[i], *])
    if use_IDL_CUDA eq 2 then begin	;calculate using CUDA
      corr_result = perform_cuda_temp_corr(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                           overlap, use_hanning, auto, calc_covariance)
    endif else begin			;calculate using IDL
      corr_result = perform_idl_temp_corr(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                          overlap, use_hanning, cov = calc_covariance)
    endelse 

  ; check error during perform_idl_temp_corr
    if corr_result.erc ne 0 then begin
      result.erc = corr_result.erc
      result.errmsg = corr_result.errmsg
      return, result
    endif

  ; retrieve the output data
    corr = corr_result.corr
    if i eq 0 then begin
      tau_vector = (findgen(corr_result.out_num_corr_pts_per_subwindow) - long(corr_result.out_num_corr_pts_per_subwindow/2)) * $
                    in_dt * 1e6	;in [microsec]
      if calc_fcn_time eq 1 then begin
        t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
        t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
        time_vector = findgen(corr_result.out_time_pts) * t_step + t_start
      endif else begin
        time_vector = fltarr(1)
      endelse
      spa_temp_corr = fltarr(corr_result.out_num_corr_pts_per_subwindow, nch, corr_result.out_time_pts)
    endif

    for k = 0l, corr_result.out_time_pts - 1 do $
      spa_temp_corr[*, i, k] = corr_result.corr[k, *]

  endfor

; converting time-delay to toroidal direction
  if ( (convert_temp_to_spa eq 1) and (calc_pol_spa eq 1) ) then begin
  ; for now, use manual_vtor.
  ;  this needs to be changes later so that it can take CXRS data as well.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if msg_box_on eq 1 then begin
      str = string(10b) + '<Converting time-delay to toroidal direction>'
      widget_control, widget_text_id, set_value = str, /append
      str = '  Using CXRS data is not implemented.' + string(10b) + '  Manual v_tor will be used.' 
      widget_control, widget_text_id, set_value = str, /append
    endif

    tau_vector = tau_vector * manual_vtor * 1e-3	;in [m] toroidal direction
  endif

; increasing the spatial resolution
  if factor_inc_spa_pts gt 1 then begin
    if msg_box_on eq 1 then begin
      str = string(10b) + '<Increasing the spatial (' 
      if calc_pol_spa eq 1 then $
        str = str + 'poloidal)' $
      else $
        str = str + 'radial)'
      str = str + ' resolution>...'
      widget_control, widget_text_id, set_value = str, /append, /no_newline
    endif

    old_y = temporary(spa_vector)
    old_ny = n_elements(old_y)
    max_y = max(old_y, min=min_y, /nan)
    new_ny = old_ny * factor_inc_spa_pts 
    spa_vector = findgen(new_ny) * (max_y-min_y)/(new_ny-1) + min_y
    inx_y = (old_ny-1)/(max_y-min_y) * spa_vector - (old_ny-1)*min_y/(max_y-min_y)
    inx_x = lindgen(n_elements(tau_vector))

    new_spa_temp_corr = fltarr(n_elements(tau_vector), n_elements(spa_vector), n_elements(time_vector))
    for i = 0l, n_elements(time_vector)-1 do $
      new_spa_temp_corr[*, *, i] = interpolate(reform(spa_temp_corr[*, *, i]), inx_x, inx_y, /grid, cubic = -0.5)

    spa_temp_corr = temporary(new_spa_temp_corr)

    if msg_box_on eq 1 then begin
      widget_control, widget_text_id, set_value = 'DONE!', /append
    endif

  endif


  result = create_struct(result, 'spa_temp_corr', spa_temp_corr, $
                                 'tau_vector', tau_vector, $
                                 'spa_vector', spa_vector, $
                                 'time_vector', time_vector)


  return, result

end


;==================================================================================
; This function performs spatio-spatio correlation uinsg IDL routines.
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;   2) in_data: <2D floating array> signals to be correlated [nch, ntime]
;   3) in_dt: <floating> time resolution of in_data in [sec]
;   4) in_time: <1d floating array> time vector for in_data
;   5) ref_signal_ch: <integer> contains the reference channel number of BES (base 1-index system)
;                     If this is set to 0, then spatial averaging is performed.
;   6) num_pts_per_subwindow: <long> contains the number points per sub-time window
;   7) num_bins_to_avg: <long> contains the number of bins to be averaged
;   8) overlap: <floating> contains a fraction to be overlapped between neighboring
;                          sub-time windows
;   9) use_hanning: <1 or 0> If 1, then apply hanning window on each sub-time window.
;                            If 0, then do not apply hanning window.
;  10) calc_covariance: <1 or 0> If this is 1, then calculate the covariance (not normalized)
;  11) compare_coarr: <1 or 0> If this is 1, then compares coarrays.
;  12) use_IDL_CUDA: <integer> if 1, then use IDL to calculat correlation
;                              if 2, then use CUDA to calculate correlation
;===================================================================================
; Return value:
;   1) result: <structure> : 
;              result.erc: <int> contains the error number
;              result.errmsg: <string> contains the error message
;              result.spa_spa_corr: <3D> correlation
;                                    1st dimension: x-axis: del_R in [cm]
;                                    2nd dimension: y-axis: del_Z in [cm]
;                                    3rd dimension: t-axis: time-delay
;              result.xvector: <1D> x-axis
;              result.yvector: <1D> t-axis
;              result.tauvector: <1D> time delay-axis
;===================================================================================
function perform_spa_spa_corr,  info, in_data, in_dt, in_time, ref_signal_ch, $
                                num_pts_per_subwindow, num_bins_to_average, overlap, $
                                use_hanning, calc_covariance, compare_coarr, use_IDL_CUDA

; define the result structure
  result = {erc:0, $
            errmsg:''}

; retrieve the necessary data from info
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

; check whether to perform spatial averaging or not
  if ref_signal_ch eq 0 then $
    spatial_avg = 1 $
  else $
    spatial_avg = 0

; Setting the number of BES channels
  nR_BES = 8
  nZ_BES = 4
  nRZ_BES = nR_BES * nZ_BES
  nxvector = nR_BES * 2 - 1
  nyvector = nZ_BES * 2 - 1
  xvector = (findgen(nxvector) - fix(nxvector/2.0)) * 2.0
  yvector = (findgen(nyvector) - fix(nyvector/2.0)) * 2.0

; perform temporal correlation
  if spatial_avg eq 1 then $
    nloop = 32 $
  else $
    nloop = 1

  for i = 0, nloop - 1 do begin
    if spatial_avg eq 1 then inx_ref_ch = i else inx_ref_ch = ref_signal_ch - 1
    in_data1 = reform(in_data[inx_ref_ch, *])
    for j = 0, nRZ_BES - 1 do begin 
    ; show message box
      if msg_box_on eq 1 then begin
        str = string(10b) + 'Calculating correlation between Ch. ' + string(inx_ref_ch+1, format='(i0)') + ' and ' + $
              string(j+1, format='(i0)') + '.'
        widget_control, widget_text_id, set_value = str, /append
      endif
    ; set auto
      if inx_ref_ch eq j then auto = 1 else auto = 0
    ; get in_data2
      in_data2 = reform(in_data[j, *])
    ; calculate correlation
      if use_IDL_CUDA eq 2 then begin	;calculate using CUDA
        corr_result = perform_cuda_temp_corr(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                             overlap, use_hanning, auto, calc_covariance)
      endif else begin			;calculate using IDL
        corr_result = perform_idl_temp_corr(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                            overlap, use_hanning, cov = calc_covariance)
      endelse

    ; check error during perform_idl_temp_corr
      if corr_result.erc ne 0 then begin
        result.erc = corr_result.erc
        result.errmsg = corr_result.errmsg
        return, result
      endif

    ; retrieve the output data
      corr = corr_result.corr
      if ( (i eq 0) and (j eq 0) ) then begin
        tauvector = (findgen(corr_result.out_num_corr_pts_per_subwindow) - long(corr_result.out_num_corr_pts_per_subwindow/2)) * $
                    in_dt * 1e6	;in [microsec]
        spa_spa_corr = fltarr(nloop, nxvector, nyvector, n_elements(tauvector))
        num_pts = lonarr(nxvector, nyvector)
        num_pts[*, *] = 0l
      endif

    ; Find correct x and y positions with respect to the inx_ref_ch.
    ; ref_ch sits always in the ceter of the x and y positions.
      inx_centre_xpos = (nxvector - 1) / 2
      inx_centre_ypos = (nyvector - 1) / 2
      offset_xpos = (inx_ref_ch mod nR_BES) - (j mod nR_BES)
      offset_ypos = (j / nR_BES) - (inx_ref_ch / nR_BES)
    ; save the correlation result to spa_spa_corr
      spa_spa_corr[i, inx_centre_xpos + offset_xpos, inx_centre_ypos + offset_ypos, *] = corr[0, *]
      num_pts[inx_centre_xpos + offset_xpos, inx_centre_ypos + offset_ypos] += 1

    endfor
  endfor

; if compare_coarr is set, then compare the coarrays at tauvector = 0.0 microsecond
  if compare_coarr eq 1 then begin
    inx_tau = where(tauvector ge 0.0) 
    inx_tau = inx_tau[0]
    inx_centre_ypos = (nyvector - 1) / 2
    inx_centre_xpos = (nxvector - 1) / 2
    for i = 0, nRZ_BES - 1 do begin
      xrange = [inx_centre_xpos - (nR_BES-1) + (i mod nR_BES), inx_centre_xpos + (i mod nR_BES)]
      if (i mod 8) eq 0 then begin
        if calc_covariance eq 1 then ytitle = 'Covariance' else ytitle = 'Correlation'
        ycplot, xvector[xrange[0]:xrange[1]], reform(spa_spa_corr[i, xrange[0]:xrange[1], inx_centre_ypos, inx_tau]), out_base_id = oplotid, $
                title = 'Coarray Comparison at Row: ' + string( (i/nR_BES) + 1, format='(i0)'), $
                xtitle = '!7D!3R [cm]', ytitle = ytitle, legend_item = 'Ref. Column Pos: ' + string((i mod nR_BES) + 1, format='(i0)')
      endif else begin
        ycplot, xvector[xrange[0]:xrange[1]], reform(spa_spa_corr[i, xrange[0]:xrange[1], inx_centre_ypos, inx_tau]), oplot_id = oplotid, $
                legend_item = 'Ref. Column Pos: ' + string((i mod nR_BES) + 1, format='(i0)')
      endelse
    endfor
  endif


; spatial averaging
  if spatial_avg eq 1 then begin
    if msg_box_on eq 1 then begin
      str = string(10b) + 'Averaging the spatial correlation...'
      widget_control, widget_text_id, set_value = str, /append, /no_newline
    endif

    avg_spa_spa_corr = fltarr(nxvector, nyvector, n_elements(tauvector))
    avg_spa_spa_corr = total(spa_spa_corr, 1)
    for i = 0, nxvector - 1 do begin
      for j = 0, nyvector - 1 do begin
        if num_pts[i, j] ne 0.0 then $
          avg_spa_spa_corr[i, j, *] = avg_spa_spa_corr[i, j, *]/num_pts[i, j]
      endfor
    endfor
    spa_spa_corr = temporary(avg_spa_spa_corr)

    if msg_box_on eq 1 then begin
      widget_control, widget_text_id, set_value = 'DONE!', /append
    endif
  endif
  spa_spa_corr = reform(spa_spa_corr)


  result = create_struct(result, 'spa_spa_corr', spa_spa_corr, $
                                 'xvector', xvector, $
                                 'yvector', yvector, $
                                 'tauvector', tauvector)

  return, result

end


;==================================================================================
; This function performs to calculate the time evolution of velocity in IDL
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;   2) spa_temp_data: <3D floating array>
;                     1st dim: time-delay
;                     2nd dim: spatial displacement
;                     3rd dim: time flow
;   3) tau_vector: <1D floating array> vector array for time-delay in [micro-sec]
;   4) spa_vector: <1D floating array> vector array for spatial displacement in [m]
;   5) time_vector: <1D floating array> vector array for time evolution in [sec]
;   6) apply_median_filter: <1 or 0> If 1, then apply median filter so that salt-papper filtering is performed.
;   7) median_filter_width: <long> the width of median filter
;   8) apply_field_method: <1 or 0> If 1, then applies filtering algorithm Dr. Field suggested.
;   9) num_time_pts_field_method: <long> number of time points to calculate running mean and standard deviation for field_method
;  10) allowed_mult_sd: <float> allowed multiple of standard deviation for field_method
;===================================================================================
; Return value:
;   1) result: <structure> : 
;              result.erc: <int> contains the error number
;              result.errmsg: <string> contains the error message
;              result.vel: <1D array> velocity
;              result.vel_err: <2D array> error bar for velocity
;                              [0, n_elements(time)] --> upper err bar
;                              [1, n_elements(time)] --> lower err bar
;              result.time: <1D array> time vector for velocity
;===================================================================================
function perform_vel_time_evol, info, spa_temp_data, tau_vector, spa_vector, time_vector, apply_median_filter, median_filter_width, $
                                apply_field_method, num_time_pts_field_method, allowed_mult_sd

; define the result structure
  result = {erc:0, $
            errmsg:''}

; check parameters
  dim = size(spa_temp_data, /dim)
  if n_elements(dim) ne 3 then begin
    result.erc = 453
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  if ( (dim[0] ne n_elements(tau_vector)) or (dim[1] ne n_elements(spa_vector)) or (dim[2] ne n_elements(time_vector)) ) then begin
    result.erc = 453
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

  if dim[2] lt 2 then begin
    result.erc = 454
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

; retrieve the necessary data from info
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

  if msg_box_on eq 1 then begin
    str = string(10b) + '<Calculating pattern velocity from spatio-temp corr.>' + string(10b) + '  '
    widget_control, widget_text_id, set_value = str, /append, /no_newline
  endif

  ntime = n_elements(time_vector)
  nspa = n_elements(spa_vector)
  perc_chk_point = long(ntime/10)
  curr_perc = 1
; calculate the pattern velocity
;  This is how the velocity is found at each time for each spatial displacement
;  1. Find the global maximum of correlation function.
;     Set this correlation value to be corr2, and the time-delay at this point is tau2
;  2. Find the next largest value from the time-delay less than tau2
;     Set this correlation value to be corr1, and the time-delay at this point is tau1
;  3. Find the next largest value from the time-delay greater than tau2
;     Set this correlation value to be corr3, and the time-delay at this point is tau3
;  4. Fit 2nd order polynomial using [tau1, corr1], [tau2, corr2], and [tau3, corr3].
;  5. Find the global maximum frmo this fitted 2nd order polynomial.
;     Set the time-delay to be tau_max.
;  6. Fit a linear line spatial_disaplcement vs. tau_max
;  7. The slope is the pattern velocity.
;  8. If the slope comes out to be NaN, then force the velocity to be 0.0 km/s.
  velocity = fltarr(ntime)
  vel_err = fltarr(2, ntime)
  for i = 0l, ntime - 1 do begin
    tau_max = fltarr(nspa)
    tau_max[0] = 0.0	;The autocorrelation has a peak at time-delay = 0.0 always.
    for j = 1l, nspa - 1 do begin
      temp_data = reform(spa_temp_data[*, j, i])
    ; first, find the global maximum
      corr2 = max(temp_data, inx2)
      tau2 = tau_vector[inx2]
      if ( (inx2 lt 3) or (inx2 gt (n_elements(temp_data)-3)) ) then begin
;        if msg_box_on eq 1 then begin
;          widget_control, widget_text_id, set_value = 'FAILED!', /append
;        endif
;        result.erc = 455
;        result.errmsg = bes_analyser_error_list(result.erc)
;        return, result
        tau_max[j] = 0.0
      endif else begin
      ; second, find the next largest value from time-delay less than tau2
;        corr1 = max(temp_data[0:inx2-1], inx1)
;        tau1 = tau_vector[inx1]
        tau1 = tau_vector[inx2-1]
        corr1 = temp_data[inx2-1]
      ; third, find the next largest value from time-delay greater than tau2
;        corr3 = max(temp_data[inx2+1:n_elements(temp_data)-1], inx3)
;        tau3 = tau_vector[inx3 + inx2 + 1]
        tau3 = tau_vector[inx2+1]
        corr3 = temp_data[inx2+1]
      ; using these three points, fit a 2nd order polynomial, and find the tau_max.
      ; Fitting to y = ax^2 + bx + c
        a = 1.0/(tau2 - tau3) * ( (corr1-corr2)/(tau1-tau2) - (corr1-corr3)/(tau1-tau3) )
        b = (corr1-corr2)/(tau1-tau2) - a*(tau1+tau2)
        c = corr1 - a*tau1^2 - b*tau1
      ; The points we are after is where dy/dx = 0.
      ; dy/dx = 2ax + b = 0  --> x = -b/2a
        tau_max[j] = -b/(2*a)
      endelse
    endfor

  ;now, fit a linear line on spa_vector vx. tau_max
    spa_disp = spa_vector * 1e3	;converting from m to mm.
    lin_fit_result = linfit(tau_max, spa_disp, sigma = s)
    if finite(lin_fit_result[1]) ne 1 then begin
      velocity[i] = 0.0
      vel_err[*, i] = 0.0
    endif else begin
      velocity[i] = lin_fit_result[1]
      vel_err[*, i] = s[1]
    endelse

    if msg_box_on eq 1 then begin
      if i ge curr_perc * perc_chk_point then begin
        str = string(curr_perc*10, format='(i0)') + '% '
        widget_control, widget_text_id, set_value = str, /append, /no_newline 
        curr_perc = curr_perc + 1
      endif
    endif

  endfor

  if msg_box_on eq 1 then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; apply median filter for salt-pepper filtering
  if apply_median_filter eq 1 then begin
    if msg_box_on eq 1 then begin
      widget_control, widget_text_id, set_value = '  Applying median filter...', /append, /no_newline
    endif
    velocity_median_filter = median(velocity, median_filter_width, /even)
    if msg_box_on eq 1 then begin
      widget_control, widget_text_id, set_value = 'DONE!', /append
    endif
  ;apply Dr. Field's filtering algorithm
    if apply_field_method eq 1 then begin
    ; Algorithm:
    ; 1. Calculate the running mean and standard deviation of velocity_median_filter with num_time_pts_field_method time interval
    ;       Mean = vel_mean(t)
    ;       Standard Deviaction = vel_sd(t)
    ; 2. Calculate velocity_diff(t) = velocity(t) - velocity_median_filter(t)
    ; 3. Calculate filtered velocity = velocity_new(t)
    ;      velocity_new(t) = vel_mean(t) if velocity_diff(t) > allowed_mult_sd * vel_sd(t)
    ;                      = velocity(t) otherwise
    ;
    ;
    ; Now, calcualte the vel_mean(t) and vel_sd(t) of velocity_median_filter(t)
      npts = n_elements(velocity_median_filter)
      if npts le num_time_pts_field_method then begin
        velocity = temporary(velocity_median_filter)
      endif else begin
        if msg_box_on eq 1 then begin
          widget_control, widget_text_id, set_value = '  Applying Field''s Method to filter...', /append, /no_newline
        endif
        velocity_diff = velocity - velocity_median_filter
        velocity_new = velocity
        inx_start = long((num_time_pts_field_method-1)/2)
        inx_end = long(npts - (num_time_pts_field_method+1)/2)
        for i = inx_start, inx_end do begin
          vel_mean = total(velocity_median_filter[i-(num_time_pts_field_method-1)/2:i+(num_time_pts_field_method-1)/2])/num_time_pts_field_method
          vel_sd = stddev(velocity_median_filter[i-(num_time_pts_field_method-1)/2:i+(num_time_pts_field_method-1)/2])
          if abs(velocity_diff[i]) gt abs(allowed_mult_sd * vel_sd) then begin
            velocity_new[i] = vel_mean
          endif
        endfor
        velocity = velocity_new
        if msg_box_on eq 1 then begin
          widget_control, widget_text_id, set_value = 'DONE!', /append
        endif
      endelse
    endif else begin
      velocity = temporary(velocity_median_filter)
    endelse
  endif


  result = create_struct(result, 'vel', velocity, $
                                 'vel_err', vel_err, $
                                 'time', time_vector)

  return, result

end




