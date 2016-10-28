;===================================================================================
;
; This file contains following functions and procedures to plot the data
;
;  1) init_plot_window
;     --> initialize the plot window and returns the system variable
;
;  2) plot_highlight
;     --> plots highlight on the window
;
;  3) draw_timeline_on_time_sel_plot
;     --> draws and/or erases timeline on time_sel_plot
;
;  4) draw_timeline_on_result_plot
;     --> draws and/or erases timeline on result_plot
;
;  5) draw_timeline
;     --> draws timeline on time_sel_window and result_window
;
;  6) plot_time_sel_window
;     --> Plot data on the time_sel_window
;
;  7) replot_time_sel_window
;     --> Replot data on the time_sel_window due to zoom or time-(de)selection.
;
;  8) plot_result_window
;     --> plot data on the result_window
;
;  9) replot_result_window
;     --> replot data on the result window due to mouse motions
;
;===================================================================================




;===================================================================================
; This porcedure initializes the plot window
;===================================================================================
; The function parameters:
;   1) 'wid' is the ID for the plot window
;   2) 'org_sys_var' is the original system variable
;===================================================================================
function init_plot_window, wid, org_sys_var

  wset, wid
  !p.background = truecolor('white')
  !p.color = truecolor('black')
  x = findgen(10)
  y = findgen(10)

  plot, x, y, /nodata, xstyle = 4, ystyle = 4

; save the system variable
  sys_var = {p:!p, $
             x:!x, $
             y:!y, $
             z:!z}

; restore the orginal system variable
  restore_sys_var, org_sys_var

; return the sys_var
  return, sys_var

end

;===================================================================================
; This porcedure highlights the mouse-selected region on the window
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'wid' is the ID for the plot window
;   3) 'for_time_sel' is set if plot_highlight is called to highlight the time selected region
;   4) 'xy_direction': if this is 1, then highlight x-direction.
;                      if this is 2, then highlight y-direction.
;                      if this is 3, then highlight z-direction (scale bar).
;                         Note: The 3D or 4d graphs ends at x=0.88 (in normalized unit) always.
;                               The scalebar ends at x = 0.93 (in normalized unit) always.
;                      Note: This keyword has a higher priority thatn info.mouse.xy_direction.
;                            So, info.mouse.xy_direction is used only if xy_direction not set.
;  5) 'mouse_position': This is an 2-element vector array (i.e. [min, max]) for highlighting in device unit.
;                       If xy_direction = 1, then x-positions are stored.
;                       If xy_direction = 2, then y-positions are stored.
;                       If xy_direction = 3, then y-positions for scalebar are stored.
;                       Note: This keyword has a higher priority thatn info.mouse.x or info.mouse.y.
;                             So, info.mouse.x or info.mouse.y are used only if mouse_position is not set.
;  6) 'data': If this is set, then mouse_position comes in as in 'data' unit rather than a device unit.
;===================================================================================
pro plot_highlight, info, wid, $
                    for_time_sel = in_for_time_sel, $
                    xy_direction = in_xy_direction, $
                    mouse_position = in_mouse_position, $
                    data = in_data

; keyword check
  if keyword_set(in_for_time_sel) then $
    highlight_color = 'green' $	;which corresponds to magenta color
  else $
    highlight_color = 'blue'	;which corresponds to yellow color

  if keyword_set(in_xy_direction) then $
    xy_direction = in_xy_direction $
  else $
    xy_direction = info.mouse.xy_direction

  if keyword_set(in_mouse_position) then $
    mouse_position = in_mouse_position $
  else begin
    if xy_direction eq 1 then $
      mouse_position = [info.mouse.x0, info.mouse.x1] $
    else if xy_direction eq 2 then $
      mouse_position = [info.mouse.y0, info.mouse.y1] $
    else if xy_direction eq 3 then $
      mouse_position = [info.mouse.y0, info.mouse.y1]
  endelse

  if keyword_set(in_data) then $
    data = 1 $
  else $
    data = 0

; set the window
  wset, wid

; restore the system variable for wid
  widget_control, info.id.main_window.time_sel_draw, get_value = wid1
  widget_control, info.id.main_window.result_draw, get_value = wid2
  if wid eq wid1 then $
    restore_sys_var, info.sys_var.time_sel_plot $
  else $
    restore_sys_var, info.sys_var.result_plot

; get the coordinate of the device region
  xr_device = [!p.clip[0], !p.clip[2]]
  yr_device = [!p.clip[1], !p.clip[3]]

  if xy_direction eq 1 then begin		;x-direciton highlight (if xy_direction=1, then x-direction)
    xr = mouse_position
    yr = yr_device
    if data eq 0 then $
      polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor(highlight_color) $
    else $
      polyfill, [xr[0], xr[1], xr[1], xr[0]], [!y.crange[0], !y.crange[0], !y.crange[1], !y.crange[1]], /data, col = truecolor(highlight_color)
  endif else if xy_direction eq 2 then begin	;y-direction highlight (if xy_direction=2, then y-direction)
    xr = xr_device
    yr = mouse_position
    if data eq 0 then $
      polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor(highlight_color) $
    else $
      polyfill, [!x.crange[0], !x.crange[1], !x.crange[1], !x.crange[0]], [yr[0], yr[0], yr[1], yr[1]], /data, col = truecolor(highlight_color)
  endif else if xy_direction eq 3 then begin	;scalebar highlight
    temp_xr = convert_coord([0.88, 0.93], [0, 1], /norm, /to_device)
    xr = reform(temp_xr[0, *])
    yr = mouse_position
    polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor(highlight_color)
  endif

; save the system variable
  save_sys_var, info, wid

; restore the system variable
  restore_sys_var, info.sys_var.org

end


;===================================================================================
; This porcedure draws the time-line on the time_sel_plot
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'time': floating type: contains the time in [sec]
;===================================================================================
pro draw_timeline_on_time_sel_plot, info, time

  line_color = truecolor('white')
  restore_sys_var, info.sys_var.time_sel_plot
  xrange = !x.crange
  yrange = !y.crange
  if ( (time gt xrange[0]) and (time lt xrange[1]) ) then begin
    widget_control, info.id.main_window.time_sel_draw, get_value = wid
    wset, wid
    device, get_graphics = oldg, set_graphics = 6
    plots, [[time, yrange[0]], [time, yrange[1]]], linestyle = 2, col = line_color
    device, set_graphics = oldg
  endif

; restore the system variable
  restore_sys_var, info.sys_var.org

end


;===================================================================================
; This porcedure draws the time-line on the result_plot
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'time': floating type: contains the time in [sec]
;   3) 'ylog': if 1, then yaxis is in log-scale
;              if 0, then yaxis is in linear-scale
;===================================================================================
pro draw_timeline_on_result_plot, info, time, ylog

  line_color = truecolor('white')
  restore_sys_var, info.sys_var.result_plot
  xrange = !x.crange
  if ylog eq 1 then yrange = 10.0^!y.crange else yrange = !y.crange

  if ( (time gt xrange[0]) and (time lt xrange[1]) ) then begin
    widget_control, info.id.main_window.result_draw, get_value = wid
    wset, wid
    device, get_graphics = oldg, set_graphics = 6
    plots, [[time, yrange[0]], [time, yrange[1]]], linestyle = 2, col = line_color
    device, set_graphics = oldg
  endif

; restore the system variable
  restore_sys_var, info.sys_var.org

end

;===================================================================================
; This porcedure draws the time-line on the plots
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'by_slider': <1 or 0>
;                   If 1, then this procedure is called due to the slider motion.
;                   If 0, then this procedure is called from a regular plot
;   3) 'by_time_sel_plot': <1 or 0>
;                          If 1, then this procedure is called due to replotting time_sel_plot window
;   4) 'by_result_plot': <1 or 0>
;                        If 1, then this procedure is called due to replotting result_plot window
;===================================================================================
pro draw_timeline, info, by_slider = in_by_slider, by_time_sel_plot = in_by_time_sel_plot, by_result_plot = in_by_result_plot

; get the previous timeline location
  prev_time = info.main_window_data.slider_pos_time
; get the plotdata
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

; For the case when timeline is not allowed.

  if (widget_info(info.id.main_window.show_time_indicator_button, /sensitive) eq 0) then begin
    if (info.main_window_data.timeline_indicator_ON eq 1) then begin
    ; time indicator is not allowed, but the timeline was ON before. 
    ; thus, I need to remove the timeline on the time_sel_draw
    ; Note: I do not need to remove the tmieilne on the result_draw because the line is automatically removed by the plot procedure.
      draw_timeline_on_time_sel_plot, info, prev_time

    ; setting main_window_data
      info.main_window_data.slider_pos_time = !values.f_nan
      info.main_window_data.timeline_indicator_ON = 0
      widget_control, info.id.main_window.main_base, set_uvalue = info
    endif

    return
  endif

; For the case when timeline is allowed.

; time_indicator_button becomes OFF.
  if widget_info(info.id.main_window.show_time_indicator_button, /button_set) eq 0 then begin
    if (info.main_window_data.timeline_indicator_ON eq 0) then begin
    ; it was OFF before, so there is nothing to do.
      return
    endif else begin
    ; it was ON before, and a user wants it to be OFF.
    ; remove the existing timeline
      draw_timeline_on_result_plot, info, prev_time, plotdata.ylog
      draw_timeline_on_time_sel_plot, info, prev_time

    ; setting main_window_data
      info.main_window_data.timeline_indicator_ON = 0
      widget_control, info.id.main_window.main_base, set_uvalue = info
      return
    endelse
  endif

; The user moved the slider to move the timeline indicator
  if keyword_set(in_by_slider) then begin
  ; get the new time
    slider_min_max = widget_info(info.id.main_window.result_draw_slider, /slider_min_max)
    widget_control, info.id.main_window.result_draw_slider, get_value = curr_slider_pos
    restore_sys_var, info.sys_var.result_plot
    xrange = !x.crange
    new_time = (xrange[1]-xrange[0])/(slider_min_max[1]-slider_min_max[0])*curr_slider_pos + xrange[0]
    new_time = long(new_time*1e7)*1e-7	;precision change.

    if (info.main_window_data.timeline_indicator_ON eq 0) then begin
    ; the timeline was OFF before.
    ; draw the timelines
      draw_timeline_on_result_plot, info, new_time, plotdata.ylog
      draw_timeline_on_time_sel_plot, info, new_time
    endif else begin
    ; the timeilne was ON before.
    ; easre the previous timeilne and draw the new time ilne
      draw_timeline_on_result_plot, info, prev_time, plotdata.ylog
      draw_timeline_on_result_plot, info, new_time, plotdata.ylog
      draw_timeline_on_time_sel_plot, info, prev_time
      draw_timeline_on_time_sel_plot, info, new_time
    endelse

    ; setting main_window_data
    info.main_window_data.slider_pos_time = new_time
    info.main_window_data.timeline_indicator_ON = 1
    widget_control, info.id.main_window.main_base, set_uvalue = info
    return
  endif

; The user replotted the time_sel_plot
  if keyword_set(in_by_time_sel_plot) then begin
    if (info.main_window_data.timeline_indicator_ON eq 1) then begin
      draw_timeline_on_time_sel_plot, info, prev_time
    endif
    return
  endif

; The user replotted the result_plot
  if keyword_set(in_by_result_plot) then begin
    if (info.main_window_data.timeline_indicator_ON eq 1) then begin
    ; move the slider position in accordance with the prev_time line position
    ; set the slider position
      slider_min_max = widget_info(info.id.main_window.result_draw_slider, /slider_min_max)
      restore_sys_var, info.sys_var.result_plot
      xrange = !x.crange
      curr_slider_pos = (prev_time - xrange[0])/(xrange[1]-xrange[0]) * (slider_min_max[1] - slider_min_max[0])
      if curr_slider_pos lt 0 then curr_slider_pos = 0
      if curr_slider_pos gt slider_min_max[1] then curr_silder_pos = slider_min_max[1]
      widget_control, info.id.main_window.result_draw_slider, set_value = curr_slider_pos

    ; redraw the timeline
      draw_timeline_on_result_plot, info, prev_time, plotdata.ylog
    endif
    return
  endif

end


;===================================================================================
; This porcedure plots data on the time_sel_window
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
; Return value:
;   result = {erc:erc, errmsg:errmsg}
;   if result.erc eq 0, then no error
;   if result.erc ne 0, then error
;===================================================================================
function plot_time_sel_window, info

; return variable structure
  result = {erc:0, $
            errmsg:''}

; get the window id
  widget_control, info.id.main_window.time_sel_draw, get_value = wid
  wset, wid

; get the plotdata
  widget_control, info.id.main_window.time_sel_draw, get_uvalue = plotdata

; retrieve necessary data
  BES_data = info.main_window_data.BES_data
  plasma_current_data = info.main_window_data.plasma_current_data
  plasma_density_data = info.main_window_data.plasma_density_data
  SS_beam_data = info.main_window_data.SS_beam_data
  dalpha_data = info.main_window_data.dalpha_data

; check the number of plots to be drawn on the window
  curr_num_plots = 0
  for i = 0, 31 do begin
    if ( (info.time_sel_window_data.BES_ch_sel[i] eq 1) and (BES_data.loaded_ch[i] eq 1) ) then begin
      curr_num_plots = curr_num_plots + 1
    endif
  endfor
  if ( (info.time_sel_window_data.plasma_current_sel eq 1) and (plasma_current_data.loaded eq 1) ) then $
    curr_num_plots = curr_num_plots + 1
  if ( (info.time_sel_window_data.plasma_density_sel eq 1) and (plasma_density_data.loaded eq 1) ) then $
    curr_num_plots = curr_num_plots + 1
  if ( (info.time_sel_window_data.SS_beam_sel eq 1) and (SS_beam_data.loaded eq 1) ) then $
    curr_num_plots = curr_num_plots + 1
  if ( (info.time_sel_window_data.dalpha_sel eq 1) and (dalpha_data.loaded eq 1) ) then $
    curr_num_plots = curr_num_plots + 1

  if curr_num_plots gt plotdata.MAX_NUM_PLOTS then begin
    result.erc = 1
    result.errmsg = 'Maximum allowed number of plots are ' + string(plotdata.MAX_NUM_PLOTS, format='(i0)') + '.' + $
                    string(10b) + 'You specified too many plots to be drawn.'
    return, result
  endif

  plotdata.curr_num_plots = curr_num_plots
  inx_curr_plots = 0

; set the system variable for time_sel_window plot
  restore_sys_var, info.sys_var.time_sel_plot

  MAX_TIME = 1.0	;plot the data only for less than 1.0 second
  MIN_TIME = -0.1
  xrange = [MIN_TIME, MAX_TIME]
  xtitle = 'Time [sec]'
  ytitle = 'BES Singal [V]'

  first_plot = 1
  for i = 0, 31 do begin
    if info.time_sel_window_data.BES_ch_sel[i] eq 1 then begin
      if BES_data.loaded_ch[i] eq 1 then begin
        time = *BES_data.ptr_time
        data = *BES_data.ptr_data[i]
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
      ;filter the signal
        freq_low = info.time_sel_window_data.freq_filter_low
        freq_high = info.time_sel_window_data.freq_filter_high
        dt = info.main_window_data.BES_data.dt
        if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
          widget_control, info.id.IDL_msg_box_window.msg_text, set_value = '', /append
          str = 'Filtering BES Signal Ch. ' + string(i+1, format='(i0)') + ' from ' + $
                string(freq_low, format='(f0.2)') + ' to ' + string(freq_high, format='(f0.2)') + 'kHz...'
          widget_control, info.id.IDL_msg_box_window.msg_text, set_value = str, /append, /no_newline
        endif
        filter_result = freq_filter_signal(data, freq_low, freq_high, dt)
        filtered_data = filter_result.filtered_signal[filter_result.inx_nonzero_begin:filter_result.inx_nonzero_end]
        time = time[filter_result.inx_nonzero_begin:filter_result.inx_nonzero_end]
        if info.main_window_data.IDL_msg_box_window_ON eq 1 then begin
          widget_control, info.id.IDL_msg_box_window.msg_text, set_value = 'DONE!', /append
        endif
      ; plot the data
        if first_plot eq 1 then begin
          first_plot = 0
          plot, time, filtered_data, col = truecolor('black'), xrange = xrange, xstyle = 1, ytitle = ytitle, xtitle = xtitle
        endif else begin
          oplot, time, filtered_data, col = truecolor('black')
        endelse
      ; save the data
        plotdata.ptr_x[inx_curr_plots] = ptr_new(time)
        plotdata.ptr_y[inx_curr_plots] = ptr_new(filtered_data)
        plotdata.line_color[inx_curr_plots] = 'black'
        inx_curr_plots = inx_curr_plots + 1
      endif
    endif
  endfor

  if info.time_sel_window_data.plasma_current_sel eq 1 then begin
    if plasma_current_data.loaded eq 1 then begin
      time = *plasma_current_data.ptr_time
      data = *plasma_current_data.ptr_data
      norm = info.time_sel_window_data.plasma_current_scale *1000.0
      if first_plot eq 1 then begin
        first_plot = 0
        plot, time, data/norm, col = truecolor('black'), /nodata, xrange = xrange, xstyle = 1, ytitle = ytitle, xtitle = xtitle
        oplot, time, data/norm, col = truecolor('red')
      endif else begin
        oplot, time, data/norm, col = truecolor('red')
      endelse
      plotdata.ptr_x[inx_curr_plots] = ptr_new(time)
      plotdata.ptr_y[inx_curr_plots] = ptr_new(data/norm)
      plotdata.line_color[inx_curr_plots] = 'red'
      inx_curr_plots = inx_curr_plots + 1
    endif
  endif

  if info.time_sel_window_data.plasma_density_sel eq 1 then begin
    if plasma_density_data.loaded eq 1 then begin
      time = *plasma_density_data.ptr_time
      data = *plasma_density_data.ptr_data
      norm = info.time_sel_window_data.plasma_density_scale
      if first_plot eq 1 then begin
        first_plot = 0
        plot, time, data/norm, col = truecolor('black'), /nodata, xrange = xrange, xstyle = 1, ytitle = ytitle, xtitle = xtitle
        oplot, time, data/norm, col = truecolor('green')
      endif else begin
        oplot, time, data/norm, col = truecolor('green')
      endelse
      plotdata.ptr_x[inx_curr_plots] = ptr_new(time)
      plotdata.ptr_y[inx_curr_plots] = ptr_new(data/norm)
      plotdata.line_color[inx_curr_plots] = 'green'
      inx_curr_plots = inx_curr_plots + 1
    endif
  endif

  if info.time_sel_window_data.SS_beam_sel eq 1 then begin
    if SS_beam_data.loaded eq 1 then begin
      time = *SS_beam_data.ptr_time
      data = *SS_beam_data.ptr_data
      norm = info.time_sel_window_data.SS_beam_scale
      if first_plot eq 1 then begin
        first_plot = 0
        plot, time, data/norm, col = truecolor('black'), /nodata, xrange = xrange, xstyle = 1, ytitle = ytitle, xtitle = xtitle
        oplot, time, data/norm, col = truecolor('blue')
      endif else begin
        oplot, time, data/norm, col = truecolor('blue')
      endelse
      plotdata.ptr_x[inx_curr_plots] = ptr_new(time)
      plotdata.ptr_y[inx_curr_plots] = ptr_new(data/norm)
      plotdata.line_color[inx_curr_plots] = 'blue'
      inx_curr_plots = inx_curr_plots + 1
    endif
  endif

  if info.time_sel_window_data.dalpha_sel eq 1 then begin
    if dalpha_data.loaded eq 1 then begin
      time = *dalpha_data.ptr_time
      data = *dalpha_data.ptr_data
      norm = info.time_sel_window_data.dalpha_scale
      if first_plot eq 1 then begin
        first_plot = 0
        plot, time, data/norm, col = truecolor('black'), /nodata,  xrange = xrange, xstyle = 1, ytitle = ytitle, xtitle = xtitle
        oplot, time, data/norm, col = truecolor('cyan')
      endif else begin
        oplot, time, data/norm, col = truecolor('cyan')
      endelse
      plotdata.ptr_x[inx_curr_plots] = ptr_new(time)
      plotdata.ptr_y[inx_curr_plots] = ptr_new(data/norm)
      plotdata.line_color[inx_curr_plots] = 'cyan'
      inx_curr_plots = inx_curr_plots + 1
    endif
  endif

; write the shot number
  shot_info_str = 'Shot Number: ' + string(BES_data.shot, format='(i0)')
  xyouts, 0.75, 0.92, shot_info_str, /normal

; save the plotdata
  if plotdata.curr_num_plots lt 1 then $
    plotdata.type = 0 $
  else $
    plotdata.type = 11
  widget_control, info.id.main_window.time_sel_draw, set_uvalue = plotdata

; save the system variable
  save_sys_var, info, wid

; Draw highlights if selected time regions exist.
  device, get_graphics = oldg, set_graphics = 6
  for i = 0, info.time_sel_struct.curr_num_time_regions - 1 do begin
    timerange = reform(info.time_sel_struct.time_regions[i, *])
    if (timerange[1] gt xrange[0]) and (timerange[0] lt xrange[1]) then begin
      if ( timerange[0] lt xrange[0] ) then $
        timerange[0] = xrange[0]
      if ( timerange[1] gt xrange[1] ) then $
        timerange[1] = xrange[1]

    ; set the system variable for time_sel_window plot
      restore_sys_var, info.sys_var.time_sel_plot
      temp_device_coord = convert_coord([timerange[0], timerange[1]],[0, 1], /data, /to_device)
      xr_device = reform(temp_device_coord[0, *])
      plot_highlight, info, wid, /for_time_sel, xy_direction = 1, mouse_position = xr_device
    endif
  endfor
  device, set_graphics = oldg

; check if plotdata.curr_num_plots = 0.  If it is, then initialize the plot
  widget_control, info.id.main_window.time_sel_draw, get_uvalue = plotdata
  if plotdata.curr_num_plots lt 1 then begin
    info.sys_var.time_sel_plot = init_plot_window(wid, info.sys_var.org)
    widget_control, info.id.main_window.main_base, set_uvalue = info
  endif

; restore the system variable
  restore_sys_var, info.sys_var.org

; draw the timeilne indicator
  draw_timeline, info, /by_time_sel_plot

  return, result

end

;===================================================================================
; This porcedure replots data on the time_sel_window due to zoom or time-(de)selection.
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'xr_device' is the range of x-axis in device unit. i.e. xrange = [xmin, xmax]
;   3) 'yr_device' is the range of y-axis in device unit. i.e. yrange = [ymin, ymax]
;   NOTE: if 'xr_device' or 'yr_device' is not specified, then
;         use !x.crange or !y.crange
;         if neither xr_device nor yr_deivce are specified, then reset the plot.
;===================================================================================
pro replot_time_sel_window, info, xr_device = in_xr_device, yr_device = in_yr_device

; get the window id
  widget_control, info.id.main_window.time_sel_draw, get_value = wid
  wset, wid

; get the plotdata
  widget_control, info.id.main_window.time_sel_draw, get_uvalue = plotdata

; set the system variable for time_sel_window plot
  restore_sys_var, info.sys_var.time_sel_plot

; check the keyword
  if ( (not keyword_set(in_xr_device)) and (not keyword_set(in_yr_device)) ) then begin
  ; reset the plot
  ; I need to find the max and min of x and y values.
    for i = 0, plotdata.curr_num_plots - 1 do begin
      x = *plotdata.ptr_x[i]
      y = *plotdata.ptr_y[i]
      if i eq 0 then begin
        xmin = min(x, /nan, max = xmax)
        ymin = min(y, /nan, max = ymax)
      endif
      temp_xmin = min(x, /nan, max = temp_xmax)
      temp_ymin = min(y, /nan, max = temp_ymax)
      xmin = xmin < temp_xmin
      xmax = xmax > temp_xmax
      ymin = ymin < temp_ymin
      ymax = ymax > temp_ymax
    endfor
    xmin = xmin > (-0.1)
    xmax = xmax < 1.0
    xrange = [xmin, xmax]
    yrange = [ymin, ymax]
  endif else begin
   if not keyword_set(in_xr_device) then begin
      xrange = !x.crange
    endif else begin
    ; convert the in_xr_device into data units
      xr_device = in_xr_device
      temp_data_coord = convert_coord([xr_device[0], xr_device[1]], [0, 1], /device, /to_data)
      xrange = reform(temp_data_coord[0, *])
    endelse

    if not keyword_set(in_yr_device) then begin
      yrange = !y.crange
    endif else begin
    ; convert the in_yr_device into data units
      yr_device = in_yr_device
      temp_data_coord = convert_coord([0, 1], [yr_device[0], yr_device[1]], /device, /to_data)
      yrange = reform(temp_data_coord[1, *])
    endelse
  endelse

; plot the data
  for i = 0, plotdata.curr_num_plots - 1 do begin
    x = *plotdata.ptr_x[i]
    y = *plotdata.ptr_y[i]
    if i eq 0 then begin
      plot, x, y, xrange = xrange, yrange = yrange, xtitle = 'Time [sec]', ytitle = 'BES Signal [V]', /nodata, color = truecolor('black'), $
            xstyle = 1, ystyle = 1
    endif
    oplot, x, y, col = truecolor(plotdata.line_color[i])
  endfor

; write the shot number
  shot_info_str = 'Shot Number: ' + string(info.main_window_data.BES_data.shot, format='(i0)')
  xyouts, 0.75, 0.92, shot_info_str, /normal

; save the system variable
  save_sys_var, info, wid

; Draw highlights if selected time regions exist.
  device, get_graphics = oldg, set_graphics = 6
  for i = 0, info.time_sel_struct.curr_num_time_regions - 1 do begin
    timerange = reform(info.time_sel_struct.time_regions[i, *])
    if (timerange[1] gt xrange[0]) and (timerange[0] lt xrange[1]) then begin
      if ( timerange[0] lt xrange[0] ) then $
        timerange[0] = xrange[0]
      if ( timerange[1] gt xrange[1] ) then $
        timerange[1] = xrange[1]

    ; set the system variable for time_sel_window plot
      restore_sys_var, info.sys_var.time_sel_plot
      temp_device_coord = convert_coord([timerange[0], timerange[1]],[0, 1], /data, /to_device)
      xr_device = reform(temp_device_coord[0, *])
      plot_highlight, info, wid, /for_time_sel, xy_direction = 1, mouse_position = xr_device
    endif
  endfor
  device, set_graphics = oldg

; restore the system variable
  restore_sys_var, info.sys_var.org

; draw the timeilne indicator
  draw_timeline, info, /by_time_sel_plot

end


;===================================================================================
; This porcedure plots data on the result_window
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'nplot' is the number of data to be overplotted.
;       If nplot is not set, then redraw whole data sets in plotdata.
;       if nplot is set to some number, then draw only last nplot data sets.
;   3) 'play_movie' keyword is usde only for 4D data type.
;                   If this is set, then plays movie.
;                   If this is not set, then show a plot at one time.
;===================================================================================
pro plot_result_window, info, nplot = in_nplot, play_movie = in_play_movie

; keyword check
  if keyword_set(in_nplot) then $
    nplot = in_nplot $
  else $
    nplot = 0 

  if keyword_set(in_play_movie) then $
    play_movie = 1 $
  else $
    play_movie = 0

; set the plot window
  widget_control, info.id.main_window.result_draw, get_value = wid
  wset, wid

; get the plotdata
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

; get the dimension of the data
  if plotdata.type gt 0 then $
    plot_dim = fix(alog10(plotdata.type)) + 1 $
  else $
    plot_dim = 2

; restore the system variable
  restore_sys_var, info.sys_var.result_plot

; plot the result
  xtitle = plotdata.xtitle
  ytitle = plotdata.ytitle
  ztitle = plotdata.ztitle
  title = plotdata.title
  pre_title = plotdata.pre_title
  xlog = plotdata.xlog
  ylog = plotdata.ylog
  zlog = plotdata.zlog
  shade_pos = plotdata.shade_pos
  scale_pos = plotdata.scale_pos

  if nplot ne 0 then $
    start_inx = plotdata.curr_num_plots - nplot $
  else $
    start_inx = 0

  for i = start_inx, plotdata.curr_num_plots - 1 do begin
    x = *plotdata.ptr_x[i]
    y = *plotdata.ptr_y[i]
    if plot_dim ge 3 then z = *plotdata.ptr_z[i]
    if plot_dim ge 4 then t = *plotdata.ptr_t[i]
    if i eq 0 then begin
      if plot_dim eq 2 then begin
      ;2D plot
        plot, x, y, xtitle = xtitle, ytitle = ytitle, ylog = ylog, /nodata, color = truecolor('black')
      endif else if plot_dim eq 3 then begin
      ;3D plot
        minx = min(x, max = maxx)
        miny = min(y, max = maxy)
        if zlog eq 1 then begin
        ; I need to be careful of taking log base 10, since the argument must be greater than 0.
          inx_zero = where(z le 0.0, count_zero)
          if count_zero gt 0 then $
            z[inx_zero] = !values.f_nan
          z = temporary(alog10(z))
          minz = min(z, /nan, max = maxz)
        endif else begin
          minz = min(z, max = maxz)
        endelse
        if minx eq maxx then maxx = minx + 1.0
        if miny eq maxy then maxy = miny + 1.0
        if minz eq maxz then maxz = minz + 1.0
        bes_analyser_cp_shade_mod, z, x, y, $
                                   title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                   /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                   xrange = [minx, maxx], yrange = [miny, maxy], zrange = [minz, maxz], $
                                   pos = shade_pos, scalepos = scale_pos
      endif else if plot_dim eq 4 then begin
      ;4D plot
        if plotdata.type eq 1001 then begin
        ; This is a BES movie
          bes_ani_data = info.bes_animation_window_data
          inx_curr_time = plotdata.inx_curr_time
          minx = min(x, max = maxx)
          miny = min(y, max = maxy)
          minz = min(z, max = maxz)
          if minx eq maxx then maxx = minx + 1.0
          if miny eq maxy then maxy = miny + 1.0
          if minz eq maxz then maxz = minz + 1.0
          if bes_ani_data.show_BES_pos eq 1 then begin
              centre_pos = info.main_window_data.BES_data.viewRadius
              bes_pos = fltarr(32, 2)
              inx = findgen(32)
              bes_pos[*, 0] = ((inx mod 8)-3.5) * (-2.0) + centre_pos * 100.0	;Major Radial position in [cm]
              bes_pos[*, 1] = (fix(inx/8) - 1.5) * 2.0				;Polodial position in [c]
          endif

          if play_movie eq 1 then begin
          ; get the window and pixmap ids
            x_win_size = !d.x_size
            y_win_size = !d.y_size
            window, /free, /pixmap, xsize = x_win_size, ysize = y_win_size	;creating pixmap window
            pid = !d.window
            nt = n_elements(t)
            for i = 0, nt - 1 do begin
              title = pre_title +  'Time = '
              title = title + string(t[i]*1e3, format='(f0.4)') + ' [msec]'
            ; make the pixmap the active window
              wset, pid	
              bes_analyser_cp_shade_mod, z[*, *, i], x, y, $
                                         title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                         /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                         xrange = [minx-0.5, maxx+0.5], yrange = [miny-0.5, maxy+0.5], zrange = [minz, maxz], $
                                         pos = shade_pos, scalepos = scale_pos

              if bes_ani_data.show_BES_pos eq 1 then $
                oplot, bes_pos[*, 0], bes_pos[*, 1], psym = 2, col = truecolor(bes_ani_data.col_BES_pos_str)
            ; set the draw window to be active once again
              wset, wid
            ; copy the contents of the pixmap to the draw window
              device, copy = [0 , 0, x_win_size, y_win_size, 0, 0, pid]
            endfor
            wdelete, pid	; delete pixmap window	
          endif else begin
            title = pre_title + 'Time = '
            title = title + string(t[inx_curr_time]*1e3, format='(f0.4)') + ' [msec]'
            bes_analyser_cp_shade_mod, z[*, *, inx_curr_time], x, y, $
                                       title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                       /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                       xrange = [minx-0.5, maxx+0.5], yrange = [miny-0.5, maxy+0.5], zrange = [minz, maxz], $
                                       pos = shade_pos, scalepos = scale_pos

            if bes_ani_data.show_BES_pos eq 1 then $
              oplot, bes_pos[*, 0], bes_pos[*, 1], psym = 2, col = truecolor(bes_ani_data.col_BES_pos_str)
          endelse

        endif else if ( (plotdata.type eq 1006) or (plotdata.type eq 1007) or (plotdata.type eq 1008) or (plotdata.type eq 1009) or $
                        (plotdata.type eq 1011) or (plotdata.type eq 1012) ) then begin
          inx_curr_time = plotdata.inx_curr_time
          minx = min(x, max = maxx)
          miny = min(y, max = maxy)
          if zlog eq 1 then begin
          ; I need to be careful of taking log base 10, since the argument must be greater than 0.
            inx_zero = where(z le 0.0, count_zero)
            if count_zero gt 0 then $
              z[inx_zero] = !values.f_nan
            z = temporary(alog10(z))
            minz = min(z, /nan, max = maxz)
          endif else begin
            minz = min(z, max = maxz)
          endelse
          if minx eq maxx then maxx = minx + 1.0
          if miny eq maxy then maxy = miny + 1.0
          if minz eq maxz then maxz = minz + 1.0
          if play_movie eq 1 then begin
          ; get the window and pixmap ids
            x_win_size = !d.x_size
            y_win_size = !d.y_size
            window, /free, /pixmap, xsize = x_win_size, ysize = y_win_size	;creating pixmap window
            pid = !d.window
            nt = n_elements(t)
            for i = 0, nt - 1 do begin
              title = pre_title +  'Time = '
              title = title + string(t[i]*1e3, format='(f0.4)') + ' [msec]'
            ; make the pixmap the active window
              wset, pid	
              bes_analyser_cp_shade_mod, z[*, *, i], x, y, $
                                         title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                         /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                         xrange = [minx, maxx], yrange = [miny, maxy], zrange = [minz, maxz], $
                                         pos = shade_pos, scalepos = scale_pos
            ; set the draw window to be active once again
              wset, wid
            ; copy the contents of the pixmap to the draw window
              device, copy = [0 , 0, x_win_size, y_win_size, 0, 0, pid]
            endfor
            wdelete, pid	; delete pixmap window
          endif else begin
            title = pre_title + 'Time = '
            title = title + string(t[inx_curr_time]*1e3, format='(f0.4)') + ' [msec]'
            bes_analyser_cp_shade_mod, z[*, *, inx_curr_time], x, y, $
                                       title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                       /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                         xrange = [minx, maxx], yrange = [miny, maxy], zrange = [minz, maxz], $
                                         pos = shade_pos, scalepos = scale_pos
          endelse
        endif else if plotdata.type eq 1010 then begin	; for flux surface
          inx_curr_time = plotdata.inx_curr_time
          minx = min(x, max = maxx)
          miny = min(y, max = maxy)
          if zlog eq 1 then begin
          ; I need to be careful of taking log base 10, since the argument must be greater than 0.
            inx_zero = where(z le 0.0, count_zero)
            if count_zero gt 0 then $
              z[inx_zero] = !values.f_nan
            z = temporary(alog10(z))
            minz = min(z, /nan, max = maxz)
          endif else begin
            minz = min(z, max = maxz)
          endelse
          title = pre_title + 'Time = '
          title = title + string(t[inx_curr_time]*1e3, format='(f0.4)') + ' [msec]'
        ; draw flux contour
          label_step_size = info.show_flux_surface_window_data.contour_line_step
          show_label = info.show_flux_surface_window_data.show_label
          last_line = 1.5
          num_lines = fix(last_line/label_step_size)
          levels = findgen(num_lines)*label_step_size
          inx_lcfs_level = where(levels ge 0.999, count)
          if count gt 0 then inx_lcfs_level = inx_lcfs_level[0] else inx_lcfs_level = -1
          c_labels = intarr(num_lines)
          c_labels[*] = show_label
          c_colors = lonarr(num_lines)
          c_colors[*] = truecolor('black')
          if inx_lcfs_level ne -1 then c_colors[inx_lcfs_level] = truecolor('blue')

          contour, reform(z[*, *, inx_curr_time]), x, y, $
                   levels = levels, c_labels = c_labels, c_colors = c_colors, $
                   title = title, xtitle = xtitle, ytitle = ytitle, $
                   xrange = [minx, maxx], yrange = [miny, maxy], zrange = [minz, maxz], /iso

          bes_cent_pos = info.main_window_data.BES_data.viewRadius
          zpos = [-0.03, -0.01, 0.01, 0.03]
          rpos = findgen(8)*0.02 - 0.07 + bes_cent_pos
          psymcircle, size = 0.5, /fill
          for i = 0, 7 do begin
            for j = 0, 3 do begin
              oplot, [rpos[i], rpos[i]], [zpos[j], zpos[j]], psym = 8, col = truecolor('red')
            endfor
          endfor
        endif
      ; save the title for 4D
        plotdata.title = title
        widget_control, info.id.main_window.result_draw, set_uvalue = plotdata
      endif
    endif
    if plot_dim eq 2 then $
      oplot, x, y, color = truecolor(plotdata.line_color[i]), linestyle = plotdata.line_style[i]

  endfor


; save the system variable
  save_sys_var, info, wid

; restore the system variable
  restore_sys_var, info.sys_var.org

; draw the timeilne indicator
  draw_timeline, info, /by_result_plot

end


;===================================================================================
; This porcedure replots data on the result_window due to mouse motions
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;   2) 'xr_device' is the range of x-axis in device unit. i.e. xrange = [xmin, xmax]
;   3) 'yr_device' is the range of y-axis in device unit. i.e. yrange = [ymin, ymax]
;   4) 'zr_device' is the range of z-axis in device unit. i.e. zrange = [zmin, zmax]
;                  Note: zr_device is actually given in y-direction device coordinates because
;                        the scalebar is in y-direction.
;   5) 'data': if this is set, then xr_device, yr_device, and zr_device is given in data unit rather than device unit.
;   NOTE: if 'xr_device', 'yr_device' or 'zr_device' is not specified, then
;         use !x.crange, !y.crange or !z.crange
;         if neither xr_device nor yr_deivce nor zr_device are specified, then reset the plot.
;===================================================================================
pro replot_result_window, info, xr_device = in_xr_device, yr_device = in_yr_device, zr_device = in_zr_device, data = in_data

; get the window id
  widget_control, info.id.main_window.result_draw, get_value = wid
  wset, wid

; get the plotdata
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

; set the system variable for result plot
  restore_sys_var, info.sys_var.result_plot

; get the dimension of the data
  if plotdata.type gt 0 then $
    plot_dim = fix(alog10(plotdata.type)) + 1 $
  else $
    plot_dim = 2

; checking the keywords
  if keyword_set(in_data) then begin
    data_unit = 1
  endif else begin
    data_unit = 0
  endelse

  xtitle = plotdata.xtitle
  ytitle = plotdata.ytitle
  ztitle = plotdata.ztitle
  title = plotdata.title
  pre_title = plotdata.pre_title
  xlog = plotdata.xlog
  ylog = plotdata.ylog
  zlog = plotdata.zlog
  shade_pos = plotdata.shade_pos
  scale_pos = plotdata.scale_pos

  if plot_dim eq 2 then begin
    if ( (not keyword_set(in_xr_device)) and (not keyword_set(in_yr_device)) ) then begin
    ; reset the plot
    ; I need to find the max and min of x and y values.
      for i = 0, plotdata.curr_num_plots - 1 do begin
        x = *plotdata.ptr_x[i]
        y = *plotdata.ptr_y[i]
        if i eq 0 then begin
          xmin = min(x, /nan, max = xmax)
          ymin = min(y, /nan, max = ymax)
        endif
        temp_xmin = min(x, /nan, max = temp_xmax)
        temp_ymin = min(y, /nan, max = temp_ymax)
        xmin = xmin < temp_xmin
        xmax = xmax > temp_xmax
        ymin = ymin < temp_ymin
        ymax = ymax > temp_ymax
      endfor
      xrange = [xmin, xmax]
      yrange = [ymin, ymax]
    endif else begin
      if not keyword_set(in_xr_device) then begin
        xrange = !x.crange
      endif else begin
      ; convert the in_xr_device into data units
        xr_device = in_xr_device
        if data_unit eq 1 then begin
          xrange = xr_device
        endif else begin
          temp_data_coord = convert_coord([xr_device[0], xr_device[1]], [0, 1], /device, /to_data)
          xrange = reform(temp_data_coord[0, *])
        endelse
      endelse

      if not keyword_set(in_yr_device) then begin
        if ylog eq 1 then begin
        ; y-axis is in log-scale
          yrange = 10.0^!y.crange
        endif else begin
          yrange = !y.crange
        endelse
      endif else begin
      ; convert the in_yr_device into data units
        yr_device = in_yr_device
        if data_unit eq 1 then begin
          yrange = yr_device
        endif else begin
          temp_data_coord = convert_coord([0, 1], [yr_device[0], yr_device[1]], /device, /to_data)
          yrange = reform(temp_data_coord[1, *])
        endelse
      endelse
    endelse
  endif else if plot_dim eq 3 then begin
  ; for 3D plot
    if ( (not keyword_set(in_xr_device)) and (not keyword_set(in_yr_device)) and (not keyword_set(in_zr_device)) ) then begin
    ; reset the plot
    ; I need to find the max and min of x, y and z values
      for i = 0, plotdata.curr_num_plots - 1 do begin
        x = *plotdata.ptr_x[i]
        y = *plotdata.ptr_y[i]
        z = *plotdata.ptr_z[i]
        if zlog eq 1 then begin
        ; This plot type has z-axis as a log-scale
        ; I need to be careful of taking log base 10, since the argument must be greater than 0.
          inx_zero = where(z le 0.0, count_zero)
          if count_zero gt 0 then $
            z[inx_zero] = !values.f_nan
          z = temporary(alog10(z))
        endif
        if i eq 0 then begin
          xmin = min(x, /nan, max = xmax)
          ymin = min(y, /nan, max = ymax)
          zmin = min(z, /nan, max = zmax)
        endif
        temp_xmin = min(x, /nan, max = temp_xmax)
        temp_ymin = min(y, /nan, max = temp_ymax)
        temp_zmin = min(z, /nan, max = temp_zmax)
        xmin = xmin < temp_xmin
        xmax = xmax > temp_xmax
        ymin = ymin < temp_ymin
        ymax = ymax > temp_ymax
        zmin = zmin < temp_zmin
        zmax = zmax > temp_zmax
      endfor
      xrange = [xmin, xmax]
      yrange = [ymin, ymax]
      zrange = [zmin, zmax]
    endif else begin
      if not keyword_set(in_xr_device) then begin
        xrange = !x.crange
      endif else begin
      ; convert the in_xr_device into data units
        xr_device = in_xr_device
        if data_unit eq 1 then begin
          xrange = xr_device
        endif else begin
          temp_data_coord = convert_coord([xr_device[0], xr_device[1]], [0, 1], /device, /to_data)
          xrange = reform(temp_data_coord[0, *])
        endelse
      endelse

      if not keyword_set(in_yr_device) then begin
        yrange = !y.crange
      endif else begin
      ; convert the in_yr_device into data units
        yr_device = in_yr_device
        if data_unit eq 1 then begin
          yrange = yr_device
        endif else begin
          temp_data_coord = convert_coord([0, 1], [yr_device[0], yr_device[1]], /device, /to_data)
          yrange = reform(temp_data_coord[1, *])
        endelse
      endelse

      if not keyword_set(in_zr_device) then begin
        zrange = !z.crange
      endif else begin
        zr_device = in_zr_device
        if data_unit eq 1 then begin
          zrange = zr_device
        endif else begin
        ; To zoom in z-direction properly, I need to know
        ;  1. current zrange --> this is stored in !z.crange
        ;  2. y-direction of the scale bar position.
        ;
        ; convert the zr_device into normalized unit.
          temp_yr_norm = convert_coord([0, 1], [zr_device[0], zr_device[1]], /device, /to_norm)
          yr_norm = reform(temp_yr_norm[1, *]) 
        ; get current zrange
          curr_zrange = !z.crange
        ; get the scale bar positions
          norm_start = scale_pos[1]
          norm_end = scale_pos[3]
        ; Now, curr_zrange[0] : norm_start
        ;      curr_zrange[1] : norm_end
        ; This information can be used to convert normalized yr_norm to data range.
          slope = (curr_zrange[1] - curr_zrange[0])/(norm_end - norm_start)
          inter = (curr_zrange[0] * norm_end - curr_zrange[1] * norm_start)/(norm_end - norm_start)
        ; finally, zrange is
          zrange = slope * yr_norm + inter
        endelse
      endelse

    endelse
  endif else if plot_dim eq 4 then begin
    if ( (not keyword_set(in_xr_device)) and (not keyword_set(in_yr_device)) and (not keyword_set(in_zr_device)) ) then begin
    ; reset the plot
    ; I need to find the max and min of x, y and z values
      for i = 0, plotdata.curr_num_plots - 1 do begin
        x = *plotdata.ptr_x[i]
        y = *plotdata.ptr_y[i]
        z = *plotdata.ptr_z[i]
        if i eq 0 then begin
          xmin = min(x, /nan, max = xmax)
          ymin = min(y, /nan, max = ymax)
          zmin = min(z, /nan, max = zmax)
        endif
        temp_xmin = min(x, /nan, max = temp_xmax)
        temp_ymin = min(y, /nan, max = temp_ymax)
        temp_zmin = min(z, /nan, max = temp_zmax)
        xmin = xmin < temp_xmin
        xmax = xmax > temp_xmax
        ymin = ymin < temp_ymin
        ymax = ymax > temp_ymax
        zmin = zmin < temp_zmin
        zmax = zmax > temp_zmax
      endfor
      xrange = [xmin, xmax]
      yrange = [ymin, ymax]
      zrange = [zmin, zmax]
      if plotdata.type eq 1001 then begin
      ;This is a BES movie
        xrange = [xrange[0]-0.5, xrange[1]+0.5]
        yrange = [yrange[0]-0.5, yrange[1]+0.5]
      endif
    endif else begin
      if not keyword_set(in_xr_device) then begin
        xrange = !x.crange
      endif else begin
      ; convert the in_xr_device into data units
        xr_device = in_xr_device
        if data_unit eq 1 then begin
          xrange = xr_device
        endif else begin
          temp_data_coord = convert_coord([xr_device[0], xr_device[1]], [0, 1], /device, /to_data)
          xrange = reform(temp_data_coord[0, *])
        endelse
      endelse

      if not keyword_set(in_yr_device) then begin
        yrange = !y.crange
      endif else begin
      ; convert the in_yr_device into data units
        yr_device = in_yr_device
        if data_unit eq 1 then begin
          yrange = yr_device
        endif else begin
          temp_data_coord = convert_coord([0, 1], [yr_device[0], yr_device[1]], /device, /to_data)
          yrange = reform(temp_data_coord[1, *])
        endelse
      endelse

      if not keyword_set(in_zr_device) then begin
        zrange = !z.crange
      endif else begin
        zr_device = in_zr_device
        if data_unit eq 1 then begin
          zrange = zr_device
        endif else begin
        ; To zoom in z-direction properly, I need to know
        ;  1. current zrange --> this is stored in !z.crange
        ;  2. y-direction of the scale bar position.
        ;     For plotdata.type = 1001 --> y-direction scale bar position is [0.1, 0.464] in normalized unit.
        ; convert the zr_device into normalized unit.
          temp_yr_norm = convert_coord([0, 1], [zr_device[0], zr_device[1]], /device, /to_norm)
          yr_norm = reform(temp_yr_norm[1, *]) 
        ; get current zrange
          curr_zrange = !z.crange
        ; get the scale bar positions
          norm_start = scale_pos[1]
          norm_end = scale_pos[3]
        ; Now, curr_zrange[0] : norm_start
        ;      curr_zrange[1] : norm_end
        ; This information can be used to convert normalized yr_norm to data range.
          slope = (curr_zrange[1] - curr_zrange[0])/(norm_end - norm_start)
          inter = (curr_zrange[0] * norm_end - curr_zrange[1] * norm_start)/(norm_end - norm_start)
        ; finally, zrange is
          zrange = slope * yr_norm + inter
        endelse
      endelse
    endelse
  endif


  for i = 0, plotdata.curr_num_plots - 1 do begin
    x = *plotdata.ptr_x[i]
    y = *plotdata.ptr_y[i]
    if plot_dim ge 3 then z = *plotdata.ptr_z[i]
    if plot_dim ge 4 then t = *plotdata.ptr_t[i]
    if i eq 0 then begin
      if plot_dim eq 2 then begin
      ;2d plot
        plot, x, y, xrange = xrange, yrange = yrange, xtitle = xtitle, ytitle = ytitle, /nodata, color = truecolor('black'), $
              xstyle = 1, ystyle = 1, ylog = ylog
      endif else if plot_dim eq 3 then begin
      ; 3d plot
        if zlog eq 1 then begin
        ; I need to be careful of taking log base 10, since the argument must be greater than 0.
          inx_zero = where(z le 0.0, count_zero)
          if count_zero gt 0 then $
            z[inx_zero] = !values.f_nan
          z = temporary(alog10(z))
        endif
        bes_analyser_cp_shade_mod, z, x, y, $
                                   title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                   /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                   xrange = xrange, yrange = yrange, zrange = zrange, $
                                   pos = shade_pos, scalepos = scale_pos
      endif else if plot_dim eq 4 then begin
      ; 4d plot
        inx_curr_time = plotdata.inx_curr_time
        if plotdata.type eq 1001 then begin
        ; This is a BES movie
          bes_ani_data = info.bes_animation_window_data
          if bes_ani_data.show_BES_pos eq 1 then begin
              centre_pos = info.main_window_data.BES_data.viewRadius
              bes_pos = fltarr(32, 2)
              inx = findgen(32)
              bes_pos[*, 0] = ((inx mod 8)-3.5) * (-2.0) + centre_pos * 100.0	;Major Radial position in [cm]
              bes_pos[*, 1] = (fix(inx/8) - 1.5) * 2.0				;Polodial position in [c]
          endif
          title = pre_title + 'Time = '
          title = title + string(t[inx_curr_time]*1e3, format='(f0.4)') + ' [msec]'
          bes_analyser_cp_shade_mod, z[*, *, inx_curr_time], x, y, $
                                     title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                     /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                     xrange = xrange, yrange = yrange, zrange = zrange, $
                                     pos = shade_pos, scalepos = scale_pos
           if bes_ani_data.show_BES_pos eq 1 then $
             oplot, bes_pos[*, 0], bes_pos[*, 1], psym = 2, col = truecolor(bes_ani_data.col_BES_pos_str)
        endif else if plotdata.type eq 1010 then begin	; for flux surface
          title = pre_title + 'Time = '
          title = title + string(t[inx_curr_time]*1e3, format='(f0.4)') + ' [msec]'
        ; draw flux contour
          label_step_size = info.show_flux_surface_window_data.contour_line_step
          show_label = info.show_flux_surface_window_data.show_label
          last_line = 1.5
          num_lines = fix(last_line/label_step_size)
          levels = findgen(num_lines)*label_step_size
          inx_lcfs_level = where(levels ge 0.999, count)
          if count gt 0 then inx_lcfs_level = inx_lcfs_level[0] else inx_lcfs_level = -1
          c_labels = intarr(num_lines)
          c_labels[*] = show_label
          c_colors = lonarr(num_lines)
          c_colors[*] = truecolor('black')
          if inx_lcfs_level ne -1 then c_colors[inx_lcfs_level] = truecolor('blue')

          contour, reform(z[*, *, inx_curr_time]), x, y, $
                   levels = levels, c_labels = c_labels, c_colors = c_colors, $
                   title = title, xtitle = xtitle, ytitle = ytitle, $
                   xrange = xrange, yrange = yrange, zrange = zrange, /iso

          bes_cent_pos = info.main_window_data.BES_data.viewRadius
          zpos = [-0.03, -0.01, 0.01, 0.03]
          rpos = findgen(8)*0.02 - 0.07 + bes_cent_pos
          psymcircle, size = 0.5, /fill
          for i = 0, 7 do begin
            for j = 0, 3 do begin
              oplot, [rpos[i], rpos[i]], [zpos[j], zpos[j]], psym = 8, col = truecolor('red')
            endfor
          endfor
        endif else begin
          title = pre_title + 'Time = '
          title = title + string(t[inx_curr_time]*1e3, format='(f0.4)') + ' [msec]'
          bes_analyser_cp_shade_mod, z[*, *, inx_curr_time], x, y, $
                                     title = title, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, $
                                     /showscale, ctable = plotdata.inx_ctable, invert = plotdata.inv_ctable, $
                                     xrange = xrange, yrange = yrange, zrange = zrange, $
                                     pos = shade_pos, scalepos = scale_pos
        endelse
      ;save the title for 4D
        plotdata.title = title
        widget_control, info.id.main_window.result_draw, set_uvalue = plotdata
      endif
    endif

    if plot_dim eq 2 then $
      oplot, x, y, col = truecolor(plotdata.line_color[i]), linestyle = plotdata.line_style[i]

  endfor

; save the system variable
  save_sys_var, info, wid

; restore the system variable
  restore_sys_var, info.sys_var.org

; draw the timeilne indicator
  draw_timeline, info, /by_result_plot

end
