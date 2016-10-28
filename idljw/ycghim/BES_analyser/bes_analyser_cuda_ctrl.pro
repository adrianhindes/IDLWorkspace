;===================================================================================
;
; This file contains following functions and procedures to control the CUDA communication
;   generated by windows for bes_analyser:
;
;  1) open_cuda_comm_line
;     --> opens up the cuda communication line between IDL and C
;  2) close_cuda_comm_line
;     --> closes the cuda communication line between IDL and C
;  3) perform_cuda_fft
;     --> performs FFT using CUDA and calculates auto- or cross-spectrum
;  4) perform_cuda_coh
;     --> performs FFT using CUDA and calculates coherency
;  5) perform_cuda_temp_corr
;     --> performs temporal correaltion using CUDA
;===================================================================================

@client_controller
@client_fcn
@bes_analyser_misc

;===================================================================================
; This function opens the CUDA communication line
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;===================================================================================
; Return value:
;   1) error_msg: error message during the open_cuda_comm_line.
;                 An empty string is returned if no error has been occured.
;===================================================================================
function open_cuda_comm_line, info

; retrieve the necessary data from info
  main_base = info.id.main_window.main_base
  config_file = info.CUDA_comm_window_data.conf_file
  status_file = info.CUDA_comm_window_data.sts_file
  pipes = info.pipes
  COMM_TEST = info.CUDA_command.TEST
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  msg_text_id = info.id.IDL_msg_box_window.msg_text

; set error_msg
  error_num = 0
  error_msg = bes_analyser_error_list(error_num)

; check config_file exists
  openr, in_conf, config_file, /get_lun, error = err
  if err ne 0 then begin
    error_num = 2
    error_msg = bes_analyser_error_list(error_num)
    return, error_msg
  endif
  free_lun, in_conf

; check status_file exist
  openr, in_sts, status_file, /get_lun, error = err
  if err ne 0 then begin
    error_num = 3
    error_msg = bes_analyser_error_list(error_num)
    return, error_msg
  endif
  free_lun, in_sts

  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Opening CUDA communication line...', /append
  endif

; open up the server program on a new konsole
  spawn, 'xterm -T CUDA_TERMINAL -e Run_server_anal ' + config_file + ' ' + status_file + ' &'

; start the client pipes
  result = client_startup(config_file, pipes)
  if result ne 1 then begin
    error_num = 4
    error_msg = bes_analyser_error_list(error_num)
    return, error_msg
  endif

; save the pipes into info
  info.pipes = pipes
  widget_control, main_base, set_uvalue = info

;Connection test between server and client
  if msg_box_on then $
    error = client_comm_test(pipes, COMM_TEST, msg_text_id) $
  else $
    error = client_comm_test(pipes, COMM_TEST)

  if error ne 0 then begin
    if msg_box_on then begin
      str = client_error(error)
      widget_control, msg_text_id, set_value = str, /append 
    endif
    error_num = 1
    error_msg = bes_analyser_error_list(error_num)
  ; terminate the CUDA connection
    close_cuda_comm_line, info

    return, error_msg
  endif

  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'CUDA communicatione line is online!', /append
  endif

  return, error_msg

end


;===================================================================================
; This procedure close the CUDA communication line
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;===================================================================================
pro close_cuda_comm_line, info

; retrieve the necessary data from info
  main_base = info.id.main_window.main_base
  pipes = info.pipes
  COMM_QUIT= info.CUDA_command.QUIT
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  msg_text_id = info.id.IDL_msg_box_window.msg_text

; send command to CUDA to stop communication
  error = client_comm_quit(pipes, COMM_QUIT)

  close, pipes.unit_r & free_lun, pipes.unit_r
  close, pipes.unit_w & free_lun, pipes.unit_w

; save the pipes into info
  info.pipes = pipes
  widget_control, main_base, set_uvalue = info

  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'CUDA communication line is closed.', /append
  endif

end


;===================================================================================
; This function performs FFT using CUDA and calculates auto- or cross-spectrum
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
function perform_cuda_fft, info, $
                           in_data1, in_data2, in_num_pts_per_subwindow, in_num_bins_to_avg, $
                           in_overlap, in_use_hanning, in_auto

; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}


; retrieve the necessary data from info
  main_base = info.id.main_window.main_base
  pipes = info.pipes
  COMM_CUDA_FFT= info.CUDA_command.CUDA_FFT
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

  ndata = long(n_elements(in_data1))

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '', /append
    widget_control, widget_text_id, set_value = '<Performing FFT on CUDA>', /append
    widget_control, widget_text_id, set_value = '  Sending Data...', /append, /no_newline
  endif

; send data to CUDA

; send the command
  client_put_data, pipes, COMM_CUDA_FFT, error = error
  if error ne 0 then goto, err_ctrl

; send the ndata
  client_put_data, pipes, ndata, error = error
  if error ne 0 then goto, err_ctrl

; send the sub_twindow size
  sub_twindow = long(in_num_pts_per_subwindow)
  client_put_data, pipes, sub_twindow, error = error
  if error ne 0 then goto, err_ctrl

; send the overlap
  client_put_data, pipes, in_overlap, error = error
  if error ne 0 then goto, err_ctrl

; send the use_han
  use_han = long(in_use_hanning)
  client_put_data, pipes, use_han, error = error
  if error ne 0 then goto, err_ctrl

; send the num_bins_avg
  num_bins_avg = long(in_num_bins_to_avg)
  client_put_data, pipes, num_bins_avg, error = error
  if error ne 0 then goto, err_ctrl

; send the autospec
  autospec = long(in_auto)
  client_put_data, pipes, autospec, error = error
  if error ne 0 then goto, err_ctrl

; send the data
  client_put_data, pipes, in_data1, error = error
  if error ne 0 then goto, err_ctrl
  if autospec ne 1 then begin
    client_put_data, pipes, in_data2, error = error
    if error ne 0 then goto, err_ctrl
  endif

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
    widget_control, widget_text_id, set_value = '  GPU is performing FFT...', /append, /no_newline
  endif

; receive the result of FFT
  client_get_data, pipes, 'long', output_result, error = error
  if error ne 0 then goto, err_ctrl
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif
  if output_result ne 1 then begin
    error = 15
    goto, err_ctrl
  endif

; receive the result of bin averaging
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  GPU is performing bin averaging...', /append, /no_newline
  endif
  client_get_data, pipes, 'long', output_result, error = error
  if error ne 0 then goto, err_ctrl
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

  if output_result ne 1 then begin
    error = 15
    goto, err_ctrl
  endif

; receiving the data from the CUDA server
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Receiving Data...', /append, /no_newline
  endif

; receive num_bins_out
  temp_num_bins = long(0)
  client_get_data, pipes, 'long', temp_num_bins, error = error
  if error ne 0 then goto, err_ctrl
  out_time_pts = temp_num_bins[0]

; receive total number of bins created during FFT
  temp_total_num_bins = long(0)
  client_get_data, pipes, 'long', temp_total_num_bins, error = error
  if error ne 0 then goto, err_ctrl
  out_total_num_bins = temp_total_num_bins[0]

; receive num_fft_pts_per_window
  temp_fft_pts_per_window = long(0)
  client_get_data, pipes, 'long', temp_fft_pts_per_window, error = error
  if error ne 0 then goto, err_ctrl
  out_num_fft_pts_per_subwindow = temp_fft_pts_per_window[0]

; receive the output data
  if autospec eq 1 then begin
    out_power = fltarr(out_time_pts, out_num_fft_pts_per_subwindow)
    out_phase = fltarr(out_time_pts, out_num_fft_pts_per_subwindow)
    out_phase[*, *] = 1.0	;note: phase of autopower is always 1.0.

    temp_output_power = fltarr(out_time_pts*out_num_fft_pts_per_subwindow)
    client_get_data, pipes, 'float', temp_output_power, error = error
    if error ne 0 then goto, err_ctrl
    for i = 0l, out_time_pts - 1 do $
      out_power[i, *] = temp_output_power[i*out_num_fft_pts_per_subwindow:(i+1)*out_num_fft_pts_per_subwindow-1]
  endif else begin
    out_complex_spec = complexarr(out_time_pts, out_num_fft_pts_per_subwindow)
    out_power = fltarr(out_time_pts, out_num_fft_pts_per_subwindow)
    out_phase = fltarr(out_time_pts, out_num_fft_pts_per_subwindow)

    temp_output_spec_real = fltarr(out_time_pts*out_num_fft_pts_per_subwindow)
    temp_output_spec_imag = fltarr(out_time_pts*out_num_fft_pts_per_subwindow)

    client_get_data, pipes, 'float', temp_output_spec_real, error = error
    if error ne 0 then goto, err_ctrl

    client_get_data, pipes, 'float', temp_output_spec_imag, error = error
    if error ne 0 then goto, err_ctrl

    for i = 0l, out_time_pts - 1 do begin
      out_complex_spec[i, *] = complex(temp_output_spec_real[(i+0)*out_num_fft_pts_per_subwindow: $
                                                             (i+1)*out_num_fft_pts_per_subwindow-1], $
                                       temp_output_spec_imag[(i+0)*out_num_fft_pts_per_subwindow: $
                                                             (i+1)*out_num_fft_pts_per_subwindow-1])
      out_power[i, *] = abs(out_complex_spec[i, *])
      out_phase[i, *] = atan(out_complex_spec[i, *], /phase)
    endfor
  endelse

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; print-out some of the output results
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
                                 'power', out_power, $
                                 'phase', out_phase)


; end the timer
  end_time = systime(1)

  if msg_box_on then begin
    msg_str = '  Elapsed time: ' + string(end_time - start_time, format='(f0.3)') + ' [sec].'
    widget_control, widget_text_id, set_value = msg_str, /append
  endif

  return, result

err_ctrl:
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'FAILED!', /append
    str = client_error(error)
    widget_control, widget_text_id, set_value = str, /append
  endif
  result.erc = 1
  result.errmsg = bes_analyser_error_list(result.erc)
  return, result

end



;===================================================================================
; This function performs FFT using CUDA and calculates coherency
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
;===================================================================================
; Return value:
;   1) result: <structure> : {erc, errmsg,
;              result.erc: <int> contains the error number
;              result.errmsg: <string> contains the error message
;              result.coh: <1D (spectrum) or 2D (spectrogram) floating array> contains the coherency
;              result.out_time_pts: <long> number of time points for the output.
;                                   For spectrum, this number should be 1.
;              result.out_total_num_bins: <long> total number of sub-time window that has been actually used
;                                                to perform FFT.
;                                                This number must be cross-checked.
;              result.out_num_fft_pts_per_subwindow: <long> contains the number of points in frequency domain
;                                                           per each time window.
;===================================================================================
function perform_cuda_coh, info, $
                           in_data1, in_data2, in_num_pts_per_subwindow, in_num_bins_to_avg, $
                           in_overlap, in_use_hanning

; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}


; retrieve the necessary data from info
  main_base = info.id.main_window.main_base
  pipes = info.pipes
  COMM_CUDA_COH= info.CUDA_command.CUDA_COH
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

  ndata = long(n_elements(in_data1))

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '', /append
    widget_control, widget_text_id, set_value = '<Performing FFT on CUDA>', /append
    widget_control, widget_text_id, set_value = '  Sending Data...', /append, /no_newline
  endif

; send data to CUDA

; send the command
  client_put_data, pipes, COMM_CUDA_COH, error = error
  if error ne 0 then goto, err_ctrl

; send the ndata
  client_put_data, pipes, ndata, error = error
  if error ne 0 then goto, err_ctrl

; send the sub_twindow size
  sub_twindow = long(in_num_pts_per_subwindow)
  client_put_data, pipes, sub_twindow, error = error
  if error ne 0 then goto, err_ctrl

; send the overlap
  client_put_data, pipes, in_overlap, error = error
  if error ne 0 then goto, err_ctrl

; send the use_han
  use_han = long(in_use_hanning)
  client_put_data, pipes, use_han, error = error
  if error ne 0 then goto, err_ctrl

; send the num_bins_avg
  num_bins_avg = long(in_num_bins_to_avg)
  client_put_data, pipes, num_bins_avg, error = error
  if error ne 0 then goto, err_ctrl

; send the data1
  client_put_data, pipes, in_data1, error = error
  if error ne 0 then goto, err_ctrl

; send the data2
  client_put_data, pipes, in_data2, error = error
  if error ne 0 then goto, err_ctrl

; receive the rsults of FFT
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
    widget_control, widget_text_id, set_value = '  GPU is performing FFT...', /append, /no_newline
  endif

  client_get_data, pipes, 'long', output_result, error = error
  if error ne 0 then goto, err_ctrl
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif
  if output_result ne 1 then begin
    error = 15
    goto, err_ctrl
  endif

; receive the results of bin-averaging
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  GPU is performing bin averaging...', /append, /no_newline
  endif
  client_get_data, pipes, 'long', output_result, error = error
  if error ne 0 then goto, err_ctrl
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif
  if output_result ne 1 then begin
    error = 15
    goto, err_ctrl
  endif

; receive the results of coherency calcualtion
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  GPU is calculating coh...', /append, /no_newline
  endif
  client_get_data, pipes, 'long', output_result, error = error
  if error ne 0 then goto, err_ctrl
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif
  if output_result ne 1 then begin
    error = 15
    goto, err_ctrl
  endif

; receiving the data from the CUDA server
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Receiving Data...', /append, /no_newline
  endif

; receive num_bins_out
  temp_num_bins = long(0)
  client_get_data, pipes, 'long', temp_num_bins, error = error
  if error ne 0 then goto, err_ctrl
  out_time_pts = temp_num_bins[0]

; receive total number of bins created during FFT
  temp_total_num_bins = long(0)
  client_get_data, pipes, 'long', temp_total_num_bins, error = error
  if error ne 0 then goto, err_ctrl
  out_total_num_bins = temp_total_num_bins[0]

; receive num_fft_pts_per_window
  temp_fft_pts_per_window = long(0)
  client_get_data, pipes, 'long', temp_fft_pts_per_window, error = error
  if error ne 0 then goto, err_ctrl
  out_num_fft_pts_per_subwindow = temp_fft_pts_per_window[0]

; receive the output data
  out_coh = fltarr(out_time_pts, out_num_fft_pts_per_subwindow)
  temp_output_power = fltarr(out_time_pts*out_num_fft_pts_per_subwindow)
  client_get_data, pipes, 'float', temp_output_power, error = error
  if error ne 0 then goto, err_ctrl
  for i = 0l, out_time_pts - 1 do $
    out_coh[i, *] = temp_output_power[i*out_num_fft_pts_per_subwindow:(i+1)*out_num_fft_pts_per_subwindow-1]

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; print-out some of the output results
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
                                 'coh', out_coh)

; end the timer
  end_time = systime(1)

  if msg_box_on then begin
    msg_str = '  Elapsed time: ' + string(end_time - start_time, format='(f0.3)') + ' [sec].'
    widget_control, widget_text_id, set_value = msg_str, /append
  endif

  return, result

err_ctrl:
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'FAILED!', /append
    str = client_error(error)
    widget_control, widget_text_id, set_value = str, /append
  endif
  result.erc = 1
  result.errmsg = bes_analyser_error_list(result.erc)
  return, result

end


;===================================================================================
; This function performs temporal correlation on CUDA
;===================================================================================
; The function parameters:
;   1) info: a structure that is saved as uvalue under the main_base.
;   2) in_data1: <1D floating array> signal 1 for temporal correlation
;   3) in_data2: <1D floating array> signal 2 for temporal correlation
;   4) in_num_pts_per_subwindow: <long> contains the number points per sub-time window
;   5) in_num_bins_to_avg: <long> contains the number of bins to be averaged
;   6) in_overlap: <floating> contains a fraction to be overlapped between neighboring
;                             sub-time windows
;   7) in_use_hanning: <1 or 0> If 1, then apply hanning window on each sub-time window.
;                               If 0, then do not apply hanning window.
;   8) in_auto: <1 or 0> If 1, then auto-correlation
;                        If 0, then cross-correlation
;   9) in_cov: <1 or 0> If 1, then calculate covariance (not normalized)
;                    If 0, then calculate correlation (normalized)
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
function perform_cuda_temp_corr, info, $
                                 in_data1, in_data2, in_num_pts_per_subwindow, in_num_bins_to_avg, $
                                 in_overlap, in_use_hanning, in_auto, in_cov

; start the timer
  start_time = systime(1)

; define the result structure
  result = {erc:0, $
            errmsg:''}


; retrieve the necessary data from info
  main_base = info.id.main_window.main_base
  pipes = info.pipes
  COMM_CUDA_CORR= info.CUDA_command.CUDA_CORR
  msg_box_on = info.main_window_data.IDL_msg_box_window_ON
  widget_text_id = info.id.IDL_msg_box_window.msg_text

  ndata = long(n_elements(in_data1))

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '', /append
    widget_control, widget_text_id, set_value = '<Performing Corr. on CUDA>', /append
    widget_control, widget_text_id, set_value = '  Sending Data...', /append, /no_newline
  endif

; send data to CUDA

; send the command
  client_put_data, pipes, COMM_CUDA_CORR, error = error
  if error ne 0 then goto, err_ctrl

; send the ndata
  client_put_data, pipes, ndata, error = error
  if error ne 0 then goto, err_ctrl

; send the sub_twindow size
  sub_twindow = long(in_num_pts_per_subwindow)
  client_put_data, pipes, sub_twindow, error = error
  if error ne 0 then goto, err_ctrl

; send the overlap
  client_put_data, pipes, in_overlap, error = error
  if error ne 0 then goto, err_ctrl

; send the use_han
  use_han = long(in_use_hanning)
  client_put_data, pipes, use_han, error = error
  if error ne 0 then goto, err_ctrl

; send the num_bins_avg
  num_bins_avg = long(in_num_bins_to_avg)
  client_put_data, pipes, num_bins_avg, error = error
  if error ne 0 then goto, err_ctrl

; send the covariance
  cov = long(in_cov)
  client_put_data, pipes, cov, error = error
  if error ne 0 then goto, err_ctrl

; send auto-correlation
  auto = long(in_auto)
  client_put_data, pipes, auto, error = error
  if error ne 0 then goto, err_ctrl

; send the data1
  client_put_data, pipes, in_data1, error = error
  if error ne 0 then goto, err_ctrl

; send the data2 if not auto
  if auto ne 1 then begin
    client_put_data, pipes, in_data2, error = error
    if error ne 0 then goto, err_ctrl
  endif

; sending data finished
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
    widget_control, widget_text_id, set_value = '  GPU is performing Corr...', /append, /no_newline
  endif

; GPU finishes its calculatino
  client_get_data, pipes, 'long', output_result, error = error
  if error ne 0 then goto, err_ctrl
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif
  if output_result ne 1 then begin
    error = 15
    goto, err_ctrl
  endif

; receiving the data
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = '  Receiving Data...', /append, /no_newline
  endif

; receive num_bins_out
  temp_num_bins = long(0)
  client_get_data, pipes, 'long', temp_num_bins, error = error
  if error ne 0 then goto, err_ctrl
  out_time_pts = temp_num_bins[0]

; receive total number of bins created during correlation calculation
  temp_total_num_bins = long(0)
  client_get_data, pipes, 'long', temp_total_num_bins, error = error
  if error ne 0 then goto, err_ctrl
  out_total_num_bins = temp_total_num_bins[0]

; receive num_corr_pts_per_subwindow
  temp_corr_pts_per_subwindow = long(0)
  client_get_data, pipes, 'long', temp_corr_pts_per_subwindow, error = error
  if error ne 0 then goto, err_ctrl
  out_num_corr_pts_per_subwindow = temp_corr_pts_per_subwindow[0]

; receive the output data
  out_corr = fltarr(out_time_pts, out_num_corr_pts_per_subwindow)
  temp_out_corr = fltarr(out_time_pts*out_num_corr_pts_per_subwindow)
  client_get_data, pipes, 'float', temp_out_corr, error = error
  for i = 0l, out_time_pts - 1 do $ 
    out_corr[i, *] = temp_out_corr[i*out_num_corr_pts_per_subwindow:(i+1)*out_num_corr_pts_per_subwindow-1]

  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'DONE!', /append
  endif

; print-out some of the output results
  if msg_box_on then begin
    msg_str = '    Number of time points: ' + string(out_time_pts, format='(i0)') + string(10b) + $
              '    Total number of created bin: ' + string(out_total_num_bins, format='(i0)') + string(10b) + $
              '    Number of points in tau. domain: ' + string(out_num_corr_pts_per_subwindow, format='(i0)')
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

err_ctrl:
  if msg_box_on then begin
    widget_control, widget_text_id, set_value = 'FAILED!', /append
    str = client_error(error)
    widget_control, widget_text_id, set_value = str, /append
  endif
  result.erc = 1
  result.errmsg = bes_analyser_error_list(result.erc)
  return, result

end




