;==========================================================================================

;NTI_WAVELET_GUI_ADDMESSAGE.PRO

;==========================================================================================
;-- This extends the existing statustext and prints to the measurement window
;==========================================================================================

pro nti_wavelet_gui_addmessage, addtext=addtext
@nti_wavelet_gui_common.pro

  ;read data from statusblock -> add new message -> write back to statusblock
  widget_control,nti_wavelet_gui_statustext_widg,get_value=statustext
  statustext=[addtext,statustext]
  widget_control,nti_wavelet_gui_statustext_widg,set_value=statustext
  return

end