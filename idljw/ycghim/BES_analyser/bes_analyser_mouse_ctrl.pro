;===================================================================================
;
; This file contains following functions and procedures to control the events
;   generated by mouse motions.
;
;  1) bes_analyser_button_down
;  2) bes_analyser_button_up
;  3) bes_analyser_button_move
;  4) bes_analyser_wheel_motion
;
;  5) bes_analyser_mouse_event
;     --> main function to control the events generated by mouse motions
;
;===================================================================================


;===================================================================================
; This procedure is called when the mouse is pressed.
;===================================================================================
; The function parameters:
;   1) 'event' is the structure that contains the information about the mouse motions.
;   2) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro bes_analyser_button_down, event, info
;event.press = 1 --> left button
;            = 2 --> middle button
;            = 4 --> right button

; if left or middle button is in 'holding' status, do not take button press events.
  if ( (info.mouse.left_middle eq 1) or (info.mouse.left_middle eq 2) ) then $
    return

; get the wid
  widget_control, event.id, get_value = wid

  if event.press eq 1 then begin		;left button is pressed.
  ;Prepare either zoom or time-selection.
  ;Both cases require 'highlight'

  ;save the mouse position.
    info.mouse.x0 = event.x
    info.mouse.x1 = event.x
    info.mouse.y0 = event.y
    info.mouse.y1 = event.y
    info.mouse.left_middle = 1		;I need to know whether left button or middle is pressed for mouse motion.
                                        ;If this is 1, then left button. If this is 2, then middle button 

  ; activate the mouse motion events on the plot
    widget_control, event.id, draw_motion_events = 1

  ; save the graphics mode to draw selection lines
    device, get_graphics = oldg, set_graphics = 6
    info.mouse.graphic_mode = oldg

  ; save the info
    widget_control, info.id.main_window.main_base, set_uvalue = info
  endif else if event.press eq 2 then begin	;middle button is pressed.
  ; prepare for panning
  ; save the mouse position.
    info.mouse.x0 = event.x
    info.mouse.x1 = event.x
    info.mouse.y0 = event.y
    info.mouse.y1 = event.y
    info.mouse.left_middle = 2		;I need to know whether left button or middle is pressed for mouse motion.
                                        ;If this is 1, then left button. If this is 2, then middle button

  ; activate the mouse motion events on the plot
    widget_control, event.id, draw_motion_events = 1

  ; save the idinfo
    widget_control, info.id.main_window.main_base, set_uvalue = info
  endif else if event.press eq 4 then begin	;right button is pressed.
  ; do nothing
  ; but, do something when right button is released.

  endif else begin
  ; do nothing

  endelse

end


;===================================================================================
; This procedure is called when the mouse is released.
;===================================================================================
; The function parameters:
;   1) 'event' is the structure that contains the information about the mouse motions.
;   2) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro bes_analyser_button_up, event, info
;event.release = 1 --> left button
;              = 2 --> middle button
;              = 4 --> right button

; set minimum distance of mouse motion for real 'action' to happen.
  min_mouse_motion = 1	;in device unit

; get the wid
  widget_control, event.id, get_value = wid

  if ( (event.release eq 1) and (info.mouse.left_middle eq 1) ) then begin		;left button is released.
  ; perform either zoom or time-select
  ; deactivate the mouse motion
    widget_control, event.id, draw_motion_events = 0
  ; remove the highlight for zoom.
  ; For time-selection, do not remove the highlight unless the maximum number of selected time regions is reached.
    if ( (event.id eq info.id.main_window.result_draw) or $
         ( (event.id eq info.id.main_window.time_sel_draw) and (widget_info(info.id.main_window.time_sel_zoom_button, /button_set) eq 1) ) ) then $ 
      plot_highlight, info, wid

  ; get the current selected range in device coordinate
    xr_device = [info.mouse.x0 < info.mouse.x1, info.mouse.x0 > info.mouse.x1]
    yr_device = [info.mouse.y0 < info.mouse.y1, info.mouse.y0 > info.mouse.y1]
    xy_direction = info.mouse.xy_direction
  ; reset the mouse info
    info.mouse.left_middle = 0
    info.mouse.xy_direction = 0
  ; restore the graphic mode
    device, set_graphics = info.mouse.graphic_mode
  ; save the info
    widget_control, info.id.main_window.main_base, set_uvalue = info

    if event.id eq info.id.main_window.result_draw then begin
    ; perform zoom
      if xy_direction eq 1 then begin	;x-direction zoom
        if abs(xr_device[1] - xr_device[0]) ge min_mouse_motion then $
          replot_result_window, info, xr_device = xr_device
      endif else if xy_direction eq 2 then begin	;y-direction zoom
        if abs(yr_device[1] - yr_device[0]) ge min_mouse_motion then $
          replot_result_window, info, yr_device = yr_device
      endif else if xy_direction eq 3 then begin			;z-direction zoom
        if abs(yr_device[1] - yr_device[0]) ge min_mouse_motion then $
          replot_result_window, info, zr_device = yr_device
      endif
    endif
    if event.id eq info.id.main_window.time_sel_draw then begin
      if widget_info(info.id.main_window.time_sel_zoom_button, /button_set) eq 1 then begin
      ; perform zoom
        if xy_direction eq 1 then begin	;x-direction zoom
          if abs(xr_device[1] - xr_device[0]) ge min_mouse_motion then $
            replot_time_sel_window, info, xr_device = xr_device 
        endif else begin 				;y-direction zoom
          if abs(yr_device[1] - yr_device[0]) ge min_mouse_motion then $
            replot_time_sel_window, info, yr_device = yr_device
        endelse
      endif else begin
      ; perform time selection
        if abs(xr_device[1]-xr_device[0]) lt min_mouse_motion then begin
        ; remove the last highlight
          device, get_graphics = oldg, set_graphics = 6
          plot_highlight, info, wid, /for_time_sel, xy_direction = xy_direction, mouse_position = xr_device
          device, set_graphics = oldg
          return
        endif

        if (info.time_sel_struct.curr_num_time_regions ge info.time_sel_struct.MAX_NUM_TIME_REGIONS) then begin
        ; display an error message
          errmsg = 'Maximum allowed number of selected time regions are ' + $
                   string(info.time_sel_struct.MAX_NUM_TIME_REGIONS, format='(i0)') + '.' + string(10b) + $
                   'You have reached the maximum number of regions.' + string(10b) + $
                   'The last selected regions will be added.'
          create_err_msg_window, errmsg, info.id.main_window.main_base
        ; remove the last highlight
          device, get_graphics = oldg, set_graphics = 6
          plot_highlight, info, wid, /for_time_sel, xy_direction = xy_direction, mouse_position = xr_device
          device, set_graphics = oldg
          return
        endif

      ; set the system variable for time_sel_window plot
        restore_sys_var, info.sys_var.time_sel_plot

      ; convert the selected region from device unit to data unit
        temp_data_coord = convert_coord([xr_device[0], xr_device[1]], [0, 1], /device, /to_data)
        timerange = reform(temp_data_coord[0, *])

      ; save the time range
        info.time_sel_struct.time_regions[info.time_sel_struct.curr_num_time_regions, *] = timerange
        info.time_sel_struct.curr_num_time_regions += 1

      ; save the info
        widget_control, info.id.main_window.main_base, set_uvalue = info

      ; restore the system variable
        restore_sys_var, info.sys_var.org
      endelse
    endif

  endif else if ( (event.release eq 2) and (info.mouse.left_middle eq 2) ) then begin	;middle button is released.
  ; stop panning
  ; deactivate the mouse motion
    widget_control, event.id, draw_motion_events = 0
  ; reset the mouse info
    info.mouse.left_middle = 0
  ; save the info
    widget_control, info.id.main_window.main_base, set_uvalue = info

  endif else if ( (event.release eq 4) and (info.mouse.left_middle eq 0) ) then begin	;right button is released.
  ; reset the plot or deselect the time-region
    if event.id eq info.id.main_window.result_draw then begin
    ; reset the plot
      replot_result_window, info
    endif
    if event.id eq info.id.main_window.time_sel_draw then begin
      if widget_info(info.id.main_window.time_sel_zoom_button, /button_set) eq 1 then begin
      ; reset the plot
        replot_time_sel_window, info
      endif else begin
      ; remove the last selected time region.
        if info.time_sel_struct.curr_num_time_regions gt 0 then begin
        ; convert the last selected time range from data unit to device unit
          timerange = reform(info.time_sel_struct.time_regions[info.time_sel_struct.curr_num_time_regions-1, *])

        ; remove the highlight
          device, get_graphics = oldg, set_graphics = 6
          plot_highlight, info, wid, /for_time_sel, xy_direction = 1, mouse_position = timerange, /data

          device, set_graphics = oldg

        ; remove the time range
          info.time_sel_struct.time_regions[info.time_sel_struct.curr_num_time_regions-1, *] = 0.0
          info.time_sel_struct.curr_num_time_regions -= 1

        ; save the info
          widget_control, info.id.main_window.main_base, set_uvalue = info
        endif
      endelse
    endif

  endif else begin
  ; do nothing

  endelse

end


;===================================================================================
; This procedure is called when the mouse is moved.
;===================================================================================
; The function parameters:
;   1) 'event' is the structure that contains the information about the mouse motions.
;   2) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro bes_analyser_button_move, event, info
;event.press = 1 --> left button
;            = 2 --> middle button
;            = 4 --> right button

; get the wid
  widget_control, event.id, get_value = wid

  if info.mouse.left_middle eq 1 then begin		;moved while left button is pressed.
  ; Highlighting the selected region: either zoom or Time-selection
  ; delete the current highlight
    if event.id eq info.id.main_window.result_draw then $
      plot_highlight, info, wid $
    else begin
      if widget_info(info.id.main_window.time_sel_zoom_button, /button_set) eq 1 then $
        plot_highlight, info, wid $
      else $
        plot_highlight, info, wid, /for_time_sel
    endelse

  ; save the current mouse position
    info.mouse.x1 = event.x
    info.mouse.y1 = event.y
    x_motion = abs(info.mouse.x1 - info.mouse.x0)
    y_motion = abs(info.mouse.y1 - info.mouse.y0)
    if event.id eq info.id.main_window.result_draw then begin
    ;get the plotdata
      widget_control, info.id.main_window.result_draw, get_uvalue = plotdata
      if plotdata.type gt 0 then $
        plot_dim = fix(alog10(plotdata.type)) + 1 $
      else $
        plot_dim = 2
      if plot_dim eq 2 then begin
        if x_motion ge y_motion then $
          info.mouse.xy_direction = 1 $	;x-direction zoom
        else $
          info.mouse.xy_direction = 2 	;y-direction zoom
      endif else if plot_dim ge 3 then begin
      ; Note: the scale bar position in x-direction is [0.9, 0.93] in normalized unit
        temp_scalebar_xr = convert_coord([0.88, 0.93], [0, 1], /norm, /to_device)
        scalebar_xr = reform(temp_scalebar_xr[0, *])
        if info.mouse.x0 ge scalebar_xr[0] then begin
          info.mouse.xy_direction = 3	;z-direction zoom (i.e. scale bar)
        endif else begin
          if x_motion ge y_motion then $
            info.mouse.xy_direction = 1 $	;x-direction zoom
          else $
            info.mouse.xy_direction = 2 	;y-direction zoom
        endelse
      endif
    endif
    if event.id eq info.id.main_window.time_sel_draw then begin
      if widget_info(info.id.main_window.time_sel_zoom_button, /button_set) eq 1 then begin
        if x_motion ge y_motion then $
          info.mouse.xy_direction = 1 $	;x-direction zoom
        else $
          info.mouse.xy_direction = 2 	;y-direction zoom
      endif else $
        info.mouse.xy_direction = 1	;time-selection. The direction is always x-direction.
    endif

    widget_control, info.id.main_window.main_base, set_uvalue = info
  ; draw the highlight again 
    if event.id eq info.id.main_window.result_draw then $
      plot_highlight, info, wid $
    else begin
      if widget_info(info.id.main_window.time_sel_zoom_button, /button_set) eq 1 then $
        plot_highlight, info, wid $
      else $
        plot_highlight, info, wid, /for_time_sel
    endelse
  endif else if info.mouse.left_middle eq 2 then begin	;moved while middle button is pressed.
  ; panning
  ; save the current mouse positino
    info.mouse.x1 = event.x
    info.mouse.y1 = event.y
    x_motion_device = info.mouse.x0 - info.mouse.x1	;in device unit
    y_motion_device = info.mouse.y0 - info.mouse.y1	;in device unit
    info.mouse.x0 = event.x
    info.mouse.y0 = event.y
    widget_control, info.id.main_window.main_base, set_uvalue = info

  ; restore the system variable
    if event.id eq info.id.main_window.result_draw then $
      restore_sys_var, info.sys_var.result_plot $
    else $
      restore_sys_var, info.sys_var.time_sel_plot

  ; !p.clip[0] in device unit for xrange[0]
  ; !p.clip[1] in device unit for yrange[0]
  ; !p.clip[2] in device unit for xrange[1] 
  ; !p.clip[3] in device unit for yrange[1]
    new_xr_device = [!p.clip[0], !p.clip[2]] + x_motion_device
    new_yr_device = [!p.clip[1], !p.clip[3]] + y_motion_device

  ; restore the original system variable
    restore_sys_var, info.sys_var.org

  ; replot the window
    if event.id eq info.id.main_window.result_draw then begin
      replot_result_window, info, xr_device = new_xr_device, yr_device = new_yr_device
    endif else begin
      replot_time_sel_window, info, xr_device = new_xr_device, yr_device = new_yr_device
    endelse

  endif else begin
  ;do nothing

  endelse


end


;===================================================================================
; This procedure is called when the mouse wheel is moved.
;===================================================================================
; The function parameters:
;   1) 'event' is the structure that contains the information about the mouse motions.
;   2) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro bes_analyser_wheel_motion, event, info
;event.clicks = 1  --> wheel moved up
;             = -1 --> wheel moved down

  if event.id ne info.id.main_window.result_draw then $
    return 

; get plotdata
  widget_control, info.id.main_window.result_draw, get_uvalue = plotdata

; check if plotdata type is 4D
  if plotdata.type lt 1000 then $
    return

; get the inx_curr_time
  inx_curr_time = long(plotdata.inx_curr_time)

; get the number of time points
  time = *plotdata.ptr_t[0]
  nt = long(n_elements(time))

; calculate the inx_new_time
  inx_new_time = long(inx_curr_time) + long(event.clicks) 

; check the inx_new_time is out of the range
  if inx_new_time lt 0 then $
    inx_new_time = 0 $
  else if inx_new_time ge nt then $
    inx_new_time = nt - 1

; redraw the plot if inx_new_time is different from inx_curr_time
  if inx_new_time ne inx_curr_time then begin
    plotdata.inx_curr_time = inx_new_time
  ; save the plotdate
    widget_control, info.id.main_window.result_draw, set_uvalue= plotdata

  ; get the currnet ranges of the plot
  ; set the system variable for result plot
    restore_sys_var, info.sys_var.result_plot
    xrange = !x.crange
    yrange = !y.crange
    zrange = !z.crange
  ; restore the system variable
    restore_sys_var, info.sys_var.org

  ; draw the plot
    replot_result_window, info, xr_device = xrange, yr_device = yrange, zr_device = zrange, /data

  endif

end


;===================================================================================
; This procedure controls the events generated by mouse motion
;===================================================================================
; The function parameters:
;   1) 'event' is the structure that contains the information about the mouse motions.
;   2) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro bes_analyser_mouse_event, event, info
; event.type = 0 --> button down
;            = 1 --> button up
;            = 2 --> button move
;            = 7 --> wheel.

  if event.type eq 0 then $	;button down
    bes_analyser_button_down, event, info

  if event.type eq 1 then $	;button up
    bes_analyser_button_up, event, info

  if event.type eq 2 then $	;mouse move
    bes_analyser_button_move, event, info

  if event.type eq 7 then $	;wheel
    bes_analyser_wheel_motion, event, info

end