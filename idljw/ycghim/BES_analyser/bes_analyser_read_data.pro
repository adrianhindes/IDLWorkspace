;===================================================================================
;
; This file contains following functions and procedures to read the MAST data
;   for bes_analyser:
;
;  1) read_plasma_current_data
;     --> read plasma current ('amc_plasma current')
;  2) read_plasma_density_data
;     --> read line integrated plasma density ('ane_density')
;  3) read_ss_total_power_data
;     --> read SS beam total power ('anb_ss_sum_power')
;  4) read_dalpha_data
;     --> read dalpha data ('aim_da/hm10/t')
;  5) read_APD_setting:
;     --> reads the APD camera settnig for the specified shot number
;  6) read_bes_data:
;     --> reads either experimental or synthetic BES data.
;  7) load_data_for_time_sel_win
;     --> loads the necessary data for time_sel_window plot
;  8) load_bes_data:
;     --> loads the bes data
;     --> Note: this function is a wrap-up code of read_bes_data function
;
;===================================================================================


;===================================================================================
; This function read the plasma current
;===================================================================================
; The function parameters:
;   1) shot: <integer> shot number of the MAST experiment
;   2) msg_box_on: <integer> if 1, then IDL message box is ON.
;                            if 0, then IDL message box is OFF.
;   3) msg_text_id: <long> ID of the IDL message box window.
;===================================================================================
; Return value:
;   1) result: <structure>
;===================================================================================
function read_plasma_current_data, shot, msg_box_on, msg_text_id

; define return variable structure
  result = {erc:0l, $		;error number.  This is 0, if no error occured.
            errmsg:''} 	;string of error message if erc is not 0.

; get the plasma current
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Reading Plasma Current...', /append, /no_newline
  endif
  ds = getdata('amc_plasma current', shot)
  if ds.erc ne 0 then begin
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'FAILED!', /append
    endif
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
  endif

  time = ds.time
  data = ds.data

  result = create_struct(result, 'time', time, 'data', data)

  return, result

end


;===================================================================================
; This function read the plasma density
;===================================================================================
; The function parameters:
;   1) shot: <integer> shot number of the MAST experiment
;   2) msg_box_on: <integer> if 1, then IDL message box is ON.
;                            if 0, then IDL message box is OFF.
;   3) msg_text_id: <long> ID of the IDL message box window.
;===================================================================================
; Return value:
;   1) result: <structure>
;===================================================================================
function read_plasma_density_data, shot, msg_box_on, msg_text_id

; define return variable structure
  result = {erc:0l, $		;error number.  This is 0, if no error occured.
            errmsg:''} 	;string of error message if erc is not 0.

; get the plasma density
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Reading Line Integrated Plasma Density...', /append, /no_newline
  endif
  ds = getdata('ane_density', shot)
  if ds.erc ne 0 then begin
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'FAILED!', /append
    endif
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
  endif

  time = ds.time
  data = ds.data

  result = create_struct(result, 'time', time, 'data', data)

  return, result

end


;===================================================================================
; This function read the SS Beam Total Power
;===================================================================================
; The function parameters:
;   1) shot: <integer> shot number of the MAST experiment
;   2) msg_box_on: <integer> if 1, then IDL message box is ON.
;                            if 0, then IDL message box is OFF.
;   3) msg_text_id: <long> ID of the IDL message box window.
;===================================================================================
; Return value:
;   1) result: <structure>
;===================================================================================
function read_ss_total_power_data, shot, msg_box_on, msg_text_id

; define return variable structure
  result = {erc:0l, $		;error number.  This is 0, if no error occured.
            errmsg:''} 	;string of error message if erc is not 0.

; get the SS Beam Sum Power
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Reading SS Beam Sum Power...', /append, /no_newline
  endif
  ds = getdata('anb_ss_sum_power', shot)
  if ds.erc ne 0 then begin
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'FAILED!', /append
    endif
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
  endif

  time = ds.time
  data = ds.data

  result = create_struct(result, 'time', time, 'data', data)

  return, result

end


;===================================================================================
; This function read the D-alpha
;===================================================================================
; The function parameters:
;   1) shot: <integer> shot number of the MAST experiment
;   2) msg_box_on: <integer> if 1, then IDL message box is ON.
;                            if 0, then IDL message box is OFF.
;   3) msg_text_id: <long> ID of the IDL message box window.
;===================================================================================
; Return value:
;   1) result: <structure>
;===================================================================================
function read_dalpha_data, shot, msg_box_on, msg_text_id

; define return variable structure
  result = {erc:0l, $		;error number.  This is 0, if no error occured.
            errmsg:''} 	;string of error message if erc is not 0.

; get the dalpha
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Reading D-alpha signal...', /append, /no_newline
  endif
  ds = getdata('aim_da/hm10/t', shot)
  if ds.erc ne 0 then begin
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'FAILED!', /append
    endif
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
  endif

  time = ds.time
  data = ds.data

  result = create_struct(result, 'time', time, 'data', data)

  return, result

end

;===================================================================================
; This function read the APD settings
;===================================================================================
; The function parameters:
;   1) shot: <integer> shot number of the MAST experiment
;   2) msg_box_on: <integer> if 1, then IDL message box is ON.
;                            if 0, then IDL message box is OFF.
;   3) msg_text_id: <long> ID of the IDL message box window.
;===================================================================================
; Return value:
;   1) result: <structure>
;===================================================================================
function read_APD_setting, shot, msg_box_on, msg_text_id

; define return variable structure
  result = {erc:0l, $		;error number.  This is 0, if no error occured.
            errmsg:'', $	;string of error message if erc is not 0.
            dt:0.0, $		;BES sampling time in [seconds]
            APD_bias:0.0, $	;BES APD Bias voltage in [V]
            viewRadius:0.0}	;BES Viewing Radius (for the centre of the APD camera) in [m]

  if shot ge 27621 and shot ne 28410 then begin
  ;BES view position was fixed at 1.3 m due to vacuum leakage due to BES for these shots.
    result.dt = 0.5e-6
    result.APD_bias = 310
    result.viewRadius = 1.3
    
    return, result
  endif


; Define the NETCDF filename to read APD camera settings
  suff = '.nc'
  str1 = strtrim(string(shot, format='(i0)'), 2)
  pre = '$MAST_DATA/' + str1 + '/LATEST/xbt'
  dir = ''
  str2 = '000000'
  strput, str2, str1, 6-strlen(str1)
  filename = 'NETCDF::' + dir + pre + str2 + suff

; get the clock speed (sampling time of the BES data)
  str_dev_loc = '/devices/d3_APDcamera/clock'
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Get APD camera Sampling rate: ', /append
    msg_str = '  Reading [' + filename + ', ' + str_dev_loc + ']...'
    widget_control, msg_text_id, set_value = msg_str, /append, /no_newline
  endif
  ds = getdata(str_dev_loc, filename)
  if ds.erc ne 0 then begin
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'FAILED!', /append
    endif
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  dt = ds.data[0]
  result.dt = dt
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
    msg_str = '  Sampling Time is ' + string(dt * 1e6, format='(f0.2)') + ' microsec.'
    widget_control, msg_text_id, set_value = msg_str, /append
  endif


; get the APD Bias voltage
  str_dev_loc = '/devices/d3_APDcamera/bias'
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Get APD camera BIAS voltage ', /append
    msg_str = '  Reading [' + filename + ', ' + str_dev_loc + ']...'
    widget_control, msg_text_id, set_value = msg_str, /append, /no_newline
  endif
  ds = getdata(str_dev_loc, filename)
  if ds.erc ne 0 then begin
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'FAILED!', /append
    endif
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  APD_bias = ds.data[0]
  result.APD_bias = APD_bias
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
    msg_str = '  APD Bias voltage is ' + string(APD_bias, format='(f0.2)') + ' Volts.'
    widget_control, msg_text_id, set_value = msg_str, /append
  endif

; get the APD camera location.
;  The viewing location is the raidal location of the center of the APD camera.
  str_dev_loc = '/devices/d4_mirror/viewRadius'
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = '', /append
    widget_control, msg_text_id, set_value = 'Get APD camera Viewing Location ', /append
    msg_str = '  Reading [' + filename + ', ' + str_dev_loc + ']...'
    widget_control, msg_text_id, set_value = msg_str, /append, /no_newline
  endif
  ds = getdata(str_dev_loc, filename)
  if ds.erc ne 0 then begin
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'FAILED!', /append
    endif
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  viewRadius = ds.data[0]
  result.viewRadius = viewRadius
  if msg_box_on then begin
    widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
    msg_str = '  Viewing radius of the centre of the APD is ' + string(viewRadius, format='(f0.2)') + ' m.'
    widget_control, msg_text_id, set_value = msg_str, /append
  endif

  return, result

end


;===================================================================================
; This function read the bes data
;===================================================================================
; The function parameters:
;   1) shot: <integer> shot number of the MAST experiment
;   2) ch: <interger> contains the channel numbers whose index starts from 1 
;                            (rather than 0-indexing).
;   3) msg_box_on: <integer> if 1, then IDL message box is ON.
;                            if 0, then IDL message box is OFF.
;   4) msg_text_id: <long> ID of the IDL message box window.
;   5) synthetic: <integer> if 0, then read MAST experimental BES data.
;                           if 1, then read synthetic BES data generated by turb_gen (bloby program)
;                           if 2, then read synthetic BES data generated by ORB5
;                           if 3, then read synthetic BES data generated by GS2
;===================================================================================
; Return value:
;   1) result: <structure>
;===================================================================================
function read_bes_data, shot, ch, msg_box_on, msg_text_id, synthetic = in_synthetic

  if not keyword_set(in_synthetic) then $
    synthetic = 0 $
  else $
    synthetic = 1

; define the return variable structure
  result = {erc:0l, $			;error number.  This is 0, if no error occured.
            errmsg:''}			;string of error message if erc is not 0.

; read the experimental or synthetic BES data
  if not synthetic then begin
  ; Experimental BES data
  ; Define the NETCDF filename to read APD camera settings
    suff = '.nc'
    str1 = strtrim(string(shot, format='(i0)'), 2)
    pre = '$MAST_DATA/' + str1 + '/LATEST/xbt'
    dir = ''
    str2 = '000000'
    strput, str2, str1, 6-strlen(str1)
    filename = 'NETCDF::' + dir + pre + str2 + suff

    str1 = strtrim(string(ch, format='(i0)'), 2)
    str2 = '00'
    strput, str2, str1, 2 - strlen(str1)
    str_dev_loc = 'xbt/channel' + str2
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = '', /append
      msg_str = 'Get BES Data Ch' + strtrim(string(ch, format='(i0)'), 2)
      widget_control, msg_text_id, set_value = msg_str, /append
      msg_str = '  Reading [' + filename + ', ' + str_dev_loc + ']...'
      widget_control, msg_text_id, set_value = msg_str, /append, /no_newline
    endif
  ; read the BES data
    ds = getdata(str_dev_loc, filename)

    if ds.erc ne 0 then begin
      if msg_box_on then begin
        widget_control, msg_text_id, set_value = 'FAILED!', /append
      endif
      result.erc = ds.erc
      result.errmsg = ds.errmsg
      return, result
    endif
    if msg_box_on then begin
      widget_control, msg_text_id, set_value = 'SUCCEEDED!', /append
    endif

    time = ds.time
    i0 = 0l
    i1 = where(time lt 0.0) & i1 = i1[n_elements(i1)-1]
      
  ; remove the offset on the data
    offset_val = total(ds.data[i0:i1]) / (i1 - i0 + 1)
    data = ds.data - offset_val

    result = create_struct(result, 'time', time, 'data', data)

  endif else begin
  ; Synthetic BES data




  endelse



  return, result

end

;===================================================================================
; This function loads the data for time_sel_window plot
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
; Return value
;   result: <structure>
;     result = {erc:erc, errmsg:errmsg
;           if result.erc = 0 --> no error
;              result.erc = 1 --> error occured but not fatal error
;              result.erc = -1 --> error occured and fatal.
;           result.errmsg contains a string of error message to be displayed.
;
;  Fatal Error: if invalid shot number
;               if reading APD setting failed
;               if reading BES data failed
;  Non-fatal Error: reading other data (i.e. plasma current, etc.) failed
;===================================================================================
function load_data_for_time_sel_win, info
; define return variable
  result = {erc:0l, $
            errmsg:''}

; retrieve some data
  id = info.id.main_window
  
; first, read the shot number from the main window
  widget_control, id.shot_number_text, get_value = str_shot
  str_shot = str_shot[0]

; check the shot number whether to read the synthetic data or experimental data
; if str_shot is appended by 'b', then synthetic_data = 1
;                            'o', then synthetic_data = 2
;                            'g', then synthetic_data = 3
;                            'c', then synthetic_data = 4
  synthetic_char = strlowcase(strmid(str_shot, strlen(str_shot)-1, 1))
  if synthetic_char eq 'b' then begin
    synthetic_data_num = 1
    str_shot = strmid(str_shot, 0, strlen(str_shot)-1)
  endif else if synthetic_char eq 'o' then begin
    synthetic_data_num = 2
    str_shot = strmid(str_shot, 0, strlen(str_shot)-1)
  endif else if synthetic_char eq 'g' then begin
    synthetic_data_num = 3
    str_shot = strmid(str_shot, 0, strlen(str_shot)-1)
  endif else if synthetic_char eq 'c' then begin
    synthetic_data_num = 4
    str_shot = strmid(str_shot, 0, strlen(str_shot)-1)
  endif else begin
    synthetic_data_num = 0
  endelse

; check the validity of shot number
  valid_shot = is_valid_str_to_be_number(str_shot)
  if valid_shot ne 1 then begin	;fatal error
    error_num = 5
    result.errmsg = bes_analyser_error_list(error_num)
    result.erc = -1
    widget_control, id.shot_number_text, set_value = string(info.main_window_data.BES_data.shot, format='(i0)')
    return, result
  endif

; now, shot number is valid.
  shot = long(str_shot)

; check the validity of spike_remover
; A user must know that to update the spike_remover, he/she must hit 'Load' button on the main window because
;   this is only routine where spike_remover is saved under info.main_window_data throughout the program.
  widget_control, id.spike_remover_text, get_value = str_spike_remover
  str_spike_remover = str_spike_remover[0]
  valid_spike_rem = is_valid_str_to_be_number(str_spike_remover)
  if valid_spike_rem ne 1 then begin	;if not valid, then force spike_remover to be 0.0, i.e. no spike removing
    spike_remover = 0.0
    widget_control, id.spike_remover_text, set_value = string(spike_remover, format = '(f0.2)')
  endif else begin
    spike_remover = float(str_spike_remover)
  endelse
  info.main_window_data.spike_remover = spike_remover

; load the synthetic data
  if synthetic_data_num ne 0 then begin
    fpath = '~/BES/synthetic_data/'
;    fpath = '/home/yckim/BES/synthetic_data/'
    case synthetic_data_num of
      1: fpath = fpath + 'bloby_turb/'
      2: fpath = fpath + 'orb5/'
      3: fpath = fpath + 'gs2/'
      4: fpath = fpath + 'centori/'
    endcase
    fname = fpath + str_shot +'.sav'
    if info.main_window_data.IDL_msg_box_window_ON then begin
      widget_control, info.id.IDL_msg_box_window.msg_text, set_value = '', /append
      msg_str  = 'Loading the synthetic data: ' + fname + '...'
      widget_control, info.id.IDL_msg_box_window.msg_text, set_value = msg_str, /append, /no_newline
    endif

    openr, in_file, fname, error = error_status, /get_lun
    if error_status ne 0 then begin
      result.erc = -1
      result.errmsg = bes_analyser_error_list(27)
      widget_control, id.shot_number_text, set_value = string(info.main_window_data.BES_data.shot, format='(i0)')
      return, result
    endif
    free_lun, in_file

    restore, fname	;now, synthetic_data is available

    if info.main_window_data.IDL_msg_box_window_ON then begin
      widget_control, info.id.IDL_msg_box_window.msg_text, set_value = 'DONE!', /append
    endif
    widget_control, id.shot_number_text, set_value = string(shot, format='(i0)')

    info.main_window_data.BES_data.shot = shot
    info.main_window_data.BES_data.viewRadius = synthetic_data.bes_pos
    info.main_window_data.BES_data.dt =  synthetic_data.dt
    info.main_window_data.BES_data.ptr_time = ptr_new(synthetic_data.tvector)
    for i = 0, 31 do begin
      info.main_window_data.BES_data.ptr_data[i] = ptr_new(reform(synthetic_data.density[i mod 8, fix(i/8), *]))
    endfor
    info.main_window_data.BES_data.loaded_ch[*] = 1
    info.main_window_data.BES_data.synthetic_data = synthetic_data_num

  ;create xdisplay for the file info
    str_finfo = 'This is the information of the loaded synthetic BES data.' + string(10b) + $
                'Turbulence Generator: '
    case synthetic_data_num of
      1: str_finfo = str_finfo + 'bloby turbulent generator.' + string(10b)
      2: str_finfo = str_finfo + 'ORB5.' + string(10b)
      3: str_finfo = str_finfo + 'GS2.' + string(10b)
      4: str_finfo = str_finfo + 'CENTORI.' + string(10b)
    endcase
    struct_tag_names = TAG_NAMES(synthetic_data)
    struct_tag_names = STRLOWCASE(struct_tag_names)
    struct_inx = WHERE(struct_tag_names eq 'data_fname', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'Original Turbulence Data File: ' + synthetic_data.data_fname + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'psf_fname', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'PSF Data File: ' + synthetic_data.psf_fname + string(10b)
    str_finfo = str_finfo + 'Synthetic Data File: ' + fname + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'snr', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'SNR: ' + string(synthetic_data.SNR, format = '(f0.2)') + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'dc_value', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'Signal DC Level: ' + string(synthetic_data.DC_VALUE, format = '(f0.3)') + ' [V]' + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'noise_rms', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'Noise RMS: ' + string(synthetic_data.Noise_RMS, format = '(f0.0)') + ' [V]' + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'di_dc', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'Fluctuation Level (dI/I): ' + string(synthetic_data.dI_DC * 100.0, format = '(f0.2)') + ' [%]' + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'di_rms', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'dI RMS: ' + string(synthetic_data.dI_RMS, format = '(f0.0)') + ' [V]' + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'di_rms_noise_rms', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'dI_RMS/Noise_RMS: ' + string(synthetic_data.dI_RMS_Noise_RMS, format = '(f0.0)') + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'global_dc', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'Global Mode Fluctuation Level: ' + string(synthetic_data.global_DC*100.0, format = '(f0.2)') + ' [%]' + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'global_rms', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'Global Mode RMS: ' + string(synthetic_data.global_RMS, format = '(f0.0)') + ' [V]' + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'global_freq', struct_count)
    if struct_count gt 0 then $
      str_finfo = str_finfo + 'Global Mode Frequency: ' + string(synthetic_data.global_freq, format = '(f0.2)') + ' [kHz]' + string(10b)
    struct_inx = WHERE(struct_tag_names eq 'mean_vel', struct_count)
    if struct_count gt 0 then begin
      str_finfo = str_finfo + 'Mean Velocity of each radial location (from out to in): ' + string(10b)
      str_finfo_add = ''
      for i = 0, 7 do begin
        str_finfo_add += '   ' + string(synthetic_data.mean_vel[i] * 1e-3, format = '(f0.3)') + ' [km/s]' + string(10b)
      endfor
      str_finfo = str_finfo + str_finfo_add
    endif
    xdisplayfile, title = 'Information of the loaded synthetic BES data', text = str_finfo, group = info.id.main_window.main_base


    goto, save_info 
  endif

; Check if APD settings for the specified shot has been loaded before.
; If not, load the APD settings.
  if shot ne info.main_window_data.BES_data.shot then begin
  ; Read the APD settings
    APD_result = read_APD_setting(shot, info.main_window_data.IDL_msg_box_window_ON, info.id.IDL_msg_box_window.msg_text)
    if APD_result.erc ne 0 then begin	;fatal error
    ; reading APD settings is failed.
      result.errmsg = 'APD Settings: ' + APD_result.errmsg
      result.erc = -1
      widget_control, id.shot_number_text, set_value = string(info.main_window_data.BES_data.shot, format='(i0)')
      return, result
    endif
    ; reading APD settings is successful.
      info.main_window_data.BES_data.shot = shot
      info.main_window_data.BES_data.APD_bias = APD_result.APD_bias
      info.main_window_data.BES_data.viewRadius = APD_result.viewRadius
      info.main_window_data.BES_data.dt = APD_result.dt
      info.main_window_data.BES_data.synthetic_data = synthetic_data_num
    ; reset the loaded_ch info because this is a new shot number
      info.main_window_data.BES_data.loaded_ch[*] = 0
      ptr_free, info.main_window_data.BES_data.ptr_time
      ptr_free, info.main_window_data.BES_data.ptr_data
    ;save info
      widget_control, id.main_base, set_uvalue = info
  endif

; load the BES data
  first_load = 1
  for i = 0, 31 do begin
  ; load the BES data if BES_ch is selected and this channel is not loaded, yet.
    if ( (info.time_sel_window_data.BES_ch_sel[i] eq 1) and $
         (info.main_window_data.BES_data.loaded_ch[i] eq 0) ) then begin
      BES_result = read_bes_data(shot, i+1, info.main_window_data.IDL_msg_box_window_ON, info.id.IDL_msg_box_window.msg_text)
      if BES_result.erc ne 0 then begin	;fatal error
      ; there was an error during reading BES data
        result.errmsg = 'BES Ch.' + string(i+1, format='(i0)') + ' Data: ' + BES_result.errmsg
        result.erc = -1
        return, result
      endif
      info.main_window_data.BES_data.loaded_ch[i] = 1
      if first_load eq 1 then begin
        first_load = 0
        info.main_window_data.BES_data.ptr_time = ptr_new(BES_result.time)
      endif
      info.main_window_data.BES_data.ptr_data[i] = ptr_new(BES_result.data)
    endif
  endfor

; Load the plasma current data
  if info.time_sel_window_data.plasma_current_sel eq 1 then begin
    if shot ne info.main_window_data.plasma_current_data.shot then begin
      info.main_window_data.plasma_current_data.shot = shot
      info.main_window_data.plasma_current_data.loaded = 0
      ptr_free, info.main_window_data.plasma_current_data.ptr_time
      ptr_free, info.main_window_data.plasma_current_data.ptr_data
    endif
    if info.main_window_data.plasma_current_data.loaded eq 0 then begin
      plasma_current_result = read_plasma_current_data(shot, info.main_window_data.IDL_msg_box_window_ON, info.id.IDL_msg_box_window.msg_text)
      if plasma_current_result.erc ne 0 then begin ;not fatal error
      ; an error occured during the reading plasma current
        result.errmsg = result.errmsg + string(10b) + 'Plasma Current Data: ' + plasma_current_result.errmsg
        result.erc = 1
      endif else begin
      ; plasma current was successfully read.
        info.main_window_data.plasma_current_data.loaded = 1
        info.main_window_data.plasma_current_data.ptr_time = ptr_new(plasma_current_result.time)
        info.main_window_data.plasma_current_data.ptr_data = ptr_new(plasma_current_result.data)
      endelse
    endif
  endif

; Load the Plasma Density data
  if info.time_sel_window_data.plasma_density_sel eq 1 then begin
    if shot ne info.main_window_data.plasma_density_data.shot then begin
      info.main_window_data.plasma_density_data.shot = shot
      info.main_window_data.plasma_density_data.loaded = 0
      ptr_free, info.main_window_data.plasma_density_data.ptr_time
      ptr_free, info.main_window_data.plasma_density_data.ptr_data
    endif
    if info.main_window_data.plasma_density_data.loaded eq 0 then begin
      plasma_density_result = read_plasma_density_data(shot, info.main_window_data.IDL_msg_box_window_ON, info.id.IDL_msg_box_window.msg_text)
      if plasma_density_result.erc ne 0 then begin
      ; there was an error during reading plasma density
        result.errmsg = result.errmsg + string(10b) + 'Plasma Density Data: ' + plasma_density_result.errmsg
        result.erc = 1
      endif else begin
      ; reading the data was successful
        info.main_window_data.plasma_density_data.loaded = 1
        info.main_window_data.plasma_density_data.ptr_time = ptr_new(plasma_density_result.time)
        info.main_window_data.plasma_density_data.ptr_data = ptr_new(plasma_density_result.data)
      endelse
    endif
  endif

; Load the SS Beam data
  if info.time_sel_window_data.SS_beam_sel eq 1 then begin
    if shot ne info.main_window_data.SS_beam_data.shot then begin
      info.main_window_data.SS_beam_data.shot = shot
      info.main_window_data.SS_beam_data.loaded = 0
      ptr_free, info.main_window_data.SS_beam_data.ptr_time
      ptr_free, info.main_window_data.SS_beam_data.ptr_data
    endif
    if info.main_window_data.SS_beam_data.loaded eq 0 then begin
      ss_beam_result = read_ss_total_power_data(shot, info.main_window_data.IDL_msg_box_window_ON, info.id.IDL_msg_box_window.msg_text)
      if ss_beam_result.erc ne 0 then begin
      ; there was an error during reading SS beam data
        result.errmsg = result.errmsg + string(10b) + 'SS Beam Total Power Data: ' + ss_beam_result.errmsg
        result.erc = 1
      endif else begin
      ; reading the data was successful
        info.main_window_data.SS_beam_data.loaded = 1
        info.main_window_data.SS_beam_data.ptr_time = ptr_new(ss_beam_result.time)
        info.main_window_data.SS_beam_data.ptr_data = ptr_new(ss_beam_result.data)
      endelse
    endif
  endif

; Load the Dalpha data
  if info.time_sel_window_data.dalpha_sel eq 1 then begin
    if shot ne info.main_window_data.dalpha_data.shot then begin
      info.main_window_data.dalpha_data.shot = shot
      info.main_window_data.dalpha_data.loaded = 0
      ptr_free, info.main_window_data.dalpha_data.ptr_time
      ptr_free, info.main_window_data.dalpha_data.ptr_data
    endif
    if info.main_window_data.dalpha_data.loaded eq 0 then begin
      dalpha_data_result = read_dalpha_data(shot, info.main_window_data.IDL_msg_box_window_ON, info.id.IDL_msg_box_window.msg_text)
      if dalpha_data_result.erc ne 0 then begin
      ; there was an error during reading D-alpha data
        result.errmsg = result.errmsg + string(10b) + 'D-alpha Data: ' + dalpha_data_result.errmsg
        result.erc = 1
      endif else begin
      ; read the data was successful
        info.main_window_data.dalpha_data.loaded = 1
        info.main_window_data.dalpha_data.ptr_time = ptr_new(dalpha_data_result.time)
        info.main_window_data.dalpha_data.ptr_data = ptr_new(dalpha_data_result.data)
      endelse
    endif
  endif

save_info:

;save info
  widget_control, id.main_base, set_uvalue = info

  return, result

end


;===================================================================================
; This function loads the BES data for general purporse
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2). 'BES_ch' is a 1D array containing the BES channel numbers (index base 1) to be loaded.
;===================================================================================
; Return value
;   result: <structure>
;     result = {erc:erc, errmsg:errmsg
;           if result.erc = 0 --> no error
;              result.erc = -1 --> error occured and fatal.
;           result.errmsg contains a string of error message to be displayed.
;
;  Fatal Error: if invalid shot number
;               if reading APD setting failed
;               if reading BES data failed
;===================================================================================
function load_bes_data, info, BES_ch
; define return variable
  result = {erc:0l, $
            errmsg:''}

; retrieve some data
  id = info.id.main_window

; first, read the shot number from the main window
  widget_control, id.shot_number_text, get_value = str_shot
  str_shot = str_shot[0]

; check the validify of shot number
  valid_shot = is_valid_str_to_be_number(str_shot)
  if valid_shot ne 1 then begin	;fatal error
    error_num = 5
    result.errmsg = bes_analyser_error_list(error_num)
    result.erc = -1
    widget_control, id.shot_number_text, set_value = string(info.main_window_data.BES_data.shot, format='(i0)')
    return, result
  endif

; now, shot number is valid.
  shot = long(str_shot)

; Check if APD settings for the specified shot has been loaded before.
; If not, ask the user to load it from time selectin plot.
  if shot ne info.main_window_data.BES_data.shot then begin
    result.errmsg = 'Load the BES APD setting first from <Option for Time Selection Plot>'
    result.erc = -1
    return, result
  endif

; Load the selected BES data channels only if they are not yet loaded.
  temp_inx = where(info.main_window_data.BES_data.loaded_ch eq 1, count)
  if count le 0 then $
    first_load = 1 $
  else $
    first_load = 0

  for i = 0, n_elements(BES_ch) - 1 do begin
    if info.main_window_data.BES_data.loaded_ch[BES_ch[i]-1] ne 1 then begin
    ;load the selected BES channel
      BES_result = read_bes_data(shot, BES_ch[i], info.main_window_data.IDL_msg_box_window_ON, $
                                                  info.id.IDL_msg_box_window.msg_text)
      if BES_result.erc ne 0 then begin
      ; there was an error during read_bes_data call
        result.errmsg = 'BES Ch.' + string(BES_ch[i], format='(i0)') + ' Data: ' + BES_result.errmsg
        result.erc = -1
        return, result
      endif
      info.main_window_data.BES_data.loaded_ch[BES_ch[i]-1] = 1
      if first_load eq 1 then begin
        first_load = 0
        info.main_window_data.BES_data.ptr_time = ptr_new(BES_result.time)
      endif 
      info.main_window_data.BES_data.ptr_data[BES_ch[i]-1] = ptr_new(BES_result.data)
    endif
  endfor

; save the info
  widget_control, info.id.main_window.main_base, set_uvalue = info

  return, result
end


