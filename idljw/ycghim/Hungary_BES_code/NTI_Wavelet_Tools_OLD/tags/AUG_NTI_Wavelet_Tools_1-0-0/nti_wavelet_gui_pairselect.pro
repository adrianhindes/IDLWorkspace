;==========================================================================================

;NTI_WAVELET_GUI_PAIRSELECT.PRO

;==========================================================================================
;-- This handles the Channels Pair Select widget
;==========================================================================================

pro nti_wavelet_gui_pairselect
@nti_wavelet_gui_common.pro


  ;Create data for pairselect_widget:
  *datablock.channelpairs=strarr(2, 0.5*(datablock.numofchann*(datablock.numofchann-1)))
  datablock.channelpairs_num=long(n_elements((*datablock.channelpairs)[0,*]))
  k=0
  for i=0L,datablock.numofchann-1 do begin
    for j=i+1,datablock.numofchann-1 do begin
      (*datablock.channelpairs)[0,k] = (*datablock.channels)[i]
      (*datablock.channelpairs)[1,k] = (*datablock.channels)[j]
      k=k+1
    endfor
  endfor

  ;Create datablock.channelpairs_index variable:
  if not keyword_set(*datablock.channelpairs_ind) then begin
    *datablock.channelpairs_ind = intarr(datablock.channelpairs_num)
  endif


;Create base widget of pair select:
nti_wavelet_gui_pairselect_base_widg=widget_base(title='Select Channel Pairs',event_pro='nti_wavelet_gui_pairselect_event',col=2)

  ;Create base of buttons:
  nti_wavelet_gui_pairselect_buttons_widg = widget_base(nti_wavelet_gui_pairselect_base_widg,col=1)
      ;Create buttons:
      nti_wavelet_gui_pairselect_reset_widg=widget_button(nti_wavelet_gui_pairselect_buttons_widg,value='RESET',/align_center,xsize=80)
      nti_wavelet_gui_pairselect_all_widg=widget_button(nti_wavelet_gui_pairselect_buttons_widg,value='ALL',/align_center,xsize=80)
      nti_wavelet_gui_pairselect_ok_widg=widget_button(nti_wavelet_gui_pairselect_buttons_widg,value='OK',/align_center,xsize=80)
      nti_wavelet_gui_pairselect_cancel_widg=widget_button(nti_wavelet_gui_pairselect_buttons_widg,value='CANCEL',/align_center,xsize=80)
  ;Create pairselect_widget:
  channelpairs_print = strarr(n_elements((*datablock.channelpairs)[0,*])) ;to visualise channel pairs
  channelpairs_print[*] = (*datablock.channelpairs)[0,*]+" and "+(*datablock.channelpairs)[1,*]
  nti_wavelet_gui_pairselect_widg = cw_bgroup(nti_wavelet_gui_pairselect_base_widg, channelpairs_print ,col=4, /nonexclusive, set_value = *datablock.channelpairs_ind)

;Create the widgets, they are still inactive
widget_control,nti_wavelet_gui_pairselect_base_widg,/realize

end