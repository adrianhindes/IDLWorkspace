;==========================================================================================

;NTI_WAVELET_GUI_EVENT.PRO

;==========================================================================================
;-- This is the event handler of NTI_WAVELET_GUI
;==========================================================================================

pro nti_wavelet_gui_event,event
@nti_wavelet_gui_common.pro

;HELP
;========
;========

  ;INPUT DATA block:
      if (event.ID eq nti_wavelet_gui_setup_dataman_help_widg) then begin
	res = dialog_message($
	  ['Data can be loaded form and save to IDL binary files with specific variable names.',$
	  'An example is the test.sav in the program directory.',$
	  'Data manipulations should be traced by adding a string to the data_history variable.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

      if (event.ID eq nti_wavelet_gui_setup_pairselect_help_widg) then begin
	res = dialog_message($
	  ['Prior to further analysis, signal pairs to be taken into account in mode number determination have to be selected.',$
	  'Transforms will only be calculated for signals being in a selected pair.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

  ;PROCESSING BLOCK:
    ;CWT:
      if (event.ID eq nti_wavelet_gui_process_transf_cwt_help_widg) then begin
	res = dialog_message('CWT', dialog_parent=event.top, Title="HELP")
      endif

    ;STFT:
      if (event.ID eq nti_wavelet_gui_process_transf_stft_help_widg) then begin
	res = dialog_message('STFT', dialog_parent=event.top, Title="HELP")
      endif

    ;FREQUENCY RANGE:
      if (event.ID eq nti_wavelet_gui_process_freqrange_help_widg) then begin
	res = dialog_message('FREQUENCY RANGE', dialog_parent=event.top, Title="HELP")
      endif

    ;COHERENCES:
      if (event.ID eq nti_wavelet_gui_process_coh_help_widg) then begin
	res = dialog_message('COHERENCES', dialog_parent=event.top, Title="HELP")
      endif

    ;MODENUMBERS:
      if (event.ID eq nti_wavelet_gui_process_mode_help_widg) then begin
	res = dialog_message('MODENUMBERS 1', dialog_parent=event.top, Title="HELP")
      endif

      if (event.ID eq nti_wavelet_gui_process_mode_filterparam_help_widg) then begin
	res = dialog_message('MODENUMBERS 2', dialog_parent=event.top, Title="HELP")
      endif


  ;VISUALIZATION BLOCK:
    ;TRANSFORMS:
      if (event.ID eq nti_wavelet_gui_visual_transf_param_help_widg) then begin
	res = dialog_message('TRANSFORMS', dialog_parent=event.top, Title="HELP")
      endif

    ;CROSS-TRANSFORMS:
      if (event.ID eq nti_wavelet_gui_visual_crosstr_param_help_widg) then begin
	res = dialog_message('CROSS-TRANSFORMS', dialog_parent=event.top, Title="HELP")
      endif

    ;COHERENCES:
      if (event.ID eq nti_wavelet_gui_visual_coh_param_help_widg) then begin
	res = dialog_message('COHERENCES', dialog_parent=event.top, Title="HELP")
      endif

    ;MODENUMBERS:
      if (event.ID eq nti_wavelet_gui_visual_mode_param_help_widg) then begin
	res = dialog_message('MODENUMBERS', dialog_parent=event.top, Title="HELP")
      endif



;MENU BAR
;========
;========

  if (event.ID eq nti_wavelet_gui_menu_widg) then begin
    case Event.Value of
      'File.Open configuration': begin

	guiblock.loadfile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter="*.cfg", /must_exist)
	if not keyword_set(guiblock.loadfile_path) then begin
	  nti_wavelet_gui_addmessage, addtext='No loadpath selected, cannot load configuration!'
	endif else begin	;keywordset(guiblock.loadfile_path)
	restore, guiblock.loadfile_path
	guiblock.loadfile_path = 0

	;WRITE TO datablock:
	  struct_assign, cfgblock, datablock, /nozero

	;SET CONFIGURATION on WIDGETS:
	  nti_wavelet_gui_writeconfig, /processing, /visualization
	;HANDLE SENSITIVITY:
	  nti_wavelet_gui_sens
	end

      end
      'File.Save configuration': begin

      ;READ CONFIGURATION:
	nti_wavelet_gui_readconfig, /processing, /visualization

	;WRITE TO cfgblock:
	  struct_assign, datablock, cfgblock, /nozero
	;SAVE cfgblock:
	  save, cfgblock, filename = 'nti_wavelet_tools.cfg'

      end
      'File.Save configuration as ..': begin

	  guiblock.savefile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter="*.cfg", /overwrite_prompt,$
	    /write, file='nti_wavelet_tools_personal.cfg')

	  if not keyword_set(guiblock.savefile_path) then begin
	    nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save configuration!'
	  endif else begin
	  ;READ CONFIGURATION:
	    nti_wavelet_gui_readconfig, /processing, /visualization
	  ;WRITE TO cfgblock:
	    struct_assign, datablock, cfgblock, /verbose, /nozero
	  ;SAVE cfgblock:
	    save, cfgblock, filename = guiblock.savefile_path
	  end

	guiblock.savefile_path = 0
      end
      'File.Exit': begin

	print,'Thank you for using NTI Wavelet Tools!'
	; Destroy the whole widget tree
	widget_control,/destroy,nti_wavelet_gui_widg
	return

      end
      'Help.About': begin
	res = dialog_message('NTI Wavelet Tools - pokol@reak.bme.hu', dialog_parent=event.top)
      end
      'Help.Report bug': begin
	os = !VERSION.OS_NAME
	case os of
	  'linux': begin
	    res = dialog_message('Visit http://deep.reak.bme.hu:3000/projects/wavelet/issues/new', dialog_parent=event.top)
;	    spawn, 'sensible-browser http://deep.reak.bme.hu:3000/projects/wavelet/issues/new'
	  end
	  'Microsoft Windows': begin
	    spawn, 'start http://deep.reak.bme.hu:3000/projects/wavelet/issues/new'
	  end
	  'Solaris': begin
	    spawn, 'sdtwebclient http://deep.reak.bme.hu:3000/projects/wavelet/issues/new'
	  end
	  else : begin
	    res = dialog_message('Visit http://deep.reak.bme.hu:3000/projects/wavelet/issues/new', dialog_parent=event.top)
	  endelse
	endcase
      end

    endcase
  endif


;INPUT DATA - SETUP BLOCK
;========================
;========================

  ;********************
  ;* LOAD DATA button *
  ;********************

  if (event.ID eq nti_wavelet_gui_setup_dataman_load_widg) then begin
    widget_control, nti_wavelet_gui_widg, sensitive = 0

    guiblock.loadfile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter="*.sav", /must_exist)

    if not keyword_set(guiblock.loadfile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No loadpath selected, cannot load data!'
    endif else begin	;keywordset(guiblock.loadfile_path)

        restore, guiblock.loadfile_path

       ;Add loaded data to datablock
	datablock.expname = expname
	datablock.shotnumber = shotnumber
	*datablock.channels = channels
	*datablock.data = data
	*datablock.time = timeax
	*datablock.theta = theta
	*datablock.phi = phi
	datablock.theta_type=theta_type
	datablock.data_history=data_history

	;Clear channelpairs information
	*datablock.channelpairs_ind = 0
	*datablock.channelpairs = 0

	;Calculate timerange, sample frequency and number of channels:
	datablock.timerange=[(*datablock.time)[0], (*datablock.time)[n_elements(*datablock.time)-1]]
	datablock.samplefreq=1D-3/(((*datablock.time)[n_elements(*datablock.time)-1]-(*datablock.time)[0])/double(n_elements(*datablock.time)-1))
	datablock.numofchann=n_elements(*datablock.channels)

	;Replot infos from shot:
	  ;Experiment name:
	  widget_control, nti_wavelet_gui_expname_widg, set_value="Experiment: "+datablock.expname
	;Shotnumber:
	  widget_control, nti_wavelet_gui_shotnumber_widg, set_value="Shotnumber: "+string(datablock.shotnumber)
	;Timerange:
	  widget_control, nti_wavelet_gui_timerange_widg,$
	    set_value="Timerange: "+string(datablock.timerange[0])+" s - "+string(datablock.timerange[1])+" s"
	;Sample Frequency:
	  widget_control, nti_wavelet_gui_sfreq_widg, set_value="Sample Frequency: "+string(datablock.samplefreq)+" kHz"
	;Number of Channels:
	  widget_control, nti_wavelet_gui_numchannels_widg, set_value="Number of channels: "+string(datablock.numofchann)
	;Theta coordinates:
	  widget_control, nti_wavelet_gui_theta_star_widg, set_value="Coordinates: Theta "+string(datablock.theta_type)
	;Data_histrory:
	  widget_control, nti_wavelet_gui_data_history_widg, set_value="History: "+string(datablock.data_history)

      nti_wavelet_gui_addmessage, addtext='Data loaded!'

      ;Handle sensitivity:
	widget_control, nti_wavelet_gui_setup_pairselect_button_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_freqrange_max_widg, get_value = max_freq
	  if not keyword_set(double(max_freq)) then begin
	    widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = (0.5D*datablock.samplefreq)
	  endif
	nti_wavelet_gui_sens

     endelse	;keywordset(guiblock.loadfile_path)

    widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_setup_dataman_load_widg)


  ;********************
  ;* SAVE DATA button *
  ;********************

  if (event.ID eq nti_wavelet_gui_setup_dataman_save_widg) then begin
    widget_control, nti_wavelet_gui_widg, sensitive = 0

    guiblock.savefile_path = 0
    guiblock.savefile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter="*.sav", /overwrite_prompt, /write, path="./save_data",$
      file=string(datablock.expname)+"_"+strcompress(string(datablock.shotnumber), /remove_all)+"_"+strcompress(string(datablock.data_history), /remove_all)+".sav")

    if not keyword_set(guiblock.savefile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save data!'
    endif else begin

    file_mkdir, file_dirname(guiblock.savefile_path, /mark_directory)

    ;Create variables for saving:
	expname = datablock.expname
	shotnumber = datablock.shotnumber
	channels = *datablock.channels
	theta_type = datablock.theta_type
	data = *datablock.data
	timeax = *datablock.time
	theta = *datablock.theta
	phi = *datablock.phi
	data_history = datablock.data_history

    save, expname, shotnumber, channels, theta_type, data, timeax, theta, phi, data_history, filename = guiblock.savefile_path
    nti_wavelet_gui_addmessage, addtext='Data saved!'
    guiblock.savefile_path = 0


    endelse

    widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif


  ;*******************************
  ;* SELECT CHANNEL PAIRS button *
  ;*******************************

  if (event.ID eq nti_wavelet_gui_setup_pairselect_button_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0
      nti_wavelet_gui_addmessage, addtext='Select channel pairs!'
      ;Start the channel pairs select widget:
      nti_wavelet_gui_pairselect
  endif


;PROCESSING BLOCK
;================
;================

  ;******************************
  ;* LOAD PROCESSED DATA button *
  ;******************************

  if (event.ID eq nti_wavelet_gui_process_loadbutton_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0

    guiblock.loadfile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter="*.sav", /must_exist)

    if not keyword_set(guiblock.loadfile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No loadpath selected, cannot load data!'
    endif else begin	;keyword_set(guiblock.loadfile_path)

    restore, guiblock.loadfile_path

    guiblock.loadfile_path = 0

      ;HANDLE SENSITIVITY
      ;------------------

	widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

	;TRAMSFROMS
	if keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;CROSS-TRAMSFROMS
	if keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;SMOOTHED APSDS
	if keyword_set(*datablock.smoothed_apsds) then begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 0
	endelse

	;SMOOTHED CROSS-TRANSFORMS
	if keyword_set(*datablock.smoothed_crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 0
	endelse

	;COHERENCES
	if keyword_set(*datablock.coherences) then begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;MODENUMBERS
	if keyword_set(*datablock.modenumbers) then begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;OTHER
	  widget_control, nti_wavelet_gui_setup_pairselect_button_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_setup_pairselect_selectednum_widg, set_value="Num. of Sel. Ch. Pairs: "+string(datablock.channelpairs_select_num)

	;SELECT PAIR CHANNELS BUTTON
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

	nti_wavelet_gui_sens


      ;SET KEYWORDS FROM LOADED DATA
      ;-----------------------------
	nti_wavelet_gui_writeconfig, /processing

	;Replot infos from shot:
	  ;Experiment name:
	  widget_control, nti_wavelet_gui_expname_widg, set_value="Experiment: "+datablock.expname
	;Shotnumber:
	  widget_control, nti_wavelet_gui_shotnumber_widg, set_value="Shotnumber: "+string(datablock.shotnumber)
	;Timerange:
	  widget_control, nti_wavelet_gui_timerange_widg,$
	    set_value="Timerange: "+string(datablock.timerange[0])+" s - "+string(datablock.timerange[1])+" s"
	;Sample Frequency:
	  widget_control, nti_wavelet_gui_sfreq_widg, set_value="Sample Frequency: "+string(datablock.samplefreq)+" kHz"
	;Number of Channels:
	  widget_control, nti_wavelet_gui_numchannels_widg, set_value="Number of channels: "+string(datablock.numofchann)
	;Theta coordinates:
	  widget_control, nti_wavelet_gui_theta_star_widg, set_value="Coordinates: Theta "+string(datablock.theta_type)
	;Data_histrory:
	  widget_control, nti_wavelet_gui_data_history_widg, set_value="History: "+string(datablock.data_history)


    endelse		;(keyword_set(guiblock.loadfile_path)

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_process_loadbutton_widg)



  ;******************************
  ;* PROCESS BLOCK's selections *
  ;******************************

    ;TRANSFORMS:
    if (event.ID eq nti_wavelet_gui_process_transf_select_widg) then begin
      widget_control, nti_wavelet_gui_process_transf_select_widg, get_value = transf_select_index
      if keyword_set(transf_select_index) then begin
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 0

	widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 0

	widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0

	widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0

      endelse
    endif

    ;CROSS-TRANSFORMS
    if (event.ID eq nti_wavelet_gui_process_crosstr_widg) then begin
      widget_control, nti_wavelet_gui_process_crosstr_widg, get_value = crosstr_select_index
      if keyword_set(crosstr_select_index) then begin
	widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0

	widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
      endelse
    endif

    ;COHERENCES:
    if (event.ID eq nti_wavelet_gui_process_coh_widg) then begin
      widget_control, nti_wavelet_gui_process_coh_widg, get_value = coh_select_index
      if keyword_set(coh_select_index) then begin
	widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1

	widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 1

	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0

	widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
      endelse
    endif

    ;MODENUMBERS:
    if (event.ID eq nti_wavelet_gui_process_mode_select_widg) then begin
      widget_control, nti_wavelet_gui_process_mode_select_widg, get_value = mode_select_index
      if keyword_set(mode_select_index) then begin
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 1

	widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1

	widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 1

	widget_control, nti_wavelet_gui_process_coh_widg, set_value = 1
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
      endelse
    endif


  ;*************************
  ;* TRANSFORMS CWT SELECT *
  ;*************************

    if (event.ID eq   nti_wavelet_gui_process_transf_cwt_widg) then begin
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
    endif


  ;**************************
  ;* TRANSFORMS STFT SELECT *
  ;**************************

    if (event.ID eq   nti_wavelet_gui_process_transf_stft_widg) then begin
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
    endif


  ;****************************
  ;* START CALCULATION button *
  ;****************************

  if (event.ID eq nti_wavelet_gui_process_buttons_start_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0

  ;READ CONFIGURATION:
    nti_wavelet_gui_readconfig, /processing

      ;INITIALIZE CHANNEL POSITION:
	case datablock.proc_mode_type of
	  'Toroidal': begin
	    chpos = *datablock.phi
	  end
	  'Poloidal': begin
	    chpos = *datablock.theta
	  end
	endcase


      ;INITIALIZE USED CHANNELS POSITION:
	channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind))
	channelpairs_used=reform((*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)), n_elements(channelpairs_used))
	channels_ind = intarr(n_elements(*datablock.channels))
	for i=0L,n_elements(channelpairs_used)-1 do begin
	  ind = where(*datablock.channels eq channelpairs_used[i])
	  channels_ind[ind] = 1
	endfor

;CALCULATE DATA:

      widget_control, nti_wavelet_gui_widg, sensitive = 1

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 0
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 0
      widget_control, nti_wavelet_gui_process_widg, sensitive = 0
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 0

      nti_wavelet_gui_addmessage, addtext='Calculate data, it can take so much time!'
      nti_wavelet_gui_addmessage, addtext='Working ...'

nti_wavelet_main,$
  ;INPUT:
    data=(*datablock.data)(*,where(channels_ind)), dtimeax=*datablock.time, chpos=chpos(where(channels_ind)),$
    expname=datablock.expname, shotnumber=datablock.shotnumber, timerange=datablock.timerange,$
    channels=(*datablock.channels)(where(channels_ind)),$
    channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)),$
    transf_selection=datablock.proc_transf_selection, cwt_selection=datablock.proc_transf_cwt_selection,$
    cwt_family=datablock.proc_transf_cwt_family, cwt_order=datablock.proc_transf_cwt_order,$
    cwt_dscale=datablock.proc_transf_cwt_dscale, stft_selection=datablock.proc_transf_stft_selection,$
    stft_window=datablock.proc_transf_stft_window, stft_length=datablock.proc_transf_stft_length,$
    stft_fres=datablock.proc_transf_stft_fres, stft_step=datablock.proc_transf_stft_step,$
    freq_min=datablock.proc_transf_freq_min, freq_max=datablock.proc_transf_freq_max,$
    crosstr_selection=datablock.proc_crosstr_selection, coh_selection=datablock.proc_coh_selection,$
    coh_avr=datablock.proc_coh_avg, mode_selection=datablock.proc_mode_selection, mode_type=datablock.proc_mode_type,$
    mode_filter=datablock.proc_mode_filter, mode_steps=datablock.proc_mode_steps, mode_min=datablock.proc_mode_min,$
    mode_max=datablock.proc_mode_max, startpath=datablock.startpath,$
  ;OUTPUT
    timeax=*datablock.transf_timeax, freqax=*datablock.transf_freqax, scaleax=*datablock.transf_scaleax, transforms=*datablock.transforms,$
    smoothed_apsds=*datablock.smoothed_apsds, crosstransforms=*datablock.crosstransforms,$
    smoothed_crosstransforms=*datablock.smoothed_crosstransforms, coherences=*datablock.coherences,$
    modenumbers=*datablock.modenumbers, qs=*datablock.qs

  widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = datablock.proc_transf_freq_min

      ;ACTIVATE GUI
      nti_wavelet_gui_addmessage, addtext='Ready'
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 1
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 1
      widget_control, nti_wavelet_gui_process_widg, sensitive = 1
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 1



      ;HANDLE SENSITIVITY
      ;------------------

	widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

	;TRAMSFROMS
	if keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;CROSS-TRAMSFROMS
	if keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;SMOOTHED APSDS
	if keyword_set(*datablock.smoothed_apsds) then begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 0
	endelse

	;SMOOTHED CROSS-TRANSFORMS
	if keyword_set(*datablock.smoothed_crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 0
	endelse

	;COHERENCES
	if keyword_set(*datablock.coherences) then begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;MODENUMBERS
	if keyword_set(*datablock.modenumbers) then begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	endelse

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif

  ;******************************
  ;* SAVE PROCESSED DATA button *
  ;******************************

  if (event.ID eq nti_wavelet_gui_process_buttons_save_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0

  ;READ CURRENT SETUPS
  ;-------------------
  nti_wavelet_gui_readconfig, /processing

    guiblock.savefile_path = 0
    guiblock.savefile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter="*.sav",$
      path="./save_data", /overwrite_prompt, /write,$
      file=string(datablock.expname)+"_"+strcompress(string(datablock.shotnumber), /remove_all)+"_"+strcompress(string(datablock.data_history), /remove_all)+"_processed.sav")

    if not keyword_set(guiblock.savefile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save data!'
    endif else begin	;keyword_set(guiblock.savefile_path)

    file_mkdir, file_dirname(guiblock.savefile_path, /mark_directory)

    save, datablock, filename = guiblock.savefile_path
    nti_wavelet_gui_addmessage, addtext='Data saved!'

    guiblock.savefile_path = 0
    endelse

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_process_buttons_save_widg)



;VISUALIZATION BLOCK
;===================
;===================

  ;************************************
  ;* VISUALIZATION BLOCK's selections *
  ;************************************

    ;TRANSFORMS:
    if (event.ID eq nti_wavelet_gui_visual_transf_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_transf_select_widg, get_value = transf_select_index
      if keyword_set(transf_select_index) then begin
	widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 0
      endelse
    endif

    ;CROSS-TRANSFORMS
    if (event.ID eq nti_wavelet_gui_visual_crosstr_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, get_value = crosstr_select_index
      if keyword_set(crosstr_select_index) then begin
	widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
      endelse
    endif

    ;COHERENCES:
    if (event.ID eq nti_wavelet_gui_visual_coh_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_coh_select_widg, get_value = coh_select_index
      if keyword_set(coh_select_index) then begin
	widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 1
	widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
      endelse
    endif

    ;MODENUMBERS:
    if (event.ID eq nti_wavelet_gui_visual_mode_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_mode_select_widg, get_value = mode_select_index
      if keyword_set(mode_select_index) then begin
	widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
      endelse
    endif

  ;*************************
  ;* START PLOTTING button *
  ;*************************

  if (event.ID eq nti_wavelet_gui_visual_buttons_start_widg) then begin

  ;READ VISUALIZATION BLOCK CONFIGURATION:
    nti_wavelet_gui_readconfig, /visualization

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 0
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 0
      widget_control, nti_wavelet_gui_process_widg, sensitive = 0
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 0

      nti_wavelet_gui_addmessage, addtext='Plot data, it can take so much time!'
      nti_wavelet_gui_addmessage, addtext='Working ...'

      ;INITIALIZE USED CHANNELS POSITION:
	channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind))
	channelpairs_used=reform((*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)), n_elements(channelpairs_used))
	channels_ind = intarr(n_elements(*datablock.channels))
	for i=0L,n_elements(channelpairs_used)-1 do begin
	  ind = where(*datablock.channels eq channelpairs_used[i])
	  channels_ind[ind] = 1
	endfor

;PLOTTER PROGRAM
nti_wavelet_plot, $
  ; Inputs - calculation results
    timeax=*datablock.transf_timeax, freqax=*datablock.transf_freqax, scaleax=*datablock.transf_scaleax,$
     transforms=*datablock.transforms, smoothed_apsds=*datablock.smoothed_apsds, crosstransforms=*datablock.crosstransforms,$
    smoothed_crosstransforms=*datablock.smoothed_crosstransforms, coherences=*datablock.coherences,$
    modenumbers=*datablock.modenumbers, qs=*datablock.qs,$
  ; Inputs - processing parameters
    expname=datablock.expname, shotnumber=datablock.shotnumber,$
    channels=(*datablock.channels)(where(channels_ind)),$
    channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)) ,$
    cwt_selection=datablock.proc_transf_cwt_selection, cwt_family=datablock.proc_transf_cwt_family,$
    cwt_order=datablock.proc_transf_cwt_order, cwt_dscale=datablock.proc_transf_cwt_dscale,$
    stft_selection=datablock.proc_transf_stft_selection, stft_window=datablock.proc_transf_stft_window,$
    stft_length=datablock.proc_transf_stft_length, stft_fres=datablock.proc_transf_stft_fres,$
    stft_step=datablock.proc_transf_stft_step, freq_min=datablock.proc_transf_freq_min,$
    freq_max=datablock.proc_transf_freq_max, coh_avr=datablock.proc_coh_avg,$
    mode_type=datablock.proc_mode_type, mode_filter=datablock.proc_mode_filter,$
    mode_steps=datablock.proc_mode_steps, mode_min=datablock.proc_mode_min, mode_max=datablock.proc_mode_max, $
  ; Inputs - visualization parameters
    transf_selection=datablock.plot_transf_selection, transf_smooth=datablock.plot_transf_smooth,$
    transf_energy=datablock.plot_transf_energy, transf_phase=datablock.plot_transf_phase,$
    transf_cscale=datablock.plot_transf_cscale, crosstr_selection=datablock.plot_crosstr_selection,$
    crosstr_smooth=datablock.plot_crosstr_smooth, crosstr_energy=datablock.plot_crosstr_energy,$
    crosstr_phase=datablock.plot_transf_phase, crosstr_cscale=datablock.plot_transf_cscale,$
    coh_selection=datablock.plot_coh_selection, coh_all=datablock.plot_coh_all, coh_avg=datablock.plot_coh_avg,$
    coh_min=datablock.plot_coh_min, mode_selection=datablock.plot_mode_selection,$
    mode_cohlimit=datablock.plot_mode_cohlimit, mode_powlimit=datablock.plot_mode_powlimit,$
    mode_qlimit=datablock.plot_mode_qlimit, linear_freqax=datablock.plot_linear_freqax,$
  ; Save path
    savepath=datablock.plot_savepath,$
  ; Other
    startpath=datablock.startpath, version=datablock.version

      ;ACTIVATE GUI
      nti_wavelet_gui_addmessage, addtext='Ready'
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 1
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 1
      widget_control, nti_wavelet_gui_process_widg, sensitive = 1
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

  endif


  ;************************
  ;* SET SAVE PATH button *
  ;************************

  if (event.ID eq nti_wavelet_gui_visual_buttons_save_widg) then begin
    widget_control, nti_wavelet_gui_widg, sensitive = 0

    plot_savepath = dialog_pickfile(dialog_parent=event.top, title = "Select directory!", /directory)
    if keyword_set(plot_savepath) then begin
      datablock.plot_savepath = plot_savepath
      file_mkdir, datablock.plot_savepath
      widget_control, nti_wavelet_gui_visual_buttons_save_path_widg, set_value = datablock.plot_savepath
    endif
    widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif


end