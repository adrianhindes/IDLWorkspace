;===================================================================================
;
; This file contains following functions and procedures to control the windows for
;   bes_analyser:
;
;  1) create_err_msg_window
;     --> creates an modal window to show error message window
;
;  2) create_IDL_msg_box_window
;     --> creates an IDL message box window to show a user currunt status of computation
;
;  3) show_IDL_msg_box_window
;     --> starts the xmanager for IDL_msg_box_window
;
;  4) kill_IDL_msg_box_window
;     --> kills the IDL_msg_box_window
;
;  5) create_CUDA_comm_window
;     --> creates a CUDA communication window
;
;  6) show_CUDA_comm_window
;     --> starts the xmanager for CUDA_comm_window
;
;  7) kill_CUDA_comm_window
;     --> kills the CUDA_comm_window
;
;  8) create_time_sel_window
; 
;  9) show_time_sel_window
;
; 10) kill_time_sel_window
;
; 11) create_time_file_sel_window
;
; 12) kill_time_file_sel_window
;
; 13) create_load_options_window
;
; 14) kill_load_options_window
;
; 15) create_save_options_window
;
; 16) kill_save_options_window
;
; 17) create_bes_time_evol_window
;
; 18) kill_bes_time_evol_window
;
; 19) create_bes_rms_dc_time_evol_window
;
; 20) kill_bes_rms_dc_time_evol_window
;
; 21) create_bes_animation_window
;
; 22) kill_bes_animation_window
;
; 23) create_dens_spec_window
;
; 24) kill_dens_spec_window
;
; 25) create_dens_coh_window
;
; 26) kill_dens_coh_window
;
; 27) create_dens_temporal_corr_window
;
; 28) kill_dens_temporal_corr_window
;
; 29) create_dens_spa_temp_corr_window
;
; 30) kill_dens_spa_temp_corr_window
;
; 31) create_vel_evol_window
;
; 32) kill_vel_evol_window
;
; 33) create_vel_spec_window
;
; 34) kill_vel_spec_window
;
; 35) create_show_flux_surface_window
;
; 36) kill_show_fulx_surface_window
;
; 37) create_dens_spatio_spatio_corr_window
;
; 38) kill_dens_spatio_spatio_corr_window
;
;===================================================================================




;===================================================================================
; This procedure creates the error message window as a modal window
;   which shows a user that an error has been occured.
;===================================================================================
; The procedure parameters:
;   1) 'msg_str' is a string type which will be displayed on the error message window.
;   2) 'group_leader' is the leader of the window for wnidow control purpose
;===================================================================================
pro create_err_msg_window, msg_str, group_leader

  window_title = 'Error/Warning Message Window'
  base = widget_base(title = window_title, xsize = 500, ysize = 100, /modal, group_leader = group_leader, /column)
  label = widget_label(base, value = msg_str, /align_center)
  label = widget_label(base, value = '')
  label = widget_label(base, value = '')
  label = widget_label(base, value = '')
  ok_button = widget_button(base, value = 'OK', xsize = 100, ysize = 30, /align_center)

  widget_control, base, set_uvalue = ok_button

  widget_control, base, /realize
  xmanager, 'bes_analyser_err_msg_window', base	;this window blocks every other windows.

end



;===================================================================================
; This procedure creates the IDL message box window
;   which shows the current status of bes_analyser and calculations being performed.
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro create_IDL_msg_box_window, info

  window_title = 'IDL Message Box'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events, xsize = 450, ysize = 300, $
                     group_leader = info.id.main_window.main_base)
    msg_text = widget_text(base, value = 'IDL message box starts...', /scroll, /wrap, scr_ysize = 250)
    base1 = widget_base(base)
      close_button = widget_button(base1, value = 'Close', xsize = 100, ysize = 30, xoffset = 350, yoffset = 10)



; set id
  info.id.IDL_msg_box_window.IDL_msg_box_window_base = base
  info.id.IDL_msg_box_window.msg_text = msg_text
  info.id.IDL_msg_box_window.close_button = close_button


;save the user value, 'info'
  widget_control, info.id.main_window.main_base, set_uvalue = info

; The base ID of CUDA_comm_window must know the ID of main window so that
;   CUDA_comm_window can retrieve the 'info' of the main_base.
  widget_control, base, set_uvalue = info.id.main_window.main_base

end

;===================================================================================
; This function starts the xmanager for the IDL message box window
;===================================================================================
; The function parameters:
;   1) 'id' is a structure that contains the ids of IDL message box window
;===================================================================================
pro show_IDL_msg_box_window, id

; realize the window
  widget_control, id.IDL_msg_box_window_base, /realize

; start the xmanager for the window
  xmanager, 'IDL_msg_box_window', id.IDL_msg_box_window_base, /no_block

end

;===================================================================================
; This procedure kills the xmanager for the IDL message box window
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro kill_IDL_msg_box_window, info 

; kill the IDL_msg_box_window
  widget_control, info.id.IDL_msg_box_window.IDL_msg_box_window_base, /destroy

; create IDL_msg_box_window so that it can be started later on if a user wishes to re-start.
  create_IDL_msg_box_window, info

end


;===================================================================================
; This function creates the CUDA_comm_window
;   which controls the CUDA communication line
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro create_CUDA_comm_window, info

  window_title = 'CUDA Communication Line Controller'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 350, ysize = 170, $
                     group_leader = info.id.main_window.main_base) 
    base1 = widget_base(base, /column, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Configuration File: ')
        str = info.CUDA_comm_window_data.conf_file
        conf_file_text = widget_text(base11, /editable, scr_xsize = 200, value = str)
      base12 = widget_base(base1, /row)
        label12 = widget_label(base12, value = 'Status File:        ') 
        str = info.CUDA_comm_window_data.sts_file
        sts_file_text = widget_text(base12, /editable, scr_xsize = 200, value = str)
      base13 = widget_base(base1)
        open_comm_button =  widget_button(base13, value = 'Open Comm. Line', xsize = 150, ysize = 30, xoffset = 0)
        close_comm_button = widget_button(base13, value = 'Close Comm. Line', xsize = 150, ysize = 30, xoffset = 190)
    base2 = widget_base(base)
      close_button = widget_button(base2, value = 'Close', xsize = 150, ysize = 30, xoffset = 200, yoffset = 10)

; set id
  info.id.CUDA_comm_window.CUDA_comm_window_base = base
  info.id.CUDA_comm_window.conf_file_text = conf_file_text
  info.id.CUDA_comm_window.sts_file_text = sts_file_text
  info.id.CUDA_comm_window.open_comm_button = open_comm_button
  info.id.CUDA_comm_window.close_comm_button = close_comm_button
  info.id.CUDA_comm_window.close_button = close_button

;save the user value, 'info'
  widget_control, info.id.main_window.main_base, set_uvalue = info

; The base ID of CUDA_comm_window must know the ID of main window so that
;   CUDA_comm_window can retrieve the 'info' of the main_base.
  widget_control, base, set_uvalue = info.id.main_window.main_base

end


;===================================================================================
; This function starts the xmanager for the CUDA_comm_window
;===================================================================================
; The function parameters:
;   1) 'id' is a structure that contains the ids of CUDA_comm_window
;===================================================================================
pro show_CUDA_comm_window, id

; realize the window
  widget_control, id.CUDA_comm_window_base, /realize

; start the xmanager for the window
  xmanager, 'CUDA_comm_window', id.CUDA_comm_window_base, /no_block

end


;===================================================================================
; This procedure kills the xmanager for the CUDA_comm_window
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro kill_CUDA_comm_window, info 

; before kill the CUDA_comm_window, save the file name
  widget_control, info.id.CUDA_comm_window.conf_file_text, get_value = str
  info.CUDA_comm_window_data.conf_file = str[0]
  widget_control, info.id.CUDA_comm_window.sts_file_text, get_value = str
  info.CUDA_comm_window_data.sts_file = str[0]

  widget_control, info.id.main_window.main_base, set_uvalue = info

; kill the CUDA_comm_window
  widget_control, info.id.CUDA_comm_window.CUDA_comm_window_base, /destroy

; create CUDA_comm_window so that it can be started later on if a user wishes to re-start.
  create_CUDA_comm_window, info

end


;===================================================================================
; This function creates the time_sel_window
;   which controls the time selection plot on the main window
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro create_time_sel_window, info

  data = info.time_sel_window_data

  window_title = 'Options for Time Selection Plot'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 550, ysize = 700, $
                     group_leader = info.id.main_window.main_base) 
    label = widget_label(base, value = '<Select signals to be plotted for Time Selection>', /align_left)
    label = widget_label(base, value = '')
    label = widget_label(base, value = 'NOTE: y-axis (except BES Signal) will be normalized by the scaling factors.')
    base1 = widget_base(base, /column, frame = 1)
      base10 = widget_base(base1, /row)
        label10 = widget_label(base10, value = 'MAST BES Signals (Black): Frequency Filtering From ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base10, value = str, /editable, scr_xsize = 80)
        label10 = widget_label(base10, value = ' To ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base10, value = str, /editable, scr_xsize = 80)
        label10 = widget_label(base10, value = ' kHz')
      BES_Ch_button = lonarr(32)
      POL_Ch_button = lonarr(4)
      RAD_Ch_button = lonarr(8)
      base11 = widget_base(base1, /row)
        base111 = widget_base(base11, /row)
          label111 = widget_label(base111, value = '         ')
        base112 = widget_base(base11, /row, /nonexclusive)
          RAD_Ch_button[7] = widget_button(base112, value = 'RAD 8')
          RAD_Ch_button[6] = widget_button(base112, value = 'RAD 7')
          RAD_Ch_button[5] = widget_button(base112, value = 'RAD 6')
          RAD_Ch_button[4] = widget_button(base112, value = 'RAD 5')
          RAD_Ch_button[3] = widget_button(base112, value = 'RAD 4')
          RAD_Ch_button[2] = widget_button(base112, value = 'RAD 3')
          RAD_Ch_button[1] = widget_button(base112, value = 'RAD 2')
          RAD_Ch_button[0] = widget_button(base112, value = 'RAD 1')
      base12 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[3] = widget_button(base12, value = 'POL 4  ')
        BES_Ch_button[31] = widget_button(base12, value = '32   ')
        BES_Ch_button[30] = widget_button(base12, value = '31   ')
        BES_Ch_button[29] = widget_button(base12, value = '30   ')
        BES_Ch_button[28] = widget_button(base12, value = '29   ')
        BES_Ch_button[27] = widget_button(base12, value = '28   ')
        BES_Ch_button[26] = widget_button(base12, value = '27   ')
        BES_Ch_button[25] = widget_button(base12, value = '26   ')
        BES_Ch_button[24] = widget_button(base12, value = '25   ')
      base13 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[2] = widget_button(base13, value = 'POL 3  ')
        BES_Ch_button[23] = widget_button(base13, value = '24   ')
        BES_Ch_button[22] = widget_button(base13, value = '23   ')
        BES_Ch_button[21] = widget_button(base13, value = '22   ')
        BES_Ch_button[20] = widget_button(base13, value = '21   ')
        BES_Ch_button[19] = widget_button(base13, value = '20   ')
        BES_Ch_button[18] = widget_button(base13, value = '19   ')
        BES_Ch_button[17] = widget_button(base13, value = '18   ')
        BES_Ch_button[16] = widget_button(base13, value = '17   ')
      base14 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[1] = widget_button(base14, value = 'POL 2  ')
        BES_Ch_button[15] = widget_button(base14, value = '16   ')
        BES_Ch_button[14] = widget_button(base14, value = '15   ')
        BES_Ch_button[13] = widget_button(base14, value = '14   ')
        BES_Ch_button[12] = widget_button(base14, value = '13   ')
        BES_Ch_button[11] = widget_button(base14, value = '12   ')
        BES_Ch_button[10] = widget_button(base14, value = '11   ')
        BES_Ch_button[9] = widget_button(base14, value = '10   ')
        BES_Ch_button[8] = widget_button(base14, value = ' 9   ')
      base15 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[0] = widget_button(base15, value = 'POL 1  ')
        BES_Ch_button[7] = widget_button(base15, value = ' 8   ')
        BES_Ch_button[6] = widget_button(base15, value = ' 7   ')
        BES_Ch_button[5] = widget_button(base15, value = ' 6   ')
        BES_Ch_button[4] = widget_button(base15, value = ' 5   ')
        BES_Ch_button[3] = widget_button(base15, value = ' 4   ')
        BES_Ch_button[2] = widget_button(base15, value = ' 3   ')
        BES_Ch_button[1] = widget_button(base15, value = ' 2   ')
        BES_Ch_button[0] = widget_button(base15, value = ' 1   ')
      for i = 0, n_elements(data.BES_ch_sel)-1 do $
        widget_control, BES_Ch_button[i], set_button = data.BES_ch_sel[i]
      for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
        widget_control, RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
      for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
        widget_control, POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
    base2 = widget_base(base, /column, frame = 1)
      label2 = widget_label(base2, value = 'Other Singals', /align_left)
        base21 = widget_base(base2, /row)
          base211 = widget_base(base21, /column, /nonexclusive)
            plasma_current_button = widget_button(base211, value = 'Plasma Current (Red)       ')
            widget_control, plasma_current_button, set_button = data.plasma_current_sel
          base212 = widget_base(base21, /row)
            label212 = widget_label(base212, value = '   Scaling Factor: ')
            str = string(data.plasma_current_scale, format='(f0.2)')
            plasma_current_scale_text = widget_text(base212, value = str, /editable, scr_xsize = 80)
            label212 = widget_label(base212, value = ' [MA]') 
        base22 = widget_base(base2, /row)
          base221 = widget_base(base22, /column, /nonexclusive)
            plasma_density_button = widget_button(base221, value = 'Plasma Density (Green)     ')
            widget_control, plasma_density_button, set_button = data.plasma_density_sel
          base222 = widget_base(base22, /row)
            label222 = widget_label(base222, value = '   Scaling Factor: ')
            str = string(data.plasma_density_scale, format='(e0.2)')
            plasma_density_scale_text = widget_text(base222, value = str, /editable, scr_xsize = 80)
            label222 = widget_label(base222, value = ' [m^-2]')
        base23 = widget_base(base2, /row)
          base231 = widget_base(base23, /column, /nonexclusive)
            SS_beam_button = widget_button(base231, value = 'SS Beam Total Power (Blue) ')
            widget_control, SS_beam_button, set_button = data.SS_beam_sel
          base232 = widget_base(base23, /row)
            label232 = widget_label(base232, value = '   Scaling Factor: ')
            str = string(data.SS_beam_scale, format='(f0.2)')
            SS_beam_scale_text = widget_text(base232, value = str, /editable, scr_xsize = 80)
            label232 = widget_label(base232, value = ' [MW]')
        base24 = widget_base(base2, /row)
          base241 = widget_base(base24, /column, /nonexclusive)
            dalpha_button = widget_button(base241, value = 'D-alpha (Cyan)             ')
            widget_control, dalpha_button, set_button = data.dalpha_sel
          base242 = widget_base(base24, /row)
            label242 = widget_label(base242, value = '   Scaling Factor: ')
            str = string(data.dalpha_scale, format='(e0.2)')
            dalpha_scale_text = widget_text(base242, value = str, /editable, scr_xsize = 80)
            label242 = widget_label(base242, value = ' [ph/sr/m^2/s]')
    base3 = widget_base(base)
      plot_button = widget_button(base3, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 450, yoffset = 10)
    base4 = widget_base(base, /column)
      label41 = widget_label(base4, value = '')
      label42 = widget_label(base4, value = '')
      label43 = widget_label(base4, value = '<Save/Load a Time File>')
    base5 = widget_base(base, /column, frame = 1)
      base51 = widget_base(base5, /row)
        label51 = widget_label(base51, value = 'Save as ')
        filename_text = widget_text(base51, value = '', /editable, scr_xsize = 150)
        save_button = widget_button(base51, value = 'SAVE', xsize = 100, ysize = 30)
        label51 = widget_label(base51, value = '  OR   ')
        load_button = widget_button(base51, value = 'LOAD an existing file', xsize = 170, ysize = 30) 
      base52 = widget_base(base5, /row)
        label52 = widget_label(base52, value = '         Do NOT include file extension.')
    base6 = widget_base(base)
      close_button = widget_button(base6, value = 'Close', xsize = 100, ysize = 30, xoffset = 450, yoffset = 20)

; set id
  info.id.time_sel_window.time_sel_window_base = base
  info.id.time_sel_window.freq_filter_low_text = freq_filter_low_text
  info.id.time_sel_window.freq_filter_high_text = freq_filter_high_text
  info.id.time_sel_window.BES_Ch_button = BES_Ch_button
  info.id.time_sel_window.POL_Ch_button = Pol_Ch_button
  info.id.time_sel_window.RAD_Ch_button = RAD_Ch_button
  info.id.time_sel_window.plasma_current_button = plasma_current_button
  info.id.time_sel_window.plasma_current_scale_text = plasma_current_scale_text
  info.id.time_sel_window.plasma_density_button = plasma_density_button
  info.id.time_sel_window.plasma_density_scale_text = plasma_density_scale_text
  info.id.time_sel_window.SS_beam_button = SS_beam_button
  info.id.time_sel_window.SS_beam_scale_text = SS_beam_scale_text
  info.id.time_sel_window.dalpha_button = dalpha_button
  info.id.time_sel_window.dalpha_scale_text = dalpha_scale_text
  info.id.time_sel_window.plot_button = plot_button
  info.id.time_sel_window.filename_text = filename_text
  info.id.time_sel_window.save_button = save_button
  info.id.time_sel_window.load_button = load_button
  info.id.time_sel_window.close_button = close_button


;save the user value, 'info'
  widget_control, info.id.main_window.main_base, set_uvalue = info

; The base ID of time_sel_window must know the ID of main window so that
;   time_sel_window can retrieve the 'info' of the main_base.
  widget_control, base, set_uvalue = info.id.main_window.main_base

end


;===================================================================================
; This procedure starts the xmanager for the time_sel_window
;===================================================================================
; The function parameters:
;   1) 'id' is a structure that contains the ids of time_sel_window
;===================================================================================
pro show_time_sel_window, id

; realize the window
  widget_control, id.time_sel_window_base, /realize

; start the xmanager for the window
  xmanager, 'time_sel_window', id.time_sel_window_base, /no_block

end


;===================================================================================
; This procedure kills the xmanager for the time_sel_window
;===================================================================================
; The function parameters:
;   1) 'info' is a structure that is saved as uvalue under the main_base.
;===================================================================================
pro kill_time_sel_window, info

; kill the time_sel_window
  widget_control, info.id.time_sel_window.time_sel_window_base, /destroy

; create time_sel_window so that it can be started later on if a user wishes to re-start.
  create_time_sel_window, info

end


;===================================================================================
; This procedure creates time_file_sel_window starts the xmanager for it
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main window (i.e. bes_analyser main base).
;         This window needs to know id_main_base so that it can control 'info' structure.
;   2) 'group_leader' is the ID of the parent window that calls this procedure.
;   3) 'fnames' is an 1-D string array that contains the existing time file names.
;===================================================================================
pro create_time_file_sel_window, id_main_base, group_leader, fnames

; create the window
  window_title = 'Select existing time file'
  base = widget_base(title = window_title, xsize = 200, ysize = 90, /modal, group_leader = group_leader, /column, /tlb_kill_request_events)
    label1 = widget_label(base, value = '')
    time_file_combo = widget_combobox(base, value = fnames)
    label2 = widget_label(base, value = '')
    base1 = widget_base(base)
      cancel_button = widget_button(base1, value = 'Cancel', xsize = 85, ysize = 30, xoffset = 10, yoffset = 10)
      load_button = widget_button(base1, value= 'Load', xsize = 85, ysize = 30, xoffset = 105, yoffset = 10)

; save idinfo
  idinfo = {base:base, $
            time_file_combo:time_file_combo, $
            cancel_button:cancel_button, $
            load_button:load_button, $
            id_main_base:id_main_base}

  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'time_file_sel_window', base, /no_block	;this window blocks every other windows

end


;===================================================================================
; This procedure kills the xmanager for the time_file_sel_window
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for time_file_sel_window
;===================================================================================
pro kill_time_file_sel_window, base_id

; kill the time_file_sel_window
  widget_control, base_id, /destroy

end

;===================================================================================
; This procedure creates the window to load options
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;   2) 'file_extension': <string> containing the file extension to be appeared on the widget_tree
;===================================================================================
; Return value:
;        result: <string> contains the user selected filename (full path)
;                 This is NULL if no file is selected by the user.
;===================================================================================
function create_load_options_window, id_main_base, file_extension

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

; create the file selection dialog
  filter = '*' + file_extension
  result = dialog_pickfile(dialog_parent = id_main_base, $
                           title = 'Select a file to be loaded.', $
                           path = dir_name, filter = filter, /must_exist)

  return, result

end

;===================================================================================
; This procedure kills the load option window
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for time_file_sel_window
;===================================================================================
pro kill_load_options_window, base_id



end

;===================================================================================
; This procedure creates the window to save options
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;   2) 'file_extension': <string> containing the file extension to be used for the filename
;===================================================================================
pro create_save_options_window, id_main_base, file_extension

; creating widgets
  window_title = 'Save Options...'
  base = widget_base(/column, title = window_title, /modal, /tlb_kill_request_events, xsize = 300, ysize = 300, $
                     group_leader = id_main_base)
    base1 = widget_base(base, /row)
      label1 = widget_label(base1, value = 'Save as  ')
      filename_text = widget_text(base1, value = '', /editable, scr_xsize = 150)
      label1 = widget_label(base1, value = file_extension)
    base2 = widget_base(base, /column)
      label2 = widget_label(base2, value = 'Do NOT include the file extension!', /align_left)
      label2 = widget_label(base2, value = '')
      label2 = widget_label(base2, value = '')
      label2 = widget_label(base2, value = 'Add any comments', /align_left)
    base3 = widget_base(base, /column)
      comment_text = widget_text(base3, /editable, scr_ysize = 150, scr_xsize = 295, /scroll, /wrap)
    base4 = widget_base(base)
      cancel_button = widget_button(base4, value = 'Cancel', xsize = 100, ysize = 30, xoffset = 25, yoffset = 10)
      save_button = widget_button(base4, value = 'Save', xsize = 100, ysize = 30, xoffset = 175, yoffset = 10)

; saving the idinfo
  idinfo = {file_extension:file_extension, $
            id_main_base:id_main_base, $
            base:base, $
            filename_text:filename_text, $
            comment_text:comment_text, $
            cancel_button:cancel_button, $
            save_button:save_button}


  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'save_options_window', base

  return

end


;===================================================================================
; This procedure kills the save option window
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for time_file_sel_window
;===================================================================================
pro kill_save_options_window, base_id

  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for BES time evolution signal, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_bes_time_evol_window, id_main_base

; get the bes_time_evol_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.bes_time_evol_window_data

; creating widgets
  window_title = 'Options to plot raw BES signal'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 550, ysize = 380, $
                     group_leader = id_main_base)
    label0 = widget_label(base, value = 'Note: This analysis does NOT use CUDA.') 
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = '<Select BES signals to be plotted>', /align_left)
    base1 = widget_base(base, /column, frame = 1)
      base10 = widget_base(base1, /row)
        label10 = widget_label(base10, value = 'Frequency Filtering From ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base10, value = str, /editable, scr_xsize = 80)
        label10 = widget_label(base10, value = ' To ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base10, value = str, /editable, scr_xsize = 80)
        label10 = widget_label(base10, value = ' kHz')
      BES_Ch_button = lonarr(32)
      POL_Ch_button = lonarr(4)
      RAD_Ch_button = lonarr(8)
      base11 = widget_base(base1, /row)
        base111 = widget_base(base11, /row)
          label111 = widget_label(base111, value = '         ')
        base112 = widget_base(base11, /row, /nonexclusive)
          RAD_Ch_button[7] = widget_button(base112, value = 'RAD 8')
          RAD_Ch_button[6] = widget_button(base112, value = 'RAD 7')
          RAD_Ch_button[5] = widget_button(base112, value = 'RAD 6')
          RAD_Ch_button[4] = widget_button(base112, value = 'RAD 5')
          RAD_Ch_button[3] = widget_button(base112, value = 'RAD 4')
          RAD_Ch_button[2] = widget_button(base112, value = 'RAD 3')
          RAD_Ch_button[1] = widget_button(base112, value = 'RAD 2')
          RAD_Ch_button[0] = widget_button(base112, value = 'RAD 1')
      base12 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[3] = widget_button(base12, value = 'POL 4  ')
        BES_Ch_button[31] = widget_button(base12, value = '32   ')
        BES_Ch_button[30] = widget_button(base12, value = '31   ')
        BES_Ch_button[29] = widget_button(base12, value = '30   ')
        BES_Ch_button[28] = widget_button(base12, value = '29   ')
        BES_Ch_button[27] = widget_button(base12, value = '28   ')
        BES_Ch_button[26] = widget_button(base12, value = '27   ')
        BES_Ch_button[25] = widget_button(base12, value = '26   ')
        BES_Ch_button[24] = widget_button(base12, value = '25   ')
      base13 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[2] = widget_button(base13, value = 'POL 3  ')
        BES_Ch_button[23] = widget_button(base13, value = '24   ')
        BES_Ch_button[22] = widget_button(base13, value = '23   ')
        BES_Ch_button[21] = widget_button(base13, value = '22   ')
        BES_Ch_button[20] = widget_button(base13, value = '21   ')
        BES_Ch_button[19] = widget_button(base13, value = '20   ')
        BES_Ch_button[18] = widget_button(base13, value = '19   ')
        BES_Ch_button[17] = widget_button(base13, value = '18   ')
        BES_Ch_button[16] = widget_button(base13, value = '17   ')
      base14 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[1] = widget_button(base14, value = 'POL 2  ')
        BES_Ch_button[15] = widget_button(base14, value = '16   ')
        BES_Ch_button[14] = widget_button(base14, value = '15   ')
        BES_Ch_button[13] = widget_button(base14, value = '14   ')
        BES_Ch_button[12] = widget_button(base14, value = '13   ')
        BES_Ch_button[11] = widget_button(base14, value = '12   ')
        BES_Ch_button[10] = widget_button(base14, value = '11   ')
        BES_Ch_button[9] = widget_button(base14, value = '10   ')
        BES_Ch_button[8] = widget_button(base14, value = ' 9   ')
      base15 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[0] = widget_button(base15, value = 'POL 1  ')
        BES_Ch_button[7] = widget_button(base15, value = ' 8   ')
        BES_Ch_button[6] = widget_button(base15, value = ' 7   ')
        BES_Ch_button[5] = widget_button(base15, value = ' 6   ')
        BES_Ch_button[4] = widget_button(base15, value = ' 5   ')
        BES_Ch_button[3] = widget_button(base15, value = ' 4   ')
        BES_Ch_button[2] = widget_button(base15, value = ' 3   ')
        BES_Ch_button[1] = widget_button(base15, value = ' 2   ')
        BES_Ch_button[0] = widget_button(base15, value = ' 1   ')
      for i = 0, n_elements(data.BES_ch_sel)-1 do $
        widget_control, BES_Ch_button[i], set_button = data.BES_ch_sel[i]
      for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
        widget_control, RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
      for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
        widget_control, POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
      base16 = widget_base(base1)
        plot_button = widget_button(base16, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 125, yoffset = 10)
        oplot_button = widget_button(base16, value = 'OPLOT', xsize = 100, ysize = 30, xoffset = 325, yoffset = 10)
    base2 = widget_base(base)
      load_options_button = widget_button(base2, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 190, yoffset = 20)
      save_options_button = widget_button(base2, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 320, yoffset = 20)
      close_button = widget_button(base2, value = 'Close', xsize = 100, ysize = 30, xoffset= 450, yoffset = 20)

; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            BES_Ch_button:BES_Ch_button, $
            POL_Ch_button:POL_Ch_button, $
            RAD_Ch_button:RAD_Ch_button, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}

  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_time_evol_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for BES time evolution signal
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_time_evol_window
;===================================================================================
pro kill_bes_time_evol_window, base_id

; kill the bes_time_evol_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for BES RMS/DC evolution signal, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_bes_rms_dc_time_evol_window, id_main_base

; get the rms_dc_time_evol_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.rms_dc_time_evol_window_data

; creating widgets
  window_title = 'Options to plot RMS/DC of BES signal'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 550, ysize = 570, $
                     group_leader = id_main_base)
    label0 = widget_label(base, value = 'Note: This analysis does NOT use CUDA.')
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = '<Select BES signals to be plotted>', /align_left)
    base1 = widget_base(base, /column, frame = 1)
      BES_Ch_button = lonarr(32)
      POL_Ch_button = lonarr(4)
      RAD_Ch_button = lonarr(8)
      base11 = widget_base(base1, /row)
        base111 = widget_base(base11, /row)
          label111 = widget_label(base111, value = '         ')
        base112 = widget_base(base11, /row, /nonexclusive)
          RAD_Ch_button[7] = widget_button(base112, value = 'RAD 8')
          RAD_Ch_button[6] = widget_button(base112, value = 'RAD 7')
          RAD_Ch_button[5] = widget_button(base112, value = 'RAD 6')
          RAD_Ch_button[4] = widget_button(base112, value = 'RAD 5')
          RAD_Ch_button[3] = widget_button(base112, value = 'RAD 4')
          RAD_Ch_button[2] = widget_button(base112, value = 'RAD 3')
          RAD_Ch_button[1] = widget_button(base112, value = 'RAD 2')
          RAD_Ch_button[0] = widget_button(base112, value = 'RAD 1')
      base12 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[3] = widget_button(base12, value = 'POL 4  ')
        BES_Ch_button[31] = widget_button(base12, value = '32   ')
        BES_Ch_button[30] = widget_button(base12, value = '31   ')
        BES_Ch_button[29] = widget_button(base12, value = '30   ')
        BES_Ch_button[28] = widget_button(base12, value = '29   ')
        BES_Ch_button[27] = widget_button(base12, value = '28   ')
        BES_Ch_button[26] = widget_button(base12, value = '27   ')
        BES_Ch_button[25] = widget_button(base12, value = '26   ')
        BES_Ch_button[24] = widget_button(base12, value = '25   ')
      base13 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[2] = widget_button(base13, value = 'POL 3  ')
        BES_Ch_button[23] = widget_button(base13, value = '24   ')
        BES_Ch_button[22] = widget_button(base13, value = '23   ')
        BES_Ch_button[21] = widget_button(base13, value = '22   ')
        BES_Ch_button[20] = widget_button(base13, value = '21   ')
        BES_Ch_button[19] = widget_button(base13, value = '20   ')
        BES_Ch_button[18] = widget_button(base13, value = '19   ')
        BES_Ch_button[17] = widget_button(base13, value = '18   ')
        BES_Ch_button[16] = widget_button(base13, value = '17   ')
      base14 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[1] = widget_button(base14, value = 'POL 2  ')
        BES_Ch_button[15] = widget_button(base14, value = '16   ')
        BES_Ch_button[14] = widget_button(base14, value = '15   ')
        BES_Ch_button[13] = widget_button(base14, value = '14   ')
        BES_Ch_button[12] = widget_button(base14, value = '13   ')
        BES_Ch_button[11] = widget_button(base14, value = '12   ')
        BES_Ch_button[10] = widget_button(base14, value = '11   ')
        BES_Ch_button[9] = widget_button(base14, value = '10   ')
        BES_Ch_button[8] = widget_button(base14, value = ' 9   ')
      base15 = widget_base(base1, /row, /nonexclusive)
        POL_Ch_button[0] = widget_button(base15, value = 'POL 1  ')
        BES_Ch_button[7] = widget_button(base15, value = ' 8   ')
        BES_Ch_button[6] = widget_button(base15, value = ' 7   ')
        BES_Ch_button[5] = widget_button(base15, value = ' 6   ')
        BES_Ch_button[4] = widget_button(base15, value = ' 5   ')
        BES_Ch_button[3] = widget_button(base15, value = ' 4   ')
        BES_Ch_button[2] = widget_button(base15, value = ' 3   ')
        BES_Ch_button[1] = widget_button(base15, value = ' 2   ')
        BES_Ch_button[0] = widget_button(base15, value = ' 1   ')
      for i = 0, n_elements(data.BES_ch_sel)-1 do $
        widget_control, BES_Ch_button[i], set_button = data.BES_ch_sel[i]
      for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
        widget_control, RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
      for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
        widget_control, POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
      base16 = widget_base(base1)
        plot_button = widget_button(base16, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 125, yoffset = 10)
        oplot_button = widget_button(base16, value = 'OPLOT', xsize = 100, ysize = 30, xoffset = 325, yoffset = 10)
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = '<Options to calculate RMS/DC>', /align_left)
    base2 = widget_base(base, /column, frame = 1)
      base21 = widget_base(base2, /row)
        label21 = widget_label(base21, value = 'Number of points for averaging:  ')
        str = string(data.avg_nt, format='(i0)')
        avg_nt_text = widget_text(base21, value = str, /editable, scr_xsize = 80)
        time_resolution = info.main_window_data.BES_data.dt * data.avg_nt * 1e6	;in [micro sec]
        str = ' dt of outupt = ' + string(time_resolution, format='(f0.2)') + ' [micro-sec]'
        time_res_label = widget_label(base21, value = str, /dynamic_resize)
      base22 = widget_base(base2, /row, /nonexclusive)
        use_LPF_for_DC_button = widget_button(base22, value = 'Use Low Pass Filter to get DC values (if not selected, DC = time average)')
        widget_control, use_LPF_for_DC_button, set_button = data.use_LPF_for_DC
      base23 = widget_base(base2, /row)
        label23 = widget_label(base23, value = '      Low Pass Filter Range:  0.0 - ')
        str = string(data.DC_freq_filter_high, format='(f0.2)')
        DC_freq_filter_high_text = widget_text(base23, value = str, /editable, scr_xsize = 80)
        label23 = widget_label(base23, value = ' [kHz]')
        if data.use_LPF_for_DC then $
          widget_control, DC_freq_filter_high_text, sensitive = 1 $
        else $
          widget_control, DC_freq_filter_high_text, sensitive = 0
      base24 = widget_base(base2, /row)
        label24 = widget_label(base24, value = 'Frequency Filtering for fluctuating signal from ')
        str = string(data.RMS_freq_filter_low, format='(f0.2)')
        RMS_freq_filter_low_text = widget_text(base24, value = str, /editable, scr_xsize = 80)
        label24 = widget_label(base24, value = ' to ')
        str = string(data.RMS_freq_filter_high, format='(f0.2)')
        RMS_freq_filter_high_text = widget_text(base24, value = str, /editable, scr_xsize = 80)
        label24 = widget_label(base24, value = ' [kHz]')
      base25 = widget_base(base2, /row, /nonexclusive)
        subtract_DC_button = widget_button(base25, value = 'Subtract DC values to calculate RMS')
        widget_control, subtract_DC_button, set_button = data.subtract_DC
    base3 = widget_base(base)
      help_button = widget_button(base3, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base3, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 190, yoffset = 20)
      save_options_button = widget_button(base3, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 320, yoffset = 20)
      close_button = widget_button(base3, value = 'Close', xsize = 100, ysize = 30, xoffset= 450, yoffset = 20)



; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            BES_Ch_button:BES_Ch_button, $
            POL_Ch_button:POL_Ch_button, $
            RAD_Ch_button:RAD_Ch_button, $
            avg_nt_text:avg_nt_text, $
            time_res_label:time_res_label, $
            use_LPF_for_DC_button:use_LPF_for_DC_button, $
            DC_freq_filter_high_text:DC_freq_filter_high_text, $
            RMS_freq_filter_low_text:RMS_freq_filter_low_text, $
            RMS_freq_filter_high_text:RMS_freq_filter_high_text, $
            subtract_DC_button:subtract_DC_button, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}
 
  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_rms_dc_time_evol_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for BES RMS/DC evolution signal.
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_rms_dc_time_evol_window
;===================================================================================
pro kill_bes_rms_dc_time_evol_window, base_id

; kill the bes_rms_dc_time_evol_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for BES animation, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_bes_animation_window, id_main_base

; get the bes_animation_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.bes_animation_window_data

; creating widgets
  window_title = 'Options to plot BES animation'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 550, ysize = 640, $
                     group_leader = id_main_base)
    label0 = widget_label(base, value = 'Note: This analysis does NOT use CUDA.')
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = '')
    label0 = widget_label(base, value = 'Signal is defined as n(t) = n0(t) + n1(t)', /align_left)
    label0 = widget_label(base, value = '       where n0(t) is the mean value (i.e. slowly varing quantity), and', /align_left)
    label0 = widget_label(base, value = '             n1(t) is the fluctuating part.', /align_left)
    base1 = widget_base(base, /column, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Increase the spatial resolution by factor of    ')
        str = string(data.factor_inc_spa_pts, format='(i0)')
        factor_inc_spa_pts_text = widget_text(base11, value = str, /editable, scr_xsize = 80)
        label11 = widget_label(base11, value = '(by spatial interpolation)')
      base12 = widget_base(base1, /row)
        label12 = widget_label(base12, value = 'Frequency Filtering From   ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base12, value = str, /editable, scr_xsize = 80)
        label12 = widget_label(base12, value = '  To  ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base12, value = str, /editable, scr_xsize = 80)
        label12 = widget_label(base12, value = ' [kHz]')
      base13 = widget_base(base1, /row)
        label13 = widget_label(base13, value = 'Movie Type: ')
        str = ['n(t)', 'n1(t)', 'n1(t)/n0(t)']
        play_type_combo = widget_combobox(base13, value = str)
        widget_control, play_type_combo, set_combobox_select = data.inx_play_type
      base14 = widget_base(base1, /row)
        base140 = widget_base(base14, /column)
          label140 = widget_label(base140, value = '   ')
          label140 = widget_label(base140, value = '   ')
        base141 = widget_base(base14, /exclusive, /column)
          by_time_avg_for_DC_button = widget_button(base141, value = 'Calc. n0(t) by time-averaging ', ysize = 43)
          by_LPF_for_DC_button = widget_button(base141, value = 'Calc. n0(t) by Low Pass Filter', ysize = 43)
          if data.by_time_avg_for_DC eq 1 then begin
            widget_control, by_time_avg_for_DC_button, set_button = 1
            widget_control, by_LPF_for_DC_button, set_button = 0
          endif else begin
            widget_control, by_time_avg_for_DC_button, set_button = 0
            widget_control, by_LPF_for_DC_button, set_button = 1
          endelse
        base142 = widget_base(base14, /column)
          base1421 = widget_base(base142, /row)
            label1421 = widget_label(base1421, value = 'Number of points for averaging: ')
            str = string(data.avg_nt, format='(i0)')
            avg_nt_text = widget_text(base1421, value = str, /editable, scr_xsize = 80)
          base1422 = widget_base(base142, /row)
            label1422 = widget_label(base1422, value = 'Low Pass Filter Range:    0.0 - ')
            str = string(data.DC_freq_filter_high, format='(f0.2)')
            DC_freq_filter_high_text = widget_text(base1422, value = str, /editable, scr_xsize = 80)
            label1422 = widget_label(base1422, value = ' [kHz]')
        if data.inx_play_type eq 0 then begin
          widget_control, by_time_avg_for_DC_button, sensitive = 0
          widget_control, by_LPF_for_DC_button, sensitive = 0
          widget_control, avg_nt_text, sensitive = 0
          widget_control, DC_freq_filter_high_text, sensitive = 0
        endif else begin
          widget_control, by_time_avg_for_DC_button, sensitive = 1
          widget_control, by_LPF_for_DC_button, sensitive = 1
          if  data.by_time_avg_for_DC eq 1 then begin
            widget_control, avg_nt_text, sensitive = 1
            widget_control, DC_freq_filter_high_text, sensitive = 0
          endif else begin
            widget_control, avg_nt_text, sensitive = 0
            widget_control, DC_freq_filter_high_text, sensitive = 1
          endelse
        endelse
      base15 = widget_base(base1, /nonexclusive)
        normalize_button = widget_button(base15, value = 'Normalize')
        widget_control, normalize_button, set_button = data.normalize
      base16 = widget_base(base1, /row)
        base161 = widget_base(base16, /column)
          label161 = widget_label(base161, value = '   ')
          label161 = widget_label(base161, value = '   ')
        base162 = widget_base(base16, /column, /exclusive)
          norm_by_own_ch_button = widget_button(base162, value = 'by maximum of each channel')
          norm_by_all_ch_button = widget_button(base162, value = 'by maximum of all channels')
          if data.norm_by_own_ch eq 1 then begin
            widget_control, norm_by_own_ch_button, set_button = 1
            widget_control, norm_by_all_ch_button, set_button = 0
          endif else begin
            widget_control, norm_by_own_ch_button, set_button = 0
            widget_control, norm_by_all_ch_button, set_button = 1
          endelse
        if data.normalize eq 1 then begin
          widget_control, norm_by_own_ch_button, sensitive = 1
          widget_control, norm_by_all_ch_button, sensitive = 1
        endif else begin
          widget_control, norm_by_own_ch_button, sensitive = 0
          widget_control, norm_by_all_ch_button, sensitive = 0
        endelse
      base16 = widget_base(base1, /column)
        base161 = widget_base(base16, /nonexclusive)
          show_BES_pos_button = widget_button(base161, value = 'Show BES Positions')
          if data.show_BES_pos eq 1 then $
            widget_control, show_BES_pos_button, set_button = 1 $
          else $
            widget_control, show_BES_pos_button, set_button = 0
        base162 = widget_base(base16, /row)
          label162 = widget_label(base162, value = '      Color for BES position marker: ')
          combo_str = info.color_table_str
          col_BES_pos_combo = widget_combobox(base162, value = combo_str) 
          inx_curr_sel = where(data.col_BES_pos_str eq info.color_table_str, count)
          if count le 0 then inx_curr_sel = 0
          widget_control, col_BES_pos_combo, set_combobox_select = inx_curr_sel
        if data.show_BES_pos eq 1 then $
          widget_control, col_BES_pos_combo, sensitive = 1 $
        else $
          widget_control, col_BES_pos_combo, sensitive = 0
      base17 = widget_base(base1)
        plot_button = widget_button(base17, value = 'PLOT', xsize = 120, ysize = 30, xoffset = 115, yoffset = 10)
        start_ani_button = widget_button(base17, value = 'START ANIMATION', xsize = 120, ysize = 30, xoffset = 315, yoffset = 10)
    base2 = widget_base(base, /row, frame = 1)
      label2= widget_label(base2, value = 'Color Table for the plot: ')
      loadct, get_names = ctable_str
      ctable_combo = widget_combobox(base2, value = ctable_str)
      widget_control, ctable_combo, set_combobox_select = data.inx_ctable
      label2 = widget_label(base2, value = '    ')
      base21 = widget_base(base2, /row, /nonexclusive)
        inv_ctable_button = widget_button(base21, value = 'Invert color table')
        if data.inv_ctable eq 1 then $
          widget_control, inv_ctable_button, set_button = 1 $
        else $
          widget_control, inv_ctable_button, set_button = 0
    base3 = widget_base(base)
      help_button = widget_button(base3, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base3, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 190, yoffset = 20)
      save_options_button = widget_button(base3, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 320, yoffset = 20)
      close_button = widget_button(base3, value = 'Close', xsize = 100, ysize = 30, xoffset= 450, yoffset = 20)

; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            factor_inc_spa_pts_text:factor_inc_spa_pts_text, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            play_type_combo:play_type_combo, $
            by_time_avg_for_DC_button:by_time_avg_for_DC_button, $
            by_LPF_for_DC_button:by_LPF_for_DC_button, $
            avg_nt_text:avg_nt_text, $
            DC_freq_filter_high_text:DC_freq_filter_high_text, $
            normalize_button:normalize_button, $
            norm_by_own_ch_button:norm_by_own_ch_button, $
            norm_by_all_ch_button:norm_by_all_ch_button, $
            show_BES_pos_button:show_BES_pos_button, $
            col_BES_pos_combo:col_BES_pos_combo, $
            ctable_combo:ctable_combo, $
            inv_ctable_button:inv_ctable_button, $
            plot_button:plot_button, $
            start_ani_button:start_ani_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}


  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_animation_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for BES animation.
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_animation_window
;===================================================================================
pro kill_bes_animation_window, base_id

; kill bes_animation_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for density spectrum, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_dens_spec_window, id_main_base

; get the dens_spec_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.dens_spec_window_data


; creating widgets
  window_title = 'Options to calculate density spectrum'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 485, ysize = 850, $
                     group_leader = id_main_base)
    base1 = widget_base(base, /row, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Calculate density spectrum or spectrogram using ', /align_left)
      base12 = widget_base(base1, /row, /exclusive)
        calc_in_IDL_button = widget_button(base12, value = '  IDL  ')
        calc_in_CUDA_button = widget_button(base12, value = '  CUDA  ')
        if data.calc_in_IDL eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 1
          widget_control, calc_in_CUDA_button, set_button = 0
        endif else if data.calc_in_CUDA eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 0
          widget_control, calc_in_CUDA_button, set_button = 1
        endif
    base2 = widget_base(base, /column)
      label2 = widget_label(base2, value = 'Select one BES Ch. for Signal 1', /align_left)
      base21 = widget_base(base2, /column, frame = 1)
        BES_ch_sel1_button = lonarr(32)
        base211 = lonarr(4)
        for i = 0, 3 do begin
          base211[i] = widget_base(base21, /row, /nonexclusive)
          for j = 0, 7 do begin
            ch_num = 32 - j - i*8
            str = string(ch_num, format='(i2)') + '   '
            BES_ch_sel1_button[ch_num - 1] = widget_button(base211[i], value = str)
          endfor
        endfor
        for i = 0, n_elements(data.BES_ch_sel1)-1 do $
          widget_control, BEs_ch_sel1_button[i], set_button = data.BES_ch_sel1[i]
    base3 = widget_base(base, /column)
      label3 = widget_label(base3, value = 'Select one BES Ch. for Signal 2', /align_left)
      base31 = widget_base(base3, /column, frame = 1)
        BES_ch_sel2_button = lonarr(32)
        base311 = lonarr(4)
        for i = 0, 3 do begin
          base311[i] = widget_base(base31, /row, /nonexclusive)
          for j = 0, 7 do begin
            ch_num = 32 - j - i*8
            str = string(ch_num, format='(i2)') + '   '
            BES_ch_sel2_button[ch_num - 1] = widget_button(base311[i], value = str)
          endfor
        endfor
        for i = 0, n_elements(data.BES_ch_sel2)-1 do $
          widget_control, BEs_ch_sel2_button[i], set_button = data.BES_ch_sel2[i]
    base4 = widget_base(base)
      plot_button = widget_button(base4, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 100, yoffset = 10)
      oplot_button = widget_button(base4, value = 'OPLOT', xsize = 100, ysize = 30, xoffset = 285, yoffset = 10)
    label = widget_label(base, value = '')
    label = widget_label(base, value = '')
    base5 = widget_base(base, /column, frame = 1)
      base51 = widget_base(base5, /row)
        label51 = widget_label(base51, value = 'Frequency Filtering From  ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  To  ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  kHz')
      base52 = widget_base(base5, /column)
        label52 = widget_label(base52, value = 'Calculate', /align_left)
      base53 = widget_base(base5, /row)
        base531 = widget_base(base53, /column)
          label531 = widget_label(base531, value = '     ')
          label531 = widget_label(base531, value = '     ')
        base532 = widget_base(base53, /column, frame = 1, /exclusive, xsize = 180)
          calc_spectrum_button = widget_button(base532, value = 'Spectrum       ')
          calc_spectrogram_button = widget_button(base532, value = 'Spectrogram    ')
          if data.calc_spectrum eq 1 then begin
            widget_control, calc_spectrum_button, set_button = 1
            widget_control, calc_spectrogram_button, set_button = 0
          endif else if data.calc_spectrogram eq 1 then begin
            widget_control, calc_spectrum_button, set_button = 0
            widget_control, calc_spectrogram_button, set_button = 1
          endif
        base533 = widget_base(base53, /column)
          label533 = widget_label(base533, value = '     ')
          label533 = widget_label(base533, value = '     ')
        base534 = widget_base(base53, /column, frame = 1, /exclusive, xsize = 180)
          calc_power_button = widget_button(base534, value = 'Power     ')
          calc_phase_button = widget_button(base534, value = 'Phase     ')
          if data.calc_power eq 1 then begin
            widget_control, calc_power_button, set_button = 1
            widget_control, calc_phase_button, set_button = 0
          endif else if data.calc_phase eq 1 then begin
            widget_control, calc_power_button, set_button = 0
            widget_control, calc_phase_button, set_button = 1
          endif
      base54 = widget_base(base5, /row)
        label54 = widget_label(base54, value = 'Number of points per sub-time window:              ')
        npts = long(2^(findgen(15)+5))
        num_pts_per_subwindow_combo = widget_combobox(base54, value = string(npts, format='(i0)'))
        inx = where(data.num_pts_per_subwindow eq npts, count)
        if count eq 0 then inx = 0
        widget_control, num_pts_per_subwindow_combo, set_combobox_select = inx
      base55 = widget_base(base5, /row)
        label55 = widget_label(base55, value = 'Number of bins of sub-time windows to be averaged: ')
        str = string(data.num_bins_to_average, format='(i0)')
        num_bins_to_average_text = widget_text(base55, value = str, /editable, scr_xsize = 110)
        if data.calc_spectrum then $
          widget_control, num_bins_to_average_text, sensitive = 0 $
        else $
          widget_control, num_bins_to_average_text, sensitive = 1
      base56 = widget_base(base5, /row)
        label56 = widget_label(base56, value = 'Fraction of sub-time window overlap:               ')
        frac_overlap_subwindow_slider = widget_slider(base56,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
        widget_control, frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
        str = string(data.frac_overlap_subwindow, format='(f0.1)')
        frac_overlap_subwindow_label = widget_label(base56, value = str)
      base56_5 = widget_base(base5, /row)
        label56_5 = widget_label(base56_5, value = 'Normalize signals by its DC value:                 ')
        str = ['No', 'Yes']
        norm_by_DC_combo = widget_combobox(base56_5, value = str, scr_xsize = 110) 
        widget_control, norm_by_DC_combo, set_combobox_select = data.norm_by_DC
      base57 = widget_base(base5, /row)
        label57 = widget_label(base57, value = 'Apply Hanning Window to each sub-time window:      ')
        str = ['No', 'Yes']
        use_hanning_window_combo = widget_combobox(base57, value = str, scr_xsize = 110) 
        widget_control, use_hanning_window_combo, set_combobox_select = data.use_hanning_window
      base58 = widget_base(base5, /row)
        label58 = widget_label(base58, value = 'Remove Large Structure by spatial averaging:       ')
        str = ['No', 'Yes']
        remove_large_structure_combo = widget_combobox(base58, value = str, scr_xsize = 110)
        widget_control, remove_large_structure_combo, set_combobox_select = data.remove_large_structure
    base6 = widget_base(base)
      help_button = widget_button(base6, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base6, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 160, yoffset = 20)
      save_options_button = widget_button(base6, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 270, yoffset = 20)
      close_button = widget_button(base6, value = 'Close', xsize = 100, ysize = 30, xoffset= 385, yoffset = 20)

; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            calc_in_IDL_button:calc_in_IDL_button, $
            calc_in_CUDA_button:calc_in_CUDA_button, $
            BES_ch_sel1_button:BES_ch_sel1_button, $
            BEs_ch_sel2_button:BEs_ch_sel2_button, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            calc_spectrum_button:calc_spectrum_button, $
            calc_spectrogram_button:calc_spectrogram_button, $
            calc_power_button:calc_power_button, $
            calc_phase_button:calc_phase_button, $
            num_pts_per_subwindow_combo:num_pts_per_subwindow_combo, $
            num_bins_to_average_text:num_bins_to_average_text, $
            frac_overlap_subwindow_slider:frac_overlap_subwindow_slider, $
            frac_overlap_subwindow_label:frac_overlap_subwindow_label, $
            norm_by_DC_combo:norm_by_DC_combo, $
            use_hanning_window_combo:use_hanning_window_combo, $
            remove_large_structure_combo:remove_large_structure_combo, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}


  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_dens_spec_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for density spectrum.
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_dens_spec_window
;===================================================================================
pro kill_dens_spec_window, base_id

; kill dens_spec_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for density coherency, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_dens_coh_window, id_main_base


; get the dens_spec_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.dens_coh_window_data

; creating widgets
  window_title = 'Options to calculate density coherency'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 485, ysize = 810, $
                     group_leader = id_main_base)
    base1 = widget_base(base, /row, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Calculate density coherency using               ', /align_left)
      base12 = widget_base(base1, /row, /exclusive)
        calc_in_IDL_button = widget_button(base12, value = '  IDL  ')
        calc_in_CUDA_button = widget_button(base12, value = '  CUDA  ')
        if data.calc_in_IDL eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 1
          widget_control, calc_in_CUDA_button, set_button = 0
        endif else if data.calc_in_CUDA eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 0
          widget_control, calc_in_CUDA_button, set_button = 1
        endif
    base2 = widget_base(base, /column)
      label2 = widget_label(base2, value = 'Select one BES Ch. for Signal 1', /align_left)
      base21 = widget_base(base2, /column, frame = 1)
        BES_ch_sel1_button = lonarr(32)
        base211 = lonarr(4)
        for i = 0, 3 do begin
          base211[i] = widget_base(base21, /row, /nonexclusive)
          for j = 0, 7 do begin
            ch_num = 32 - j - i*8
            str = string(ch_num, format='(i2)') + '   '
            BES_ch_sel1_button[ch_num - 1] = widget_button(base211[i], value = str)
          endfor
        endfor
        for i = 0, n_elements(data.BES_ch_sel1)-1 do $
          widget_control, BEs_ch_sel1_button[i], set_button = data.BES_ch_sel1[i]
    base3 = widget_base(base, /column)
      label3 = widget_label(base3, value = 'Select one BES Ch. for Signal 2', /align_left)
      base31 = widget_base(base3, /column, frame = 1)
        BES_ch_sel2_button = lonarr(32)
        base311 = lonarr(4)
        for i = 0, 3 do begin
          base311[i] = widget_base(base31, /row, /nonexclusive)
          for j = 0, 7 do begin
            ch_num = 32 - j - i*8
            str = string(ch_num, format='(i2)') + '   '
            BES_ch_sel2_button[ch_num - 1] = widget_button(base311[i], value = str)
          endfor
        endfor
        for i = 0, n_elements(data.BES_ch_sel2)-1 do $
          widget_control, BEs_ch_sel2_button[i], set_button = data.BES_ch_sel2[i]
    base4 = widget_base(base)
      plot_button = widget_button(base4, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 100, yoffset = 10)
      oplot_button = widget_button(base4, value = 'OPLOT', xsize = 100, ysize = 30, xoffset = 285, yoffset = 10)
    label = widget_label(base, value = '')
    label = widget_label(base, value = '')
    base5 = widget_base(base, /column, frame = 1)
      base51 = widget_base(base5, /row)
        label51 = widget_label(base51, value = 'Frequency Filtering From  ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  To  ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  kHz')
      base52 = widget_base(base5, /column)
        label52 = widget_label(base52, value = 'Calculate', /align_left)
      base53 = widget_base(base5, /row)
        base531 = widget_base(base53, /column)
          label531 = widget_label(base531, value = '     ')
          label531 = widget_label(base531, value = '     ')
        base532 = widget_base(base53, /column, frame = 1, /exclusive, xsize = 180)
          calc_spectrum_button = widget_button(base532, value = 'Spectrum       ')
          calc_spectrogram_button = widget_button(base532, value = 'Spectrogram    ')
          if data.calc_spectrum eq 1 then begin
            widget_control, calc_spectrum_button, set_button = 1
            widget_control, calc_spectrogram_button, set_button = 0
          endif else if data.calc_spectrogram eq 1 then begin
            widget_control, calc_spectrum_button, set_button = 0
            widget_control, calc_spectrogram_button, set_button = 1
          endif
        base533 = widget_base(base53, /column)
          label533 = widget_label(base533, value = '     ')
          label533 = widget_label(base533, value = '     ')
        base534 = widget_base(base53, /column, frame = 1, /exclusive, xsize = 180)
          calc_power_button = widget_button(base534, value = 'Coherency ')
          calc_phase_button = widget_button(base534, value = 'Phase     ')
          if data.calc_power eq 1 then begin
            widget_control, calc_power_button, set_button = 1
            widget_control, calc_phase_button, set_button = 0
          endif else if data.calc_phase eq 1 then begin
            widget_control, calc_power_button, set_button = 0
            widget_control, calc_phase_button, set_button = 1
          endif
      base54 = widget_base(base5, /row)
        label54 = widget_label(base54, value = 'Number of points per sub-time window:              ')
        npts = long(2^(findgen(15)+5))
        num_pts_per_subwindow_combo = widget_combobox(base54, value = string(npts, format='(i0)'))
        inx = where(data.num_pts_per_subwindow eq npts, count)
        if count eq 0 then inx = 0
        widget_control, num_pts_per_subwindow_combo, set_combobox_select = inx
      base55 = widget_base(base5, /row)
        label55 = widget_label(base55, value = 'Number of bins of sub-time windows to be averaged: ')
        str = string(data.num_bins_to_average, format='(i0)')
        num_bins_to_average_text = widget_text(base55, value = str, /editable, scr_xsize = 110)
        if data.calc_spectrum then $
          widget_control, num_bins_to_average_text, sensitive = 0 $
        else $
          widget_control, num_bins_to_average_text, sensitive = 1
      base56 = widget_base(base5, /row)
        label56 = widget_label(base56, value = 'Fraction of sub-time window overlap:               ')
        frac_overlap_subwindow_slider = widget_slider(base56,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
        widget_control, frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
        str = string(data.frac_overlap_subwindow, format='(f0.1)')
        frac_overlap_subwindow_label = widget_label(base56, value = str)
      base57 = widget_base(base5, /row)
        label57 = widget_label(base57, value = 'Apply Hanning Window to each sub-time window:      ')
        str = ['No', 'Yes']
        use_hanning_window_combo = widget_combobox(base57, value = str, scr_xsize = 110) 
        widget_control, use_hanning_window_combo, set_combobox_select = data.use_hanning_window
      base58 = widget_base(base5, /row)
        label58 = widget_label(base58, value = 'Remove Large Structure by spatial averaging:       ')
        str = ['No', 'Yes']
        remove_large_structure_combo = widget_combobox(base58, value = str, scr_xsize = 110)
        widget_control, remove_large_structure_combo, set_combobox_select = data.remove_large_structure
    base6 = widget_base(base)
      help_button = widget_button(base6, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base6, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 160, yoffset = 20)
      save_options_button = widget_button(base6, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 270, yoffset = 20)
      close_button = widget_button(base6, value = 'Close', xsize = 100, ysize = 30, xoffset= 385, yoffset = 20)

; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            calc_in_IDL_button:calc_in_IDL_button, $
            calc_in_CUDA_button:calc_in_CUDA_button, $
            BES_ch_sel1_button:BES_ch_sel1_button, $
            BEs_ch_sel2_button:BEs_ch_sel2_button, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            calc_spectrum_button:calc_spectrum_button, $
            calc_spectrogram_button:calc_spectrogram_button, $
            calc_power_button:calc_power_button, $
            calc_phase_button:calc_phase_button, $
            num_pts_per_subwindow_combo:num_pts_per_subwindow_combo, $
            num_bins_to_average_text:num_bins_to_average_text, $
            frac_overlap_subwindow_slider:frac_overlap_subwindow_slider, $
            frac_overlap_subwindow_label:frac_overlap_subwindow_label, $
            use_hanning_window_combo:use_hanning_window_combo, $
            remove_large_structure_combo:remove_large_structure_combo, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}


  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_dens_coh_window', base, /no_block


end


;===================================================================================
; This procedure kills a window for density coherency
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_dens_coh_window
;===================================================================================
pro kill_dens_coh_window, base_id

; kill dens_spec_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for density temporal correaltion, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_dens_temporal_corr_window, id_main_base

; get the dens_spec_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.dens_temp_corr_window_data

; creating widgets
  window_title = 'Options to calculate density temporal correlation'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 485, ysize = 895, $
                     group_leader = id_main_base)
   base1 = widget_base(base, /row, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Calculate density temporal correlation using    ', /align_left)
      base12 = widget_base(base1, /row, /exclusive)
        calc_in_IDL_button = widget_button(base12, value = '  IDL  ')
        calc_in_CUDA_button = widget_button(base12, value = '  CUDA  ')
        if data.calc_in_IDL eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 1
          widget_control, calc_in_CUDA_button, set_button = 0
        endif else if data.calc_in_CUDA eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 0
          widget_control, calc_in_CUDA_button, set_button = 1
        endif
    base2 = widget_base(base, /column)
      label2 = widget_label(base2, value = 'Select one BES Ch. for Signal 1', /align_left)
      base21 = widget_base(base2, /column, frame = 1)
        BES_ch_sel1_button = lonarr(32)
        base211 = lonarr(4)
        for i = 0, 3 do begin
          base211[i] = widget_base(base21, /row, /nonexclusive)
          for j = 0, 7 do begin
            ch_num = 32 - j - i*8
            str = string(ch_num, format='(i2)') + '   '
            BES_ch_sel1_button[ch_num - 1] = widget_button(base211[i], value = str)
          endfor
        endfor
        for i = 0, n_elements(data.BES_ch_sel1)-1 do $
          widget_control, BEs_ch_sel1_button[i], set_button = data.BES_ch_sel1[i]
    base3 = widget_base(base, /column)
      label3 = widget_label(base3, value = 'Select one BES Ch. for Signal 2', /align_left)
      base31 = widget_base(base3, /column, frame = 1)
        BES_ch_sel2_button = lonarr(32)
        base311 = lonarr(4)
        for i = 0, 3 do begin
          base311[i] = widget_base(base31, /row, /nonexclusive)
          for j = 0, 7 do begin
            ch_num = 32 - j - i*8
            str = string(ch_num, format='(i2)') + '   '
            BES_ch_sel2_button[ch_num - 1] = widget_button(base311[i], value = str)
          endfor
        endfor
        for i = 0, n_elements(data.BES_ch_sel2)-1 do $
          widget_control, BES_ch_sel2_button[i], set_button = data.BES_ch_sel2[i]
    base4 = widget_base(base)
      plot_button = widget_button(base4, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 100, yoffset = 10)
      oplot_button = widget_button(base4, value = 'OPLOT', xsize = 100, ysize = 30, xoffset = 285, yoffset = 10)
    label = widget_label(base, value = '')
    label = widget_label(base, value = '')
    base5 = widget_base(base, /column, frame = 1)
      base51 = widget_base(base5, /row)
        label51 = widget_label(base51, value = 'Frequency Filtering From  ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  To  ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  kHz')
      base52 = widget_base(base5, /column)
        label52 = widget_label(base52, value = 'Calculate', /align_left)
      base53 = widget_base(base5, /row)
        base531 = widget_base(base53, /column)
          label531 = widget_label(base531, value = '     ')
          label531 = widget_label(base531, value = '     ')
        base532 = widget_base(base53, /column, frame = 1, /exclusive, xsize = 180)
          calc_correlation_button = widget_button(base532, value = 'Correlation (Normalized)')
          calc_covariance_button = widget_button(base532, value = 'Covariance')
          if data.calc_correlation eq 1 then begin
            widget_control, calc_correlation_button, set_button = 1
            widget_control, calc_covariance_button, set_button = 0
          endif else begin
            widget_control, calc_correlation_button, set_button = 0
            widget_control, calc_covariance_button, set_button = 1
          endelse
        base533 = widget_base(base53, /column)
          label533 = widget_label(base533, value = '     ')
          label533 = widget_label(base533, value = '     ')
        base534 = widget_base(base53, /column, frame = 1, /exclusive, xsize = 180)
          calc_fcn_tau_button = widget_button(base534, value = 'As a fcn of tau')
          calc_fcn_tau_time_button = widget_button(base534, value = 'As a fcn of tau and time')
          if data.calc_fcn_tau eq 1 then begin
            widget_control, calc_fcn_tau_button, set_button = 1
            widget_control, calc_fcn_tau_time_button, set_button = 0
          endif else begin
            widget_control, calc_fcn_tau_button, set_button = 0
            widget_control, calc_fcn_tau_time_button, set_button = 1
          endelse
      base54 = widget_base(base5, /row)
        label54 = widget_label(base54, value = 'Time delay range:  From  ', /align_left)
        str = string(data.time_delay_low, format='(f0.1)')
        time_delay_low_text = widget_text(base54, value = str, /editable, scr_xsize = 80)
        label54 = widget_label(base54, value = '  To  ')
        str = string(data.time_delay_high, format='(f0.1)')
        time_delay_high_text = widget_text(base54, value = str, /editable, scr_xsize = 80)
        label54 = widget_label(base54, value = '  micro-seconds')
      base55 = widget_base(base5, /row)
        label55 = widget_label(base55, value = 'Number of bins of sub-time windows to be averaged: ')
        str = string(data.num_bins_to_average, format='(i0)')
        num_bins_to_average_text = widget_text(base55, value = str, /editable, scr_xsize = 110)
        if data.calc_fcn_tau then $
          widget_control, num_bins_to_average_text, sensitive = 0 $
        else $
          widget_control, num_bins_to_average_text, sensitive = 1
      base56 = widget_base(base5, /row)
        label56 = widget_label(base56, value = 'Fraction of sub-time window overlap:               ')
        frac_overlap_subwindow_slider = widget_slider(base56,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
        widget_control, frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
        str = string(data.frac_overlap_subwindow, format='(f0.1)')
        frac_overlap_subwindow_label = widget_label(base56, value = str)
      base57 = widget_base(base5, /row)
        label57 = widget_label(base57, value = 'Apply Hanning Window to each sub-time window:      ')
        str = ['No', 'Yes']
        use_hanning_window_combo = widget_combobox(base57, value = str, scr_xsize = 110) 
        widget_control, use_hanning_window_combo, set_combobox_select = data.use_hanning_window
      base58 = widget_base(base5, /row)
        label58 = widget_label(base58, value = 'Remove Large Structure by spatial averaging:       ')
        str = ['No', 'Yes']
        remove_large_structure_combo = widget_combobox(base58, value = str, scr_xsize = 110)
        widget_control, remove_large_structure_combo, set_combobox_select = data.remove_large_structure
      base59 = widget_base(base5, /row)
        label59 = widget_label(base59, value = 'Number of pts to remove ph. peak for auto-corr.:   ')
        str = string(data.num_pts_to_remove_ph_peak, format='(i0)')
        num_pts_to_remove_ph_peak_text = widget_text(base59, value = str, /editable, scr_xsize=110)
        label59 = widget_label(base59, value = ' pts')
      base60 = widget_base(base5, /row)
        base601 = widget_base(base60, /column, /nonexclusive)
          show_filter_response_button = widget_button(base601, value = '  Show Filter Response') 
          if data.show_filter_response eq 1 then $
            widget_control, show_filter_response_button, set_button = 1 $
          else $
            widget_control, show_filter_response_button, set_button = 0
        base602 = widget_base(base60, /column)
          label602 = widget_label(base602, value = '          ')
        base603 = widget_base(base60, /column, /nonexclusive)
          show_envelope_button = widget_button(base603, value = '  Show Envelope') 
          if data.show_envelope eq 1 then $
            widget_control, show_envelope_button, set_button = 1 $
          else $
            widget_control, show_envelope_button, set_button = 0
    base7 = widget_base(base)
      help_button = widget_button(base7, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base7, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 160, yoffset = 20)
      save_options_button = widget_button(base7, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 270, yoffset = 20)
      close_button = widget_button(base7, value = 'Close', xsize = 100, ysize = 30, xoffset= 385, yoffset = 20)

; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            calc_in_IDL_button:calc_in_IDL_button, $
            calc_in_CUDA_button:calc_in_CUDA_button, $
            BES_ch_sel1_button:BES_ch_sel1_button, $
            BEs_ch_sel2_button:BEs_ch_sel2_button, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            calc_correlation_button:calc_correlation_button, $
            calc_covariance_button:calc_covariance_button, $
            calc_fcn_tau_button:calc_fcn_tau_button, $
            calc_fcn_tau_time_button:calc_fcn_tau_time_button, $
            time_delay_low_text:time_delay_low_text, $
            time_delay_high_text:time_delay_high_text, $
            num_bins_to_average_text:num_bins_to_average_text, $
            frac_overlap_subwindow_slider:frac_overlap_subwindow_slider, $
            frac_overlap_subwindow_label:frac_overlap_subwindow_label, $
            use_hanning_window_combo:use_hanning_window_combo, $
            remove_large_structure_combo:remove_large_structure_combo, $
            num_pts_to_remove_ph_peak_text:num_pts_to_remove_ph_peak_text, $
            show_filter_response_button:show_filter_response_button, $
            show_envelope_button:show_envelope_button, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}

  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_dens_temporal_corr_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for density temporal correlation
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_dens_temporal_corr_window
;===================================================================================
pro kill_dens_temporal_corr_window, base_id

; kill dens_temporal_corr_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for density spatio-temporal correaltion, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_dens_spa_temp_corr_window, id_main_base

; get the dens_spec_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.dens_spa_temp_corr_window_data

; creating widgets
  window_title = 'Options to calculate density spatio-temporal correlation'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 555, ysize = 805, $
                     group_leader = id_main_base)
   base1 = widget_base(base, /row, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Calculate density spatio-temporal corr. using   ', /align_left)
      base12 = widget_base(base1, /row, /exclusive)
        calc_in_IDL_button = widget_button(base12, value = '  IDL       ')
        calc_in_CUDA_button = widget_button(base12, value = '  CUDA       ')
        if data.calc_in_IDL eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 1
          widget_control, calc_in_CUDA_button, set_button = 0
        endif else if data.calc_in_CUDA eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 0
          widget_control, calc_in_CUDA_button, set_button = 1
        endif
    base2 = widget_base(base, /row, frame = 1)
      base21 = widget_base(base2, /row)
        label21 = widget_label(base21, value = 'The direction of spatial correlation            ', /align_left)
      base22 = widget_base(base2, /row, /exclusive)
        calc_pol_spa_button = widget_button(base22, value = 'POLOIDL     ')
        calc_rad_spa_button = widget_button(base22, value = 'RADIAL     ')
        if data.calc_pol_spa eq 1 then begin
          widget_control, calc_pol_spa_button, set_button = 1
          widget_control, calc_rad_spa_button, set_button = 0
        endif else if data.calc_rad_spa eq 1 then begin
          widget_control, calc_pol_spa_button, set_button = 0
          widget_control, calc_rad_spa_button, set_button = 1
        endif
    base3 = widget_base(base, /column)
      label3 = widget_label(base3, value = 'Select multiple BES channels for spatio-temporal correlation', /align_left)
      base31 = widget_base(base3, /column, frame = 1)
        BES_Ch_button = lonarr(32)
        POL_Ch_button = lonarr(4)
        RAD_Ch_button = lonarr(8)
        base311 = widget_base(base31, /row)
          base3111 = widget_base(base311, /row)
            label3111 = widget_label(base3111, value = '         ')
          base3112 = widget_base(base311, /row, /nonexclusive)
            RAD_Ch_button[7] = widget_button(base3112, value = 'RAD 8')
            RAD_Ch_button[6] = widget_button(base3112, value = 'RAD 7')
            RAD_Ch_button[5] = widget_button(base3112, value = 'RAD 6')
            RAD_Ch_button[4] = widget_button(base3112, value = 'RAD 5')
            RAD_Ch_button[3] = widget_button(base3112, value = 'RAD 4')
            RAD_Ch_button[2] = widget_button(base3112, value = 'RAD 3')
            RAD_Ch_button[1] = widget_button(base3112, value = 'RAD 2')
            RAD_Ch_button[0] = widget_button(base3112, value = 'RAD 1')
        base312 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[3] = widget_button(base312, value = 'POL 4  ')
          BES_Ch_button[31] = widget_button(base312, value = '32   ')
          BES_Ch_button[30] = widget_button(base312, value = '31   ')
          BES_Ch_button[29] = widget_button(base312, value = '30   ')
          BES_Ch_button[28] = widget_button(base312, value = '29   ')
          BES_Ch_button[27] = widget_button(base312, value = '28   ')
          BES_Ch_button[26] = widget_button(base312, value = '27   ')
          BES_Ch_button[25] = widget_button(base312, value = '26   ')
          BES_Ch_button[24] = widget_button(base312, value = '25   ')
        base313 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[2] = widget_button(base313, value = 'POL 3  ')
          BES_Ch_button[23] = widget_button(base313, value = '24   ')
          BES_Ch_button[22] = widget_button(base313, value = '23   ')
          BES_Ch_button[21] = widget_button(base313, value = '22   ')
          BES_Ch_button[20] = widget_button(base313, value = '21   ')
          BES_Ch_button[19] = widget_button(base313, value = '20   ')
          BES_Ch_button[18] = widget_button(base313, value = '19   ')
          BES_Ch_button[17] = widget_button(base313, value = '18   ')
          BES_Ch_button[16] = widget_button(base313, value = '17   ')
        base314 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[1] = widget_button(base314, value = 'POL 2  ')
          BES_Ch_button[15] = widget_button(base314, value = '16   ')
          BES_Ch_button[14] = widget_button(base314, value = '15   ')
          BES_Ch_button[13] = widget_button(base314, value = '14   ')
          BES_Ch_button[12] = widget_button(base314, value = '13   ')
          BES_Ch_button[11] = widget_button(base314, value = '12   ')
          BES_Ch_button[10] = widget_button(base314, value = '11   ')
          BES_Ch_button[9] = widget_button(base314, value = '10   ')
          BES_Ch_button[8] = widget_button(base314, value = ' 9   ')
        base315 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[0] = widget_button(base315, value = 'POL 1  ')
          BES_Ch_button[7] = widget_button(base315, value = ' 8   ')
          BES_Ch_button[6] = widget_button(base315, value = ' 7   ')
          BES_Ch_button[5] = widget_button(base315, value = ' 6   ')
          BES_Ch_button[4] = widget_button(base315, value = ' 5   ')
          BES_Ch_button[3] = widget_button(base315, value = ' 4   ')
          BES_Ch_button[2] = widget_button(base315, value = ' 3   ')
          BES_Ch_button[1] = widget_button(base315, value = ' 2   ')
          BES_Ch_button[0] = widget_button(base315, value = ' 1   ')
      for i = 0, n_elements(data.BES_ch_sel)-1 do $
        widget_control, BES_Ch_button[i], set_button = data.BES_ch_sel[i]
      for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
        widget_control, RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
      for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
        widget_control, POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
    base4 = widget_base(base)
      plot_button = widget_button(base4, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 50, yoffset = 10)
      movie_button = widget_button(base4, value = 'START MOVIE', xsize = 100, ysize = 30, xoffset = 220, yoffset = 10)
      plot_pitch_button = widget_button(base4, value = 'PLOT PITCH ANGLE', xsize = 120, ysize = 30, xoffset = 390, yoffset = 10)
    label = widget_label(base, value = '')
    label = widget_label(base, value = '')
    base5 = widget_base(base, /column, frame = 1)
      base51 = widget_base(base5, /row)
        label51 = widget_label(base51, value = 'Frequency Filtering From  ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  To  ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  kHz')
      base52 = widget_base(base5, /row)
        label52 = widget_label(base52, value = 'Calculate', /align_left)
        str = ['At a fixed time', 'As a fcn of time']
        calc_fcn_time_combo = widget_combobox(base52, value = str, scr_xsize = 150)
        widget_control, calc_fcn_time_combo, set_combobox_select = data.calc_fcn_time
        label52 = widget_label(base52, value = '     ')
        base521 = widget_base(base52, /row, /nonexclusive)
          convert_temp_to_spa_button = widget_button(base521, value = 'Convert Temporal info to Spatial info')
          widget_control, convert_temp_to_spa_button, set_button = data.convert_temp_to_spa
      base53 = widget_base(base5, /row)
        base531 = widget_base(base53, /column)
          label531 = widget_label(base531, value = '  ')
          label531 = widget_label(base531, value = '  ')
        base532 = widget_base(base53, /column, frame = 1, /exclusive, xsize = 170)
          calc_correlation_button = widget_button(base532, value = 'Correlation (Normalized)')
          calc_covariance_button = widget_button(base532, value = 'Covariance')
          if data.calc_correlation eq 1 then begin
            widget_control, calc_correlation_button, set_button = 1
            widget_control, calc_covariance_button, set_button = 0
          endif else begin
            widget_control, calc_correlation_button, set_button = 0
            widget_control, calc_covariance_button, set_button = 1
          endelse
        base533 = widget_base(base53, /column)
          label533 = widget_label(base533, value = '        ')
          label533 = widget_label(base533, value = '        ')
        base534 = widget_base(base53, /column, frame = 1)
          base5341 = widget_base(base534, /row)
            base53411 = widget_base(base5341, /row, /nonexclusive)
              use_cxrs_data_button = widget_button(base53411, value = 'Use CXRS ')
              widget_control, use_cxrs_data_button, set_button = data.use_cxrs_data
            base53412 = widget_base(base5341, /row)
              str = ['SW', 'SS']
              use_ss_cxrs_combo = widget_combobox(base53412, value = str, scr_xsize = 50)
              widget_control, use_ss_cxrs_combo, set_combobox_select = data.use_ss_cxrs
            base53413 = widget_base(base5341, /row)
              plot_cxrs_button = widget_button(base53413, value = 'PLOT (v_tor)', xsize = 100)
          base5342 = widget_base(base534, /row)
            label5342 = widget_label(base5342, value = ' Manual Input: ')
            str = string(data.manual_vtor, format='(f0.2)')
            manual_vtor_text = widget_text(base5342, value = str, /editable, scr_xsize = 100)
            label5342 = widget_label(base5342, value = ' km/s')
      base54 = widget_base(base5, /row)
        label54 = widget_label(base54, value = 'Time delay range:  From  ', /align_left)
        str = string(data.time_delay_low, format='(f0.1)')
        time_delay_low_text = widget_text(base54, value = str, /editable, scr_xsize = 80)
        label54 = widget_label(base54, value = '  To  ')
        str = string(data.time_delay_high, format='(f0.1)')
        time_delay_high_text = widget_text(base54, value = str, /editable, scr_xsize = 80)
        label54 = widget_label(base54, value = '  micro-seconds')
      base55 = widget_base(base5, /row)
        label55 = widget_label(base55, value = 'Number of bins of sub-time windows to be averaged: ')
        str = string(data.num_bins_to_average, format='(i0)')
        num_bins_to_average_text = widget_text(base55, value = str, /editable, scr_xsize = 110)
      base56 = widget_base(base5, /row)
        label56 = widget_label(base56, value = 'Fraction of sub-time window overlap:               ')
        frac_overlap_subwindow_slider = widget_slider(base56,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
        widget_control, frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
        str = string(data.frac_overlap_subwindow, format='(f0.1)')
        frac_overlap_subwindow_label = widget_label(base56, value = str)
      base57 = widget_base(base5, /row)
        label57 = widget_label(base57, value = 'Apply Hanning Window to each sub-time window:      ')
        str = ['No', 'Yes']
        use_hanning_window_combo = widget_combobox(base57, value = str, scr_xsize = 110) 
        widget_control, use_hanning_window_combo, set_combobox_select = data.use_hanning_window
      base58 = widget_base(base5, /row)
        label58 = widget_label(base58, value = 'Remove Large Structure by spatial averaging:       ')
        str = ['No', 'Yes']
        remove_large_structure_combo = widget_combobox(base58, value = str, scr_xsize = 110)
        widget_control, remove_large_structure_combo, set_combobox_select = data.remove_large_structure
      base59 = widget_base(base5, /row)
        label59 = widget_label(base59, value = 'Increase the spatial resolution by factor of ')
        str = string(data.factor_inc_spa_pts, format = '(i0)')
        factor_inc_spa_pts_text = widget_text(base59, value = str, /editable, scr_xsize = 80)
        label59 = widget_label(base59, value = '(by spatial interpolation)')
    base6 = widget_base(base)
      help_button = widget_button(base6, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base6, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 190, yoffset = 20)
      save_options_button = widget_button(base6, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 320, yoffset = 20)
      close_button = widget_button(base6, value = 'Close', xsize = 100, ysize = 30, xoffset= 455, yoffset = 20)


; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            calc_in_IDL_button:calc_in_IDL_button, $
            calc_in_CUDA_button:calc_in_CUDA_button, $
            calc_pol_spa_button:calc_pol_spa_button, $
            calc_rad_spa_button:calc_rad_spa_button, $
            BES_Ch_button:BES_Ch_button, $
            POL_Ch_button:POL_Ch_button, $
            RAD_Ch_button:RAD_Ch_button, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            calc_fcn_time_combo:calc_fcn_time_combo, $
            convert_temp_to_spa_button:convert_temp_to_spa_button, $
            calc_correlation_button:calc_correlation_button, $
            calc_covariance_button:calc_covariance_button, $
            use_cxrs_data_button:use_cxrs_data_button, $
            use_ss_cxrs_combo:use_ss_cxrs_combo, $
            manual_vtor_text:manual_vtor_text, $
            time_delay_low_text:time_delay_low_text, $
            time_delay_high_text:time_delay_high_text, $
            num_bins_to_average_text:num_bins_to_average_text, $
            frac_overlap_subwindow_slider:frac_overlap_subwindow_slider, $
            frac_overlap_subwindow_label:frac_overlap_subwindow_label, $
            remove_large_structure_combo:remove_large_structure_combo, $
            use_hanning_window_combo:use_hanning_window_combo, $
            factor_inc_spa_pts_text:factor_inc_spa_pts_text, $
            plot_button:plot_button, $
            movie_button:movie_button, $
            plot_pitch_button:plot_pitch_button, $
            plot_cxrs_button:plot_cxrs_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}


  widget_control, base, set_uvalue = idinfo

; control the senstivity of widgets
  sens_check_bes_dens_spa_temp_corr_window, idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_dens_spa_temp_corr_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for density spatio temporal correlation
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_dens_spa_temp_corr_window
;===================================================================================
pro kill_dens_spa_temp_corr_window, base_id

; kill dens_spa_temp_corr_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for calculating time evolution of velocity, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_vel_evol_window, id_main_base

; get the vel_time_evol_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.vel_time_evol_window_data

; creating widgets
  window_title = 'Options to calculate time evolution of pattern velocity'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events, xsize = 555, ysize = 845, $
                     group_leader = id_main_base)
   base1 = widget_base(base, /row, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Calculate time evolution of pattern velocity using', /align_left)
      base12 = widget_base(base1, /row, /exclusive)
        calc_in_IDL_button = widget_button(base12, value = '  IDL       ')
        calc_in_CUDA_button = widget_button(base12, value = '  CUDA       ')
        if data.calc_in_IDL eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 1
          widget_control, calc_in_CUDA_button, set_button = 0
        endif else if data.calc_in_CUDA eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 0
          widget_control, calc_in_CUDA_button, set_button = 1
        endif
    base2 = widget_base(base, /row, frame = 1)
      base21 = widget_base(base2, /row)
        labe21 = widget_label(base21, value = 'The direction of velocity to be calculated        ', /align_left)
      base22 = widget_base(base2, /row, /exclusive)
        calc_pol_vel_button = widget_button(base22, value = 'POLOIDL     ')
        calc_rad_vel_button = widget_button(base22, value = 'RADIAL     ')
        if data.calc_pol_vel eq 1 then begin
          widget_control, calc_pol_vel_button, set_button = 1
          widget_control, calc_rad_vel_button, set_button = 0
        endif else if data.calc_rad_vel eq 1 then begin
          widget_control, calc_pol_vel_button, set_button = 0
          widget_control, calc_rad_vel_button, set_button = 1
        endif
    base3 = widget_base(base, /column)
      label3 = widget_label(base3, value = 'Select multiple BES channels for velocity calculation', /align_left)
      base31 = widget_base(base3, /column, frame = 1)
        BES_Ch_button = lonarr(32)
        POL_Ch_button = lonarr(4)
        RAD_Ch_button = lonarr(8)
        base311 = widget_base(base31, /row)
          base3111 = widget_base(base311, /row)
            label3111 = widget_label(base3111, value = '         ')
          base3112 = widget_base(base311, /row, /nonexclusive)
            RAD_Ch_button[7] = widget_button(base3112, value = 'RAD 8')
            RAD_Ch_button[6] = widget_button(base3112, value = 'RAD 7')
            RAD_Ch_button[5] = widget_button(base3112, value = 'RAD 6')
            RAD_Ch_button[4] = widget_button(base3112, value = 'RAD 5')
            RAD_Ch_button[3] = widget_button(base3112, value = 'RAD 4')
            RAD_Ch_button[2] = widget_button(base3112, value = 'RAD 3')
            RAD_Ch_button[1] = widget_button(base3112, value = 'RAD 2')
            RAD_Ch_button[0] = widget_button(base3112, value = 'RAD 1')
        base312 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[3] = widget_button(base312, value = 'POL 4  ')
          BES_Ch_button[31] = widget_button(base312, value = '32   ')
          BES_Ch_button[30] = widget_button(base312, value = '31   ')
          BES_Ch_button[29] = widget_button(base312, value = '30   ')
          BES_Ch_button[28] = widget_button(base312, value = '29   ')
          BES_Ch_button[27] = widget_button(base312, value = '28   ')
          BES_Ch_button[26] = widget_button(base312, value = '27   ')
          BES_Ch_button[25] = widget_button(base312, value = '26   ')
          BES_Ch_button[24] = widget_button(base312, value = '25   ')
        base313 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[2] = widget_button(base313, value = 'POL 3  ')
          BES_Ch_button[23] = widget_button(base313, value = '24   ')
          BES_Ch_button[22] = widget_button(base313, value = '23   ')
          BES_Ch_button[21] = widget_button(base313, value = '22   ')
          BES_Ch_button[20] = widget_button(base313, value = '21   ')
          BES_Ch_button[19] = widget_button(base313, value = '20   ')
          BES_Ch_button[18] = widget_button(base313, value = '19   ')
          BES_Ch_button[17] = widget_button(base313, value = '18   ')
          BES_Ch_button[16] = widget_button(base313, value = '17   ')
        base314 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[1] = widget_button(base314, value = 'POL 2  ')
          BES_Ch_button[15] = widget_button(base314, value = '16   ')
          BES_Ch_button[14] = widget_button(base314, value = '15   ')
          BES_Ch_button[13] = widget_button(base314, value = '14   ')
          BES_Ch_button[12] = widget_button(base314, value = '13   ')
          BES_Ch_button[11] = widget_button(base314, value = '12   ')
          BES_Ch_button[10] = widget_button(base314, value = '11   ')
          BES_Ch_button[9] = widget_button(base314, value = '10   ')
          BES_Ch_button[8] = widget_button(base314, value = ' 9   ')
        base315 = widget_base(base31, /row, /nonexclusive)
          POL_Ch_button[0] = widget_button(base315, value = 'POL 1  ')
          BES_Ch_button[7] = widget_button(base315, value = ' 8   ')
          BES_Ch_button[6] = widget_button(base315, value = ' 7   ')
          BES_Ch_button[5] = widget_button(base315, value = ' 6   ')
          BES_Ch_button[4] = widget_button(base315, value = ' 5   ')
          BES_Ch_button[3] = widget_button(base315, value = ' 4   ')
          BES_Ch_button[2] = widget_button(base315, value = ' 3   ')
          BES_Ch_button[1] = widget_button(base315, value = ' 2   ')
          BES_Ch_button[0] = widget_button(base315, value = ' 1   ')
      for i = 0, n_elements(data.BES_ch_sel)-1 do $
        widget_control, BES_Ch_button[i], set_button = data.BES_ch_sel[i]
      for i = 0, n_elements(data.BES_RAD_ch_sel)-1 do $
        widget_control, RAD_Ch_button[i], set_button = data.BES_RAD_ch_sel[i]
      for i = 0, n_elements(data.BES_POL_ch_sel)-1 do $
        widget_control, POL_Ch_button[i], set_button = data.BES_POL_ch_sel[i]
    base4 = widget_base(base)
        plot_button = widget_button(base4, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 125, yoffset = 10)
        oplot_button = widget_button(base4, value = 'OPLOT', xsize = 100, ysize = 30, xoffset = 325, yoffset = 10)
    label = widget_label(base, value = '')
    label = widget_label(base, value = '')
    base5 = widget_base(base, /column, frame = 1)
      base51 = widget_base(base5, /row)
        label51 = widget_label(base51, value = 'Frequency Filtering From  ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  To  ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  kHz')
      base52 = widget_base(base5, /row)
        base521 = widget_base(base52, /row, /nonexclusive)
          convert_to_tor_vel_button = widget_button(base521, value = 'Convert to Toroidal Velocity')
          widget_control, convert_to_tor_vel_button, set_button = data.convert_to_tor_vel
          widget_control, convert_to_tor_vel_button, sensitive = data.calc_pol_vel
        label = widget_label(base52, value = '          ')
        base522 = widget_base(base52, /column, /nonexclusive, frame = 1)
          compare_cxrs_ss_button = widget_button(base522, value = 'Compare with CXRS SS data          ')
          compare_cxrs_sw_button = widget_button(base522, value = 'Compare with CXRS SW data          ')
          widget_control, compare_cxrs_ss_button, set_button = data.compare_cxrs_ss
          widget_control, compare_cxrs_sw_button, set_button = data.compare_cxrs_sw
          if ( (data.calc_pol_vel eq 1) and (data.convert_to_tor_vel eq 1) ) then begin
            widget_control, compare_cxrs_ss_button, sensitive = 1
            widget_control, compare_cxrs_sw_button, sensitive = 1
          endif else begin
            widget_control, compare_cxrs_ss_button, sensitive = 0
            widget_control, compare_cxrs_sw_button, sensitive = 0
          endelse
      base54 = widget_base(base5, /row)
        label54 = widget_label(base54, value = 'Time delay range:  From  ', /align_left)
        str = string(data.time_delay_low, format='(f0.1)')
        time_delay_low_text = widget_text(base54, value = str, /editable, scr_xsize = 80)
        label54 = widget_label(base54, value = '  To  ')
        str = string(data.time_delay_high, format='(f0.1)')
        time_delay_high_text = widget_text(base54, value = str, /editable, scr_xsize = 80)
        label54 = widget_label(base54, value = '  micro-seconds')
      base55 = widget_base(base5, /row)
        label55 = widget_label(base55, value = 'Number of bins of sub-time windows to be averaged: ')
        str = string(data.num_bins_to_average, format='(i0)')
        num_bins_to_average_text = widget_text(base55, value = str, /editable, scr_xsize = 110)
      base56 = widget_base(base5, /row)
        label56 = widget_label(base56, value = 'Fraction of sub-time window overlap:               ')
        frac_overlap_subwindow_slider = widget_slider(base56,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
        widget_control, frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
        str = string(data.frac_overlap_subwindow, format='(f0.1)')
        frac_overlap_subwindow_label = widget_label(base56, value = str)
      base57 = widget_base(base5, /row)
        label57 = widget_label(base57, value = 'Apply Hanning Window to each sub-time window:      ')
        str = ['No', 'Yes']
        use_hanning_window_combo = widget_combobox(base57, value = str, scr_xsize = 110) 
        widget_control, use_hanning_window_combo, set_combobox_select = data.use_hanning_window
      base58 = widget_base(base5, /row)
        label58 = widget_label(base58, value = 'Remove Large Structure by spatial averaging:       ')
        str = ['No', 'Yes']
        remove_large_structure_combo = widget_combobox(base58, value = str, scr_xsize = 110)
        widget_control, remove_large_structure_combo, set_combobox_select = data.remove_large_structure
      base59 = widget_base(base5, /row)
        base591 = widget_base(base59, /row, /nonexclusive)
          apply_median_filter_button = widget_button(base591, value = 'Apply median filter on v(t)')
          widget_control, apply_median_filter_button, set_button = data.apply_median_filter
        base592 = widget_base(base59, /row)
          label592 = widget_label(base592, value = '          Median Filter Width: ')
          str = string(data.median_filter_width, format='(i0)')
          median_filter_width_text = widget_text(base592, value = str, /editable, scr_xsize = 80)
          label592 = widget_label(base592, value = 'points')
          widget_control, median_filter_width_text, sensitive = data.apply_median_filter
      base5_10 = widget_base(base5, /row)
        base5_101 = widget_base(base5_10, /row)
          base5_1011 = widget_base(base5_101, /row, /nonexclusive)
            apply_field_method_button = widget_button(base5_1011, value = 'Apply Field''s Method')
            widget_control, apply_field_method_button, set_button = data.apply_field_method
            widget_control, apply_field_method_button, sensitive = data.apply_median_filter
        base5_102 = widget_base(base5_10, /column)
          base5_1021 = widget_base(base5_102, /row)
            label5_1021 = widget_label(base5_1021, value = '  Num. of time pts for running mean & S.D: ')
            str = string(data.num_time_pts_field_method, format='(i0)')
            num_time_pts_field_method_text = widget_text(base5_1021, value = str, /editable, scr_xsize = 50)
            label5_1021 = widget_label(base5_1021, value = 'points')
          base5_1022 = widget_base(base5_102, /row)
            label5_1022 = widget_label(base5_1022, value = '  Allowed multiple of standard deviation:  ')
            str = string(data.allowed_mult_sd, format='(f0.1)')
            allowed_mult_sd_text = widget_text(base5_1022, value = str, /editable, scr_xsize = 50)
          if ( (data.apply_median_filter eq 1) and (data.apply_field_method) ) then begin
            widget_control, num_time_pts_field_method_text, sensitive = 1
            widget_control, allowed_mult_sd_text, sensitive = 1
          endif else begin
            widget_control, num_time_pts_field_method_text, sensitive = 0
            widget_control, allowed_mult_sd_text, sensitive = 0
          endelse
    base6 = widget_base(base)
      help_button = widget_button(base6, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base6, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 190, yoffset = 20)
      save_options_button = widget_button(base6, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 320, yoffset = 20)
      close_button = widget_button(base6, value = 'Close', xsize = 100, ysize = 30, xoffset= 455, yoffset = 20)


; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            calc_in_IDL_button:calc_in_IDL_button, $
            calc_in_CUDA_button:calc_in_CUDA_button, $
            calc_pol_vel_button:calc_pol_vel_button, $
            calc_rad_vel_button:calc_rad_vel_button, $
            BES_Ch_button:BES_Ch_button, $
            POL_Ch_button:POL_Ch_button, $
            RAD_Ch_button:RAD_Ch_button, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            convert_to_tor_vel_button:convert_to_tor_vel_button, $
            compare_cxrs_ss_button:compare_cxrs_ss_button, $
            compare_cxrs_sw_button:compare_cxrs_sw_button, $
            time_delay_low_text:time_delay_low_text, $
            time_delay_high_text:time_delay_high_text, $
            num_bins_to_average_text:num_bins_to_average_text, $
            frac_overlap_subwindow_slider:frac_overlap_subwindow_slider, $
            frac_overlap_subwindow_label:frac_overlap_subwindow_label, $
            use_hanning_window_combo:use_hanning_window_combo, $
            remove_large_structure_combo:remove_large_structure_combo, $
            apply_median_filter_button:apply_median_filter_button, $
            median_filter_width_text:median_filter_width_text, $
            apply_field_method_button:apply_field_method_button, $
            num_time_pts_field_method_text:num_time_pts_field_method_text, $
            allowed_mult_sd_text:allowed_mult_sd_text, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}

  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_vel_evol_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for velocity evolution window
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_vel_evol_window
;===================================================================================
pro kill_vel_evol_window, base_id

; kill bes_vel_evol_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window for calculating spectrum of v(t), then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_vel_spec_window, id_main_base

; get the vel_time_evol_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.vel_spec_window_data

; creating widgets
  window_title = 'Options to calculate spectrum of pattern velocity'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 1115, ysize = 775, $
                     group_leader = id_main_base)
    base1 = widget_base(base, /row)
      base11 = widget_base(base1, /row, frame = 1)
        base111 = widget_base(base11, /row)
          label111 = widget_label(base11, value = 'Calculate spectrum pattern velocity using         ', /align_left)
        base112 = widget_base(base11, /row, /exclusive)
          calc_in_IDL_button = widget_button(base112, value = '  IDL       ')
          calc_in_CUDA_button = widget_button(base112, value = '  CUDA       ')
          if data.calc_in_IDL eq 1 then begin
            widget_control, calc_in_IDL_button, set_button = 1
            widget_control, calc_in_CUDA_button, set_button = 0
          endif else if data.calc_in_CUDA eq 1 then begin
            widget_control, calc_in_IDL_button, set_button = 0
            widget_control, calc_in_CUDA_button, set_button = 1
          endif
      base11_5 = widget_base(base1, /row)
        label11_5 = widget_label(base11_5, value = '   ')
      base12 = widget_base(base1, /row, frame = 1)
        base121 = widget_base(base12, /row)
          labe121 = widget_label(base121, value = 'The direction of velocity to be calculated        ', /align_left)
        base122 = widget_base(base12, /row, /exclusive)
          calc_pol_vel_button = widget_button(base122, value = 'POLOIDL     ')
          calc_rad_vel_button = widget_button(base122, value = 'RADIAL     ')
          if data.calc_pol_vel eq 1 then begin
            widget_control, calc_pol_vel_button, set_button = 1
            widget_control, calc_rad_vel_button, set_button = 0
          endif else if data.calc_rad_vel eq 1 then begin
            widget_control, calc_pol_vel_button, set_button = 0
            widget_control, calc_rad_vel_button, set_button = 1
          endif
    base2 = widget_base(base, /row)
      base21 = widget_base(base2, /column)
        label21 = widget_label(base21, value = 'Select multiple BES channels for velocity #1', /align_left)
        base211 = widget_base(base21, /column, frame = 1)
          BES_Ch_button1 = lonarr(32)
          POL_Ch_button1 = lonarr(4)
          RAD_Ch_button1 = lonarr(8)
          base2111 = widget_base(base211, /row)
            base21111 = widget_base(base2111, /row)
              label21111 = widget_label(base21111, value = '         ')
            base21112 = widget_base(base2111, /row, /nonexclusive)
              RAD_Ch_button1[7] = widget_button(base21112, value = 'RAD 8')
              RAD_Ch_button1[6] = widget_button(base21112, value = 'RAD 7')
              RAD_Ch_button1[5] = widget_button(base21112, value = 'RAD 6')
              RAD_Ch_button1[4] = widget_button(base21112, value = 'RAD 5')
              RAD_Ch_button1[3] = widget_button(base21112, value = 'RAD 4')
              RAD_Ch_button1[2] = widget_button(base21112, value = 'RAD 3')
              RAD_Ch_button1[1] = widget_button(base21112, value = 'RAD 2')
              RAD_Ch_button1[0] = widget_button(base21112, value = 'RAD 1')
          base2112 = widget_base(base211, /row, /nonexclusive)
            POL_Ch_button1[3] = widget_button(base2112, value = 'POL 4  ')
            BES_Ch_button1[31] = widget_button(base2112, value = '32   ')
            BES_Ch_button1[30] = widget_button(base2112, value = '31   ')
            BES_Ch_button1[29] = widget_button(base2112, value = '30   ')
            BES_Ch_button1[28] = widget_button(base2112, value = '29   ')
            BES_Ch_button1[27] = widget_button(base2112, value = '28   ')
            BES_Ch_button1[26] = widget_button(base2112, value = '27   ')
            BES_Ch_button1[25] = widget_button(base2112, value = '26   ')
            BES_Ch_button1[24] = widget_button(base2112, value = '25   ')
          base2113 = widget_base(base211, /row, /nonexclusive)
            POL_Ch_button1[2] = widget_button(base2113, value = 'POL 3  ')
            BES_Ch_button1[23] = widget_button(base2113, value = '24   ')
            BES_Ch_button1[22] = widget_button(base2113, value = '23   ')
            BES_Ch_button1[21] = widget_button(base2113, value = '22   ')
            BES_Ch_button1[20] = widget_button(base2113, value = '21   ')
            BES_Ch_button1[19] = widget_button(base2113, value = '20   ')
            BES_Ch_button1[18] = widget_button(base2113, value = '19   ')
            BES_Ch_button1[17] = widget_button(base2113, value = '18   ')
            BES_Ch_button1[16] = widget_button(base2113, value = '17   ')
          base2114 = widget_base(base211, /row, /nonexclusive)
            POL_Ch_button1[1] = widget_button(base2114, value = 'POL 2  ')
            BES_Ch_button1[15] = widget_button(base2114, value = '16   ')
            BES_Ch_button1[14] = widget_button(base2114, value = '15   ')
            BES_Ch_button1[13] = widget_button(base2114, value = '14   ')
            BES_Ch_button1[12] = widget_button(base2114, value = '13   ')
            BES_Ch_button1[11] = widget_button(base2114, value = '12   ')
            BES_Ch_button1[10] = widget_button(base2114, value = '11   ')
            BES_Ch_button1[9] = widget_button(base2114, value = '10   ')
            BES_Ch_button1[8] = widget_button(base2114, value = ' 9   ')
          base2115 = widget_base(base211, /row, /nonexclusive)
            POL_Ch_button1[0] = widget_button(base2115, value = 'POL 1  ')
            BES_Ch_button1[7] = widget_button(base2115, value = ' 8   ')
            BES_Ch_button1[6] = widget_button(base2115, value = ' 7   ')
            BES_Ch_button1[5] = widget_button(base2115, value = ' 6   ')
            BES_Ch_button1[4] = widget_button(base2115, value = ' 5   ')
            BES_Ch_button1[3] = widget_button(base2115, value = ' 4   ')
            BES_Ch_button1[2] = widget_button(base2115, value = ' 3   ')
            BES_Ch_button1[1] = widget_button(base2115, value = ' 2   ')
            BES_Ch_button1[0] = widget_button(base2115, value = ' 1   ')
        for i = 0, n_elements(data.BES_ch_sel1)-1 do $
          widget_control, BES_Ch_button1[i], set_button = data.BES_ch_sel1[i]
        for i = 0, n_elements(data.BES_RAD_ch_sel1)-1 do $
          widget_control, RAD_Ch_button1[i], set_button = data.BES_RAD_ch_sel1[i]
        for i = 0, n_elements(data.BES_POL_ch_sel1)-1 do $
          widget_control, POL_Ch_button1[i], set_button = data.BES_POL_ch_sel1[i]
      base22 = widget_base(base2, /column)
        label22 = widget_label(base22, value = 'Select multiple BES channels for velocity #2', /align_left)
        base221 = widget_base(base22, /column, frame = 1)
          BES_Ch_button2 = lonarr(32)
          POL_Ch_button2 = lonarr(4)
          RAD_Ch_button2 = lonarr(8)
          base2211 = widget_base(base221, /row)
            base22111 = widget_base(base2211, /row)
              label22111 = widget_label(base22111, value = '         ')
            base22112 = widget_base(base2211, /row, /nonexclusive)
              RAD_Ch_button2[7] = widget_button(base22112, value = 'RAD 8')
              RAD_Ch_button2[6] = widget_button(base22112, value = 'RAD 7')
              RAD_Ch_button2[5] = widget_button(base22112, value = 'RAD 6')
              RAD_Ch_button2[4] = widget_button(base22112, value = 'RAD 5')
              RAD_Ch_button2[3] = widget_button(base22112, value = 'RAD 4')
              RAD_Ch_button2[2] = widget_button(base22112, value = 'RAD 3')
              RAD_Ch_button2[1] = widget_button(base22112, value = 'RAD 2')
              RAD_Ch_button2[0] = widget_button(base22112, value = 'RAD 1')
          base2212 = widget_base(base221, /row, /nonexclusive)
            POL_Ch_button2[3] = widget_button(base2212, value = 'POL 4  ')
            BES_Ch_button2[31] = widget_button(base2212, value = '32   ')
            BES_Ch_button2[30] = widget_button(base2212, value = '31   ')
            BES_Ch_button2[29] = widget_button(base2212, value = '30   ')
            BES_Ch_button2[28] = widget_button(base2212, value = '29   ')
            BES_Ch_button2[27] = widget_button(base2212, value = '28   ')
            BES_Ch_button2[26] = widget_button(base2212, value = '27   ')
            BES_Ch_button2[25] = widget_button(base2212, value = '26   ')
            BES_Ch_button2[24] = widget_button(base2212, value = '25   ')
          base2213 = widget_base(base221, /row, /nonexclusive)
            POL_Ch_button2[2] = widget_button(base2213, value = 'POL 3  ')
            BES_Ch_button2[23] = widget_button(base2213, value = '24   ')
            BES_Ch_button2[22] = widget_button(base2213, value = '23   ')
            BES_Ch_button2[21] = widget_button(base2213, value = '22   ')
            BES_Ch_button2[20] = widget_button(base2213, value = '21   ')
            BES_Ch_button2[19] = widget_button(base2213, value = '20   ')
            BES_Ch_button2[18] = widget_button(base2213, value = '19   ')
            BES_Ch_button2[17] = widget_button(base2213, value = '18   ')
            BES_Ch_button2[16] = widget_button(base2213, value = '17   ')
          base2214 = widget_base(base221, /row, /nonexclusive)
            POL_Ch_button2[1] = widget_button(base2214, value = 'POL 2  ')
            BES_Ch_button2[15] = widget_button(base2214, value = '16   ')
            BES_Ch_button2[14] = widget_button(base2214, value = '15   ')
            BES_Ch_button2[13] = widget_button(base2214, value = '14   ')
            BES_Ch_button2[12] = widget_button(base2214, value = '13   ')
            BES_Ch_button2[11] = widget_button(base2214, value = '12   ')
            BES_Ch_button2[10] = widget_button(base2214, value = '11   ')
            BES_Ch_button2[9] = widget_button(base2214, value = '10   ')
            BES_Ch_button2[8] = widget_button(base2214, value = ' 9   ')
          base2215 = widget_base(base221, /row, /nonexclusive)
            POL_Ch_button2[0] = widget_button(base2215, value = 'POL 1  ')
            BES_Ch_button2[7] = widget_button(base2215, value = ' 8   ')
            BES_Ch_button2[6] = widget_button(base2215, value = ' 7   ')
            BES_Ch_button2[5] = widget_button(base2215, value = ' 6   ')
            BES_Ch_button2[4] = widget_button(base2215, value = ' 5   ')
            BES_Ch_button2[3] = widget_button(base2215, value = ' 4   ')
            BES_Ch_button2[2] = widget_button(base2215, value = ' 3   ')
            BES_Ch_button2[1] = widget_button(base2215, value = ' 2   ')
            BES_Ch_button2[0] = widget_button(base2215, value = ' 1   ')
        for i = 0, n_elements(data.BES_ch_sel2)-1 do $
          widget_control, BES_Ch_button2[i], set_button = data.BES_ch_sel2[i]
        for i = 0, n_elements(data.BES_RAD_ch_sel2)-1 do $
          widget_control, RAD_Ch_button2[i], set_button = data.BES_RAD_ch_sel2[i]
        for i = 0, n_elements(data.BES_POL_ch_sel2)-1 do $
          widget_control, POL_Ch_button2[i], set_button = data.BES_POL_ch_sel2[i]
    base3 = widget_base(base)
      plot_button = widget_button(base3, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 405, yoffset = 10)
      oplot_button = widget_button(base3, value = 'OPLOT', xsize = 100, ysize = 30, xoffset = 605, yoffset = 10)
    base4 = widget_base(base, /row)
      base41 = widget_base(base4, /column)
        label41 = widget_label(base41, value = '')
        label41 = widget_label(base41, value = '')
        label41 = widget_label(base41, value = 'Options to calculate time evolution of pattern velocity: v(t)', /align_left)
        base411 = widget_base(base41, /column, frame = 1)
          base4111 = widget_base(base411, /row)
            label4111 = widget_label(base4111, value = 'Frequency Filtering From  ', /align_left)
            str = string(data.freq_filter_low, format='(f0.1)')
            freq_filter_low_text = widget_text(base4111, value = str, /editable, scr_xsize = 80)
            label4111 = widget_label(base4111, value = '  To  ')
            str = string(data.freq_filter_high, format='(f0.1)')
            freq_filter_high_text = widget_text(base4111, value = str, /editable, scr_xsize = 80)
            label4111 = widget_label(base4111, value = '  kHz')
          base4112 = widget_base(base411, /row)
            label4112 = widget_label(base4112, value = 'Time delay range:   From  ', /align_left)
            str = string(data.time_delay_low, format='(f0.1)')
            time_delay_low_text = widget_text(base4112, value = str, /editable, scr_xsize = 80)
            label4112 = widget_label(base4112, value = '  To  ')
            str = string(data.time_delay_high, format='(f0.1)')
            time_delay_high_text = widget_text(base4112, value = str, /editable, scr_xsize = 80)
            label4112 = widget_label(base4112, value = '  micro-seconds')
          base4113 = widget_base(base411, /row)
            label4113 = widget_label(base4113, value = 'Number of bins of sub-time windows to be averaged: ')
            str = string(data.num_bins_to_average_vt, format='(i0)')
            num_bins_to_average_vt_text = widget_text(base4113, value = str, /editable, scr_xsize = 110)
          base4114 = widget_base(base411, /row)
            label4114 = widget_label(base4114, value = 'Fraction of sub-time window overlap:               ')
            frac_overlap_subwindow_vt_slider = widget_slider(base4114,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
            widget_control, frac_overlap_subwindow_vt_slider, set_value = fix(data.frac_overlap_subwindow_vt * 10)
            str = string(data.frac_overlap_subwindow_vt, format='(f0.1)')
            frac_overlap_subwindow_vt_label = widget_label(base4114, value = str)
          base4115 = widget_base(base411, /row)
            label4115 = widget_label(base4115, value = 'Apply Hanning Window to each sub-time window:      ')
            str = ['No', 'Yes']
            use_hanning_window_vt_combo = widget_combobox(base4115, value = str, scr_xsize = 110) 
            widget_control, use_hanning_window_vt_combo, set_combobox_select = data.use_hanning_window_vt
          base4116 = widget_base(base411, /row)
            label4116 = widget_label(base4116, value = 'Remove Large Structure by spatial averaging:       ')
            str = ['No', 'Yes']
            remove_large_structure_combo = widget_combobox(base4116, value = str, scr_xsize = 110)
            widget_control, remove_large_structure_combo, set_combobox_select = data.remove_large_structure
          base4117 = widget_base(base411, /row)
            base41171 = widget_base(base4117, /row, /nonexclusive)
              apply_median_filter_button = widget_button(base41171, value = 'Apply median filter on v(t)')
              widget_control, apply_median_filter_button, set_button = data.apply_median_filter
            base41172 = widget_base(base4117, /row)
              label41172 = widget_label(base41172, value = '  Median Filter Width: ')
              str = string(data.median_filter_width, format='(i0)')
              median_filter_width_text = widget_text(base41172, value = str, /editable, scr_xsize = 80)
              label41172 = widget_label(base41172, value = 'points')
              widget_control, median_filter_width_text, sensitive = data.apply_median_filter
          base4118 = widget_base(base411, /row)
            base41181 = widget_base(base4118, /row, /nonexclusive)
              apply_field_method_button = widget_button(base41181, value = 'Apply Field''s Method')
              widget_control, apply_field_method_button, set_button = data.apply_field_method
              widget_control, apply_field_method_button, sensitive = data.apply_median_filter
            base41182 = widget_base(base4118, /column)
              base411821 = widget_base(base41182, /row)
                label411821 = widget_label(base411821, value = '  Num. of time pts for running mean & S.D: ')
                str = string(data.num_time_pts_field_method, format='(i0)')
                num_time_pts_field_method_text = widget_text(base411821, value = str, /editable, scr_xsize = 50)
                label411821 = widget_label(base411821, value = 'points')
              base411822 = widget_base(base41182, /row)
                label411822 = widget_label(base411822, value = '  Allowed multiple of standard deviation:  ')
                str = string(data.allowed_mult_sd, format='(f0.1)')
                allowed_mult_sd_text = widget_text(base411822, value = str, /editable, scr_xsize = 50)
            if ( (data.apply_median_filter eq 1) and (data.apply_field_method) ) then begin
              widget_control, num_time_pts_field_method_text, sensitive = 1
              widget_control, allowed_mult_sd_text, sensitive = 1
            endif else begin
              widget_control, num_time_pts_field_method_text, sensitive = 0
              widget_control, allowed_mult_sd_text, sensitive = 0
            endelse
      base42 = widget_base(base4, /column)
        label42 = widget_label(base42, value = '          ')
        label42 = widget_label(base42, value = '          ')
      base43 = widget_base(base4, /column)
        label43 = widget_label(base43, value = '')
        label43 = widget_label(base43, value = '')
        label43 = widget_label(base43, value = 'Options to calculate spectrum of v(t)', /align_left)
        base431 = widget_base(base43, /column, frame = 1)
          base4311 = widget_base(base431, /row)
            label4311 = widget_label(base4311, value = 'Calculate   ')
            str = ['Spectrum', 'Spectrogram']
            calc_spectrogram_combo = widget_combobox(base4311, value = str, scr_xsize = 110, scr_ysize = 28)
            widget_control, calc_spectrogram_combo, set_combobox_select = data.calc_spectrogram
            label4311 = widget_label(base4311, value = '     ')
            str = ['Power', 'Phase']
            calc_phase_combo = widget_combobox(base4311, value = str, scr_xsize = 110, scr_ysize = 28)
            widget_control, calc_phase_combo, set_combobox_select = data.calc_phase
          base4312 = widget_base(base431, /row)
             label4312 = widget_label(base4312, value = 'Number of points per sub-time window:              ')
             npts = long(2^(findgen(15)+3))
             num_pts_per_subwindow_vf_combo = widget_combobox(base4312, value = string(npts, format='(i0)'), scr_xsize = 110, scr_ysize = 28)
             inx = where(data.num_pts_per_subwindow_vf eq npts, count)
             if count eq 0 then inx = 0
             widget_control, num_pts_per_subwindow_vf_combo, set_combobox_select = inx
          base4313 = widget_base(base431, /row)
            label4313 = widget_label(base4313, value = 'Number of bins of sub-time windows to be averaged: ')
            str = string(data.num_bins_to_average_vf, format='(i0)')
            num_bins_to_average_vf_text = widget_text(base4313, value = str, /editable, scr_xsize = 110)
            if data.calc_spectrogram eq 1 then $
              widget_control, num_bins_to_average_vf_text, sensitive = 1 $
            else $
              widget_control, num_bins_to_average_vf_text, sensitive = 0
          base4314 = widget_base(base431, /row)
            label4314 = widget_label(base4314, value = 'Fraction of sub-time window overlap:               ')
            frac_overlap_subwindow_vf_slider = widget_slider(base4314,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
            widget_control, frac_overlap_subwindow_vf_slider, set_value = fix(data.frac_overlap_subwindow_vf * 10)
            str = string(data.frac_overlap_subwindow_vf, format='(f0.1)')
            frac_overlap_subwindow_vf_label = widget_label(base4314, value = str)
          base4315 = widget_base(base431, /row)
            label4315 = widget_label(base4315, value = 'Apply Hanning Window to each sub-time window:      ')
            str = ['No', 'Yes']
            use_hanning_window_vf_combo = widget_combobox(base4315, value = str, scr_xsize = 110, scr_ysize = 28) 
            widget_control, use_hanning_window_vf_combo, set_combobox_select = data.use_hanning_window_vf
          base4316 = widget_base(base431, /row)
            label4316 = widget_label(base4316, value = 'Normalize signals by its DC value:                 ')
            str = ['No', 'Yes']
            norm_by_DC_combo = widget_combobox(base4316, value = str, scr_xsize = 110, scr_ysize = 28) 
            widget_control, norm_by_DC_combo, set_combobox_select = data.norm_by_DC
    base5 = widget_base(base)
      help_button = widget_button(base5, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base5, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 755, yoffset = 20)
      save_options_button = widget_button(base5, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 885, yoffset = 20)
      close_button = widget_button(base5, value = 'Close', xsize = 100, ysize = 30, xoffset= 1015, yoffset = 20)

; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $
            calc_in_IDL_button:calc_in_IDL_button, $
            calc_in_CUDA_button:calc_in_CUDA_button, $
            calc_pol_vel_button:calc_pol_vel_button, $
            calc_rad_vel_button:calc_rad_vel_button, $
            BES_Ch_button1:BES_Ch_button1, $
            RAD_Ch_button1:RAD_Ch_button1, $
            POL_Ch_button1:POL_Ch_button1, $
            BES_Ch_button2:BES_Ch_button2, $
            RAD_Ch_button2:RAD_Ch_button2, $
            POL_Ch_button2:POL_Ch_button2, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            time_delay_low_text:time_delay_low_text, $
            time_delay_high_text:time_delay_high_text, $
            num_bins_to_average_vt_text:num_bins_to_average_vt_text, $
            frac_overlap_subwindow_vt_slider:frac_overlap_subwindow_vt_slider, $
            frac_overlap_subwindow_vt_label:frac_overlap_subwindow_vt_label, $
            use_hanning_window_vt_combo:use_hanning_window_vt_combo, $
            remove_large_structure_combo:remove_large_structure_combo, $
            apply_median_filter_button:apply_median_filter_button, $
            median_filter_width_text:median_filter_width_text, $
            apply_field_method_button:apply_field_method_button, $
            num_time_pts_field_method_text:num_time_pts_field_method_text, $
            allowed_mult_sd_text:allowed_mult_sd_text, $
            calc_spectrogram_combo:calc_spectrogram_combo, $
            calc_phase_combo:calc_phase_combo, $
            num_pts_per_subwindow_vf_combo:num_pts_per_subwindow_vf_combo, $
            num_bins_to_average_vf_text:num_bins_to_average_vf_text, $
            frac_overlap_subwindow_vf_slider:frac_overlap_subwindow_vf_slider, $
            frac_overlap_subwindow_vf_label:frac_overlap_subwindow_vf_label, $
            use_hanning_window_vf_combo:use_hanning_window_vf_combo, $
            norm_by_DC_combo:norm_by_DC_combo, $
            plot_button:plot_button, $
            oplot_button:oplot_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}


  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_vel_spec_window', base, /no_block

end



;===================================================================================
; This procedure kills a window for velocity spectrum window
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for bes_vel_spec_window
;===================================================================================
pro kill_vel_spec_window, base_id

; kill bes_vel_spec_window
  widget_control, base_id, /destroy

end


;===================================================================================
; This procedure creates a window to show flux surface, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_show_flux_surface_window, id_main_base

; get the vel_time_evol_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.show_flux_surface_window_data

; creating widgets
  window_title = 'Options to show flux surface'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 350, ysize = 160, $
                     group_leader = id_main_base)
    base0 = widget_base(base, /row)
      label0 = widget_label(base0, value = 'At time:                        ')
      str = string(data.time, format='(f0.3)')
      time_text = widget_text(base0, value = str, /editable, scr_xsize = 100)
      label0 = widget_label(base0, value = 'sec')
    base1 = widget_base(base, /row)
      label1 = widget_label(base1, value = 'Step size for contour lines     ')
      contour_line_step_slider = widget_slider(base1, /suppress_value, xsize = 100, maximum = 20, minimum = 1)
      widget_control, contour_line_step_slider, set_value = fix(data.contour_line_step * 100)
      str = string(data.contour_line_step, format='(f0.2)')
      contour_line_step_label = widget_label(base1, value = str)
    base2 = widget_base(base, /row, /nonexclusive)
      show_label_button = widget_button(base2, value = 'Show Label')
      widget_control, show_label_button, set_button = data.show_label
    base3 = widget_base(base)
      plot_button = widget_button(base3, value = 'Plot', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      close_button = widget_button(base3, value = 'Close', xsize = 100, ysize = 30, xoffset = 250, yoffset = 20)



; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $ 
            time_text:time_text, $
            contour_line_step_slider:contour_line_step_slider, $
            contour_line_step_label:contour_line_step_label, $
            show_label_button:show_label_button, $
            plot_button:plot_button, $
            close_button:close_button}

  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'show_flux_surface_window', base, /no_block

end


;===================================================================================
; This procedure kills a window for flux surface wnidow
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for show_flux_surface_window
;===================================================================================
pro kill_show_flux_surface_window, base_id

; kill show_flux_surface_window
  widget_control, base_id, /destroy

end



;===================================================================================
; This procedure creates a window to show dens_spatio_spatio_corr_window, then start xmanager.
;===================================================================================
; The function parameters:
;   1) 'id_main_base' is the ID of the main bes_analyser window.
;===================================================================================
pro create_dens_spatio_spatio_corr_window, id_main_base

; get the dens_spa_spa_window_data
  widget_control, id_main_base, get_uvalue = info
  data = info.dens_spa_spa_corr_window_data

; creating widgets
  window_title = 'Options to calculate density spatio-spatio correlation'
  base = widget_base(/column, title = window_title, /tlb_kill_request_events,xsize = 485, ysize = 635, $
                     group_leader = id_main_base)
    base1 = widget_base(base, /row, frame = 1)
      base11 = widget_base(base1, /row)
        label11 = widget_label(base11, value = 'Calculate density spatio-spatio corr. using   ', /align_left)
      base12 = widget_base(base1, /row, /exclusive)
        calc_in_IDL_button = widget_button(base12, value = '  IDL     ')
        calc_in_CUDA_button = widget_button(base12, value = '  CUDA     ')
        if data.calc_in_IDL eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 1
          widget_control, calc_in_CUDA_button, set_button = 0
        endif else if data.calc_in_CUDA eq 1 then begin
          widget_control, calc_in_IDL_button, set_button = 0
          widget_control, calc_in_CUDA_button, set_button = 1
        endif
    base2 = widget_base(base, /row, frame = 1)
      base21 = widget_base(base2, /row)
        label21 = widget_label(base21, value = 'Calculate AVERAGE density spatio-spatio corr. ', /align_left)
      base22 = widget_base(base2, /row, /exclusive)
        calc_spa_avg_NO_button = widget_button(base22, value = '   NO     ')
        calc_spa_avg_YES_button = widget_button(base22, value = '   YES     ')
        if data.calc_spa_avg_NO eq 1 then begin
          widget_control, calc_spa_avg_NO_button, set_button = 1
          widget_control, calc_spa_avg_YES_button, set_button = 0
        endif else if data.calc_spa_avg_YES eq 1 then begin
          widget_control, calc_spa_avg_NO_button, set_button = 0
          widget_control, calc_spa_avg_YES_button, set_button = 1
        endif
    base3 = widget_base(base, /column)
      label3 = widget_label(base3, value = 'Select one reference BES Channel', /align_left)
      base31 = widget_base(base3, /column, frame = 1)
        BES_ch_sel_button = lonarr(32)
        base311 = lonarr(4)
        for i = 0, 3 do begin
          base311[i] = widget_base(base31, /row, /nonexclusive)
          for j = 0, 7 do begin
            ch_num = 32 - j - i*8
            str = string(ch_num, format='(i2)') + '   '
            BES_ch_sel_button[ch_num - 1] = widget_button(base311[i], value = str)
          endfor
        endfor
        for i = 0, n_elements(data.BES_ch_sel)-1 do begin
          widget_control, BES_ch_sel_button[i], set_button = data.BES_ch_sel[i]
          widget_control, BES_ch_sel_button[i], sensitive = data.calc_spa_avg_NO
        endfor
    base4 = widget_base(base)
      plot_button = widget_button(base4, value = 'PLOT', xsize = 100, ysize = 30, xoffset = 193, yoffset = 10)
    label = widget_label(base, value = '')
    label = widget_label(base, value = '')
    base5 = widget_base(base, /column, frame = 1)
      base51 = widget_base(base5, /row)
        label51 = widget_label(base51, value = 'Frequency Filtering From  ', /align_left)
        str = string(data.freq_filter_low, format='(f0.1)')
        freq_filter_low_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  To  ')
        str = string(data.freq_filter_high, format='(f0.1)')
        freq_filter_high_text = widget_text(base51, value = str, /editable, scr_xsize = 80)
        label51 = widget_label(base51, value = '  kHz')
      base52 = widget_base(base5, /row)
        label52 = widget_label(base52, value = 'Time delay range:   From  ', /align_left)
        str = string(data.time_delay_low, format='(f0.1)')
        time_delay_low_text = widget_text(base52, value = str, /editable, scr_xsize = 80)
        label52 = widget_label(base52, value = '  To  ')
        str = string(data.time_delay_high, format='(f0.1)')
        time_delay_high_text = widget_text(base52, value = str, /editable, scr_xsize = 80)
        label52 = widget_label(base52, value = '  micro-seconds')
      base53 = widget_base(base5, /row)
        label53 = widget_label(base53, value = 'Calculate                ', /align_left)
        base531 = widget_base(base53, /row, /exclusive)
          calc_covariance_button = widget_button(base531, value = 'Covariance      ')
          calc_correlation_button = widget_button(base531, value = 'Correlation   ')
          if data.calc_covariance eq 1 then begin
            widget_control, calc_covariance_button, set_button = 1
            widget_control, calc_correlation_button, set_button = 0
          endif else if data.calc_correlation eq 1 then begin
            widget_control, calc_covariance_button, set_button = 0
            widget_control, calc_correlation_button, set_button = 1
          endif
      base54 = widget_base(base5, /row)
        label54 = widget_label(base54, value = 'Fraction of sub-time window overlap:               ')
        frac_overlap_subwindow_slider = widget_slider(base54,  /suppress_value, /drag, xsize = 110, maximum = 9, minimum = 0)
        widget_control, frac_overlap_subwindow_slider, set_value = fix(data.frac_overlap_subwindow * 10)
        str = string(data.frac_overlap_subwindow, format='(f0.1)')
        frac_overlap_subwindow_label = widget_label(base54, value = str)
      base55 = widget_base(base5, /row)
        label55 = widget_label(base55, value = 'Apply Hanning Window to each sub-time window:      ')
        str = ['No', 'Yes']
        use_hanning_window_combo = widget_combobox(base55, value = str, scr_xsize = 110) 
        widget_control, use_hanning_window_combo, set_combobox_select = data.use_hanning_window
      base56 = widget_base(base5, /row)
        label56 = widget_label(base56, value = 'Remove Large Structure by spatial averaging:       ')
        str = ['No', 'Yes']
        remove_large_structure_combo = widget_combobox(base56, value = str, scr_xsize = 110)
        widget_control, remove_large_structure_combo, set_combobox_select = data.remove_large_structure
      base57 = widget_base(base5)
        compare_coarr_button = widget_button(base57, value = 'Compare Co-arrays', xsize = 150, ysize = 30, xoffset = 315, yoffset = 10)
        widget_control, compare_coarr_button, sensitive = data.calc_spa_avg_YES
    base6 = widget_base(base)
      help_button = widget_button(base6, value = 'Help', xsize = 100, ysize = 30, xoffset = 50, yoffset = 20)
      load_options_button = widget_button(base6, value = 'Load Options', xsize = 100, ysize = 30, xoffset = 160, yoffset = 20)
      save_options_button = widget_button(base6, value = 'Save Options', xsize = 100, ysize = 30, xoffset = 270, yoffset = 20)
      close_button = widget_button(base6, value = 'Close', xsize = 100, ysize = 30, xoffset= 385, yoffset = 20)


; saving the idinfo
  idinfo = {id_main_base:id_main_base, $
            base:base, $ 
            calc_in_IDL_button:calc_in_IDL_button, $
            calc_in_CUDA_button:calc_in_CUDA_button, $
            calc_spa_avg_NO_button:calc_spa_avg_NO_button, $
            calc_spa_avg_YES_button:calc_spa_avg_YES_button, $
            BES_ch_sel_button:BES_ch_sel_button, $
            freq_filter_low_text:freq_filter_low_text, $
            freq_filter_high_text:freq_filter_high_text, $
            time_delay_low_text:time_delay_low_text, $
            time_delay_high_text:time_delay_high_text, $
            calc_covariance_button:calc_covariance_button, $
            calc_correlation_button:calc_correlation_button, $
            frac_overlap_subwindow_slider:frac_overlap_subwindow_slider, $
            frac_overlap_subwindow_label:frac_overlap_subwindow_label, $
            use_hanning_window_combo:use_hanning_window_combo, $
            remove_large_structure_combo:remove_large_structure_combo, $
            compare_coarr_button:compare_coarr_button, $
            plot_button:plot_button, $
            help_button:help_button, $
            load_options_button:load_options_button, $
            save_options_button:save_options_button, $
            close_button:close_button}


  widget_control, base, set_uvalue = idinfo

; realize the window and start xmanager
  widget_control, base, /realize
  xmanager, 'bes_dens_spa_spa_corr_window', base, /no_block

end



;===================================================================================
; This procedure kills a window for dens_spatio_spatio_corr_window
;===================================================================================
; The function parameters:
;   1) 'base_id' is the base id for dens_spatio_spatio_corr_window
;===================================================================================
pro kill_dens_spatio_spatio_corr_window, base_id

; kill dens_spatio_spatio_corr_window
  widget_control, base_id, /destroy

end



