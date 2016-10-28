; This is a widget-based (GUI) program to show bes data



;=================================================
; event handler
;=================================================

PRO show_bes_data_widget_event, event
; get base widget info
  widget_control, event.top, get_uvalue = idinfo

; kill_request is received
  if (tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST') or (event.id eq idinfo.quit_button) then begin
  ; destroy the window
    widget_control, idinfo.base, /destroy
    return
  end

; event due to shot_number_text
  if event.id eq idinfo.shot_number_text then begin
    widget_control, idinfo.shot_number_text, get_value = str_shotnumber
    shot_number = LONG(str_shotnumber[0])
    if shot_number LE idinfo.old_bes_system_shot_end then begin
      widget_control, idinfo.old_new_indicator_label, set_value = '                                                         -------------------------------------------'
    endif else begin
      widget_control, idinfo.old_new_indicator_label, set_value = '            ----------------------------------------------------------------------------------------'
    endelse
  endif

; event due to ch_sel_all_button
  if event.id eq idinfo.ch_sel_all_button then begin
    for i=0, idinfo.total_num_bes_ch-1 do begin
      widget_control, idinfo.bes_ch_button[i], set_button = 1
    endfor
  endif

; event due to ch_desel_all_button
  if event.id eq idinfo.ch_desel_all_button then begin
    for i=0, idinfo.total_num_bes_ch-1 do begin
      widget_control, idinfo.bes_ch_button[i], set_button = 0
    endfor
  endif

; event due to plot_button or oplot_button
  if (event.id eq idinfo.plot_button) or (event.id eq idinfo.oplot_button) then begin
    widget_control, idinfo.message_text, set_value = ''
    widget_control, idinfo.shot_number_text, get_value = str_shotnumber
    shot_number = LONG(str_shotnumber[0])
    str_server = widget_info(idinfo.server_combo, /combobox_gettext)
    if str_server eq idinfo.server[0] then begin
      fusion01 = 1
      bes03 = 0
    endif else begin
      fusion01 = 0
      bes03 = 1  
    endelse
    widget_control, idinfo.time_range_from_text, get_value = str_time_range_from
    widget_control, idinfo.time_range_to_text, get_value = str_time_range_to
    time_range = [float(str_time_range_from[0]), float(str_time_range_to[0])]
    if time_range[1] LE time_range[0] then begin
      widget_control, idinfo.message_text, set_value = 'Invalid time range.'
      return
    endif
    widget_control, idinfo.freq_range_from_text, get_value = str_freq_range_from
    widget_control, idinfo.freq_range_to_text, get_value = str_freq_range_to
    freq_range = [float(str_freq_range_from[0]), float(str_freq_range_to[0])]*1e3 ;change form [kHz] to [Hz]
    if freq_range[1] LE freq_range[0] then begin
      widget_control, idinfo.message_text, set_value = 'Invalid frequency range.'
      return
    endif

    if event.id eq idinfo.plot_button then begin
    ; for 'plot_all'
      bes_plot_all_ch_data, shot_number, trange = time_range, freq_filter = freq_range, fusion01=fusion01, bes03=bes03, error_out = error_out    
      if error_out ne 0 then begin
        widget_control, idinfo.message_text, set_value = 'Failed to read BES data shot number ' + string(shot_number, format='(i0)') + $
                                                         ' from the server ' + str_server + '.' 
        return
      endif
      if widget_info(idinfo.show_position_button, /button_set) eq 1 then begin
        if fusion01 eq 1 then $
          bes_pos = bes_read_position(shot_number, /plot, /ijwkim) $
        else $
          bes_pos = bes_read_position(shot_number, /plot, /bes03)
        if bes_pos.err eq 1 then begin
          widget_control, idinfo.message_text, set_value = 'Failed to read BES position shot number ' +  string(shot_number, format='(i0)') + $
                                                           ' from the server ' + str_server + '.' 
          return
        endif
      endif    
    endif else begin
    ; for 'over plot'
      first_flag = 1
      for i=0, idinfo.total_num_bes_ch - 1 do begin
        if widget_info(idinfo.bes_ch_button[i], /button_set) eq 1 then begin
          str_column = strcompress(string(fix(i/idinfo.num_horizontal_ch)+1, format='(i0)'), /remove_all)
          str_row = strcompress(string(fix(i mod idinfo.num_horizontal_ch)+1, format='(i0)'), /remove_all)
          str_ch_number = str_column + '-' + str_row
          data_struct = bes_read_data(shot_number, str_ch_number, trange = time_range, freq_filter=freq_range, fusion01=fusion01, bes03=bes03)
          if data_struct.err LT 0 then begin
            widget_control, idinfo.message_text, set_value = 'Failed to read BES data shot number ' + string(shot_number, format='(i0)') + $
                                                             ' ch ' + str_ch_number + ' from the server ' + str_server + '.', /append
          endif else begin
            if first_flag eq 1 then begin
              str_title = 'BES data for ' + string(shot_number, format='(i0)') + ' from [' + $
                          string(time_range[0], format='(f0.0)') + ', ' + string(time_range[1], format='(f0.0)') + '] sec in [' + $
                          string(freq_range[0]/1e3, format='(f0.0)') + ', ' + string(freq_range[1]/1e3, format='(f0.0)') + '] kHz'
              ycplot, data_struct.tvector, data_struct.data, legend_item = str_ch_number, title=str_title, out_base_id = oplot_id
              first_flag = 0
            endif else begin
              ycplot, data_struct.tvector, data_struct.data, legend_item = str_ch_number, oplot_id = oplot_id
            endelse
         endelse
        endif
      endfor
    endelse
  endif


END




;==================================================
; Main-routine for show_bes_data_widget
;==================================================

PRO show_bes_data_widget

  version = 0.1
  num_horizontal_ch = 16
  num_vertical_ch = 4
  total_num_bes_ch = num_horizontal_ch * num_vertical_ch

; Create a structure for the widget
  shotnumber = ''
  bes_ch_sel = INTARR(total_num_bes_ch)+1
  time_range = [0.0, 0.0] ;in seconds
  freq_range = [0.0, 500.0] ;in kHz
  server = ['fusion01_KAIST', 'bes03_NFRI']
  baseinfo = {shotnumber:shotnumber, $
              bes_ch_sel:bes_ch_sel, $
              time_range:time_range, $
              freq_range:freq_range, $
              server:server, $
              old_bes_system_shot_end:9427}

; read the dafault values from show_bes_data_widget.def
  openr, lun, '/home/ycghim/IDL/BES_routines/show_bes_data_widget.def', /get_lun
  line = ''

  readf, lun, line ;reading the first line containing shot number
  temp_def = strsplit(line, ' ', /extract)
  baseinfo.shotnumber = temp_def[0] ;get the default shot number

  readf, lun, line ;reading the second line containing time range in seconds
  temp_def = strsplit(line, ' ', /extract)
  baseinfo.time_range = [FLOAT(temp_def[0]), FLOAT(temp_def[1])] ;get the time range
  
  readf, lun, line ;reading the third line containing freq range in kHz  
  temp_def = strsplit(line, ' ', /extract)
  baseinfo.freq_range = [FLOAT(temp_def[0]), FLOAT(temp_def[1])] ;get the freq range
 
  readf, lun, line ; reading the fourth line containing server
  temp_def = strsplit(line, ' ', /extract)
  def_server_str = temp_def[0]
  free_lun, lun

; create widget
  xsize = 650
  ysize = 645

  window_title = 'Show BES data v.' + strcompress(string(version, format='(f0.2)'), /remove_all)
  base = widget_base(/column, title = window_title, /tlb_kill_request_events, xsize=xsize, ysize=ysize)
  widget_control, base, base_set_title = window_title
  shot_number_base = widget_base(base, /row, xsize = xsize, ysize = 30)
    shot_number_label = widget_label(shot_number_base, value = 'Shot Number ')
    shot_number_text = widget_text(shot_number_base, value = baseinfo.shotnumber, /all_events, /editable, xsize=10)
    server_label = widget_label(shot_number_base, value = '             Server ')
    server_combo = widget_combobox(shot_number_base, value = server)
    widget_control, server_combo, set_combobox_select = where(strupcase(baseinfo.server) eq strupcase(def_server_str))
  option_base = widget_base(base, /column, xsize = xsize, ysize = 75, frame = 1)
    option_base1 = widget_base(option_base, /row, xsize = xsize, ysize = 30)
      time_range_from_label = widget_label(option_base1, value = 'Time range           from ')
      time_range_from_text = widget_text(option_base1, xsize=10, value = strcompress(string(baseinfo.time_range[0], format='(f0.0)'), /remove_all), /editable)
      time_range_to_label = widget_label(option_base1, value = ' to ')
      time_range_to_text = widget_text(option_base1, xsize=10, value = strcompress(string(baseinfo.time_range[1], format='(f0.0)'), /remove_all), /editable)
      time_range_unit_label = widget_label(option_base1, value = ' [sec]')
    option_base2 = widget_base(option_base, /row, xsize = xsize, ysize = 30)
      freq_range_from_label = widget_label(option_base2, value = 'Frequency Filtering  from ')
      freq_range_from_text = widget_text(option_base2, xsize=10, value = strcompress(string(baseinfo.freq_range[0], format='(f0.0)'), /remove_all), /editable)
      freq_range_to_label = widget_label(option_base2, value = ' to ')
      freq_range_to_text = widget_text(option_base2, xsize=10, value = strcompress(string(baseinfo.freq_range[1], format='(f0.0)'), /remove_all), /editable)
      freq_range_unit_label = widget_label(option_base2, value = ' [kHz]')
  ch_base = widget_base(base, /column, xsize = xsize, frame = 1)
    bes_ch_button = LONARR(total_num_bes_ch)
    ch_base1 = widget_base(ch_base, /row, xsize = xsize, ysize = 30)
      ch_selection_label = widget_label(ch_base1, value = 'Select BES channels       ')
      ch_sel_all_button = widget_button(ch_base1, value = '  Select All  ')
      ch_selection_label = widget_label(ch_base1, value = '   ')
      ch_desel_all_button = widget_button(ch_base1, value = '  Deselect All  ')
    ch_base2 = widget_base(ch_base, /column, xsize = xsize)
      ch_base21 = widget_base(ch_base2, /row, xsize = xsize, ysize = 20)
        bes_ch_label = widget_label(ch_base21, value = '            16    15   14    13    12    11   10    9     8     7    6     5     4    3     2    1 ')
    for j=0, num_vertical_ch-1 do begin
      ch_base22 = widget_base(ch_base2, /row)
        bes_ch_label = widget_label(ch_base22, value = '        '+strcompress(string(4-j, format='(i0)'), /remove_all)+' ')
        ch_base221 = widget_base(ch_base22, /row, /nonexclusive)
        for i=0, num_horizontal_ch-1 do begin
          inx_button = ((num_vertical_ch-j)*num_horizontal_ch-1)-i
          bes_ch_button[inx_button] = widget_button(ch_base221, value=' ')
          widget_control, bes_ch_button[inx_button], set_button = baseinfo.bes_ch_sel[inx_button]
        endfor
     endfor
      ch_base23 = widget_base(ch_base, /row)
      if baseinfo.shotnumber LE baseinfo.old_bes_system_shot_end then begin
        old_new_indicator_label = widget_label(ch_base23, value = '                                                         -------------------------------------------')
      endif else begin
        old_new_indicator_label = widget_label(ch_base23, value = '            ----------------------------------------------------------------------------------------')
      endelse
  plot_base = widget_base(base, /row, xsize=xsize, ysize=30)
    plot_label = widget_label(plot_base, value = '        ')
    plot_button = widget_button(plot_base, value = '  PLOT ALL  ')
    plot_label = widget_label(plot_base, value = '   ')
    oplot_button = widget_button(plot_base, value = '  OVER PLOT  ')
    plot_label = widget_label(plot_base, value = ' ')
    plot_base1 = widget_base(plot_base, /column, /nonexclusive)
      show_position_button = widget_button(plot_base1, value = 'Show BES positions')
  message_base = widget_base(base, /column, xsize = xsize, /base_align_left)
    message_label = widget_label(message_base, value = 'Error Message Box')
    message_text = widget_text(message_base, value='', xsize=xsize, ysize=10, /wrap)
  quit_base = widget_base(base, /column, xsize=xsize)
    quit_button = widget_button(quit_base, value = 'QUIT', ysize=30)

; set user values
  idinfo = {base:base, $
            shot_number_text:shot_number_text, $
            server_combo:server_combo, $
            time_range_from_text:time_range_from_text, $
            time_range_to_text:time_range_to_text, $
            freq_range_from_text:freq_range_from_text, $
            freq_range_to_text:freq_range_to_text, $
            ch_sel_all_button:ch_sel_all_button, $
            ch_desel_all_button:ch_desel_all_button, $
            bes_ch_button:bes_ch_button, $
            old_new_indicator_label:old_new_indicator_label, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            show_position_button:show_position_button, $
            message_text:message_text, $
            quit_button:quit_button, $
            total_num_bes_ch:total_num_bes_ch, $
            num_horizontal_ch:num_horizontal_ch, $
            num_vertical_ch:num_vertical_ch, $
            server:server, $
            old_bes_system_shot_end:baseinfo.old_bes_system_shot_end}

  widget_control, base, set_uvalue = idinfo  

; realize the widget
  widget_control, base, /realize

; start xmanager
  xmanager, 'show_bes_data_widget', base, /no_block

END
