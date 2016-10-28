;==========================================================================================

;NTI_WAVELET_GUI_PAIRSELECT_EVENT.PRO

;==========================================================================================
;-- This is the event handler of NTI_WAVELET_GUI_PAIRSELECT_WIDG
;==========================================================================================

pro nti_wavelet_gui_pairselect_event, event
@nti_wavelet_gui_common.pro

;RESET button
  if (event.ID eq nti_wavelet_gui_pairselect_reset_widg) then begin
    (*datablock.channelpairs_ind)[*] = 0
    widget_control, nti_wavelet_gui_pairselect_widg, set_value=*datablock.channelpairs_ind
  endif

;ALL button
  if (event.ID eq nti_wavelet_gui_pairselect_all_widg) then begin
    (*datablock.channelpairs_ind)[*] = 1
    widget_control, nti_wavelet_gui_pairselect_widg, set_value=*datablock.channelpairs_ind
  endif

;OK button
  if (event.ID eq nti_wavelet_gui_pairselect_ok_widg) then begin
    widget_control, nti_wavelet_gui_pairselect_widg, get_value=*datablock.channelpairs_ind
    ;Calculate number of selected channel pairs, and write to input data widget
      wh = where(*datablock.channelpairs_ind, count)
      datablock.channelpairs_select_num = count
      widget_control, nti_wavelet_gui_setup_pairselect_selectednum_widg, set_value="Num. of Sel. Ch. Pairs: "+string(datablock.channelpairs_select_num)
    widget_control,/destroy,nti_wavelet_gui_pairselect_base_widg
    if (datablock.channelpairs_select_num eq 0) then begin
      nti_wavelet_gui_addmessage, addtext='No Channel pairs selected!'
    endif else begin
    nti_wavelet_gui_addmessage, addtext='Channels pair selected!'
    endelse

      ;Handle sensitivity
	if keyword_set (datablock.channelpairs_select_num) then begin
	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 0
	endelse

      widget_control, nti_wavelet_gui_widg, sensitive = 1

  endif

;CANCEL button
  if (event.ID eq nti_wavelet_gui_pairselect_cancel_widg) then begin
    widget_control,/destroy,nti_wavelet_gui_pairselect_base_widg
    nti_wavelet_gui_addmessage, addtext='No changes in channels pair selection!'

      widget_control, nti_wavelet_gui_widg, sensitive = 1

      ;Handle sensitivity
	if keyword_set (datablock.channelpairs_select_num) then begin
	  widget_control, nti_wavelet_gui_process_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_process_widg, sensitive = 0
	endelse

  endif

end