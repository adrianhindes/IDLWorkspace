;===================================================================================
;
; This file contains following miscellaneous functions and procedures 
;   for bes_analyser:
;
;  1) bes_analyser_error_list
;     --> List of errors raised by bes_analyser
;  2) restore_sys_var
;     --> restores the original system variable for plot
;  3) save_sys_var
;     --> saves the current system variable for plot
;  4) freq_filter_signal
;     --> frequency filters the singal
;  5) save_time_file
;     --> saves the time file
;  6) load_time_file
;     --> loads the selected time regions from the time file
;  7) open_help_file
;  8) bes_ch_button_ctrl
;  9) bes_pol_ch_button_ctrl
; 10) bes_rad_ch_button_ctrl
; 11) make_bes_ch_button_exclusive
; 12) check_bes_ch_pol_rad_direction
; 13) set_extra_plot_info
; 14) save_options_info
; 15) load_options_info
;
;===================================================================================


;===================================================================================
; This function contains the list of errors raised by bes_analyser and
;   returns the string of error in accordance with the error_num
;===================================================================================
; The function parameters:
;  1) error_num: error number as integer
;===================================================================================
function bes_analyser_error_list, error_num

  case error_num of
    0: error_msg = ''
    1: error_msg = 'CUDA Communication Error!'
    2: error_msg = 'Configuration file for CUDA comm. is not availble.'
    3: error_msg = 'Status file for CUDA comm. is not availble.'
    4: error_msg = 'PIPEs are failed to be created.'
    5: error_msg = 'The specified Shot Number is not in valid format.'
    6: error_msg = 'Frequency Filtering range for low side is not valid.' + string(10b) + 'It will be set to 0.0 kHz'
    7: error_msg = 'Frequency Filtering range for high side is not valid.' + string(10b) + 'It will be set to 50.0 kHz'
    8: error_msg = 'Scaling factor for plasma current is not valid.' + string(10b) + 'It will be set to 1.0.'
    9: error_msg = 'Scaling factor for plasma density is not valid.' + string(10b) + 'It will be set to 1.0e+20.'
   10: error_msg = 'Scaling factor for SS beam Total power is not valid.' + string(10b) + 'It will be set to 1.0.'
   11: error_msg = 'Scaling factor for D-alpha is not valid.' + string(10b) + 'It will be set to 1.0e+19.'
   12: error_msg = 'Specified file name is not valid.'
   13: error_msg = 'Same file name already exists.  Use different file name.'
   14: error_msg = 'Time regions are not selected.  Select the time regions from the right-top plot.'
   15: error_msg = 'To load the time file, Time Selection Plot must not be empty.'
   16: error_msg = 'There is no existing time files.'
   17: error_msg = 'Failed to read the selected time file.'
   18: error_msg = 'Selected file is not a valid time file.'
   19: error_msg = 'No BES channels are selected.'
   20: error_msg = 'Perform ''Plot'' first before ''Oplot''.'
   21: error_msg = 'Plot type mismatch! Oplot cannot be performed.'
   22: error_msg = 'Oplot is performed.  But, the dimension of the data may be different.'
   23: error_msg = 'Oplot cannot be performed for 3D graph.'
   24: error_msg = 'File name is not valid.'
   25: error_msg = 'Same file name exits.' + string(10b) + 'Use differnet file name.'
   26: error_msg = 'The selected file is not compatible with the current version of bes_analyer.'
   27: error_msg = 'Specifield synthetic data cannot be loaded.'
  100: error_msg = 'CUDA cannot be run on this machine.' + string(10b) + 'Use the machine that has CUDA compatible GPU card.'
  101: error_msg = 'CUDA is not online.' + string(10b) + 'Open CUDA from ''Control the CUDA Communication Line''.'
  200: error_msg = 'Error from calc_rms_over_dc().' + string(10b) + $
                   'Input parameters of time and data do not have the same number of elements.'
  201: error_msg = 'Error from calc_rms_over_dc().' + string(10b) + $
                   'Number of points for averaging is too big.'
  202: error_msg = 'Number of points for averaging is not valid.' + string(10b) + 'It will be set to 1000.'
  203: error_msg = 'Number of points for averaging must be greater than 1.' + string(10b) + 'It will be set to 1000.'
  204: error_msg = 'Specified frequency for Low Pass Filter is not valid.' + string(10b) + 'It will be set to 10.0'
  205: error_msg = 'Specified low frequency for fluctuating part is not valid.' + string(10b) + 'It will be set to 0.0'
  206: error_msg = 'Specified high frequency for fluctuating part is not valid.' + string(10b) + 'It will be set to 200.0'
  250: error_msg = 'Factor to increase the spatial resolution is not valid.' + string(10b) + 'It will be set to 10.'
  251: error_msg = 'Factor to increase the spatial resolution must be ' + string(10b) + $
                   'greter than or equal to 1, or less than or equal to 30.' + string(10b) + $
                   'It will be set to 10.'
  252: error_msg = 'Specified low frequency for filtering is not valid.' + string(10b) + 'It will be set to 0.0'
  253: error_msg = 'Specified high frequency for filtering is not valid.' + string(10b) + 'It will be set to 1000.0'
  254: error_msg = 'Number of points for DC averaging is not valid.' + string(10b) + 'It will be set to 1000.'
  255: error_msg = 'Number of points for DC averaging must be greater than 1.' + string(10b) + 'It will be set to 1000.'
  256: error_msg = 'Specified frequency for Low Pass Filter is not valid.' + string(10b) + 'It will be set to 10.0'
  257: error_msg = 'Time region is not selected.' + string(10b) + 'Select a time region from the right-top plot.'
  258: error_msg = 'Multiple time regions are selected.' + string(10b) + 'Only one time region is allowed for this analysis.'
  259: error_msg = 'Error while generating BES animation from make_BES_animation().'
  300: error_msg = 'Number of bins of sub-time windows to be averaged is not valid.' + string(10b) + 'It will be set to 10.'
  301: error_msg = 'Error while preparing data from prep_to_perform_stat().'
  302: error_msg = 'Number of bins for averaging must be greater than 0 for spectrogram.' + string(10b) + 'It will be set to 10.'
  303: error_msg = 'No valid time ranges are selected.'
  304: error_msg = 'Number of bins for averaging is too big for spectrogram.'
  350: error_msg = 'Specified low time-delay is not valid.' + string(10b) + 'It will be set to -50.0'
  351: error_msg = 'Specified high time-delay is not valid.' + string(10b) + 'It will be set to 50.0'
  352: error_msg = 'Number of bins for averaging must be greater than 0.' + string(10b) + 'It will be set to 10.'
  353: error_msg = 'Number of points to remove photon peak is not vaild.' + string(10b) + 'It will be set to 0.'
  400: error_msg = 'Specified toroidal velocity is not valid.' + string(10b) + 'It will be set to 50.0'
  401: error_msg = 'At least two BES channels must be selected.'
  402: error_msg = 'BES channels with same poloidal locations are selected' + string(10b) + 'while poloidal direction is selected.'
  403: error_msg = 'BES channels with same radial locations are selected' + string(10b) + 'while radial direction is selected.'
  450: error_msg = 'Specified low time-delay is not valid.' + string(10b) + 'It will be set to -30.0'
  451: error_msg = 'Specified high time-delay is not valid.' + string(10b) + 'It will be set to 30.0'
  452: error_msg = 'Number of bins of sub-time windows to be averaged is not valid.' + string(10b) + 'It will be set to 300.'
  453: error_msg = 'Calculating pattern velocity is failed!'
  454: error_msg = 'Too few points for time evolution of pattern velocity!'
  455: error_msg = 'Failed to calculate the pattern velocity.' + string(10b) + 'Increase the time-delay range.'
  456: error_msg = 'Median Filter Width is not valid.' + string(10b) + 'It will be set to 3.'
  457: error_msg = 'Num. of time pts for running mean & S.D is not valid.' + string(10b) + 'It will be set to 50.'
  458: error_msg = 'Allowed multiple of standard deviation is not valied.' + string(10b) + 'It will be set to 3.0.'
  459: error_msg = 'Loading pitch angle and EFIT failed.' + string(10b) + 'Converting to toroidal velocity is not possible.'
  460: error_msg = 'Reading the toroidal velocity from SS failed.' + string(10b) + 'Converting to toroidal velocity is not possible.'
  461: error_msg = 'Reading the toroidal velocity from SW failed.' + string(10b) + 'Converting to toroidal velocity is not possible.'
  462: error_msg = 'Pitch angle at this BES position is not avilable.' + string(10b) + 'Converting to toroidal velocity is not possible.'
  500: error_msg = 'Number of bins of sub-time windoww to be averaged for v(t) is not valid.' + string(10b) + 'It will be set to 2.'
  550: error_msg = 'Time for flux surface plot is not valid.' + string(10b) + 'It will be set to 0.1.'
  551: error_msg = 'An error occured while reading the EFIT data.'
 1000: error_msg = 'This analysis is NOT yet implemented.' + string(10b) + 'Contact Young-chul Ghim(Kim) for further information.'
    else: error_msg = 'Unknows error occured.'
  endcase

  return, error_msg

end

;===================================================================================
; This procedure restores the system variable
;===================================================================================
; The function parameters:
;  1) 'sys_var' contains the system variable
;===================================================================================
pro restore_sys_var, sys_var

  !p = sys_var.p
  !x = sys_var.x
  !y = sys_var.y
  !z = sys_var.z

end

;===================================================================================
; This procedure saves the system variable
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'wid' is contains the ID for the current plot window
;===================================================================================
pro save_sys_var, info, wid

  widget_control, info.id.main_window.time_sel_draw, get_value = wid1
  widget_control, info.id.main_window.result_draw, get_value = wid2

  if wid eq wid1 then begin
    info.sys_var.time_sel_plot.p = !p
    info.sys_var.time_sel_plot.x = !x
    info.sys_var.time_sel_plot.y = !y
    info.sys_var.time_sel_plot.z = !z
  endif else if wid eq wid2 then begin
    info.sys_var.result_plot.p = !p
    info.sys_var.result_plot.x = !x
    info.sys_var.result_plot.y = !y
    info.sys_var.result_plot.z = !z
  endif

; save the info
  widget_control, info.id.main_window.main_base, set_uvalue = info

end


;===================================================================================
; This function filters the singal
;===================================================================================
; The function parameters:
;   1) 'singal' is the 1-D array data containing the data to be filtered.
;   2) 'freq_low' is the lowest frequency to be passed in [kHz]
;   3) 'freq_high' is the highest frequency to be passed in [kHz]
;   4) 'dt' is the time step of the signal in [sec]
;===================================================================================
; Return value:
;   result = {filtered_signal, num_zeroed_begin, num_zeroed_end}
;             filtered_signal: 1D array (whose size is equal to signal) of filtered signal
;             inx_nonzero_begin: index of the filtered_signal where non-zero values start.
;             inx_nonzero_end: index of the filtred_signal where non-zero values end.
;===================================================================================
function freq_filter_signal, signal, freq_low, freq_high, dt

; copy the singal
  org_signal = reform(signal)

; unit conversion for freq_low and freq_high
  f_low = freq_low * 1e3	;change to [Hz]
  f_high = freq_high * 1e3	;change to [Hz]

; calculate the Nyquist frequency
  f_nyq = 1.0/(2.0 * dt)

; check if filtering is necessary
  if ( (f_low le 0.0) and (f_high ge f_nyq) ) then begin
  ;filtering is not necessary
    result = {filtered_signal:org_signal, $
              inx_nonzero_begin:0, $
              inx_nonzero_end:long(n_elements(org_signal)-1)}

    return, result
  endif

; make sure f_low and f_high has meaningful numbers.
  if f_low lt 0.0 then f_low = 0.0
  if f_high gt f_nyq then f_high = f_nyq

; filtering starts.
  if f_low eq 0.0 then $
    filter_order = (f_nyq/f_high)*1.5 $
  else $
    filter_order = (f_nyq/f_low)*1.5

  filter = digital_filter( (f_low/f_nyq) > 0.0, (f_high/f_nyq) < 1.0, 50, filter_order)
  filtered_signal = convol(org_signal, filter)

; because convol function is performed with CENTER keyword omitted, 
;  zeros are padded into the filtered_signal where i<fix(k/2) and i>(n-fix(k/2)-1)
;  where i is the index and k is the number of elements in filter_order, n is the
;  number of elements in org_signal
  k = n_elements(filter)
  n = n_elements(org_signal)
  inx_nonzero_begin = long(k/2)
  inx_nonzero_end = n - long(k/2) - 1

  result = {filtered_signal:filtered_signal, $
            inx_nonzero_begin:inx_nonzero_begin, $
            inx_nonzero_end:inx_nonzero_end}

  return, result

end


;===================================================================================
; This procedure saves the time file
;===================================================================================
; The function parameters:
;   1) 'time_sel_struct' is a structure containing the info about the selected time regions.
;   2) 'filename' is a string for the file name
;   3) 'dirname' is a string for the directory
;===================================================================================
pro save_time_file, time_sel_struct, filename, dirname

  openw, outunit, dirname + filename, /get_lun

; first, write the number of selected regions
  line = string(time_sel_struct.curr_num_time_regions, format='(i0)')
  printf, outunit, line

; then, write the selected time ranges
  for i = 0, time_sel_struct.curr_num_time_regions - 1 do begin
    line = string(time_sel_struct.time_regions[i, 0], format = '(f0.0)') + $
           string(9b) + $	;horizontal tab
           string(time_sel_struct.time_regions[i, 1], format = '(f0.0)')
    printf, outunit, line
  endfor
  free_lun, outunit

end


;===================================================================================
; This function loads the selected time regions from the time file
;===================================================================================
; The function parameters:
;   1) 'fname' is a string for the file name
;   2) 'dirname' is a string for the directory
;===================================================================================
; Return value:
;   result: <structure>
;     result.erc: 0 or 1.  If 0, then no error while reading the file.
;                          If 1, then error while reading the file.
;     result.num_time_regions: <integer> containing the number of selected time regions
;     result.time_regions[result.num_time_regions, 2]: <floating array> containing the 
;            selected time regions
;===================================================================================
function load_time_file, fname, dirname

  result = {erc:0}

; open the file to read
  filename = dirname + fname
  openr, in, filename, /get_lun, error = err

  if err ne 0 then begin
    result.erc = 1
    return, result
  endif

; The first line contains the number of selected time regions
  temp_num = intarr(1)
  readf, in, temp_num
  num_time_regions = temp_num[0]
  temp_time = fltarr(2)
  time_regions = fltarr(num_time_regions, 2)

; Following lines contain the selected time regions
  for i = 0, num_time_regions - 1 do begin
    if ~EOF(in) then begin
      readf, in, temp_time
      time_regions[i, *] = temp_time
    endif
  endfor

  free_lun, in

  result = create_struct(result, 'num_time_regions', num_time_regions, 'time_regions', time_regions)
  
  return, result

end


;===================================================================================
; This function opens the help file using 'evince'
;===================================================================================
; The function parameters:
;   1) 'filename': <string> contains the filename to be opened by evince
;===================================================================================
; Return value:
;   result: <structure>
;     result.erc: 0 or 1.  If 0, then no error while reading the file.
;                          If 1, then error while reading the file.
;     result.errmsg: <string> contains the error message
;===================================================================================
function open_help_file, filename

  result = {erc:0, errmsg:''}

; check if evince is installed on the machine.
  spawn, 'evince --version &', r, err
  if err[0] ne '' then begin
    result.erc = 1
    result.errmsg = 'You do not have evince installed on your machine.' + string(10b) + $
                    'Read ' + filename + ' under your working directory manually.'
    return, result
  endif

  linux_command = 'evince ' + filename + ' &'
  spawn, linux_command
  return, result

end


;===================================================================================
; This procedure controls the buttons for selecting BES channels.
;===================================================================================
; The function parameters:
;  1) inx_rad_pos: index of the bes channel radial position that is being pressed by a user.
;  2) inx_pol_pos: index of the bes channel poloidal position that is being pressed by a user.
;  3) button_set: 1 if the pressed button is set, or 0 if the pressed button is not set.
;  4) id_bes_ch_button: 1D array containing IDs of BES channel buttons
;  5) id_bes_pol_ch_button: 1D array containing IDs of BES poloidal channel buttons
;  6) id_bes_rad_ch_button: 1D array containing IDs of BES radial channnle buttons
;===================================================================================
pro bes_ch_button_ctrl, inx_rad_pos, inx_pol_pos, button_set, $
                        id_bes_ch_button, id_bes_pol_ch_button, id_bes_rad_ch_button

  temp_inx = indgen(4) * 8 + inx_rad_pos
  temp_button_set = widget_info(id_bes_ch_button[temp_inx], /button_set)
  all_set = temp_button_set eq 1
  all_set_inx = where(all_set eq 0, count)
  if button_set then begin
    if count le 0 then $
      widget_control, id_bes_rad_ch_button[inx_rad_pos], set_button = 1
  endif else begin
    if count gt 0 then $
      widget_control, id_bes_rad_ch_button[inx_rad_pos], set_button = 0
  endelse

  temp_inx = indgen(8) + inx_pol_pos * 8
  temp_button_set = widget_info(id_bes_ch_button[temp_inx], /button_set)
  all_set = temp_button_set eq 1
  all_set_inx = where(all_set eq 0, count)
  if button_set then begin
    if count le 0 then $
      widget_control, id_bes_pol_ch_button[inx_pol_pos], set_button = 1
  endif else begin
    if count gt 0 then $
      widget_control, id_bes_pol_ch_button[inx_pol_pos], set_button = 0
  endelse

end


;===================================================================================
; This procedure controls the buttons for selecting BES channels.
;===================================================================================
; The function parameters:
;  1) inx_pol_pos: index of the bes channel poloidal position that is being pressed by a user.
;  2) button_set: 1 if the pressed button is set, or 0 if the pressed button is not set.
;  3) id_bes_ch_button: 1D array containing IDs of BES channel buttons
;  4) id_bes_pol_ch_button: 1D array containing IDs of BES poloidal channel buttons
;  5) id_bes_rad_ch_button: 1D array containing IDs of BES radial channnle buttons
;===================================================================================
pro bes_pol_ch_button_ctrl, inx_pol_pos, button_set, $
                            id_bes_ch_button, id_bes_pol_ch_button, id_bes_rad_ch_button

  for i = 0, 7 do $
    widget_control, id_bes_ch_button[inx_pol_pos * 8 + i], set_button = button_set

  for i = 0 , 7 do begin
    temp_inx = indgen(4)*8 + i
    temp_button_set = widget_info(id_bes_ch_button[temp_inx], /button_set)
    all_set = temp_button_set eq 1
    all_set_inx = where(all_set eq 0, count)
    if button_set then begin
      if count le 0 then $
        widget_control, id_bes_rad_ch_button[i], set_button = 1
    endif else begin
      if count gt 0 then $
        widget_control, id_bes_rad_ch_button[i], set_button = 0
    endelse
  endfor

end


;===================================================================================
; This procedure controls the buttons for selecting BES channels.
;===================================================================================
; The function parameters:
;  1) inx_rad_pos: index of the bes channel radial position that is being pressed by a user.
;  2) button_set: 1 if the pressed button is set, or 0 if the pressed button is not set.
;  3) id_bes_ch_button: 1D array containing IDs of BES channel buttons
;  4) id_bes_pol_ch_button: 1D array containing IDs of BES poloidal channel buttons
;  5) id_bes_rad_ch_button: 1D array containing IDs of BES radial channnle buttons
;===================================================================================
pro bes_rad_ch_button_ctrl, inx_rad_pos, button_set, $
                            id_bes_ch_button, id_bes_pol_ch_button, id_bes_rad_ch_button

  for i = 0, 3 do $
    widget_control, id_bes_ch_button[i*8 + inx_rad_pos], set_button = button_set

  for i = 0, 3 do begin
    temp_inx = indgen(8) + i*8
    temp_button_set = widget_info(id_bes_ch_button[temp_inx], /button_set)
    all_set = temp_button_set eq 1
    all_set_inx = where(all_set eq 0, count)
    if button_set then begin
      if count le 0 then $
        widget_control, id_bes_pol_ch_button[i], set_button = 1
    endif else begin
      if count gt 0 then $
        widget_control, id_bes_pol_ch_button[i], set_button = 0
    endelse
  endfor

end


;===================================================================================
; This procedure makes the nonexclusive BES channel buttons act as exclusive buttons. 
;===================================================================================
; The function parameters:
;  1) inx_to_be_set: index of id_bes_ch to be set
;  2) id_bes_ch: ID of all the BES channel buttons
;===================================================================================
pro make_bes_ch_button_exclusive, inx_to_be_set, id_bes_ch

  nch = n_elements(id_bes_ch)

  widget_control, id_bes_ch[inx_to_be_set], set_button = 1
  for i = 0, nch - 1 do begin
    if ( (widget_info(id_bes_ch[i], /button_set) eq 1) and (i ne inx_to_be_set) ) then $
      widget_control, id_bes_ch[i], set_button = 0
  endfor

end


;===================================================================================
; This function checks the selected BES channels.
;    If Poloidal direction is set, then selected BES channels must NOT have same poloidal location.
;    If Radial direction is set, then selected BES channels must NOT have same radial location.
;===================================================================================
; The function parameters:
;  1) pol_dir: <1 or 0> If 1, then a user wants to have poloidal displacement.
;                       If 0, then a user wants to have radial displacement.
;  2) id_bes_ch: ID of all the BES channel buttons
;===================================================================================
;  Return value:
;    error number:  If 0, then no error
;                   If not zero, then error.
;===================================================================================
function check_bes_ch_pol_rad_direction, pol_dir, id_bes_ch

  error_num = 0

  nch = n_elements(id_bes_ch)
  BES_ch_sel = intarr(nch)
  for i = 0, nch - 1 do $
    BES_ch_sel[i] = widget_info(id_bes_ch[i], /button_set)

  inx = where(BES_ch_sel eq 1, count)
  if count lt 2 then begin
    error_num = 401
    return, error_num
  endif

  if pol_dir eq 1 then begin
  ;a user wants to have a spatial displacement in poloidal direction.
  ;make sure no channels have same poloidal location.
    pol_loc = fix(inx/8)
    for i = 0, n_elements(pol_loc) - 1 do begin
      inx = where(pol_loc eq pol_loc[i], count)
      if count gt 1 then begin
        error_num = 402
        return, error_num
      endif
    endfor
  endif else begin
  ; a user wants to have a spatial displacement in radial direction.
  ; make sure no channels have same radial location.
    rad_loc = fix(inx mod 8)
    for i = 0, n_elements(rad_loc) - 1 do begin
      inx = where(rad_loc eq rad_loc[i], count)
      if count gt 1 then begin
        error_num = 403
        return, error_num
      endif
    endfor
  endelse

  return, error_num

end


;===================================================================================
; This function sets extra info to plot data in accordance with plotdata
;===================================================================================
; The function parameters:
;  1) info: a structure saved as a uvalue under the main window
;  2) plodata: a structure saved as a uvalue under result_plot
;===================================================================================
;  Return value:
;    plotdata
;===================================================================================
function set_extra_plot_info, info, plotdata

  if plotdata.type eq 11 then begin
    xtitle = 'Time [sec]'
    ytitle = 'BES Signal [V]'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 1
  endif else if plotdata.type eq 12 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Normalized [-]'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 1
  endif else if plotdata.type eq 21 then begin
    xtitle = 'Frequency [kHz]'
    ytitle = 'Power'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 1
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 0
  endif else if plotdata.type eq 22 then begin
    xtitle = 'Frequency [kHz]'
    ytitle = 'Coherency [-]'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 0
  endif else if plotdata.type eq 23 then begin
    xtitle = 'Frequency [kHz]'
    ytitle = 'Phase [Rad]'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 0
  endif else if plotdata.type eq 24 then begin
    xtitle = 'Time Delay [!7l!3sec]'
    ytitle = 'Correlation'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 0
  endif else if plotdata.type eq 25 then begin
    xtitle = 'Time Delay [!7l!3sec]'
    ytitle = 'Covariance'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 0
  endif else if plotdata.type eq 26 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Velocity [km/s]'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 1
  endif else if plotdata.type eq 30 then begin
    xtitle = 'Frequency [kHz]'
    ytitle = 'Power'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 0
  endif else if plotdata.type eq 31 then begin
    xtitle = 'Frequency [kHz]'
    ytitle = 'Phase [Rad]'
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.0, 0.0, 0.0, 0.0]
    scale_pos = [0.0, 0.0, 0.0, 0.0]
    xaxis_time = 0
  endif else if plotdata.type eq 101 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Frequency [kHz]'
    ztitle = 'Log!L10!N(Power)'
    title = 'Power'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 1
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 1
  endif else if plotdata.type eq 102 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Frequency [kHz]'
    ztitle = ''
    title = 'Coherency'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 1
  endif else if plotdata.type eq 103 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Frequency [kHz]'
    ztitle = ''
    title = 'Phase'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 1
  endif else if plotdata.type eq 104 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Time Delay [!7l!3sec]'
    ztitle = ''
    title = 'Correlation'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 1
  endif else if plotdata.type eq 105 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Time Delay [!7l!3sec]'
    ztitle = ''
    title = 'Covariance'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 1
  endif else if plotdata.type eq 106 then begin
    xtitle = 'Time Delay [!7l!3sec]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = 'Correlation'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 107 then begin
    xtitle = 'Time Delay [!7l!3sec]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = 'Covariance'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 108 then begin
    xtitle = '!7DU!3 [m]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = 'Correlation'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 109 then begin
    xtitle = '!7DU!3 [m]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = 'Covariance'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 130 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Frequency [kHz]'
    ztitle = ''
    title = 'Power'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 1
  endif else if plotdata.type eq 131 then begin
    xtitle = 'Time [sec]'
    ytitle = 'Frequency [kHz]'
    ztitle = ''
    title = 'Phase'
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 1
  endif else if plotdata.type eq 1001 then begin
    bes_ani_data = info.bes_animation_window_data
    xtitle = 'Major Raidus [cm]'
    ytitle = 'Height [cm]'
    pre_title = 'BES Movie: '
    title = ''
    if bes_ani_data.normalize eq 1 then $
      ztitle = 'Normalized ' $
    else $
      ztitle = ''
    if bes_ani_data.inx_play_type eq 0 then $
      ztitle = ztitle + 'n(t)' $
    else if bes_ani_data.inx_play_type eq 1 then $
      ztitle = ztitle + 'n1(t)' $
    else $
      ztitle = ztitle + 'n1(t)/n0(t)' 
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.464]
    scale_pos = [0.9, 0.1, 0.93, 0.464]
    xaxis_time = 0
  endif else if plotdata.type eq 1006 then begin
    xtitle = 'Time Delay [!7l!3sec]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = ''
    pre_title = 'Correlation: '
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 1007 then begin
    xtitle = 'Time Delay [!7l!3sec]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = ''
    pre_title = 'Covariance: '
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 1008 then begin
    xtitle = '!7DU!3 [m]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = ''
    pre_title = 'Correlation: '
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 1009 then begin
    xtitle = '!7DU!3 [m]'
    ytitle = '!7D!3x [m]'
    ztitle = ''
    title = ''
    pre_title = 'Covariance: '
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 1010 then begin
    xtitle = 'R [m]'
    ytitle = 'Z [m]'
    ztitle = ''
    title = ''
    pre_title = 'Flux Surface: '
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 1011 then begin
    xtitle = '!7D!3R [cm]'
    ytitle = '!7D!3Z [cm]'
    ztitle = ''
    title = ''
    pre_title = 'Correlation: '
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else if plotdata.type eq 1012 then begin
    xtitle = '!7D!3R [cm]'
    ytitle = '!7D!3Z [cm]'
    ztitle = ''
    title = ''
    pre_title = 'Covariance: '
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endif else begin
    xtitle = ''
    ytitle = ''
    ztitle = ''
    title = ''
    pre_title = ''
    xlog = 0
    ylog = 0
    zlog = 0
    shade_pos = [0.1, 0.1, 0.88, 0.9]
    scale_pos = [0.9, 0.1, 0.93, 0.9]
    xaxis_time = 0
  endelse

  if xaxis_time eq 1 then begin
  ; make show_time_indicator_button activie
    widget_control, info.id.main_window.show_time_indicator_button, sensitive = 1
    if widget_info(info.id.main_window.show_time_indicator_button, /button_set) eq 1 then $
      widget_control, info.id.main_window.result_draw_slider, sensitive = 1 $
    else $
      widget_control, info.id.main_window.result_draw_slider, sensitive = 0
  endif else begin
    widget_control, info.id.main_window.show_time_indicator_button, set_button = 0
    widget_control, info.id.main_window.show_time_indicator_button, sensitive = 0
    widget_control, info.id.main_window.result_draw_slider, sensitive = 0
    widget_control, info.id.main_window.result_draw_slider, set_value = 0
  endelse

  plotdata.xtitle = xtitle
  plotdata.ytitle = ytitle
  plotdata.ztitle = ztitle
  plotdata.title = title
  plotdata.pre_title = pre_title
  plotdata.xlog = xlog
  plotdata.ylog = ylog
  plotdata.zlog = zlog
  plotdata.shade_pos = shade_pos
  plotdata.scale_pos = scale_pos

  return, plotdata

end



;===================================================================================
; This function saves the option information to a file
;===================================================================================
; The function parameters:
;  1) id_main_base: <long> main base widget ID
;  2) filename: <string> file name (without the file extension)
;  3) file_extension: <string> file extension
;  4) comment: <string array> comment given by the user
;===================================================================================
;  Return value:
;    result: <integer> contains the error number
;            If this is 0, then no error.
;===================================================================================
function save_options_info, id_main_base, filename, file_extension, comment

  result = 0

; check if the filename is empty or not
  if filename eq '' then begin
    result = 24
    return, result
  endif

; get the info structure
  widget_control, id_main_base, get_uvalue = info

; check the bes_analyser_options folder exists.
  dir_name = 'bes_analyser_options/'
  spawn, 'ls -d1 */', out_dir_name, outerr, count = num_dir
  if num_dir lt 1 then begin
  ; bes_analyser_options folder does not exist
    linux_command = 'mkdir ' + dir_name
    spawn, linux_command
  endif else begin
    inx = where(out_dir_name eq dir_name, count)
    if count eq 0 then begin
    ; bes_analyser_options folder does not exist
      linux_command = 'mkdir ' + dir_name
      spawn, linux_command
    endif
  endelse

; check whether the folder for the shotnumber exists
  shotnumber = info.main_window_data.BES_data.shot
  shot_dir_name = dir_name + string(shotnumber, format='(i0)') + '/'
  linux_command = 'ls -d1 ' + dir_name + '*/'
  spawn, linux_command, out_dir_name, outerr, count = num_dir
  if num_dir lt 1 then begin
  ; the shot number folder does not exist
    linux_command = 'mkdir ' + shot_dir_name
    spawn, linux_command
  endif else begin
    inx = where(out_dir_name eq shot_dir_name, count)
    if count eq 0 then begin
    ; the shot number folder does not exist
      linux_command = 'mkdir ' + shot_dir_name
      spawn, linux_command
    endif
  endelse

; now, check whether there is an existing same filename
  filename = filename + file_extension
  linux_command = 'ls ' + shot_dir_name
  spawn, linux_command, out_fname, outerr, count = num_file
  if num_file gt 0 then begin
    inx = where(filename eq out_fname, count)
    if count ne 0 then begin
    ; same file name exists.
      result = 25
      return, result
    endif
  endif

  full_filename = shot_dir_name + filename

; now, save the options in accordance with the file extension
  if file_extension eq '.bes_evol' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.bes_time_evol_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.rms_evol' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.rms_dc_time_evol_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.bes_ani' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.bes_animation_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.dens_spec' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.dens_spec_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.dens_coh' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.dens_coh_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.dens_tcorr' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.dens_temp_corr_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.dens_stcorr' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.dens_spa_temp_corr_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.dens_sscorr' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.dens_spa_spa_corr_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.vel_evol' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.vel_time_evol_window_data} 
    save, option_data, filename = full_filename
  endif else if file_extension eq '.vel_spec' then begin
    option_data = {version:info.version, $
                   shotnumber:shotnumber, $
                   comment:comment, $
                   time_sel_struct:info.time_sel_struct, $
                   option:info.vel_spec_window_data} 
    save, option_data, filename = full_filename
  endif


  return, result

end


;===================================================================================
; This function loads the option information to a file
;===================================================================================
; The function parameters:
;  1) id_main_base: <long> main base widget ID
;  2) idinfo: IDs of the current widget window
;  3) filename: <string> full path file name with the extension
;  4) file_extension: <string> file extension
;===================================================================================
;  Return value:
;    result: <integer> contains the error number
;            If this is 0, then no error.
;===================================================================================
function load_options_info, id_main_base, idinfo, filename, file_extension

  result = 0

; get the info structure
  widget_control, id_main_base, get_uvalue = info

; restore the option_data
  restore, filename	;now a structure called option_data is available.

; check the bes_analyer_version
  compatible_version = [0.4]
  inx = where(compatible_version eq option_data.version, count)
  if count lt 1 then begin
    result = 26
    return, result
  endif

; now, load the options in accordance with the file extension
  comment = option_data.comment
  info.time_sel_struct = option_data.time_sel_struct
  data = option_data.option

  if file_extension eq '.bes_evol' then begin
    info.bes_time_evol_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    for i = 0, n_elements(data.BES_ch_sel)-1 do $
      widget_control, idinfo.BES_Ch_button[i], set_button = data.BES_ch_sel[i]
    for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
      widget_control, idinfo.RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
    for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
      widget_control, idinfo.POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]

  endif else if file_extension eq '.rms_evol' then begin
    info.rms_dc_time_evol_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    for i = 0, n_elements(data.BES_ch_sel)-1 do $
      widget_control, idinfo.BES_Ch_button[i], set_button = data.BES_ch_sel[i]
    for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
      widget_control, idinfo.RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
    for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
      widget_control, idinfo.POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
    str = string(data.avg_nt, format='(i0)')
    widget_control, idinfo.avg_nt_text, set_value = str
    time_resolution = info.main_window_data.BES_data.dt * data.avg_nt * 1e6	;in [micro sec]
    str = ' dt of outupt = ' + string(time_resolution, format='(f0.2)') + ' [micro-sec]'
    widget_control, idinfo.time_res_label, set_value = str
    widget_control, idinfo.use_LPF_for_DC_button, set_button = data.use_LPF_for_DC
    str = string(data.DC_freq_filter_high, format='(f0.2)')
    widget_control, idinfo.DC_freq_filter_high_text, set_value = str
    widget_control, idinfo.DC_freq_filter_high_text, sensitive = data.use_LPF_for_DC
    str = string(data.RMS_freq_filter_low, format='(f0.2)')
    widget_control, idinfo.RMS_freq_filter_low_text, set_value = str
    str = string(data.RMS_freq_filter_high, format='(f0.2)')
    widget_control, idinfo.RMS_freq_filter_high_text, set_value = str
    widget_control, idinfo.subtract_DC_button, set_button = data.subtract_DC
  endif else if file_extension eq '.bes_ani' then begin
    info.bes_animation_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    str = string(data.factor_inc_spa_pts, format='(i0)')
    widget_control, idinfo.factor_inc_spa_pts_text, set_value = str
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    widget_control, idinfo.play_type_combo, set_combobox_select = data.inx_play_type
    if data.by_time_avg_for_DC eq 1 then begin
      widget_control, idinfo.by_time_avg_for_DC_button, set_button = 1
      widget_control, idinfo.by_LPF_for_DC_button, set_button = 0
    endif else begin
      widget_control, idinfo.by_time_avg_for_DC_button, set_button = 0
      widget_control, idinfo.by_LPF_for_DC_button, set_button = 1
    endelse
    str = string(data.avg_nt, format='(i0)')
    widget_control, idinfo.avg_nt_text, set_value = str
    str = string(data.DC_freq_filter_high, format='(f0.2)')
    widget_control, idinfo.DC_freq_filter_high_text, set_value = str
    if data.inx_play_type eq 0 then begin
      widget_control, idinfo.by_time_avg_for_DC_button, sensitive = 0
      widget_control, idinfo.by_LPF_for_DC_button, sensitive = 0
      widget_control, idinfo.avg_nt_text, sensitive = 0
      widget_control, idinfo.DC_freq_filter_high_text, sensitive = 0
    endif else begin
      widget_control, idinfo.by_time_avg_for_DC_button, sensitive = 1
      widget_control, idinfo.by_LPF_for_DC_button, sensitive = 1
      if  data.by_time_avg_for_DC eq 1 then begin
        widget_control, idinfo.avg_nt_text, sensitive = 1
        widget_control, idinfo.DC_freq_filter_high_text, sensitive = 0
      endif else begin
        widget_control, idinfo.avg_nt_text, sensitive = 0
        widget_control, idinfo.DC_freq_filter_high_text, sensitive = 1
      endelse
    endelse
    widget_control, idinfo.normalize_button, set_button = data.normalize
    if data.norm_by_own_ch eq 1 then begin
      widget_control, idinfo.norm_by_own_ch_button, set_button = 1
      widget_control, idinfo.norm_by_all_ch_button, set_button = 0
    endif else begin
      widget_control, idinfo.norm_by_own_ch_button, set_button = 0
      widget_control, idinfo.norm_by_all_ch_button, set_button = 1
    endelse
    if data.normalize eq 1 then begin
      widget_control, idinfo.norm_by_own_ch_button, sensitive = 1
      widget_control, idinfo.norm_by_all_ch_button, sensitive = 1
    endif else begin
      widget_control, idinfo.norm_by_own_ch_button, sensitive = 0
      widget_control, idinfo.norm_by_all_ch_button, sensitive = 0
    endelse
    widget_control, idinfo.show_BES_pos_button, set_button = data.show_BES_pos
    combo_str = info.color_table_str 
    inx_curr_sel = where(data.col_BES_pos_str eq info.color_table_str, count)
    if count le 0 then inx_curr_sel = 0
    widget_control, idinfo.col_BES_pos_combo, set_combobox_select = inx_curr_sel
    widget_control, idinfo.col_BES_pos_combo, sensitive = data.show_BES_pos
    widget_control, idinfo.ctable_combo, set_combobox_select = data.inx_ctable
    widget_control, idinfo.inv_ctable_button, set_button = data.inv_ctable

  endif else if file_extension eq '.dens_spec' then begin
    info.dens_spec_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    if data.calc_in_IDL eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 1
      widget_control, idinfo.calc_in_CUDA_button, set_button = 0
    endif else if data.calc_in_CUDA eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 0
      widget_control, idinfo.calc_in_CUDA_button, set_button = 1
    endif
    for i = 0, n_elements(data.BES_ch_sel1)-1 do $
      widget_control, idinfo.BES_ch_sel1_button[i], set_button = data.BES_ch_sel1[i]
    for i = 0, n_elements(data.BES_ch_sel2)-1 do $
      widget_control, idinfo.BES_ch_sel2_button[i], set_button = data.BES_ch_sel2[i]
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    if data.calc_spectrum eq 1 then begin
      widget_control, idinfo.calc_spectrum_button, set_button = 1
      widget_control, idinfo.calc_spectrogram_button, set_button = 0
    endif else if data.calc_spectrogram eq 1 then begin
      widget_control, idinfo.calc_spectrum_button, set_button = 0
      widget_control, idinfo.calc_spectrogram_button, set_button = 1
    endif
    if data.calc_power eq 1 then begin
      widget_control, idinfo.calc_power_button, set_button = 1
      widget_control, idinfo.calc_phase_button, set_button = 0
    endif else if data.calc_phase eq 1 then begin
      widget_control, idinfo.calc_power_button, set_button = 0
      widget_control, idinfo.calc_phase_button, set_button = 1
    endif    
    widget_control, idinfo.num_pts_per_subwindow_combo, get_value = compare_str
    inx = where(data.num_pts_per_subwindow eq compare_str, count)
    if count le 0 then inx = 0
    widget_control, idinfo.num_pts_per_subwindow_combo, set_combobox_select = inx
    str = string(data.num_bins_to_average, format='(i0)')
    widget_control, idinfo.num_bins_to_average_text, set_value = str
    widget_control, idinfo.num_bins_to_average_text, sensitive = data.calc_spectrogram
    widget_control, idinfo.frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
    str = string(data.frac_overlap_subwindow, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_label, set_value = str
    widget_control, idinfo.norm_by_DC_combo, set_combobox_select = data.norm_by_DC
    widget_control, idinfo.use_hanning_window_combo, set_combobox_select = data.use_hanning_window
    widget_control, idinfo.remove_large_structure_combo, set_combobox_select = data.remove_large_structure

  endif else if file_extension eq '.dens_coh' then begin
    info.dens_coh_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    if data.calc_in_IDL eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 1
      widget_control, idinfo.calc_in_CUDA_button, set_button = 0
    endif else if data.calc_in_CUDA eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 0
      widget_control, idinfo.calc_in_CUDA_button, set_button = 1
    endif
    for i = 0, n_elements(data.BES_ch_sel1)-1 do $
      widget_control, idinfo.BES_ch_sel1_button[i], set_button = data.BES_ch_sel1[i]
    for i = 0, n_elements(data.BES_ch_sel2)-1 do $
      widget_control, idinfo.BES_ch_sel2_button[i], set_button = data.BES_ch_sel2[i]
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    if data.calc_spectrum eq 1 then begin
      widget_control, idinfo.calc_spectrum_button, set_button = 1
      widget_control, idinfo.calc_spectrogram_button, set_button = 0
    endif else if data.calc_spectrogram eq 1 then begin
      widget_control, idinfo.calc_spectrum_button, set_button = 0
      widget_control, idinfo.calc_spectrogram_button, set_button = 1
    endif
    if data.calc_power eq 1 then begin
      widget_control, idinfo.calc_power_button, set_button = 1
      widget_control, idinfo.calc_phase_button, set_button = 0
    endif else if data.calc_phase eq 1 then begin
      widget_control, idinfo.calc_power_button, set_button = 0
      widget_control, idinfo.calc_phase_button, set_button = 1
    endif    
    widget_control, idinfo.num_pts_per_subwindow_combo, get_value = compare_str
    inx = where(data.num_pts_per_subwindow eq compare_str, count)
    if count le 0 then inx = 0
    widget_control, idinfo.num_pts_per_subwindow_combo, set_combobox_select = inx
    str = string(data.num_bins_to_average, format='(i0)')
    widget_control, idinfo.num_bins_to_average_text, set_value = str
    widget_control, idinfo.num_bins_to_average_text, sensitive = data.calc_spectrogram
    widget_control, idinfo.frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
    str = string(data.frac_overlap_subwindow, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_label, set_value = str
    widget_control, idinfo.use_hanning_window_combo, set_combobox_select = data.use_hanning_window
    widget_control, idinfo.remove_large_structure_combo, set_combobox_select = data.remove_large_structure

  endif else if file_extension eq '.dens_tcorr' then begin
    info.dens_temp_corr_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    if data.calc_in_IDL eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 1
      widget_control, idinfo.calc_in_CUDA_button, set_button = 0
    endif else if data.calc_in_CUDA eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 0
      widget_control, idinfo.calc_in_CUDA_button, set_button = 1
    endif
    for i = 0, n_elements(data.BES_ch_sel1)-1 do $
      widget_control, idinfo.BES_ch_sel1_button[i], set_button = data.BES_ch_sel1[i]
    for i = 0, n_elements(data.BES_ch_sel2)-1 do $
      widget_control, idinfo.BES_ch_sel2_button[i], set_button = data.BES_ch_sel2[i]
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    if data.calc_correlation eq 1 then begin
      widget_control, idinfo.calc_correlation_button, set_button = 1
      widget_control, idinfo.calc_covariance_button, set_button = 0
    endif else begin
      widget_control, idinfo.calc_correlation_button, set_button = 0
      widget_control, idinfo.calc_covariance_button, set_button = 1
    endelse
    if data.calc_fcn_tau eq 1 then begin
      widget_control, idinfo.calc_fcn_tau_button, set_button = 1
      widget_control, idinfo.calc_fcn_tau_time_button, set_button = 0
    endif else begin
      widget_control, idinfo.calc_fcn_tau_button, set_button = 0
      widget_control, idinfo.calc_fcn_tau_time_button, set_button = 1
    endelse
    str = string(data.time_delay_low, format='(f0.1)')
    widget_control, idinfo.time_delay_low_text, set_value = str
    str = string(data.time_delay_high, format='(f0.1)')
    widget_control, idinfo.time_delay_high_text, set_value = str
    str = string(data.num_bins_to_average, format='(i0)')
    widget_control, idinfo.num_bins_to_average_text, set_value = str
    widget_control, idinfo.num_bins_to_average_text, sensitive = data.calc_fcn_tau_time
    widget_control, idinfo.frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
    str = string(data.frac_overlap_subwindow, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_label, set_value = str
    widget_control, idinfo.use_hanning_window_combo, set_combobox_select = data.use_hanning_window
    widget_control, idinfo.remove_large_structure_combo, set_combobox_select = data.remove_large_structure
    str = string(data.num_pts_to_remove_ph_peak, format = '(i0)')
    widget_control, idinfo.num_pts_to_remove_ph_peak_text, set_value = str

  endif else if file_extension eq '.dens_stcorr' then begin
    info.dens_spa_temp_corr_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    if data.calc_in_IDL eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 1
      widget_control, idinfo.calc_in_CUDA_button, set_button = 0
    endif else if data.calc_in_CUDA eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 0
      widget_control, idinfo.calc_in_CUDA_button, set_button = 1
    endif
    if data.calc_pol_spa eq 1 then begin
      widget_control, idinfo.calc_pol_spa_button, set_button = 1
      widget_control, idinfo.calc_rad_spa_button, set_button = 0
    endif else if data.calc_rad_spa eq 1 then begin
      widget_control, idinfo.calc_pol_spa_button, set_button = 0
      widget_control, idinfo.calc_rad_spa_button, set_button = 1
    endif
    for i = 0, n_elements(data.BES_ch_sel)-1 do $
      widget_control, idinfo.BES_Ch_button[i], set_button = data.BES_ch_sel[i]
    for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
      widget_control, idinfo.RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
    for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
      widget_control, idinfo.POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    widget_control, idinfo.calc_fcn_time_combo, set_combobox_select = data.calc_fcn_time
    widget_control, idinfo.convert_temp_to_spa_button, set_button = data.convert_temp_to_spa
    if data.calc_correlation eq 1 then begin
      widget_control, idinfo.calc_correlation_button, set_button = 1
      widget_control, idinfo.calc_covariance_button, set_button = 0
    endif else begin
      widget_control, idinfo.calc_correlation_button, set_button = 0
      widget_control, idinfo.calc_covariance_button, set_button = 1
    endelse
    widget_control, idinfo.use_cxrs_data_button, set_button = data.use_cxrs_data
    widget_control, idinfo.use_ss_cxrs_combo, set_combobox_select = data.use_ss_cxrs
    str = string(data.manual_vtor, format='(f0.2)')
    widget_control, idinfo.manual_vtor_text, set_value = str
    str = string(data.time_delay_low, format='(f0.1)')
    widget_control, idinfo.time_delay_low_text, set_value = str
    str = string(data.time_delay_high, format='(f0.1)')
    widget_control, idinfo.time_delay_high_text, set_value = str
    str = string(data.num_bins_to_average, format='(i0)')
    widget_control, idinfo.num_bins_to_average_text, set_value = str
    widget_control, idinfo.frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
    str = string(data.frac_overlap_subwindow, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_label, set_value = str
    widget_control, idinfo.use_hanning_window_combo, set_combobox_select = data.use_hanning_window
    widget_control, idinfo.remove_large_structure_combo, set_combobox_select = data.remove_large_structure
    str = string(data.factor_inc_spa_pts, format = '(i0)')
    widget_control, idinfo.factor_inc_spa_pts_text, set_value = str

  ; control the senstivity of widgets
    sens_check_bes_dens_spa_temp_corr_window, idinfo

  endif else if file_extension eq '.dens_sscorr' then begin
    info.dens_spa_spa_corr_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    if data.calc_in_IDL eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 1
      widget_control, idinfo.calc_in_CUDA_button, set_button = 0
    endif else if data.calc_in_CUDA eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 0
      widget_control, idinfo.calc_in_CUDA_button, set_button = 1
    endif
    if data.calc_spa_avg_NO eq 1 then begin
      widget_control, idinfo.calc_spa_avg_NO_button, set_button = 1
      widget_control, idinfo.calc_spa_avg_YES_button, set_button = 0
    endif else if data.calc_spa_avg_YES eq 1 then begin
      widget_control, idinfo.calc_spa_avg_NO_button, set_button = 0
      widget_control, idinfo.calc_spa_avg_YES_button, set_button = 1
    endif
    for i = 0, n_elements(data.BES_ch_sel)-1 do begin
      widget_control, idinfo.BES_ch_sel_button[i], set_button = data.BES_ch_sel[i]
      widget_control, idinfo.BES_ch_sel_button[i], sensitive = data.calc_spa_avg_NO
    endfor
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    str = string(data.time_delay_low, format='(f0.1)')
    widget_control, idinfo.time_delay_low_text, set_value = str
    str = string(data.time_delay_high, format='(f0.1)')
    widget_control, idinfo.time_delay_high_text, set_value = str
    if data.calc_covariance eq 1 then begin
      widget_control, idinfo.calc_covariance_button, set_button = 1
      widget_control, idinfo.calc_correlation_button, set_button = 0
    endif else if data.calc_correlation eq 1 then begin
      widget_control, idinfo.calc_covariance_button, set_button = 0
      widget_control, idinfo.calc_correlation_button, set_button = 1
    endif
    widget_control, idinfo.frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
    str = string(data.frac_overlap_subwindow, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_label, set_value = str
    widget_control, idinfo.use_hanning_window_combo, set_combobox_select = data.use_hanning_window
    widget_control, idinfo.remove_large_structure_combo, set_combobox_select = data.remove_large_structure
    widget_control, idinfo.compare_coarr_button, sensitive = data.calc_spa_avg_YES

  endif else if file_extension eq '.vel_evol' then begin
    info.vel_time_evol_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    if data.calc_in_IDL eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 1
      widget_control, idinfo.calc_in_CUDA_button, set_button = 0
    endif else if data.calc_in_CUDA eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 0
      widget_control, idinfo.calc_in_CUDA_button, set_button = 1
    endif
    if data.calc_pol_vel eq 1 then begin
      widget_control, idinfo.calc_pol_vel_button, set_button = 1
      widget_control, idinfo.calc_rad_vel_button, set_button = 0
    endif else if data.calc_rad_vel eq 1 then begin
      widget_control, idinfo.calc_pol_vel_button, set_button = 0
      widget_control, idinfo.calc_rad_vel_button, set_button = 1
    endif
    for i = 0, n_elements(data.BES_ch_sel)-1 do $
      widget_control, idinfo.BES_Ch_button[i], set_button = data.BES_ch_sel[i]
    for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
      widget_control, idinfo.RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
    for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
      widget_control, idinfo.POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    widget_control, idinfo.convert_to_tor_vel_button, set_button = data.convert_to_tor_vel
    widget_control, idinfo.convert_to_tor_vel_button, sensitive = data.calc_pol_vel
    widget_control, idinfo.compare_cxrs_ss_button, set_button = data.compare_cxrs_ss
    widget_control, idinfo.compare_cxrs_sw_button, set_button = data.compare_cxrs_sw
    if ( (data.calc_pol_vel eq 1) and (data.convert_to_tor_vel eq 1) ) then begin
      widget_control, idinfo.compare_cxrs_ss_button, sensitive = 1
      widget_control, idinfo.compare_cxrs_sw_button, sensitive = 1
    endif else begin
      widget_control, idinfo.compare_cxrs_ss_button, sensitive = 0
      widget_control, idinfo.compare_cxrs_sw_button, sensitive = 0
    endelse
    str = string(data.time_delay_low, format='(f0.1)')
    widget_control, idinfo.time_delay_low_text, set_value = str
    str = string(data.time_delay_high, format='(f0.1)')
    widget_control, idinfo.time_delay_high_text, set_value = str
    str = string(data.num_bins_to_average, format='(i0)')
    widget_control, idinfo.num_bins_to_average_text, set_value = str
    widget_control, idinfo.frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
    str = string(data.frac_overlap_subwindow, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_label, set_value = str
    widget_control, idinfo.use_hanning_window_combo, set_combobox_select = data.use_hanning_window
    widget_control, idinfo.remove_large_structure_combo, set_combobox_select = data.remove_large_structure
    widget_control, idinfo.apply_median_filter_button, set_button = data.apply_median_filter
    str = string(data.median_filter_width, format='(i0)')
    widget_control, idinfo.median_filter_width_text, set_value = str
    widget_control, idinfo.median_filter_width_text, sensitive = data.apply_median_filter
    widget_control, idinfo.apply_field_method_button, set_button = data.apply_field_method
    widget_control, idinfo.apply_field_method_button, sensitive = data.apply_median_filter
    str = string(data.num_time_pts_field_method, format='(i0)')
    widget_control, idinfo.num_time_pts_field_method_text, set_value = str
    str = string(data.allowed_mult_sd, format='(f0.1)')
    widget_control, idinfo.allowed_mult_sd_text, set_value = str
    if ( (data.apply_median_filter eq 1) and (data.apply_field_method) ) then begin
      widget_control, idinfo.num_time_pts_field_method_text, sensitive = 1
      widget_control, idinfo.allowed_mult_sd_text, sensitive = 1
    endif else begin
      widget_control, idinfo.num_time_pts_field_method_text, sensitive = 0
      widget_control, idinfo.allowed_mult_sd_text, sensitive = 0
    endelse
  endif else if file_extension eq '.vel_spec' then begin
    info.vel_spec_window_data = data
  ; save the info structure
    widget_control, id_main_base, set_uvalue = info
  ; update the fields
    if data.calc_in_IDL eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 1
      widget_control, idinfo.calc_in_CUDA_button, set_button = 0
    endif else if data.calc_in_CUDA eq 1 then begin
      widget_control, idinfo.calc_in_IDL_button, set_button = 0
      widget_control, idinfo.calc_in_CUDA_button, set_button = 1
    endif
    if data.calc_pol_vel eq 1 then begin
      widget_control, idinfo.calc_pol_vel_button, set_button = 1
      widget_control, idinfo.calc_rad_vel_button, set_button = 0
    endif else if data.calc_rad_vel eq 1 then begin
      widget_control, idinfo.calc_pol_vel_button, set_button = 0
      widget_control, idinfo.calc_rad_vel_button, set_button = 1
    endif
    for i = 0, n_elements(data.BES_ch_sel1)-1 do $
      widget_control, idinfo.BES_Ch_button1[i], set_button = data.BES_ch_sel1[i]
    for i = 0, n_elements(data.BES_RAD_ch_sel1)-1 do $
      widget_control, idinfo.RAD_Ch_button1[i], set_button = data.BES_RAD_ch_sel1[i]
    for i = 0, n_elements(data.BES_POL_ch_sel1)-1 do $
      widget_control, idinfo.POL_Ch_button1[i], set_button = data.BES_POL_ch_sel1[i]
    for i = 0, n_elements(data.BES_ch_sel2)-1 do $
      widget_control, idinfo.BES_Ch_button2[i], set_button = data.BES_ch_sel2[i]
    for i = 0, n_elements(data.BES_RAD_ch_sel2)-1 do $
      widget_control, idinfo.RAD_Ch_button2[i], set_button = data.BES_RAD_ch_sel2[i]
    for i = 0, n_elements(data.BES_POL_ch_sel2)-1 do $
      widget_control, idinfo.POL_Ch_button2[i], set_button = data.BES_POL_ch_sel2[i]
    str = string(data.freq_filter_low, format='(f0.1)')
    widget_control, idinfo.freq_filter_low_text, set_value = str
    str = string(data.freq_filter_high, format='(f0.1)')
    widget_control, idinfo.freq_filter_high_text, set_value = str
    str = string(data.time_delay_low, format='(f0.1)')
    widget_control, idinfo.time_delay_low_text, set_value = str
    str = string(data.time_delay_high, format='(f0.1)')
    widget_control, idinfo.time_delay_high_text, set_value = str
    str = string(data.num_bins_to_average_vt, format='(i0)')
    widget_control, idinfo.num_bins_to_average_vt_text, set_value = str
    widget_control, idinfo.frac_overlap_subwindow_vt_slider, set_value = fix(data.frac_overlap_subwindow_vt * 10)
    str = string(data.frac_overlap_subwindow_vt, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_vt_label, set_value = str
    widget_control, idinfo.use_hanning_window_vt_combo, set_combobox_select = data.use_hanning_window_vt
    widget_control, idinfo.remove_large_structure_combo, set_combobox_select = data.remove_large_structure
    widget_control, idinfo.apply_median_filter_button, set_button = data.apply_median_filter
    str = string(data.median_filter_width, format='(i0)')
    widget_control, idinfo.median_filter_width_text, set_value = str
    widget_control, idinfo.median_filter_width_text, sensitive = data.apply_median_filter
    widget_control, idinfo.apply_field_method_button, set_button = data.apply_field_method
    widget_control, idinfo.apply_field_method_button, sensitive = data.apply_median_filter
    str = string(data.num_time_pts_field_method, format='(i0)')
    widget_control, idinfo.num_time_pts_field_method_text, set_value = str
    str = string(data.allowed_mult_sd, format='(f0.1)')
    widget_control, idinfo.allowed_mult_sd_text, set_value = str
    if ( (data.apply_median_filter eq 1) and (data.apply_field_method) ) then begin
      widget_control, idinfo.num_time_pts_field_method_text, sensitive = 1
      widget_control, idinfo.allowed_mult_sd_text, sensitive = 1
    endif else begin
      widget_control, idinfo.num_time_pts_field_method_text, sensitive = 0
      widget_control, idinfo.allowed_mult_sd_text, sensitive = 0
    endelse
    widget_control, idinfo.calc_spectrogram_combo, set_combobox_select = data.calc_spectrogram
    widget_control, idinfo.calc_phase_combo, set_combobox_select = data.calc_phase
    widget_control, idinfo.num_pts_per_subwindow_vf_combo, get_value = compare_str
    inx = where(data.num_pts_per_subwindow_vf eq compare_str, count)
    if count le 0 then inx = 0
    widget_control, idinfo.num_pts_per_subwindow_vf_combo, set_combobox_select = inx
    str = string(data.num_bins_to_average_vf, format='(i0)')
    widget_control, idinfo.num_bins_to_average_vf_text, set_value = str
    widget_control, idinfo.num_bins_to_average_vf_text, sensitive = data.calc_spectrogram
    widget_control, idinfo.frac_overlap_subwindow_vf_slider, set_value = fix(data.frac_overlap_subwindow_vf * 10)
    str = string(data.frac_overlap_subwindow_vf, format='(f0.1)')
    widget_control, idinfo.frac_overlap_subwindow_vf_label, set_value = str
    widget_control, idinfo.use_hanning_window_vf_combo, set_combobox_select = data.use_hanning_window_vf
    widget_control, idinfo.norm_by_DC_combo, set_combobox_select = data.norm_by_DC

  endif

; replot the time selection window
  widget_control, info.id.main_window.time_sel_draw, get_uvalue = plotdata
  if plotdata.curr_num_plots gt 0 then $
    replot_time_sel_window, info
; show the comments if not empty
  comment_size = size(comment, /dim)
  comment_size = comment_size[0]
  print_comment = 0
  for i = 0, comment_size - 1 do begin
    if (comment[i] ne '') then print_comment = 1
  endfor
  if print_comment eq 1 then dummy = dialog_message(comment, title = 'Comments about this option')


  return, result

end