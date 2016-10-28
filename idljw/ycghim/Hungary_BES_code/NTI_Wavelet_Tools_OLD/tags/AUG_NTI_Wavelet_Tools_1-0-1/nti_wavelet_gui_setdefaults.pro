;==========================================================================================

;NTI_WAVELET_GUI_SETDEFAULTS.PRO

;==========================================================================================
;-- This program set defaults og NTI WAVELET TOOLS GUI
;==========================================================================================

pro nti_wavelet_gui_setdefaults
@nti_wavelet_gui_common.pro

widget_control, nti_wavelet_gui_widg, sensitive = 0

;Processing:
;===========

  ;TRANSFORM CWT SELECTION:
    widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 1
    ;TRANSFORM CWT ORDER:
      widget_control, nti_wavelet_gui_process_transf_cwt_order_widg, set_value = 6
    ;TRANSFORM CWT DSCALE:
      widget_control, nti_wavelet_gui_process_transf_cwt_dscale_widg, set_value = 0.1D
  ;TRANSFORM STFT SELECTION:
    widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 0
    ;TRANSFORM STFT LENGTH:
      widget_control, nti_wavelet_gui_process_transf_stft_length_widg, set_value = 50
    ;TRANSFORM STFT FRES:
      widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, set_value = 2000
    ;TRANSFORM STFT STEP:
      widget_control, nti_wavelet_gui_process_transf_stft_step_widg, set_value = 1
    ;FREQUENCY RANGE:
      widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = 0D
      widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = 0D
  ;COHERENCE AVG:
      widget_control, nti_wavelet_gui_process_coh_avg_widg, set_value = 5
  ;MODENUMBER STEPS:
      widget_control, nti_wavelet_gui_process_mode_filterparam_steps_widg, set_value = 1
  ;MODENUMBER RANGE:
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_min_widg, set_value = -6
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_max_widg, set_value = 6


;Visualization:
;==============
 ;TRANSFORMS:
    widget_control, nti_wavelet_gui_visual_transf_param_smooth_param_widg, set_value = [1,0]
    widget_control, nti_wavelet_gui_visual_transf_param_cscale_widg, set_value = 0.2D
  ;CROSS-TRANSFORMS:
    widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_param_widg, set_value = [1,0]
    widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_cscale_widg,set_value = 0.2D
  ;COHERENCES:
    widget_control, nti_wavelet_gui_visual_coh_param_widg, set_value = [0,0,1]
  ;MODENUMBERS:
    widget_control, nti_wavelet_gui_visual_mode_param_coh_widg, set_value = 0
    widget_control, nti_wavelet_gui_visual_mode_param_pow_widg, set_value = 0
    widget_control, nti_wavelet_gui_visual_mode_param_q_widg, set_value = 100
  ;SAVEPATH:
    cd, current = current_path
    datablock.plot_savepath = current_path + "/save_data"
    widget_control, nti_wavelet_gui_visual_buttons_save_path_widg, set_value = datablock.plot_savepath


widget_control, nti_wavelet_gui_widg, sensitive = 1

end