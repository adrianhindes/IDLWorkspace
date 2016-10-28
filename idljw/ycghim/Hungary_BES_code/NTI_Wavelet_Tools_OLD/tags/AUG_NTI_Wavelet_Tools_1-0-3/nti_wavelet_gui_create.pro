;==========================================================================================

;NTI_WAVELET_GUI_CREATE.PRO

;==========================================================================================
;-- This is the widget creator of NTI_WAVELET_GUI
;==========================================================================================


pro nti_wavelet_gui_create
@nti_wavelet_gui_common.pro

;Define the widget tree
nti_wavelet_gui_widg=widget_base(title='NTI Wavelet Tools',$
          xoff=0,yoff=0,event_pro='nti_wavelet_gui_event',row=2, mbar=mbar)

;Create Menu:
;===========
  ;Create menu structure:
  menudesc = [ $
  '1\File', $
      '0\Open configuration', $
      '0\Save configuration', $
      '0\Save configuration as ..', $
      '2\Exit', $
  '1\Help', $
      '0\Report bug', $
      '2\About' $
  ]
  ;Create widget of menubar:
  nti_wavelet_gui_menu_widg = cw_pdmenu(mbar, menudesc, /mbar,  /return_full_name)

;Create block of setups:
;=================
nti_wavelet_gui_setup_widg = widget_base(nti_wavelet_gui_widg,row=3,/frame)
  ;Create label:
  nti_wavelet_gui_setup_label_widg=widget_label(nti_wavelet_gui_setup_widg,value="Input Data")
  ;Create data maipulation:
  nti_wavelet_gui_setup_dataman_widg = widget_base(nti_wavelet_gui_setup_widg,row=1)
    ;Create buttons:
    nti_wavelet_gui_setup_dataman_load_widg = widget_button(nti_wavelet_gui_setup_dataman_widg, value="Load data", xsize=100)
    nti_wavelet_gui_setup_dataman_save_widg = widget_button(nti_wavelet_gui_setup_dataman_widg, value="Save data", xsize=100)
    nti_wavelet_gui_setup_dataman_help_widg = widget_button(nti_wavelet_gui_setup_dataman_widg, value="?")
  ;Create select pairs base
  nti_wavelet_gui_setup_pairselect_widg = widget_base(nti_wavelet_gui_setup_widg,row=1)
    ;Create channel pair select button
    nti_wavelet_gui_setup_pairselect_button_widg=widget_button(nti_wavelet_gui_setup_pairselect_widg,value='Select channel pairs')
    nti_wavelet_gui_setup_pairselect_selectednum_widg=  widget_label(nti_wavelet_gui_setup_pairselect_widg,$
      value="Num. of Sel. Ch. Pairs: "+string(datablock.channelpairs_select_num))
    nti_wavelet_gui_setup_pairselect_help_widg=widget_button(nti_wavelet_gui_setup_pairselect_widg,value='?')


;Create statusblock:
;==================
nti_wavelet_gui_statustext_widg=widget_text(nti_wavelet_gui_widg,$
  value=['Welcome to NTI Wavelet Tools!','Version: '+datablock.version],xsize=60,ysize=10,/scroll)

;Create startblock:
;=================
nti_wavelet_gui_startblock_widg = widget_base(nti_wavelet_gui_widg,col=1, /frame)
  ;Create block of data info:
  nti_wavelet_gui_datainfo_block_widg=widget_base(nti_wavelet_gui_startblock_widg,col=1)
    ;Create label of Experiment name:
    nti_wavelet_gui_expname_widg=widget_label(nti_wavelet_gui_datainfo_block_widg,value="Experiment: "+datablock.expname, /frame, xsize = 320)
    ;Create label of Shotnumber:
    nti_wavelet_gui_shotnumber_widg=widget_label(nti_wavelet_gui_datainfo_block_widg,value="Shotnumber: "+string(datablock.shotnumber),/frame, xsize = 320)
    ;Create label of Timerange:
    nti_wavelet_gui_timerange_widg=widget_label(nti_wavelet_gui_datainfo_block_widg,$
      value="Timerange: "+string(datablock.timerange[0])+" s - "+string(datablock.timerange[1])+" s", /frame, xsize = 320)
    ;Create label of Sample Frequency:
    nti_wavelet_gui_sfreq_widg=widget_label(nti_wavelet_gui_datainfo_block_widg,$
      value="Sample Frequency: "+string(datablock.samplefreq)+" kHz",/frame, xsize = 320)
    ;Create label of Number of Channels:
    nti_wavelet_gui_numchannels_widg=widget_label(nti_wavelet_gui_datainfo_block_widg,$
      value="Number of channels: "+string(datablock.numofchann), /frame, xsize = 320)
    ;Create label of Theta* switch:
    nti_wavelet_gui_theta_star_widg = widget_label(nti_wavelet_gui_datainfo_block_widg,$
      value="Coordinates: Theta "+string(datablock.theta_type), /frame, xsize = 320)
    ;Create label of data_histrory:
    nti_wavelet_gui_data_history_widg=widget_label(nti_wavelet_gui_datainfo_block_widg,$
      value="History: "+string(datablock.data_history), /frame, xsize = 320)


;Create block of processing:
;=================
nti_wavelet_gui_process_widg = widget_base(nti_wavelet_gui_widg,col=1,/frame)
  ;Create label of Process Widg:
  nti_wavelet_gui_process_label_widg=widget_label(nti_wavelet_gui_process_widg,value="Processing")
  ;Create load button:
  nti_wavelet_gui_process_loadbutton_widg=widget_button(nti_wavelet_gui_process_widg,value='Load Processed Data')
  ;Create base of Transforms:
  nti_wavelet_gui_process_transfmain_widg = widget_base(nti_wavelet_gui_process_widg,column=2,/frame)
    ;Create Transforms select:
    nti_wavelet_gui_process_transf_widg = widget_base(nti_wavelet_gui_process_transfmain_widg, row=1)
    nti_wavelet_gui_process_transf_inidic_widg = widget_button(nti_wavelet_gui_process_transf_widg, value=guiblock.red_indicator, sensitive=1)
    nti_wavelet_gui_process_transf_select_widg = cw_bgroup(nti_wavelet_gui_process_transf_widg, "Transforms", /nonexclusive)
    ;Create Transforms parameters block:
    nti_wavelet_gui_process_transfparam_widg = widget_base(nti_wavelet_gui_process_transfmain_widg, col=1)
      ;Create cwt parameters block:
      nti_wavelet_gui_process_transf_cwt_param_widg = widget_base(nti_wavelet_gui_process_transfparam_widg, row=1)
	  ;Create cwt parameters:
	  nti_wavelet_gui_process_transf_cwt_widg = cw_bgroup(nti_wavelet_gui_process_transf_cwt_param_widg, "CWT", /nonexclusive, row=1)
	  nti_wavelet_gui_process_transf_cwt_base_widg = widget_base(nti_wavelet_gui_process_transf_cwt_param_widg, row=1)
	    ;Create label of family:
	    nti_wavelet_gui_process_transf_cwt_family_label_widg = widget_label(nti_wavelet_gui_process_transf_cwt_base_widg, value = "Family:")
	    nti_wavelet_gui_process_transf_cwt_family_widg = widget_droplist(nti_wavelet_gui_process_transf_cwt_base_widg,$
	      value = guiblock.cwt_family)
	    nti_wavelet_gui_process_transf_cwt_order_widg = cw_field (nti_wavelet_gui_process_transf_cwt_base_widg,/string,Title="Order:",xsize=2)
	    nti_wavelet_gui_process_transf_cwt_dscale_widg = cw_field (nti_wavelet_gui_process_transf_cwt_base_widg,/string,Title="Dscale:",xsize=6)
	    nti_wavelet_gui_process_transf_cwt_help_widg=widget_button(nti_wavelet_gui_process_transf_cwt_base_widg,value='?')
      ;Create stft parameters block:
      nti_wavelet_gui_process_transf_stft_param_widg = widget_base(nti_wavelet_gui_process_transfparam_widg, row=1)
	  ;Create stft parameters:
	  nti_wavelet_gui_process_transf_stft_widg = cw_bgroup(nti_wavelet_gui_process_transf_stft_param_widg, "STFT", /nonexclusive, row=1)
	  nti_wavelet_gui_process_transf_stft_base_widg = widget_base(nti_wavelet_gui_process_transf_stft_param_widg, row=1)
	    nti_wavelet_gui_process_transf_stft_window_widg = widget_droplist(nti_wavelet_gui_process_transf_stft_base_widg,$
	      value = guiblock.stft_window)
	    nti_wavelet_gui_process_transf_stft_length_widg = cw_field (nti_wavelet_gui_process_transf_stft_base_widg,/string,Title="Length:",xsize=3)
	    nti_wavelet_gui_process_transf_stft_freq_widg = cw_field (nti_wavelet_gui_process_transf_stft_base_widg,/string,Title="F.res:",xsize=5)
	    nti_wavelet_gui_process_transf_stft_step_widg = cw_field (nti_wavelet_gui_process_transf_stft_base_widg,/string,Title="Step:",xsize=2)
	    nti_wavelet_gui_process_transf_stft_help_widg=widget_button(nti_wavelet_gui_process_transf_stft_base_widg,value='?')
      ;Create Frequency range parameters block:
      nti_wavelet_gui_process_freqrange_widg = widget_base(nti_wavelet_gui_process_transfparam_widg, row=1)
	nti_wavelet_gui_process_freqrange_label_widg = widget_label(nti_wavelet_gui_process_freqrange_widg, value="Frequency Range:")
	nti_wavelet_gui_process_freqrange_min_widg = cw_field(nti_wavelet_gui_process_freqrange_widg,/string,Title="min:",xsize=8)
	nti_wavelet_gui_process_freqrange_minlabel_widg = widget_label(nti_wavelet_gui_process_freqrange_widg, value="kHz")
	nti_wavelet_gui_process_freqrange_max_widg = cw_field(nti_wavelet_gui_process_freqrange_widg,/string,Title="max:",xsize=8)
	nti_wavelet_gui_process_freqrange_maxlabel_widg = widget_label(nti_wavelet_gui_process_freqrange_widg, value="kHz")
	nti_wavelet_gui_process_freqrange_help_widg=widget_button(nti_wavelet_gui_process_freqrange_widg,value='?')
  ;Create Cross-transforms block:
  nti_wavelet_gui_process_crosstr_base_widg = widget_base(nti_wavelet_gui_process_widg, row=1, /frame)
    nti_wavelet_gui_process_crosstr_inidic_widg = widget_button(nti_wavelet_gui_process_crosstr_base_widg, value=guiblock.red_indicator, sensitive=1)
    nti_wavelet_gui_process_crosstr_widg = cw_bgroup(nti_wavelet_gui_process_crosstr_base_widg, "Cross-transforms", /nonexclusive, row=1)

  ;Create Coherences block:
  nti_wavelet_gui_process_coh_base_widg = widget_base(nti_wavelet_gui_process_widg, row=1, /frame)
    nti_wavelet_gui_process_coh_inidic_widg = widget_button(nti_wavelet_gui_process_coh_base_widg, value=guiblock.red_indicator, sensitive=1)
    nti_wavelet_gui_process_coh_widg = cw_bgroup(nti_wavelet_gui_process_coh_base_widg, "Coherences", /nonexclusive, row=1)
    nti_wavelet_gui_process_coh_avg_widg = cw_field(nti_wavelet_gui_process_coh_base_widg, /string, Title="Average", xsize=2)
    nti_wavelet_gui_process_coh_help_widg=widget_button(nti_wavelet_gui_process_coh_base_widg,value='?')
  ;Create Modeneumber base block:
  nti_wavelet_gui_process_mode_base_widg = widget_base(nti_wavelet_gui_process_widg, row=2, /frame)
    nti_wavelet_gui_process_mode_widg = widget_base(nti_wavelet_gui_process_mode_base_widg, row=1)
      nti_wavelet_gui_process_mode_inidic_widg = widget_button(nti_wavelet_gui_process_mode_widg, value=guiblock.red_indicator, sensitive=1)
      nti_wavelet_gui_process_mode_select_widg = cw_bgroup(nti_wavelet_gui_process_mode_widg, "Modenumbers", /nonexclusive, row=1)
      nti_wavelet_gui_process_mode_type_widg = widget_droplist(nti_wavelet_gui_process_mode_widg, value=guiblock.mode_type)
      nti_wavelet_gui_process_mode_filter_label_widg = widget_label(nti_wavelet_gui_process_mode_widg, value = "Filter:")
      nti_wavelet_gui_process_mode_filter_widg = widget_droplist(nti_wavelet_gui_process_mode_widg, value=guiblock.filter)
      nti_wavelet_gui_process_mode_help_widg=widget_button(nti_wavelet_gui_process_mode_widg,value='?')
    nti_wavelet_gui_process_mode_filterparam_widg = widget_base(nti_wavelet_gui_process_mode_base_widg, row=1)
      nti_wavelet_gui_process_mode_filterparam_label_widg = widget_label (nti_wavelet_gui_process_mode_filterparam_widg, value="Filter parameters:")
      nti_wavelet_gui_process_mode_filterparam_steps_widg = cw_field(nti_wavelet_gui_process_mode_filterparam_widg, /string, Title="Modenumber Steps:", xsize=2)

      nti_wavelet_gui_process_mode_filterparam_range_label_widg = widget_label(nti_wavelet_gui_process_mode_filterparam_widg, value = "Modenumber range:")
      nti_wavelet_gui_process_mode_filterparam_range_min_widg = cw_field(nti_wavelet_gui_process_mode_filterparam_widg, /string, Title="", xsize=3)
      nti_wavelet_gui_process_mode_filterparam_range_max_widg = cw_field(nti_wavelet_gui_process_mode_filterparam_widg, /string, Title="- ", xsize=3)

      nti_wavelet_gui_process_mode_filterparam_help_widg=widget_button(nti_wavelet_gui_process_mode_filterparam_widg,value='?')
  ;Create Processing action buttons:
  nti_wavelet_gui_process_buttons_widg = widget_base(nti_wavelet_gui_process_widg, col=2)
    nti_wavelet_gui_process_buttons_start_widg = widget_button(nti_wavelet_gui_process_buttons_widg, value="Start Calculation")
    nti_wavelet_gui_process_buttons_save_widg = widget_button(nti_wavelet_gui_process_buttons_widg, value="Save Processed Data")

;Create block of Visualization:
;=================
nti_wavelet_gui_visual_widg = widget_base(nti_wavelet_gui_widg,col=1,/frame)
  ;Create label of Visualization Widg:
  nti_wavelet_gui_visual_label_widg=widget_label(nti_wavelet_gui_visual_widg, value="Visualization")

  ;Create base General Seetings Widget:
  nti_wavelet_gui_visual_genset_widg = widget_base(nti_wavelet_gui_visual_widg,col=1,/frame)
    ;Create General Settings label:
      nti_wavelet_gui_visual_genset_label_widg = widget_label(nti_wavelet_gui_visual_genset_widg, value = "General Settings")
    ;Create Force linear frequency axis selection:
      nti_wavelet_gui_visual_genset_linfreqax_widg = cw_bgroup(nti_wavelet_gui_visual_genset_widg, "Force Linear Frequency Axis", /nonexclusive)


  ;Create base of Transforms:
  nti_wavelet_gui_visual_transfmain_widg = widget_base(nti_wavelet_gui_visual_widg,column=2,/frame)
    ;Create Transforms select:
    nti_wavelet_gui_visual_transf_select_widg = cw_bgroup(nti_wavelet_gui_visual_transfmain_widg, "Transforms", /nonexclusive)
    ;Create Transforms parameters block:
    nti_wavelet_gui_visual_transf_param_widg = widget_base(nti_wavelet_gui_visual_transfmain_widg, row=1)
      nti_wavelet_gui_visual_transf_param_smooth_widg = cw_bgroup(nti_wavelet_gui_visual_transf_param_widg, "Smoothed", /nonexclusive, row=1)
      nti_wavelet_gui_visual_transf_param_smooth_param_widg = cw_bgroup(nti_wavelet_gui_visual_transf_param_widg, guiblock.ctf_smooth, /nonexclusive, col=1)
      nti_wavelet_gui_visual_transf_param_cscale_widg = cw_field(nti_wavelet_gui_visual_transf_param_widg, /string, Title="Cscale opt.:", xsize=5)
      nti_wavelet_gui_visual_transf_param_help_widg=widget_button(nti_wavelet_gui_visual_transf_param_widg,value='?')
  ;Create Cross-transforms block:
  nti_wavelet_gui_visual_crosstr_base_widg = widget_base(nti_wavelet_gui_visual_widg, row=1, /frame)
    nti_wavelet_gui_visual_crosstr_select_widg = cw_bgroup(nti_wavelet_gui_visual_crosstr_base_widg, "Cross-transforms", /nonexclusive, row=1)
    nti_wavelet_gui_visual_crosstr_param_widg = widget_base(nti_wavelet_gui_visual_crosstr_base_widg, row=1)
      nti_wavelet_gui_visual_crosstr_param_smooth_widg = cw_bgroup(nti_wavelet_gui_visual_crosstr_param_widg, "Smoothed", /nonexclusive, row=1)
      nti_wavelet_gui_visual_crosstr_param_smooth_param_widg = cw_bgroup(nti_wavelet_gui_visual_crosstr_param_widg, guiblock.ctf_smooth, /nonexclusive, col=1)
      nti_wavelet_gui_visual_crosstr_param_smooth_cscale_widg = cw_field(nti_wavelet_gui_visual_crosstr_param_widg, /string, Title="Cscale opt.:", xsize=5)
      nti_wavelet_gui_visual_crosstr_param_help_widg=widget_button(nti_wavelet_gui_visual_crosstr_param_widg,value='?')
  ;Create Coherences block:
  nti_wavelet_gui_visual_coh_base_widg = widget_base(nti_wavelet_gui_visual_widg, row=1, /frame)
    nti_wavelet_gui_visual_coh_select_widg = cw_bgroup(nti_wavelet_gui_visual_coh_base_widg, "Coherences", /nonexclusive, row=1)
    nti_wavelet_gui_visual_coh_param_widg = cw_bgroup(nti_wavelet_gui_visual_coh_base_widg, guiblock.coh_plot_type, row=1, /nonexclusive)
    nti_wavelet_gui_visual_coh_param_help_widg=widget_button(nti_wavelet_gui_visual_coh_base_widg,value='?')
  ;Create Modeneumber base block:
  nti_wavelet_gui_visual_mode_base_widg = widget_base(nti_wavelet_gui_visual_widg, row=1, /frame)
    nti_wavelet_gui_visual_mode_select_widg = cw_bgroup(nti_wavelet_gui_visual_mode_base_widg, "Modenumbers", /nonexclusive, row=1)
    nti_wavelet_gui_visual_mode_param_widg = widget_base(nti_wavelet_gui_visual_mode_base_widg, row=1)
      nti_wavelet_gui_visual_mode_param_coh_widg = cw_field(nti_wavelet_gui_visual_mode_param_widg, /string, Title="Coherence Limit:", xsize=5)
      nti_wavelet_gui_visual_mode_param_coh_label_widg = widget_label(nti_wavelet_gui_visual_mode_param_widg, value="%")
      nti_wavelet_gui_visual_mode_param_pow_widg = cw_field(nti_wavelet_gui_visual_mode_param_widg, /string, Title="Power Limit:", xsize=5)
      nti_wavelet_gui_visual_mode_param_pow_label_widg = widget_label(nti_wavelet_gui_visual_mode_param_widg, value="%")
      nti_wavelet_gui_visual_mode_param_q_widg = cw_field(nti_wavelet_gui_visual_mode_param_widg, /string, Title="Q Limit:", xsize=5)
      nti_wavelet_gui_visual_mode_param_q_label_widg = widget_label(nti_wavelet_gui_visual_mode_param_widg, value="%")
      nti_wavelet_gui_visual_mode_param_help_widg=widget_button(nti_wavelet_gui_visual_mode_param_widg,value='?')
  ;Create Visualization action buttons:
  nti_wavelet_gui_visual_buttons_widg = widget_base(nti_wavelet_gui_visual_widg, row = 2)
    nti_wavelet_gui_visual_buttons_start_widg = widget_button(nti_wavelet_gui_visual_buttons_widg, value="Start Plotting")
    nti_wavelet_gui_visual_buttons_save_widg = widget_button(nti_wavelet_gui_visual_buttons_widg, value = "Set Save Path")
    nti_wavelet_gui_visual_buttons_save_path_widg = cw_field(nti_wavelet_gui_visual_buttons_widg, /noedit, /string, Title="Save Path:", xsize=70,$
      value = datablock.plot_savepath)
  


;Create the widgets, they are still inactive
  widget_control,nti_wavelet_gui_widg,/realize
;Setting defaults:
  nti_wavelet_gui_setdefaults

;Inactive some widget:

  ;PROCESSING
  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 0
  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 0
  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 0
  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 0
  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 0

  ;PROCESSING TRANSFORMS STFT:
  widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 0

  ;VISUAL
  widget_control, nti_wavelet_gui_visual_widg, sensitive = 0

  ;PAIRSELECT BUTTON
  if not keyword_set(*datablock.data) then begin
  widget_control, nti_wavelet_gui_setup_pairselect_button_widg, sensitive = 0
  endif else begin
  widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = (0.5D*datablock.samplefreq)
  endelse

  ;LOAD CONGIURATION FILE IF EXISTS
  file = file_search('nti_wavelet_tools.cfg', count = file_num)
  if keyword_set(file_num) then begin
    	restore, 'nti_wavelet_tools.cfg'

	;WRITE TO datablock:
	  struct_assign, cfgblock, datablock, /verbose, /nozero

	;SET CONFIGURATION on WIDGETS:
	  nti_wavelet_gui_writeconfig, /processing, /visualization

	;HANDLE SENSITIVITY:
	nti_wavelet_gui_sens
  endif

end