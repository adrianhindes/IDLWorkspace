
;=================================================================
;IDL Procedure for plotting: ycplot.pro
;
;  Developer: Young-chul Ghim(Kim)
;  Starting Date of writing the program: 14-01-2011
;
; <version history>
; - v.1.0:
;      The first version of the program.
;      Completed on the 19-01-2011.
; 
;=================================================================
;
;input parameters:
;
;  xdata: [optional].  Type: 1-D array of numerics
;         Values of x for a plot of y vs. x
;         If this is not specified, then x is generated as an array of index
;  ydata: [required.  or can be optional if saved_file is provided].  Type: 1-D array of numerics
;         Values of y for a plot of y vs. x
;
;
;input keywords:
;  
;  error: [optional].  Type: 1-D or 2-D array of numerics
;         Error bar size for y values.
;         If this is 1-D array, then the hi-error and lo-error are assumed to be equal.
;         If this is 2-D array, then error[0, *] is used for hi-error, and
;                                    error[1, *] is used for lo-error.
;
;  oplot_id: [optional].  Type: scalar
;            If this value is set, then the data are plotted over the existing plot.
;            The value of oplot_id tells the data on which window will be plotted.
;            Note that each time ycplot is called, on the top of the window the unique ID is shown for the ycplot window.
;                      Use this ID for the value of oplot_id.
;            Note that the maximum possible oplots are set by the variable called MAX_NUM_PLOT
;
;  saved_file: [optional]. Type: string
;              If this value is provided, then the program reads the saved data.
;              Note: all the other inputs values are ignored if this value is provided, except xsize and ysize keywords.
;
;  title: [optional]. Type: string
;         title of the plot.  
;         NOte; if this is provided with oplot_id or saved_file, then this is ignored.
;
;  xtitle: [optional]. Type: string
;          xtitle of the plot
;         NOte; if this is provided with oplot_id or saved_file, then this is ignored.
;
;  ytitle: [optional]. Type: string
;          ytitle of the plot
;         NOte; if this is provided with oplot_id or saved_file, then this is ignored.
;
;  xlog: [optional].  Type: scalar (0 or 1)
;        If this is set, then x-axis is in logarithmic.
;        If this is not set, then x-axis is in linear.
;
;  ylog: [optional].  Type: scalar (0 or 1)
;        If this is set, then y-axis is in logarithmic.
;        If this is not set, then y-axis is in linear.
;
;  xsize: [optional].  Type: scalar
;         xsize sets the size of plot in horizontal direction
;         if xsize is less than 640, then xsize is set to 640 
;
;  ysize: [optional].  Type: scalar
;         ysize sets the size of plot in vertical direction
;         if ysize is less than 480, then ysize is set to 480
;
;  legend_item; [optional].  Type: string
;               This keyword sets a string for the legend for the given data
;
;  description: [optional]. Type: string
;               Enter a description of the data
;               This variable is shown to a user and can be modified by a user while running.
;
;  note: [optional].  Type: string
;        This is a note for the data.
;        Unlike description, this variable is not shown to a user and cannot be modified by a user.
;        This vairable can be used as a 'book-keeping of the data' if necessary.
;
;
;
;output keyword:
;  
;  out_base_id: Type: scalar (variable)
;               Set a variable to this keyword so that the variable contains the base id can be used for oplot from other programs
;
;=================================================================





;=================================================================
; sub-routnies for ycplot
;=================================================================

pro draw_highlight, idinfo

; get the window id
  widget_control, idinfo.plot_draw, get_value = win
  wset, win

; get the plotinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; save the system variable
  psys = !p
  xsys = !x
  ysys = !y
  zsys = !z

; restore the system variable
  !p = plotinfo.sys_var.p
  !x = plotinfo.sys_var.x
  !y = plotinfo.sys_var.y
  !z = plotinfo.sys_var.z

  xr_device = [!p.clip[0], !p.clip[2]]
  yr_device = [!p.clip[1], !p.clip[3]]

  if idinfo.mouse.xy_direction eq 1 then begin			;x-direciton highlight (if xy_direction=1, then x-direction)
    xr = [idinfo.mouse.x0, idinfo.mouse.x1]
    yr = yr_device
    polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor('blue')
  endif else if idinfo.mouse.xy_direction eq 2 then begin	;y-direction highlight (if xy_direction=2, then y-direction)
    xr = xr_device
    yr = [idinfo.mouse.y0, idinfo.mouse.y1]
    polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor('blue')
  endif

; restore the system variable
  !p = psys
  !x = xsys
  !y = ysys
  !z = zsys
end


pro plot_one, plotinfo, plot_id, inx_data_num
; at any given 'plot screen', maximum data points that will be displayed is set by MAX_DATA_POINT.
; nsum keyword for plot procedure will be calculated in accordance with the MAX_DATA_POINT and the available data points.
  MAX_DATA_POINT = 10000	;this is not really used. see where nsum is defined.

;get the window id
  widget_control, plot_id, get_value = win
  wset, win

;retrieve the necessary data from plotinfo
  plot_setting = plotinfo.plot_setting
  line_setting = plotinfo.line_setting
  sys_var = plotinfo.sys_var

;save the system variable
  psys = !p
  xsys = !x
  ysys = !y
  zsys = !z

; restore the system variable
  !p = sys_var.p
  !x = sys_var.x
  !y = sys_var.y
  !z = sys_var.z
  !p.charsize = plot_setting.charsize
  !p.charthick = plot_setting.charthick

  psymcircle, /fill
; plot data
  data = *plotinfo.pdata[inx_data_num]
  inx_x = where( ( (data.x ge plot_setting.xrange[0]) and (data.x le plot_setting.xrange[1]) ), count )
 ; if count gt MAX_DATA_POINT then $
 ;   nsum = fix(count / MAX_DATA_POINT) $
 ; else $
    nsum = 0

  if line_setting.symbol[inx_data_num] gt 0 then $
    oplot, data.x, data.y, psym = line_setting.symbol[inx_data_num], symsize = line_setting.sym_size[inx_data_num], $
           col = line_setting.color[inx_data_num], thick = line_setting.thick[inx_data_num], nsum = nsum
  if line_setting.style[inx_data_num] ge 0 then $
    oplot, data.x, data.y, thick = line_setting.thick[inx_data_num], linestyle = line_setting.style[inx_data_num], $
           col = line_setting.color[inx_data_num], nsum = nsum
  if( plot_setting.show_errbar eq 1 ) then begin
    if data.errbar_exist then begin  
      if (line_setting.symbol[inx_data_num] gt 0) or (line_setting.style[inx_data_num] ge 0) then begin
        oploterror_ycplot, data.x, data.y, data.hi_err, /hibar, errcol = line_setting.color[inx_data_num], col = line_setting.color[inx_data_num], nsum = nsum, $ 
                           psym = line_setting.symbol[inx_data_num], symsize = line_setting.sym_size[inx_data_num], $
                           linestyle=line_setting.style[inx_data_num], thick = line_setting.thick[inx_data_num]
        oploterror_ycplot, data.x, data.y, data.lo_err, /lobar, errcol = line_setting.color[inx_data_num], col = line_setting.color[inx_data_num], nsum = nsum, $
                           psym = line_setting.symbol[inx_data_num], symsize = line_setting.sym_size[inx_data_num], $
                           linestyle=line_setting.style[inx_data_num], thick = line_setting.thick[inx_data_num]
      endif
    endif
  endif

; show legend if it is set
  if (plotinfo.legend_setting.show_legend eq 1) then begin
    legend_item = plotinfo.legend_setting.item[0:plotinfo.num_plot-1]
    legend_linestyle = line_setting.style[0:plotinfo.num_plot-1]
    legend_symbol = line_setting.symbol[0:plotinfo.num_plot-1]
    legend_linethick = line_setting.thick[0:plotinfo.num_plot-1]
    legend_symsize = line_setting.sym_size[0:plotinfo.num_plot-1]
    legend_color = line_setting.color[0:plotinfo.num_plot-1]
    ;if linestyle < 0, then only text (i.e neither line nor symbol)
    ;if linestyle > 0 and psym > 0, then text and symbol (no line)
    ;if linestyle > 0 and psym < 0, then text, symbol and line
    for i = 0, plotinfo.num_plot - 1 do begin
      if legend_linestyle[i] lt 0 then begin	;no line
        if legend_symbol[i] gt 0 then $		;with symbol
          legend_linestyle[i] = abs(legend_linestyle[i])
      endif else begin
        if legend_symbol[i] gt 0 then $
          legend_symbol[i] = -legend_symbol[i]
      endelse
    endfor
    legendd_ycplot, legend_item, linestyle = legend_linestyle, thick = legend_linethick, $
                          psym = legend_symbol, symsize = legend_symsize, col = legend_color, $
                          left = plotinfo.legend_setting.position.left, right = plotinfo.legend_setting.position.right, $
                          top = plotinfo.legend_setting.position.top, bottom = plotinfo.legend_setting.position.bottom
  endif

; show xyouts if it is set
  if plotinfo.xyouts_setting.show_xyouts eq 1 then begin
    xyout_index = where(plotinfo.xyouts_setting.text ne '', num_xyout)
    for i = 0, num_xyout-1 do begin
      xyouts, plotinfo.xyouts_setting.position.x[xyout_index[i]], plotinfo.xyouts_setting.position.y[xyout_index[i]], $
              plotinfo.xyouts_setting.text[xyout_index[i]], $
              charsize = plotinfo.xyouts_setting.charsize[xyout_index[i]], $
              charthick = plotinfo.xyouts_setting.charthick[xyout_index[i]], $
              color = plotinfo.xyouts_setting.color[xyout_index[i]], $
              orientation = plotinfo.xyouts_setting.orientation[xyout_index[i]], $
              /norm
    endfor
  endif


;save the system variables
  plotinfo.sys_var.p = !p
  plotinfo.sys_var.x = !x
  plotinfo.sys_var.y = !y
  plotinfo.sys_var.z = !z
  widget_control, plot_id, set_uvalue = plotinfo


  !p = psys
  !x = xsys
  !y = ysys
  !z = zsys

end


pro replot_all, plotinfo, plot_id, first = first, psplot = psplot
; at any given 'plot screen', maximum data points that will be displayed is set by MAX_DATA_POINT.
; nsum keyword for plot procedure will be calculated in accordance with the MAX_DATA_POINT and the available data points.
  MAX_DATA_POINT = 10000	;this is not really used. see where nsum is defined.

;get the window id
  if not keyword_set(psplot) then begin
    widget_control, plot_id, get_value = win
    wset, win
  endif

;retrieve the necessary data from plotinfo
  plot_setting = plotinfo.plot_setting
  line_setting = plotinfo.line_setting
  sys_var = plotinfo.sys_var

;save the system variable
; this is modified for psplot
  if not keyword_set(psplot) then begin
    psys = !p
    xsys = !x
    ysys = !y
    zsys = !z

    if keyword_set(first) then begin
      !p.background = truecolor('white')
      !p.color = truecolor('black')
      !p.charsize = plot_setting.charsize
      !p.charthick = plot_setting.charthick
      !p.multi = 0
    endif else begin
      !p = sys_var.p
      !x = sys_var.x
      !y = sys_var.y
      !z = sys_var.z
      !p.charsize = plot_setting.charsize
      !p.charthick = plot_setting.charthick
    endelse
  endif

  psymcircle, /fill

; color table check. Note: color table for psplot is different from regular plot
;  this is added for psplot.
  num = n_elements(line_setting.color)
  for i = 0, num - 1 do begin
    inx = where(line_setting.color_table eq line_setting.color[i], count)
    if count le 0 then inx = 0 else inx = inx[0]
    line_setting.color[i] = truecolor(strcompress(line_setting.color_table_str[inx], /remove_all))
  endfor

  for i = 0, plotinfo.num_plot - 1 do begin
    data = *plotinfo.pdata[i]
    inx_x = where( ( (data.x ge plot_setting.xrange[0]) and (data.x le plot_setting.xrange[1]) ), count )
 ;   if count gt MAX_DATA_POINT then $
 ;     nsum = fix(count / MAX_DATA_POINT) $
 ;   else $
      nsum = 0

    if i eq 0 then begin
    ;prepare for plot (i.e. no data)
      plot, data.x, data.y, xr = plot_setting.xrange, yr = plot_setting.yrange, $
            thick = line_setting.thick[i], linestyle = line_setting.style[i], $
            title = plot_setting.title, xtitle = plot_setting.xtitle, ytitle = plot_setting.ytitle, $
            xstyle = plot_setting.xstyle, ystyle = plot_setting.ystyle, $
            xlog = plot_setting.xlog, ylog = plot_setting.ylog, iso = plot_setting.isotropic, nsum = nsum, /nodata
    endif
    if line_setting.symbol[i] gt 0 then $
      oplot, data.x, data.y, psym = line_setting.symbol[i], symsize = line_setting.sym_size[i], col = line_setting.color[i], thick = line_setting.thick[i], nsum = nsum
    if line_setting.style[i] ge 0 then $
      oplot, data.x, data.y, thick = line_setting.thick[i], linestyle = line_setting.style[i], col = line_setting.color[i], nsum = nsum
    if( plot_setting.show_errbar eq 1 ) then begin
      if data.errbar_exist then begin  
        if (line_setting.symbol[i] gt 0) or (line_setting.style[i] ge 0) then begin
          oploterror_ycplot, data.x, data.y, data.hi_err, /hibar, errcol = line_setting.color[i], col = line_setting.color[i], nsum = nsum, $ 
                             psym = line_setting.symbol[i], symsize = line_setting.sym_size[i], linestyle=line_setting.style[i], thick = line_setting.thick[i]
          oploterror_ycplot, data.x, data.y, data.lo_err, /lobar, errcol = line_setting.color[i], col = line_setting.color[i], nsum = nsum, $
                             psym = line_setting.symbol[i], symsize = line_setting.sym_size[i], linestyle=line_setting.style[i], thick = line_setting.thick[i]
        endif
      endif
    endif
  endfor

; show legend if it is set
  if (plotinfo.legend_setting.show_legend eq 1) then begin
    legend_item = plotinfo.legend_setting.item[0:plotinfo.num_plot-1]
    legend_linestyle = line_setting.style[0:plotinfo.num_plot-1]
    legend_symbol = line_setting.symbol[0:plotinfo.num_plot-1]
    legend_linethick = line_setting.thick[0:plotinfo.num_plot-1]
    legend_symsize = line_setting.sym_size[0:plotinfo.num_plot-1]
    legend_color = line_setting.color[0:plotinfo.num_plot-1]
    ;if linestyle < 0, then only text (i.e neither line nor symbol)
    ;if linestyle > 0 and psym > 0, then text and symbol (no line)
    ;if linestyle > 0 and psym < 0, then text, symbol and line
    for i = 0, plotinfo.num_plot - 1 do begin
      if legend_linestyle[i] lt 0 then begin	;no line
        if legend_symbol[i] gt 0 then $		;with symbol
          legend_linestyle[i] = abs(legend_linestyle[i])
      endif else begin
        if legend_symbol[i] gt 0 then $
          legend_symbol[i] = -legend_symbol[i]
      endelse
    endfor
    legendd_ycplot, legend_item, linestyle = legend_linestyle, thick = legend_linethick, $
                          psym = legend_symbol, symsize = legend_symsize, col = legend_color, $
                          left = plotinfo.legend_setting.position.left, right = plotinfo.legend_setting.position.right, $
                          top = plotinfo.legend_setting.position.top, bottom = plotinfo.legend_setting.position.bottom
  endif

; show xyouts if it is set
  if plotinfo.xyouts_setting.show_xyouts eq 1 then begin
    xyout_index = where(plotinfo.xyouts_setting.text ne '', num_xyout)

  ; color table check. Note: color table for psplot is different from regular plot
  ;  this is added for psplot.
    xy_col = lindgen(num_xyout)
    for i = 0, num_xyout - 1 do begin
      inx = where(line_setting.color_table eq plotinfo.xyouts_setting.color[xyout_index[i]], count)
      if count le 0 then inx = 0 else inx = inx[0]
      xy_col[i] = truecolor(strcompress(line_setting.color_table_str[inx], /remove_all))
    endfor

    for i = 0, num_xyout-1 do begin
      xyouts, plotinfo.xyouts_setting.position.x[xyout_index[i]], plotinfo.xyouts_setting.position.y[xyout_index[i]], $
              plotinfo.xyouts_setting.text[xyout_index[i]], $
              charsize = plotinfo.xyouts_setting.charsize[xyout_index[i]], $
              charthick = plotinfo.xyouts_setting.charthick[xyout_index[i]], $
              color = xy_col[i], $
              orientation = plotinfo.xyouts_setting.orientation[xyout_index[i]], $
              /norm
    endfor
  endif


;save the system variables
  if not keyword_set(psplot) then begin
    plotinfo.sys_var.p = !p
    plotinfo.sys_var.x = !x
    plotinfo.sys_var.y = !y
    plotinfo.sys_var.z = !z
    widget_control, plot_id, set_uvalue = plotinfo

    !p = psys
    !x = xsys
    !y = ysys
    !z = zsys
  endif

end


pro save_figure_window_event, event
; get save_figure_window id
  widget_control, event.top, get_uvalue = save_figure_id

;kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    widget_control, save_figure_id.base, /destroy
  endif

;event due to save button
  if event.id eq save_figure_id.save_button then begin
    widget_control, save_figure_id.filename_text, get_value = str
    filename = str
    extension = widget_info(save_figure_id.fileformat_combo, /combobox_gettext)
    filename = str + extension
    widget_control, save_figure_id.parent_id, get_uvalue = idinfo
    idinfo.save_figure_filename = filename
    widget_control, save_figure_id.parent_id, set_uvalue = idinfo
    widget_control, save_figure_id.base, /destroy
  endif

;event due to cancel button
  if event.id eq save_figure_id.cancel_button then begin
    widget_control, save_figure_id.base, /destroy
  endif

end


pro save_figure_window, parent_id
; create widget for save_figure widget

  window_title = 'Save Figure for Plot ID: ' + string(parent_id, format='(i0)')
  base = widget_base(/column, title = window_title, xsize = 300, ysize = 160, /modal, $
                     group_leader = parent_id, /tlb_kill_request_events)
    base1 = widget_base(base, /row)
      label = widget_label(base1, value = 'File name:     ')
      filename_text = widget_text(base1, /editable, scr_xsize = 200)
    base2 = widget_base(base, /row)
      label = widget_label(base2, value = 'File format:   ')
      fileformat_combo = widget_combobox(base2, value = ['.bmp', '.gif', '.png'])
    base3 = widget_base(base, /column)
    note_str = 'Note:' + string(10b) + $
               'If there exists a file with the same filename,' + string(10b) + $ 
               'then this will overwrite the file'
    label = widget_label(base3, value = note_str, /align_left)
    base4 = widget_base(base)
      cancel_button = widget_button(base4, value = 'Cancel', xsize = 100, xoffset=90, yoffset = 10)
      save_button = widget_button(base4, value = 'Save', xsize = 100, xoffset = 200, yoffset = 10)


  save_figure_id = {parent_id:parent_id, $
                      base:base, $
                        filename_text:filename_text, $
                        fileformat_combo:fileformat_combo, $
                        cancel_button:cancel_button, $
                        save_button:save_button}

  widget_control, base, set_uvalue = save_figure_id
  widget_control, base, /realize
  xmanager, 'save_figure_window', base

end


pro save_data_window_event, event
; get save_figure_window id
  widget_control, event.top, get_uvalue = save_data_id

;kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    widget_control, save_data_id.base, /destroy
  endif

;event due to save button
  if event.id eq save_data_id.save_button then begin
    widget_control, save_data_id.filename_text, get_value = str
    filename = str
    extension = '.sav'
    filename = str + extension
    widget_control, save_data_id.parent_id, get_uvalue = idinfo
    idinfo.save_data_filename = filename
    widget_control, save_data_id.parent_id, set_uvalue = idinfo
    widget_control, save_data_id.base, /destroy
  endif

;event due to cancel button
  if event.id eq save_data_id.cancel_button then begin
    widget_control, save_data_id.base, /destroy
  endif
end

pro save_data_window, parent_id
; create widget for save_data widget

  window_title = 'Save Data for Plot ID: ' + string(parent_id, format='(i0)')
  base = widget_base(/column, title = window_title, xsize = 300, ysize = 130, /modal, $
                     group_leader = parent_id, /tlb_kill_request_events)
    base1 = widget_base(base, /row)
      label = widget_label(base1, value = 'File name:     ')
      filename_text = widget_text(base1, /editable, scr_xsize = 170)
      label = widget_label(base1, value = '.sav')
    base2 = widget_base(base, /column)
    note_str = 'Note:' + string(10b) + $
               'If there exists a file with the same filename,' + string(10b) + $ 
               'then this will overwrite the file'
    label = widget_label(base2, value = note_str, /align_left)
    base3 = widget_base(base)
      cancel_button = widget_button(base3, value = 'Cancel', xsize = 100, xoffset=90, yoffset = 10)
      save_button = widget_button(base3, value = 'Save', xsize = 100, xoffset = 200, yoffset = 10)


  save_data_id = {parent_id:parent_id, $
                      base:base, $
                        filename_text:filename_text, $
                        cancel_button:cancel_button, $
                        save_button:save_button}

  widget_control, base, set_uvalue = save_data_id
  widget_control, base, /realize
  xmanager, 'save_data_window', base
end


pro create_plot_setting_window, base_id

; retrieve the necessary data
  widget_control, base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  plot_setting = plotinfo.plot_setting

  window_title = 'ycplot: Plot Setting Window for Plot ID: ' + string(idinfo.base, format='(i0)')
  
  base_plot_setting_window = widget_base(/column, title = window_title, xsize = 430, ysize = 550, $
                                         group_leader = base_id, /tlb_kill_request_events)
    base1 = widget_base(base_plot_setting_window, /column, frame = 1)
      base10 = widget_base(base1, /row)
        description_label = widget_label(base10, value = 'Plot Description:   ')
        plot_set_description_text = widget_text(base10, /editable, scr_xsize = 290, /scroll, /wrap, value = plotinfo.description)  
      base11 = widget_base(base1, /row)
        title_label = widget_label(base11, value = 'Title:         ')
        title_text = widget_text(base11, /editable, scr_xsize = 320, value = plot_setting.title)
      base12 = widget_base(base1, /row)
        xtitle_label = widget_label(base12, value = 'xTitle:        ')
        xtitle_text = widget_text(base12, /editable, scr_xsize = 320, value = plot_setting.xtitle)
      base13 = widget_base(base1, /row)
        ytitle_label = widget_label(base13, value = 'yTitle:        ')
        ytitle_text = widget_text(base13, /editable, scr_xsize = 320, value = plot_setting.ytitle)
      base14 = widget_base(base1, /row)
        str_charsize = strcompress(string(plot_setting.charsize, format='(f0.2)'), /remove_all)
        charsize_label = widget_label(base14, value = 'Char. Size:    ')
        charsize_text = widget_text(base14, /editable, scr_xsize = 80, value = str_charsize)
        str_charthick = strcompress(string(plot_setting.charthick, format='(f0.2)'), /remove_all)
        charthick_label = widget_label(base14, value = '          Char. Thick:   ')
        charthick_text = widget_text(base14, /editable, scr_xsize = 80, value = str_charthick)
    base2 = widget_base(base_plot_setting_window, /row, frame = 1)
      base21 = widget_base(base2, /column)
        xstyle_label = widget_label(base21, value = '<x-axis style>')
        base211 = widget_base(base21, /column, /nonexclusive)
          xstyle1_button = widget_button(base211, value = 'Force exact axis range')
          xstyle2_button = widget_button(base211, value = 'Extend axis range')
          xstyle3_button = widget_button(base211, value = 'Suprress entire axis')
          xstyle4_button = widget_button(base211, value = 'Suprress box style aixs')
          curr_xstyle = plot_setting.xstyle
          xstyle_button_set = intarr(4)
          for i = 0, 3 do begin
            if ( curr_xstyle ge 2^(3-i) ) then begin
              xstyle_button_set[3-i] = 1
              curr_xstyle -= 2^(3-i)
            endif else begin
              xstyle_button_set[3-i] = 0
            endelse
          endfor
          widget_control, xstyle1_button, set_button = xstyle_button_set[0]
          widget_control, xstyle2_button, set_button = xstyle_button_set[1]
          widget_control, xstyle3_button, set_button = xstyle_button_set[2]
          widget_control, xstyle4_button, set_button = xstyle_button_set[3]
        base212 = widget_base(base21, /row)
          xlog_label = widget_label(base212, value = 'x-axis type:  ')
          xtype_combo = widget_combobox(base212, value = ['linear', 'logarithmic'])
          widget_control, xtype_combo, set_combobox_select = plot_setting.xlog
        base213 = widget_base(base21, /row)
          xrange_label1 = widget_label(base213, value = '                From     To')
        base214 = widget_base(base21, /row)
          str_xmin = strcompress(string(plot_setting.xrange[0]), /remove_all)
          str_xmax = strcompress(string(plot_setting.xrange[1]), /remove_all)
          xrange_label2 = widget_label(base214, value = 'x-axis range: ')
          xrange_min_text = widget_text(base214, /editable, scr_xsize=50, value = str_xmin)
          xrange_max_text = widget_text(base214, /editable, scr_xsize=50, value = str_xmax)
      base22 = widget_base(base2, /column)
        xstyle_label = widget_label(base22, value = '<y-axis style>')
        base221 = widget_base(base22, /column, /nonexclusive)
          ystyle1_button = widget_button(base221, value = 'Force exact axis range')
          ystyle2_button = widget_button(base221, value = 'Extend axis range')
          ystyle3_button = widget_button(base221, value = 'Suprress entire axis')
          ystyle4_button = widget_button(base221, value = 'Suprress box style aixs')
          curr_ystyle = plot_setting.ystyle
          ystyle_button_set = intarr(4)
          for i = 0, 3 do begin
            if ( curr_ystyle ge 2^(3-i) ) then begin
              ystyle_button_set[3-i] = 1
              curr_ystyle -= 2^(3-i)
            endif else begin
              ystyle_button_set[3-i] = 0
            endelse
          endfor
          widget_control, ystyle1_button, set_button = ystyle_button_set[0]
          widget_control, ystyle2_button, set_button = ystyle_button_set[1]
          widget_control, ystyle3_button, set_button = ystyle_button_set[2]
          widget_control, ystyle4_button, set_button = ystyle_button_set[3]
        base222 = widget_base(base22, /row)
          ylog_label = widget_label(base222, value = 'y-axis type:  ')
          ytype_combo = widget_combobox(base222, value = ['linear', 'logarithmic'])
          widget_control, ytype_combo, set_combobox_select = plot_setting.ylog
        base223 = widget_base(base22, /row)
          yrange_label1 = widget_label(base223, value = '                From     To')
        base224 = widget_base(base22, /row)
          str_ymin = strcompress(string(plot_setting.yrange[0]), /remove_all)
          str_ymax = strcompress(string(plot_setting.yrange[1]), /remove_all)
          yrange_label2 = widget_label(base224, value = 'y-axis range: ')
          yrange_min_text = widget_text(base224, /editable, scr_xsize=50, value = str_ymin)
          yrange_max_text = widget_text(base224, /editable, scr_xsize=50, value = str_ymax)
    base3 = widget_base(base_plot_setting_window, /row, frame = 1, /nonexclusive)
      iso_button = widget_button(base3, value = 'Set scale of x- and y-axes to be equal. (i.e. isotropic)')
      widget_control, iso_button, set_button = plot_setting.isotropic
    base4 = widget_base(base_plot_setting_window)
      plot_setting_apply_button = widget_button(base4, value = 'Apply', $
                                                xsize = 100, xoffset = 70, yoffset = 15)
      plot_setting_cancel_button = widget_button(base4, value = 'Cancel', $
                                                 xsize=100, xoffset=200, yoffset=15)
      plot_setting_ok_button = widget_button(base4, value = 'OK', $
                                             xsize=100, xoffset=330, yoffset=15)

; assign the idinfo values
  idinfo.base_plot_setting_window = base_plot_setting_window
  idinfo.plot_set_description_text = plot_set_description_text
  idinfo.title_text = title_text
  idinfo.xtitle_text = xtitle_text
  idinfo.ytitle_text = ytitle_text
  idinfo.charsize_text = charsize_text
  idinfo.charthick_text = charthick_text
  idinfo.xstyle1_button = xstyle1_button
  idinfo.xstyle2_button = xstyle2_button
  idinfo.xstyle3_button = xstyle3_button
  idinfo.xstyle4_button = xstyle4_button
  idinfo.xtype_combo = xtype_combo
  idinfo.xrange_min_text = xrange_min_text
  idinfo.xrange_max_text = xrange_max_text
  idinfo.ystyle1_button = ystyle1_button
  idinfo.ystyle2_button = ystyle2_button
  idinfo.ystyle3_button = ystyle3_button
  idinfo.ystyle4_button = ystyle4_button
  idinfo.ytype_combo = ytype_combo
  idinfo.yrange_min_text = yrange_min_text
  idinfo.yrange_max_text = yrange_max_text
  idinfo.iso_button = iso_button
  idinfo.plot_setting_apply_button = plot_setting_apply_button
  idinfo.plot_setting_cancel_button = plot_setting_cancel_button
  idinfo.plot_setting_ok_button = plot_setting_ok_button

; save the data
  widget_control, base_id, set_uvalue = idinfo

; this window must know the base_id
  widget_control, base_plot_setting_window, set_uvalue = base_id

end


pro show_plot_setting_window, idinfo

; realize the plot setting window
  widget_control, idinfo.base_plot_setting_window, /realize

; start the xmanager
  xmanager, 'plot_setting_window', idinfo.base_plot_setting_window, /no_block

end


pro kill_plot_setting_window, idinfo, plotinfo

  plotinfo.plot_setting.xlog_combo_temp = plotinfo.plot_setting.xlog
  plotinfo.plot_setting.ylog_combo_temp = plotinfo.plot_setting.ylog
  widget_control, idinfo.plot_draw, set_uvalue = plotinfo

; kill the plot setting window
  widget_control, idinfo.base_plot_setting_window, /destroy

; create the plot setting window so that it can be opend later.
  create_plot_setting_window, idinfo.base
end


pro save_plot_setting, idinfo, plotinfo

  widget_control, idinfo.plot_set_description_text, get_value = str
  plotinfo.description = str
  widget_control, idinfo.description_text, set_value = str
  widget_control, idinfo.title_text, get_value = str
  plotinfo.plot_setting.title = str
  widget_control, idinfo.xtitle_text, get_value = str
  plotinfo.plot_setting.xtitle = str
  widget_control, idinfo.ytitle_text, get_value = str 
  plotinfo.plot_setting.ytitle = str
  widget_control, idinfo.xrange_min_text, get_value = str
  plotinfo.plot_setting.xrange[0] = float(str)
  widget_control, idinfo.xrange_max_text, get_value = str
  plotinfo.plot_setting.xrange[1] = float(str)
  widget_control, idinfo.yrange_min_text, get_value = str
  plotinfo.plot_setting.yrange[0] = float(str)
  widget_control, idinfo.yrange_max_text, get_value = str
  plotinfo.plot_setting.yrange[1] = float(str)
  temp_xstyle = intarr(4)
  temp_xstyle[0] = widget_info(idinfo.xstyle1_button, /button_set)
  temp_xstyle[1] = widget_info(idinfo.xstyle2_button, /button_set)
  temp_xstyle[2] = widget_info(idinfo.xstyle3_button, /button_set)
  temp_xstyle[3] = widget_info(idinfo.xstyle4_button, /button_set)
  plotinfo.plot_setting.xstyle = 0
  for i = 0, 3 do begin
    plotinfo.plot_setting.xstyle += temp_xstyle[i] * 2^i
  endfor
  temp_ystyle = intarr(4)
  temp_ystyle[0] = widget_info(idinfo.ystyle1_button, /button_set)
  temp_ystyle[1] = widget_info(idinfo.ystyle2_button, /button_set)
  temp_ystyle[2] = widget_info(idinfo.ystyle3_button, /button_set)
  temp_ystyle[3] = widget_info(idinfo.ystyle4_button, /button_set)
  plotinfo.plot_setting.ystyle = 0
  for i = 0, 3 do begin
    plotinfo.plot_setting.ystyle += temp_ystyle[i] * 2^i
  endfor
  widget_control, idinfo.charsize_text, get_value = str
  plotinfo.plot_setting.charsize = float(str)
  widget_control, idinfo.charthick_text, get_value = str
  plotinfo.plot_setting.charthick = float(str)
  plotinfo.plot_setting.xlog = plotinfo.plot_setting.xlog_combo_temp
  plotinfo.plot_setting.ylog = plotinfo.plot_setting.ylog_combo_temp
  plotinfo.plot_setting.isotropic = widget_info(idinfo.iso_button, /button_set)

  widget_control, idinfo.plot_draw, set_uvalue = plotinfo
end


pro plot_setting_window_event, event

; get base widget info
  widget_control, event.top, get_uvalue = base_id
  widget_control, base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    kill_plot_setting_window, idinfo, plotinfo
    return
  endif

; event due to apply button
  if event.id eq idinfo.plot_setting_apply_button then begin
  ;save the data and replot the graph
    save_plot_setting, idinfo, plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to cancel button
  if event.id eq idinfo.plot_setting_cancel_button then begin
    kill_plot_setting_window, idinfo, plotinfo
    return
  endif

; event due to ok button
  if event.id eq idinfo.plot_setting_ok_button then begin
  ;save the data, then kill the window and redraw the graph
    save_plot_setting, idinfo, plotinfo
    kill_plot_setting_window, idinfo, plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to xtype_combo
  if event.id eq idinfo.xtype_combo then begin
    plotinfo.plot_setting.xlog_combo_temp = event.index
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

; event due to ytype_combo
  if event.id eq idinfo.ytype_combo then begin
    plotinfo.plot_setting.ylog_combo_temp = event.index
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

end


pro create_oplot_setting_window, base_id

; retrieve the necessary data
  widget_control, base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  line_setting = plotinfo.line_setting
  num_plot = plotinfo.num_plot

  window_title = 'ycplot: Oplot Setting Window for Plot ID: ' + string(idinfo.base, format='(i0)')
  base_oplot_setting_window = widget_base(/column, title = window_title, xsize = 370, ysize = 270, $
                                          group_leader = base_id, /tlb_kill_request_events)
    base1 = widget_base(base_oplot_setting_window, /row)
      label1 = widget_label(base1, value = 'Select Line Number: ')
      sel_line_num_combo = widget_combobox(base1, value = string(indgen(num_plot)+1, format='(i0)'))
      widget_control, sel_line_num_combo, set_combobox_select = 0
    base2 = widget_base(base_oplot_setting_window, /column, frame = 1)
      base21 = widget_base(base2, /row)
        label21 = widget_label(base21, value = 'Line Thickness: ')
        str_thick = strcompress(string(line_setting.thick[0], format='(f0.2)'), /remove_all)
        thick_text = widget_text(base21, /editable, scr_xsize = 200, value = str_thick, /all_events)
      base22 = widget_base(base2, /row)
        label22 = widget_label(base22, value = 'Line Style:     ')
        style_combo = widget_combobox(base22, value = ['No Line', $
                                                       'Solid', $
                                                       'Dotted', $
                                                       'Dashed', $
                                                       'Dash Dot', $
                                                       'Dash Dot Dot', $
                                                       'Long Dashes'])
        widget_control, style_combo, set_combobox_select = line_setting.style[0]+1
      base23 = widget_base(base2, /row)
        label23 = widget_label(base23, value = 'Line Color:     ')
        color_combo = widget_combobox(base23, value = line_setting.color_table_str)
        widget_control, color_combo, set_combobox_select = where(line_setting.color_table eq line_setting.color[0])
      base24 = widget_base(base2, /row)
        label24 = widget_label(base24, value = 'Symbol Style:   ')
        symbol_combo = widget_combobox(base24, value = ['No Symbol', $
                                                        'Plus (+)', $
                                                        'Asterisk (*)', $
                                                        'Period (.)', $
                                                        'Diamond', $
                                                        'Triangle', $
                                                        'Square', $
                                                        'X', $
                                                        'Circle'])
        widget_control, symbol_combo, set_combobox_select = line_setting.symbol[0]
      base25 = widget_base(base2, /row)
        label25 = widget_label(base25, value = 'Symbol Size:    ')
        str_sym_size = strcompress(string(line_setting.sym_size[0], format='(f0.2)'), /remove_all)
        sym_size_text = widget_text(base25, /editable, scr_xsize = 200, value = str_sym_size, /all_events)
    base3 = widget_base(base_oplot_setting_window)
      oplot_setting_apply_button = widget_button(base3, value = 'Apply', $
                                                 xsize = 100, xoffset = 30, yoffset = 10)
      oplot_setting_cancel_button = widget_button(base3, value = 'Cancel', $
                                                  xsize = 100, xoffset = 150, yoffset = 10)
      oplot_setting_ok_button = widget_button(base3, value = 'OK', $
                                                  xsize = 100, xoffset = 270, yoffset = 10)

  idinfo.base_oplot_setting_window = base_oplot_setting_window
  idinfo.sel_line_num_combo = sel_line_num_combo
  idinfo.thick_text = thick_text
  idinfo.style_combo = style_combo
  idinfo.color_combo = color_combo
  idinfo.symbol_combo = symbol_combo
  idinfo.sym_size_text = sym_size_text
  idinfo.oplot_setting_apply_button = oplot_setting_apply_button
  idinfo.oplot_setting_cancel_button = oplot_setting_cancel_button
  idinfo.oplot_setting_ok_button = oplot_setting_ok_button

  oplot_info = line_setting
  oplot_info = create_struct(oplot_info, 'base_id', base_id)

; save the data
  widget_control, base_id, set_uvalue = idinfo

; this window must know the base_id
  widget_control, base_oplot_setting_window, set_uvalue = oplot_info

end


pro show_oplot_setting_window, idinfo

; realize the plot setting window
  widget_control, idinfo.base_oplot_setting_window, /realize

; start the xmanager
  xmanager, 'oplot_setting_window', idinfo.base_oplot_setting_window, /no_block

end

pro kill_oplot_setting_window, idinfo

; kill the plot setting window
  widget_control, idinfo.base_oplot_setting_window, /destroy

; create the plot setting window so that it can be opend later.
  create_oplot_setting_window, idinfo.base

end


pro save_oplot_setting, idinfo

  widget_control, idinfo.base_oplot_setting_window, get_uvalue = oplot_info
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

  plotinfo.line_setting.thick = oplot_info.thick
  plotinfo.line_setting.style = oplot_info.style
  plotinfo.line_setting.color = oplot_info.color
  plotinfo.line_setting.symbol = oplot_info.symbol
  plotinfo.line_setting.sym_size = oplot_info.sym_size

  widget_control, idinfo.plot_draw, set_uvalue = plotinfo
end


pro oplot_setting_window_event, event

; get base widget info
  widget_control, event.top, get_uvalue = oplot_info
  widget_control, oplot_info.base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    kill_oplot_setting_window, idinfo
    return
  endif

; event due to apply button
  if event.id eq idinfo.oplot_setting_apply_button then begin
  ;save the data, and redraw the graph
    save_oplot_setting, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to cancel button
  if event.id eq idinfo.oplot_setting_cancel_button then begin
    kill_oplot_setting_window, idinfo
    return
  endif

; event due to ok button
  if event.id eq idinfo.oplot_setting_ok_button then begin
  ;save the data, then kill the window and redraw the graph
    save_oplot_setting, idinfo
    kill_oplot_setting_window, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to select line number combo box 
  if event.id eq idinfo.sel_line_num_combo then begin
    line_num_inx = event.index
    str = strcompress(string(oplot_info.thick[line_num_inx], format='(f0.2)'), /remove_all)
    widget_control, idinfo.thick_text, set_value = str
    widget_control, idinfo.style_combo, set_combobox_select = oplot_info.style[line_num_inx]+1
    widget_control, idinfo.color_combo, set_combobox_select = where(oplot_info.color_table eq oplot_info.color[line_num_inx])
    widget_control, idinfo.symbol_combo, set_combobox_select = oplot_info.symbol[line_num_inx]
    str = strcompress(string(oplot_info.sym_size[line_num_inx], format='(f0.2)'), /remove_all)
    widget_control, idinfo.sym_size_text, set_value = str
  endif


; get the current line number index
  str_line_num_inx = widget_info(idinfo.sel_line_num_combo, /combobox_gettext)
  line_num_inx = fix(str_line_num_inx) - 1

; event due to chages in line thickness text box
  if event.id eq idinfo.thick_text then begin
    widget_control, idinfo.thick_text, get_value = str
    oplot_info.thick[line_num_inx] = float(str)
    widget_control, event.top, set_uvalue = oplot_info
  endif

; event due to line style combo box
  if event.id eq idinfo.style_combo then begin
    oplot_info.style[line_num_inx] = event.index - 1
    widget_control, event.top, set_uvalue = oplot_info
  endif

; event due to color combo box
  if event.id eq idinfo.color_combo then begin
    oplot_info.color[line_num_inx] = oplot_info.color_table[event.index]
    widget_control, event.top, set_uvalue = oplot_info
  endif

; event due to symbol combo box
  if event.id eq idinfo.symbol_combo then begin
    oplot_info.symbol[line_num_inx] = event.index
    widget_control, event.top, set_uvalue = oplot_info
  endif

; event due to symbox size text box
  if event.id eq idinfo.sym_size_text then begin
    widget_control, idinfo.sym_size_text, get_value = str
    oplot_info.sym_size[line_num_inx] = float(str)
    widget_control, event.top, set_uvalue = oplot_info
  endif

end


pro create_legend_setting_window, base_id

; retrieve the necessary data
  widget_control, base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  legend_setting = plotinfo.legend_setting
  num_plot = plotinfo.num_plot

  window_title = 'ycplot: Legend Setting Window for Plot ID: ' + string(idinfo.base, format='(i0)')
  base_legend_setting_window = widget_base(/column, title = window_title, xsize = 370, ysize = 250, $
                                           group_leader = base_id, /tlb_kill_request_events)
    base1 = widget_base(base_legend_setting_window, /row, /nonexclusive)
      show_legend_button = widget_button(base1, value = 'Show Legend')
      widget_control, show_legend_button, set_button = legend_setting.show_legend
    base2 = widget_base(base_legend_setting_window, /column, frame=1)
      label2 = widget_label(base2, value = '<Legend Position>')
      base21 = widget_base(base2, /row, /exclusive)
        pos_left_button = widget_button(base21, value = 'Left')
        pos_right_button = widget_button(base21, value = 'Right')
        widget_control, pos_left_button, set_button = legend_setting.position.left
        widget_control, pos_right_button, set_button = legend_setting.position.right
      base22 = widget_base(base2, /row, /exclusive)
        pos_top_button = widget_button(base22, value = 'Top')
        pos_bottom_button = widget_button(base22, value = 'Bottom')
        widget_control, pos_top_button, set_button = legend_setting.position.top
        widget_control, pos_bottom_button, set_button = legend_setting.position.bottom
    base3 = widget_base(base_legend_setting_window, /column, frame = 1)
      base31 = widget_base(base3, /row)
        label31 = widget_label(base31, value = 'Select Line Number: ')
        legend_sel_line_num_combo = widget_combobox(base31, value = string(indgen(num_plot)+1, format='(i0)'))
        widget_control, legend_sel_line_num_combo, set_combobox_select = 0
      base32 = widget_base(base3, /row)
        label32 = widget_label(base32, value = 'Legend Text:        ')
        item_text = widget_text(base32, /editable, scr_xsize = 240, value = legend_setting.item[0], /all_events)
    base4 = widget_base(base_legend_setting_window)
      legend_setting_apply_button = widget_button(base4, value = 'Apply', $
                                                  xsize = 100, xoffset = 30, yoffset = 10)
      legend_setting_cancel_button = widget_button(base4, value = 'Cancel', $
                                                   xsize = 100, xoffset = 150, yoffset = 10)
      legend_setting_ok_button = widget_button(base4, value = 'OK', $
                                               xsize = 100, xoffset = 270, yoffset = 10)

  idinfo.base_legend_setting_window = base_legend_setting_window
  idinfo.show_legend_button = show_legend_button
  idinfo.pos_left_button = pos_left_button
  idinfo.pos_right_button = pos_right_button
  idinfo.pos_top_button = pos_top_button
  idinfo.pos_bottom_button = pos_bottom_button
  idinfo.legend_sel_line_num_combo = legend_sel_line_num_combo
  idinfo.item_text = item_text
  idinfo.legend_setting_apply_button = legend_setting_apply_button
  idinfo.legend_setting_cancel_button = legend_setting_cancel_button
  idinfo.legend_setting_ok_button = legend_setting_ok_button

  legend_info = legend_setting
  legend_info = create_struct(legend_info, 'base_id', base_id)

; save the data
  widget_control, base_id, set_uvalue = idinfo

; this window must know the base_id
  widget_control, base_legend_setting_window, set_uvalue = legend_info

end


pro show_legend_setting_window, idinfo

; realize the plot setting window
  widget_control, idinfo.base_legend_setting_window, /realize

; start the xmanager
  xmanager, 'legend_setting_window', idinfo.base_legend_setting_window, /no_block

end


pro kill_legend_setting_window, idinfo

; kill the plot setting window
  widget_control, idinfo.base_legend_setting_window, /destroy

; create the plot setting window so that it can be opend later.
  create_legend_setting_window, idinfo.base

end


pro save_legend_setting, idinfo

  widget_control, idinfo.base_legend_setting_window, get_uvalue = legend_info
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

  plotinfo.legend_setting.item = legend_info.item
  plotinfo.legend_setting.show_legend = legend_info.show_legend
  plotinfo.legend_setting.position = legend_info.position

  widget_control, idinfo.plot_draw, set_uvalue = plotinfo

end


pro legend_setting_window_event, event
; get base widget info
  widget_control, event.top, get_uvalue = legend_info
  widget_control, legend_info.base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    kill_legend_setting_window, idinfo
    return
  endif

;event due to apply button
  if event.id eq idinfo.legend_setting_apply_button then begin
  ;save the data,  and redraw the graph
    save_legend_setting, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to cancel button
  if event.id eq idinfo.legend_setting_cancel_button then begin
    kill_legend_setting_window, idinfo
    return
  endif

; event due to ok button
  if event.id eq idinfo.legend_setting_ok_button then begin
  ;save the data, then kill the window and redraw the graph
    save_legend_setting, idinfo
    kill_legend_setting_window, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to show legend button
  if event.id eq idinfo.show_legend_button then begin
    legend_info.show_legend = widget_info(idinfo.show_legend_button, /button_set)
    widget_control, event.top, set_uvalue = legend_info
  endif

; event due to pos_left_button or pos_right_button
  if ( (event.id eq idinfo.pos_left_button) or (event.id eq idinfo.pos_right_button) ) then begin
    legend_info.position.left = widget_info(idinfo.pos_left_button, /button_set)
    legend_info.position.right = widget_info(idinfo.pos_right_button, /button_set)
    widget_control, event.top, set_uvalue = legend_info
  endif

; event due to pos_top_button or pos_bottom_button
  if ( (event.id eq idinfo.pos_top_button) or (event.id eq idinfo.pos_bottom_button) ) then begin
    legend_info.position.top = widget_info(idinfo.pos_top_button, /button_set)
    legend_info.position.bottom = widget_info(idinfo.pos_bottom_button, /button_set)
    widget_control, event.top, set_uvalue = legend_info
  endif

; event due to select line number combo box
  if event.id eq idinfo.legend_sel_line_num_combo then begin
    widget_control, idinfo.item_text, set_value = legend_info.item[event.index]
  endif

; get the current line number index
  str_line_num_inx = widget_info(idinfo.legend_sel_line_num_combo, /combobox_gettext)
  line_num_inx = fix(str_line_num_inx) - 1

; event due to legend text
  if event.id eq idinfo.item_text then begin
    widget_control, idinfo.item_text, get_value = str
    legend_info.item[line_num_inx] = str
    widget_control, event.top, set_uvalue = legend_info
  endif

end


pro create_xyouts_setting_window, base_id

; retrieve the necessary data
  widget_control, base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  xyouts_setting = plotinfo.xyouts_setting
  line_setting = plotinfo.line_setting

  window_title = 'ycplot: xyouts Setting Window for Plot ID: ' + string(idinfo.base, format='(i0)')
  base_xyouts_setting_window = widget_base(/column, title = window_title, xsize = 400, ysize = 360, $
                                           group_leader = base_id, /tlb_kill_request_events)
    base0 = widget_base(base_xyouts_setting_window, /row, /nonexclusive)
      show_xyouts_button = widget_button(base0, value = 'Show xyouts')
      widget_control, show_xyouts_button, set_button = xyouts_setting.show_xyouts
    base1 = widget_base(base_xyouts_setting_window, /row)
      label1 = widget_label(base1, value = 'Text Number:  ')
      sel_xyouts_num_combo = widget_combobox(base1, value = string(indgen(xyouts_setting.MAX_NUM_XYOUTS)+1, format='(i0)'))
      widget_control, sel_xyouts_num_combo, set_combobox_select = 0
    base2 = widget_base(base_xyouts_setting_window, /column, frame = 1)
      base21 = widget_base(base2, /row)
        label21 = widget_label(base21, value = 'Text: ')
        xyouts_text = widget_text(base21, /editable, scr_xsize = 340, value = xyouts_setting.text[0], /all_events)
      base22 = widget_base(base2)
        label221 = widget_label(base22, value = 'x', xoffset = 165)
        label222 = widget_label(base22, value = 'y', xoffset = 305)
      base23 = widget_base(base2, /row)
        label23 = widget_label(base23, value = 'Text Position: ')
        str = strcompress(string(xyouts_setting.position.x[0], format='(f0.2)'), /remove_all)
        position_x_text = widget_text(base23, /editable, scr_xsize = 140, value = str, /all_events)
        str = strcompress(string(xyouts_setting.position.y[0], format='(f0.2)'), /remove_all)
        position_y_text = widget_text(base23, /editable, scr_xsize = 140, value = str, /all_events) 
      base24 = widget_base(base2)
        label242 = widget_label(base24, xoffset = 30, value = 'Note: Use normalized units for position. (from 0.0 to 1.0)'+string(10b))
      base25 = widget_base(base2, /row)
        label251 = widget_label(base25, value = 'Char. Size: ')
        str = strcompress(string(xyouts_setting.charsize[0], format='(f0.2)'), /remove_all)
        xyouts_charsize_text = widget_text(base25, /editable, scr_xsize = 90, value = str, /all_events)
        label252 = widget_label(base25, value = '     Char. Thick: ')
        str = strcompress(string(xyouts_setting.charthick[0], format='(f0.2)'), /remove_all)
        xyouts_charthick_text = widget_text(base25, /editable, scr_xsize = 90, value = str, /all_events)
      base26 = widget_base(base2, /row)
        label26 = widget_label(base26, value = 'Color: ')
        xyouts_color_combo = widget_combobox(base26, value = line_setting.color_table_str)
        widget_control, xyouts_color_combo, set_combobox_select = where(line_setting.color_table eq xyouts_setting.color[0])
      base27 = widget_base(base2, /row)
        label271 = widget_label(base27, value = 'Orientation: ')
        str = strcompress(string(xyouts_setting.orientation[0], format='(f0.2)'), /remove_all)
        xyouts_orientation_text = widget_text(base27, /editable, scr_xsize=100, value = str, /all_events)
        label272 = widget_label(base27, value = 'in degrees')
    base3 = widget_base(base_xyouts_setting_window)
      xyouts_setting_apply_button = widget_button(base3, value = 'Apply', $
                                    xsize = 100, xoffset = 60, yoffset = 10)
      xyouts_setting_cancel_button = widget_button(base3, value = 'Cancel', $
                                                   xsize = 100, xoffset = 180, yoffset = 10)
      xyouts_setting_ok_button = widget_button(base3, value = 'OK', $
                                                   xsize = 100, xoffset = 300, yoffset = 10)

  idinfo.base_xyouts_setting_window = base_xyouts_setting_window
  idinfo.show_xyouts_button = show_xyouts_button
  idinfo.sel_xyouts_num_combo = sel_xyouts_num_combo
  idinfo.xyouts_text = xyouts_text
  idinfo.position_x_text = position_x_text
  idinfo.position_y_text = position_y_text
  idinfo.xyouts_charsize_text = xyouts_charsize_text
  idinfo.xyouts_charthick_text = xyouts_charthick_text
  idinfo.xyouts_color_combo = xyouts_color_combo
  idinfo.xyouts_orientation_text = xyouts_orientation_text
  idinfo.xyouts_setting_apply_button = xyouts_setting_apply_button
  idinfo.xyouts_setting_cancel_button = xyouts_setting_cancel_button
  idinfo.xyouts_setting_ok_button = xyouts_setting_ok_button

  xyouts_info = xyouts_setting
  xyouts_info = create_struct(xyouts_info, 'base_id', base_id)

; save the data
  widget_control, base_id, set_uvalue = idinfo

; this window must know the base_id
  widget_control, base_xyouts_setting_window, set_uvalue = xyouts_info

end

pro show_xyouts_setting_window, idinfo

; realize the xyouts setting window
  widget_control, idinfo.base_xyouts_setting_window, /realize

; start the xmanager
  xmanager, 'xyouts_setting_window', idinfo.base_xyouts_setting_window, /no_block

end

pro kill_xyouts_setting_window, idinfo

; kill the xyouts setting window
  widget_control, idinfo.base_xyouts_setting_window, /destroy

; create the xyouts setting window so that it can be opend later.
  create_xyouts_setting_window, idinfo.base

end


pro save_xyouts_setting, idinfo

  widget_control, idinfo.base_xyouts_setting_window, get_uvalue = xyouts_info
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

  plotinfo.xyouts_setting.text = xyouts_info.text
  plotinfo.xyouts_setting.position = xyouts_info.position
  plotinfo.xyouts_setting.charsize = xyouts_info.charsize
  plotinfo.xyouts_setting.charthick = xyouts_info.charthick
  plotinfo.xyouts_setting.color = xyouts_info.color
  plotinfo.xyouts_setting.orientation = xyouts_info.orientation
  plotinfo.xyouts_setting.show_xyouts = xyouts_info.show_xyouts

  widget_control, idinfo.plot_draw, set_uvalue = plotinfo

end

pro xyouts_setting_window_event, event
; get base widget info
  widget_control, event.top, get_uvalue = xyouts_info
  widget_control, xyouts_info.base_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    kill_xyouts_setting_window, idinfo
    return
  endif

; event due to apply button
  if event.id eq idinfo.xyouts_setting_apply_button then begin
  ;save the data, and redraw the graph
    save_xyouts_setting, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to cancel button
  if event.id eq idinfo.xyouts_setting_cancel_button then begin
    kill_xyouts_setting_window, idinfo
    return
  endif

; event due to ok button
  if event.id eq idinfo.xyouts_setting_ok_button then begin
  ;save the data, then kill the window and redraw the graph
    save_xyouts_setting, idinfo
    kill_xyouts_setting_window, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to show_xyouts_button
  if event.id eq idinfo.show_xyouts_button then begin
    xyouts_info.show_xyouts = widget_info(idinfo.show_xyouts_button, /button_set)
    widget_control, event.top, set_uvalue = xyouts_info
  endif

; event due to sel_xyouts_num_combo
  if event.id eq idinfo.sel_xyouts_num_combo then begin
    widget_control, idinfo.xyouts_text, set_value = xyouts_info.text[event.index]
    str = strcompress(string(xyouts_info.position.x[event.index], format='(f0.2)'), /remove_all)
    widget_control, idinfo.position_x_text, set_value = str
    str = strcompress(string(xyouts_info.position.y[event.index], format='(f0.2)'), /remove_all)
    widget_control, idinfo.position_y_text, set_value = str
    str = strcompress(string(xyouts_info.charsize[event.index], format='(f0.2)'), /remove_all)
    widget_control, idinfo.xyouts_charsize_text, set_value = str
    str = strcompress(string(xyouts_info.charthick[event.index], format='(f0.2)'), /remove_all)
    widget_control, idinfo.xyouts_charthick_text, set_value = str
    widget_control, idinfo.xyouts_color_combo, $
                    set_combobox_select = where(plotinfo.line_setting.color_table eq xyouts_info.color[event.index])
    str = strcompress(string(xyouts_info.orientation[event.index], format='(f0.2)'), /remove_all)
    widget_control, idinfo.xyouts_orientation_text, set_value = str

    widget_control, event.top, set_uvalue = xyouts_info
  endif


; get the current line number index
  str_line_num_inx = widget_info(idinfo.sel_xyouts_num_combo, /combobox_gettext)
  line_num_inx = fix(str_line_num_inx) - 1

; event due to xyouts_text
  if event.id eq idinfo.xyouts_text then begin
    widget_control, idinfo.xyouts_text, get_value = str
    xyouts_info.text[line_num_inx] = str
    widget_control, event.top, set_uvalue = xyouts_info
  endif

; event due to position_x_text
  if event.id eq idinfo.position_x_text then begin
    widget_control, idinfo.position_x_text, get_value = str
    xyouts_info.position.x[line_num_inx] = float(str)
    widget_control, event.top, set_uvalue = xyouts_info
  endif

; event due to position_y_text
  if event.id eq idinfo.position_y_text then begin
    widget_control, idinfo.position_y_text, get_value = str
    xyouts_info.position.y[line_num_inx] = float(str)
    widget_control, event.top, set_uvalue = xyouts_info
  endif

; event due to xyouts_charsize_text
  if event.id eq idinfo.xyouts_charsize_text then begin
    widget_control, idinfo.xyouts_charsize_text, get_value = str
    xyouts_info.charsize[line_num_inx] = float(str)
    widget_control, event.top, set_uvalue = xyouts_info
  endif

; event due to xyouts_charthick_text
  if event.id eq idinfo.xyouts_charthick_text then begin
    widget_control, idinfo.xyouts_charthick_text, get_value = str
    xyouts_info.charthick[line_num_inx] = float(str)
    widget_control, event.top, set_uvalue = xyouts_info
  endif

; event due to xyouts_color_combo
  if event.id eq idinfo.xyouts_color_combo then begin
    xyouts_info.color[line_num_inx] = plotinfo.line_setting.color_table[event.index]
    widget_control, event.top, set_uvalue = xyouts_info
  endif

; event due to xyouts_orientation_text
  if event.id eq idinfo.xyouts_orientation_text then begin
    widget_control, idinfo.xyouts_orientation_text, get_value = str
    xyouts_info.orientation[line_num_inx] = float(str)
    widget_control, event.top, set_uvalue = xyouts_info
  endif

end

pro ycplot_mouse_button_down, event, idinfo

;event.press = 1 --> left button
;            = 2 --> middle button
;            = 4 --> right button


  if event.press eq 1 then begin	;left button is pressed: prepare for zoomming in x- and y- directions
  ;save the mouse position.
    idinfo.mouse.x0 = event.x
    idinfo.mouse.x1 = event.x
    idinfo.mouse.y0 = event.y
    idinfo.mouse.y1 = event.y
    idinfo.mouse.left_middle = 1	;I need to know whether left button or middle is pressed for mouse motion.
                                        ;If this is 1, then left button. If this is 2, then middle button 

  ; activate the mouse motion events on the plot
    widget_control, event.id, draw_motion_events = 1

  ; save the graphics mode to draw selection lines
    device, get_graphics = oldg, set_graphics = 6
    idinfo.mouse.graphic_mode = oldg

  ; save the idinfo
    widget_control, idinfo.base, set_uvalue = idinfo
  endif else if event.press eq 2 then begin	;middle button is pressed: prepare for panning the window
  ;save the mouse position.
    idinfo.mouse.x0 = event.x
    idinfo.mouse.x1 = event.x
    idinfo.mouse.y0 = event.y
    idinfo.mouse.y1 = event.y
    idinfo.mouse.left_middle = 2	;I need to know whether left button or middle is pressed for mouse motion.
                                        ;If this is 1, then left button. If this is 2, then middle button
  ; activate the mouse motion events on the plot
    widget_control, event.id, draw_motion_events = 1

  ; save the idinfo
    widget_control, idinfo.base, set_uvalue = idinfo
  endif else if event.press eq 4 then begin	;right button is pressed: do nothing
  ; do nothing

  endif else begin
  ; do nothing

  endelse 

end

pro ycplot_mouse_button_up, event, idinfo
;event.release = 1 --> left button
;              = 2 --> middle button
;              = 4 --> right button

  if event.release eq 1 then begin		;left button is released: stop zooming
  ; deactivate the mouse motion
    widget_control, event.id, draw_motion_events = 0
  ; remove the highlight
    draw_highlight, idinfo
  ; get the current zoom range in device coordinate
    xr_device = [idinfo.mouse.x0 < idinfo.mouse.x1, idinfo.mouse.x0 > idinfo.mouse.x1]
    yr_device = [idinfo.mouse.y0 < idinfo.mouse.y1, idinfo.mouse.y0 > idinfo.mouse.y1]
    xy_direction = idinfo.mouse.xy_direction
  ; reset the mouse info
    idinfo.mouse.left_middle = 0
    idinfo.mouse.xy_direction = 0
  ; restore the graphic mode
    device, set_graphics = idinfo.mouse.graphic_mode
  ; save the idinfo
    widget_control, idinfo.base, set_uvalue = idinfo

  ; get the plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  ; save the system variables
    psys = !p
    xsys = !x
    ysys = !y
    zsys = !z
  ; restore the plot_draw system variables
    !p = plotinfo.sys_var.p
    !x = plotinfo.sys_var.x
    !y = plotinfo.sys_var.y
    !z = plotinfo.sys_var.z
  ; convert the mouse device coordinate into data coordinate
    temp_data_coord = convert_coord([xr_device[0], xr_device[1]], [yr_device[0], yr_device[1]], /device, /to_data)
  ; save the xrange and yrange
    if xy_direction eq 1 then begin
      plotinfo.plot_setting.xrange = reform(temp_data_coord[0, *])
      str = strcompress(string(plotinfo.plot_setting.xrange[0]), /remove_all)
      widget_control, idinfo.xrange_min_text, set_value = str
      str = strcompress(string(plotinfo.plot_setting.xrange[1]), /remove_all)
      widget_control, idinfo.xrange_max_text, set_value = str
    endif else if xy_direction eq 2 then begin
      plotinfo.plot_setting.yrange = reform(temp_data_coord[1, *])
      str = strcompress(string(plotinfo.plot_setting.yrange[0]), /remove_all)
      widget_control, idinfo.yrange_min_text, set_value = str
      str = strcompress(string(plotinfo.plot_setting.yrange[1]), /remove_all)
      widget_control, idinfo.yrange_max_text, set_value = str
    endif
  ; save the plotinfo
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo

  ; restore the system variables
    !p = psys
    !x = xsys
    !y = ysys
    !z = zsys

  ; redraw the plot
    replot_all, plotinfo, idinfo.plot_draw
  endif else if event.release eq 2 then begin	; middle button is relased: stop panning
  ; deactivate the mouse motion
    widget_control, event.id, draw_motion_events = 0
  ; reset the mouse info
    idinfo.mouse.left_middle = 0
  ; save the idinfo
    widget_control, idinfo.base, set_uvalue = idinfo

  ; get the plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo

  ; updat the xrange and yrange text boxes
    str = strcompress(string(plotinfo.plot_setting.xrange[0]), /remove_all)
    widget_control, idinfo.xrange_min_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.xrange[1]), /remove_all)
    widget_control, idinfo.xrange_max_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.yrange[0]), /remove_all)
    widget_control, idinfo.yrange_min_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.yrange[1]), /remove_all)
    widget_control, idinfo.yrange_max_text, set_value = str
  endif else if event.release eq 4 then begin	; right button is release: reset the plot window
  ; get the plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo

    xmin_temp = fltarr(plotinfo.num_plot)
    xmax_temp = fltarr(plotinfo.num_plot)
    ymin_temp = fltarr(plotinfo.num_plot)
    ymax_temp = fltarr(plotinfo.num_plot)
  ; find out min and max of x and y
    for i = 0, plotinfo.num_plot - 1 do begin
      data = *plotinfo.pdata[i]
      xmin_temp[i] = min(data.x)
      xmax_temp[i] = max(data.x)
      ymin_temp[i] = min(data.y)
      ymax_temp[i] = max(data.y)
    endfor
    plotinfo.plot_setting.xrange = [min(xmin_temp), max(xmax_temp)]
    plotinfo.plot_setting.yrange = [min(ymin_temp), max(ymax_temp)]

  ; save the plotinfo
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo

  ; updat the xrange and yrange text boxes
    str = strcompress(string(plotinfo.plot_setting.xrange[0]), /remove_all)
    widget_control, idinfo.xrange_min_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.xrange[1]), /remove_all)
    widget_control, idinfo.xrange_max_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.yrange[0]), /remove_all)
    widget_control, idinfo.yrange_min_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.yrange[1]), /remove_all)
    widget_control, idinfo.yrange_max_text, set_value = str

  ;redraw the plot
    replot_all, plotinfo, idinfo.plot_draw
  endif else begin
  ; do nothing

  endelse

end

pro ycplot_mouse_button_move, event, idinfo
;event.press = 1 --> left button
;            = 2 --> middle button

  if idinfo.mouse.left_middle eq 1 then begin		;left button motion: zoom
  ; delete the current highlight
    draw_highlight, idinfo
  ; save the current mouse position
    idinfo.mouse.x1 = event.x
    idinfo.mouse.y1 = event.y
    x_motion = abs(idinfo.mouse.x1 - idinfo.mouse.x0)
    y_motion = abs(idinfo.mouse.y1 - idinfo.mouse.y0)
    if x_motion ge y_motion then $
      idinfo.mouse.xy_direction = 1 $	;x-direction zoom
    else $
      idinfo.mouse.xy_direction = 2 	;y-direction zoom
    widget_control, idinfo.base, set_uvalue = idinfo
  ; draw the highlight again 
    draw_highlight, idinfo
  endif else if idinfo.mouse.left_middle eq 2 then begin	;middle button motion: pan
  ; save the current mouse positino
    idinfo.mouse.x1 = event.x
    idinfo.mouse.y1 = event.y
    x_motion_device = idinfo.mouse.x0 - idinfo.mouse.x1	;in device unit
    y_motion_device = idinfo.mouse.y0 - idinfo.mouse.y1	;in device unit
    idinfo.mouse.x0 = event.x
    idinfo.mouse.y0 = event.y
    widget_control, idinfo.base, set_uvalue = idinfo

  ; get the plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo

  ; get the current x- and y-ranges in data coordinate
    xrange = plotinfo.plot_setting.xrange
    yrange = plotinfo.plot_setting.yrange

  ; save the system variables
    psys = !p
    xsys = !x
    ysys = !y
    zsys = !z
  ; restore the plot_draw system variables
    !p = plotinfo.sys_var.p
    !x = plotinfo.sys_var.x
    !y = plotinfo.sys_var.y
    !z = plotinfo.sys_var.z

  ; calculate the to-be-updated x- and y-ranges due to panning
  ; !p.clip[0] in device unit : xrange[0] in data unit
  ; !p.clip[1] in device unit : yrange[0] in data unit
  ; !p.clip[2] in device unit : xrange[1] in data unit
  ; !p.clip[3] in device unit : yrange[1] in data unit
    x_motion_data = x_motion_device * (xrange[1] - xrange[0])/(!p.clip[2] - !p.clip[0])
    y_motion_data = y_motion_device * (yrange[1] - yrange[0])/(!p.clip[3] - !p.clip[1])

  ; save the new x- and y-ranges
    plotinfo.plot_setting.xrange = xrange + x_motion_data
    plotinfo.plot_setting.yrange = yrange + y_motion_data
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo

  ; restore the system variables
    !p = psys
    !x = xsys
    !y = ysys
    !z = zsys

  ; redraw the plot
    replot_all, plotinfo, idinfo.plot_draw
  endif else begin
  ;do nothing

  endelse

end


pro ycplot_mouse_event, event, idinfo
; event.type = 0 --> button down
;            = 1 --> button up
;            = 2 --> button move

  if event.type eq 0 then $	;button down
    ycplot_mouse_button_down, event, idinfo

  if event.type eq 1 then $	;button up
    ycplot_mouse_button_up, event, idinfo

  if event.type eq 2 then $	;mouse move
    ycplot_mouse_button_move, event, idinfo

end


pro kill_ycplot_window, plotinfo, base_id, plot_draw_id
; free the pointer
  ptr_free, plotinfo.pdata

  widget_control, plot_draw_id, get_value = win
  wdelete, win

; destroy the window
  widget_control, base_id, /destroy

  print, 'ycplot (Plot ID: ' + string(base_id, format='(i0)') + '): Terminate ycplot window'
end


pro ycplot_event, event
; get base widget info
  widget_control, event.top, get_uvalue = idinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    kill_ycplot_window, plotinfo, idinfo.base, idinfo.plot_draw
    return
  endif

; event due to plot_setting_button
  if event.id eq idinfo.plot_setting_button then begin
  ;show the plot setting window
    show_plot_setting_window, idinfo
  endif

; event due to oplot_setting_button
  if event.id eq idinfo.oplot_setting_button then begin
  ;show the oplot setting window
    show_oplot_setting_window, idinfo
  endif

; event due to legend_setting_button
  if event.id eq idinfo.legend_setting_button then begin
  ;show the legend setting window
    show_legend_setting_window, idinfo
  endif

; event due to xyouts_setting_button
  if event.id eq idinfo.xyouts_setting_button then begin
  ;show the xyouts setting window
    show_xyouts_setting_window, idinfo
  endif

; event due to errbar_show_button
  if event.id eq idinfo.errbar_show_button then begin
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    plotinfo.plot_setting.show_errbar = widget_info(idinfo.errbar_show_button, /button_set)
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo

    replot_all, plotinfo, idinfo.plot_draw
  endif

; event due to save_figure_button
  if event.id eq idinfo.save_figure_button then begin
    filename = dialog_pickfile(dialog_parent = idinfo.base, $
                               title = 'Save figure...', $
                               filter = ['*.eps', '*.bmp', '*.gif', '*.png'], $
                               /fix_filter, /overwrite_prompt, /write)
    if filename ne '' then begin
    ; get the file extension
      file_extension = strmid(filename, strlen(filename)-4, 4)
      if ( (file_extension ne '.eps') and (file_extension ne '.bmp') and $
           (file_extension ne '.gif') and (file_extension ne '.png') ) then begin
        str = 'File extension is missing.' + string(10b) + 'Allowed extensions are *.eps, *.bmp, *.gif and *.png'
        error_box = dialog_message(str, /error, dialog_parent = idinfo.base)
      endif else begin
      ;get the window id
        widget_control, idinfo.plot_draw, get_value = win
        widget_control, idinfo.plot_draw, get_uvalue = plotinfo
        wset, win
        if file_extension eq '.eps' then begin
          sys = ps_init(filename, aspect = 1.0)
          replot_all, plotinfo, idinfo.plot_draw, /psplot
          dum = ps_restore(sys)
        endif else begin
        case file_extension of
          '.gif': export, filename, /gif
          '.png': export, filename, /png
          else: export, filename	;save as .bmp
        endcase
        endelse
      endelse
    endif
  endif

; event due to save_data_button
  if event.id eq idinfo.save_data_button then begin
    filename = dialog_pickfile(default_extension = 'sav', $
                               dialog_parent = idinfo.base, $
                               title = 'Save data...', $
                               filter = ['*.sav'], $
                               /fix_filter, /overwrite_prompt, /write)
    if filename ne '' then begin
      widget_control, idinfo.plot_draw, get_uvalue = plotinfo
      save, plotinfo, filename = filename
    endif
  endif


; event due to mouse motion on plot_draw
  if event.id eq idinfo.plot_draw then begin
    widget_control, idinfo.plot_draw, get_value = win
    wset, win

    ycplot_mouse_event, event, idinfo
  endif

end


;=================================================================
; legendd routine for yclpot
;=================================================================
;+
; NAME:
;       LEGEND
; PURPOSE:
;       Create an annotation legend for a plot.
; EXPLANATION:
;       This procedure makes a legend for a plot.  The legend can contain
;       a mixture of symbols, linestyles, Hershey characters (vectorfont),
;       and filled polygons (usersym).  A test procedure, legendtest.pro,
;       shows legend's capabilities.  Placement of the legend is controlled
;       with keywords like /right, /top, and /center or by using a position
;       keyword for exact placement (position=[x,y]) or via mouse (/position).
; CALLING SEQUENCE:
;       LEGEND [,items][,keyword options]
; EXAMPLES:
;       The call:
;               legend,['Plus sign','Asterisk','Period'],psym=[1,2,3]
;         produces:
;               -----------------
;               |               |
;               |  + Plus sign  |
;               |  * Asterisk   |
;               |  . Period     |
;               |               |
;               -----------------
;         Each symbol is drawn with a plots command, so they look OK.
;         Other examples are given in optional output keywords.
;
;       lines = indgen(6)                       ; for line styles
;       items = 'linestyle '+strtrim(lines,2)   ; annotations
;       legend,items,linestyle=lines            ; vertical legend---upper left
;       items = ['Plus sign','Asterisk','Period']
;       sym = [1,2,3]
;       legend,items,psym=sym                   ; ditto except using symbols
;       legend,items,psym=sym,/horizontal       ; horizontal format
;       legend,items,psym=sym,box=0             ; sans border
;       legend,items,psym=sym,delimiter='='     ; embed '=' betw psym & text
;       legend,items,psym=sym,margin=2          ; 2-character margin
;       legend,items,psym=sym,position=[x,y]    ; upper left in data coords
;       legend,items,psym=sym,pos=[x,y],/norm   ; upper left in normal coords
;       legend,items,psym=sym,pos=[x,y],/device ; upper left in device coords
;       legend,items,psym=sym,/position         ; interactive position
;       legend,items,psym=sym,/right            ; at upper right
;       legend,items,psym=sym,/bottom           ; at lower left
;       legend,items,psym=sym,/center           ; approximately near center
;       legend,items,psym=sym,number=2          ; plot two symbols, not one
;       legend,items,/fill,psym=[8,8,8],colors=[10,20,30]; 3 filled squares
; INPUTS:
;       items = text for the items in the legend, a string array.
;               For example, items = ['diamond','asterisk','square'].
;               You can omit items if you don't want any text labels.
; OPTIONAL INPUT KEYWORDS:
;
;       linestyle = array of linestyle numbers  If linestyle[i] < 0, then omit
;               ith symbol or line to allow a multi-line entry.     If 
;               linestyle = -99 then text will be left-justified.  
;       psym = array of plot symbol numbers.  If psym[i] is negative, then a
;               line connects pts for ith item.  If psym[i] = 8, then the
;               procedure usersym is called with vertices define in the
;               keyword usersym.   If psym[i] = 88, then use the previously
;               defined user symbol
;       vectorfont = vector-drawn characters for the sym/line column, e.g.,
;               ['!9B!3','!9C!3','!9D!3'] produces an open square, a checkmark,
;               and a partial derivative, which might have accompanying items
;               ['BOX','CHECK','PARTIAL DERIVATIVE'].
;               There is no check that !p.font is set properly, e.g., -1 for
;               X and 0 for PostScript.  This can produce an error, e.g., use
;               !20 with PostScript and !p.font=0, but allows use of Hershey
;               *AND* PostScript fonts together.
;       N. B.: Choose any of linestyle, psym, and/or vectorfont.  If none is
;               present, only the text is output.  If more than one
;               is present, all need the same number of elements, and normal
;               plot behaviour occurs.
;               By default, if psym is positive, you get one point so there is
;               no connecting line.  If vectorfont[i] = '',
;               then plots is called to make a symbol or a line, but if
;               vectorfont[i] is a non-null string, then xyouts is called.
;       /help = flag to print header
;       /horizontal = flag to make the legend horizontal
;       /vertical = flag to make the legend vertical (D=vertical)
;       box = flag to include/omit box around the legend (D=include)
;       clear = flag to clear the box area before drawing the legend
;       delimiter = embedded character(s) between symbol and text (D=none)
;       colors = array of colors for plot symbols/lines (D=!P.color)
;       textcolors = array of colors for text (D=!P.color)
;       margin = margin around text measured in characters and lines
;       spacing = line spacing (D=bit more than character height)
;       pspacing = psym spacing (D=3 characters) (when number of symbols is
;             greater than 1)
;       charsize = just like !p.charsize for plot labels
;       charthick = just like !p.charthick for plot labels
;       thick = array of line thickness numbers (D = !P.thick), if used, then 
;               linestyle must also be specified
;       position = data coordinates of the /top (D) /left (D) of the legend
;       normal = use normal coordinates for position, not data
;       device = use device coordinates for position, not data
;       number = number of plot symbols to plot or length of line (D=1)
;       usersym = 2-D array of vertices, cf. usersym in IDL manual. 
;             (/USERSYM =square, default is to use existing USERSYM definition)
;       /fill = flag to fill the usersym
;       /left_legend = flag to place legend snug against left side of plot
;                 window (D)
;       /right_legend = flag to place legend snug against right side of plot
;               window.    If /right,pos=[x,y], then x is position of RHS and
;               text runs right-to-left.
;       /top_legend = flag to place legend snug against top of plot window (D)
;       /bottom = flag to place legend snug against bottom of plot window
;               /top,pos=[x,y] and /bottom,pos=[x,y] produce same positions.
;
;       If LINESTYLE, PSYM, VECTORFONT, THICK, COLORS, or TEXTCOLORS are
;       supplied as scalars, then the scalar value is set for every line or
;       symbol in the legend.
; Outputs:
;       legend to current plot device
; OPTIONAL OUTPUT KEYWORDS:
;       corners = 4-element array, like !p.position, of the normalized
;         coords for the box (even if box=0): [llx,lly,urx,ury].
;         Useful for multi-column or multi-line legends, for example,
;         to make a 2-column legend, you might do the following:
;           c1_items = ['diamond','asterisk','square']
;           c1_psym = [4,2,6]
;           c2_items = ['solid','dashed','dotted']
;           c2_line = [0,2,1]
;           legend,c1_items,psym=c1_psym,corners=c1,box=0
;           legend,c2_items,line=c2_line,corners=c2,box=0,pos=[c1[2],c1[3]]
;           c = [c1[0]<c2[0],c1[1]<c2[1],c1[2]>c2[2],c1[3]>c2[3]]
;           plots,[c[0],c[0],c[2],c[2],c[0]],[c[1],c[3],c[3],c[1],c[1]],/norm
;         Useful also to place the legend.  Here's an automatic way to place
;         the legend in the lower right corner.  The difficulty is that the
;         legend's width is unknown until it is plotted.  In this example,
;         the legend is plotted twice: the first time in the upper left, the
;         second time in the lower right.
;           legend,['1','22','333','4444'],linestyle=indgen(4),corners=corners
;                       ; BOGUS LEGEND---FIRST TIME TO REPORT CORNERS
;           xydims = [corners[2]-corners[0],corners[3]-corners[1]]
;                       ; SAVE WIDTH AND HEIGHT
;           chdim=[!d.x_ch_size/float(!d.x_size),!d.y_ch_size/float(!d.y_size)]
;                       ; DIMENSIONS OF ONE CHARACTER IN NORMALIZED COORDS
;           pos = [!x.window[1]-chdim[0]-xydims[0] $
;                       ,!y.window[0]+chdim[1]+xydims[1]]
;                       ; CALCULATE POSITION FOR LOWER RIGHT
;           plot,findgen(10)    ; SIMPLE PLOT; YOU DO WHATEVER YOU WANT HERE.
;           legend,['1','22','333','4444'],linestyle=indgen(4),pos=pos
;                       ; REDO THE LEGEND IN LOWER RIGHT CORNER
;         You can modify the pos calculation to place the legend where you
;         want.  For example to place it in the upper right:
;           pos = [!x.window[1]-chdim[0]-xydims[0],!y.window[1]-xydims[1]]
; Common blocks:
;       none
; Procedure:
;       If keyword help is set, call doc_library to print header.
;       See notes in the code.  Much of the code deals with placement of the
;       legend.  The main problem with placement is not being
;       able to sense the length of a string before it is output.  Some crude
;       approximations are used for centering.
; Restrictions:
;       Here are some things that aren't implemented.
;       - An orientation keyword would allow lines at angles in the legend.
;       - An array of usersyms would be nice---simple change.
;       - An order option to interchange symbols and text might be nice.
;       - Somebody might like double boxes, e.g., with box = 2.
;       - Another feature might be a continuous bar with ticks and text.
;       - There are no guards to avoid writing outside the plot area.
;       - There is no provision for multi-line text, e.g., '1st line!c2nd line'
;         Sensing !c would be easy, but !c isn't implemented for PostScript.
;         A better way might be to simply output the 2nd line as another item
;         but without any accompanying symbol or linestyle.  A flag to omit
;         the symbol and linestyle is linestyle[i] = -1.
;       - There is no ability to make a title line containing any of titles
;         for the legend, for the symbols, or for the text.
; Side Effects:
; Modification history:
;       write, 24-25 Aug 92, F K Knight (knight@ll.mit.edu)
;       allow omission of items or omission of both psym and linestyle, add
;         corners keyword to facilitate multi-column legends, improve place-
;         ment of symbols and text, add guards for unequal size, 26 Aug 92, FKK
;       add linestyle(i)=-1 to suppress a single symbol/line, 27 Aug 92, FKK
;       add keyword vectorfont to allow characters in the sym/line column,
;         28 Aug 92, FKK
;       add /top, /bottom, /left, /right keywords for automatic placement at
;         the four corners of the plot window.  The /right keyword forces
;         right-to-left printing of menu. 18 Jun 93, FKK
;       change default position to data coords and add normal, data, and
;         device keywords, 17 Jan 94, FKK
;       add /center keyword for positioning, but it is not precise because
;         text string lengths cannot be known in advance, 17 Jan 94, FKK
;       add interactive positioning with /position keyword, 17 Jan 94, FKK
;       allow a legend with just text, no plotting symbols.  This helps in
;         simply describing a plot or writing assumptions done, 4 Feb 94, FKK
;       added thick, symsize, and clear keyword Feb 96, W. Landsman HSTX
;               David Seed, HR Wallingford, d.seed@hrwallingford.co.uk
;       allow scalar specification of keywords, Mar 96, W. Landsman HSTX
;       added charthick keyword, June 96, W. Landsman HSTX
;       Made keyword names  left,right,top,bottom,center longer,
;                                 Aug 16, 2000, Kim Tolbert
;       Added ability to have regular text lines in addition to plot legend 
;       lines in legend.  If linestyle is -99 that item is left-justified.
;       Previously, only option for no sym/line was linestyle=-1, but then text
;       was lined up after sym/line column.    10 Oct 2000, Kim Tolbert
;       Make default value of thick = !P.thick  W. Landsman  Jan. 2001
;       Don't overwrite existing USERSYM definition  W. Landsman Mar. 2002
;-
pro legendd_ycplot, items, BOTTOM_LEGEND=bottom, BOX = box, CENTER_LEGEND=center, $
    CHARTHICK=charthick, CHARSIZE = charsize, CLEAR = clear, COLORS = colorsi, $
    CORNERS = corners, DATA=data, DELIMITER=delimiter, DEVICE=device, $
    FILL=fill, HELP = help, HORIZONTAL=horizontal,LEFT_LEGEND=left, $
    LINESTYLE=linestylei, MARGIN=margin, NORMAL=normal, NUMBER=number, $
    POSITION=position,PSPACING=pspacing, PSYM=psymi, RIGHT_LEGEND=right, $
    SPACING=spacing, SYMSIZE=symsize, TEXTCOLORS=textcolorsi, THICK=thicki, $
    TOP_LEGEND=top, USERSYM=usersym,  VECTORFONT=vectorfonti, VERTICAL=vertical
;
;       =====>> HELP
;

on_error,2
if keyword_set(help) then begin & doc_library,'legend' & return & endif
;
;       =====>> SET DEFAULTS FOR SYMBOLS, LINESTYLES, AND ITEMS.
;
 ni = n_elements(items)
 np = n_elements(psymi)
 nl = n_elements(linestylei)
 nth = n_elements(thicki)
 nv = n_elements(vectorfonti)
 nlpv = max([np,nl,nv])
 n = max([ni,np,nl,nv])                                  ; NUMBER OF ENTRIES
strn = strtrim(n,2)                                     ; FOR ERROR MESSAGES
if n eq 0 then message,'No inputs!  For help, type legend,/help.'
if ni eq 0 then begin
  items = replicate('',n)                               ; DEFAULT BLANK ARRAY
endif else begin
  if size(items,/TNAME) NE 'STRING' then message, $
      'First parameter must be a string array.  For help, type legend,/help.'
  if ni ne n then message,'Must have number of items equal to '+strn
endelse
symline = (np ne 0) or (nl ne 0)                        ; FLAG TO PLOT SYM/LINE
 if (np ne 0) and (np ne n) and (np NE 1) then message, $
        'Must have 0, 1 or '+strn+' elements in PSYM array.'
 if (nl ne 0) and (nl ne n) and (nl NE 1) then message, $
         'Must have 0, 1 or '+strn+' elements in LINESTYLE array.'
 if (nth ne 0) and (nth ne n) and (nth NE 1) then message, $
         'Must have 0, 1 or '+strn+' elements in THICK array.'

 case nl of 
 0: linestyle = intarr(n)              ;Default = solid
 1: linestyle = intarr(n)  + linestylei
 else: linestyle = linestylei
 endcase 
 
 case nth of 
 0: thick = replicate(!p.thick,n)      ;Default = !P.THICK
 1: thick = intarr(n) + thicki
 else: thick = thicki
 endcase 

 case np of             ;Get symbols
 0: psym = intarr(n)    ;Default = solid
 1: psym = intarr(n) + psymi
 else: psym = psymi
 endcase 

 case nv of 
 0: vectorfont = replicate('',n)
 1: vectorfont = replicate(vectorfonti,n)
 else: vectorfont = vectorfonti
 endcase 
;
;       =====>> CHOOSE VERTICAL OR HORIZONTAL ORIENTATION.
;
if n_elements(horizontal) eq 0 then begin               ; D=VERTICAL
  if n_elements(vertical) eq 0 then vertical = 1
endif else begin
  if n_elements(vertical) eq 0 then vertical = not horizontal
endelse
;
;       =====>> SET DEFAULTS FOR OTHER OPTIONS.
;
if n_elements(box) eq 0 then box = 1
if n_elements(clear) eq 0 then clear = 0

if n_elements(margin) eq 0 then margin = 0.5
if n_elements(delimiter) eq 0 then delimiter = ''
if n_elements(charsize) eq 0 then charsize = !p.charsize
if n_elements(charthick) eq 0 then charthick = !p.charthick
if charsize eq 0 then charsize = 1
if (n_elements (symsize) eq 0) then symsize= charsize + intarr(n)
if n_elements(number) eq 0 then number = 1
 case N_elements(colorsi) of 
 0: colors = replicate(!P.color,n)     ;Default is !P.COLOR
 1: colors = replicate(colorsi,n)
 else: colors = colorsi
 endcase 

 case N_elements(textcolorsi) of 
 0: textcolors = replicate(!P.color,n)      ;Default is !P.COLOR
 1: textcolors = replicate(textcolorsi,n)
 else: textcolors = textcolorsi
 endcase 
 fill = keyword_set(fill)
if n_elements(usersym) eq 1 then usersym = 2*[[0,0],[0,1],[1,1],[1,0],[0,0]]-1
;
;       =====>> INITIALIZE SPACING
;
if n_elements(spacing) eq 0 then spacing = 1.2
if n_elements(pspacing) eq 0 then pspacing = 3
xspacing = !d.x_ch_size/float(!d.x_size) * (spacing > charsize)
yspacing = !d.y_ch_size/float(!d.y_size) * (spacing > charsize)
ltor = 1                                        ; flag for left-to-right
if n_elements(left) eq 1 then ltor = left eq 1
if n_elements(right) eq 1 then ltor = right ne 1
ttob = 1                                        ; flag for top-to-bottom
if n_elements(top) eq 1 then ttob = top eq 1
if n_elements(bottom) eq 1 then ttob = bottom ne 1
xalign = ltor ne 1                              ; x alignment: 1 or 0
yalign = -0.5*ttob + 1                          ; y alignment: 0.5 or 1
xsign = 2*ltor - 1                              ; xspacing direction: 1 or -1
ysign = 2*ttob - 1                              ; yspacing direction: 1 or -1
if not ttob then yspacing = -yspacing
if not ltor then xspacing = -xspacing
;
;       =====>> INITIALIZE POSITIONS: FIRST CALCULATE X OFFSET FOR TEXT
;
xt = 0
if nlpv gt 0 then begin                         ; SKIP IF TEXT ITEMS ONLY.
if vertical then begin                          ; CALC OFFSET FOR TEXT START
  for i = 0,n-1 do begin
    if (psym[i] eq 0) and (vectorfont[i] eq '') then num = (number + 1) > 3 else num = number
    if psym[i] lt 0 then num = number > 2       ; TO SHOW CONNECTING LINE
    if psym[i] eq 0 then expand = 1 else expand = 2
    thisxt = (expand*pspacing*(num-1)*xspacing)
    if ltor then xt = thisxt > xt else xt = thisxt < xt
    endfor
endif   ; NOW xt IS AN X OFFSET TO ALIGN ALL TEXT ENTRIES.
endif
;
;       =====>> INITIALIZE POSITIONS: SECOND LOCATE BORDER
;
if !x.window[0] eq !x.window[1] then begin
  plot,/nodata,xstyle=4,ystyle=4,[0],/noerase
endif
;       next line takes care of weirdness with small windows
pos = [min(!x.window),min(!y.window),max(!x.window),max(!y.window)]
case n_elements(position) of
 0: begin
  if ltor then px = pos[0] else px = pos[2]
  if ttob then py = pos[3] else py = pos[1]
  if keyword_set(center) then begin
    if not keyword_set(right) and not keyword_set(left) then $
      px = (pos[0] + pos[2])/2. - xt
    if not keyword_set(top) and not keyword_set(bottom) then $
      py = (pos[1] + pos[3])/2. + n*yspacing
    endif
  position = [px,py] + [xspacing,-yspacing]
  end
 1: begin       ; interactive
  message,/inform,'Place mouse at upper left corner and click any mouse button.'
  cursor,x,y,/normal
  position = [x,y]
  end
 2: begin       ; convert upper left corner to normal coordinates
  if keyword_set(data) then $
    position = convert_coord(position,/to_norm) $
  else if keyword_set(device) then $
    position = convert_coord(position,/to_norm,/device) $
  else if not keyword_set(normal) then $
    position = convert_coord(position,/to_norm)
  end
 else: message,'Position keyword can have 0, 1, or 2 elements only. Try legend,/help.'
endcase

yoff = 0.25*yspacing*ysign                      ; VERT. OFFSET FOR SYM/LINE.

x0 = position[0] + (margin)*xspacing            ; INITIAL X & Y POSITIONS
y0 = position[1] - margin*yspacing + yalign*yspacing    ; WELL, THIS WORKS!
;
;       =====>> OUTPUT TEXT FOR LEGEND, ITEM BY ITEM.
;       =====>> FOR EACH ITEM, PLACE SYM/LINE, THEN DELIMITER,
;       =====>> THEN TEXT---UPDATING X & Y POSITIONS EACH TIME.
;       =====>> THERE ARE A NUMBER OF EXCEPTIONS DONE WITH IF STATEMENTS.
;
for iclr = 0,clear do begin
  y = y0                                                ; STARTING X & Y POSITIONS
  x = x0
  if ltor then xend = 0 else xend = 1           ; SAVED WIDTH FOR DRAWING BOX

 if ttob then ii = [0,n-1,1] else ii = [n-1,0,-1]
 for i = ii[0],ii[1],ii[2] do begin
  if vertical then x = x0 else y = y0           ; RESET EITHER X OR Y
  x = x + xspacing                              ; UPDATE X & Y POSITIONS
  y = y - yspacing
  if nlpv eq 0 then goto,TEXT_ONLY              ; FLAG FOR TEXT ONLY
  if (psym[i] eq 0) and (vectorfont[i] eq '') then num = (number + 1) > 3 else num = number
  if psym[i] lt 0 then num = number > 2         ; TO SHOW CONNECTING LINE
  if psym[i] eq 0 then expand = 1 else expand = 2
  xp = x + expand*pspacing*indgen(num)*xspacing
  if (psym[i] gt 0) and (num eq 1) and vertical then xp = x + xt/2.
  yp = y + intarr(num)
  if vectorfont[i] eq '' then yp = yp + yoff
  if psym[i] eq 0 then begin
    xp = [min(xp),max(xp)]                      ; TO EXPOSE LINESTYLES
    yp = [min(yp),max(yp)]                      ; DITTO
    endif
  if (psym[i] eq 8) and (N_elements(usersym) GT 1) then $
                usersym,usersym,fill=fill,color=colors[i]
;; extra by djseed .. psym=88 means use the already defined usersymbol
 if psym[i] eq 88 then psym[i] =8
  if vectorfont[i] ne '' then begin
;    if (num eq 1) and vertical then xp = x + xt/2      ; IF 1, CENTERED.
    xyouts,xp,yp,vectorfont[i],width=width,color=colors[i] $
      ,size=charsize,align=xalign,charthick = charthick,/norm
    xt = xt > width
    xp = xp + width/2.
  endif else begin
    if symline and (linestyle[i] ge 0) then plots,xp,yp,color=colors[i] $
      ,/normal,linestyle=linestyle[i],psym=psym[i],symsize=symsize[i], $
      thick=thick[i]
  endelse

  if vertical then x = x + xt else if ltor then x = max(xp) else x = min(xp)
  if symline then x = x + xspacing
  TEXT_ONLY:
  if vertical and (vectorfont[i] eq '') and symline and (linestyle[i] eq -99) then x=x0 + xspacing
  xyouts,x,y,delimiter,width=width,/norm,color=textcolors[i], $
         size=charsize,align=xalign,charthick = charthick
  x = x + width*xsign
  if width ne 0 then x = x + 0.5*xspacing
  xyouts,x,y,items[i],width=width,/norm,color=textcolors[i],size=charsize, $
             align=xalign,charthick=charthick
  x = x + width*xsign
  if not vertical and (i lt (n-1)) then x = x+2*xspacing; ADD INTER-ITEM SPACE
  xfinal = (x + xspacing*margin)
  if ltor then xend = xfinal > xend else xend = xfinal < xend   ; UPDATE END X
 endfor

 if (iclr lt clear ) then begin
;       =====>> CLEAR AREA
        x = position[0]
        y = position[1]
        if vertical then bottom = n else bottom = 1
        ywidth = - (2*margin+bottom-0.5)*yspacing
        corners = [x,y+ywidth,xend,y]
        polyfill,[x,xend,xend,x,x],y + [0,0,ywidth,ywidth,0],/norm,color=-1
;       plots,[x,xend,xend,x,x],y + [0,0,ywidth,ywidth,0],thick=2
 endif else begin

;
;       =====>> OUTPUT BORDER
;
        x = position[0]
        y = position[1]
        if vertical then bottom = n else bottom = 1
        ywidth = - (2*margin+bottom-0.5)*yspacing
        corners = [x,y+ywidth,xend,y]
        if box then plots,[x,xend,xend,x,x],y + [0,0,ywidth,ywidth,0],/norm
        return
 endelse
endfor

end






;=================================================================
; oploterror routine for yclpot
;=================================================================

PRO  oploterror_ycplot, x, y, xerr, yerr, NOHAT=hat, HATLENGTH=hln, ERRTHICK=eth, $
      ERRSTYLE=est, THICK = thick, NOCLIP=noclip, ERRCOLOR = ecol, Nsum = nsum,$
      NSKIP=nskip, LOBAR=lobar, HIBAR=hibar,_EXTRA = pkey
;+
; NAME:
;      OPLOTERROR
; PURPOSE:
;      Over-plot data points with accompanying X or Y error bars.
; EXPLANATION:
;      For use instead of PLOTERROR when the plotting system has already been
;      defined. 
;
; CALLING SEQUENCE:
;      oploterror, [ x,]  y, [xerr], yerr,   
;            [ /NOHAT, HATLENGTH= , ERRTHICK =, ERRSTYLE=, ERRCOLOR =, 
;              /LOBAR, /HIBAR, NSKIP = , NSUM = , ... OPLOT keywords ]
; INPUTS:
;      X = array of abcissae, any datatype except string
;      Y = array of Y values, any datatype except string
;      XERR = array of error bar values (along X)
;      YERR = array of error bar values (along Y)
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;      /NOHAT     = if specified and non-zero, the error bars are drawn
;                  without hats.
;      HATLENGTH = the length of the hat lines used to cap the error bars.
;                  Defaults to !D.X_VSIZE / 100).
;      ERRTHICK  = the thickness of the error bar lines.  Defaults to the
;                  THICK plotting keyword.
;      ERRSTYLE  = the line style to use when drawing the error bars.  Uses
;                  the same codes as LINESTYLE.
;      ERRCOLOR =  scalar integer (0 - !D.N_TABLE) specifying the color to
;                  use for the error bars
;      NSKIP = Positive Integer specifying the error bars to be plotted.   
;            For example, if NSKIP = 2 then every other error bar is 
;            plotted; if NSKIP=3 then every third error bar is plotted.   
;            Default is to plot every error bar (NSKIP = 1)
;      NSUM =  Number of points to average over before plotting, default = 
;             !P.NSUM  The errors are also averaged, and then divided by 
;             sqrt(NSUM).   This approximation is meaningful only when the 
;             neighboring error bars have similar sizes.
; 
;      /LOBAR = if specified and non-zero, will draw only the -ERR error bars.
;      /HIBAR = if specified and non-zero, will draw only the +ERR error bars.
;                  If neither LOBAR or HIBAR are set _or_ if both are set,
;                  you will get both error bars.  Just specify one if you
;                  only want one set.
;     Any valid keywords to the OPLOT command (e.g. PSYM, YRANGE) are also 
;     accepted by OPLOTERROR via the _EXTRA facility.
;
; NOTES:
;     If only two parameters are input, they are taken as Y and YERR.  If only
;     three parameters are input, they will be taken as X, Y and YERR, 
;     respectively.
;
; EXAMPLE:
;      Suppose one has X and Y vectors with associated errors XERR and YERR
;      and that a plotting system has already been defined:
;
;       (1) Overplot Y vs. X with both X and Y errors and no lines connecting
;           the points
;                  IDL> oploterror, x, y, xerr, yerr, psym=3
;
;       (2) Like (1) but overplot only the Y errors bars and omits "hats"
;                  IDL> oploterror, x, y, yerr, psym=3, /NOHAT
;
;       (3) Like (2) but suppose one has a positive error vector YERR1, and 
;               a negative error vector YERR2 (asymmetric error bars)
;                  IDL> oploterror, x, y, yerr1, psym=3, /NOHAT,/HIBAR
;                  IDL> oploterror, x, y, yerr2, psym=3, /NOHAT,/LOBAR
;
; PROCEDURE:
;      A plot of X versus Y with error bars drawn from Y - YERR to Y + YERR
;      and optionally from X - XERR to X + XERR is written to the output device
;
; WARNING:
;      This an enhanced version of the procedure OPLOTERR in the standard RSI
;      library.    It was renamed to OPLOTERROR in June 1998 in the IDL 
;      Astronomy library.
;
; MODIFICATION HISTORY:
;      Adapted from the most recent version of PLOTERR.  M. R. Greason,
;            Hughes STX, 11 August 1992.
;      Added COLOR keyword option to error bars W. Landsman   November 1993
;      Add ERRCOLOR, use _EXTRA keyword,           W. Landsman, July 1995
;      Remove spurious call to PLOT_KEYWORDS     W. Landsman, August 1995
;      OPLOT more than 32767 error bars          W. Landsman, Feb 1996
;      Added NSKIP keyword                       W. Landsman, Dec 1996
;      Added HIBAR and LOBAR keywords, M. Buie, Lowell Obs., Feb 1998
;      Rename to OPLOTERROR    W. Landsman    June 1998
;      Ignore !P.PSYM when drawing error bars   W. Landsman   Jan 1999
;      Handle NSUM keyword correctly           W. Landsman    Aug 1999
;      Check limits for logarithmic axes       W. Landsman    Nov. 1999
;      Work in the presence of  NAN values     W. Landsman    Dec 2000
;      Improve logic when NSUM or !P.NSUM is set  W. Landsman      Jan 2001
;      Remove NSUM keyword from PLOTS call    W. Landsman      March 2001
;      Only draw error bars with in XRANGE (for speed)  W. Landsman Jan 2002
;      Fix Jan 2002 update to work with log plots  W. Landsman Jun 2002
;      Added STRICT_EXTRA keyword   W. Landsman     July 2005
;      W. Landsman Fixed case of logarithmic axes reversed Mar 2009
;-
;                  Check the parameters.
;
 On_error, 2
 compile_opt idl2
 np = N_params()
 IF (np LT 2) THEN BEGIN
      print, "OPLOTERR must be called with at least two parameters."
      print, "Syntax: oploterr, [x,] y, [xerr], yerr, [..oplot keywords... "
      print,'     /NOHAT, HATLENGTH = , ERRTHICK=, ERRSTLYE=, ERRCOLOR='
      print,'     /LOBAR, /HIBAR, NSKIP= ]'
      RETURN
 ENDIF

; Error bar keywords (except for HATLENGTH; this one will be taken care of 
; later, when it is time to deal with the error bar hats).

 IF (keyword_set(hat)) THEN hat = 0 ELSE hat = 1
 if not keyword_set(THICK) then thick = !P.THICK
 IF (n_elements(eth) EQ 0) THEN eth = thick
 IF (n_elements(est) EQ 0) THEN est = 0
 IF (n_elements(ecol) EQ 0) THEN ecol = !P.COLOR
 if N_elements( NOCLIP ) EQ 0 THEN noclip = 0
 if not keyword_set(NSKIP) then nskip = 1
 if N_elements(nsum) EQ 0 then nsum = !P.NSUM
 if not keyword_set(lobar) and not keyword_set(hibar) then begin
      lobar=1
      hibar=1
 endif else if keyword_set(lobar) and keyword_set(hibar) then begin
      lobar=1
      hibar=1
 endif else if keyword_set(lobar) then begin
      lobar=1
      hibar=0
 endif else begin
      lobar=0
      hibar=1
 endelse
;
; If no X array has been supplied, create one.  Make sure the rest of the 
; procedure can know which parameter is which.
;
 IF np EQ 2 THEN BEGIN                  ; Only Y and YERR passed.
      yerr = y
      yy = x
      xx = indgen(n_elements(yy))
      xerr = make_array(size=size(xx))

 ENDIF ELSE IF np EQ 3 THEN BEGIN       ; X, Y, and YERR passed.
        yerr = xerr
        yy = y
        xx = x

 ENDIF ELSE BEGIN                        ; X, Y, XERR and YERR passed.
      yy = y
      g = where(finite(xerr))
      xerr[g] = abs(xerr[g])
      xx = x
 ENDELSE

 g = where(finite(yerr))
 yerr[g] = abs(yerr[g])

;
;                  Determine the number of points being plotted.  This
;                  is the size of the smallest of the three arrays
;                  passed to the procedure.  Truncate any overlong arrays.
;

 n = N_elements(xx) < N_elements(yy)

 IF np GT 2 then n = n < N_elements(yerr)   
 IF np EQ 4 then n = n < N_elements(xerr)

 xx = xx[0:n-1]
 yy = yy[0:n-1]
 yerr = yerr[0:n-1]
 IF np EQ 4 then xerr = xerr[0:n-1]

; If NSUM is greater than one, then we need to smooth ourselves (using FREBIN)

 if NSum GT 1 then begin
      n1 = float(n) / nsum
      n  = long(n1)
      xx = frebin(xx, n1)
      yy = frebin(yy, n1)
      yerror = frebin(yerr,n1)/sqrt(nsum)
      if NP EQ 4 then xerror = frebin(xerr,n1)/sqrt(nsum)
  endif else begin
      yerror = yerr
      if NP EQ 4 then xerror = xerr
  endelse

 ylo = yy - yerror*lobar
 yhi = yy + yerror*hibar

 if Np EQ 4 then begin
     xlo = xx - xerror*lobar
     xhi = xx + xerror*hibar
 endif
;
;                  Plot the positions.
;
 if n NE 1 then begin
     oplot, xx, yy, NOCLIP=noclip,THICK = thick,_STRICT_EXTRA = pkey 
 endif else begin 
     plots, xx, yy, NOCLIP=noclip,THICK = thick,_STRICT_EXTRA = pkey
 endelse
;
; Plot the error bars.   Compute the hat length in device coordinates
; so that it remains fixed even when doing logarithmic plots.
;
 data_low = convert_coord(xx,ylo,/TO_DEVICE)
 data_hi = convert_coord(xx,yhi,/TO_DEVICE)
 if NP EQ 4 then begin
    x_low = convert_coord(xlo,yy,/TO_DEVICE)
    x_hi = convert_coord(xhi,yy,/TO_DEVICE)
 endif
 
 ycrange = !Y.CRANGE   &  xcrange = !X.CRANGE
   if !Y.type EQ 1 then ylo = ylo > 10^min(ycrange)    
	                    
    if (!X.type EQ 1) and (np EQ 4) then xlo = xlo > 10^min(xcrange) 

 sv_psym = !P.PSYM & !P.PSYM = 0     ;Turn off !P.PSYM for error bars
; Only draw error bars for X values within XCRANGE
    if !X.TYPE EQ 1 then xcrange = 10^xcrange
    g = where((xx GT xcrange[0]) and (xx LE xcrange[1]), Ng)
    if (Ng GT 0) and (Ng NE n) then begin  
          istart = min(g, max = iend)  
    endif else begin
          istart = 0L & iend = n-1
    endelse
    
 FOR i = istart, iend, Nskip DO BEGIN

    plots, [xx[i],xx[i]], [ylo[i],yhi[i]], LINESTYLE=est,THICK=eth,  $
           NOCLIP = noclip, COLOR = ecol

    ; Plot X-error bars 
    ;
    if np EQ 4 then $
       plots, [xlo[i],xhi[i]],[yy[i],yy[i]],LINESTYLE=est, $
              THICK=eth, COLOR = ecol, NOCLIP = noclip

    IF (hat NE 0) THEN BEGIN
       IF (N_elements(hln) EQ 0) THEN hln = !D.X_VSIZE/100. 
       exx1 = data_low[0,i] - hln/2.
       exx2 = exx1 + hln
       if lobar then $
          plots, [exx1,exx2], [data_low[1,i],data_low[1,i]],COLOR=ecol, $
                 LINESTYLE=est,THICK=eth,/DEVICE, noclip = noclip
       if hibar then $
          plots, [exx1,exx2], [data_hi[1,i],data_hi[1,i]], COLOR = ecol,$
                 LINESTYLE=est,THICK=eth,/DEVICE, noclip = noclip
;                                          
       IF np EQ 4 THEN BEGIN
          IF (N_elements(hln) EQ 0) THEN hln = !D.Y_VSIZE/100.
             eyy1 = x_low[1,i] - hln/2.
             eyy2 = eyy1 + hln
             if lobar then $
                plots, [x_low[0,i],x_low[0,i]], [eyy1,eyy2],COLOR = ecol, $
                       LINESTYLE=est,THICK=eth,/DEVICE, NOCLIP = noclip
             if hibar then $
                plots, [x_hi[0,i],x_hi[0,i]], [eyy1,eyy2],COLOR = ecol, $
                       LINESTYLE=est,THICK=eth,/DEVICE, NOCLIP = noclip
          ENDIF
       ENDIF
    NOPLOT:
ENDFOR
 !P.PSYM = sv_psym 
;
RETURN
END








;=================================================================
; Main-routine for yclpot
;=================================================================

pro ycplot,  xdata, ydata, error = in_error, $
             oplot_id = in_oplot_id, saved_file = in_saved_file, $
             title = in_title, xtitle = in_xtitle, ytitle = in_ytitle, xlog = in_xlog, ylog = in_ylog, $
             xsize = in_xsize, ysize = in_ysize, legend_item = in_legend_item, $
             description = in_description, note = in_note, $
             out_base_id = out_base_id

  MAX_NUM_PLOT = 50
  MAX_NUM_XYOUTS = 50
  version = 1.0
  prog_name = 'ycplot'

  if keyword_set(in_saved_file) then begin
    saved_file = in_saved_file
    restore, saved_file
    if( plotinfo.version ne version ) then begin
      print, 'The saved_file is created with INCOMPATIBLE version of ycplot.  Exit the program.'
      return
    endif
    if( plotinfo.prog_name ne prog_name) then begin
      print, 'The saved_file is NOT created by ycplot.  Exit the program.'
      return
    endif
    print, 'If values of x, y, error and/or oplot_id were provided, they will be ignored.'
    goto, start_widget
  endif


;====== check the x and y data =======
  npar = n_params()
  if npar eq 0 then begin
  ; no data are specified.  
    print, 'No data are specified.  Exit the program.'
    return
  endif else if npar eq 1 then begin	
  ;only x is specified.  Set, the speficied x value as y, then create x as an array of index
    if defined(xdata) eq 0 then begin
      print, 'Data must be in 1-D array. Exit the program.'
      return
    endif
    y = reform(xdata)
    y_size = size(y)
    if y_size[0] ne 1 then begin	;check number of dimensions in y
      print, 'Data must be in 1-D array.  Exit the program.'
      return
    endif
    ny = y_size[1]	;number of elements in y
    nx = ny
    x = findgen(nx)
  endif else begin
  ;x and y are specified, check the number of data
    if ( defined(xdata) eq 0 ) or ( defined(ydata) eq 0 ) then begin
      print, 'Data must be in 1-D array. Exit the pgoram.'
      return
    endif
    x = reform(xdata)
    y = reform(ydata)
    x_size = size(x)
    y_size = size(y)
    if ( (x_size[0] ne 1) or (y_size[0] ne 1) ) then begin
      print, 'Data must be in 1-D array.  Exit the program.'
      return
    endif
    nx = x_size[1]
    ny = y_size[1]
    if (nx ne ny) then begin
      print, 'Number of elements in x and y are not equal. Exit the program.'
      return
    endif
  endelse


;====== check the error keyword =======
  if not keyword_set(in_error) then begin
    errbar_exist = 0
    hi_err = 0
    lo_err = 0
  endif else begin
    error = reform(in_error)
    err_size = size(error)
    if (err_size[0] eq 1) then begin
      nerr = err_size[1]
      if (nerr ne ny) then begin
        print, 'Number of elements in error is not equal to number of elements in y.  Exit the program.'
        return
      endif
      hi_err = error
      lo_err = error
    endif else if (err_size[0] eq 2) then begin
      nerr = err_size[2]
      if (nerr ne ny) then begin
        print, 'Number of elements in error is not equal to number of elements in y.  Exit the program.'
        return
      endif
      hi_err = reform(error[0, *])
      lo_err = reform(error[1, *])
    endif else begin
      print, 'Error must be 1-D or 2-D array.  Exit the program.'
      return
    endelse
    errbar_exist = 1
  endelse


;====== set the color table =======
  color_table_str = ['black', $
                     'crimson', $
                     'blue', $
                     'green', $
                     'dark cyan', $
                     'magenta', $
                     'orange red', $
                     'dark olive green', $
                     'indigo', $
                     'dark golden rod']

  color_table = [ truecolor('black'), $
                  truecolor('crimson'), $
                  truecolor('blue'), $
                  truecolor('green'), $
                  truecolor('darkcyan'), $
                  truecolor('magenta'), $
                  truecolor('orangered'), $
                  truecolor('darkolivegreen'), $
                  truecolor('indigo'), $
                  truecolor('darkgoldenrod') ]

  ncolor_table = n_elements(color_table)

;====== create the plotdata structure =======
  if keyword_set(in_oplot_id) then begin
    oplot_id = in_oplot_id
  ; over plot setting
  ; get the  idinfo and plotinfo
    widget_control, oplot_id, bad_id = bad_id, get_uvalue = idinfo
    if bad_id ne 0 then begin
      print, 'Bad oplot_id is specified.'
      return
    endif
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo

    if ( (plotinfo.num_plot + 1) gt MAX_NUM_PLOT ) then begin
      print, 'Maximum allowable oplot number is exceeded.'
      return
    endif

    data = {x:x, y:y, hi_err:hi_err, lo_err:lo_err, errbar_exist:errbar_exist}
    plotinfo.pdata[plotinfo.num_plot] = ptr_new(data)

    if not keyword_set(in_legend_item) then $
      legend_item = '' $
    else $
      legend_item = in_legend_item

    if legend_item ne '' then begin
      plotinfo.legend_setting.item[plotinfo.num_plot] = legend_item
    endif
    plotinfo.num_plot = plotinfo.num_plot + 1

  ; recalcualte the xrange and yrange
    xmin1 = plotinfo.plot_setting.xrange[0]
    xmax1 = plotinfo.plot_setting.xrange[1]
    ymin1 = plotinfo.plot_setting.yrange[0]
    ymax1 = plotinfo.plot_setting.yrange[1]
    xmin2 = min(x, max = xmax2)
    ymin2 = min(y, max = ymax2)
    plotinfo.plot_setting.xrange = [min([xmin1, xmin2]), max([xmax1, xmax2])] 
    plotinfo.plot_setting.yrange = [min([ymin1, ymin2]), max([ymax1, ymax2])]
  ;set user values
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo

  ;need to destroy the currently opened window and recreate the oplot and legend setting windows
    kill_plot_setting_window, idinfo, plotinfo
    kill_oplot_setting_window, idinfo
    kill_legend_setting_window, idinfo
    kill_xyouts_setting_window, idinfo

    replot_all, plotinfo, idinfo.plot_draw
;    plot_one, plotinfo, idinfo.plot_draw, plotinfo.num_plot-1

  endif else begin	;new plot setting
  ;check other keywords =======
    if not keyword_set(in_title) then $
      title = 'y vs. x' $
    else $
      title = in_title

    if not keyword_set(in_xtitle) then $
      xtitle = 'x' $
    else $
      xtitle = in_xtitle

    if not keyword_set(in_ytitle) then $
      ytitle = 'y' $
    else $
      ytitle = in_ytitle

    if not keyword_set(in_xlog) then $
      xlog = 0 $
    else $
      xlog = 1

    if not keyword_set(in_ylog) then $
      ylog = 0 $
    else $
      ylog = 1

    if not keyword_set(in_description) then $
      description = '' $
    else $
      description = in_description

    if not keyword_set(in_note) then $
      note = '' $
    else $
      note = in_note

    if not keyword_set(in_legend_item) then $
      legend_item = '' $
    else $
      legend_item = in_legend_item

    pdata = ptrarr(MAX_NUM_PLOT)
    data = {x:x, y:y, hi_err:hi_err, lo_err:lo_err, errbar_exist:errbar_exist}
    pdata[0] = ptr_new(data)
    num_plot = 1

    plot_setting = {title:title, $
                    xtitle:xtitle, $
                    ytitle:ytitle, $
                    xstyle:1, $
                    ystyle:1, $
                    xrange:float([min(x, /nan), max(x, /nan)]), $
                    yrange:float([min(y, /nan), max(y, /nan)]), $
                    xlog:xlog, $
                    ylog:ylog, $
                    xlog_combo_temp:xlog, $
                    ylog_combo_temp:ylog, $
                    isotropic:0, $
                    charsize:1.0, $
                    charthick:1.0, $
                    show_errbar:errbar_exist}
    line_setting = {thick:fltarr(MAX_NUM_PLOT)+1.0, $
                    style:fix(indgen(MAX_NUM_PLOT)/ncolor_table), $
                    color:color_table[(indgen(MAX_NUM_PLOT) mod ncolor_table)], $
                    symbol:intarr(MAX_NUM_PLOT), $
                    sym_size:fltarr(MAX_NUM_PLOT)+1.0, $
                    color_table:color_table, $
                    color_table_str:color_table_str}
    sys_var = {p:!p, $
               x:!x, $
               y:!y, $
               z:!z}
    legend_position = {left:1, right:0, top:1, bottom:0}
    legend_setting = {item:['Line ' + string(indgen(MAX_NUM_PLOT)+1, format='(i0)')], $
                      show_legend:0, position:legend_position}
    if legend_item ne '' then begin
      legend_setting.item[0] = legend_item
      legend_setting.show_legend = 1
    endif

    xyouts_position = {x:fltarr(MAX_NUM_XYOUTS), y:fltarr(MAX_NUM_XYOUTS)}
    xyouts_setting = {text:strarr(MAX_NUM_XYOUTS), $
                      position:xyouts_position, $
                      charsize:fltarr(MAX_NUM_XYOUTS)+1.0, $
                      charthick:fltarr(MAX_NUM_XYOUTS)+1.0, $
                      color:color_table[intarr(MAX_NUM_XYOUTS)], $
                      orientation:fltarr(MAX_NUM_XYOUTS), $
                      show_xyouts:0, $
                      MAX_NUM_XYOUTS:MAX_NUM_XYOUTS}
    plotinfo = {pdata:pdata, $
                num_plot:num_plot, $
                plot_setting:plot_setting, $
                line_setting:line_setting, $
                sys_var:sys_var, $
                legend_setting:legend_setting, $
                xyouts_setting:xyouts_setting, $
                description:description, $
                note:note, $
                version:version, $
                prog_name:prog_name}

start_widget:

  ; create widget
    if keyword_set(in_xsize) then begin
      xsize = in_xsize
      if xsize lt 640 then $
        xsize = 640
    endif else begin
      xsize = 640
    endelse

    if keyword_set(in_ysize) then begin
      ysize = in_ysize
      if ysize lt 480 then $
        ysize = 480
    endif else begin
      ysize = 480
    endelse

    window_title = 'ycplot Version ' + strcompress(string(plotinfo.version, format='(f3.1)'), /remove_all)
    base = widget_base(/column, title = window_title, /tlb_kill_request_events)
    widget_control, base, base_set_title = window_title + ' (Plot ID: ' + string(base, format='(i0)') + ')'
      setting_base = widget_base(base, /row, xsize = xsize, ysize = 30, frame = 1)
        plot_setting_button = widget_button(setting_base, value = 'Plot Set...')
        oplot_setting_button = widget_button(setting_base, value = 'Oplot Set...')
        legend_setting_button = widget_button(setting_base, value = 'Legend Set...')
        xyouts_setting_button = widget_button(setting_base, value = 'xyouts...')
        errbar_setting_base = widget_base(setting_base, /nonexclusive, /align_center)
          errbar_show_button = widget_button(errbar_setting_base, value = 'Show Error Bar')
          widget_control, errbar_show_button, set_button = plotinfo.plot_setting.show_errbar
        save_figure_button = widget_button(setting_base, value = 'Save Figure...')
        save_data_button = widget_button(setting_base, value = 'Save Data...')
      description_base = widget_base(base, /row, xsize = xsize)
        description_label = widget_label(description_base, value = 'Plot Description: ')
        description_text = widget_text(description_base, value = plotinfo.description, /scroll, /wrap, scr_xsize = xsize - 120)
      plot_draw = widget_draw(base, xsize = xsize, ysize = ysize,  /button_event, retain = 2)
      str_info = 'Zoom: Hold left mouse button.  Pan: Hold middle mouse button.  Reset: Click right mouse button'
      info_label = widget_label(base, value = str_info)


    mouse = {x0:0l, x1: 0l, y0:0l, y1:0l, left_middle:0, graphic_mode:0, xy_direction:0}
    idinfo = {base:base, $
                plot_setting_button:plot_setting_button, $
                oplot_setting_button:oplot_setting_button, $
                legend_setting_button:legend_setting_button, $
                xyouts_setting_button:xyouts_setting_button, $
                errbar_show_button:errbar_show_button, $
                save_figure_button:save_figure_button, $
                save_data_button:save_data_button, $
                description_text:description_text, $
                plot_draw:plot_draw, $
              base_plot_setting_window:0l, $
                plot_set_description_text:0l, $
                title_text:0l, $
                xtitle_text:0l, $
                ytitle_text:0l, $
                charsize_text:0l, $
                charthick_text:0l, $
                xstyle1_button:0l, $
                xstyle2_button:0l, $
                xstyle3_button:0l, $
                xstyle4_button:0l, $
                xtype_combo:0l, $
                xrange_min_text:0l, $
                xrange_max_text:0l, $
                ystyle1_button:0l, $
                ystyle2_button:0l, $
                ystyle3_button:0l, $
                ystyle4_button:0l, $
                ytype_combo:0l, $
                yrange_min_text:0l, $
                yrange_max_text:0l, $
                iso_button:0l, $
                plot_setting_apply_button:0l, $
                plot_setting_cancel_button:0l, $
                plot_setting_ok_button:0l, $
              base_oplot_setting_window:0l, $
                sel_line_num_combo:0l, $
                thick_text:0l, $
                style_combo:0l, $
                color_combo:0l, $
                symbol_combo:0l, $
                sym_size_text:0l, $
                oplot_setting_apply_button:0l, $
                oplot_setting_cancel_button:0l, $
                oplot_setting_ok_button:0l, $
              base_legend_setting_window:0l, $
                show_legend_button:0l, $
                pos_left_button:0l, $
                pos_right_button:0l, $
                pos_top_button:0l, $
                pos_bottom_button:0l, $
                legend_sel_line_num_combo:0l, $
                item_text:0l, $
                legend_setting_apply_button:0l, $
                legend_setting_cancel_button:0l, $
                legend_setting_ok_button:0l, $
              base_xyouts_setting_window:0l, $
                show_xyouts_button:0l, $
                sel_xyouts_num_combo:0l, $
                xyouts_text:0l, $
                position_x_text:0l, $
                position_y_text:0l, $
                xyouts_charsize_text:0l, $
                xyouts_charthick_text:0l, $
                xyouts_color_combo:0l, $
                xyouts_orientation_text:0l, $
                xyouts_setting_apply_button:0l, $
                xyouts_setting_cancel_button:0l, $
                xyouts_setting_ok_button:0l, $
              save_figure_filename:'', $
              save_data_filename:'', $
              mouse:mouse}


  ;set the output keyword
    out_base_id = base

  ;set user values
    widget_control, base, set_uvalue = idinfo
    widget_control, plot_draw, set_uvalue = plotinfo

  ;create optional windows
    create_plot_setting_window, base
    create_oplot_setting_window, base
    create_legend_setting_window, base
    create_xyouts_setting_window, base

  ; realize the widget
    widget_control, base, /realize

    replot_all, plotinfo, plot_draw, /first

  ; start xmanager
    xmanager, 'ycplot', base, /no_block

  endelse

end