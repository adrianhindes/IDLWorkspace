

;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_comm_quit function                                                *
;*----------------------------------------------------------------------------*
;* send COMM_QUIT command to the server                                       *
;* Return:                                                                    *
;    0 if successful                                                          *
;*   error number if not (see client_error.pro)                               *
;******************************************************************************
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 11. Dec. 2010                                                *
;******************************************************************************

function client_comm_quit, pipes, COMM_QUIT

;send the COMM_QUIT command to the server
  client_put_data, pipes, COMM_QUIT, error = error
  if error ne 0 then return, error ;if an error occurs during the communication, returns the error number

  close, pipes.unit_r & free_lun, pipes.unit_r
  close, pipes.unit_w & free_lun, pipes.unit_w

  return, 0

end



;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_comm_test function                                                *
;*----------------------------------------------------------------------------*
;* Testing connections between the server and client                          *
;* Return:                                                                    *
;    0 if successful                                                          *
;*   error number if not (see client_error.pro)                               *
;*                                                                            *
;* Testing procedure                                                          *
;*  Send 'ping' to the server, then receive 'pong'                            *
;******************************************************************************
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 11. Dec. 2010                                                *
;******************************************************************************

function client_comm_test, pipes, COMM_TEST, widget_text_id

  if n_params() eq 3  then begin
    widget_control, widget_text_id, set_value = '', /append
    widget_control, widget_text_id, set_value = 'Communication test starts...', /append, /no_newline
  endif else begin
    print, ''
    print, 'Communication test starts...', format='(A,$)'
  endelse

; send the COMM_TEST command to the server
  client_put_data, pipes, COMM_TEST, error = error
  if error ne 0 then return, error

; send 'ping' to the server
  client_put_data, pipes, 'ping', error = error
  if error ne 0 then return, error

; receive 'pong' from the server
  received_str = ''
  client_get_data, pipes, 'string', received_str, error = error
  if error ne 0 then return, error

; check if received_str is really 'pong'
  if received_str ne 'pong' then begin
    error = 14
    if n_params() eq 3  then begin
      widget_control, widget_text_id, set_value = 'Failed.', /append
      widget_control, widget_text_id, set_value = 'Received characters are ' + received_str + ' while expecting pong', /append
    endif else begin
      print, 'Failed.'
      print, 'Received characters are ' + received_str + ' while expecting pong'
    endelse
    return, error
  endif

  if n_params() eq 3  then begin
    widget_control, widget_text_id, set_value = 'Successful!', /append
  endif else begin
    print, 'Successful!'
  endelse
 
  return, 0

end



;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_comm_chk_rate function                                            *
;*----------------------------------------------------------------------------*
;* Testing floating data transfer rate between the server and client          *
;* Return:                                                                    *
;    0 if successful                                                          *
;*   error number if not (see client_error.pro)                               *
;*                                                                            *
;******************************************************************************
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 11. Dec. 2010                                                *
;******************************************************************************

function client_comm_chk_rate, pipes, COMM_CHK_RATE, widget_text_id, num_data

  if n_params() eq 4 then begin
    widget_control, widget_text_id, set_value = '', /append
    widget_control, widget_text_id, set_value = 'Data Transfer Rate Check starts...', /append, /no_newline
  endif else begin
    print, ''
    print, 'Data Transfer Rate check starts...', format = '(A,$)'
  endelse

  if n_params() eq 4 then begin
    ndata = long(num_data)
  endif else begin
    ndata = long(0)
    read, 'Enter the number of data to send to the server: ', ndata
    ndata = long(ndata)
  endelse

; send the COMM_CHK_RATE command to the server
  client_put_data, pipes, COMM_CHK_RATE, error = error
  if error ne 0 then return, error

; send ndata to the server
  client_put_data, pipes, ndata, error = error
  if error ne 0 then return, error

; create the random data to send
  data = randomn(seed, ndata)

; timing starts
  start_t = systime(1, /seconds)

; send the data to the server
  client_put_data, pipes, data, error = error
  if error ne 0 then return, error

; received the data back from the server
  r_data = fltarr(ndata)
  client_get_data, pipes, 'float', r_data, error = error
  if error ne 0 then return, error

; timing ends.
  end_t = systime(1, /seconds)

  if n_params() eq 4 then $
    widget_control, widget_text_id, set_value = 'Done!', /append $
  else $
    print, 'Done!'


; check whether the send and received data are the same
  if array_equal(data, r_data) eq 1 then begin
    if n_params() eq 4 then $
      widget_control, widget_text_id, set_value = 'Data are NOT corrupted.', /append $
    else $
      print, 'Data are NOT corrupted.'
  endif else begin
    if n_params() eq 4 then $
      widget_control, widget_text_id, set_value = 'Data are corrupted. (may be due to numerical error!)', /append $
    else $
      print, 'Data are corrupted. (Corruption maybe due to numerical error!)'
  endelse

; print the time elapsed
  elap_t = end_t - start_t
  str1 = 'Total time it took to transfer ' + string(ndata, format='(i0)') + ' floating data is: ' + $
          strcompress(string(elap_t), /remove_all) + ' seconds'
  str2 = 'Data trasfer rate is ' + strcompress(string(elap_t / ndata), /remove_all) + ' seconds per floating-data'
  if n_params() eq 4 then begin
    widget_control, widget_text_id, set_value = str1, /append
    widget_control, widget_text_id, set_value = str2, /append
  endif else begin
    print, str1
    print, str2
  endelse

  return, 0

end




;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_comm_cuda_corr function                                           *
;*----------------------------------------------------------------------------*
;* Performing correlation                                                     *
;* Return: structure: rs={error, data}                                        *
;*   rs.error = 0 if successful                                               *
;*            = error number if not (see client_error.pro)                    *
;*                                                                            *
;*   rs.data = output data                                                    *
;******************************************************************************
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 28. Jan. 2011                                                *
;******************************************************************************

;unlike other functions, this function only works with IDL widget program.
function client_comm_cuda_corr, pipes, data, COMM_CUDA_CORR, widget_text_id, option_data

  rs = {error:0}

  if n_params() ne 5 then begin
    rs.error = 8
    return, rs
  endif

;Note: structure of option_data
;  option_data.dt: <floating point number>
;                  time step of the signal
;  option_data.auto: <1 or 0>
;                    if 1 then auto-correlation, if 0 then cross-correlation
;  option_data.covariance: <1 or 0>
;                          if 1 then covariance, if 0 then correlation (normalized)
;
;  option_data.ref_ch: <1-d array integer>
;                      contains the channel indices for reference signal (base 1 array)
;  option_data.plot_ch: <1-d array integer>
;                      contains the channel indices for plot signal (base 1 array)
;  option_data.overlap: <from 0.0 to 1.0>
;                       overlap fraction for sub-time_windows
;  option_data.use_han: <0 or 1>
;                       if 0 then do not use hanning window, if 1 then use hanning window for each sub-time_windows
;  option_data.corr_sub_twindow: <long integer number>
;                                  number of time points for each sub-time_window
;                                  this value determines the size of each sub-time window and maximum possible time-delay for correlation calculation
;  option_data.corr_num_bins_avg: <long integer numbers> 
;                                 number of bins (sub-time_windows) to be averaged over
;                                 If this number is set to 0, then uses all the available sub-time_windows for averaging.  Thus, no time trace available.
;                                 this number plays a role to determine time resolution and noise level.
;
;


; get the number of time-points and spatial points
  ndim = size(data, /n_dim)
  data_dim = size(data, /dim)
  ntime = long(data_dim[0])	;total number of time points
  if ndim eq 1 then $		;total number of spatial points
    nch = 1 $
  else $
    nch = data_dim[1]

; time step
  dt = option_data.dt

; check whether to perform auto- or cross-correlation
  if option_data.auto eq 1 then $
    autocorr = long(1) $		;perform auto-correlation
  else $
    autocorr = long(0)			;perform cross-correlation

; check whether to perform correlation (normalized) or covariance
  if option_data.covariance eq 1 then $
    covariance = long(1) $
  else $
    covariance = long(0)

; check which channels would be used for calculation
  inx_ref_ch = option_data.ref_ch - 1
  inx_plot_ch = option_data.plot_ch - 1
  if autocorr eq 1 then begin
    num_calc_repeat = n_elements(inx_ref_ch)
  endif else begin
    num_calc_repeat = n_elements(inx_plot_ch)
  endelse


; other information: overlap, use_han, sub_twindow, num_bins_avg
  overlap = option_data.overlap
  use_han = long(option_data.use_han)
  sub_twindow = long(option_data.corr_sub_twindow)
  num_bins_avg = long(option_data.corr_num_bins_avg)

; peform correlation using CUDA for each channel
  c_start = systime(1, /second)
  for i = 0, num_calc_repeat - 1 do begin
    if autocorr eq 1 then begin
      str = 'Performing auto-correlation for Ch. ' + strcompress(string(inx_ref_ch[i]+1), /remove_all)
      widget_control, widget_text_id, set_value = '', /append
      widget_control, widget_text_id, set_value = str, /append
    endif else begin
      str = 'Performing cross-correlation for Ch. ' + strcompress(string(inx_ref_ch[i]+1), /remove_all) + ' and ' + $
                                                      strcompress(string(inx_plot_ch[i]+1), /remove_all)
      widget_control, widget_text_id, set_value = '', /append
      widget_control, widget_text_id, set_value = str, /append
    endelse

  ;sending data to CUDA
    widget_control, widget_text_id, set_value = '  Sending Data...', /append, /no_newline

  ;send the command
    client_put_data, pipes, COMM_CUDA_CORR, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send the ndata
    client_put_data, pipes, ntime, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send sub_twindow
    client_put_data, pipes, sub_twindow, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send overlap
    client_put_data, pipes, overlap, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send use_han
    client_put_data, pipes, use_han, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send num_bins_avg
    client_put_data, pipes, num_bins_avg, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send covariance
    client_put_data, pipes, covariance, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send autocorr
    client_put_data, pipes, autocorr, error = error
    rs.error = error
    if rs.error ne 0 then return, rs

  ;send the data
    input = reform(data[*, inx_ref_ch[i]])
    client_put_data, pipes, input, error = error
    rs.error = error
    if rs.error ne 0 then return, rs
    if autocorr ne 1 then begin	;cross-correlation.  Thus, send anothe data set to CUDA
      input = reform(data[*, inx_plot_ch[i]])
      client_put_data, pipes, input, error = error
      rs.error = error
      if rs.error ne 0 then return, rs
    endif

  ;finished sending input data to CUDA
    widget_control, widget_text_id, set_value = 'DONE!', /append

  ; Now, by this time, GPU is performing computations..
    widget_control, widget_text_id, set_value = '  GPU is performing correlation...', /append, /no_newline

  ; Receive the result of correlation
    client_get_data, pipes, 'long', output_result, error = error
    widget_control, widget_text_id, set_value = 'DONE!', /append
    rs.error = error
    if rs.error ne 0 then return, rs
    if output_result ne 1 then begin
      rs.error = 16
      return, rs
    endif

  ; Receive the output data from the server
    widget_control, widget_text_id, set_value = '  Receiving Data...', /append, /no_newline

  ;receive num_bins_out: number of bins for output (after bin-averagin)
    if i eq 0 then output_num_bins = lonarr(num_calc_repeat)
    temp_num_bins = long(0)
    client_get_data, pipes, 'long', temp_num_bins, error = error
    rs.error = error
    if rs.error ne 0 then return, rs
    output_num_bins[i] = temp_num_bins

  ;receive the total number of bins before bin-averaging
    if i eq 0 then output_total_num_bins = lonarr(num_calc_repeat)
    temp_total_num_bins = long(0)
    client_get_data, pipes, 'long', temp_total_num_bins, error = error
    rs.error = error
    if rs.error ne 0 then return, rs
    output_total_num_bins[i] = temp_total_num_bins

  ;receive the number of points per bin
    if i eq 0 then output_num_pts_per_window = lonarr(num_calc_repeat)
    temp_output_num_pts_per_window = long(0)
    client_get_data, pipes, 'long', temp_output_num_pts_per_window, error = error
    rs.error = error
    if rs.error ne 0 then return, rs
    output_num_pts_per_window[i] = temp_output_num_pts_per_window

  ;receive the output data
    if i eq 0 then output_data = fltarr(num_calc_repeat, output_num_bins[0], output_num_pts_per_window[0])
    temp_output_data = fltarr(output_num_bins[i] * output_num_pts_per_window[i])
    client_get_data, pipes, 'float', temp_output_data, error = error
    rs.error = error
    if rs.error ne 0 then return, rs
    for k = 0l, output_num_bins[i] - 1 do begin
      output_data[i, k, *] = temp_output_data[(k+0)*output_num_pts_per_window[i]: $
                                              (k+1)*output_num_pts_per_window[i]-1]
    endfor

    widget_control, widget_text_id, set_value = 'DONE!', /append 

  endfor
  c_end = systime(1, /second)

; construct time domain
  t_start = dt * sub_twindow/2
  t_step = dt * sub_twindow * (1.0 - overlap) * num_bins_avg
  t_arr = findgen(output_num_bins[0]) * t_step + t_start

; construct tau (time-lag) domain
  tau_arr = findgen(output_num_pts_per_window[0]) - fix(output_num_pts_per_window[0]/2)
  tau_arr = tau_arr * dt * 1e6		;time delay in micro-seconds

; checking with IDL routines
;  CHK_WITH_IDL = 0
;  idl_start = systime(1, /second)
;  if (CHK_WITH_IDL eq 1) then begin
;    for i = 0, num_calc_repeat - 1 do begin
;      d1 = reform(data[*, inx_ref_ch[i]])
;      if autocorr ne 1 then d2 = reform(data[*, inx_plot_ch[i]])
;
;      if autocorr eq 1 then begin
;        result = turb_calc_corr(d1, d1, dt, autocorr = autocorr, sub_twindow = sub_twindow, overlap = overlap, hanwindow = use_han, $
;                                num_bins_avg = num_bins_avg, covariance = covariance, $
;                                out_taxis = idl_temp_taxis, out_tau_axis = idl_temp_tau_axis, out_data = idl_temp_data) 
;      endif else begin
;        result = turb_calc_corr(d1, d2, dt, autocorr = 0, sub_twindow = sub_twindow, overlap = overlap, hanwindow = use_han, $
;                                num_bins_avg = num_bins_avg, covariance = covariance, $
;                                out_taxis = idl_temp_taxis, out_tau_axis = idl_temp_tau_axis, out_data = idl_temp_data) 
;      endelse
;      if i eq 0 then begin
;        idl_taxis = idl_temp_taxis
;        idl_tau_axis = idl_temp_tau_axis
;        dim = size(idl_temp_data, /dim)
;        idl_data_out = fltarr(num_calc_repeat, dim[0], dim[1]) 
;      endif
;      idl_data_out[i, *, *] = idl_temp_data
;    endfor
;  endif
;  idl_end = systime(1, /second)


;  if CHK_WITH_IDL eq 1 then begin
;    print, 'CUDA took ' + string(c_end - c_start, format = '(f0.3)') + ' seconds'
;    print, 'IDL took ' + string(idl_end - idl_start, format = '(f0.3)') + ' seconds'
;  ;plotting the results
;    if output_num_bins[0] eq 1 then begin
;      for i = 0, num_calc_repeat - 1 do begin
;        ycplot, tau_arr, output_data[i, 0, *], out_base_id = oplot_id
;        ycplot, idl_tau_axis, idl_data_out[i, 0, *], oplot_id = oplot_id
;      endfor
;    endif else begin
;      for i = 0, num_calc_repeat - 1 do begin
;        ycshade, output_data[i, *, *], t_arr, tau_arr, title = 'CUDA'
;        ycshade, idl_data_out[i, *, *], idl_taxis, idl_tau_axis, title = 'IDL'
;      endfor
;    endelse
;  endif

  if num_bins_avg eq 0 then $
    num_bins_avg = output_total_num_bins[0]

  result_data = {num_time_pts:output_num_bins[0], $
                 num_bins_avg:num_bins_avg, $
                 num_out_pts_per_window:output_num_pts_per_window[0], $
                 time_axis:t_arr, $		;in seconds
                 tau_axis:tau_arr, $		;in micro-seconds
                 out_corr:output_data}

  rs = create_struct(rs, 'data', result_data)

  return, rs

end


;******************************************************************************
;* IDL routine                                                                *
;*   client_idl_cctd_vel_calc function                                        *
;*----------------------------------------------------------------------------*
;* This routine calculates the velocity based on the CCTD method.             *
;*      It does not use CUDA.                                                 *
;*      If we find that this routine takes sufficiently long time, then       *
;*         I will implement CUDA programs for this routine as well.           *
;******************************************************************************
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 07. Feb. 2011                                                *
;******************************************************************************

function client_idl_cctd_vel_calc, data, dz, use_envelop, signal_number, widget_text_id

  widget_control, widget_text_id, set_value = '', /append
  str = 'Calculating velocity for signal number ' + strcompress(string(signal_number, format='(i0)'), /remove_all) + ' based on cross-correlation starts.'
  widget_control, widget_text_id, set_value = str, /append

  dim = size(data.out_corr, /dim)
  nch = dim[0]
  ntime = dim[1]
  ntau = dim[2]

  cc_data = fltarr(nch, ntime, ntau)
  if use_envelop eq 1 then begin
    widget_control, widget_text_id, set_value = '  Performing Hilbert Transform to calculate the envelop...', /append, /no_newline
    for i = 0l, nch -1 do begin
      for j = 0l, ntime - 1 do begin
        data_temp = reform(data.out_corr[i, j, *])
        hilb = hilbert(data_temp)
        cc_data[i, j, *] = sqrt( data_temp^2 + hilb * conj(hilb) )
      endfor
    endfor
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif else begin
    cc_data = data.out_corr
  endelse

  widget_control, widget_text_id, set_value = '  Finding the time-dealy points with max cross-corr values...', /append, /no_newline
  z = findgen(nch + 1) * dz		;in mm
  t = fltarr(nch + 1, ntime)		;in micro-seconds
  t[*, *] = 0.0
  for i = 0l, nch - 1 do begin
    for j = 0l, ntime - 1 do begin
      cc = cc_data[i, j, *]
      max_val = max(cc, inx_t)
      if finite(max_val) eq 1 then begin
        t[i+1, j] = data.tau_axis[inx_t]
      endif else begin
        t[i+1, j] = 0.0
      endelse
    endfor
  endfor
  widget_control, widget_text_id, set_value = 'DONE!', /append

  widget_control, widget_text_id, set_value = '  Fitting a linear line to calculate the velocity...', /append, /no_newline
  vel = fltarr(ntime)
  vel_err = fltarr(ntime)
  for i = 0l, ntime - 1 do begin
    linfit_result = linfit(reform(t[*, i]), z, sigma = s)
    vel[i] = linfit_result[1]	; in km/sec
    if ( finite(vel[i]) eq 1 ) then begin
      vel_err[i] = s[1]
    endif else begin
      vel[i] = 0.0
      vel_err[i] = 0.0
    endelse
    if ( finite(vel_err[i]) ne 1 ) then begin
      vel_err[i] = 0.0
    endif
  endfor
  widget_control, widget_text_id, set_value = 'DONE!', /append

  result = {vel:vel, vel_err:vel_err, time:data.time_axis}

  return, result
end