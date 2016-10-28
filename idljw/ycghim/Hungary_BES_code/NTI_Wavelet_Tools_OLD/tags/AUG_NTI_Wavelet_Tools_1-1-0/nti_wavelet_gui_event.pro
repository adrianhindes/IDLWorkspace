;+
; NAME:
;	NTI_WAVELET_GUI_EVENT
;
; PURPOSE:
;	This procedure is the event handler of NTI Wavelet Tools Graphical User Interface
;	main widget (nti_wavelet_gui_widg).
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_EVENT
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
;-


pro nti_wavelet_gui_event,event
@nti_wavelet_gui_common.pro

;HELP
;========
;========

  ;INPUT DATA block:
      if (event.ID eq nti_wavelet_gui_setup_dataman_help_widg) then begin
	res = dialog_message($
	  ['Data can be loaded form and saved to IDL binary files with specific variable names.',$
	  'An example is the test.sav in the program directory.',$
	  'Data manipulations should be traced by adding a string to the data_history or coordinates_history variable.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

      if (event.ID eq nti_wavelet_gui_setup_pairselect_help_widg) then begin
	res = dialog_message($
	  ['Prior to further analysis, signal pairs to be taken into account in mode number determination are to be selected.',$
	  'Transforms will only be calculated for signals being in a selected pair.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

  ;PROCESSING BLOCK:
    ;CWT:
      if (event.ID eq nti_wavelet_gui_process_transf_cwt_help_widg) then begin
	res = dialog_message($
	  ['CWT selects Contimuous Wavelet Transform as the type of continuous linear time-frequency transform to be used.',$
	  '- It is important to use analytical wavelets, so Family should be selected accordingly - Morlet wavelet is a straightforward choice.',$
	  '- Order of the wavelet defines its form: e.g. number of periods within the envelope.',$
	  '- Dscale defines the fraction of the dyadic scaling for the discretizition of the scale axis.',$
	  'Largest value should be 0.25 for continuous transform. Lower values can also be used for nicer images.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

    ;STFT:
      if (event.ID eq nti_wavelet_gui_process_transf_stft_help_widg) then begin
	res = dialog_message($
	  ['STFT selects Short-Time Fourier Transform as the type of continuous linear time-frequency transform to be used.',$
    '- Window type should be selected to satisfy the time-frequency resolution requirements - Gauss window is a straightforward choice.',$
    '- Length of the window is 2*sigma_t, given in number of samples.',$
    '- F.res is the required discretization of the frequency axis. This should always be at least 4* the length of the window to give a continuous transform.',$
    '- Step determines the discretization of the time axis. It should be at most length of the window /4.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;FREQUENCY RANGE:
      if (event.ID eq nti_wavelet_gui_process_freqrange_help_widg) then begin
	res = dialog_message($
	  ['Frequency range for the calculation can be set here.',$
    '- The minimum for STFT is always 0 kHz, ignoring the value set.',$
    '- For CWT the possible minimum value is determined by the transfrorm parameters but can be forced to be higher.',$
    '- Maximum value can be the Nyquist frequency at most, but lower values can be given.',$
    'Giving a maximum value lower than the Nyquist frequency will cause a Fourier domain downsampling of the signals.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;COHERENCES:
      if (event.ID eq nti_wavelet_gui_process_coh_help_widg) then begin
	res = dialog_message($
	  ['Coherence gives a meaningful value, if the number of averages (Average) is >0.',$
    'Selecting Average>0 will initiate a smoothing of the transforms with a kernel length of 2*sigma_t*Average.',$
    'Secelting Average=0 switches the smoothing off, thus allowing mode number calculations with the best possible resolution.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;MODENUMBERS:
      if (event.ID eq nti_wavelet_gui_process_mode_help_widg) then begin
	res = dialog_message($
	  ['Mode numbers can be calculated in the poloidal or toroidal directions determinimg the coordinate set to use.',$
    '- The selected filter is run at every time-frequency point, and determines the best fitting mode number.',$
    'Filter Rel.pos. determines the slope of the best fitting straight line to the measured phases as function of relative probe position.']$
    , dialog_parent=event.top, Title="HELP")
      endif

      if (event.ID eq nti_wavelet_gui_process_mode_filterparam_help_widg) then begin
	res = dialog_message($
	  ['Filter parameters determine the set of mode numbers to consider in the search for the best fitting one.',$
    '- For global modes, mode steps should be integers. It can be e.g. 2, if even or odd mode numbers can be ruled out.',$
    '- Mode number range is to be determined based considering probe positions and prior knowledge.']$
    , dialog_parent=event.top, Title="HELP")
      endif


  ;VISUALIZATION BLOCK:
    ;TRANSFORMS:
      if (event.ID eq nti_wavelet_gui_visual_transf_param_help_widg) then begin
	res = dialog_message($
	  ['Either transforms or smoothed transforms can be plotted to PS files at the Save path.',$
    '- For transforms both energy density distribution and the phase is availeble, while for smoothed transforms only the energy density distribution can be plotted.',$
    '- Cscale opt gives the exponent for the color scale of the energy density plots. Lower value means more resuolution at lower energy.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;CROSS-TRANSFORMS:
      if (event.ID eq nti_wavelet_gui_visual_crosstr_param_help_widg) then begin
	res = dialog_message($
    ['Either cross-transforms or smoothed cross-transforms can be plotted to PS files at the Save path.',$
    '- Energy density distributions and relative phases can be plotted.',$
    '- Cscale opt gives the exponent for the color scale of the energy density plots. Lower value means more resuolution at lower energy.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;COHERENCES:
      if (event.ID eq nti_wavelet_gui_visual_coh_param_help_widg) then begin
	res = dialog_message($
    ['Time-frequency coherences can be plotted to PS files at the Save path.',$
    '- All switch causes coherences to be plotted for all pairs of signals selected.',$
    '- Average switch makes a plot of the average coherence. This is useful for detecting partially coherent features.',$
    '- Minimum switch makes a plot of the minimum wavelet coherence. This is useful for detecting globally coherent features.',$
    'Average and minimum are taken at each time-frequency point.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;MODENUMBERS:
      if (event.ID eq nti_wavelet_gui_visual_mode_param_help_widg) then begin
	res = dialog_message($
    ['Estimated mode numbers on the time-frequency plane can be plotted to PS files at the Save path.',$
    'Mode numbers are to be plotted only for the time-frequency points satisfying all filters:',$
    '- Minimum wavelet coherence must be higher than the value set.',$
    '- Average smoothed cross-energy density must be higher than the set percentage of the maximum.',$
    '- The residual for the best fit must be lower than the set percentage of the maximum.']$
    , dialog_parent=event.top, Title="HELP")
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

	;SET CONFIGURATION on WIDGETS, only where indicator is RED:
	  if not (defined(*datablock.transforms, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_transforms
	  endif
	  if not (defined(*datablock.crosstransforms, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_crosstransforms
	  endif
	  if not (defined(*datablock.coherences, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_coherences
	  endif
	  if not (defined(*datablock.modenumbers, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_modenumbers
	  endif

	  ;Set configuration on visual block:
	    nti_wavelet_gui_writeconfig, /visualization
	;HANDLE SENSITIVITY:
	  nti_wavelet_gui_sens, /processing, /visualization
	;CALCULATE USED MEMORY:
	  nti_wavelet_gui_calcmemory
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
      'File.Reset configuration': begin
	widget_control, nti_wavelet_gui_widg, sensitive = 0
      
      ;Check existence of nti_wavelet_tools.cfg
	cfg_test = file_test ('nti_wavelet_tools.cfg')
	  ;DELETE nti_wavelet_tools.cfg:
	  if cfg_test then begin
	    file_delete, 'nti_wavelet_tools.cfg'
	  endif

	;RESET CONFIGURATION on WIDGETS, only where indicator is RED:
	if not (defined(*datablock.transforms, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_transforms
	endif
	if not (defined(*datablock.crosstransforms, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_crosstransforms
	endif
	if not (defined(*datablock.coherences, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_coherences
	endif
	if not (defined(*datablock.modenumbers, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_modenumbers
	endif
      ;Set defaults of visualization:
	nti_wavelet_gui_setdefaults, /visualization
      ;HANDLE SENSITIVITY:
	nti_wavelet_gui_sens, /processing, /visualization
      ;CALCULATE USED MEMORY:
	nti_wavelet_gui_calcmemory

	widget_control, nti_wavelet_gui_widg, sensitive = 1
      end
      'File.Exit': begin

	print,'Thank you for using NTI Wavelet Tools!'
	; Destroy the whole widget tree
	widget_control,/destroy,nti_wavelet_gui_widg
	return

      end
      'Filter.Auto AR filtering': begin

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 0
      delete_proc_data = 0

      if defined(*datablock.data, /nullarray) then begin
	nti_wavelet_gui_addmessage, addtext = 'Starting AR Filtering method!'
	nti_wavelet_gui_addmessage, addtext = 'Working...'

	res1 = dialog_message(['Starting AR Filtering method!', 'Do you want to see filtered data?'], /center, /question, /cancel)
	history = '_AR-filtered'


	  if (res1 eq 'Yes') then begin
	    filtered_data = *datablock.data
	    filtered_data(*, *) = 0
	    i = 0
	    cancel = 0
	    exit = 0
	    while (exit eq 0) do begin
	      history = '_AR-filtered'
	      ardata = 0
	      ardata = (*datablock.data)(*,i)
		auto_ar_filter, data = ardata, timeax = *datablock.time, /gui, /verbose, channel_name = (*datablock.channels)(i)
	      res2 = dialog_message('Do you want to continue and see next?', /center, /information, /cancel)
		if (res2 eq 'OK')  then begin
		  filtered_data(*,i) = ardata
		endif
		if (res2 eq 'Cancel')  then begin
		  filtered_data(*, *) = 0
		  res3 = dialog_message('All filtered data was deleted, and original data was restored!', /center, /information)
		  nti_wavelet_gui_addmessage, addtext = 'Original data restored!'
		  exit = 1
		  cancel = 1
		  history = ''
		endif
	      if (i ge n_elements((*datablock.data)(0,*))-1) then exit = 1
	      i = i + 1
	    endwhile
	    wdelete
	    if not cancel then begin
	      *datablock.data = filtered_data
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	    endif
	  endif

	  if (res1 eq 'No') then begin
	    for i = 0, n_elements((*datablock.data)(0,*))-1 do begin
	      ardata = 0
	      ardata = (*datablock.data)(*,i)
		auto_ar_filter, data = ardata, timeax = *datablock.time, /gui, verbose = 0
		(*datablock.data)(*,i) = ardata
	    endfor
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	  endif

	  if (res1 eq 'Cancel') then begin
	    nti_wavelet_gui_addmessage, addtext = 'Starting AR Filtering method stoped!'
	  endif

	    ;HANDLE INDICATORS AND CALCULATED DATA:
	      if delete_proc_data then begin
		if defined(*datablock.transforms, /nullarray) then begin
		  nti_wavelet_gui_addmessage, addtext = "Processed data deleted!"
		endif
		  ;Reset calculated values:
		    *datablock.transf_timeax = 0
		    *datablock.transf_freqax = 0
		    *datablock.transf_scaleax = 0
		    *datablock.transforms = 0
		    *datablock.smoothed_apsds = 0
		    *datablock.crosstransforms = 0
		    *datablock.smoothed_crosstransforms = 0
		    *datablock.coherences = 0
		    *datablock.modenumbers = 0
		    *datablock.qs = 0
		  ;Set indicators color and delete version:
		    ;TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
		      datablock.transf_version = '-'
		    ;CROSS-TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
		      datablock.crosstr_version = '-'
		    ;COHERENCES
		      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
		      datablock.coh_version = '-'
		    ;MODENUMBERS
		      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
		      datablock.mode_version = '-'
	      endif

	;Data_histrory:
	  datablock.data_history = datablock.data_history + history
	  widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)

      endif else begin
	res = dialog_message('Data was not loaded yet!', /center)
	nti_wavelet_gui_addmessage, addtext = 'AR Filtering failed!'
      endelse

      ;ACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 1

      end
      'Filter.Auto SPRT': begin
print, (*datablock.data)(10000,*)

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 0
      delete_proc_data = 0

      if defined(*datablock.data, /nullarray) then begin
	nti_wavelet_gui_addmessage, addtext = 'Starting SPRT Filtering method!'
	nti_wavelet_gui_addmessage, addtext = 'Working...'

	res1 = dialog_message(['Starting SPRT Filtering method!', 'Do you want to see filtered data?'], /center, /question, /cancel)
	history = '_SPRT-filtered'


	  if (res1 eq 'Yes') then begin
	    filtered_data = *datablock.data
	    filtered_data(*, *) = 0
	    i = 0
	    cancel = 0
	    exit = 0
	    while (exit eq 0) do begin
	      history = '_SPRT-filtered'
	      sprtdata = 0
	      sprtdata = (*datablock.data)(*,i)
		auto_sprt, data = sprtdata, timeax = *datablock.time, /gui, /verbose, channel_name = (*datablock.channels)(i)
	      res2 = dialog_message('Do you want to continue and see next?', /center, /information, /cancel)
		if (res2 eq 'OK')  then begin
		  filtered_data(*,i) = sprtdata
		endif
		if (res2 eq 'Cancel')  then begin
		  filtered_data(*, *) = 0
		  res3 = dialog_message('All filtered data was deleted, and original data was restored!', /center, /information)
		  nti_wavelet_gui_addmessage, addtext = 'Original data restored!'
		  exit = 1
		  cancel = 1
		  history = ''
		endif
	      if (i ge n_elements((*datablock.data)(0,*))-1) then exit = 1
	      i = i + 1
	    endwhile
	    wdelete
	    if not cancel then begin
	      *datablock.data = filtered_data
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	    endif
	  endif

	  if (res1 eq 'No') then begin
	    for i = 0, n_elements((*datablock.data)(0,*))-1 do begin
	      sprtdata = 0
	      sprtdata = (*datablock.data)(*,i)
		auto_sprt, data = sprtdata, timeax = *datablock.time, /gui, verbose = 0
		(*datablock.data)(*,i) = sprtdata
	    endfor
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	  endif

	  if (res1 eq 'Cancel') then begin
	    nti_wavelet_gui_addmessage, addtext = 'Starting SPRT Filtering method stoped!'
	  endif

	    ;HANDLE INDICATORS AND CALCULATED DATA:
	      if delete_proc_data then begin
		if defined(*datablock.transforms, /nullarray) then begin
		  nti_wavelet_gui_addmessage, addtext = "Processed data deleted!"
		endif
		  ;Reset calculated values:
		    *datablock.transf_timeax = 0
		    *datablock.transf_freqax = 0
		    *datablock.transf_scaleax = 0
		    *datablock.transforms = 0
		    *datablock.smoothed_apsds = 0
		    *datablock.crosstransforms = 0
		    *datablock.smoothed_crosstransforms = 0
		    *datablock.coherences = 0
		    *datablock.modenumbers = 0
		    *datablock.qs = 0
		  ;Set indicators color and delete version:
		    ;TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
		      datablock.transf_version = '-'
		    ;CROSS-TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
		      datablock.crosstr_version = '-'
		    ;COHERENCES
		      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
		      datablock.coh_version = '-'
		    ;MODENUMBERS
		      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
		      datablock.mode_version = '-'
	      endif

	;Data_histrory:
	  datablock.data_history = datablock.data_history + history
	  widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)

      endif else begin
	res = dialog_message('Data was not loaded yet!', /center)
	nti_wavelet_gui_addmessage, addtext = 'SPRT Filtering failed!'
      endelse

      ;ACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 1

print, (*datablock.data)(10000,*)
      end
      'Help.About': begin
	res = dialog_message('NTI Wavelet Tools - pokol@reak.bme.hu', dialog_parent=event.top)
      end
      'Help.Documentation': begin
	start_web_browser, guiblock.startpath+'documentation.html'
      end
      'Help.Report bug': begin
	start_web_browser, 'http://deep.reak.bme.hu:3000/projects/wavelet/issues/new'
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

    ;Delete old variables before restore:
      channels = 0
      coord_history = 0
      data = 0
      data_history = 0
      expname = 0
      phi = 0
      shotnumber = 0
      theta = 0
      timeax = 0

        restore, guiblock.loadfile_path

    ;CHECK LOADED DATA:
      load_data_error = 0
      if not defined(CHANNELS, /nullarray) then begin	;CHANNELS
	nti_wavelet_gui_addmessage, addtext='ERROR --- CHANNELS variable is undefined!'
	load_data_error = 1
      endif
      if not defined(COORD_HISTORY, /nullarray) then begin	;COORD_HISTORY
	nti_wavelet_gui_addmessage, addtext='ERROR --- COORD_HISTORY variable is undefined!'
	load_data_error = 1
      endif
      if not defined(DATA, /nullarray) then begin	;DATA
	nti_wavelet_gui_addmessage, addtext='ERROR --- DATA variable is undefined!'
	load_data_error = 1
      endif
      if not defined(DATA_HISTORY, /nullarray) then begin	;DATA_HISTORY
	nti_wavelet_gui_addmessage, addtext='ERROR --- DATA_HISTORY variable is undefined!'
	load_data_error = 1
      endif
      if not defined(EXPNAME, /nullarray) then begin	;EXPNAME
	nti_wavelet_gui_addmessage, addtext='ERROR --- EXPNAME variable is undefined!'
	load_data_error = 1
      endif
      if not defined(PHI, /nullarray) then begin	;PHI
	nti_wavelet_gui_addmessage, addtext='ERROR --- PHI variable is undefined!'
	load_data_error = 1
      endif
      if not defined(SHOTNUMBER, /nullarray) then begin	;SHOTNUMBER
	nti_wavelet_gui_addmessage, addtext='ERROR --- SHOTNUMBER variable is undefined!'
	load_data_error = 1
      endif
      if not defined(THETA, /nullarray) then begin	;THETA
	nti_wavelet_gui_addmessage, addtext='ERROR --- CHANNELS variable is undefined!'
	load_data_error = 1
      endif
      if not defined(TIMEAX, /nullarray) then begin	;TIMEAX
	nti_wavelet_gui_addmessage, addtext='ERROR --- TIMEAX variable is undefined!'
	load_data_error = 1
      endif

      if not load_data_error then begin
	channels_d = size(CHANNELS, /dimensions)
	data_d = size(DATA, /dimensions)
	phi_d = size(PHI, /dimensions)
	theta_d = size(THETA, /dimensions)
	timeax_d = size(TIMEAX, /dimensions)

	;CHECK DIMENSIONS:
	size1 = [channels_d, data_d(1), phi_d, theta_d]
	res = where((size1(0) ne size1), size1_count)
	if (size1_count ne 0) then begin
	  nti_wavelet_gui_addmessage, addtext='ERROR --- Problem with dimensions of CHANNELS, DATA, PHI or THETA'
	  load_data_error = 1
	endif

	size2 = [data_d(0), timeax_d]
	res = where((size2(0) ne size2), size2_count)
	if (size2_count ne 0) then begin
	  nti_wavelet_gui_addmessage, addtext='ERROR --- Length of DATA and TIMEAX not equal!'
	  load_data_error = 1
	endif
      endif

      ;IF NO ERROR, CONTINUE:
      if not load_data_error then begin

	;Add loaded data to datablock
	  datablock.expname = expname
	  datablock.shotnumber = shotnumber
	  *datablock.channels = channels
	  *datablock.data = data
	  *datablock.time = timeax
	  *datablock.theta = theta
	  *datablock.phi = phi
	  datablock.data_history=data_history
	  datablock.coord_history=coord_history

	  ;Clear channelpairs information
	  *datablock.channelpairs_ind = 0
	  *datablock.channelpairs = 0
	  widget_control, nti_wavelet_gui_setup_pairselect_selectednum_widg, set_value="Num. of Sel. Ch. Pairs: "+string(0L)

	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 0

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

	  ;Data_histrory:
	    widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)
	  ;Coord_histrory:
	    widget_control, nti_wavelet_gui_setup_history_coord_widg, set_value = string(datablock.coord_history)

	nti_wavelet_gui_addmessage, addtext='Data loaded!'

	;Handle sensitivity:
	  widget_control, nti_wavelet_gui_process_pairselect_base_widg, sensitive = 1
	    widget_control, nti_wavelet_gui_process_freqrange_max_widg, get_value = max_freq
	    if not keyword_set(double(max_freq)) then begin
	      widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = (0.5D*datablock.samplefreq)
	    endif

	;Handle indicators and calculated data:
	if defined(*datablock.transforms, /nullarray) then begin
	  nti_wavelet_gui_addmessage, addtext = "Processed data deleted!"
	endif
	  ;Reset calculated values:
	    *datablock.transf_timeax = 0
	    *datablock.transf_freqax = 0
	    *datablock.transf_scaleax = 0
	    *datablock.transforms = 0
	    *datablock.smoothed_apsds = 0
	    *datablock.crosstransforms = 0
	    *datablock.smoothed_crosstransforms = 0
	    *datablock.coherences = 0
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color and delete version:
	    ;TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
	      datablock.transf_version = '-'
	  ;CROSS-TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
	      datablock.crosstr_version = '-'
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      datablock.coh_version = '-'
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      datablock.mode_version = '-'

      endif else begin	;not load_data_error
	nti_wavelet_gui_addmessage, addtext = "Data loading failed!"
      endelse	;not load_data_error
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
      file=string(datablock.expname)+"_"+strcompress(string(datablock.shotnumber), /remove_all)+"_"+$
      strcompress(string(datablock.data_history), /remove_all)+".sav")

    if not keyword_set(guiblock.savefile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save data!'
    endif else begin

    file_mkdir, file_dirname(guiblock.savefile_path, /mark_directory)

    ;Create variables for saving:
	expname = datablock.expname
	shotnumber = datablock.shotnumber
	channels = *datablock.channels
	data = *datablock.data
	timeax = *datablock.time
	theta = *datablock.theta
	phi = *datablock.phi
	data_history = datablock.data_history
	coord_history = datablock.coord_history

    save, expname, shotnumber, channels, data, timeax, theta, phi, data_history, coord_history, filename = guiblock.savefile_path
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

    datablock_names = tag_names(datablock)
    restore, guiblock.loadfile_path
      guiblock.loadfile_path = 0

    load_prdata_error = 0

    ;check existence of saved_datablock:
      if not defined(saved_datablock) then begin
	nti_wavelet_gui_addmessage, addtext='Error --- Structure of loaded data is not valid!'
	load_prdata_error = 1
      endif

    ;check names of loaded variable
      if not load_prdata_error then begin
	if not array_equal(datablock_names, tag_names(saved_datablock)) then begin
	  nti_wavelet_gui_addmessage, addtext='Error --- Structure of loaded data is not valid!'
	  load_prdata_error = 1
	endif
      endif

    ;CHECK LOADED DATA:
      if not load_prdata_error then begin
	if not defined(*SAVED_DATABLOCK.CHANNELS, /nullarray) then begin	;CHANNELS
	  nti_wavelet_gui_addmessage, addtext='ERROR --- CHANNELS variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(SAVED_DATABLOCK.COORD_HISTORY, /nullarray) then begin	;COORD_HISTORY
	  nti_wavelet_gui_addmessage, addtext='ERROR --- COORD_HISTORY variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(*SAVED_DATABLOCK.DATA, /nullarray) then begin	;DATA
	  nti_wavelet_gui_addmessage, addtext='ERROR --- DATA variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(SAVED_DATABLOCK.DATA_HISTORY, /nullarray) then begin	;DATA_HISTORY
	  nti_wavelet_gui_addmessage, addtext='ERROR --- DATA_HISTORY variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(SAVED_DATABLOCK.EXPNAME, /nullarray) then begin	;EXPNAME
	  nti_wavelet_gui_addmessage, addtext='ERROR --- EXPNAME variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(*SAVED_DATABLOCK.PHI, /nullarray) then begin	;PHI
	  nti_wavelet_gui_addmessage, addtext='ERROR --- PHI variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(SAVED_DATABLOCK.SHOTNUMBER, /nullarray) then begin	;SHOTNUMBER
	  nti_wavelet_gui_addmessage, addtext='ERROR --- SHOTNUMBER variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(*SAVED_DATABLOCK.THETA, /nullarray) then begin	;THETA
	  nti_wavelet_gui_addmessage, addtext='ERROR --- CHANNELS variable is undefined!'
	  load_prdata_error = 1
	endif
	if not defined(*SAVED_DATABLOCK.TIME, /nullarray) then begin	;TIMEAX
	  nti_wavelet_gui_addmessage, addtext='ERROR --- TIMEAX variable is undefined!'
	  load_prdata_error = 1
	endif
      endif

	;CHECK DIMENSIONS:
	if not load_prdata_error then begin
	  ;Find out dimensions:
	  channels_d = size(*SAVED_DATABLOCK.CHANNELS, /dimensions)
	  res = where(*SAVED_DATABLOCK.CHANNELS_IND, channels_select_num)
	  channelpairs_select_num = SAVED_DATABLOCK.CHANNELPAIRS_SELECT_NUM
	  data_d = size(*SAVED_DATABLOCK.DATA, /dimensions)
	  phi_d = size(*SAVED_DATABLOCK.PHI, /dimensions)
	  theta_d = size(*SAVED_DATABLOCK.THETA, /dimensions)
	  timeax_d = size(*SAVED_DATABLOCK.TIME, /dimensions)
	  transf_timeax_d = size(*SAVED_DATABLOCK.TRANSF_TIMEAX, /dimensions)
	  transf_freqax_d = size(*SAVED_DATABLOCK.TRANSF_FREQAX, /dimensions)
	  transf_scaleax_d = size(*SAVED_DATABLOCK.TRANSF_SCALEAX, /dimensions)
	  transforms_d = size(*SAVED_DATABLOCK.TRANSFORMS, /dimensions)
	  smoothed_apsds_d = size(*SAVED_DATABLOCK.SMOOTHED_APSDS, /dimensions)
	  crosstransforms_d = size(*SAVED_DATABLOCK.CROSSTRANSFORMS, /dimensions)
	  smoothed_crosstransforms_d = size(*SAVED_DATABLOCK.SMOOTHED_CROSSTRANSFORMS, /dimensions)
	  coherences_d = size(*SAVED_DATABLOCK.COHERENCES, /dimensions)
	  modenumbers_d = size(*SAVED_DATABLOCK.MODENUMBERS, /dimensions)
	  qs_d = size(*SAVED_DATABLOCK.QS, /dimensions)

	  ;Check input data:
	  size1 = [channels_d, data_d(1), phi_d, theta_d]
	  res = where((size1(0) ne size1), size1_count)
	  if (size1_count ne 0) then begin
	    nti_wavelet_gui_addmessage, addtext='ERROR --- Problem with dimensions of CHANNELS, DATA, PHI or THETA'
	    load_prdata_error = 1
	  endif

	  size2 = [data_d(0), timeax_d]
	  res = where((size2(0) ne size2), size2_count)
	  if (size2_count ne 0) then begin
	    nti_wavelet_gui_addmessage, addtext='ERROR --- Length of DATA and TIMEAX not equal!'
	    load_prdata_error = 1
	  endif
	endif

	;Check output data:
	if not load_prdata_error then begin
	  if defined(*saved_datablock.transforms, /nullarray) then begin
	    ;number of transforms:
	      if (transforms_d(0) ne channels_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of smoothed_apsds:
	  if defined(*saved_datablock.smoothed_apsds, /nullarray) then begin
	      if (smoothed_apsds_d(0) ne channels_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of smoothed apsds wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of cross-transforms:
	  if defined(*saved_datablock.crosstransforms, /nullarray) then begin
	      if (crosstransforms_d(0) ne channelpairs_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of smoothed cross-transforms:
	  if defined(*saved_datablock.smoothed_crosstransforms, /nullarray) then begin
	      if (smoothed_crosstransforms_d(0) ne channelpairs_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of smoothed cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of coherences:
	  if defined(*saved_datablock.coherences, /nullarray) then begin
	      if (coherences_d(0) ne channelpairs_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of coherences wrong!'
		load_prdata_error = 1
	      endif
	  endif

	    ;timeax of transforms:
	  if defined(*saved_datablock.transforms, /nullarray) then begin
	      if (transforms_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of smoothed_apsds_d:
	  if defined(*saved_datablock.smoothed_apsds, /nullarray) then begin
	      if (smoothed_apsds_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of smoothed apsds wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of crosstransforms_d:
	  if defined(*saved_datablock.crosstransforms, /nullarray) then begin
	      if (crosstransforms_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of smoothed_crosstransforms_d:
	  if defined(*saved_datablock.smoothed_crosstransforms, /nullarray) then begin
	      if (smoothed_crosstransforms_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of smoothed cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of coherences_d:
	  if defined(*saved_datablock.coherences, /nullarray) then begin
	      if (coherences_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of coherences wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of modenumbers_d:
	  if defined(*saved_datablock.modenumbers, /nullarray) then begin
	      if (modenumbers_d(0) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of modenumbers wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of qs_d:
	  if defined(*saved_datablock.qs, /nullarray) then begin
	      if (qs_d(0) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of qs wrong!'
		load_prdata_error = 1
	      endif
	  endif

	    ;freqax of transforms:
	  if defined(*saved_datablock.transforms, /nullarray) then begin
	      if (transforms_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of smoothed_apsds_d:
	  if defined(*saved_datablock.smoothed_apsds, /nullarray) then begin
	      if (smoothed_apsds_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of smoothed apsds wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of crosstransforms_d:
	  if defined(*saved_datablock.crosstransforms, /nullarray) then begin
	      if (crosstransforms_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of smoothed_crosstransforms_d:
	  if defined(*saved_datablock.smoothed_crosstransforms, /nullarray) then begin
	      if (smoothed_crosstransforms_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of smoothed cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of coherences_d:
	  if defined(*saved_datablock.coherences, /nullarray) then begin
	      if (coherences_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of coherences wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of modenumbers_d:
	  if defined(*saved_datablock.modenumbers, /nullarray) then begin
	      if (modenumbers_d(1) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of modenumbers wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of qs_d:
	  if defined(*saved_datablock.qs, /nullarray) then begin
	      if (qs_d(1) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of qs wrong!'
		load_prdata_error = 1
	      endif
	  endif
      endif

      ;IF NO ERROR, CONTINUE:
      if not load_prdata_error then begin
      datablock = saved_datablock

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
	  widget_control, nti_wavelet_gui_process_pairselect_base_widg, sensitive = 1
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

      ;SET KEYWORDS FROM LOADED DATA AND HANDLE SENSITIVITY
      ;-----------------------------
	nti_wavelet_gui_writeconfig, /processing

	;CHECK CHANNEL POSITIONS: (if all positions equals, modenumber calculations will be forbidden)
	  used_theta = (*datablock.theta)(where(*datablock.channels_ind))
	  res = where((used_theta eq used_theta(0)), theta_num)
	  if (theta_num eq n_elements(used_theta)) then begin
	    guiblock.theta_equal = 1
	  endif
	  used_phi = (*datablock.phi)(where(*datablock.channels_ind))
	  res = where((used_phi eq used_phi(0)), phi_num)
	  if (phi_num eq n_elements(used_phi)) then begin
	    guiblock.phi_equal = 1
	  endif
	nti_wavelet_gui_sens, /processing


      ;Replot infos from shot:
      ;-----------------------
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

	;Data_histrory:
	  widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)
	;Coord_histrory:
	  widget_control, nti_wavelet_gui_setup_history_coord_widg, set_value = string(datablock.coord_history)

	;CALCULATE USED MEMORY:
	nti_wavelet_gui_calcmemory

      endif else begin	;not load_prdata_error
	nti_wavelet_gui_addmessage, addtext = "Processed Data loading failed!"
      endelse	;not load_prdata_error
    endelse		;(keyword_set(guiblock.loadfile_path)

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_process_loadbutton_widg)


  ;***********************
  ;* VERSION INFO button *
  ;***********************

    if (event.ID eq nti_wavelet_gui_process_versioninfo_button_widg) then begin
      res = dialog_message($
	[ 'Versions of Processed Data', $
	'', $	
	'Transforms:     ' + datablock.transf_version, $
	'Cross-transforms:     ' + datablock.crosstr_version, $
	'Coherences:     ' + datablock.coh_version, $
	'Modenumbers:     ' + datablock.mode_version ] $
	, dialog_parent=event.top, /information, Title="Versions of Processed Data")
    endif


  ;******************************
  ;* PROCESS BLOCK's selections *
  ;******************************

    ;TRANSFORMS:
    if (event.ID eq nti_wavelet_gui_process_transf_select_widg) then begin
      widget_control, nti_wavelet_gui_process_transf_select_widg, get_value = transf_select_index
      if keyword_set(transf_select_index) then begin
	;Handling indicators:
	if keyword_set(*datablock.transforms) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Transforms deleted!"
	      datablock.transf_version = '-'
	    if (defined(*datablock.crosstransforms, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Cross-transforms deleted!"
	      datablock.crosstr_version = '-'
	    endif
	    if (defined(*datablock.coherences, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Coherences deleted!"
	      datablock.coh_version = '-'
	    endif
	    if (defined(*datablock.modenumbers, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
	    endif
	  ;Reset calculated values:
	    *datablock.transf_timeax = 0
	    *datablock.transf_freqax = 0
	    *datablock.transf_scaleax = 0
	    *datablock.transforms = 0
	    *datablock.smoothed_apsds = 0
	    *datablock.crosstransforms = 0
	    *datablock.smoothed_crosstransforms = 0
	    *datablock.coherences = 0
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 0
	    ;CROSS-TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endif

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
	;Handling indicators:
	if keyword_set(*datablock.crosstransforms) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Cross-transforms deleted!"
	      datablock.crosstr_version = '-'
	    if (defined(*datablock.coherences, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Coherences deleted!"
	      datablock.coh_version = '-'
	    endif
	    if (defined(*datablock.modenumbers, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
	    endif
	  ;Reset calculated values:
	    *datablock.crosstransforms = 0
	    *datablock.smoothed_crosstransforms = 0
	    *datablock.coherences = 0
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;CROSS-TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endif

	if not keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
	endif
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
	;Handling indicators:
	if keyword_set(*datablock.coherences) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Coherences deleted!"
	      datablock.coh_version = '-'
	    if (defined(*datablock.modenumbers, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
	    endif
	  ;Reset calculated values:
	    *datablock.coherences = 0
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endif

	if not keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
	endif
	if not keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 1
	endif

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
	;Handling indicators:
	if keyword_set(*datablock.modenumbers) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
	  ;Reset calculated values:
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endif

	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 1

	if not keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
	endif
	if not keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 1
	endif
	if not keyword_set(*datablock.coherences) then begin
	  widget_control, nti_wavelet_gui_process_coh_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 1
	endif
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

      ;INITIALIZE STFT FREQUENCY RESOLUTION POSITION:
	stft_fres = datablock.proc_transf_stft_fres

;CALCULATE DATA:

      widget_control, nti_wavelet_gui_widg, sensitive = 1

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 0
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 0
      widget_control, nti_wavelet_gui_process_widg, sensitive = 0
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 0

      nti_wavelet_gui_addmessage, addtext='Calculate data, it can take a lot of time!'
      nti_wavelet_gui_addmessage, addtext='Working ...'

      ;SET PROCESSED DATA VERSION
	;TRANSFROMS
	if not defined(*datablock.transforms, /nullarray) then begin
	  datablock.transf_version = guiblock.version
	endif
	;CROSS-TRANSFROMS
	if not defined(*datablock.crosstransforms, /nullarray) then begin
	  datablock.crosstr_version = guiblock.version
	endif
	;COHERENCES
	if not defined(*datablock.coherences, /nullarray) then begin
	  datablock.coh_version = guiblock.version
	endif
	;MODENUMBERS
	if not defined(*datablock.modenumbers, /nullarray) then begin
	  datablock.mode_version = guiblock.version
	endif

nti_wavelet_main,$
  ;INPUT:
    data=(*datablock.data)(*,where(*datablock.channels_ind)), dtimeax=*datablock.time, chpos=chpos(where(*datablock.channels_ind)),$
    expname=datablock.expname, shotnumber=datablock.shotnumber, timerange=datablock.timerange,$
    channels=(*datablock.channels)(where(*datablock.channels_ind)),$
    channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)),$
    transf_selection=datablock.proc_transf_selection, cwt_selection=datablock.proc_transf_cwt_selection,$
    cwt_family=datablock.proc_transf_cwt_family, cwt_order=datablock.proc_transf_cwt_order,$
    cwt_dscale=datablock.proc_transf_cwt_dscale, stft_selection=datablock.proc_transf_stft_selection,$
    stft_window=datablock.proc_transf_stft_window, stft_length=datablock.proc_transf_stft_length,$
    stft_step=datablock.proc_transf_stft_step,$
    freq_min=datablock.proc_transf_freq_min, freq_max=datablock.proc_transf_freq_max,$
    crosstr_selection=datablock.proc_crosstr_selection, coh_selection=datablock.proc_coh_selection,$
    coh_avr=datablock.proc_coh_avg, mode_selection=datablock.proc_mode_selection, mode_type=datablock.proc_mode_type,$
    mode_filter=datablock.proc_mode_filter, mode_steps=datablock.proc_mode_steps, mode_min=datablock.proc_mode_min,$
    mode_max=datablock.proc_mode_max, startpath=guiblock.startpath,$
  ;OUTPUT
    timeax=*datablock.transf_timeax, freqax=*datablock.transf_freqax, scaleax=*datablock.transf_scaleax, transforms=*datablock.transforms,$
    smoothed_apsds=*datablock.smoothed_apsds, crosstransforms=*datablock.crosstransforms,$
    smoothed_crosstransforms=*datablock.smoothed_crosstransforms, coherences=*datablock.coherences,$
    modenumbers=*datablock.modenumbers, qs=*datablock.qs, $
  ;INPUT - OUTPUT
    stft_fres=stft_fres

      ;STORE STFT FREQUENCY RESOLUTION POSITION:
	datablock.proc_transf_stft_fres = stft_fres
	widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, set_value = datablock.proc_transf_stft_fres

  widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = datablock.proc_transf_freq_min
  nti_wavelet_gui_calcmemory

      ;HANDLE SENSITIVITY
      ;------------------

	widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

	;TRAMSFROMS
	if keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.green_indicator
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 0
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;CROSS-TRAMSFROMS
	if keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.green_indicator
	  widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 0
	  nti_wavelet_gui_sens, /processing
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
	  widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;MODENUMBERS
	if keyword_set(*datablock.modenumbers) then begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.green_indicator
	  widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	endelse

      ;ACTIVATE GUI
      nti_wavelet_gui_addmessage, addtext='Ready'
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 1
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 1
      widget_control, nti_wavelet_gui_process_widg, sensitive = 1
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

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
      file=string(datablock.expname)+"_"+strcompress(string(datablock.shotnumber), /remove_all)+"_"+$
      strcompress(string(datablock.data_history), /remove_all)+"_processed.sav")

    if not keyword_set(guiblock.savefile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save data!'
    endif else begin	;keyword_set(guiblock.savefile_path)

    file_mkdir, file_dirname(guiblock.savefile_path, /mark_directory)

    saved_datablock = datablock
    save, saved_datablock, filename = guiblock.savefile_path
    nti_wavelet_gui_addmessage, addtext='Data saved!'

    guiblock.savefile_path = 0
    endelse

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_process_buttons_save_widg)


  ;******************************
  ;* CALCULATE MEMORY *
  ;******************************

    calcmemory_events = [ $
	nti_wavelet_gui_process_transf_select_widg, $
	nti_wavelet_gui_process_transf_cwt_widg, $
	nti_wavelet_gui_process_transf_cwt_order_widg, $
	nti_wavelet_gui_process_transf_cwt_dscale_widg, $
	nti_wavelet_gui_process_transf_stft_widg, $
	nti_wavelet_gui_process_transf_stft_length_widg, $
	nti_wavelet_gui_process_transf_stft_freq_widg, $
	nti_wavelet_gui_process_transf_stft_step_widg, $
	nti_wavelet_gui_process_freqrange_min_widg, $
	nti_wavelet_gui_process_freqrange_max_widg, $
	nti_wavelet_gui_process_crosstr_widg, $
	nti_wavelet_gui_process_coh_widg, $
	nti_wavelet_gui_process_coh_avg_widg, $
	nti_wavelet_gui_process_mode_select_widg]

      if (where(calcmemory_events eq event.ID) ne -1) then begin
	nti_wavelet_gui_calcmemory
      endif

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

      nti_wavelet_gui_addmessage, addtext='Plot data, it can take a lot of time!'
      nti_wavelet_gui_addmessage, addtext='Working ...'

;PLOTTER PROGRAM
nti_wavelet_plot, $
  ; Inputs - calculation results
    timeax=*datablock.transf_timeax, freqax=*datablock.transf_freqax, scaleax=*datablock.transf_scaleax,$
     transforms=*datablock.transforms, smoothed_apsds=*datablock.smoothed_apsds, crosstransforms=*datablock.crosstransforms,$
    smoothed_crosstransforms=*datablock.smoothed_crosstransforms, coherences=*datablock.coherences,$
    modenumbers=*datablock.modenumbers, qs=*datablock.qs,$
  ; Inputs - processing parameters
    expname=datablock.expname, shotnumber=datablock.shotnumber,$
    channels=(*datablock.channels)(where(*datablock.channels_ind)),$
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
    crosstr_phase=datablock.plot_crosstr_phase, crosstr_cscale=datablock.plot_crosstr_cscale,$
    coh_selection=datablock.plot_coh_selection, coh_all=datablock.plot_coh_all, coh_avg=datablock.plot_coh_avg,$
    coh_min=datablock.plot_coh_min, mode_selection=datablock.plot_mode_selection,$
    mode_cohlimit=datablock.plot_mode_cohlimit, mode_powlimit=datablock.plot_mode_powlimit,$
    mode_qlimit=datablock.plot_mode_qlimit, linear_freqax=datablock.plot_linear_freqax,$
  ; Save path
    savepath=datablock.plot_savepath,$
  ; Other
    startpath=guiblock.startpath, version=guiblock.version

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