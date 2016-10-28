;===================================================================================
;
; This file contains following functions and procedures to control the result data for output
;
;  1) ctrl_plot_raw_bes_data
;     --> controls to plot raw bes data
;
;  2) ctrl_plot_rms_dc_bes_data
;     --> controls to plot the BES RMS/DC data.
;
;  3) ctrl_plot_bes_animation
;     --> controls to plot the BES animation
;
;  4) ctrl_plot_dens_spec
;     --> controls to plot the density spectrum or spectrogram
;
;  5) ctrl_plot_dens_coh
;     --> controls to plot the densicy coherency
;
;  6) ctrl_plot_dens_temp_corr
;     --> controls to plot the density tempoaral correlation function
;
;  7) ctrl_plot_dens_spa_temp_corr
;     --> controls to plot the density spatio-temporal correlation function
;
;  8) ctrl_plot_vel_evol
;     --> control to plot the time evolution of eddy pattern velocity
;
;  9) ctrl_plot_vel_spec
;     --> control to plot the spectrum of pattern velocity
;
; 10) ctrl_plot_flux_surface
;     --> control to plot the flux surface with BES positions
;
; 11) ctrl_plot_dens_spa_spa_corr
;     --> controls to plot the density spatio-spatio correlation function
;
;===================================================================================




;===================================================================================
; This function control for plotting raw BES data
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_time_evol_window
;   2) 'overplot' is a keyword.
;                 If this is set, then overplot the data.
;                 If this is not set, then plot the data as new data sets.
;                 NOTE: if overplot is set, then plotdata.type must be compatiable with
;                       the currently drawn data.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_raw_bes_data, idinfo, overplot=in_overplot

; keyword check
  if keyword_set(in_overplot) then $
    overplot = 1 $
  else $
    overplot = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check the selected BES channels
  BES_ch = 0
  for i = 0, 31 do begin
    if info.bes_time_evol_window_data.BES_ch_sel[i] eq 1 then $
      BES_ch = [BES_ch, i+1]
  endfor
  if n_elements(BES_ch) eq 1 then begin
    err_num = 19
    errmsg = bes_analyser_error_list(err_num)
    result.erc = err_num
    result.errmsg = errmsg
    return, result
  endif else begin
    BES_ch = BES_ch[1:n_elements(BES_ch)-1]
  endelse

; load the BES signals
  nplots = n_elements(BES_ch)
; Load the BES signals
  load_result = load_bes_data(info, BES_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif else begin
  ; no error occured during the load_bes_data call.
  ; Get the plotdata, first
    widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

  ; set and check the plotdata
    if overplot eq 0 then begin
      total_nplots = nplots
      plotdata.type = 11
      ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
      plotdata = set_extra_plot_info(info, plotdata)
      start_inx = 0
    endif else begin 
    ;overplot type check
      if plotdata.type eq 0 then begin
        result.erc = 20
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif else if plotdata.type eq 12 then begin
        result.erc = 22
        result.errmsg = bes_analyser_error_list(result.erc)
      endif else if plotdata.type ne 11 then begin	
        result.erc = 21
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif
      total_nplots = plotdata.curr_num_plots + nplots
      start_inx = plotdata.curr_num_plots
    endelse
 
    if total_nplots gt plotdata.MAX_NUM_PLOTS then begin
      result.erc = 1
      result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                      string(10b) + 'You specified too many plots to be drawn.'
      return, result
    endif

    plotdata.curr_num_plots = total_nplots

  ; set the plotdata
    freq_filter_low = info.bes_time_evol_window_data.freq_filter_low
    freq_filter_high = info.bes_time_evol_window_data.freq_filter_high
    dt = info.main_window_data.BES_data.dt
    for i = start_inx, plotdata.curr_num_plots - 1 do begin
      data = *info.main_window_data.BES_data.ptr_data[BES_ch[i-start_inx]-1]

    ; remover spikes if spike_remover ne 0.0
      if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = '', /append
        str = 'Removing spikes (neutrons peaks) from BES data with dV = ' + string(info.main_window_data.spike_remover, format = '(f0.2)') + '...'
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = str, /append, /no_newline
      endif
      data = perform_spike_remover(data, info.main_window_data.spike_remover)
      if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = 'DONE!', /append
      endif

    ; perform freq filtering
      if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = '', /append
        str = 'Filtering BES Signal Ch. ' + string(BES_ch[i-start_inx], format='(i0)') + ' from ' + $
              string(freq_filter_low, format='(f0.2)') + ' to ' + string(freq_filter_high, format='(f0.2)') + 'kHz...'
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = str, /append, /no_newline
      endif
      filter_result = freq_filter_signal(data, freq_filter_low, freq_filter_high, dt) 
      filtered_data = filter_result.filtered_signal[filter_result.inx_nonzero_begin:filter_result.inx_nonzero_end]
      time = *info.main_window_data.BES_data.ptr_time
      time = time[filter_result.inx_nonzero_begin:filter_result.inx_nonzero_end]
      if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = 'DONE!', /append
      endif
      plotdata.ptr_x[i] = ptr_new(time)
      plotdata.ptr_y[i] = ptr_new(filtered_data)
      plotdata.line_color[i] = info.color_table_str[i mod n_elements(info.color_table_str)]
      plotdata.line_style[i] = fix(i/n_elements(info.color_table_str))
    endfor

  ; save the plotdata
    widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

  ; plot the loaded data.
    if overplot eq 0 then $
      plot_result_window, info $
    else $
      plot_result_window, info, nplot = nplots

  ; print the notes about about the plotdata
    for i = start_inx, plotdata.curr_num_plots - 1 do begin
      str = '<Line ' + string(i+1, format='(i0)') + '> ' + plotdata.line_color[i]
      case plotdata.line_style[i] of
        0: str = str + ' Solid' + string(10b)
        1: str = str + ' Dotted' + string(10b)
        2: str = str + ' Dashed' + string(10b)
        3: str = str + ' Dash Dot' + string(10b)
        4: str = str + 'Dash Dot Dot' + string(10b)
        5: str = str + 'Long Dasehs' + string(10b)
        else: str = str + string(10b)
      endcase
      str = str + $
            '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
            '  BES Channel: ' + string(BES_ch[i-start_inx], format='(i0)') + string(10b) + $
            '  Data: RAW BES signal' + string(10b) + $
            '  Data Dim.: [V]' + string(10b) + $
            '  R Pos. [cm] = ' + string( ((((BES_ch[i-start_inx]-1) mod 8)-3.5) * (-2.0)) + info.main_window_data.BES_data.viewRadius * 100.0, $
                                                  format = '(f0.1)') + string(10b) + $
            '  Z Pos. [cm] = ' + string(  ((fix((BES_ch[i-start_inx]-1) / 8) - 1.5) * 2.0), format='(f0.1)') + string(10b) + $
            '  dt [microsec] = ' + string(info.main_window_data.BES_data.dt * 1e6, format='(f0.2)') + string(10b) + $
            '  APD Bias [V] = ' + string(info.main_window_data.BES_data.APD_bias, format='(f0.1)') + string(10b) + $
            '  Freq. Filter [kHz] = [' + string(freq_filter_low, format='(f0.1)') + ', ' + $
                                         string(freq_filter_high, format='(f0.1)') + ']'
      if i eq 0 then $
        widget_control, info.id.main_window.result_info_text, set_value = str $
      else begin
        widget_control, info.id.main_window.result_info_text, set_value = '', /append
        widget_control, info.id.main_window.result_info_text, set_value = str, /append
      endelse
    endfor

  endelse

  return, result

end


;===================================================================================
; This function control for plotting BES RMS/DC data
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_rms_dc_time_evol_window
;   2) 'overplot' is a keyword.
;                 If this is set, then overplot the data.
;                 If this is not set, then plot the data as new data sets.
;                 NOTE: if overplot is set, then plotdata.type must be compatiable with
;                       the currently drawn data.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_rms_dc_bes_data, idinfo, overplot = in_overplot

; keyword check
  if keyword_set(in_overplot) then $
    overplot = 1 $
  else $
    overplot = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check the selected BES channels
  BES_ch = 0
  for i = 0, 31 do begin
    if info.rms_dc_time_evol_window_data.BES_ch_sel[i] eq 1 then $
      BES_ch = [BES_ch, i+1]
  endfor
  if n_elements(BES_ch) eq 1 then begin
    err_num = 19
    errmsg = bes_analyser_error_list(err_num)
    result.erc = err_num
    result.errmsg = errmsg
    return, result
  endif else begin
    BES_ch = BES_ch[1:n_elements(BES_ch)-1]
  endelse

; load the BES signals
  nplots = n_elements(BES_ch)
; Load the BES signals
  load_result = load_bes_data(info, BES_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif else begin
  ; no error occured during the load_bes_data call.
  ; Get the plotdata, first
    widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

  ; set and check the plotdata
    if overplot eq 0 then begin
      total_nplots = nplots
      plotdata.type = 12
      ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
      plotdata = set_extra_plot_info(info, plotdata)
      start_inx = 0
    endif else begin 
    ;overplot type check
      if plotdata.type eq 0 then begin
        result.erc = 20
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif else if plotdata.type eq 11 then begin
        result.erc = 22
        result.errmsg = bes_analyser_error_list(result.erc)
      endif else if plotdata.type ne 12 then begin
        result.erc = 21
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif
      total_nplots = plotdata.curr_num_plots + nplots
      start_inx = plotdata.curr_num_plots
    endelse

    if total_nplots gt plotdata.MAX_NUM_PLOTS then begin
      result.erc = 1
      result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                      string(10b) + 'You specified too many plots to be drawn.'
      return, result
    endif

    plotdata.curr_num_plots = total_nplots

  ; set the plotdata
    avg_nt = info.rms_dc_time_evol_window_data.avg_nt
    use_LPF_for_DC = info.rms_dc_time_evol_window_data.use_LPF_for_DC
    DC_freq_filter_high = info.rms_dc_time_evol_window_data.DC_freq_filter_high
    RMS_freq_filter_low = info.rms_dc_time_evol_window_data.RMS_freq_filter_low
    RMS_freq_filter_high = info.rms_dc_time_evol_window_data.RMS_freq_filter_high
    subtract_DC = info.rms_dc_time_evol_window_data.subtract_DC
    in_dt = info.main_window_data.BES_data.dt
    in_time = *info.main_window_data.BES_data.ptr_time
    for i = start_inx, plotdata.curr_num_plots - 1 do begin
      in_data = *info.main_window_data.BES_data.ptr_data[BES_ch[i-start_inx]-1]

    ; remover spikes if spike_remover ne 0.0
      if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = '', /append
        str = 'Removing spikes (neutrons peaks) from BES data with dV = ' + string(info.main_window_data.spike_remover, format = '(f0.2)') + '...'
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = str, /append, /no_newline
      endif
      in_data = perform_spike_remover(in_data, info.main_window_data.spike_remover)
      if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = 'DONE!', /append
      endif

      if use_LPF_for_DC then begin
        rms_dc_result = calc_rms_over_dc(in_time, in_data, in_dt, avg_nt, BES_ch[i-start_inx], $
                                         subtract_DC = subtract_DC, $
                                         DC_freq_filter = DC_freq_filter_high, $
                                         RMS_freq_filter = [RMS_freq_filter_low, RMS_freq_filter_high], $
                                         write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                         ID_msg_box = info.id.IDL_msg_box_window.msg_text)
      endif else begin
        rms_dc_result = calc_rms_over_dc(in_time, in_data, in_dt, avg_nt, BES_ch[i-start_inx], $
                                         subtract_DC = subtract_DC, $
                                         RMS_freq_filter = [RMS_freq_filter_low, RMS_freq_filter_high], $
                                         write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                         ID_msg_box = info.id.IDL_msg_box_window.msg_text)
      endelse

      if rms_dc_result.erc ne 0 then begin
        result.erc = rms_dc_result.erc
        result.errmsg = rms_dc_result.errmsg
        return, result
      endif

      plotdata.ptr_x[i] = ptr_new(rms_dc_result.time)
      plotdata.ptr_y[i] = ptr_new(rms_dc_result.data)
      plotdata.line_color[i] = info.color_table_str[i mod n_elements(info.color_table_str)]
      plotdata.line_style[i] = fix(i/n_elements(info.color_table_str))
    endfor

  ; save the plotdata
    widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

  ; plot the loaded data.
    if overplot eq 0 then $
      plot_result_window, info $
    else $
      plot_result_window, info, nplot = nplots

  ; print the notes about about the plotdata
    for i = start_inx, plotdata.curr_num_plots - 1 do begin
      str = '<Line ' + string(i+1, format='(i0)') + '> ' + plotdata.line_color[i]
      case plotdata.line_style[i] of
        0: str = str + ' Solid' + string(10b)
        1: str = str + ' Dotted' + string(10b)
        2: str = str + ' Dashed' + string(10b)
        3: str = str + ' Dash Dot' + string(10b)
        4: str = str + 'Dash Dot Dot' + string(10b)
        5: str = str + 'Long Dasehs' + string(10b)
        else: str = str + string(10b)
      endcase
      str = str + $
            '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
            '  BES Channel: ' + string(BES_ch[i-start_inx], format='(i0)') + string(10b) + $
            '  Data: BES RMS/DC' + string(10b) + $
            '  Data Dim.: [-]' + string(10b) + $
            '  R Pos. [cm] = ' + string( ((((BES_ch[i-start_inx]-1) mod 8)-3.5) * (-2.0)) + info.main_window_data.BES_data.viewRadius * 100.0, $
                                                  format = '(f0.1)') + string(10b) + $
            '  Z Pos. [cm] = ' + string(  ((fix((BES_ch[i-start_inx]-1) / 8) - 1.5) * 2.0), format='(f0.1)') + string(10b) + $
            '  dt [microsec] = ' + string(avg_nt * in_dt * 1e6, format='(f0.2)') + string(10b) + $
            '  DC: '
      if use_LPF_for_DC then begin
        str = str + '[0.0, ' + string(DC_freq_filter_high, format='(f0.1)') + '] kHz' + string(10b)
      endif else begin
        str = str + 'Averaged (' + string(avg_nt, format='(i0)') + ' pts).' + string(10b)
      endelse
      str = str + '  RMS: [' + string(RMS_freq_filter_low, format='(f0.1)') + ', ' + $
                               string(RMS_freq_filter_high, format='(f0.1)') + '] kHz'
      if i eq 0 then $
        widget_control, info.id.main_window.result_info_text, set_value = str $
      else begin
        widget_control, info.id.main_window.result_info_text, set_value = '', /append
        widget_control, info.id.main_window.result_info_text, set_value = str, /append
      endelse
    endfor

  endelse

  return, result

end


;===================================================================================
; This function control to plot BES animation
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_animation_window
;   2) 'animation' is a keyword.
;                 If this is set, animation will start
;                 If this is not set, then only the very first time index is plotted. 
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_bes_animation, idinfo, animation = in_animation


; keyword check
  if keyword_set(in_animation) then $
    animation = 1 $
  else $
    animation = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check the selected time regions
  if info.time_sel_struct.curr_num_time_regions lt 1 then begin
    result.erc = 257
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  if info.time_sel_struct.curr_num_time_regions gt 1 then begin
    result.erc = 258
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

; Load all the BES channels
  BES_ch = indgen(32) + 1
  load_result = load_bes_data(info, BES_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif


; extract bes_animation_window_data
  in_factor_inc_spa_pts = info.bes_animation_window_data.factor_inc_spa_pts
  in_freq_filter = [info.bes_animation_window_data.freq_filter_low, $
                    info.bes_animation_window_data.freq_filter_high]
  in_play_type = info.bes_animation_window_data.inx_play_type
  in_by_time_avg_for_DC = info.bes_animation_window_data.by_time_avg_for_DC
  in_avg_nt = info.bes_animation_window_data.avg_nt
  in_by_LPF_for_DC = info.bes_animation_window_data.by_LPF_for_DC
  in_DC_freq_filter_high = info.bes_animation_window_data.DC_freq_filter_high
  in_normalize = info.bes_animation_window_data.normalize
  in_norm_by_own_ch = info.bes_animation_window_data.norm_by_own_ch
  in_norm_by_all_ch = info.bes_animation_window_data.norm_by_all_ch

; extract BES data
  BES_data = info.main_window_data.BES_data
  in_time = *BES_data.ptr_time
  in_dt = BES_data.dt
  centre_pos = BES_data.viewRadius
  in_data = fltarr(32, n_elements(in_time))
  in_pos = fltarr(32, 2)
  for i = 0, 31 do begin
    in_data[i, *] = *BES_data.ptr_data[i]

  ; remover spikes if spike_remover ne 0.0
    if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
      if i eq 0 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = '', /append
        str = 'Removing spikes (neutrons peaks) from BES data with dV = ' + string(info.main_window_data.spike_remover, format = '(f0.2)') + $ 
              ' for Ch.: ' + string(i+1, format = '(i0)')
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = str, /append, /no_newline
      endif else begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = ' ' + string(i+1, format = '(i0)'), /append, /no_newline
      endelse
      if i eq 31 then begin
        widget_control, info.id.IDL_msg_box_window.msg_text, set_value = '  DONE!', /append
      endif
    endif
    temp_data = reform(in_data[i, *])
    in_data[i, *] = perform_spike_remover(temp_data, info.main_window_data.spike_remover)
    in_pos[i, 0] = ((i mod 8)-3.5) * (-2.0) + centre_pos * 100.0	;Major Radial position in [cm]
    in_pos[i, 1] = (fix(i/8) - 1.5) * 2.0				;Polodial position in [cm]
  endfor

; get the time range
  in_time_range = [info.time_sel_struct.time_regions[0, 0], info.time_sel_struct.time_regions[0, 1]]

; generate the BES animation
  animation_result = make_BES_animation(in_data, in_time, in_dt, in_pos, in_time_range, $
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
                                        write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                        ID_msg_box = info.id.IDL_msg_box_window.msg_text)

  if animation_result.erc ne 0 then begin
    result.erc = animation_result.erc
    result.errmsg = animation_result.errmsg
    return, result
  endif

; Get the plotdata and save it
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

  ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
  plotdata.curr_num_plots = 1
  plotdata.type = 1001
  plotdata.inx_ctable = info.bes_animation_window_data.inx_ctable
  plotdata.inv_ctable = info.bes_animation_window_data.inv_ctable
  plotdata.ptr_x[0] = ptr_new(animation_result.xvector)
  plotdata.ptr_y[0] = ptr_new(animation_result.yvector)
  plotdata.ptr_z[0] = ptr_new(animation_result.dvector)
  plotdata.ptr_t[0] = ptr_new(animation_result.tvector)
  plotdata.inx_curr_time = 0l
  plotdata.line_color[0] = info.bes_animation_window_data.col_BES_pos_str	;this is used for BES position marker
  plotdata = set_extra_plot_info(info, plotdata)

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; print the notes on BES animation
  str = '<BES Movie>' + string(10b) + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  Data: '
  if in_play_type eq 0 then $
    str = str + 'n(t)' $
  else if in_play_type eq 1 then $
    str = str + 'n1(t)' $
  else $
    str = str + 'n1(t)/n0(t)'
  str = str + string(10b) + $
        '  Data Normalized: '
  if in_normalize eq 1 then begin
    str = str + 'Yes' + string(10b)
    if in_norm_by_own_ch eq 1 then begin
      str = str + $
            '    by max of each ch.' + string(10b)
    endif else begin
      str = str + $
            '    by max of all ch.' + string(10b)
    endelse
    str = str + $
          '  Data Dim: [-]'
  endif else begin
    str = str + 'No' + string(10b)
    str = str + $
          '  Data Dim: ' 
    if in_play_type eq 2 then $
      str = str + '[-]' $
    else $
      str = str + '[V]'
  endelse
  str = str + string(10b) + $
        '  Movie Time: [' + string(animation_result.tvector[0]*1e3, format='(f0.4)') + ', ' + $
                            string(animation_result.tvector[n_elements(animation_result.tvector)-1]*1e3, format='(f0.4)') + '] msec'
  str = str + string(10b) + $
        '  Freq. Filtered: [' + string(in_freq_filter[0], format='(f0.1)') + ', ' + $
                                string(in_freq_filter[1], format='(f0.1)') + '] kHz'

  widget_control, info.id.main_window.result_info_text, set_value = str

; plot the BES animation
  if animation eq 0 then $
    plot_result_window, info $
  else begin
    plot_result_window, info, /play_movie
  endelse

  return, result

end


;===================================================================================
; This function control for plotting BES density spectrum of spectrogram
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_dens_spec_window
;   2) 'overplot' is a keyword.
;                 If this is set, then overplot the data.
;                 If this is not set, then plot the data as new data sets.
;                 NOTE: if overplot is set, then plotdata.type must be compatiable with
;                       the currently drawn data.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_dens_spec, idinfo, overplot = in_overplot

; keyword check
  if keyword_set(in_overplot) then $
    overplot = 1 $
  else $
    overplot = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check whether to use IDL or CUDA for performing calculation
  use_IDL_CUDA = 0	;if this variable is 1, then use IDL for calculation
                        ;if this variable is 2, then use CUDA for calculation
  if info.dens_spec_window_data.calc_in_IDL eq 1 then begin
    use_IDL_CUDA = 1
  endif else begin
    use_IDL_CUDA = 2
  ; check whether CUDA is online
    if info.CUDA_comm_window_data.comm_line_on eq 0 then begin
    ; a user wants to use CUDA for calculation, but CUDA is not online. --> an error.
      result.erc = 101
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

; check the selected BES channels
  signal_ch = intarr(2) ;signal_ch[0] contains the BES channel number of signal 1.
                        ;signal_ch[1] contains the BES channel number of signal 2.
                        ;Note: BES channel number starts from 1 rather than 0. (i.e. base 1 index system)
  inx = where(info.dens_spec_window_data.BES_ch_sel1 eq 1, count)
  if count le 0 then begin
    result.erc = 19
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch[0] = inx + 1
  inx = where(info.dens_spec_window_data.BES_ch_sel2 eq 1, count)
  if count le 0 then begin
    result.erc = 19
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch[1] = inx + 1

; load the BES signals
  nplots = 1	;From this procedure, only 1 plot will be plotted on to result_draw window.
  load_result = load_bes_data(info, signal_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif

; if remove_large_structure is set, then I need to read the whole 32 BES channel signals
  if info.dens_spec_window_data.remove_large_structure eq 1 then begin
    temp_bes_ch = indgen(32) + 1
    load_result = load_bes_data(info, temp_bes_ch)
    if load_result.erc ne 0 then begin
      result.erc = load_result.erc
      result.errmsg = load_result.errmsg
      return, result
    endif
  endif

; get the plotdata, first
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

  calc_spectrogram = info.dens_spec_window_data.calc_spectrogram
  calc_power = info.dens_spec_window_data.calc_power
  if calc_spectrogram eq 1 then begin
    if calc_power then $
      datatype = 101 $
    else $
      datatype = 103
  endif else begin
    if calc_power then $
      datatype = 21 $
    else $
      datatype = 23
  endelse

; set and check the plotdata
  if overplot eq 0 then begin
    total_nplots = nplots
    plotdata.type = datatype
    ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
    plotdata = set_extra_plot_info(info, plotdata)
    start_inx = 0
  endif else begin
  ; overplot type check
    if plotdata.type eq 0 then begin
      result.erc = 20
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    if plotdata.type ne datatype then begin
      result.erc = 21
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    plot_dim = fix(alog10(plotdata.type)) + 1
    if plot_dim ge 3 then begin
    ; for 3D graph, oplot is not allowed.
      result.erc = 23
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    total_nplots = plotdata.curr_num_plots + nplots
    start_inx = plotdata.curr_num_plots
  endelse
  if total_nplots gt plotdata.MAX_NUM_PLOTS then begin
    result.erc = 1
    result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                    string(10b) + 'You specified too many plots to be drawn.'
    return, result
  endif
  plotdata.curr_num_plots = total_nplots

; retrieve the input parameters
  in_data1 = *info.main_window_data.BES_data.ptr_data[signal_ch[0]-1]
  in_data2 = *info.main_window_data.BES_data.ptr_data[signal_ch[1]-1]
  in_time = *info.main_window_data.BES_data.ptr_time
  in_dt = info.main_window_data.BES_data.dt
  num_sel_time_range = info.time_sel_struct.curr_num_time_regions
  if num_sel_time_range gt 0 then $
    sel_time_range = info.time_sel_struct.time_regions[0:num_sel_time_range-1, *]
  freq_filter = [info.dens_spec_window_data.freq_filter_low, info.dens_spec_window_data.freq_filter_high]
  num_pts_per_subwindow = info.dens_spec_window_data.num_pts_per_subwindow
  num_bins_to_average = info.dens_spec_window_data.num_bins_to_average
  overlap = info.dens_spec_window_data.frac_overlap_subwindow
  spectrogram = info.dens_spec_window_data.calc_spectrogram
  use_hanning = info.dens_spec_window_data.use_hanning_window
  calc_power = info.dens_spec_window_data.calc_power
  if signal_ch[0] eq signal_ch[1] then $
    auto = 1 $
  else $
    auto = 0
  remove_large_structure = info.dens_spec_window_data.remove_large_structure
  if remove_large_structure eq 1 then begin
    temp_data_for_removal = *info.main_window_data.BES_data.ptr_data[0]
    data_for_removal = fltarr(32, n_elements(temp_data_for_removal))
    for i = 0, 31 do begin
      data_for_removal[i, *] = *info.main_window_data.BES_data.ptr_data[i]
    endfor
  endif else begin
    data_for_removal = 0
  endelse
  norm_by_DC = info.dens_spec_window_data.norm_by_DC
  spike_remover = info.main_window_data.spike_remover

; prepare the data
  if auto eq 1 then begin
    in_data = fltarr(1, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
  endif else begin
    in_data = fltarr(2, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
    in_data[1, *] = temporary(in_data2)
  endelse

  prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                          num_sel_time_range = num_sel_time_range, $
                                          sel_time_range = sel_time_range, $
                                          freq_filter = freq_filter, $
                                          num_pts_per_subwindow = num_pts_per_subwindow, $
                                          num_bins_to_average = num_bins_to_average, $
                                          overlap = overlap, $
                                          spectrogram = spectrogram, $
                                          remove_large_structure = remove_large_structure, $
                                          data_for_removal = data_for_removal, $
                                          norm_by_DC = norm_by_DC, $
                                          write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                          ID_msg_box = info.id.IDL_msg_box_window.msg_text, $
                                          spike_remover = spike_remover)

  if prep_data_result.erc ne 0 then begin
    result.erc = prep_data_result.erc
    result.errmsg = prep_data_result.errmsg
    return, result
  endif

; retrieve the data from prep_data_result
  in_data1 = reform(prep_data_result.out_data[0, *])
  if auto eq 1 then $
    in_data2 = in_data1 $
  else $
    in_data2 = reform(prep_data_result.out_data[1, *])
  in_time = prep_data_result.out_time
  in_sel_time_range = prep_data_result.out_sel_time_range
  num_pts_per_subwindow = prep_data_result.out_num_pts_per_subwindow
  num_bins_to_average = prep_data_result.out_num_bins_to_average
  overlap = prep_data_result.out_overlap

; calculate the spectrum or spectrogram
  if use_IDL_CUDA eq 2 then begin
  ; calculate using CUDA
    fft_result = perform_cuda_fft(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                  overlap, use_hanning, auto)

  ; check error during perform_cuda_fft
    if fft_result.erc ne 0 then begin
      result.erc = fft_result.erc
      result.errmsg = fft_result.errmsg
      return, result
    endif

  ; retrieve the output data
    power = fft_result.power
    phase = fft_result.phase
    freq_vector = findgen(fft_result.out_num_fft_pts_per_subwindow) * 1.0/(in_dt * num_pts_per_subwindow) * 1e-3	;in [kHz]
    if spectrogram eq 1 then begin
       t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
       t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
       time_vector = findgen(fft_result.out_time_pts) * t_step + t_start
    endif
  endif else begin
  ; calculate using IDL
    fft_result = perform_idl_fft(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                 overlap, use_hanning, auto)

  ; check error during perform_cuda_fft
    if fft_result.erc ne 0 then begin
      result.erc = fft_result.erc
      result.errmsg = fft_result.errmsg
      return, result
    endif

  ; retrieve the output data
    power = fft_result.power
    phase = fft_result.phase
    freq_vector = findgen(fft_result.out_num_fft_pts_per_subwindow) * 1.0/(in_dt * num_pts_per_subwindow) * 1e-3	;in [kHz]
    if spectrogram eq 1 then begin
       t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
       t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
       time_vector = findgen(fft_result.out_time_pts) * t_step + t_start
    endif
  endelse

; save the data
  if datatype eq 101 then begin 
  ;power spectrogram
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_z[start_inx] = ptr_new(power)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 103 then begin
  ;phase spectrogram
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_z[start_inx] = ptr_new(phase)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 21 then begin
  ;power spectrum
    plotdata.ptr_x[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_y[start_inx] = ptr_new(power)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
  endif else if datatype eq 23 then begin
  ;phase spectrum
    plotdata.ptr_x[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_y[start_inx] = ptr_new(phase)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
  endif

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the loaded data.
  if overplot eq 0 then $
    plot_result_window, info $
  else $
    plot_result_window, info, nplot = nplots

; print the notes about about the plotdata
  plot_dim = fix(alog10(plotdata.type)) + 1
  if plot_dim eq 2 then begin
    str = '<Line ' + string(start_inx+1, format='(i0)') + '> ' + plotdata.line_color[start_inx]
    case plotdata.line_style[start_inx] of
      0: str = str + ' Solid' + string(10b)
      1: str = str + ' Dotted' + string(10b)
      2: str = str + ' Dashed' + string(10b)
      3: str = str + ' Dash Dot' + string(10b)
      4: str = str + 'Dash Dot Dot' + string(10b)
      5: str = str + 'Long Dasehs' + string(10b)
      else: str = str + string(10b)
    endcase
  endif else begin
    str = '<Contour>'
  endelse

  str = str + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  BES Ch.: ' + string(signal_ch[0], format='(i0)') + ' and ' + string(signal_ch[1], format='(i0)') + string(10b) + $
        '  Data: '
  if calc_power eq 1 then $
    str = str + 'Power' + string(10b) $
  else $
    str = str + 'Phase' + string(10b)
  str = str + '  Data Dim.: '
  if calc_power eq 1 then begin
    if norm_by_DC eq 1 then $
      str = str + '[v^2/Vdc^2/Hz]' + string(10b) $
    else $
      str = str + '[V^2/Hz]' + string(10b)
  endif else $
    str = str + '[Radian]' + string(10b)
  str = str + $
        '  F. Filter: [' + string(freq_filter[0], format='(f0.1)') + ', ' + $
                              string(freq_filter[1], format='(f0.1)') + '] kHz' + string(10b)
  dim = size(in_sel_time_range, /dim)
  str = str + '  Num. T. Int.: ' + string(dim[0], format='(i0)') + string(10b)
  for i = 0, dim[0] - 1 do begin
    str = str + '  ' + string(i+1, format='(i2)') + ': [' + $
          string(in_sel_time_range[i, 0]*1e3, format='(f0.4)') + ', ' + $
          string(in_sel_time_range[i, 1]*1e3, format='(f0.4)') + '] msec' + string(10b)
  endfor
  freq_res = 1.0/(in_dt * num_pts_per_subwindow) * 1e-3
  str = str + $
        '  F. Res.: ' + string(freq_res, format='(f0.2)') + ' [kHz]'
  if spectrogram eq 1 then begin
    time_res = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average * 1e3
    str = str + string(10b) + $
          '  T. Res.: ' + string(time_res, format='(f0.3)') + ' [msec]'
  endif

  if start_inx eq 0 then $
    widget_control, info.id.main_window.result_info_text, set_value = str $
  else begin
    widget_control, info.id.main_window.result_info_text, set_value = '', /append
    widget_control, info.id.main_window.result_info_text, set_value = str, /append
  endelse

  return, result

end


;===================================================================================
; This function control for plotting coherenyc of BES density spectrum of spectrogram
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_dens_coh_window
;   2) 'overplot' is a keyword.
;                 If this is set, then overplot the data.
;                 If this is not set, then plot the data as new data sets.
;                 NOTE: if overplot is set, then plotdata.type must be compatiable with
;                       the currently drawn data.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_dens_coh, idinfo, overplot = in_overplot

; keyword check
  if keyword_set(in_overplot) then $
    overplot = 1 $
  else $
    overplot = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check whether to use IDL or CUDA for performing calculation
  use_IDL_CUDA = 0	;if this variable is 1, then use IDL for calculation
                        ;if this variable is 2, then use CUDA for calculation
  if info.dens_coh_window_data.calc_in_IDL eq 1 then begin
    use_IDL_CUDA = 1
  endif else begin
    use_IDL_CUDA = 2
  ; check whether CUDA is online
    if info.CUDA_comm_window_data.comm_line_on eq 0 then begin
    ; a user wants to use CUDA for calculation, but CUDA is not online. --> an error.
      result.erc = 101
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

; check the selected BES channels
  signal_ch = intarr(2) ;signal_ch[0] contains the BES channel number of signal 1.
                        ;signal_ch[1] contains the BES channel number of signal 2.
                        ;Note: BES channel number starts from 1 rather than 0. (i.e. base 1 index system)
  inx = where(info.dens_coh_window_data.BES_ch_sel1 eq 1, count)
  if count le 0 then begin
    result.erc = 19
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch[0] = inx + 1
  inx = where(info.dens_coh_window_data.BES_ch_sel2 eq 1, count)
  if count le 0 then begin
    result.erc = 19
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch[1] = inx + 1

; load the BES signals
  nplots = 1	;From this procedure, only 1 plot will be plotted on to result_draw window.
  load_result = load_bes_data(info, signal_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif

; if remove_large_structure is set, then I need to read the whole 32 BES channel signals
  if info.dens_coh_window_data.remove_large_structure eq 1 then begin
    temp_bes_ch = indgen(32) + 1
    load_result = load_bes_data(info, temp_bes_ch)
    if load_result.erc ne 0 then begin
      result.erc = load_result.erc
      result.errmsg = load_result.errmsg
      return, result
    endif
  endif

; get the plotdata, first
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

  calc_spectrogram = info.dens_coh_window_data.calc_spectrogram
  calc_power = info.dens_coh_window_data.calc_power
  if calc_spectrogram eq 1 then begin
    if calc_power then $
      datatype = 102 $
    else $
      datatype = 103
  endif else begin
    if calc_power then $
      datatype = 22 $
    else $
      datatype = 23
  endelse

; set and check the plotdata
  if overplot eq 0 then begin
    total_nplots = nplots
    plotdata.type = datatype
    ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
    plotdata = set_extra_plot_info(info, plotdata)
    start_inx = 0
  endif else begin
  ; overplot type check
    if plotdata.type eq 0 then begin
      result.erc = 20
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    if plotdata.type ne datatype then begin
      result.erc = 21
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    plot_dim = fix(alog10(plotdata.type)) + 1
    if plot_dim ge 3 then begin
    ; for 3D graph, oplot is not allowed.
      result.erc = 23
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    total_nplots = plotdata.curr_num_plots + nplots
    start_inx = plotdata.curr_num_plots
  endelse
  if total_nplots gt plotdata.MAX_NUM_PLOTS then begin
    result.erc = 1
    result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                    string(10b) + 'You specified too many plots to be drawn.'
    return, result
  endif
  plotdata.curr_num_plots = total_nplots

; retrieve the input parameters
  in_data1 = *info.main_window_data.BES_data.ptr_data[signal_ch[0]-1]
  in_data2 = *info.main_window_data.BES_data.ptr_data[signal_ch[1]-1]
  in_time = *info.main_window_data.BES_data.ptr_time
  in_dt = info.main_window_data.BES_data.dt
  num_sel_time_range = info.time_sel_struct.curr_num_time_regions
  if num_sel_time_range gt 0 then $
    sel_time_range = info.time_sel_struct.time_regions[0:num_sel_time_range-1, *]
  freq_filter = [info.dens_coh_window_data.freq_filter_low, info.dens_coh_window_data.freq_filter_high]
  num_pts_per_subwindow = info.dens_coh_window_data.num_pts_per_subwindow
  num_bins_to_average = info.dens_coh_window_data.num_bins_to_average
  overlap = info.dens_coh_window_data.frac_overlap_subwindow
  spectrogram = info.dens_coh_window_data.calc_spectrogram
  use_hanning = info.dens_coh_window_data.use_hanning_window
  calc_power = info.dens_coh_window_data.calc_power
  if signal_ch[0] eq signal_ch[1] then $
    auto = 1 $
  else $
    auto = 0
  remove_large_structure = info.dens_coh_window_data.remove_large_structure
  if remove_large_structure eq 1 then begin
    temp_data_for_removal = *info.main_window_data.BES_data.ptr_data[0]
    data_for_removal = fltarr(32, n_elements(temp_data_for_removal))
    for i = 0, 31 do begin
      data_for_removal[i, *] = *info.main_window_data.BES_data.ptr_data[i]
    endfor
  endif else begin
    data_for_removal = 0
  endelse
  spike_remover = info.main_window_data.spike_remover

; prepare the data
  if auto eq 1 then begin
    in_data = fltarr(1, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
  endif else begin
    in_data = fltarr(2, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
    in_data[1, *] = temporary(in_data2)
  endelse

  prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                          num_sel_time_range = num_sel_time_range, $
                                          sel_time_range = sel_time_range, $
                                          freq_filter = freq_filter, $
                                          num_pts_per_subwindow = num_pts_per_subwindow, $
                                          num_bins_to_average = num_bins_to_average, $
                                          overlap = overlap, $
                                          spectrogram = spectrogram, $
                                          remove_large_structure = remove_large_structure, $
                                          data_for_removal = data_for_removal, $
                                          write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                          ID_msg_box = info.id.IDL_msg_box_window.msg_text, $
                                          spike_remover = spike_remover)

  if prep_data_result.erc ne 0 then begin
    result.erc = prep_data_result.erc
    result.errmsg = prep_data_result.errmsg
    return, result
  endif

; retrieve the data from prep_data_result
  in_data1 = reform(prep_data_result.out_data[0, *])
  if auto eq 1 then $
    in_data2 = in_data1 $
  else $
    in_data2 = reform(prep_data_result.out_data[1, *])
  in_time = prep_data_result.out_time
  in_sel_time_range = prep_data_result.out_sel_time_range
  num_pts_per_subwindow = prep_data_result.out_num_pts_per_subwindow
  num_bins_to_average = prep_data_result.out_num_bins_to_average
  overlap = prep_data_result.out_overlap

; calculate the spectrum or spectrogram
  if use_IDL_CUDA eq 2 then begin
  ; calculate using CUDA
    if ( (plotdata.type eq 103) or (plotdata.type eq 23) ) then begin	;phase calculation: coherency keyword does not matter.
      fft_result = perform_cuda_fft(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                    overlap, use_hanning, auto)

    ; check error during perform_cuda_fft
      if fft_result.erc ne 0 then begin
        result.erc = fft_result.erc
        result.errmsg = fft_result.errmsg
        return, result
      endif

    ; retrieve the output data
      power = fft_result.power
      phase = fft_result.phase
    endif else begin	;coherency calculation
      fft_result = perform_cuda_coh(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                    overlap, use_hanning)

      if fft_result.erc ne 0 then begin
        result.erc = fft_result.erc
        result.errmsg = fft_result.errmsg
        return, result
      endif

      power = fft_result.coh
    endelse
    freq_vector = findgen(fft_result.out_num_fft_pts_per_subwindow) * 1.0/(in_dt * num_pts_per_subwindow) * 1e-3	;in [kHz]
    if spectrogram eq 1 then begin
       t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
       t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
       time_vector = findgen(fft_result.out_time_pts) * t_step + t_start
    endif
  endif else begin
  ; calculate using IDL
    fft_result = perform_idl_fft(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                  overlap, use_hanning, auto, /coh)

  ; check error during perform_cuda_fft
    if fft_result.erc ne 0 then begin
      result.erc = fft_result.erc
      result.errmsg = fft_result.errmsg
      return, result
    endif

  ; retrieve the output data
    power = fft_result.power
    phase = fft_result.phase
    freq_vector = findgen(fft_result.out_num_fft_pts_per_subwindow) * 1.0/(in_dt * num_pts_per_subwindow) * 1e-3	;in [kHz]
    if spectrogram eq 1 then begin
       t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
       t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
       time_vector = findgen(fft_result.out_time_pts) * t_step + t_start
    endif
  endelse

; save the data
  if datatype eq 102 then begin 
  ;power spectrogram
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_z[start_inx] = ptr_new(power)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 103 then begin
  ;phase spectrogram
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_z[start_inx] = ptr_new(phase)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 22 then begin
  ;power spectrum
    plotdata.ptr_x[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_y[start_inx] = ptr_new(power)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
  endif else if datatype eq 23 then begin
  ;phase spectrum
    plotdata.ptr_x[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_y[start_inx] = ptr_new(phase)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
  endif

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the loaded data.
  if overplot eq 0 then $
    plot_result_window, info $
  else $
    plot_result_window, info, nplot = nplots

; print the notes about about the plotdata
  plot_dim = fix(alog10(plotdata.type)) + 1
  if plot_dim eq 2 then begin
    str = '<Line ' + string(start_inx+1, format='(i0)') + '> ' + plotdata.line_color[start_inx]
    case plotdata.line_style[start_inx] of
      0: str = str + ' Solid' + string(10b)
      1: str = str + ' Dotted' + string(10b)
      2: str = str + ' Dashed' + string(10b)
      3: str = str + ' Dash Dot' + string(10b)
      4: str = str + 'Dash Dot Dot' + string(10b)
      5: str = str + 'Long Dasehs' + string(10b)
      else: str = str + string(10b)
    endcase
  endif else begin
    str = '<Contour>'
  endelse

  str = str + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  BES Ch.: ' + string(signal_ch[0], format='(i0)') + ' and ' + string(signal_ch[1], format='(i0)') + string(10b) + $
        '  Data: '
  if calc_power eq 1 then $
    str = str + 'Coherency' + string(10b) $
  else $
    str = str + 'Phase' + string(10b)
  str = str + '  Data Dim.: '
  if calc_power eq 1 then $
    str = str + '[-]' + string(10b) $
  else $
    str = str + '[Radian]' + string(10b)
  str = str + $
        '  F. Filter: [' + string(freq_filter[0], format='(f0.1)') + ', ' + $
                              string(freq_filter[1], format='(f0.1)') + '] kHz' + string(10b)
  dim = size(in_sel_time_range, /dim)
  str = str + '  Num. T. Int.: ' + string(dim[0], format='(i0)') + string(10b)
  for i = 0, dim[0] - 1 do begin
    str = str + '  ' + string(i+1, format='(i2)') + ': [' + $
          string(in_sel_time_range[i, 0]*1e3, format='(f0.4)') + ', ' + $
          string(in_sel_time_range[i, 1]*1e3, format='(f0.4)') + '] msec' + string(10b)
  endfor
  freq_res = 1.0/(in_dt * num_pts_per_subwindow) * 1e-3
  str = str + $
        '  F. Res.: ' + string(freq_res, format='(f0.2)') + ' [kHz]'
  if spectrogram eq 1 then begin
    time_res = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average * 1e3
    str = str + string(10b) + $
          '  T. Res.: ' + string(time_res, format='(f0.3)') + ' [msec]'
  endif

  if start_inx eq 0 then $
    widget_control, info.id.main_window.result_info_text, set_value = str $
  else begin
    widget_control, info.id.main_window.result_info_text, set_value = '', /append
    widget_control, info.id.main_window.result_info_text, set_value = str, /append
  endelse

  return, result

end


;===================================================================================
; This function control for plotting density temporal correlation of BES signal
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_dens_temporal_corr_window
;   2) 'overplot' is a keyword.
;                 If this is set, then overplot the data.
;                 If this is not set, then plot the data as new data sets.
;                 NOTE: if overplot is set, then plotdata.type must be compatiable with
;                       the currently drawn data.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_dens_temp_corr, idinfo, overplot = in_overplot

; keyword check
  if keyword_set(in_overplot) then $
    overplot = 1 $
  else $
    overplot = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check whether to use IDL or CUDA for performing calculation
  use_IDL_CUDA = 0	;if this variable is 1, then use IDL for calculation
                        ;if this variable is 2, then use CUDA for calculation
  if info.dens_temp_corr_window_data.calc_in_IDL eq 1 then begin
    use_IDL_CUDA = 1
  endif else begin
    use_IDL_CUDA = 2
  ; check whether CUDA is online
    if info.CUDA_comm_window_data.comm_line_on eq 0 then begin
    ; a user wants to use CUDA for calculation, but CUDA is not online. --> an error.
      result.erc = 101
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

; check the selected BES channels
  signal_ch = intarr(2) ;signal_ch[0] contains the BES channel number of signal 1.
                        ;signal_ch[1] contains the BES channel number of signal 2.
                        ;Note: BES channel number starts from 1 rather than 0. (i.e. base 1 index system)
  inx = where(info.dens_temp_corr_window_data.BES_ch_sel1 eq 1, count)
  if count le 0 then begin
    result.erc = 19
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch[0] = inx + 1
  inx = where(info.dens_temp_corr_window_data.BES_ch_sel2 eq 1, count)
  if count le 0 then begin
    result.erc = 19
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch[1] = inx + 1

; load the BES signals
  load_result = load_bes_data(info, signal_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif

; if remove_large_structure is set, then I need to read the whole 32 BES channel signals
  if info.dens_temp_corr_window_data.remove_large_structure eq 1 then begin
    temp_bes_ch = indgen(32) + 1
    load_result = load_bes_data(info, temp_bes_ch)
    if load_result.erc ne 0 then begin
      result.erc = load_result.erc
      result.errmsg = load_result.errmsg
      return, result
    endif
  endif

; get the plotdata, first
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata
  calc_covariance = info.dens_temp_corr_window_data.calc_covariance
  calc_fcn_tau_time = info.dens_temp_corr_window_data.calc_fcn_tau_time
  if calc_fcn_tau_time eq 1 then begin
    if calc_covariance eq 1 then $
      datatype = 105 $
    else $
      datatype = 104
  endif else begin
    if calc_covariance eq 1 then $
      datatype = 25 $
    else $
      datatype = 24
  endelse

; set the number of plots
  nplots = 1	;From this procedure, only 1 plot will be plotted on to result_draw window + envelope (optional) + filter response (optional)
  plot_dim = fix(alog10(datatype)) + 1
  if plot_dim eq 2 then begin
    if info.dens_temp_corr_window_data.show_filter_response eq 1 then $
      nplots = nplots + 1
    if info.dens_temp_corr_window_data.show_envelope eq 1 then $
      nplots = nplots + 1
  endif

; set and check the plotdata
  if overplot eq 0 then begin
    total_nplots = nplots
    plotdata.type = datatype
    ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
    plotdata = set_extra_plot_info(info, plotdata)
    start_inx = 0
  endif else begin
  ; overplot type check
    if plotdata.type eq 0 then begin
      result.erc = 20
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    if plotdata.type ne datatype then begin
      result.erc = 21
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    if plot_dim ge 3 then begin
    ; for 3D graph, oplot is not allowed.
      result.erc = 23
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    total_nplots = plotdata.curr_num_plots + nplots
    start_inx = plotdata.curr_num_plots
  endelse
  if total_nplots gt plotdata.MAX_NUM_PLOTS then begin
    result.erc = 1
    result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                    string(10b) + 'You specified too many plots to be drawn.'
    return, result
  endif
  plotdata.curr_num_plots = total_nplots

; retrieve the input parameters
  in_data1 = *info.main_window_data.BES_data.ptr_data[signal_ch[0]-1]
  in_data2 = *info.main_window_data.BES_data.ptr_data[signal_ch[1]-1]
  in_time = *info.main_window_data.BES_data.ptr_time
  in_dt = info.main_window_data.BES_data.dt
  num_sel_time_range = info.time_sel_struct.curr_num_time_regions
  if num_sel_time_range gt 0 then $
    sel_time_range = info.time_sel_struct.time_regions[0:num_sel_time_range-1, *]
  freq_filter = [info.dens_temp_corr_window_data.freq_filter_low, info.dens_temp_corr_window_data.freq_filter_high]
  temp_tinterval = abs(info.dens_temp_corr_window_data.time_delay_low) > abs(info.dens_temp_corr_window_data.time_delay_high)
  num_pts_per_subwindow = long(temp_tinterval/(in_dt*1e6)) + 2
  num_bins_to_average = info.dens_temp_corr_window_data.num_bins_to_average
  overlap = info.dens_temp_corr_window_data.frac_overlap_subwindow
  use_hanning = info.dens_temp_corr_window_data.use_hanning_window
  if signal_ch[0] eq signal_ch[1] then $
    auto = 1 $
  else $
    auto = 0
  remove_large_structure = info.dens_temp_corr_window_data.remove_large_structure
  if remove_large_structure eq 1 then begin
    temp_data_for_removal = *info.main_window_data.BES_data.ptr_data[0]
    data_for_removal = fltarr(32, n_elements(temp_data_for_removal))
    for i = 0, 31 do begin
      data_for_removal[i, *] = *info.main_window_data.BES_data.ptr_data[i]
    endfor
  endif else begin
    data_for_removal = 0
  endelse
  num_pts_to_remove_ph_peak = info.dens_temp_corr_window_data.num_pts_to_remove_ph_peak
  spike_remover = info.main_window_data.spike_remover


; prepare the data
  if auto eq 1 then begin
    in_data = fltarr(1, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
  endif else begin
    in_data = fltarr(2, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
    in_data[1, *] = temporary(in_data2)
  endelse

  prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                          num_sel_time_range = num_sel_time_range, $
                                          sel_time_range = sel_time_range, $
                                          freq_filter = freq_filter, $
                                          num_pts_per_subwindow = num_pts_per_subwindow, $
                                          num_bins_to_average = num_bins_to_average, $
                                          overlap = overlap, $
                                          spectrogram = calc_fcn_tau_time, $
                                          remove_large_structure = remove_large_structure, $
                                          data_for_removal = data_for_removal, $
                                          write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                          ID_msg_box = info.id.IDL_msg_box_window.msg_text, $
                                          spike_remover = spike_remover)

  if prep_data_result.erc ne 0 then begin
    result.erc = prep_data_result.erc
    result.errmsg = prep_data_result.errmsg
    return, result
  endif

; retrieve the data from prep_data_result
  in_data1 = reform(prep_data_result.out_data[0, *])
  if auto eq 1 then $
    in_data2 = in_data1 $
  else $
    in_data2 = reform(prep_data_result.out_data[1, *])
  in_time = prep_data_result.out_time
  in_sel_time_range = prep_data_result.out_sel_time_range
  num_pts_per_subwindow = prep_data_result.out_num_pts_per_subwindow
  num_bins_to_average = prep_data_result.out_num_bins_to_average
  overlap = prep_data_result.out_overlap

; calculate the correlation or covariance
  if use_IDL_CUDA eq 2 then begin
  ; calcualte using CUDA
    if signal_ch[0] eq signal_ch[1] then $
      auto = 1 $
    else $
      auto = 0

    corr_result = perform_cuda_temp_corr(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                         overlap, use_hanning, auto, calc_covariance)


  endif else begin
  ; calculate using IDL
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
  tau_vector = (findgen(corr_result.out_num_corr_pts_per_subwindow) - long(corr_result.out_num_corr_pts_per_subwindow/2)) * $
               in_dt * 1e6	;in [microsec]
  if calc_fcn_tau_time eq 1 then begin
    t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
    t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
    time_vector = findgen(corr_result.out_time_pts) * t_step + t_start
  endif

; perform photon peak removal
  if ( (auto eq 1) and (num_pts_to_remove_ph_peak gt 0) ) then begin
  ; Following is how I remove the photon peak based on the user input for auto-correlation function
  ;
  ; 1. Remove the points (whose number is set by num_pts_to_remove_ph_peak) centered at time_delay = 0.0
  ;    If num_pts_to_remove_ph_peak is not an odd number, then remove num_pts_to_remove_ph_peak+1 points.
  ; 2. Use the two points from negative time_delay and two points from positive time delay to fit a 2nd order polynomial fit
  ;      Each two points set from negative and positive delays are selected from the points located closest to time_delay = 0.0
  ;        after the Step 1.
  ; 3. By usnig the polynomial fit from Step 2, fill the points around the time_delay = 0.0 whose points are removed from step 1.
  ;

    if (num_pts_to_remove_ph_peak mod 2) eq 0 then $
      num_pts_to_remove_ph_peak = num_pts_to_remove_ph_peak + 1

  ; find the index where tau_vector is zero.
    inx_zero_tau = WHERE(tau_vector eq 0.0, count)
    if count ge 1 then begin
      inx_zero_tau = inx_zero_tau[0]
    endif else begin
      inx_zero_tau1 = WHERE(tau_vector gt 0.0, count1) & inx_zero_tau1 = inx_zero_tau1[0]
      inx_zero_tau2 = WHERE(tau_vector lt 0.0, count2) & inx_zero_tau2 = inx_zero_tau2[count2-1]
      inx_zero_tau = ( ABS(tau_vector[inx_zero_tau1]) le ABS(tau_vector[inx_zero_tau2]) ) ? inx_zero_tau1 : inx_zero_tau2
    endelse

  ; calculate the number of 'plasma time' points
    if calc_fcn_tau_time eq 1 then begin
      temp_nt = N_ELEMENTS(time_vector)
    endif else begin
      temp_nt = 1
    endelse

  ; removing photon peak
    for i = 0l, temp_nt - 1 do begin
      temp_corr = REFORM(corr[i, *])
      temp_inx_fit = lindgen(2) + long(num_pts_to_remove_ph_peak/2) + 1
      inx_fit = [-ROTATE(temp_inx_fit, 2), temp_inx_fit] + inx_zero_tau
      coeff_poly_fit = poly_fit(tau_vector[inx_fit], temp_corr[inx_fit], 2)
      inx_remove = lindgen(num_pts_to_remove_ph_peak) - long(num_pts_to_remove_ph_peak/2) + inx_zero_tau
      temp_corr[inx_remove] = coeff_poly_fit[0] + coeff_poly_fit[1]*tau_vector[inx_remove] + coeff_poly_fit[2]*tau_vector[inx_remove]*tau_vector[inx_remove] 
      corr[i, *] = temp_corr
    endfor
  endif

; Calculating filter_response and envelop
  if plot_dim eq 2 then begin
  ; Calculate the filter_response function
    if info.dens_temp_corr_window_data.show_filter_response eq 1 then begin
      f_nyq = 1.0/(2.0 * in_dt)*1e-3
      ntau = N_ELEMENTS(tau_vector)
      filter_response = digital_filter( (freq_filter[0]/f_nyq) > 0.0, (freq_filter[1]/f_nyq) < 1.0, 50, (ntau-1)/2 )
      filter_response = filter_response / max(filter_response) * max(corr)	;normalize the filter function for easy comparisons
    endif

  ; Calcualte the envelop function
    if info.dens_temp_corr_window_data.show_envelope eq 1 then begin
      temp_corr = REFORM(corr)
      envelope_function = temp_corr + complex(0, 1)*HILBERT(temp_corr)
      envelope_function = ABS(envelope_function)
    endif
  endif


; save the data
  if datatype eq 104 then begin 
  ;correlation as a function of time and tau
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(tau_vector)
    plotdata.ptr_z[start_inx] = ptr_new(corr)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 105 then begin
  ;covariance as a function of time and tau
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(tau_vector)
    plotdata.ptr_z[start_inx] = ptr_new(corr)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 24 then begin
  ;correlation as a function of tau
    plotdata.ptr_x[start_inx] = ptr_new(tau_vector)
    plotdata.ptr_y[start_inx] = ptr_new(corr)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
    temp_inx = start_inx
    if info.dens_temp_corr_window_data.show_filter_response eq 1 then begin
      temp_inx = temp_inx + 1
      plotdata.ptr_x[temp_inx] = ptr_new(tau_vector)
      plotdata.ptr_y[temp_inx] = ptr_new(filter_response)
      plotdata.line_color[temp_inx] = info.color_table_str[temp_inx mod n_elements(info.color_table_str)]
      plotdata.line_style[temp_inx] = fix(temp_inx/n_elements(info.color_table_str))
    endif
    if info.dens_temp_corr_window_data.show_envelope eq 1 then begin
      temp_inx = temp_inx + 1
      plotdata.ptr_x[temp_inx] = ptr_new(tau_vector)
      plotdata.ptr_y[temp_inx] = ptr_new(envelope_function)
      plotdata.line_color[temp_inx] = info.color_table_str[temp_inx mod n_elements(info.color_table_str)]
      plotdata.line_style[temp_inx] = fix(temp_inx/n_elements(info.color_table_str))
    endif
  endif else if datatype eq 25 then begin
  ;covariance as a function of tau
    plotdata.ptr_x[start_inx] = ptr_new(tau_vector)
    plotdata.ptr_y[start_inx] = ptr_new(corr)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
    temp_inx = start_inx
    if info.dens_temp_corr_window_data.show_filter_response eq 1 then begin
      temp_inx = temp_inx + 1
      plotdata.ptr_x[temp_inx] = ptr_new(tau_vector)
      plotdata.ptr_y[temp_inx] = ptr_new(filter_response)
      plotdata.line_color[temp_inx] = info.color_table_str[temp_inx mod n_elements(info.color_table_str)]
      plotdata.line_style[temp_inx] = fix(temp_inx/n_elements(info.color_table_str))
    endif
    if info.dens_temp_corr_window_data.show_envelope eq 1 then begin
      temp_inx = temp_inx + 1
      plotdata.ptr_x[temp_inx] = ptr_new(tau_vector)
      plotdata.ptr_y[temp_inx] = ptr_new(envelope_function)
      plotdata.line_color[temp_inx] = info.color_table_str[temp_inx mod n_elements(info.color_table_str)]
      plotdata.line_style[temp_inx] = fix(temp_inx/n_elements(info.color_table_str))
    endif
  endif

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the loaded data.
  if overplot eq 0 then $
    plot_result_window, info $
  else $
    plot_result_window, info, nplot = nplots

; print the notes about about the plotdata
  plot_dim = fix(alog10(plotdata.type)) + 1
  if plot_dim eq 2 then begin
    str = '<Line ' + string(start_inx+1, format='(i0)') + '> ' + plotdata.line_color[start_inx]
    case plotdata.line_style[start_inx] of
      0: str = str + ' Solid' + string(10b)
      1: str = str + ' Dotted' + string(10b)
      2: str = str + ' Dashed' + string(10b)
      3: str = str + ' Dash Dot' + string(10b)
      4: str = str + 'Dash Dot Dot' + string(10b)
      5: str = str + 'Long Dasehs' + string(10b)
      else: str = str + string(10b)
    endcase
  endif else begin
    str = '<Contour>'
  endelse

  str = str + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  BES Ch.: ' + string(signal_ch[0], format='(i0)') + ' and ' + string(signal_ch[1], format='(i0)') + string(10b) + $
        '  Data: '
  if calc_covariance eq 1 then $
    str = str + 'Covariance' + string(10b) $
  else $
    str = str + 'Correlation' + string(10b)
  str = str + '  Data Dim.: '
  if calc_covariance eq 1 then $
    str = str + '[V^2]' + string(10b) $
  else $
    str = str + '[-]' + string(10b)
  str = str + $
        '  F. Filter: [' + string(freq_filter[0], format='(f0.1)') + ', ' + $
                           string(freq_filter[1], format='(f0.1)') + '] kHz' + string(10b)
  dim = size(in_sel_time_range, /dim)
  str = str + '  Num. T. Int.: ' + string(dim[0], format='(i0)') + string(10b)
  for i = 0, dim[0] - 1 do begin
    str = str + '  ' + string(i+1, format='(i2)') + ': [' + $
          string(in_sel_time_range[i, 0]*1e3, format='(f0.4)') + ', ' + $
          string(in_sel_time_range[i, 1]*1e3, format='(f0.4)') + '] msec' + string(10b)
  endfor
  tau_res = tau_vector[1]-tau_vector[0]
  str = str + $
        '  Tau. Res.: ' + string(tau_res, format='(f0.2)') + ' [microsec]'
  if calc_fcn_tau_time eq 1 then begin
    time_res = time_vector[1]-time_vector[0]
    str = str + string(10b) + $
          '  T. Res.: ' + string(time_res*1e3, format='(f0.3)') + ' [msec]'
  endif

; messages for filter response and envelope function
  if plot_dim eq 2 then begin
    temp_inx = start_inx
    if info.dens_temp_corr_window_data.show_filter_response eq 1 then begin
      temp_inx = temp_inx + 1
      str = str + string(10b)
      str = str + '<Line ' + string(temp_inx+1, format='(i0)') + '> ' + plotdata.line_color[temp_inx]
      case plotdata.line_style[temp_inx] of
        0: str = str + ' Solid' + string(10b)
        1: str = str + ' Dotted' + string(10b)
        2: str = str + ' Dashed' + string(10b)
        3: str = str + ' Dash Dot' + string(10b)
        4: str = str + 'Dash Dot Dot' + string(10b)
        5: str = str + 'Long Dasehs' + string(10b)
        else: str = str + string(10b)
      endcase
      str = str + '  Data: Filter Resp. Func. for Line #' + string(start_inx+1, format = '(i0)')
    endif

    if info.dens_temp_corr_window_data.show_envelope eq 1 then begin
      temp_inx = temp_inx + 1
      str = str + string(10b)
      str = str + '<Line ' + string(temp_inx+1, format='(i0)') + '> ' + plotdata.line_color[temp_inx]
      case plotdata.line_style[temp_inx] of
        0: str = str + ' Solid' + string(10b)
        1: str = str + ' Dotted' + string(10b)
        2: str = str + ' Dashed' + string(10b)
        3: str = str + ' Dash Dot' + string(10b)
        4: str = str + 'Dash Dot Dot' + string(10b)
        5: str = str + 'Long Dasehs' + string(10b)
        else: str = str + string(10b)
      endcase
      str = str + '  Data: Envelope. Func. for Line #' + string(start_inx+1, format = '(i0)')

    endif
  endif


  if start_inx eq 0 then $
    widget_control, info.id.main_window.result_info_text, set_value = str $
  else begin
    widget_control, info.id.main_window.result_info_text, set_value = '', /append
    widget_control, info.id.main_window.result_info_text, set_value = str, /append
  endelse



  return, result

end


;===================================================================================
; This function control for plotting density spatio-temporal correlation of BES signal
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_dens_spa_temp_corr_window
;   2) 'movie' is a keyword.
;                 If this is set, then play the movie
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_dens_spa_temp_corr, idinfo, movie = in_movie

; keyword check
  if keyword_set(in_movie) then $
    movie = 1 $
  else $
    movie = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check whether to use IDL or CUDA for performing calculation
  use_IDL_CUDA = 0	;if this variable is 1, then use IDL for calculation
                        ;if this variable is 2, then use CUDA for calculation
  if info.dens_spa_temp_corr_window_data.calc_in_IDL eq 1 then begin
    use_IDL_CUDA = 1
  endif else begin
    use_IDL_CUDA = 2
  ; check whether CUDA is online
    if info.CUDA_comm_window_data.comm_line_on eq 0 then begin
    ; a user wants to use CUDA for calculation, but CUDA is not online. --> an error.
      result.erc = 101
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

; check the selected BES channels
  inx = where(info.dens_spa_temp_corr_window_data.BES_ch_sel eq 1, count)
  if count lt 2 then begin
    result.erc = 401
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch = inx + 1

; load the BES signals
  nplots = 1	;From this procedure, only 1 plot will be plotted on to result_draw window.
  load_result = load_bes_data(info, signal_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif

; if remove_large_structure is set, then I need to read the whole 32 BES channel signals
  if info.dens_spa_temp_corr_window_data.remove_large_structure eq 1 then begin
    temp_bes_ch = indgen(32) + 1
    load_result = load_bes_data(info, temp_bes_ch)
    if load_result.erc ne 0 then begin
      result.erc = load_result.erc
      result.errmsg = load_result.errmsg
      return, result
    endif
  endif

; get the plotdata, first
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata
  calc_correlation = info.dens_spa_temp_corr_window_data.calc_correlation
  calc_covariance = info.dens_spa_temp_corr_window_data.calc_covariance
  calc_fcn_time = info.dens_spa_temp_corr_window_data.calc_fcn_time
  convert_temp_to_spa = info.dens_spa_temp_corr_window_data.convert_temp_to_spa
  calc_pol_spa = info.dens_spa_temp_corr_window_data.calc_pol_spa
  if ( (convert_temp_to_spa eq 1) and (calc_pol_spa eq 1) ) then $
    perform_convert_temp_to_spa = 1 $
  else $
    perform_convert_temp_to_spa = 0
  if calc_fcn_time eq 1 then begin
  ;4D
    if calc_correlation eq 1 then begin
      if perform_convert_temp_to_spa eq 1 then $
        datatype = 1008 $
      else $
        datatype = 1006
    endif else begin
      if perform_convert_temp_to_spa eq 1 then $
        datatype = 1009 $
      else $
        datatype = 1007
    endelse
  endif else begin
  ;3D
    if calc_correlation eq 1 then begin
      if perform_convert_temp_to_spa eq 1 then $
        datatype = 108 $
      else $
        datatype = 106
    endif else begin
      if perform_convert_temp_to_spa eq 1 then $
        datatype = 109 $
      else $
        datatype = 107
    endelse
  endelse

  total_nplots = nplots
  plotdata.type = datatype
  ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
  plotdata = set_extra_plot_info(info, plotdata)
  start_inx = 0
  plotdata.curr_num_plots = total_nplots

; retrieve the input parameters
  nch = n_elements(signal_ch)
  for i = 0, nch - 1 do begin
    temp_data = *info.main_window_data.BES_data.ptr_data[signal_ch[i]-1]
    if i eq 0 then begin
      in_data = fltarr(nch, n_elements(temp_data))
    endif
    in_data[i, *] = temporary(temp_data)
  endfor
  in_time = *info.main_window_data.BES_data.ptr_time
  in_dt = info.main_window_data.BES_data.dt
  num_sel_time_range = info.time_sel_struct.curr_num_time_regions
  if num_sel_time_range gt 0 then $
    sel_time_range = info.time_sel_struct.time_regions[0:num_sel_time_range-1, *]
  freq_filter = [info.dens_spa_temp_corr_window_data.freq_filter_low, info.dens_spa_temp_corr_window_data.freq_filter_high]
  temp_tinterval = abs(info.dens_spa_temp_corr_window_data.time_delay_low) > abs(info.dens_spa_temp_corr_window_data.time_delay_high)
  num_pts_per_subwindow = long(temp_tinterval/(in_dt*1e6)) + 2
  num_bins_to_average = info.dens_spa_temp_corr_window_data.num_bins_to_average
  overlap = info.dens_spa_temp_corr_window_data.frac_overlap_subwindow
  use_hanning = info.dens_spa_temp_corr_window_data.use_hanning_window
  factor_inc_spa_pts = info.dens_spa_temp_corr_window_data.factor_inc_spa_pts
  use_cxrs_data = info.dens_spa_temp_corr_window_data.use_cxrs_data
  use_ss_cxrs = info.dens_spa_temp_corr_window_data.use_ss_cxrs
  manual_vtor = info.dens_spa_temp_corr_window_data.manual_vtor
  remove_large_structure = info.dens_spa_temp_corr_window_data.remove_large_structure
  if remove_large_structure eq 1 then begin
    temp_data_for_removal = *info.main_window_data.BES_data.ptr_data[0]
    data_for_removal = fltarr(32, n_elements(temp_data_for_removal))
    for i = 0, 31 do begin
      data_for_removal[i, *] = *info.main_window_data.BES_data.ptr_data[i]
    endfor
  endif else begin
    data_for_removal = 0
  endelse
  spike_remover = info.main_window_data.spike_remover

; prepare the data
  prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                          num_sel_time_range = num_sel_time_range, $
                                          sel_time_range = sel_time_range, $
                                          freq_filter = freq_filter, $
                                          num_pts_per_subwindow = num_pts_per_subwindow, $
                                          num_bins_to_average = num_bins_to_average, $
                                          overlap = overlap, $
                                          spectrogram = calc_fcn_time, $
                                          remove_large_structure = remove_large_structure, $
                                          data_for_removal = data_for_removal, $
                                          write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                          ID_msg_box = info.id.IDL_msg_box_window.msg_text, $
                                          spike_remover = spike_remover)

  if prep_data_result.erc ne 0 then begin
    result.erc = prep_data_result.erc
    result.errmsg = prep_data_result.errmsg
    return, result
  endif

; retrieve the data from prep_data_result
  in_data = prep_data_result.out_data
  in_time = prep_data_result.out_time
  in_sel_time_range = prep_data_result.out_sel_time_range
  num_pts_per_subwindow = prep_data_result.out_num_pts_per_subwindow
  num_bins_to_average = prep_data_result.out_num_bins_to_average
  overlap = prep_data_result.out_overlap

; calculate the spatio-temporal correlation
  spa_temp_corr_result = perform_spa_temp_corr(info, in_data, in_dt, in_time, signal_ch, $
                                               num_pts_per_subwindow, num_bins_to_average, overlap, $
                                               use_hanning, calc_covariance, calc_fcn_time, $
                                               calc_pol_spa, convert_temp_to_spa, use_cxrs_data, $
                                               use_ss_cxrs, manual_vtor, factor_inc_spa_pts, use_IDL_CUDA)

; check error
  if spa_temp_corr_result.erc ne 0 then begin
    result.erc = spa_temp_corr_result.erc
    result.errmsg = spa_temp_corr_result.errmsg
    return, result
  endif

; retrieve the output
  spa_temp_corr = spa_temp_corr_result.spa_temp_corr		
  tau_vector = spa_temp_corr_result.tau_vector			;in [micro-sec]
  spa_vector = spa_temp_corr_result.spa_vector			;in [m]
  time_vector = spa_temp_corr_result.time_vector		;in [sec]

; get the plot dimension
  plot_dim = fix(alog10(plotdata.type)) + 1
  if plot_dim eq 3 then begin
  ;3D plot
  ;Note on plotdata.type
  ; 106: 3D spatio-temporal correlation
  ;      xaxis: time-delay
  ;      yaxis: poloidal or radial displacement
  ;      zaxis: correlation
  ; 107: 3D spatio-temporal covariance
  ;      xaxis: time-delay
  ;      yaxis: poloidal or radial displacement
  ;      zaxis: covariance
  ; 108: 3D spatio-spatio correlation
  ;      xaxis: converted toroidal direction
  ;      yaxis: poloidal or radial displacement
  ;      zaxis: correlation
  ; 109: 3D spatio-spatio covariacne
  ;      xaxis: converted toroidal direction
  ;      yaxis: poloidal or radial displacement
  ;      zaxis: covariance
    plotdata.ptr_x[start_inx] = ptr_new(tau_vector)
    plotdata.ptr_y[start_inx] = ptr_new(spa_vector)
    plotdata.ptr_z[start_inx] = ptr_new(spa_temp_corr)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else begin
  ;4D plot
  ;Note on plotdata.type
  ; 1006: 4D spatio-temporal correlation
  ;       xaxis: time-delay
  ;       yaxis: poloidal or radial displacement
  ;       zaxis: correlation
  ;       taxis: time
  ; 1007: 4D spatio-temporal covariance
  ;       xaxis: time-delay
  ;       yaxis: poloidal or radial displacement
  ;       zaxis: covariance
  ;       taxis: time
  ; 1008: 4D spatio-spatio correlation
  ;       xaxis: converted toroidal direction
  ;       yaxis: poloidal or radial displacement
  ;       zaxis: correlation
  ;       taxis: time
  ; 1009: 4D spatio-spatio covariacne
  ;       xaxis: converted toroidal direction
  ;       yaxis: poloidal or radial displacement
  ;       zaxis: covariance
  ;       taxis: time
    plotdata.ptr_x[start_inx] = ptr_new(tau_vector)
    plotdata.ptr_y[start_inx] = ptr_new(spa_vector)
    plotdata.ptr_z[start_inx] = ptr_new(spa_temp_corr)
    plotdata.ptr_t[start_inx] = ptr_new(time_vector)
    plotdata.inx_curr_time = 0l
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endelse

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the result data
  plot_result_window, info, play_movie = movie

; print the notes about about the plotdata
  str = '<Contour>' + string(10b) + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  BES Ch.: ' + string(signal_ch[0], format='(i0)')
  for i = 1, n_elements(signal_ch)-1 do begin
    str = str + ', ' + string(signal_ch[i], format='(i0)')
  endfor 
  str = str + string(10b) + '  Data: ' 
  if calc_correlation eq 1 then $
    str = str + 'Correlation' + string(10b) $
  else $
    str = str + 'Covariance' + string(10b)
  str = str + '  Data Dim.: '
    if calc_correlation eq 1 then $
    str = str + '[-]' + string(10b) $
  else $
    str = str + '[V^2]' + string(10b)
  str = str + $
        '  F. Filter: [' + string(freq_filter[0], format='(f0.1)') + ', ' + $
                           string(freq_filter[1], format='(f0.1)') + '] kHz' + string(10b)
  dim = size(in_sel_time_range, /dim)
  str = str + '  Num. T. Int.: ' + string(dim[0], format='(i0)') + string(10b)
  for i = 0, dim[0] - 1 do begin
    str = str + '  ' + string(i+1, format='(i2)') + ': [' + $
          string(in_sel_time_range[i, 0]*1e3, format='(f0.4)') + ', ' + $
          string(in_sel_time_range[i, 1]*1e3, format='(f0.4)') + '] msec' + string(10b)
  endfor
  tau_res = tau_vector[1]-tau_vector[0]
  str = str + $
        '  Tau. Res.: ' + string(tau_res, format='(f0.2)') + ' [microsec]'
  if plot_dim eq 4 then begin
    time_res = time_vector[1]-time_vector[0]
    str = str + string(10b) + $
          '  T. Res.: ' + string(time_res*1e3, format='(f0.3)') + ' [msec]'
  endif
  widget_control, info.id.main_window.result_info_text, set_value = str

  return, result

end



;===================================================================================
; This function control for plotting temporal evolution of eddy pattern velocity
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_vel_evol_window
;   2) 'overplot' is a keyword.
;                 If this is set, then overplot the data.
;                 If this is not set, then plot the data as new data sets.
;                 NOTE: if overplot is set, then plotdata.type must be compatiable with
;                       the currently drawn data.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_vel_evol, idinfo, overplot = in_overplot

; keyword check
  if keyword_set(in_overplot) then $
    overplot = 1 $
  else $
    overplot = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check whether to use IDL or CUDA for performing calculation
  use_IDL_CUDA = 0	;if this variable is 1, then use IDL for calculation
                        ;if this variable is 2, then use CUDA for calculation
  if info.vel_time_evol_window_data.calc_in_IDL eq 1 then begin
    use_IDL_CUDA = 1
  endif else begin
    use_IDL_CUDA = 2
  ; check whether CUDA is online
    if info.CUDA_comm_window_data.comm_line_on eq 0 then begin
    ; a user wants to use CUDA for calculation, but CUDA is not online. --> an error.
      result.erc = 101
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

; check the selected BES channels
  inx = where(info.vel_time_evol_window_data.BES_ch_sel eq 1, count)
  if count lt 2 then begin
    result.erc = 401
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch = inx + 1

; load the BES signals
  load_result = load_bes_data(info, signal_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif

; if remove_large_structure is set, then I need to read the whole 32 BES channel signals
  if info.vel_time_evol_window_data.remove_large_structure eq 1 then begin
    temp_bes_ch = indgen(32) + 1
    load_result = load_bes_data(info, temp_bes_ch)
    if load_result.erc ne 0 then begin
      result.erc = load_result.erc
      result.errmsg = load_result.errmsg
      return, result
    endif
  endif

; if a user wants to calculate the poloidal apparent velocity, and
;  compare with the CXRS data, then CXRS data and pitch angle data need to be loaded.
  if ( (info.vel_time_evol_window_data.calc_pol_vel eq 1) and $
       (info.vel_time_evol_window_data.convert_to_tor_vel eq 1) ) then begin

  ; First, load the pitch angle data
    pitch_angle_struct = getdata('ams_pitcha', info.main_window_data.BES_data.shot)
  ; If reading the pitch angle is successful, then
  ;    pitch_angle_struct.data has the 2D data [nR, nt]
  ;    pitch_angle_struct.time has the 1D data [nt]
    if pitch_angle_struct.erc ne 0 then begin
    ; if MSE data is not available, then load EFIT data
      efit_flux = read_flux(info.main_window_data.BES_data.shot, /nofc)
      if efit_flux.error ne 0 then begin
        result.erc = 459
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif
      use_efit = 1
    endif else begin
      use_efit = 0
    endelse

  ; Second, load the pitch angle R position
    if use_efit eq 0 then begin
      pitch_angle_rpos_struct = getdata('ams_rpos', info.main_window_data.BES_data.shot)
    ; If read the pitch angle R positions is successful, then
    ;    pitch_angle_rpos_struct.data has the 2D data [nR, 1]
      if pitch_angle_rpos_struct.erc ne 0 then begin
        result.erc = 459
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif
    endif

  ; Third, read the CXRS SS data
    if info.vel_time_evol_window_data.compare_cxrs_ss eq 1 then begin
      tor_vel_ss_struct = getdata('act_ss_velocity', info.main_window_data.BES_data.shot)
    ; if rading the toroidal velocity from SS beam is successful, then
    ;    tor_vel_ss_struct.data has 2D data: [nR, nt]	 in m/s
    ;    tor_vel_ss_struct.x has 1D data: [nR]
    ;    tor_vel_ss_struct.time has 1D data: [nt]
      if tor_vel_ss_struct.erc ne 0 then begin
        result.erc = 460
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif
      tor_ss_vel_available = 1
    endif else begin
      tor_ss_vel_available = 0
    endelse
    if info.vel_time_evol_window_data.compare_cxrs_sw eq 1 then begin
      tor_vel_sw_struct = getdata('act_sw_velocity', info.main_window_data.BES_data.shot)
    ; if rading the toroidal velocity from SW beam is successful, then
    ;    tor_vel_sw_struct.data has 2D data: [nR, nt]	 in m/s
    ;    tor_vel_sw_struct.x has 1D data: [nR]
    ;    tor_vel_sw_struct.time has 1D data: [nt]
      if tor_vel_sw_struct.erc ne 0 then begin
        result.erc = 461
        result.errmsg = bes_analyser_error_list(result.erc)
        return, result
      endif
      tor_sw_vel_available = 1
    endif else begin
      tor_sw_vel_available = 0
    endelse
    convert_to_tor_vel = 1
  endif else begin
    convert_to_tor_vel = 0
    tor_ss_vel_available = 0
    tor_sw_vel_available = 0
  endelse

; get the plotdata, first
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata
  datatype = 26
  nplots = 1 + tor_ss_vel_available + tor_sw_vel_available 

; set and check the plotdata
  if overplot eq 0 then begin
    total_nplots = nplots
    plotdata.type = datatype
    ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
    plotdata = set_extra_plot_info(info, plotdata)
    start_inx = 0
  endif else begin
  ; overplot type check
    if plotdata.type eq 0 then begin
      result.erc = 20
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    if plotdata.type ne datatype then begin
      result.erc = 21
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    total_nplots = plotdata.curr_num_plots + nplots
    start_inx = plotdata.curr_num_plots
  endelse
  if total_nplots gt plotdata.MAX_NUM_PLOTS then begin
    result.erc = 1
    result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                    string(10b) + 'You specified too many plots to be drawn.'
    return, result
  endif
  plotdata.curr_num_plots = total_nplots

; retrieve the input parameters
  nch = n_elements(signal_ch)
  for i = 0, nch - 1 do begin
    temp_data = *info.main_window_data.BES_data.ptr_data[signal_ch[i]-1]
    if i eq 0 then begin
      in_data = fltarr(nch, n_elements(temp_data))
    endif
    in_data[i, *] = temporary(temp_data)
  endfor
  in_time = *info.main_window_data.BES_data.ptr_time
  in_dt = info.main_window_data.BES_data.dt
  freq_filter = [info.vel_time_evol_window_data.freq_filter_low, info.vel_time_evol_window_data.freq_filter_high]
  temp_tinterval = abs(info.vel_time_evol_window_data.time_delay_low) > abs(info.vel_time_evol_window_data.time_delay_high)
  num_pts_per_subwindow = long(temp_tinterval/(in_dt*1e6)) + 2
  num_bins_to_average = info.vel_time_evol_window_data.num_bins_to_average
  overlap = info.vel_time_evol_window_data.frac_overlap_subwindow
  use_hanning = info.vel_time_evol_window_data.use_hanning_window
  convert_to_tor_vel = info.vel_time_evol_window_data.convert_to_tor_vel
  plot_cxrs_ss = info.vel_time_evol_window_data.compare_cxrs_ss
  plot_cxrs_sw = info.vel_time_evol_window_data.compare_cxrs_sw
  remove_large_structure = info.vel_time_evol_window_data.remove_large_structure
  if remove_large_structure eq 1 then begin
    temp_data_for_removal = *info.main_window_data.BES_data.ptr_data[0]
    data_for_removal = fltarr(32, n_elements(temp_data_for_removal))
    for i = 0, 31 do begin
      data_for_removal[i, *] = *info.main_window_data.BES_data.ptr_data[i]
    endfor
  endif else begin
    data_for_removal = 0
  endelse
  apply_median_filter = info.vel_time_evol_window_data.apply_median_filter
  median_filter_width = info.vel_time_evol_window_data.median_filter_width
  apply_field_method = info.vel_time_evol_window_data.apply_field_method
  num_time_pts_field_method = info.vel_time_evol_window_data.num_time_pts_field_method
  allowed_mult_sd = info.vel_time_evol_window_data.allowed_mult_sd
  spike_remover = info.main_window_data.spike_remover

; prepare the data
  prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                          freq_filter = freq_filter, $
                                          num_pts_per_subwindow = num_pts_per_subwindow, $
                                          num_bins_to_average = num_bins_to_average, $
                                          overlap = overlap, $
                                          spectrogram = 1, $
                                          remove_large_structure = remove_large_structure, $
                                          data_for_removal = data_for_removal, $
                                          write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                          ID_msg_box = info.id.IDL_msg_box_window.msg_text, $
                                          spike_remover = spike_remover)

  if prep_data_result.erc ne 0 then begin
    result.erc = prep_data_result.erc
    result.errmsg = prep_data_result.errmsg
    return, result
  endif

; retrieve the data from prep_data_result
  in_data = prep_data_result.out_data
  in_time = prep_data_result.out_time
  in_sel_time_range = prep_data_result.out_sel_time_range
  num_pts_per_subwindow = prep_data_result.out_num_pts_per_subwindow
  num_bins_to_average = prep_data_result.out_num_bins_to_average
  overlap = prep_data_result.out_overlap

; calculate the spatio-temporal correlation
  calc_covariance = 1
  calc_fcn_time = 1
  calc_pol_spa = 1	;note: it doesn't matter whether this is 1 or 0 for calculating velocity
                        ;      since I am not converting time to spatial domain
  convert_temp_to_spa = 0
  use_cxrs_data = 0
  use_ss_cxrs = 0
  manual_vtor = 0.0
  factor_inc_spa_pts = 1
  spa_temp_corr_result = perform_spa_temp_corr(info, in_data, in_dt, in_time, signal_ch, $
                                               num_pts_per_subwindow, num_bins_to_average, overlap, $
                                               use_hanning, calc_covariance, calc_fcn_time, $
                                               calc_pol_spa, convert_temp_to_spa, use_cxrs_data, $
                                               use_ss_cxrs, manual_vtor, factor_inc_spa_pts, use_IDL_CUDA)

; check error
  if spa_temp_corr_result.erc ne 0 then begin
    result.erc = spa_temp_corr_result.erc
    result.errmsg = spa_temp_corr_result.errmsg
    return, result
  endif

; retrieve the output
  spa_temp_corr = spa_temp_corr_result.spa_temp_corr		
  tau_vector = spa_temp_corr_result.tau_vector			;in [micro-sec]
  spa_vector = spa_temp_corr_result.spa_vector			;in [m]
  time_vector = spa_temp_corr_result.time_vector		;in [sec]

; calculate the pattern velocity
  vel_result = perform_vel_time_evol(info, spa_temp_corr, tau_vector, spa_vector, time_vector, apply_median_filter, median_filter_width, $
                                     apply_field_method, num_time_pts_field_method, allowed_mult_sd)

; check error
  if vel_result.erc ne 0 then begin
    result.erc = vel_result.erc
    result.errmsg = vel_result.errmsg
    return, result
  endif

; retrieve the data
  velocity = vel_result.vel
  vel_err = vel_result.vel_err
  time = vel_result.time

; conver the calcualted apparent velocity to toroidal velocity if a user requests
  if convert_to_tor_vel eq 1 then begin
  ; toroidal velocity = -velocity/tan(pitch_angle) due to barber pole effects
  ; First, get the pitch angle evolution at the selected BES locations
    bes_rpos = ( ((signal_ch[0] - 1) mod 8) - 3.5 ) * (-0.02) +  info.main_window_data.BES_data.viewRadius	; in [m]
    if use_efit eq 0 then begin
      pitch_angle_rpos = reform(pitch_angle_rpos_struct.data)
      ntime = n_elements(reform(pitch_angle_struct.time))
      pitch_tmin = min(pitch_angle_struct.time, /nan, max = pitch_tmax)
      pitch_angle = median(pitch_angle_struct.data, 5, /even, dimension = 2)
    endif else begin
      pitch_angle_rpos = reform(efit_flux.xaxis.vector)
      ntime = n_elements(reform(efit_flux.taxis.vector))
      pitch_tmin = min(efit_flux.taxis.vector, /nan, max = pitch_tmax)
      inx_zero_z = where(efit_flux.yaxis.vector ge 0.0)
      inx_zero_z = inx_zero_z[0]
      pitch_angle = reform(atan(efit_flux.bfield.vector[*, inx_zero_z[0], *, 2]/efit_flux.bfield.vector[*, inx_zero_z[0], *, 1]))
    endelse
    nR = n_elements(pitch_angle_rpos)
    pitch_Rmin = min(pitch_angle_rpos, /nan, max = pitch_Rmax)
    inxR = (nR - 1) * (bes_rpos - pitch_Rmin) / (pitch_Rmax - pitch_Rmin)
    inxt = (ntime - 1) * (time - pitch_tmin) / (pitch_tmax - pitch_tmin)
    new_pitch_angle = reform(interpolate(pitch_angle, inxR, inxt, /grid, cubic = -0.5))


;    pitch_angle_rpos = reform(pitch_angle_rpos_struct.data)
;    nR = n_elements(pitch_angle_rpos)
;    pitch_Rmin = min(pitch_angle_rpos, /nan, max = pitch_Rmax)
;    inxR = (nR - 1) * (bes_rpos - pitch_Rmin) / (pitch_Rmax - pitch_Rmin)
;    ntime = n_elements(reform(pitch_angle_struct.time))
;    pitch_tmin = min(pitch_angle_struct.time, /nan, max = pitch_tmax)
;    inxt = (ntime - 1) * (time - pitch_tmin) / (pitch_tmax - pitch_tmin)
;    pitch_angle = median(pitch_angle_struct.data, 5, /even, dimension = 2)
;    new_pitch_angle = reform(interpolate(pitch_angle, inxR, inxt, /grid, cubic = -0.5))

  ; Now, convert the apparent velocity to toroidal velocity
    velocity = -velocity / tan(new_pitch_angle)
    vel_err[0, *] = vel_err[0, *] / tan(new_pitch_angle)
    vel_err[1, *] = vel_err[1, *] / tan(new_pitch_angle)
  endif

; save the data
  plotdata.ptr_x[start_inx] = ptr_new(time)
  plotdata.ptr_y[start_inx] = ptr_new(velocity)
  plotdata.ptr_yerr[0, start_inx] = ptr_new(vel_err[0, *])
  plotdata.ptr_yerr[1, start_inx] = ptr_new(vel_err[1, *])
  plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
  plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))

  count = 0
  if tor_ss_vel_available eq 1 then begin
    count = count + 1
    vel_rpos = tor_vel_ss_struct.x
    vel_time = tor_vel_ss_struct.time
    vel = tor_vel_ss_struct.data / 1e3	;convert to km/s [nR, nt]
    vel_err = tor_vel_ss_struct.edata / 1e3
    nR = n_elements(vel_rpos)
    vel_Rmin = min(vel_rpos, /nan, max = vel_Rmax)
    inxR = (nR - 1) * (bes_rpos - vel_Rmin) / (vel_Rmax - vel_Rmin)
    ntime = n_elements(vel_time)
    inxt = findgen(ntime)
    new_vel = reform(interpolate(vel, inxR, inxt, /grid, cubic = -0.5))
    new_vel_err = reform(interpolate(vel_err, inxR, inxt, /grid, cubic = -0.5))
    plotdata.ptr_x[start_inx + count] = ptr_new(vel_time)
    plotdata.ptr_y[start_inx + count] = ptr_new(new_vel)
    plotdata.ptr_yerr[0, start_inx + count] = ptr_new(new_vel_err)
    plotdata.ptr_yerr[1, start_inx + count] = ptr_new(new_vel_err)
    plotdata.line_color[start_inx + count] = info.color_table_str[(start_inx + count) mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx + count] = fix((start_inx+count)/n_elements(info.color_table_str))
  endif

  if tor_sw_vel_available eq 1 then begin
    count = count + 1
    vel_rpos = tor_vel_sw_struct.x
    vel_time = tor_vel_sw_struct.time
    vel = tor_vel_sw_struct.data / 1e3	;convert to km/s [nR, nt]
    vel_err = tor_vel_sw_struct.edata / 1e3
    nR = n_elements(vel_rpos)
    vel_Rmin = min(vel_rpos, /nan, max = vel_Rmax)
    inxR = (nR - 1) * (bes_rpos - vel_Rmin) / (vel_Rmax - vel_Rmin)
    ntime = n_elements(vel_time)
    inxt = findgen(ntime)
    new_vel = reform(interpolate(vel, inxR, inxt, /grid, cubic = -0.5))
    new_vel_err = reform(interpolate(vel_err, inxR, inxt, /grid, cubic = -0.5))
    plotdata.ptr_x[start_inx + count] = ptr_new(vel_time)
    plotdata.ptr_y[start_inx + count] = ptr_new(new_vel)
    plotdata.ptr_yerr[0, start_inx + count] = ptr_new(new_vel_err)
    plotdata.ptr_yerr[1, start_inx + count] = ptr_new(new_vel_err)
    plotdata.line_color[start_inx + count] = info.color_table_str[(start_inx + count) mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx + count] = fix((start_inx+count)/n_elements(info.color_table_str))
  endif

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the loaded data.
  if ( (overplot eq 0) and (count eq 0) ) then $
    plot_result_window, info $
  else $
    plot_result_window, info, nplot = nplots

; print the notes about about the plotdata
  i = start_inx
  str = '<Line ' + string(i+1, format='(i0)') + '> ' + plotdata.line_color[i]
  case plotdata.line_style[i] of
    0: str = str + ' Solid' + string(10b)
    1: str = str + ' Dotted' + string(10b)
    2: str = str + ' Dashed' + string(10b)
    3: str = str + ' Dash Dot' + string(10b)
    4: str = str + 'Dash Dot Dot' + string(10b)
    5: str = str + 'Long Dasehs' + string(10b)
    else: str = str + string(10b)
  endcase
  str = str + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  BES Ch.: ' + string(signal_ch[0], format='(i0)')
  for j = 1, n_elements(signal_ch) - 1 do begin
    str = str + ', ' + string(signal_ch[j], format='(i0)')
  endfor
  str = str + string(10b) + $
        '  Data: Velocity' + string(10b) + $
        '  Data Dim.: [km/s]' + string(10b) + $
        '  F. Filter: [' + string(freq_filter[0], format='(f0.1)') + ', ' + $
                           string(freq_filter[1], format='(f0.1)') + '] kHz'
  time_res = time[1]-time[0]
  str = str + string(10b) + $
        '  T. Res.: ' + string(time_res*1e3, format='(f0.3)') + ' [msec]'

  if i eq 0 then $
    widget_control, info.id.main_window.result_info_text, set_value = str $
  else begin
    widget_control, info.id.main_window.result_info_text, set_value = '', /append
    widget_control, info.id.main_window.result_info_text, set_value = str, /append
  endelse

  for k = 0, count - 1 do begin
    i = start_inx + k + 1
    str = '<Line ' + string(i+1, format='(i0)') + '> ' + plotdata.line_color[i]
    case plotdata.line_style[i] of
      0: str = str + ' Solid' + string(10b)
      1: str = str + ' Dotted' + string(10b)
      2: str = str + ' Dashed' + string(10b)
      3: str = str + ' Dash Dot' + string(10b)
      4: str = str + 'Dash Dot Dot' + string(10b)
      5: str = str + 'Long Dasehs' + string(10b)
      else: str = str + string(10b)
    endcase
    str = str + $
          '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b)
    str = str + $
          '  R: ' + string(bes_rpos * 100, format='(f0.1)') + ' [m]' + string(10b) + $
          '  Data: Tor. Velocity' + string(10b) + $
          '  Data Dim.: [km/s]'
    widget_control, info.id.main_window.result_info_text, set_value = '', /append
    widget_control, info.id.main_window.result_info_text, set_value = str, /append
  endfor

  return, result

end



;===================================================================================
; This function control for plotting spectrum of eddy pattern velocity
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_vel_spec_window
;   2) 'overplot' is a keyword.
;                 If this is set, then overplot the data.
;                 If this is not set, then plot the data as new data sets.
;                 NOTE: if overplot is set, then plotdata.type must be compatiable with
;                       the currently drawn data.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_vel_spec, idinfo, overplot = in_overplot

; keyword check
  if keyword_set(in_overplot) then $
    overplot = 1 $
  else $
    overplot = 0

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check whether to use IDL or CUDA for performing calculation
  use_IDL_CUDA = 0	;if this variable is 1, then use IDL for calculation
                        ;if this variable is 2, then use CUDA for calculation
  if info.vel_spec_window_data.calc_in_IDL eq 1 then begin
    use_IDL_CUDA = 1
  endif else begin
    use_IDL_CUDA = 2
  ; check whether CUDA is online
    if info.CUDA_comm_window_data.comm_line_on eq 0 then begin
    ; a user wants to use CUDA for calculation, but CUDA is not online. --> an error.
      result.erc = 101
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

; check the selected BES channels
  inx = where(info.vel_spec_window_data.BES_ch_sel1 eq 1, count)
  if count lt 2 then begin
    result.erc = 401
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch1 = inx + 1

  inx = where(info.vel_spec_window_data.BES_ch_sel2 eq 1, count)
  if count lt 2 then begin
    result.erc = 401
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif
  signal_ch2 = inx + 1

; load the BES signals
  nplots = 1	;From this procedure, only 1 plot will be plotted on to result_draw window.
  load_result = load_bes_data(info, signal_ch1)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif
  load_result = load_bes_data(info, signal_ch2)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif

; if remove_large_structure is set, then I need to read the whole 32 BES channel signals
  if info.vel_spec_window_data.remove_large_structure eq 1 then begin
    temp_bes_ch = indgen(32) + 1
    load_result = load_bes_data(info, temp_bes_ch)
    if load_result.erc ne 0 then begin
      result.erc = load_result.erc
      result.errmsg = load_result.errmsg
      return, result
    endif
  endif

; get the plotdata, first
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata
  if info.vel_spec_window_data.calc_spectrogram eq 1 then begin
  ; 3D plot.  x: time, y:frequency, z:power or phase
    if info.vel_spec_window_data.calc_phase eq 1 then $
      datatype = 131 $	;x:time, y:frequency, z:phase
    else $
      datatype = 130	;x:time, y:frequency, z:power (liner scale)
  endif else begin
  ; 2D plot.  x:frequency, y:power or phase
    if info.vel_spec_window_data.calc_phase eq 1 then $
      datatype = 31 $	;x:frequency, y:phase
    else $
      datatype = 30	;x:frequency, y:power (linear scale)
  endelse

; set and check the plotdata
  if overplot eq 0 then begin
    total_nplots = nplots
    plotdata.type = datatype
    ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
    plotdata = set_extra_plot_info(info, plotdata)
    start_inx = 0
  endif else begin
  ; overplot type check
    if plotdata.type eq 0 then begin
      result.erc = 20
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    if plotdata.type ne datatype then begin
      result.erc = 21
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    plot_dim = fix(alog10(plotdata.type)) + 1
    if plot_dim ge 3 then begin
    ; for 3D graph, oplot is not allowed.
      result.erc = 23
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
    total_nplots = plotdata.curr_num_plots + nplots
    start_inx = plotdata.curr_num_plots
  endelse
  if total_nplots gt plotdata.MAX_NUM_PLOTS then begin
    result.erc = 1
    result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                    string(10b) + 'You specified too many plots to be drawn.'
    return, result
  endif
  plotdata.curr_num_plots = total_nplots

; retrieve the input parameters
  if array_equal(signal_ch1, signal_ch2) eq 1 then $
    num_calc_vel = 1 $	;if signal_ch1 and signal_ch2 are equal, then the number of velocity calculation is 1.
  else $
    num_calc_vel = 2	;if signal_ch1 and signal_ch2 are not equalt, then the number of velocity calculation is 2.

  in_time = *info.main_window_data.BES_data.ptr_time
  in_dt = info.main_window_data.BES_data.dt
  freq_filter = [info.vel_spec_window_data.freq_filter_low, info.vel_spec_window_data.freq_filter_high]
  temp_tinterval = abs(info.vel_spec_window_data.time_delay_low) > abs(info.vel_spec_window_data.time_delay_high)
  num_pts_per_subwindow_vt = long(temp_tinterval/(in_dt*1e6)) + 2
  num_bins_to_average_vt = info.vel_spec_window_data.num_bins_to_average_vt
  overlap_vt = info.vel_spec_window_data.frac_overlap_subwindow_vt
  use_hanning_vt = info.vel_spec_window_data.use_hanning_window_vt
  remove_large_structure = info.vel_spec_window_data.remove_large_structure
  if remove_large_structure eq 1 then begin
    temp_data_for_removal = *info.main_window_data.BES_data.ptr_data[0]
    data_for_removal = fltarr(32, n_elements(temp_data_for_removal))
    for i = 0, 31 do begin
      data_for_removal[i, *] = *info.main_window_data.BES_data.ptr_data[i]
    endfor
  endif else begin
    data_for_removal = 0
  endelse
  apply_median_filter = info.vel_spec_window_data.apply_median_filter
  median_filter_width = info.vel_spec_window_data.median_filter_width
  apply_field_method = info.vel_time_evol_window_data.apply_field_method
  num_time_pts_field_method = info.vel_time_evol_window_data.num_time_pts_field_method
  allowed_mult_sd = info.vel_time_evol_window_data.allowed_mult_sd
  calc_spectrogram = info.vel_spec_window_data.calc_spectrogram
  calc_phase = info.vel_spec_window_data.calc_phase
  num_pts_per_subwindow_vf = info.vel_spec_window_data.num_pts_per_subwindow_vf
  num_bins_to_average_vf = info.vel_spec_window_data.num_bins_to_average_vf
  overlap_vf = info.vel_spec_window_data.frac_overlap_subwindow_vf
  use_hanning_vf = info.vel_spec_window_data.use_hanning_window_vf
  norm_by_DC = info.vel_spec_window_data.norm_by_DC
  num_sel_time_range = info.time_sel_struct.curr_num_time_regions
  if num_sel_time_range gt 0 then $
    sel_time_range = info.time_sel_struct.time_regions[0:num_sel_time_range-1, *]
  spike_remover = info.main_window_data.spike_remover

; First, calcualte v(t)
  for i = 0, num_calc_vel - 1 do begin
    if i eq 0 then $
      signal_ch = signal_ch1 $
    else $
      signal_ch = signal_ch2
    nch = n_elements(signal_ch)
    for j = 0, nch - 1 do begin
      temp_data = *info.main_window_data.BES_data.ptr_data[signal_ch[j] - 1]
      if j eq 0 then begin
        in_data = fltarr(nch, n_elements(temp_data))
      endif
      in_data[j, *] = temporary(temp_data)
    endfor
    prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                            freq_filter = freq_filter, $
                                            num_pts_per_subwindow = num_pts_per_subwindow_vt, $
                                            num_bins_to_average = num_bins_to_average_vt, $
                                            overlap = overlap_vt, $
                                            spectrogram = 1, $
                                            remove_large_structure = remove_large_structure, $
                                            data_for_removal = data_for_removal, $
                                            write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                            ID_msg_box = info.id.IDL_msg_box_window.msg_text, $
                                            spike_remover = spike_remover)

    if prep_data_result.erc ne 0 then begin
      result.erc = prep_data_result.erc
      result.errmsg = prep_data_result.errmsg
      return, result
    endif

  ;retrieve the data from prep_data_result
    prep_in_data = prep_data_result.out_data
    prep_in_time = prep_data_result.out_time
    prep_in_sel_time_range = prep_data_result.out_sel_time_range
    prep_num_pts_per_subwindow_vt = prep_data_result.out_num_pts_per_subwindow
    prep_num_bins_to_average_vt = prep_data_result.out_num_bins_to_average
    prep_overlap_vt = prep_data_result.out_overlap

  ; calculate the spatio-temporal correlation
    calc_covariance = 1
    calc_fcn_time = 1
    calc_pol_spa = 1	;note: it doesn't matter whether this is 1 or 0 for calculating velocity
                        ;      since I am not converting time to spatial domain
    convert_temp_to_spa = 0
    use_cxrs_data = 0
    use_ss_cxrs = 0
    manual_vtor = 0.0
    factor_inc_spa_pts = 1
    spa_temp_corr_result = perform_spa_temp_corr(info, prep_in_data, in_dt, prep_in_time, signal_ch, $
                                                 prep_num_pts_per_subwindow_vt, prep_num_bins_to_average_vt, prep_overlap_vt, $
                                                 use_hanning_vt, calc_covariance, calc_fcn_time, $
                                                 calc_pol_spa, convert_temp_to_spa, use_cxrs_data, $
                                                 use_ss_cxrs, manual_vtor, factor_inc_spa_pts, use_IDL_CUDA)

  ; check error
    if spa_temp_corr_result.erc ne 0 then begin
      result.erc = spa_temp_corr_result.erc
      result.errmsg = spa_temp_corr_result.errmsg
      return, result
    endif

  ; retrieve the output
    spa_temp_corr = spa_temp_corr_result.spa_temp_corr		
    tau_vector = spa_temp_corr_result.tau_vector			;in [micro-sec]
    spa_vector = spa_temp_corr_result.spa_vector			;in [m]
    time_vector = spa_temp_corr_result.time_vector		;in [sec]

  ; calculate the pattern velocity
    vel_result = perform_vel_time_evol(info, spa_temp_corr, tau_vector, spa_vector, time_vector, apply_median_filter, median_filter_width, $
                                       apply_field_method, num_time_pts_field_method, allowed_mult_sd)

  ; check error
    if vel_result.erc ne 0 then begin
      result.erc = vel_result.erc
      result.errmsg = vel_result.errmsg
      return, result
    endif

  ; retrieve the data
    if i eq 0 then begin
      velocity1 = vel_result.vel
      vel_err1 = vel_result.vel_err
      vel_time1 = vel_result.time
    endif else begin
      velocity2 = vel_result.vel
      vel_err2 = vel_result.vel_err
      vel_time2 = vel_result.time
    endelse
  endfor

; Now, v1(t) and v2(t) are calcualted.  Calculate the power spectrum of them.
; retrieve the input parameters for spectrum calculation
  in_data1 = velocity1
  if num_calc_vel eq 1 then $
    in_data2 = in_data1 $
  else $
    in_data2 = velocity2
  in_time = vel_time1
  in_dt = vel_time1[1] - vel_time1[0]	;in seconds
  if num_calc_vel eq 1 then $
    auto = 1 $
  else $
    auto = 0

; prepare the data
  if auto eq 1 then begin
    in_data = fltarr(1, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
  endif else begin
    in_data = fltarr(2, n_elements(in_data1))
    in_data[0, *] = temporary(in_data1)
    in_data[1, *] = temporary(in_data2)
  endelse

  prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                          num_sel_time_range = num_sel_time_range, $
                                          sel_time_range = sel_time_range, $
                                          num_pts_per_subwindow = num_pts_per_subwindow_vf, $
                                          num_bins_to_average = num_bins_to_average_vf, $
                                          overlap = overlap_vf, $
                                          spectrogram = calc_spectrogram, $
                                          norm_by_DC = norm_by_DC, $
                                          write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                          ID_msg_box = info.id.IDL_msg_box_window.msg_text)

  if prep_data_result.erc ne 0 then begin
    result.erc = prep_data_result.erc
    result.errmsg = prep_data_result.errmsg
    return, result
  endif

; retrieve the data from prep_data_result
  in_data1 = reform(prep_data_result.out_data[0, *])
  if auto eq 1 then $
    in_data2 = in_data1 $
  else $
    in_data2 = reform(prep_data_result.out_data[1, *])
  in_time = prep_data_result.out_time
  in_sel_time_range = prep_data_result.out_sel_time_range
  num_pts_per_subwindow = prep_data_result.out_num_pts_per_subwindow
  num_bins_to_average = prep_data_result.out_num_bins_to_average
  overlap = prep_data_result.out_overlap

; calculate the spectrum
  if use_IDL_CUDA eq 2 then begin
  ; calculate using CUDA
    fft_result = perform_cuda_fft(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                  overlap, use_hanning_vf, auto)

  ; check error during perform_cuda_fft
    if fft_result.erc ne 0 then begin
      result.erc = fft_result.erc
      result.errmsg = fft_result.errmsg
      return, result
    endif

  ; retrieve the output data
    power = fft_result.power
    phase = fft_result.phase
    freq_vector = findgen(fft_result.out_num_fft_pts_per_subwindow) * 1.0/(in_dt * num_pts_per_subwindow) * 1e-3	;in [kHz]
    if calc_spectrogram eq 1 then begin
       t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
       t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
       time_vector = findgen(fft_result.out_time_pts) * t_step + t_start
    endif
  endif else begin
  ; calculate using IDL
    fft_result = perform_idl_fft(info, in_data1, in_data2, num_pts_per_subwindow, num_bins_to_average, $
                                 overlap, use_hanning_vf, auto)

  ; check error during perform_cuda_fft
    if fft_result.erc ne 0 then begin
      result.erc = fft_result.erc
      result.errmsg = fft_result.errmsg
      return, result
    endif

  ; retrieve the output data
    power = fft_result.power
    phase = fft_result.phase
    freq_vector = findgen(fft_result.out_num_fft_pts_per_subwindow) * 1.0/(in_dt * num_pts_per_subwindow) * 1e-3	;in [kHz]
    if calc_spectrogram eq 1 then begin
       t_start = (in_time[0] + in_time[num_pts_per_subwindow-1])/2.0
       t_step = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average
       time_vector = findgen(fft_result.out_time_pts) * t_step + t_start
    endif
  endelse

; save the data
  if datatype eq 130 then begin 
  ;power spectrogram
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_z[start_inx] = ptr_new(power)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 131 then begin
  ;phase spectrogram
    plotdata.ptr_x[start_inx] = ptr_new(time_vector)
    plotdata.ptr_y[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_z[start_inx] = ptr_new(phase)
    plotdata.inx_ctable = 5
    plotdata.inv_ctable = 0
  endif else if datatype eq 30 then begin
  ;power spectrum
    plotdata.ptr_x[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_y[start_inx] = ptr_new(power)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
  endif else if datatype eq 31 then begin
  ;phase spectrum
    plotdata.ptr_x[start_inx] = ptr_new(freq_vector)
    plotdata.ptr_y[start_inx] = ptr_new(phase)
    plotdata.line_color[start_inx] = info.color_table_str[start_inx mod n_elements(info.color_table_str)]
    plotdata.line_style[start_inx] = fix(start_inx/n_elements(info.color_table_str))
  endif

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the loaded data.
  if overplot eq 0 then $
    plot_result_window, info $
  else $
    plot_result_window, info, nplot = nplots

; print the notes about about the plotdata
 plot_dim = fix(alog10(plotdata.type)) + 1
  if plot_dim eq 2 then begin
    str = '<Line ' + string(start_inx+1, format='(i0)') + '> ' + plotdata.line_color[start_inx]
    case plotdata.line_style[start_inx] of
      0: str = str + ' Solid' + string(10b)
      1: str = str + ' Dotted' + string(10b)
      2: str = str + ' Dashed' + string(10b)
      3: str = str + ' Dash Dot' + string(10b)
      4: str = str + 'Dash Dot Dot' + string(10b)
      5: str = str + 'Long Dasehs' + string(10b)
      else: str = str + string(10b)
    endcase
  endif else begin
    str = '<Contour>'
  endelse

  str = str + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  BES Ch.: ' + string(10b)
  str = str + '   S1: ' + string(signal_ch1[0], format='(i0)')
  for i = 1, n_elements(signal_ch1) - 1 do begin
    str = str + ', ' + string(signal_ch1[i], format='(i0)')
  endfor
  str = str + string(10b) + '   S2: ' + string(signal_ch2[0], format='(i0)')  
  for i = 1, n_elements(signal_ch2) - 1 do begin
    str = str + ', ' + string(signal_ch2[i], format='(i0)')
  endfor
  str = str + string(10b) + '  Data: '
  if calc_phase eq 1 then $
    str = str + 'Phase' + string(10b) $
  else $
    str = str + 'Power' + string(10b)
  str = str + '  Data Dim.: '
  if calc_phase eq 1 then begin
    str = str + '[Radian]' + string(10b)
  endif else begin
    if norm_by_DC eq 1 then $
      str = str + '[vel^2/vel_dc^2/Hz]' + string(10b) $
    else $
      str = str + '[vel^2/Hz]' + string(10b)
  endelse
  str = str + $
        '  F. Filter: [' + string(freq_filter[0], format='(f0.1)') + ', ' + $
                           string(freq_filter[1], format='(f0.1)') + '] kHz' + string(10b)
  dim = size(in_sel_time_range, /dim)
  str = str + '  Num. T. Int.: ' + string(dim[0], format='(i0)') + string(10b)
  for i = 0, dim[0] - 1 do begin
    str = str + '  ' + string(i+1, format='(i2)') + ': [' + $
          string(in_sel_time_range[i, 0]*1e3, format='(f0.4)') + ', ' + $
          string(in_sel_time_range[i, 1]*1e3, format='(f0.4)') + '] msec' + string(10b)
  endfor
  freq_res = 1.0/(in_dt * num_pts_per_subwindow) * 1e-3
  str = str + $
        '  F. Res.: ' + string(freq_res, format='(f0.2)') + ' [kHz]'
  if calc_spectrogram eq 1 then begin
    time_res = in_dt * num_pts_per_subwindow * (1.0 - overlap) * num_bins_to_average * 1e3
    str = str + string(10b) + $
          '  T. Res.: ' + string(time_res, format='(f0.3)') + ' [msec]'
  endif

  if start_inx eq 0 then $
    widget_control, info.id.main_window.result_info_text, set_value = str $
  else begin
    widget_control, info.id.main_window.result_info_text, set_value = '', /append
    widget_control, info.id.main_window.result_info_text, set_value = str, /append
  endelse

  return, result

end


;===================================================================================
; This function control for plotting flux surface with BES positions
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_vel_spec_window
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_flux_surface, idinfo

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; get the flux info
  shot = info.main_window_data.BES_data.shot
  flux = read_flux(shot, /nofc)
  if flux.error ne 0 then begin
    result.erc = 551
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

; get plotdata
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

; set and check the plotdata
  nplots = 1
  datatype = 1010
  total_nplots = nplots
  plotdata.type = datatype
  ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
  plotdata = set_extra_plot_info(info, plotdata)
  start_inx = 0
  plotdata.curr_num_plots = total_nplots

; save the data
  plotdata.ptr_x[start_inx] = ptr_new(flux.xaxis.vector)
  plotdata.ptr_y[start_inx] = ptr_new(flux.yaxis.vector)
  plotdata.ptr_t[start_inx] = ptr_new(flux.taxis.vector)
  plotdata.ptr_z[start_inx] = ptr_new(reform(flux.fluxcoordinates.psin[*, *, *]))

; find the time index
  user_time = info.show_flux_surface_window_data.time
  inx = where(flux.taxis.vector ge user_time, count)
  if count lt 1 then inx = 0 else inx = inx[0]
  plotdata.inx_curr_time = inx

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the loaded data.
  plot_result_window, info

; print the notes about about the plotdata
  str = '<Contour>'
  str = str + string(10b) + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)')
  widget_control, info.id.main_window.result_info_text, set_value = str


  return, result

end


;===================================================================================
; This function control for plotting density spatio-spatio correlation of BES signal
;===================================================================================
; The function parameters:
;   1) 'idinfo' is a structure that is saved as uvalue for bes_dens_spa_temp_corr_window
;   2) 'compare_coarr': <1 or 0> if 1, then compares co-arrays in addition to calculating correlation
;                                if 0, then only calculates correlation
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function ctrl_plot_dens_spa_spa_corr, idinfo, compare_coarr

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the info structure
  widget_control, idinfo.id_main_base, get_uvalue = info

; check the selected time regions
  if info.time_sel_struct.curr_num_time_regions lt 1 then begin
    result.erc = 257
    result.errmsg = bes_analyser_error_list(result.erc)
    return, result
  endif

; check whether to use IDL or CUDA for performing calculation
  use_IDL_CUDA = 0	;if this variable is 1, then use IDL for calculation
                        ;if this variable is 2, then use CUDA for calculation
  if info.dens_spa_spa_corr_window_data.calc_in_IDL eq 1 then begin
    use_IDL_CUDA = 1
  endif else begin
    use_IDL_CUDA = 2
  ; check whether CUDA is online
    if info.CUDA_comm_window_data.comm_line_on eq 0 then begin
    ; a user wants to use CUDA for calculation, but CUDA is not online. --> an error.
      result.erc = 101
      result.errmsg = bes_analyser_error_list(result.erc)
      return, result
    endif
  endelse

; Load BES signals for all channels
  temp_bes_ch = indgen(32) + 1
  load_result = load_bes_data(info, temp_bes_ch)
  if load_result.erc ne 0 then begin
    result.erc = load_result.erc
    result.errmsg = load_result.errmsg
    return, result
  endif

; get the reference BES channel
  inx = where(info.dens_spa_spa_corr_window_data.BES_ch_sel eq 1, count)
  if count lt 1 then inx = 0
  ref_signal_ch = inx + 1
  if info.dens_spa_spa_corr_window_data.calc_spa_avg_YES eq 1 then $
    ref_signal_ch = 0

; get the plotdata, first
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata
  nplots = 1		;From this procedure, only 1 plot will be plotted on to result_draw window.
  calc_correlation = info.dens_spa_spa_corr_window_data.calc_correlation
  calc_covariance = info.dens_spa_spa_corr_window_data.calc_covariance
  if calc_correlation eq 1 then $
    datatype = 1011 $
  else $
    datatype = 1012
  total_nplots = nplots
  plotdata.type = datatype
  ptr_free, plotdata.ptr_x, plotdata.ptr_y, plotdata.ptr_yerr, plotdata.ptr_z, plotdata.ptr_t
  plotdata = set_extra_plot_info(info, plotdata)
  start_inx = 0
  plotdata.curr_num_plots = total_nplots


; retrieve the input parameters
  nch = 32
  for i = 0, nch - 1 do begin
    temp_data = *info.main_window_data.BES_data.ptr_data[i]
    if i eq 0 then begin
      in_data = fltarr(nch, n_elements(temp_data))
    endif
    in_data[i, *] = temporary(temp_data)
  endfor
  in_time = *info.main_window_data.BES_data.ptr_time
  in_dt = info.main_window_data.BES_data.dt
  num_sel_time_range = info.time_sel_struct.curr_num_time_regions
  if num_sel_time_range gt 0 then $
    sel_time_range = info.time_sel_struct.time_regions[0:num_sel_time_range-1, *]
  freq_filter = [info.dens_spa_spa_corr_window_data.freq_filter_low, info.dens_spa_spa_corr_window_data.freq_filter_high]
  temp_tinterval = abs(info.dens_spa_spa_corr_window_data.time_delay_low) > abs(info.dens_spa_spa_corr_window_data.time_delay_high)
  num_pts_per_subwindow = long(temp_tinterval/(in_dt*1e6)) + 2
  overlap = info.dens_spa_spa_corr_window_data.frac_overlap_subwindow
  use_hanning = info.dens_spa_spa_corr_window_data.use_hanning_window
  remove_large_structure = info.dens_spa_spa_corr_window_data.remove_large_structure
  if remove_large_structure eq 1 then begin
    data_for_removal = in_data
  endif else begin
    data_for_removal = 0
  endelse
  spike_remover = info.main_window_data.spike_remover  

; prepare the data
  prep_data_result = prep_to_perform_stat(in_data, in_time, in_dt, $
                                          num_sel_time_range = num_sel_time_range, $
                                          sel_time_range = sel_time_range, $
                                          freq_filter = freq_filter, $
                                          num_pts_per_subwindow = num_pts_per_subwindow, $
                                          num_bins_to_average = 0, $
                                          overlap = overlap, $
                                          spectrogram = 0, $
                                          remove_large_structure = remove_large_structure, $
                                          data_for_removal = data_for_removal, $
                                          write_status = info.main_window_data.IDL_msg_box_window_ON, $
                                          ID_msg_box = info.id.IDL_msg_box_window.msg_text, $
                                          spike_remover = spike_remover)

  if prep_data_result.erc ne 0 then begin
    result.erc = prep_data_result.erc
    result.errmsg = prep_data_result.errmsg
    return, result
  endif

; retrieve the data from prep_data_result
  in_data = prep_data_result.out_data
  in_time = prep_data_result.out_time
  in_sel_time_range = prep_data_result.out_sel_time_range
  num_pts_per_subwindow = prep_data_result.out_num_pts_per_subwindow
  num_bins_to_average = prep_data_result.out_num_bins_to_average
  overlap = prep_data_result.out_overlap

; calculate the spatio-spatio correlation
  spa_spa_corr_result = perform_spa_spa_corr(info, in_data, in_dt, in_time, ref_signal_ch, $
                                             num_pts_per_subwindow, num_bins_to_average, overlap, $
                                             use_hanning, calc_covariance, compare_coarr, use_IDL_CUDA)

; check error
  if spa_spa_corr_result.erc ne 0 then begin
    result.erc = spa_temp_corr_result.erc
    result.errmsg = spa_temp_corr_result.errmsg
    return, result
  endif

; retrieve the output
  spa_spa_corr = spa_spa_corr_result.spa_spa_corr		
  xvector = spa_spa_corr_result.xvector
  yvector = spa_spa_corr_result.yvector
  tauvector = spa_spa_corr_result.tauvector * 1e-6	;in [sec] unit

; save the data
  plotdata.ptr_x[start_inx] = ptr_new(xvector)
  plotdata.ptr_y[start_inx] = ptr_new(yvector)
  plotdata.ptr_z[start_inx] = ptr_new(spa_spa_corr)
  plotdata.ptr_t[start_inx] = ptr_new(tauvector)
  inx_tau = where(tauvector ge 0.0, count)
  if count lt 1 then inx_tau = 0 else inx_tau = inx_tau[0]
  plotdata.inx_curr_time = long(inx_tau)
  plotdata.inx_ctable = 5
  plotdata.inv_ctable = 0

; save the plotdata
  widget_control, info.id.main_window.result_draw, set_uvalue = plotdata

; plot the result data
  plot_result_window, info

; print the notes about about the plotdata
  str = '<Contour>' + string(10b) + $
        '  Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)') + string(10b) + $
        '  Ref. BES Ch.: '
  if ref_signal_ch eq 0 then $
    str = str + 'Spa. Avged.' $
  else $
    str = str + string(ref_signal_ch, format='(i0)')
  str = str + string(10b) + '  Data: ' 
  if calc_correlation eq 1 then $
    str = str + 'Correlation' + string(10b) $
  else $
    str = str + 'Covariance' + string(10b)
  str = str + '  Data Dim.: '
    if calc_correlation eq 1 then $
    str = str + '[-]' + string(10b) $
  else $
    str = str + '[V^2]' + string(10b)
  str = str + $
        '  F. Filter: [' + string(freq_filter[0], format='(f0.1)') + ', ' + $
                           string(freq_filter[1], format='(f0.1)') + '] kHz' + string(10b)
  dim = size(in_sel_time_range, /dim)
  str = str + '  Num. T. Int.: ' + string(dim[0], format='(i0)') + string(10b)
  for i = 0, dim[0] - 1 do begin
    str = str + '  ' + string(i+1, format='(i2)') + ': [' + $
          string(in_sel_time_range[i, 0]*1e3, format='(f0.4)') + ', ' + $
          string(in_sel_time_range[i, 1]*1e3, format='(f0.4)') + '] msec' + string(10b)
  endfor

  widget_control, info.id.main_window.result_info_text, set_value = str

  return, result

end
