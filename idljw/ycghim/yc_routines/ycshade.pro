;=================================================================
;IDL Procedure for plotting: ycshade.pro
;
;  Developer: Young-chul Ghim(Kim)
;  Starting Date of writing the program: 24-01-2011
;
; <version history>
; - v.1.0:
;      The first version of the program.
;      Completed on the 27-01-2011
; 
;=================================================================
;
;input parameters:
;
;  zdata: [required. or can be optional if saved_file is provided].  Type: 2-D or 3-D array of numerics
;         If 2D array: zdata[x, y]
;           value of z for a shade of z on the x-y plane.
;           x is the horizontal axis.
;           y is the vertical axis.
;         If 3D array: zdata[x, y, t]
;           value of z for a shade of z on the x-y plane as a function of t.
;           x is the horizontal axis.
;           y is the vertical axis
;           t is the time axis.
;           If zdata is in 3D array, then 'animation' will be available. 
;  
;  xdata: [optional].  Type: 1-D array of numerics
;         Values of x for a shade of z on the x-y plane 
;         If this is not specified, then x is generated as an array of index
;
;  ydata: [optional].  Type: 1-D array of numerics
;         Values of y for a shade of z on the x-y plane 
;         If this is not specified, then y is generated as an array of index
;
;  tdata: [optional].  Type: 1-D array of numerics
;         Values of t for a shade of z is the dimenstion of z is 3. 
;         If this is not specified, then t is generated as an array of index
;
;
;input keywords:
;
;  saved_file: [optional]. Type: string
;              If this value is provided, then the program reads the saved data.
;              Note: all the other inputs values are ignored if this value is provided, except xsize and ysize keywords.
;
;  title: [optional]. Type: string
;         title of the plot.
;
;  xtitle: [optional]. Type: string
;          xtitle of the plot
;
;  ytitle: [optional]. Type: string
;          ytitle of the plot
;
;  zlog: [optional].  Type: scalar (0 or 1)
;        If this is set, then z-axis is in logarithmic.
;        If this is not set, then z-axis is in linear.
;
;  xsize: [optional].  Type: scalar
;         xsize sets the size of plot in horizontal direction
;         if xsize is less than 640, then xsize is set to 640 
;
;  ysize: [optional].  Type: scalar
;         ysize sets the size of plot in vertical direction
;         if ysize is less than 480, then ysize is set to 480
;
;  plot_pos: [optional]. type: 4 element vector 
;            Specifies the plot position in normalized unit [x0, y0, x1, y1]
;
;  scale_pos: [optional]. type: 4 element vector 
;             Specifies the scale position in normalized unit [x0, y0, x1, y1]
;
;  ctable_num: [optional]. type: interger
;          Specified the color table number
;
;  ctable_invert: [optional]. type: 1 or 0
;                 If 1, then color table is inverted.
;
;  curr_inx_tframe: [optional]. type: long
;                   Sets up the time index for 4D plot
;
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
;=================================================================

;=================================================================
; sub-routine for ycshade
;=================================================================

function ycshade_nice_form_str_num, str

  a = strsplit(str, '.', /extract)
  if n_elements(a) lt 2 then begin
    no_frac = 1
    digit = a[0]
  endif else begin
    no_frac = 0
    digit = a[0]
    frac = a[1]
  endelse
  len_digit = strlen(digit)
  if not no_frac then len_frac = strlen(frac)

  separate = 3.0

  n = ceil(len_digit/separate)
  sub_str1 = strarr(n)
  for i = 0, fix(len_digit/separate) - 1 do begin
    sub_str1[n-i-1] = strmid(digit, (i+1)*separate-1, separate, /reverse_offset) 
  endfor
  if (i le n - 1) then begin
    sub_str1[n-i-1] = strmid(digit, (i+1)*separate-1, len_digit-i*separate, /reverse_offset)
  endif

  if not no_frac then begin
    n = ceil(len_frac/separate)
    sub_str2 = strarr(n)
    for i = 0, fix(len_frac/separate) - 1 do begin
      sub_str2[i] = strmid(frac, i*separate, separate)
    endfor
    if (i le n - 1) then begin
      sub_str2[i] = strmid(frac, i*separate, len_frac-i*separate)
    endif
  endif

  str1 = strjoin(sub_str1, ' ')
  if not no_frac then begin
    str2 = strjoin(sub_str2, ' ')
    str1 = [str1, str2]
  endif

  result = strjoin(str1, '.')

  return, result
end


pro ycshade_draw_highlight, idinfo

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

  draw_size = idinfo.draw_size
  plot_xr_device = [plotinfo.plot_setting.plot_pos[0], plotinfo.plot_setting.plot_pos[2]] * draw_size.x
  plot_yr_device = [plotinfo.plot_setting.plot_pos[1], plotinfo.plot_setting.plot_pos[3]] * draw_size.y
  scale_xr_device = [plotinfo.plot_setting.scale_pos[0], plotinfo.plot_setting.scale_pos[2]] * draw_size.x
  scale_yr_device = [plotinfo.plot_setting.scale_pos[1], plotinfo.plot_setting.scale_pos[3]] * draw_size.y

  if idinfo.mouse.xyz_direction eq 1 then begin			;x-direciton highlight (if xyz_direction=1, then x-direction)
    xr = [idinfo.mouse.x0, idinfo.mouse.x1]
    yr = plot_yr_device
    polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor('blue')
  endif else if idinfo.mouse.xyz_direction eq 2 then begin	;y-direction highlight (if xyz_direction=2, then y-direction)
    xr = plot_xr_device
    yr = [idinfo.mouse.y0, idinfo.mouse.y1]
    polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor('blue')
  endif else if idinfo.mouse.xyz_direction eq 3 then begin	;z-direction (scale) highlight (if xyz_direction = 3, then z-direction)
    xr = scale_xr_device
    yr = [idinfo.mouse.y0, idinfo.mouse.y1]
    plots, xr, [yr[0], yr[0]], /device, col = truecolor('yellow'), thick = 5
    plots, xr, [yr[1], yr[1]], /device, col = truecolor('yellow'), thick = 5
    polyfill, [xr[0], xr[1], xr[1], xr[0]], [yr[0], yr[0], yr[1], yr[1]], /device, col = truecolor('blue')
  endif else begin
  ;do nothing

  endelse

; restore the system variable
  !p = psys
  !x = xsys
  !y = ysys
  !z = zsys

end


pro ycshade_replot_all, plotinfo, plot_id, first = first, psplot = psplot

;get the window id
  if not keyword_set(psplot) then begin
    widget_control, plot_id, get_value = win
    wset, win
  endif

;retrieve the necessary data from plotinfo
  data = plotinfo.data
  plot_setting = plotinfo.plot_setting
  contour_setting = plotinfo.contour_setting
  animation_setting = plotinfo.animation_setting
  sys_var = plotinfo.sys_var

;save the system variable
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


; color table check. Note: color table for psplot is different from regular plot
;  this is added for psplot.
  inx = where(contour_setting.color_table eq contour_setting.ccolor, count)
  if count le 0 then inx = 0 else inx = inx[0]
  contour_setting.ccolor = truecolor(strcompress(contour_setting.color_table_str[inx], /remove_all))

; plot 
  z = reform(data.z[*, *, data.inx_tframe])
  if plot_setting.zlog eq 1 then begin
  ;if z or zrange value of less than zero then, I need to remove it because alog10(negative or zero) gives an error.
    inx_zero = where(z le 0.0, count_zero)
    if count_zero gt 0 then $
      z[inx_zero] = !values.f_nan
    zrange = plot_setting.zrange
    if zrange[0] le 0.0 then $
      zrange[0] = abs(min(z, /abs, /nan))
    if zrange[1] le 0.0 then $
      zrange[1] = abs(max(z, /abs, /nan))
    z = alog10(z)
    zrange = alog10(zrange)
  endif else $
    zrange = plot_setting.zrange
  x = reform(data.x)
  y = reform(data.y)

; check types of x, y and z, and make the types of range same as the data types.
; xrange, yrange and zranges are floating types by default.
  xtype = size(x, /type)
  ytype = size(y, /type)
  ztype = size(z, /type)
  if( (xtype eq 2) or (xtype eq 3) ) then $
    xrange = long(plot_setting.xrange) $
  else $
    xrange = plot_setting.xrange
  if( (ytype eq 2) or (ytype eq 3) ) then $
    yrange = long(plot_setting.yrange) $
  else $
    yrange = plot_setting.yrange
  if( (ztype eq 2) or (ztype eq 3) ) then $
    zrange = long(zrange) $
  else $
    zrange = zrange

  if (xrange[0] eq xrange[1]) then xrange[1] = xrange[0] + 1
  if (yrange[0] eq yrange[1]) then yrange[1] = yrange[0] + 1
  if (zrange[0] eq zrange[1]) then zrange[1] = zrange[0] + 1

  inx_finite_clevels = where( (finite(contour_setting.clevels) eq 1), count )

;check title
  title = plot_setting.title
  if animation_setting.sel_add_title_type ge 1 then begin
    title = title + ' ' + animation_setting.add_title_prefix + ' '
    if animation_setting.sel_add_title_type eq 1 then begin
      str = strcompress(string(data.t[data.inx_tframe], format='(f0.8)'), /remove_all)
      str = ycshade_nice_form_str_num(str)
      title = title + str  + ' ' 
    endif else begin
      str = strcompress(string(data.inx_tframe, format='(i0)'), /remove_all)
      str = ycshade_nice_form_str_num(str)
      title = title + str + ' '
    endelse
    title = title + animation_setting.add_title_postfix
  endif

  if plot_setting.box_contour eq 1 then begin
    threshold_npts = 1000
    inx_x = where((x ge xrange[0]) and (x le xrange[1]), countx)
    inx_y = where((y ge yrange[0]) and (y le yrange[1]), county)
    if countx lt 1 then countx = threshold_npts
    if county lt 1 then county = threshold_npts

    factor_x = long(threshold_npts/countx)
    if factor_x lt 1 then factor_x = 1
    factor_y = long(threshold_npts/county)
    if factor_y lt 1 then factor_y = 1
    new_nx = (countx - 1) * factor_x + 1
    new_ny = (county - 1) * factor_y + 1

    if ( (new_nx le countx) and (new_ny le county) ) then begin
      new_z = z
      new_x = x
      new_y = y
    endif else begin
      new_nx = new_nx > countx
      new_ny = new_ny > county
      new_x = fltarr(new_nx)
      new_y = fltarr(new_ny)
      new_z = fltarr(new_nx, new_ny)

      if new_nx gt countx then begin
        new_x = findgen(new_nx) * (xrange[1]-xrange[0])/(new_nx-1) + xrange[0]
      endif else begin
        new_x = x[inx_x]
      endelse

      if new_ny gt county then begin
        new_y = findgen(new_ny) * (yrange[1]-yrange[0])/(new_ny-1) + yrange[0]
      endif else begin
        new_y = y[inx_y]
      endelse

      for i = 0, countx - 2 do begin
        for j = 0, county - 2 do begin
          new_z[i*factor_x:(i+1)*factor_x-1, j*factor_y:(j+1)*factor_y-1] = z[inx_x[i], inx_y[j]] 
        endfor
        new_z[i*factor_x:(i+1)*factor_x-1, j*factor_y] = z[inx_x[i], inx_y[j]]
      endfor
      for j = 0, county - 2 do begin
        new_z[i*factor_x, j*factor_y:(j+1)*factor_y-1] = z[inx_x[i], inx_y[j]]
      endfor
      new_z[i*factor_x, j*factor_y] = z[inx_x[i], inx_y[j]]

    endelse

    old_x = x
    old_y = y

    z = temporary(new_z)
    x = temporary(new_x)
    y = temporary(new_y)
  endif else begin
    old_x = x
    old_y = y
  endelse


  if count ge 1 then begin	;draw manually provided contour lines as well
    cp_shade_mod, z, x, y, $
                  title = title, $
                  xtitle = plot_setting.xtitle, $
                  ytitle = plot_setting.ytitle, $
                  ztitle = plot_setting.ztitle, $
                  xrange = xrange, $
                  yrange = yrange, $
                  zrange = zrange, $
                  isotropic = plot_setting.isotropic, $
                  invert = plot_setting.ctable_invert, $
                  ctable = plot_setting.ctable, $
                  pos = plot_setting.plot_pos, $
                  scalepos = plot_setting.scale_pos, $
                  showscale = plot_setting.showscale, $
                  downhill = contour_setting.downhill, $
                  clabel = contour_setting.clabel, $
                  ccharsize = contour_setting.ccharsize, $
                  ccharthick = contour_setting.ccharthick, $
                  ccolor = contour_setting.ccolor, $
                  clinestyle = contour_setting.clinestyle, $
                  clinethick = contour_setting.clinethick, $
                  cvalue = contour_setting.clevels[inx_finite_clevels]
    if plot_setting.grid_line eq 1 then begin
      for i = 0l, n_elements(old_x) - 1 do begin
        if (old_x[i] gt xrange[0]) and (old_x[i] lt xrange[1]) then $
          oplot, [old_x[i], old_x[i]], yrange, col = truecolor('white'), linestyle = 1
      endfor
      for i = 0l, n_elements(old_y) - 1 do begin
        if (old_y[i] gt yrange[0]) and (old_y[i] lt yrange[1])  then $ 
          oplot, xrange, [old_y[i], old_y[i]], col = truecolor('white'), linestyle = 1
      endfor
    endif
  endif else begin		;draw contour lines in accordance with autocontour
    cp_shade_mod, z, x, y, $
                  title = title, $
                  xtitle = plot_setting.xtitle, $
                  ytitle = plot_setting.ytitle, $
                  ztitle = plot_setting.ztitle, $
                  xrange = xrange, $
                  yrange = yrange, $
                  zrange = zrange, $
                  isotropic = plot_setting.isotropic, $
                  invert = plot_setting.ctable_invert, $
                  ctable = plot_setting.ctable, $
                  pos = plot_setting.plot_pos, $
                  scalepos = plot_setting.scale_pos, $
                  showscale = plot_setting.showscale, $
                  downhill = contour_setting.downhill, $
                  clabel = contour_setting.clabel, $
                  ccharsize = contour_setting.ccharsize, $
                  ccharthick = contour_setting.ccharthick, $
                  ccolor = contour_setting.ccolor, $
                  clinestyle = contour_setting.clinestyle, $
                  clinethick = contour_setting.clinethick, $
                  autocontour = contour_setting.autocontour
    if plot_setting.grid_line eq 1 then begin
      for i = 0l, n_elements(old_x) - 1 do begin
        if (old_x[i] gt xrange[0]) and (old_x[i] lt xrange[1]) then $
          oplot, [old_x[i], old_x[i]], yrange, col = truecolor('white'), linestyle = 1
      endfor
      for i = 0l, n_elements(old_y) - 1 do begin
        if (old_y[i] gt yrange[0]) and (old_y[i] lt yrange[1])  then $ 
          oplot, xrange, [old_y[i], old_y[i]], col = truecolor('white'), linestyle = 1
      endfor
    endif
  endelse


  if not keyword_set(psplot) then begin
  ;save the system variables
    plotinfo.sys_var.p = !p
    plotinfo.sys_var.x = !x
    plotinfo.sys_var.y = !y
    plotinfo.sys_var.z = !z
    widget_control, plot_id, set_uvalue = plotinfo

  ; restore the system variables
    !p = psys
    !x = xsys
    !y = ysys
    !z = zsys
  endif

end


pro ycshade_start_animation, idinfo, filename = filename,  mesg_box = text_widget_id
;if filename is provide, then save the animation as the *.mpg file.

; retrieve the necessary info
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  data = plotinfo.data
  plot_setting = plotinfo.plot_setting
  contour_setting = plotinfo.contour_setting
  animation_setting = plotinfo.animation_setting
  sys_var = plotinfo.sys_var

;save the system variable
  psys = !p
  xsys = !x
  ysys = !y
  zsys = !z

; retrieve the system variable for the plot
  !p = sys_var.p
  !x = sys_var.x
  !y = sys_var.y
  !z = sys_var.z
  !p.charsize = plot_setting.charsize
  !p.charthick = plot_setting.charthick


; prepare for animation 
  z = reform(data.z[*, *, *])
  if plot_setting.zlog eq 1 then begin
  ;if z or zrange value of less than zero then, I need to remove it because alog10(negative or zero) gives an error.
    inx_zero = where(z le 0.0, count_zero)
    if count_zero gt 0 then $
      z[inx_zero] = !values.f_nan
    zrange = plot_setting.zrange
    if zrange[0] le 0.0 then $
      zrange[0] = abs(min(z, /abs, /nan))
    if zrange[1] le 0.0 then $
      zrange[1] = abs(max(z, /abs, /nan))
    z = alog10(z)
    zrange = alog10(zrange)
  endif else $
    zrange = plot_setting.zrange
  x = reform(data.x)
  y = reform(data.y)
  t = reform(data.t)

; check types of x, y and z, and make the types of range same as the data types.
; xrange, yrange and zranges are floating types by default.
  xtype = size(x, /type)
  ytype = size(y, /type)
  ztype = size(z, /type)
  if( (xtype eq 2) or (xtype eq 3) ) then $
    xrange = long(plot_setting.xrange) $
  else $
    xrange = plot_setting.xrange
  if( (ytype eq 2) or (ytype eq 3) ) then $
    yrange = long(plot_setting.yrange) $
  else $
    yrange = plot_setting.yrange
  if( (ztype eq 2) or (ztype eq 3) ) then $
    zrange = long(zrange) $
  else $
    zrange = zrange

  if (xrange[0] eq xrange[1]) then xrange[1] = xrange[0] + 1
  if (yrange[0] eq yrange[1]) then yrange[1] = yrange[0] + 1
  if (zrange[0] eq zrange[1]) then zrange[1] = zrange[0] + 1

; get starting and ending times for animation and waiting time for each image
  widget_control, idinfo.ani_tstart_label, get_value = str_tstart
  widget_control, idinfo.ani_tend_label, get_value = str_tend
  wait_time = 1.0 / animation_setting.frame_rate
  tstart = double(strcompress(str_tstart, /remove_all))
  tend = double(strcompress(str_tend, /remove_all))
  inx_tstart = where(t ge tstart) & inx_tstart = long(inx_tstart[0])
  inx_tend = where(t le tend) & inx_tend = long(inx_tend[n_elements(inx_tend)-1])

  if inx_tstart ge inx_tend then begin
    msg = 'The starting time must be less than the ending time.!'
    ycshade_err_msg_window, msg, idinfo.base_animation_setting_window
    goto, restore_sys
  endif


; get ready for the title
  org_title = plot_setting.title
  if animation_setting.sel_add_title_type eq 0 then begin
    prefix = ''
    timeinfo = strarr(inx_tend-inx_tstart+1)
    timeinfo[*] = ''
    postfix = ''
  endif else if animation_setting.sel_add_title_type eq 1 then begin
    prefix = ' ' + animation_setting.add_title_prefix + ' '
    timeinfo = strcompress(string(t[inx_tstart:inx_tend], format = '(f0.8)'), /remove_all)
    postfix = ' ' + animation_setting.add_title_postfix
    for i=0, inx_tend-inx_tstart do $
      timeinfo[i] = ycshade_nice_form_str_num(timeinfo[i])
  endif else if animation_setting.sel_add_title_type eq 2 then begin
    prefix = ' ' + animation_setting.add_title_prefix + ' '
    timeinfo = strcompress(string(lindgen(inx_tend - inx_tstart + 1) + inx_tstart, format = '(i0)'), /remove_all)
    postfix = ' ' + animation_setting.add_title_postfix
    for i=0, inx_tend-inx_tstart do $
      timeinfo[i] = ycshade_nice_form_str_num(timeinfo[i])
  endif else begin
  ;do nothing
  endelse

  title = org_title + prefix + timeinfo + postfix

; get the window and pixmap ids
  widget_control, idinfo.plot_draw, get_value = wid
  wset, wid
  x_win_size = !d.x_size
  y_win_size = !d.y_size
  window, /free, /pixmap, xsize = x_win_size, ysize = y_win_size	;creating pixmap window
  pid = !d.window

; movie saving
  if keyword_set(filename) then begin
    save_movie = 1
    movie_images = bytarr(3, x_win_size, y_win_size, inx_tend-inx_tstart+1)
    mpegID = MPEG_OPEN([x_win_size, y_win_size])
  endif else begin
    save_movie = 0
  endelse

 inx_finite_clevels = where( (finite(contour_setting.clevels) eq 1), count )

; start animation:
  percent_frame = (inx_tend - inx_tstart + 1) * (findgen(10)+1.0) * 0.1
  if count ge 1 then begin	;draw manually provided contour lines as well
    for i = inx_tstart, inx_tend do begin
    ; make the pixmap the active window
      wset, pid

      cp_shade_mod, reform(z[*, *, i]), x, y, $
                    title = title[i-inx_tstart], $
                    xtitle = plot_setting.xtitle, $
                    ytitle = plot_setting.ytitle, $
                    ztitle = plot_setting.ztitle, $
                    xrange = xrange, $
                    yrange = yrange, $
                    zrange = zrange, $
                    isotropic = plot_setting.isotropic, $
                    invert = plot_setting.ctable_invert, $
                    ctable = plot_setting.ctable, $
                    pos = plot_setting.plot_pos, $
                    scalepos = plot_setting.scale_pos, $
                    showscale = plot_setting.showscale, $
                    downhill = contour_setting.downhill, $
                    clabel = contour_setting.clabel, $
                    ccharsize = contour_setting.ccharsize, $
                    ccharthick = contour_setting.ccharthick, $
                    ccolor = contour_setting.ccolor, $
                    clinestyle = contour_setting.clinestyle, $
                    clinethick = contour_setting.clinethick, $
                    cvalue = contour_setting.clevels[inx_finite_clevels]

      if save_movie then begin
        if i eq inx_tstart then widget_control, text_widget_id, set_value = 'Copying images start...'
        movie_images[*, *, *, i-inx_tstart] = tvread(0, 0)
        MPEG_PUT, mpegID, IMAGE = movie_images[*, *, *, i-inx_tstart], frame = i, /order
        inx = where(percent_frame eq (i-inx_tstart), count)
        if count gt 0 then begin
          inx = inx[count-1]
          str = strcompress(string((inx+1)*10, format='(i0)'), /remove_all) + '% '
          widget_control, text_widget_id, set_value = str, /append, /no_newline
        endif
      endif else begin
      ; set the draw window to be active once again
        wset, wid
      ; copy the contents of the pixmap to the draw window
        device, copy = [0 , 0, x_win_size, y_win_size, 0, 0, pid]
      ;wait
         wait, wait_time
      endelse
    endfor
  endif else begin		;draw contour lines in accordance with autocontour
    for i = inx_tstart, inx_tend do begin
    ; make the pixmap the active window
      wset, pid

      cp_shade_mod, reform(z[*, *, i]), x, y, $
                    title = title[i-inx_tstart], $
                    xtitle = plot_setting.xtitle, $
                    ytitle = plot_setting.ytitle, $
                    ztitle = plot_setting.ztitle, $
                    xrange = xrange, $
                    yrange = yrange, $
                    zrange = zrange, $
                    isotropic = plot_setting.isotropic, $
                    invert = plot_setting.ctable_invert, $
                    ctable = plot_setting.ctable, $
                    pos = plot_setting.plot_pos, $
                    scalepos = plot_setting.scale_pos, $
                    showscale = plot_setting.showscale, $
                    downhill = contour_setting.downhill, $
                    clabel = contour_setting.clabel, $
                    ccharsize = contour_setting.ccharsize, $
                    ccharthick = contour_setting.ccharthick, $
                    ccolor = contour_setting.ccolor, $
                    clinestyle = contour_setting.clinestyle, $
                    clinethick = contour_setting.clinethick, $
                    autocontour = contour_setting.autocontour

      if save_movie then begin
        if i eq inx_tstart then widget_control, text_widget_id, set_value = 'Copying images start...'
        movie_images[*, *, *, i-inx_tstart] = tvread(0, 0)
        MPEG_PUT, mpegID, IMAGE = movie_images[*, *, *, i-inx_tstart], frame = i, /order
        inx = where(percent_frame eq (i-inx_tstart), count)
        if count gt 0 then begin
          inx = inx[count-1]
          str = strcompress(string((inx+1)*10, format='(i0)'), /remove_all) + '% '
          widget_control, text_widget_id, set_value = str, /append, /no_newline
        endif
      endif else begin
      ; set the draw window to be active once again
        wset, wid
      ; copy the contents of the pixmap to the draw window
        device, copy = [0 , 0, x_win_size, y_win_size, 0, 0, pid]
      ;wait
         wait, wait_time
      endelse
    endfor
  endelse

; delete pixmap window
  wdelete, pid

  if save_movie then begin
    widget_control, text_widget_id, set_value = '', /append
    widget_control, text_widget_id, set_value = 'Copyting images finished.', /append
    widget_control, text_widget_id, set_value = 'Saving a movie file...', /append
    MPEG_SAVE, mpegID, filename = filename
    MPEG_CLOSE, mpegID
    widget_control, text_widget_id, set_value = 'Making a movie finished.', /append
  endif


restore_sys:

;save the system variables
  plotinfo.sys_var.p = !p
  plotinfo.sys_var.x = !x
  plotinfo.sys_var.y = !y
  plotinfo.sys_var.z = !z
  widget_control, idinfo.plot_draw, set_uvalue = plotinfo

; restore the system variables
  !p = psys
  !x = xsys
  !y = ysys
  !z = zsys

end

pro ycshade_err_msg_window_event, event
  widget_control, event.top, get_uvalue = ok_button

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then $
    widget_control, event.top, /destroy

  if event.id eq ok_button then $
    widget_control, event.top, /destroy
end


; create error message window widget
pro ycshade_err_msg_window, msg, group_leader

  msg_window_base = widget_base(title = 'Message', /modal, group_leader=group_leader, /column, $
                     /tlb_kill_request_events)
  label = widget_label(msg_window_base, value = msg, /align_left)
  label = widget_label(msg_window_base, value = '')
  label = widget_label(msg_window_base, value = '')
  label = widget_label(msg_window_base, value = '')
  geometry = widget_info(msg_window_base, /geometry)

  ok_button = widget_button(msg_window_base, value = 'OK', /align_center, xsize = geometry.xsize/2, ysize = 30)

  widget_control, msg_window_base, set_uvalue = ok_button

  widget_control, msg_window_base, /realize
  widget_control, msg_window_base, /show
  xmanager, 'ycshade_err_msg_window', msg_window_base

end



pro ycshade_create_plot_setting_window, parent_id

; retrieve the necessary data
  widget_control, parent_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  plot_setting = plotinfo.plot_setting

; create the plot_setting window
  window_title = 'ycshade: Plot Setting Window'
  base_plot_setting_window = widget_base(/column, title = window_title, xsize = 430, ysize = 710, $
                                         group_leader = parent_id, /tlb_kill_request_events)
    base1 = widget_base(base_plot_setting_window, /column, frame = 1)
      base11 = widget_base(base1, /row)
        description_label = widget_label(base11, value = 'Plot Description:   ')
        plot_set_description_text = widget_text(base11, /editable, scr_xsize = 290, /scroll, /wrap, value = plotinfo.description)  
      base12 = widget_base(base1, /row)
        title_label = widget_label(base12, value = 'Title:         ')
        title_text = widget_text(base12, /editable, scr_xsize = 320, value = plot_setting.title)
      base13 = widget_base(base1, /row)
        xtitle_label = widget_label(base13, value = 'xTitle:        ')
        xtitle_text = widget_text(base13, /editable, scr_xsize = 320, value = plot_setting.xtitle)
      base14 = widget_base(base1, /row)
        ytitle_label = widget_label(base14, value = 'yTitle:        ')
        ytitle_text = widget_text(base14, /editable, scr_xsize = 320, value = plot_setting.ytitle)
      base15 = widget_base(base1, /row)
        ztitle_label = widget_label(base15, value = 'zTitle:        ')
        ztitle_text = widget_text(base15, /editable, scr_xsize = 320, value = plot_setting.ztitle) 
      base16 = widget_base(base1, /row)
        str_charsize = strcompress(string(plot_setting.charsize, format='(f0.2)'), /remove_all)
        charsize_label = widget_label(base16, value = 'Char. Size:    ')
        charsize_text = widget_text(base16, /editable, scr_xsize = 80, value = str_charsize)
        str_charthick = strcompress(string(plot_setting.charthick, format='(f0.2)'), /remove_all)
        charthick_label = widget_label(base16, value = '          Char. Thick:   ')
        charthick_text = widget_text(base16, /editable, scr_xsize = 80, value = str_charthick)
    base2 = widget_base(base_plot_setting_window, /column, frame = 1)
      base21 = widget_base(base2)
       label21 = widget_label(base21, value = 'From', xoffset = 190)
       label21 = widget_label(base21, value = 'To', xoffset = 330)
      base22 = widget_base(base2, /row)
        label22 = widget_label(base22, value = 'x-axis range:      ')
        str_xrange = strcompress(string(plot_setting.xrange), /remove_all)
        xrange_min_text = widget_text(base22, /editable, scr_xsize = 145, value = str_xrange[0])
        xrange_max_text = widget_text(base22, /editable, scr_xsize = 145, value = str_xrange[1])
      base23 = widget_base(base2, /row)
        label23 = widget_label(base23, value = 'y-axis range:      ')
        str_yrange = strcompress(string(plot_setting.yrange), /remove_all)
        yrange_min_text = widget_text(base23, /editable, scr_xsize = 145, value = str_yrange[0])
        yrange_max_text = widget_text(base23, /editable, scr_xsize = 145, value = str_yrange[1])
      base24 = widget_base(base2, /row)
        label24 = widget_label(base24, value = 'z-axis range:      ')
        str_zrange = strcompress(string(plot_setting.zrange), /remove_all)
        zrange_min_text = widget_text(base24, /editable, scr_xsize = 145, value = str_zrange[0])
        zrange_max_text = widget_text(base24, /editable, scr_xsize = 145, value = str_zrange[1])
      base25 = widget_base(base2, /row)
        base251 = widget_base(base25, /column)
          label251 = widget_label(base251, value = 'z-axis style:    ')
        base252 = widget_base(base25, /exclusive, /row)
          zaxis_linear_button = widget_button(base252, value = 'Linear              ')
          zaxis_log_button = widget_button(base252, value = 'Log (base 10)')
          if plot_setting.zlog eq 1 then $
            widget_control, zaxis_log_button, set_button = 1 $
          else $
            widget_control, zaxis_linear_button, set_button = 1
    base3 = widget_base(base_plot_setting_window, /column, frame = 1)
      base31 = widget_base(base3, /row)
        base311 = widget_base(base31, /row)
          widget_label311 = widget_label(base311, value = 'Color Table: ')
          ctable_sel_combo = widget_combobox(base311, value = plot_setting.ctable_str)
          widget_control, ctable_sel_combo, set_combobox_select = plot_setting.ctable
        base312 = widget_base(base31, /row, /nonexclusive)
          ctable_invert_button = widget_button(base312, value = 'Invert Color Table')
          widget_control, ctable_invert_button, set_button = plot_setting.ctable_invert
      base32 = widget_base(base3, /row, /nonexclusive)
        box_contour_button = widget_button(base32, value = 'Box contour')
        widget_control, box_contour_button, set_button = plot_setting.box_contour
        grid_line_button = widget_button(base32, value= 'Grid Line')
        widget_control, grid_line_button, set_button = plot_setting.grid_line
        showscale_button = widget_button(base32, value = 'Show Scalebar')
        widget_control, showscale_button, set_button = plot_setting.showscale
        isotropic_button = widget_button(base32, value = 'Iso. x- and y-axes')
        widget_control, isotropic_button, set_button = plot_setting.isotropic
    base4 = widget_base(base_plot_setting_window, /column, frame = 1)
      base41 = widget_base(base4)
        label411 = widget_label(base41, value = 'x0', xoffset = 140)
        label412 = widget_label(base41, value = 'y0', xoffset = 215)
        label413 = widget_label(base41, value = 'x1', xoffset = 290)
        label414 = widget_label(base41, value = 'y1', xoffset = 370)
      base42 = widget_base(base4, /row)
        label42 = widget_label(base42, value = 'Plot Position:  ')
        str_plot_pos = strcompress(string(plot_setting.plot_pos, format='(f0.2)'), /remove_all)
        plot_pos_x0_text = widget_text(base42, /editable, scr_xsize = 75, value = str_plot_pos[0])
        plot_pos_y0_text = widget_text(base42, /editable, scr_xsize = 75, value = str_plot_pos[1])
        plot_pos_x1_text = widget_text(base42, /editable, scr_xsize = 75, value = str_plot_pos[2])
        plot_pos_y1_text = widget_text(base42, /editable, scr_xsize = 75, value = str_plot_pos[3])
      base43 = widget_base(base4, /row)
        label43 = widget_label(base43, value = 'Scale Position: ')
        str_scale_pos = strcompress(string(plot_setting.scale_pos, format='(f0.2)'), /remove_all)
        scale_pos_x0_text = widget_text(base43, /editable, scr_xsize = 75, value = str_scale_pos[0])
        scale_pos_y0_text = widget_text(base43, /editable, scr_xsize = 75, value = str_scale_pos[1])
        scale_pos_x1_text = widget_text(base43, /editable, scr_xsize = 75, value = str_scale_pos[2])
        scale_pos_y1_text = widget_text(base43, /editable, scr_xsize = 75, value = str_scale_pos[3])
    base5 = widget_base(base_plot_setting_window, frame = 1)
      show_zx_button = widget_button(base5, value = 'Show z vs. x', xsize = 150, xoffset = 50)
      show_zy_button = widget_button(base5, value = 'Show z vs. y', xsize = 150, xoffset = 230)
    base6 = widget_base(base_plot_setting_window)
      plot_setting_apply_button = widget_button(base6, value = 'Apply', $
                                                xsize = 100, xoffset = 130, yoffset = 15)
      plot_setting_cancel_button = widget_button(base6, value = 'Cancel', $
                                                 xsize=100, xoffset=230, yoffset=15)
      plot_setting_ok_button = widget_button(base6, value = 'OK', $
                                             xsize=100, xoffset=330, yoffset=15)

; save the idinfo
  idinfo.base_plot_setting_window = base_plot_setting_window
  idinfo.plot_set_description_text = plot_set_description_text
  idinfo.title_text = title_text
  idinfo.xtitle_text = xtitle_text
  idinfo.ytitle_text = ytitle_text
  idinfo.ztitle_text = ztitle_text
  idinfo.charsize_text = charsize_text
  idinfo.charthick_text = charthick_text
  idinfo.xrange_min_text = xrange_min_text
  idinfo.xrange_max_text = xrange_max_text
  idinfo.yrange_min_text = yrange_min_text
  idinfo.yrange_max_text = yrange_max_text
  idinfo.zrange_min_text = zrange_min_text
  idinfo.zrange_max_text = zrange_max_text
  idinfo.zaxis_linear_button = zaxis_linear_button
  idinfo.zaxis_log_button = zaxis_log_button
  idinfo.ctable_sel_combo = ctable_sel_combo
  idinfo.ctable_invert_button = ctable_invert_button
  idinfo.showscale_button = showscale_button
  idinfo.box_contour_button = box_contour_button
  idinfo.grid_line_button = grid_line_button
  idinfo.isotropic_button = isotropic_button
  idinfo.plot_pos_x0_text = plot_pos_x0_text
  idinfo.plot_pos_y0_text = plot_pos_y0_text
  idinfo.plot_pos_x1_text = plot_pos_x1_text
  idinfo.plot_pos_y1_text = plot_pos_y1_text
  idinfo.scale_pos_x0_text = scale_pos_x0_text
  idinfo.scale_pos_y0_text = scale_pos_y0_text
  idinfo.scale_pos_x1_text = scale_pos_x1_text
  idinfo.scale_pos_y1_text = scale_pos_y1_text
  idinfo.show_zx_button = show_zx_button
  idinfo.show_zy_button = show_zy_button
  idinfo.plot_setting_apply_button = plot_setting_apply_button
  idinfo.plot_setting_cancel_button = plot_setting_cancel_button
  idinfo.plot_setting_ok_button = plot_setting_ok_button

  widget_control, parent_id, set_uvalue = idinfo

; this window needs to know about the parent id
  widget_control, base_plot_setting_window, set_uvalue = parent_id

end

pro ycshade_show_plot_setting_window, idinfo
; realize the plot setting window
  widget_control, idinfo.base_plot_setting_window, /realize

; start the xmanager
  xmanager, 'ycshade_plot_setting_window', idinfo.base_plot_setting_window, /no_block
end

pro ycshade_kill_plot_setting_window, idinfo
; kill the plot setting window
  widget_control, idinfo.base_plot_setting_window, /destroy

; create the plot setting window so that it can be opend later.
  ycshade_create_plot_setting_window, idinfo.base
end

pro ycshade_save_plot_setting, idinfo
;get the plotinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; save the plot setting
  widget_control, idinfo.plot_set_description_text, get_value = str
  plotinfo.description = str
  widget_control, idinfo.description_text, set_value = str
  widget_control, idinfo.title_text, get_value = str
  plotinfo.plot_setting.title = str
  widget_control, idinfo.xtitle_text, get_value = str
  plotinfo.plot_setting.xtitle = str
  widget_control, idinfo.ytitle_text, get_value = str
  plotinfo.plot_setting.ytitle = str
  widget_control, idinfo.ztitle_text, get_value = str
  plotinfo.plot_setting.ztitle = str
  widget_control, idinfo.charsize_text, get_value = str
  plotinfo.plot_setting.charsize = float(str)
  widget_control, idinfo.charthick_text, get_value = str
  plotinfo.plot_setting.charthick = float(str)
  widget_control, idinfo.xrange_min_text, get_value = str
  plotinfo.plot_setting.xrange[0] = float(str)
  widget_control, idinfo.xrange_max_text, get_value = str
  plotinfo.plot_setting.xrange[1] = float(str)
  widget_control, idinfo.yrange_min_text, get_value = str
  plotinfo.plot_setting.yrange[0] = float(str)
  widget_control, idinfo.yrange_max_text, get_value = str
  plotinfo.plot_setting.yrange[1] = float(str)
  widget_control, idinfo.zrange_min_text, get_value = str
  plotinfo.plot_setting.zrange[0] = float(str)
  widget_control, idinfo.zrange_max_text, get_value = str
  plotinfo.plot_setting.zrange[1] = float(str)
  if widget_info(idinfo.zaxis_linear_button, /button_set) then $
    plotinfo.plot_setting.zlog = 0 $
  else $
    plotinfo.plot_setting.zlog = 1
  str = widget_info(idinfo.ctable_sel_combo, /combobox_gettext)
  plotinfo.plot_setting.ctable = where(plotinfo.plot_setting.ctable_str eq str)
  plotinfo.plot_setting.ctable_invert = widget_info(idinfo.ctable_invert_button, /button_set)
  plotinfo.plot_setting.showscale = widget_info(idinfo.showscale_button, /button_set)
  plotinfo.plot_setting.box_contour = widget_info(idinfo.box_contour_button, /button_set)
  plotinfo.plot_setting.grid_line = widget_info(idinfo.grid_line_button, /button_set)
  plotinfo.plot_setting.isotropic = widget_info(idinfo.isotropic_button, /button_set)
  temp_str = strarr(4)
  widget_control, idinfo.plot_pos_x0_text, get_value = str
  temp_str[0] = str
  widget_control, idinfo.plot_pos_y0_text, get_value = str
  temp_str[1] = str
  widget_control, idinfo.plot_pos_x1_text, get_value = str
  temp_str[2] = str
  widget_control, idinfo.plot_pos_y1_text, get_value = str
  temp_str[3] = str
  plotinfo.plot_setting.plot_pos = float(temp_str)
  temp_str = strarr(4)
  widget_control, idinfo.scale_pos_x0_text, get_value = str
  temp_str[0] = str
  widget_control, idinfo.scale_pos_y0_text, get_value = str
  temp_str[1] = str
  widget_control, idinfo.scale_pos_x1_text, get_value = str
  temp_str[2] = str
  widget_control, idinfo.scale_pos_y1_text, get_value = str
  temp_str[3] = str
  plotinfo.plot_setting.scale_pos = float(temp_str)

;save the plotinfo
  widget_control, idinfo.plot_draw, set_uvalue = plotinfo

end

pro ycshade_plot_setting_window_event, event

; get base widget info
  widget_control, event.top, get_uvalue = parent_id
  widget_control, parent_id, get_uvalue = idinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    ycshade_kill_plot_setting_window, idinfo
    return
  endif

; event due to apply button
  if event.id eq idinfo.plot_setting_apply_button then begin
  ;save the data and replot the graph
    ycshade_save_plot_setting, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    ycshade_replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to cancel button
  if event.id eq idinfo.plot_setting_cancel_button then begin
    ycshade_kill_plot_setting_window, idinfo
    return
  endif

; event due to ok button
  if event.id eq idinfo.plot_setting_ok_button then begin
  ;save the data, then kill the window and redraw the graph
    ycshade_save_plot_setting, idinfo
    ycshade_kill_plot_setting_window, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    ycshade_replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to show_zx button or show_zy button
  if ( (event.id eq idinfo.show_zx_button) or (event.id eq idinfo.show_zy_button) ) then begin
  ;use plott
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    data = plotinfo.data
    plot_setting = plotinfo.plot_setting
    if event.id eq idinfo.show_zx_button then $
      ptype = 0 $
    else $
      ptype = 1

    temp_z = data.z
    if plot_setting.zlog eq 1 then begin
    ; I need to be careful of taking log base 10, since the argument must be greater than 0.
      inx_zero = where(temp_z le 0.0, count_zero)
      if count_zero gt 0 then $
        temp_z[inx_zero] = !values.f_nan
      temp_z = alog10(temp_z)
    endif

    plott, data.x, data.y, reform(temp_z[*, *, data.inx_tframe]), nlevels = 0, $
           xtitle = plot_setting.xtitle, ytitle = plot_setting.ytitle, ztitle = plot_setting.ztitle, charsize = plot_setting.charsize, $
           ptype = ptype, /quiet
  endif

end

pro ycshade_create_contour_setting_window, parent_id

; retrieve the necessary data
  widget_control, parent_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  contour_setting = plotinfo.contour_setting

; create 
  window_title = 'ycshade: Contour Line Setting Window'
  base_contour_setting_window = widget_base(/column, title = window_title, xsize = 430, ysize = 260, $
                                            group_leader = parent_id, /tlb_kill_request_events)
    base1 = widget_base(base_contour_setting_window, /row)
      label11 = widget_label(base1, value = 'Autocontour: ')
      autocontour_combo = widget_combobox(base1, value = strcompress(string(indgen(plotinfo.MAX_CONTOUR_LINES)+1), /remove_all))
      widget_control, autocontour_combo, set_combobox_select = contour_setting.autocontour-1
      label12 = widget_label(base1, value = '   Line Color: ')
      ccolor_combo = widget_combobox(base1, value = contour_setting.color_table_str)
      widget_control, ccolor_combo, set_combobox_select = where(contour_setting.color_table eq contour_setting.ccolor)
    base2 = widget_base(base_contour_setting_window, /row)
      label2 = widget_label(base2, value = 'Contour Line Levels: ')
      inx = where(finite(contour_setting.clevels) eq 0, count)
      if count gt 0 then inx = inx[0] else inx = plotinf.MAX_CONTOUR_LINES
      if inx gt 0 then $
        str = strcompress(string(contour_setting.clevels[0:inx-1], format='(f0.2)'), /remove_all) $
      else $
        str = ''
      str_clevels = ''
      for i = 0, inx - 1 do $
        str_clevels = str_clevels + str[i] + ' '
      clevels_text = widget_text(base2, /editable, scr_xsize = 290, value = str_clevels)
    base3 = widget_base(base_contour_setting_window, /row)
      str = strcompress(string(plotinfo.MAX_CONTOUR_LINES), /remove_all)
      label3 = widget_label(base3, value = '       Note: Seperate values with a space.  Max Number of levels: ' + str)
    base4 = widget_base(base_contour_setting_window, /row)
      label41 = widget_label(base4, value = 'Line Style: ')
      str = ['Solid', 'Dotted', 'Dashed', 'Dash Dot', 'Dash Dot Dot', 'Long Dashes']
      clinestyle_combo = widget_combobox(base4, value = str)
      widget_control, clinestyle_combo, set_combobox_select = contour_setting.clinestyle
      label42 = widget_label(base4, value = '         Line Thick: ')
      str = strcompress(string(contour_setting.clinethick, format = '(f0.2)'), /remove_all)
      clinethick_text = widget_text(base4, /editable, scr_xsize = 100, value = str)
    base5 = widget_base(base_contour_setting_window, /row)
      label51 = widget_label(base5, value = 'Char. Size:  ')
      str = strcompress(string(contour_setting.ccharsize, format = '(f0.2)'), /remove_all)
      ccharsize_text = widget_text(base5, /editable, scr_xsize = 100, value = str)
      label52 = widget_label(base5, value = '        Char. Thick:  ')
      str = strcompress(string(contour_setting.ccharthick, format = '(f0.2)'), /remove_all)
      ccharthick_text = widget_text(base5, /editable, scr_xsize = 100, value = str)
    base6 = widget_base(base_contour_setting_window, /row, /nonexclusive)
      showlabel_button = widget_button(base6, value = 'Show Label                     ')
      widget_control, showlabel_button, set_button = contour_setting.clabel
      downhill_button = widget_button(base6, value = 'Show Downhill')
      widget_control, downhill_button, set_button = contour_setting.downhill
    base7 = widget_base(base_contour_setting_window)
      contour_setting_apply_button = widget_button(base7, value = 'Apply', $
                                                xsize = 100, xoffset = 130, yoffset = 15)
      contour_setting_cancel_button = widget_button(base7, value = 'Cancel', $
                                                 xsize=100, xoffset=230, yoffset=15)
      contour_setting_ok_button = widget_button(base7, value = 'OK', $
                                             xsize=100, xoffset=330, yoffset=15)

; save idinfo
  idinfo.base_contour_setting_window = base_contour_setting_window
  idinfo.autocontour_combo = autocontour_combo
  idinfo.ccolor_combo = ccolor_combo
  idinfo.clevels_text = clevels_text
  idinfo.clinestyle_combo = clinestyle_combo
  idinfo.clinethick_text = clinethick_text
  idinfo.showlabel_button = showlabel_button
  idinfo.downhill_button = downhill_button
  idinfo.ccharsize_text = ccharsize_text
  idinfo.ccharthick_text = ccharthick_text
  idinfo.contour_setting_apply_button = contour_setting_apply_button
  idinfo.contour_setting_cancel_button = contour_setting_cancel_button
  idinfo.contour_setting_ok_button = contour_setting_ok_button

  widget_control, parent_id, set_uvalue = idinfo

; this window needs to know about the parent id
  widget_control, base_contour_setting_window, set_uvalue = parent_id

end

pro ycshade_show_contour_setting_window, idinfo
; realize the contour setting window
  widget_control, idinfo.base_contour_setting_window, /realize

; start the xmanager
  xmanager, 'ycshade_contour_setting_window', idinfo.base_contour_setting_window, /no_block

end

pro ycshade_kill_contour_setting_window, idinfo
; kill the contour setting window
  widget_control, idinfo.base_contour_setting_window, /destroy

; create the contour setting window so that it can be opend later.
  ycshade_create_contour_setting_window, idinfo.base
end


pro ycshade_save_contour_setting, idinfo
; get the plotinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; save the values
  plotinfo.contour_setting.downhill = widget_info(idinfo.downhill_button, /button_set)
  str = widget_info(idinfo.autocontour_combo, /combobox_gettext)
  plotinfo.contour_setting.autocontour = fix(str)
  nlines = plotinfo.MAX_CONTOUR_LINES
  widget_control, idinfo.clevels_text, get_value = str
  str_clevels = strsplit(str, ' ,;', /extract, count=count)
  if count gt 0 then $
    plotinfo.contour_setting.clevels[0:count-1] = float(str_clevels)
  plotinfo.contour_setting.clevels[count:nlines-1] = !values.f_nan
  plotinfo.contour_setting.clabel = widget_info(idinfo.showlabel_button, /button_set)
  widget_control, idinfo.ccharsize_text, get_value = str
  plotinfo.contour_setting.ccharsize = float(str)
  widget_control, idinfo.ccharthick_text, get_value = str
  plotinfo.contour_setting.ccharthick = float(str)
  str_ccolor = widget_info(idinfo.ccolor_combo, /combobox_gettext)
  inx = where(plotinfo.contour_setting.color_table_str eq str_ccolor)
  plotinfo.contour_setting.ccolor = plotinfo.contour_setting.color_table[inx]
  str = ['Solid', 'Dotted', 'Dashed', 'Dash Dot', 'Dash Dot Dot', 'Long Dashes']
  str_clinestyle = widget_info(idinfo.clinestyle_combo, /combobox_gettext)
  inx = where(str eq str_clinestyle)
  plotinfo.contour_setting.clinestyle = inx
  widget_control, idinfo.clinethick_text, get_value = str
  plotinfo.contour_setting.clinethick = float(str)

; save the plotinfo
  widget_control, idinfo.plot_draw, set_uvalue = plotinfo

end


pro ycshade_contour_setting_window_event, event

; get base widget info
  widget_control, event.top, get_uvalue = parent_id
  widget_control, parent_id, get_uvalue = idinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    ycshade_kill_contour_setting_window, idinfo
    return
  endif

; event due to apply button
  if event.id eq idinfo.contour_setting_apply_button then begin
  ;save the data and replot the graph
    ycshade_save_contour_setting, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    ycshade_replot_all, plotinfo, idinfo.plot_draw
    return
  endif

; event due to cancel button
  if event.id eq idinfo.contour_setting_cancel_button then begin
    ycshade_kill_contour_setting_window, idinfo
    return
  endif

; event due to ok button
  if event.id eq idinfo.contour_setting_ok_button then begin
  ;save the data, then kill the window and redraw the graph
    ycshade_save_contour_setting, idinfo
    ycshade_kill_contour_setting_window, idinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    ycshade_replot_all, plotinfo, idinfo.plot_draw
    return
  endif

end


pro ycshade_create_animation_setting_window, parent_id

; retrieve the necessary data
  widget_control, parent_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo
  animation_setting = plotinfo.animation_setting
  data = plotinfo.data
  nt = n_elements(data.t)

; create the window 
  window_title = 'ycshade: Animation Setting Window'
  base_animation_setting_window = widget_base(/column, title = window_title, xsize = 430, ysize = 450, $
                                              group_leader = parent_id, /tlb_kill_request_events)
    base1 = widget_base(base_animation_setting_window, /column, frame = 1)
      base11 = widget_base(base1, /column)
        label11 = widget_label(base11, value = '<Still Image Information>')
      base12 = widget_base(base1, /row)
        label12 = widget_label(base12, value = 'Select Time Position:          ')
        still_image_tslider = widget_slider(base12, /suppress_value, xsize=220)
        slider_min_max = widget_info(still_image_tslider, /slider_min_max)
        widget_control, still_image_tslider, set_value = fix( (slider_min_max[1]-slider_min_max[0])*data.inx_tframe/(nt-1) ) 
      base13 = widget_base(base1, /row)
        label13 = widget_label(base13, value = '                               Time:   ')
        str = strcompress(string(data.t[data.inx_tframe], format='(f0.8)'), /remove_all)
        str = ycshade_nice_form_str_num(str)
        still_image_time_label = widget_label(base13, /dynamic, value = str)
        label13 = widget_label(base13, value = ' seconds')
    base2 = widget_base(base_animation_setting_window, /column, frame = 1)
      base21 = widget_base(base2, /column)
        label21 = widget_label(base21, value = '<Animation Information>')
      base22 = widget_base(base2, /row)
        label22 = widget_label(base22, value = 'Select Starting Time Position: ')
        ani_start_tslider = widget_slider(base22, /suppress_value, /drag, xsize = 220)
        slider_min_max = widget_info(ani_start_tslider, /slider_min_max)
        widget_control, ani_start_tslider, set_value = fix( (slider_min_max[1]-slider_min_max[0])*animation_setting.inx_tstart/(nt-1) ) 
      base23 = widget_base(base2, /row)
        label23 = widget_label(base23, value = 'Select Ending Time Position:   ')
        ani_end_tslider = widget_slider(base23, /suppress_value, /drag, xsize = 220)
        slider_min_max = widget_info(ani_end_tslider, /slider_min_max)
        widget_control, ani_end_tslider, set_value = fix( (slider_min_max[1]-slider_min_max[0])*animation_setting.inx_tend/(nt-1) ) 
      base24 = widget_base(base2, /row)
        label24 = widget_label(base24, value = '    Time: [ ')
        str = strcompress(string(data.t[animation_setting.inx_tstart], format='(f0.8)'), /remove_all)
        str = ycshade_nice_form_str_num(str)
        ani_tstart_label = widget_label(base24, /dynamic, value = str)
        label24 = widget_label(base24, value = ' ] ~ [ ')
        str = strcompress(string(data.t[animation_setting.inx_tend], format='(f0.8)'), /remove_all)
        str = ycshade_nice_form_str_num(str)
        ani_tend_label = widget_label(base24, /dynamic, value = str)
        label24 = widget_label(base24, value = ' ] seconds')
      base25 = widget_base(base2, /row)
        label25 = widget_label(base25, value = 'Frame Rate:     SLOW  ')
        frame_rate_slider = widget_slider(base25, /suppress_value, xsize = 230)
        label25 = widget_label(base25, value = '  FAST')
        slider_min_max = widget_info(frame_rate_slider, /slider_min_max)
        frate = animation_setting.frame_rate
        frate_range = animation_setting.frame_rate_range
        widget_control, frame_rate_slider, $
                        set_value = fix( (slider_min_max[1]-slider_min_max[0])*frate/(frate_range[1]-frate_range[0]) )
      base26 = widget_base(base2)
        ani_start_button = widget_button(base26, value = 'Start Animation', xoffset = 115, yoffset = 20, xsize = 200, ysize = 35)
    base3 = widget_base(base_animation_setting_window, /column, frame = 1)
      base31 = widget_base(base3, /row)
        label31 = widget_label(base31, value = '<Addtional Title on the Plot>')
      base32 = widget_base(base3, /row)
        label32 = widget_label(base32, value = 'Diaplay:  ')
        add_title_type_combo = widget_combobox(base32, value = animation_setting.add_title_type, xsize = 130)
        widget_control, add_title_type_combo, set_combobox_select = animation_setting.sel_add_title_type
      base33 = widget_base(base3, /row)
        label33 = widget_label(base33, value = 'Prefix:   ')
        add_title_prefix_text = widget_text(base33, /editable, scr_xsize = 130, value = animation_setting.add_title_prefix, /all_events)
        label33 = widget_label(base33, value = '   Postfix:  ')
        add_title_postfix_text = widget_text(base33, /editable, scr_xsize = 130, value = animation_setting.add_title_postfix, /all_events)
    base4 = widget_base(base_animation_setting_window)
      animation_setting_close_button = widget_button(base4, value = 'Close', $
                                                     xsize=100, xoffset=330, yoffset=15)


;save idinfo
  idinfo.base_animation_setting_window = base_animation_setting_window
  idinfo.still_image_tslider = still_image_tslider
  idinfo.still_image_time_label = still_image_time_label
  idinfo.ani_start_tslider = ani_start_tslider
  idinfo.ani_end_tslider = ani_end_tslider
  idinfo.ani_tstart_label = ani_tstart_label
  idinfo.ani_tend_label = ani_tend_label
  idinfo.frame_rate_slider = frame_rate_slider
  idinfo.ani_start_button = ani_start_button
  idinfo.add_title_type_combo = add_title_type_combo
  idinfo.add_title_prefix_text = add_title_prefix_text
  idinfo.add_title_postfix_text = add_title_postfix_text
  idinfo.animation_setting_close_button = animation_setting_close_button

  widget_control, parent_id, set_uvalue = idinfo

; this window needs to know about the parent id
  widget_control, base_animation_setting_window, set_uvalue = parent_id

end


pro ycshade_show_animation_setting_window, idinfo
; realize the animation setting window
  widget_control, idinfo.base_animation_setting_window, /realize

; start the xmanager
  xmanager, 'ycshade_animation_setting_window', idinfo.base_animation_setting_window, /no_block
end

pro ycshade_kill_animation_setting_window, idinfo
; kill the animation setting window
  widget_control, idinfo.base_animation_setting_window, /destroy

; create the animation setting window so that it can be opend later.
  ycshade_create_animation_setting_window, idinfo.base
end


pro ycshade_animation_setting_window_event, event
; get base widget info
  widget_control, event.top, get_uvalue = parent_id
  widget_control, parent_id, get_uvalue = idinfo
  widget_control, idinfo.plot_draw, get_uvalue = plotinfo

; kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    ycshade_kill_animation_setting_window, idinfo
    return
  endif

; event due close button
  if event.id eq idinfo.animation_setting_close_button then begin
    ycshade_kill_animation_setting_window, idinfo
    return
  endif

; event due to still_image_tslider
  if event.id eq idinfo.still_image_tslider then begin
    nt = n_elements(plotinfo.data.t)
    widget_control, idinfo.still_image_tslider, get_value = curr_pos
    slider_min_max = widget_info(idinfo.still_image_tslider, /slider_min_max)
    frac_pos = float(curr_pos) / (float(slider_min_max[1]) - float(slider_min_max[0]))
    curr_inx = frac_pos * (nt - 1)
    plotinfo.data.inx_tframe = long(curr_inx)
    str = strcompress(string(plotinfo.data.t[plotinfo.data.inx_tframe], format='(f0.8)'), /remove_all)
    str = ycshade_nice_form_str_num(str)
    widget_control, idinfo.still_image_time_label, set_value = str

    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  ;replot
    ycshade_replot_all, plotinfo, idinfo.plot_draw
  endif

; event due to ani_start_tslider
  if event.id eq idinfo.ani_start_tslider then begin
    nt = n_elements(plotinfo.data.t)
    widget_control, idinfo.ani_start_tslider, get_value = curr_pos
    slider_min_max = widget_info(idinfo.ani_start_tslider, /slider_min_max)
    frac_pos = float(curr_pos) / (float(slider_min_max[1]) - float(slider_min_max[0]))
    curr_inx = frac_pos * (nt - 1)
    plotinfo.animation_setting.inx_tstart = long(curr_inx)
    str = strcompress(string(plotinfo.data.t[plotinfo.animation_setting.inx_tstart], format='(f0.8)'), /remove_all)
    str = ycshade_nice_form_str_num(str)
    widget_control, idinfo.ani_tstart_label, set_value = str


    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

; event due to ani_end_tslider
  if event.id eq idinfo.ani_end_tslider then begin
    nt = n_elements(plotinfo.data.t)
    widget_control, idinfo.ani_end_tslider, get_value = curr_pos
    slider_min_max = widget_info(idinfo.ani_end_tslider, /slider_min_max)
    frac_pos = float(curr_pos) / (float(slider_min_max[1]) - float(slider_min_max[0]))
    curr_inx = frac_pos * (nt - 1)
    plotinfo.animation_setting.inx_tend = long(curr_inx)
    str = strcompress(string(plotinfo.data.t[plotinfo.animation_setting.inx_tend], format='(f0.8)'), /remove_all)
    str = ycshade_nice_form_str_num(str)
    widget_control, idinfo.ani_tend_label, set_value = str

    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

; event due to frame_rate_slider
  if event.id eq idinfo.frame_rate_slider then begin
    frate_range = plotinfo.animation_setting.frame_rate_range
    widget_control, idinfo.frame_rate_slider, get_value = curr_pos
    slider_min_max = widget_info(idinfo.frame_rate_slider, /slider_min_max)
    frac_pos = float(curr_pos) / (float(slider_min_max[1]) - float(slider_min_max[0]))
    plotinfo.animation_setting.frame_rate = frac_pos * (frate_range[1]-frate_range[0]) + frate_range[0]

    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

; event due to add_title_type_combo
  if event.id eq idinfo.add_title_type_combo then begin
    plotinfo.animation_setting.sel_add_title_type = event.index
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo

  ;replot
    ycshade_replot_all, plotinfo, idinfo.plot_draw
  endif

; event due to add_title_prefix_text
  if event.id eq idinfo.add_title_prefix_text then begin
    widget_control, idinfo.add_title_prefix_text, get_value = str
    plotinfo.animation_setting.add_title_prefix = str
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

; event due to add_title_postfix_text
  if event.id eq idinfo.add_title_postfix_text then begin
    widget_control, idinfo.add_title_postfix_text, get_value = str
    plotinfo.animation_setting.add_title_postfix = str
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

; event due to ani_start_button then begin
  if event.id eq idinfo.ani_start_button then begin
  ;show hourglass and deactivate the button
    widget_control, idinfo.ani_start_button, sensitive = 0
    widget_control, /hourglass

    ycshade_start_animation, idinfo

    widget_control, idinfo.ani_start_button, sensitive = 1

  ;makae still_image_slider position same as that of ani_end_tslider
    nt = n_elements(plotinfo.data.t)
    widget_control, idinfo.ani_end_tslider, get_value = curr_pos
    slider_min_max = widget_info(idinfo.ani_end_tslider, /slider_min_max)
    frac_pos = float(curr_pos) / (float(slider_min_max[1]) - float(slider_min_max[0]))
    curr_tinx = frac_pos * (nt - 1)
    curr_tinx = long(curr_tinx)
    slider_min_max = widget_info(idinfo.still_image_tslider, /slider_min_max)
    widget_control, idinfo.still_image_tslider, set_value = fix( (slider_min_max[1]-slider_min_max[0])*curr_tinx/(nt-1) ) 
    plotinfo.data.inx_tframe = long(curr_tinx)
    str = strcompress(string(plotinfo.data.t[plotinfo.data.inx_tframe], format='(f0.8)'), /remove_all)
    str = ycshade_nice_form_str_num(str)
    widget_control, idinfo.still_image_time_label, set_value = str

    widget_control, idinfo.plot_draw, set_uvalue = plotinfo
  endif

end


pro ycshade_save_figure_window_event, event
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


pro ycshade_save_figure_window, parent_id
; create widget for save_figure widget

  window_title = 'Save Figure for ycshade'
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
  xmanager, 'ycshade_save_figure_window', base

end

pro ycshade_save_data_window_event, event
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



pro ycshade_save_data_window, parent_id
; create widget for save_data widget

  window_title = 'Save Data for ycshade'
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
  xmanager, 'ycshade_save_data_window', base
end

pro ycshade_save_ani_window_event, event
; get save_figure_window id
  widget_control, event.top, get_uvalue = save_ani_id

;kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    widget_control, save_ani_id.base, /destroy
  endif

;event due to save button
  if event.id eq save_ani_id.save_button then begin
    widget_control, save_ani_id.filename_text, get_value = str
    filename = str
    extension = '.mpg'
    filename = str + extension
    widget_control, save_ani_id.save_button, sensitive = 0
    widget_control, save_ani_id.parent_id, get_uvalue = idinfo
    widget_control, /hourglass
    ycshade_start_animation, idinfo, filename = filename, mesg_box = save_ani_id.mesg_text
    widget_control, save_ani_id.save_button, sensitive = 1
    widget_control, save_ani_id.base, /destroy
  endif

;event due to cancel button
  if event.id eq save_ani_id.cancel_button then begin
    widget_control, save_ani_id.base, /destroy
  endif

end

pro ycshade_save_ani_window, parent_id
; create widget for save_data widget

  window_title = 'Save Animation for ycshade'
  base = widget_base(/column, title = window_title, xsize = 300, ysize = 230, /modal, $
                     group_leader = parent_id, /tlb_kill_request_events)
    base1 = widget_base(base, /row)
      label = widget_label(base1, value = 'File name:     ')
      filename_text = widget_text(base1, /editable, scr_xsize = 170)
      label = widget_label(base1, value = '.mpg')
    base2 = widget_base(base, /column)
      note_str = 'Note:' + string(10b) + $
                 'If there exists a file with the same filename,' + string(10b) + $ 
                 'then this will overwrite the file'
      label = widget_label(base2, value = note_str, /align_left)
    base3 = widget_base(base, /column)
      label3 = widget_label(base3, value = '<Message Box>', /align_left)
      mesg_text = widget_text(base3, value = '', /scroll, /wrap, scr_xsize = 290, scr_ysize = 70)
    base4 = widget_base(base)
      cancel_button = widget_button(base4, value = 'Cancel', xsize = 100, xoffset=90, yoffset = 10)
      save_button = widget_button(base4, value = 'Save', xsize = 100, xoffset = 200, yoffset = 10)


  save_ani_id = {parent_id:parent_id, $
                      base:base, $
                        filename_text:filename_text, $
                        cancel_button:cancel_button, $
                        save_button:save_button, $
                        mesg_text:mesg_text}

  widget_control, base, set_uvalue = save_ani_id
  widget_control, base, /realize
  xmanager, 'ycshade_save_ani_window', base
end






pro ycshade_mouse_button_down, event, idinfo
;event.press = 1 --> left button
;            = 2 --> middle button
;            = 4 --> right button

  if event.press eq 1 then begin	;left button is pressed: prepare for zoomming
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

pro ycshade_mouse_button_up, event, idinfo
;event.release = 1 --> left button
;              = 2 --> middle button
;              = 4 --> right button

  if event.release eq 1 then begin		;left button is released: zoom-in
  ; deactivate the mouse motion
    widget_control, event.id, draw_motion_events = 0
  ; remove the highlight
    ycshade_draw_highlight, idinfo
  ; get the current zoom range in device coordinate
    mouse_xr_device = [idinfo.mouse.x0 < idinfo.mouse.x1, idinfo.mouse.x0 > idinfo.mouse.x1]
    mouse_yr_device = [idinfo.mouse.y0 < idinfo.mouse.y1, idinfo.mouse.y0 > idinfo.mouse.y1]
    xyz_direction = idinfo.mouse.xyz_direction
  ; reset the mouse info
    idinfo.mouse.left_middle = 0
    idinfo.mouse.xyz_direction = 0
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

  ;change the x, y or z-range
    draw_size = idinfo.draw_size
    plot_xr_device = [plotinfo.plot_setting.plot_pos[0], plotinfo.plot_setting.plot_pos[2]] * draw_size.x
    plot_yr_device = [plotinfo.plot_setting.plot_pos[1], plotinfo.plot_setting.plot_pos[3]] * draw_size.y
    scale_xr_device = [plotinfo.plot_setting.scale_pos[0], plotinfo.plot_setting.scale_pos[2]] * draw_size.x
    scale_yr_device = [plotinfo.plot_setting.scale_pos[1], plotinfo.plot_setting.scale_pos[3]] * draw_size.y
    xrange = plotinfo.plot_setting.xrange
    yrange = plotinfo.plot_setting.yrange
    zrange = plotinfo.plot_setting.zrange
    if xyz_direction eq 1 then begin		;change x-range
    ;note:
    ;plot_xr_device[0] : xrange[0]
    ;plot_xr_device[1] : xrange[1]
      fraction = (mouse_xr_device-plot_xr_device[0]) / (plot_xr_device[1] - plot_xr_device[0])
      plotinfo.plot_setting.xrange = xrange[0] + fraction * (xrange[1] - xrange[0])
      str = strcompress(string(plotinfo.plot_setting.xrange[0]), /remove_all)
      widget_control, idinfo.xrange_min_text, set_value = str
      str = strcompress(string(plotinfo.plot_setting.xrange[1]), /remove_all)
      widget_control, idinfo.xrange_max_text, set_value = str
    endif else if xyz_direction eq 2 then begin	;change y-range
    ;note:
    ;plot_yr_device[0] : yrange[0]
    ;plot_yr_device[1] : yrange[1]
      fraction = (mouse_yr_device-plot_yr_device[0]) / (plot_yr_device[1] - plot_yr_device[0])
      plotinfo.plot_setting.yrange = yrange[0] + fraction * (yrange[1] - yrange[0])
      str = strcompress(string(plotinfo.plot_setting.yrange[0]), /remove_all)
      widget_control, idinfo.yrange_min_text, set_value = str
      str = strcompress(string(plotinfo.plot_setting.yrange[1]), /remove_all)
      widget_control, idinfo.yrange_max_text, set_value = str
    endif else if xyz_direction eq 3 then begin	;change z-range (scale-range)
    ; note:
    ; scale_yr_device[0] : zrange[0]
    ; scale_yr_device[1] : zrange[1]
      fraction = (mouse_yr_device-scale_yr_device[0])/(scale_yr_device[1]-scale_yr_device[0])
      if plotinfo.plot_setting.zlog eq 1 then begin
      ;if z or zrange value of less than zero then, I need to remove it because alog10(negative or zero) gives an error.
        z = reform(plotinfo.data.z[*, *, plotinfo.data.inx_tframe])
        inx_zero = where(z le 0.0, count_zero)
        if count_zero gt 0 then $
          z[inx_zero] = !values.f_nan
        if zrange[0] le 0.0 then $
          zrange[0] = abs(min(z, /abs, /nan))
        if zrange[1] le 0.0 then $
          zrange[1] = abs(max(z, /abs, /nan))
        zrange = alog10(zrange)
        plotinfo.plot_setting.zrange =  10^(zrange[0] + fraction*(zrange[1] - zrange[0]))
      endif else begin
        plotinfo.plot_setting.zrange =  zrange[0] + fraction*(zrange[1] - zrange[0])
      endelse
      str = strcompress(string(plotinfo.plot_setting.zrange[0]), /remove_all)
      widget_control, idinfo.zrange_min_text, set_value = str
      str = strcompress(string(plotinfo.plot_setting.zrange[1]), /remove_all)
      widget_control, idinfo.zrange_max_text, set_value = str
    endif else begin
    ;do nothing

    endelse

  ; save the plotinfo
    widget_control, idinfo.plot_draw, set_uvalue = plotinfo

  ; restore the system variables
    !p = psys
    !x = xsys
    !y = ysys
    !z = zsys

  ; redraw the plot
    ycshade_replot_all, plotinfo, idinfo.plot_draw
  endif else if event.release eq 2 then begin	;middle button is release: stop panning
  ; deactivate the mouse motion
    widget_control, event.id, draw_motion_events = 0
  ; reset the mouse info
    idinfo.mouse.left_middle = 0
  ; save the idinfo
    widget_control, idinfo.base, set_uvalue = idinfo

  ; get the plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo

  ; update the xrange and yrange text boxes
    str = strcompress(string(plotinfo.plot_setting.xrange[0]), /remove_all)
    widget_control, idinfo.xrange_min_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.xrange[1]), /remove_all)
    widget_control, idinfo.xrange_max_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.yrange[0]), /remove_all)
    widget_control, idinfo.yrange_min_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.yrange[1]), /remove_all)
    widget_control, idinfo.yrange_max_text, set_value = str

  endif else if event.release eq 4 then begin	;right button is released: reset the plot
  ; get the plotinfo
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo

  ; find the min and max of data
    data = plotinfo.data
    xmin = min(data.x, max = xmax)
    ymin = min(data.y, max = ymax)
    zmin = min(data.z[*, *, data.inx_tframe], max = zmax)

  ; reset the ranges
    plotinfo.plot_setting.xrange = [xmin, xmax]
    plotinfo.plot_setting.yrange = [ymin, ymax]
    plotinfo.plot_setting.zrange = [zmin, zmax]

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
    str = strcompress(string(plotinfo.plot_setting.zrange[0]), /remove_all)
    widget_control, idinfo.zrange_min_text, set_value = str
    str = strcompress(string(plotinfo.plot_setting.zrange[1]), /remove_all)
    widget_control, idinfo.zrange_max_text, set_value = str

  ;redraw the plot
    ycshade_replot_all, plotinfo, idinfo.plot_draw
  endif else begin
  ;do nothing

  endelse 

end


pro ycshade_mouse_button_move, event, idinfo

  if idinfo.mouse.left_middle eq 1 then begin			;left button motion: zoom

  ; delete the current highlight
    ycshade_draw_highlight, idinfo
  ; save the current mouse position
    idinfo.mouse.x1 = event.x
    idinfo.mouse.y1 = event.y
    x_motion = abs(idinfo.mouse.x1 - idinfo.mouse.x0)
    y_motion = abs(idinfo.mouse.y1 - idinfo.mouse.y0)
  ; decide whether x, y or z-direction zoom is required
    widget_control, idinfo.plot_draw, get_uvalue = plotinfo
    draw_size = idinfo.draw_size
    scale_xr_device = [plotinfo.plot_setting.scale_pos[0], plotinfo.plot_setting.scale_pos[2]] * draw_size.x
    if( (idinfo.mouse.x0 ge scale_xr_device[0]) and (plotinfo.plot_setting.showscale eq 1) )then begin
      idinfo.mouse.xyz_direction = 3	;z-direction (scale) zoom
    endif else begin
      if x_motion ge y_motion then $
        idinfo.mouse.xyz_direction = 1 $	;x-direction zoom
      else $
        idinfo.mouse.xyz_direction = 2 	;y-direction zoom
    endelse

  ; save the idinfo
    widget_control, idinfo.base, set_uvalue = idinfo
  ; draw the highlight again 
    ycshade_draw_highlight, idinfo
  endif else if idinfo.mouse.left_middle eq 2 then begin	;middle button motion: panning
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
    ycshade_replot_all, plotinfo, idinfo.plot_draw
  endif else begin
  ; do nothing

  endelse

end


pro ycshade_mouse_event, event, idinfo
; event.type = 0 --> button down
;            = 1 --> button up
;            = 2 --> button move

  if event.type eq 0 then $	;button down
    ycshade_mouse_button_down, event, idinfo

  if event.type eq 1 then $	;button up
    ycshade_mouse_button_up, event, idinfo

  if event.type eq 2 then $	;mouse move
    ycshade_mouse_button_move, event, idinfo
end



pro ycshade_event, event
; get idinof
  widget_control, event.top, get_uvalue = idinfo

;kill_request is received
  if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    widget_control, idinfo.plot_draw, get_value = win
    wdelete, win

    widget_control, idinfo.base, /destroy
  endif

; event due to plot_setting_button
  if event.id eq idinfo.plot_setting_button then begin
  ;show the plot setting window
    ycshade_show_plot_setting_window, idinfo
  endif

; event due to contour_setting_button
  if event.id eq idinfo.contour_setting_button then begin
  ;show the contour line setting window
    ycshade_show_contour_setting_window, idinfo
  endif

; event due to ani_setting_button
  if event.id eq idinfo.ani_setting_button then begin
  ;show the animation setting window
    ycshade_show_animation_setting_window, idinfo
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
          ycshade_replot_all, plotinfo, idinfo.plot_draw , /psplot
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

; event due to save_ani_button
  if event.id eq idinfo.save_ani_button then begin
    ycshade_save_ani_window, idinfo.base
  endif

; event due to mouse motion on plot_draw
  if event.id eq idinfo.plot_draw then begin
    widget_control, idinfo.plot_draw, get_value = win
    wset, win

    ycshade_mouse_event, event, idinfo
  endif


end





;=================================================================
; Main-routine for ycshade
;=================================================================

pro ycshade, zdata, xdata, ydata, tdata, $
             saved_file = in_saved_file, $
             title = in_title, xtitle = in_xtitle, ytitle = in_ytitle, ztitle = in_ztitle, zlog = in_zlog, $
             xsize = in_xsize, ysize = in_ysize, plot_pos = in_plot_pos, scale_pos = in_scale_pos, $
             ctable_num = in_ctable_num, ctable_invert = in_ctable_invert, curr_inx_tframe = in_curr_inx_tframe, $
             description = in_description, note = in_note

  MAX_CONTOUR_LINES = 20
  version = 1.0
  prog_name = 'ycshade'

  if keyword_set(in_saved_file) then begin
    saved_file = in_saved_file
    restore, saved_file
    if( plotinfo.version ne version ) then begin
      print, 'The saved_file is created with INCOMPATIBLE version of ycplot.  Exit the program.'
      return
    endif
    if( plotinfo.prog_name ne prog_name ) then begin
      print, 'The saved_file is NOT created by ycshade.  Exit the program.'
      return
    endif
    print, 'All the input parameters will be ignored and saved parameters are loaded!'
    nx = n_elements(plotinfo.data.x)
    ny = n_elements(plotinfo.data.y)
    nt = n_elements(plotinfo.data.t)
    goto, start_widget
  endif


;====== check the zdata, xdata, ydata and tdata parameters =======
  npar = n_params()
  if npar eq 0 then begin
  ; no data are specified.  
    print, 'No data are specified.  Exit the program.'
    return
  endif else begin
  ; check whether z is defined variable
    if size(zdata, /type) eq 0 then begin
      print, 'zdata is not defined.  Exit the program.'
      return
    endif
    z = reform(zdata)
  ; check dimension of z
    z_size = size(z)
    z_ndim = z_size[0]
    if z_ndim le 1 then begin
      print, 'zdata must be at least 2-dimensional.  Exit the program'
      return
    endif else if z_ndim ge 4 then begin
      print, 'zdata must be less than or equal to 3-dimensional.  Exit the program'
      return
    endif
    nx = z_size[1]
    ny = z_size[2]
    if z_ndim eq 3 then $
      nt = z_size[3] $
    else $
      nt = 1
    if npar eq 1 then begin
    ; only zdata is provided.
      x = findgen(nx)
      y = findgen(ny)
      t = findgen(nt)
    endif else if npar eq 2 then begin
    ; only zdata and xdata are provided
    ; check xdata
      if size(xdata, /type) eq 0 then begin
        print, 'xdata is not defined.  Exit the program.'
        return
      endif
      x = reform(xdata)
      y = findgen(ny)
      t = findgen(nt)
    endif else if npar eq 3 then begin
    ; zdata, xdata and ydata are provided.
    ; check xdata and ydata
      if( (size(xdata, /type) eq 0) or (size(ydata, /type) eq 0) )then begin
        print, 'xdata and/or ydata are not defined.  Exit the program.'
        return
      endif
      x = reform(xdata)
      y = reform(ydata)
      t = findgen(nt)
    endif else begin
    ; zdata, xdata, ydata and tdata are provided.
    ; check xdata and ydata and tdata
      if( (size(xdata, /type) eq 0) or (size(ydata, /type) eq 0) or (size(tdata, /type) eq 0) )then begin
        print, 'xdata, ydata and/or tdata are not defined.  Exit the program.'
        return
      endif
      x = reform(xdata)
      y = reform(ydata)
      t = reform(tdata)
    endelse
    ; check dimensions of x, y and t
    x_size = size(x)
    y_size = size(y)
    t_size = size(t)
    if( (x_size[0] ne 1) or (y_size[0] ne 1) or (t_size[0] ne 1) ) then begin
      print, 'xdata, ydata and tdata must be 1-dimensional array.  Exit the program.'
      return
    endif
    if( (nx ne x_size[1]) or (ny ne y_size[1]) or (nt ne t_size[1]) ) then begin
      print, 'Dimensions of input parameters do not match.  Exit the program.'
      return
    endif
  endelse


;====== create the plotinfo structure =======
; check keywords
  if not keyword_set(in_title) then $
    title = 'z vs. (x, y)' $
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

  if not keyword_set(in_ztitle) then $
    ztitle = 'z' $
  else $
    ztitle = in_ztitle

  if not keyword_set(in_zlog) then $
    zlog = 0 $
  else $
    zlog = in_zlog

  if not keyword_set(in_description) then $
    description = '' $
  else $
    description = in_description

  if not keyword_set(in_note) then $
    note = '' $
  else $
    note = in_note

  if not keyword_set(in_plot_pos) then $
    plot_pos = [0.1, 0.1, 0.88, 0.9] $
  else $
    plot_pos = in_plot_pos

  if not keyword_set(in_scale_pos) then $
    scale_pos = [0.90, 0.1, 0.93, 0.9] $
  else $
    scale_pos = in_scale_pos

  if not defined(in_ctable_num) then $
    ctable_num = 5 $
  else $
    ctable_num = in_ctable_num

  if not keyword_set(in_ctable_invert) then $
    ctable_invert = 0 $
  else $
    ctable_invert = 1

  if not keyword_set(in_curr_inx_tframe) then $
    curr_inx_tframe = long(0) $
  else $
    curr_inx_tframe = long(in_curr_inx_tframe)

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


; get ctable names
  loadct, get_names = ctable_str

; make the plotinfo structure
  data = {z:z, x:x, y:y, t:t, inx_tframe:curr_inx_tframe}
  plot_setting = {title:title, $
                  xtitle:xtitle, $
                  ytitle:ytitle, $
                  ztitle:ztitle, $
                  xrange:float([min(x, /nan), max(x, /nan)]), $
                  yrange:float([min(y, /nan), max(y, /nan)]), $
                  zrange:float([min(z, /nan), max(z, /nan)]), $
                  zlog:zlog, $
                  isotropic:0, $
                  charsize:1.0, $
                  charthick:1.0, $
                  ctable_invert:ctable_invert, $		;invert the color indes for ctable
                  ctable:ctable_num,$			;ctable. from loadct
                  plot_pos:plot_pos, $	;4-elements array [x0,y0,x1,y1] for plot position in noramalized unit
                  scale_pos:scale_pos, $	;4-elements array [x0,y0,x1,y1] for scale position in noramalized unit
                  showscale:1, $
                  box_contour:0, $
                  grid_line:0, $
                  ctable_str:ctable_str}
  clevels = fltarr(MAX_CONTOUR_LINES)
  clevels[*] = !values.f_nan			;note use finite() to check whethter c_levels are finite or not.
  contour_setting = {downhill:0, $
                     autocontour:1, $		;from 1 to 20. sets the number of contour lines
                     clevels:clevels, $		;set the value of contour lines manually.
                     clabel:0, $		;if 0, then show contour labels, otherwise do not show the labels
                     ccharsize:1.0, $		;char. size of contour labels
                     ccharthick:1.0, $		;char. thickness of contour labels
                     ccolor:color_table[0], $	;contour line color
                     clinestyle:0, $		;contour line linestyle
                     clinethick:1.0, $		;contour line thickness
                     color_table_str:color_table_str, $
                     color_table:color_table}
  animation_setting = {inx_tstart:0l, $
                       inx_tend:nt-1, $
                       frame_rate_range:[1.0, 100.0], $	;Number of frames per seconds
                       frame_rate:100.0, $
                       add_title_type:['None', 'Time Data', 'Frame Number'], $
                       sel_add_title_type:0l, $
                       add_title_prefix:'', $
                       add_title_postfix:''}

  sys_var = {p:!p, $
             x:!x, $
             y:!y, $
             z:!z}

  plotinfo = {data:data, $
              plot_setting:plot_setting, $
              contour_setting:contour_setting, $
              animation_setting:animation_setting, $
              sys_var:sys_var, $
              description:description, $
              note:note, $
              MAX_CONTOUR_LINES:MAX_CONTOUR_LINES, $
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

  window_title = 'ycshade Version ' + strcompress(string(plotinfo.version, format='(f3.1)'), /remove_all)
  base = widget_base(/column, title = window_title, /tlb_kill_request_events)
    setting_base = widget_base(base, /row, xsize = xsize, ysize = 30, frame = 1)
      plot_setting_button = widget_button(setting_base, value = 'Plot Set...')
      contour_setting_button = widget_button(setting_base, value = 'Contour Lines Set...')
      ani_setting_button = widget_button(setting_base, value = 'Animation Set...')
      if nt le 1 then widget_control, ani_setting_button, sensitive = 0
      save_figure_button = widget_button(setting_base, value = 'Save Figure...')
      save_data_button = widget_button(setting_base, value = 'Save Data...')
      save_ani_button = widget_button(setting_base, value = 'Save Animation...')
      if nt le 1 then widget_control, save_ani_button, sensitive = 0
    description_base = widget_base(base, /row, xsize = xsize)
      description_label = widget_label(description_base, value = 'Plot Description: ')
      description_text = widget_text(description_base, value = plotinfo.description, /scroll, /wrap, scr_xsize = xsize - 120)
    plot_draw = widget_draw(base, xsize = xsize, ysize = ysize,  /button_event, retain = 2)
    str_info = 'Zoom: Hold left mouse button.  Pan: Hold middle mouse button.  Reset: Click right mouse button'
    info_label = widget_label(base, value = str_info)

  mouse = {x0:0l, x1: 0l, y0:0l, y1:0l, left_middle:0, graphic_mode:0, xyz_direction:0}
  draw_size = {x:xsize, y:ysize}	;in device units

  idinfo = {base:base, $
              plot_setting_button:plot_setting_button, $
              contour_setting_button:contour_setting_button, $
              ani_setting_button:ani_setting_button, $
              save_figure_button:save_figure_button, $
              save_data_button:save_data_button, $
              save_ani_button:save_ani_button, $
              description_text:description_text, $
              plot_draw:plot_draw, $
            base_plot_setting_window:0l, $
              plot_set_description_text:0l, $
              title_text:0l, $
              xtitle_text:0l, $
              ytitle_text:0l, $
              ztitle_text:0l, $
              charsize_text:0l, $
              charthick_text:0l, $
              xrange_min_text:0l, $
              xrange_max_text:0l, $
              yrange_min_text:0l, $
              yrange_max_text:0l, $
              zrange_min_text:0l, $
              zrange_max_text:0l, $
              zaxis_linear_button:0l, $
              zaxis_log_button:0l, $
              ctable_sel_combo:0l, $
              ctable_invert_button:0l, $
              showscale_button:0l, $
              box_contour_button:0l, $
              grid_line_button:0l, $
              isotropic_button:0l, $
              plot_pos_x0_text:0l, $
              plot_pos_y0_text:0l, $
              plot_pos_x1_text:0l, $
              plot_pos_y1_text:0l, $
              scale_pos_x0_text:0l, $
              scale_pos_y0_text:0l, $
              scale_pos_x1_text:0l, $
              scale_pos_y1_text:0l, $
              show_zx_button:0l, $
              show_zy_button:0l, $
              plot_setting_apply_button:0l, $
              plot_setting_cancel_button:0l, $
              plot_setting_ok_button:0l, $
            base_contour_setting_window:0l, $
              autocontour_combo:0l, $
              ccolor_combo:0l, $
              clevels_text:0l, $
              clinestyle_combo:0l, $
              clinethick_text:0l, $
              showlabel_button:0l, $
              downhill_button:0l, $
              ccharsize_text:0l, $
              ccharthick_text:0l, $
              contour_setting_apply_button:0l, $
              contour_setting_cancel_button:0l, $
              contour_setting_ok_button:0l, $
            base_animation_setting_window:0l, $
              still_image_tslider:0l, $
              still_image_time_label:0l, $
              ani_start_tslider:0l, $
              ani_end_tslider:0l, $
              ani_tstart_label:0l, $
              ani_tend_label:0l, $
              frame_rate_slider:0l, $
              ani_start_button:0l, $
              add_title_type_combo:0l, $
              add_title_prefix_text:0l, $
              add_title_postfix_text:0l, $
              animation_setting_close_button:0l, $
            mouse:mouse, $
            draw_size:draw_size, $
            save_figure_filename:'', $
            save_data_filename:'', $
            save_movie_filename:''}


; save the user values
  widget_control, base, set_uvalue = idinfo
  widget_control, plot_draw, set_uvalue = plotinfo

; create optional windows
  ycshade_create_plot_setting_window, base
  ycshade_create_contour_setting_window, base
  ycshade_create_animation_setting_window, base

; realize the widget
  widget_control, base, /realize

; plot
  ycshade_replot_all, plotinfo, plot_draw, /first

; start xmanager
  xmanager, 'ycshade', base, /no_block
end