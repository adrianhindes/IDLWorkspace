;==========================================================================================

;NTI_WAVELET_GUI_WRITECONFIG.PRO

;==========================================================================================
;-- This program write the setups of widget after end program or load data
;==========================================================================================

pro nti_wavelet_gui_writeconfig, processing=processing, visualization=visualization
@nti_wavelet_gui_common.pro

if keyword_set(processing) then begin

  ;WRITE PROCESSING BLOCK CONFIGURATION:
  ;**************************************



  ;TRANSFORMS selection:
    widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = datablock.proc_transf_selection
    ;TRANSFORM CWT SELECTION:
      widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = datablock.proc_transf_cwt_selection
    ;TRANSFORM FAMILY:
      widget_control, nti_wavelet_gui_process_transf_cwt_family_widg,$
	set_droplist_select = where (datablock.proc_transf_cwt_family eq guiblock.cwt_family)
      ;TRANSFORM CWT ORDER:
	widget_control, nti_wavelet_gui_process_transf_cwt_order_widg, set_value = datablock.proc_transf_cwt_order
      ;TRANSFORM CWT DSCALE:
	widget_control, nti_wavelet_gui_process_transf_cwt_dscale_widg, set_value = datablock.proc_transf_cwt_dscale
    ;TRANSFORM STFT SELECTION:
      widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = datablock.proc_transf_stft_selection
    ;TRANSFORM STFT WINDOW
      widget_control, nti_wavelet_gui_process_transf_stft_window_widg,$
	set_droplist_select = where (datablock.proc_transf_stft_window eq guiblock.stft_window)
      ;TRANSFORM STFT LENGTH:
	widget_control, nti_wavelet_gui_process_transf_stft_length_widg, set_value = datablock.proc_transf_stft_length
      ;TRANSFORM STFT FREQUENCY:
	widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, set_value = datablock.proc_transf_stft_fres
      ;TRANSFORM STFT STEP:
	widget_control, nti_wavelet_gui_process_transf_stft_step_widg, set_value = datablock.proc_transf_stft_step
      ;FREQUENCY RANGE:
	widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = datablock.proc_transf_freq_min
	widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = datablock.proc_transf_freq_max
  ;CROSS-TRANSFORMS selection:
    widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = datablock.proc_crosstr_selection
  ;COHERENCES selection:
    widget_control, nti_wavelet_gui_process_coh_widg, set_value = datablock.proc_coh_selection
    ;COHERENCE AVG:
      widget_control, nti_wavelet_gui_process_coh_avg_widg, set_value = datablock.proc_coh_avg
  ;MODENUMBERS selection:
    widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = datablock.proc_mode_selection
    ;MODENUMBER TYPE:
      widget_control, nti_wavelet_gui_process_mode_type_widg,$
	set_droplist_select = where (datablock.proc_mode_type eq guiblock.mode_type)
    ;MODENUMBER FILTER:
      widget_control, nti_wavelet_gui_process_mode_filter_widg,$
	set_droplist_select = where (datablock.proc_mode_filter eq guiblock.filter)
    ;MODENUMBER STEPS:
      widget_control, nti_wavelet_gui_process_mode_filterparam_steps_widg, set_value = datablock.proc_mode_steps
    ;MODENUMBER RANGE:
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_min_widg, set_value = datablock.proc_mode_min
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_max_widg, set_value = datablock.proc_mode_max

endif

if keyword_set(visualization) then begin


  ;WRITE VISUALIZATION BLOCK CONFIGURATION:
  ;****************************************
    ;GENERAL SETTINGS:
      widget_control, nti_wavelet_gui_visual_genset_linfreqax_widg, set_value = datablock.plot_linear_freqax
    ;TRANSFORMS selection:
      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = datablock.plot_transf_selection
      ;SMOOTH:
	widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, set_value = datablock.plot_transf_smooth
      ;TYPE:
	widget_control, nti_wavelet_gui_visual_transf_param_smooth_param_widg,$
	  set_value = [datablock.plot_transf_energy, datablock.plot_transf_phase]
      ;COLOR SCALE OPT:
	widget_control, nti_wavelet_gui_visual_transf_param_cscale_widg, set_value = datablock.plot_transf_cscale
    ;CROSS-TRANSFORMS selection:
      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = datablock.plot_crosstr_selection
      ;SMOOTH:
	widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, set_value = datablock.plot_crosstr_smooth
      ;SMOOTH TYPE:
	widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_param_widg,$
	  set_value = [datablock.plot_crosstr_energy, datablock.plot_crosstr_phase]
      ;COLOR SCALE OPT:
	widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_cscale_widg, set_value = datablock.plot_crosstr_cscale
    ;COHERENCES selection:
      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = datablock.plot_coh_selection
      ;TYPE:
	widget_control, nti_wavelet_gui_visual_coh_param_widg,$
	  set_value = [datablock.plot_coh_all, datablock.plot_coh_avg, datablock.plot_coh_min]
    ;MODENUMBERS selection:
      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = datablock.plot_mode_selection
      ;COH LIMIT:
	widget_control, nti_wavelet_gui_visual_mode_param_coh_widg, set_value = datablock.plot_mode_cohlimit
      ;POWER LIMIT:
	widget_control, nti_wavelet_gui_visual_mode_param_pow_widg, set_value = datablock.plot_mode_powlimit
      ;Q LIMIT:
	widget_control, nti_wavelet_gui_visual_mode_param_q_widg, set_value = datablock.plot_mode_qlimit
    ;SAVEPATH:
      widget_control, nti_wavelet_gui_visual_buttons_save_path_widg, set_value = datablock.plot_savepath



  ;SENSITIVITY:
  ;************

    ;TRANSFORMS:
      if keyword_set(datablock.plot_transf_selection) then begin
	widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 0
      endelse

    ;CROSS-TRANSFORMS
      if keyword_set(datablock.plot_crosstr_selection) then begin
	widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
      endelse

    ;COHERENCES:
      if keyword_set(datablock.plot_coh_selection) then begin
	widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 1
	widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
      endelse

    ;MODENUMBERS:
      if keyword_set(datablock.plot_mode_selection) then begin
	widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
      endelse

endif

end