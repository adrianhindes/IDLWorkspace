;+
; NAME:
;	NTI_WAVELET_GUI_SENS
;
; PURPOSE:
;	This procedure handles the sensitivity of NTI Wavelet Tools
;	Graphical User Interface's main widget.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_SENS, (/processing, /visualization)
;
;		This procedure works only if at least one keyword is set.
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; INPUTS:
;	/processing:	Sets sensitivity on Processing block.
;	/visualization:	Sets sensitivity on Visualization block.
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
; EXAMPLE:
;	NTI_WAVELET_GUI_SENS, /processing, /visualization
;
;-


pro nti_wavelet_gui_sens, processing=processing, visualization=visualization
@nti_wavelet_gui_common.pro


  ;HANDLE SENSITIVITY OF PROCESSING BLOCK
  ;**************************************

if defined(processing, /nullarray) then begin

    ;TRANSFORMS:
      widget_control, nti_wavelet_gui_process_transf_select_widg, get_value = transf_select_index
      if keyword_set(transf_select_index) then begin
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 0
      endelse

      ;TRANSFORMS CWT SELECT
	widget_control, nti_wavelet_gui_process_transf_cwt_widg, get_value = cwt_select
	  if cwt_select then begin
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 1
	    widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 0
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 0
	  endif else begin
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 1
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 1
	  endelse

      ;TRANSFORMS STFT SELECT
	widget_control, nti_wavelet_gui_process_transf_stft_widg, get_value = stft_select
	  if stft_select then begin
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 1
	    widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 0
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 0
	  endif else begin
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 1
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 1
	  endelse

    ;COHERENCES:
      widget_control, nti_wavelet_gui_process_coh_widg, get_value = coh_select_index
      if keyword_set(coh_select_index) then begin
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0
      endelse

    ;MODENUMBERS:
      widget_control, nti_wavelet_gui_process_mode_select_widg, get_value = mode_select_index
      if keyword_set(mode_select_index) then begin
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
      endelse

      ;Channel position criterion:
	if (guiblock.theta_equal and guiblock.phi_equal) then begin
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	endif else begin
	  if guiblock.theta_equal then begin
	    widget_control, nti_wavelet_gui_process_mode_type_widg, set_value = ['Toroidal']
	  endif
	  if guiblock.phi_equal then begin
	    widget_control, nti_wavelet_gui_process_mode_type_widg, set_value = ['Poloidal']
	  endif
	endelse

endif


  ;HANDLE SENSITIVITY OF VISUALIZATION BLOCK
  ;*****************************************

if defined(visualization, /nullarray) then begin

    ;TRANSFORMS:
      widget_control, nti_wavelet_gui_visual_transf_select_widg, get_value = plot_transf_selection
	if keyword_set(plot_transf_selection) then begin
	  widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 0
	endelse

    ;CROSS-TRANSFORMS
      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, get_value = plot_crosstr_selection
	if keyword_set(plot_crosstr_selection) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
	endelse

    ;COHERENCES:
      widget_control, nti_wavelet_gui_visual_coh_select_widg, get_value = plot_coh_selection
	if keyword_set(plot_coh_selection) then begin
	  widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	endelse

    ;MODENUMBERS:
      widget_control, nti_wavelet_gui_visual_mode_select_widg, get_value = plot_mode_selection
	if keyword_set(plot_mode_selection) then begin
	  widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endelse

endif

end