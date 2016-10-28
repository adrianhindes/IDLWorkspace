;==========================================================================================

;NTI_WAVELET_GUI.PRO

;==========================================================================================
;-- This program handles NTI WAVELET TOOLS routines
;==========================================================================================

pro nti_wavelet_gui, input_structure=input_structure, event=event
@nti_wavelet_gui_common.pro


;Create structures to store calculated data:
;*******************************************

datablock = { $ 
;Signal features:
	expname : "---", $
	shotnumber : 0L, $
	timerange : [0D,0D], $
	samplefreq : 0D, $
	numofchann : 0L, $
	theta_type : "---", $
	data_history : "", $
;Data of signals:
	channels : ptr_new(0), $
	data : ptr_new(0), $
	time : ptr_new(0), $
	theta : ptr_new(0), $
	phi : ptr_new(0), $
	channelpairs : ptr_new(0), $
	channelpairs_ind :ptr_new(0), $
	channelpairs_num : 0L, $
	channelpairs_select_num :  0L, $ ;number of channel pairs which selected
;Processing block:
	proc_transf_selection : 0, $
	proc_transf_cwt_selection : 0, $
	proc_transf_cwt_family : "", $
	proc_transf_cwt_order : 0L, $
	proc_transf_cwt_dscale : 0D, $
	proc_transf_stft_selection : 0, $
	proc_transf_stft_window : "", $
	proc_transf_stft_length : 0L, $
	proc_transf_stft_fres : 0L, $
	proc_transf_stft_step : 0L, $
	proc_transf_freq_min : 0D, $
	proc_transf_freq_max : 0D, $
	proc_crosstr_selection : 0, $
	proc_coh_selection : 0, $
	proc_coh_avg : 0L, $
	proc_mode_selection : 0, $
	proc_mode_type : "", $
	proc_mode_filter : "", $
	proc_mode_steps : 0L, $
	proc_mode_min : 0L, $
	proc_mode_max : 0L, $
;Visualization block:
	plot_linear_freqax : 0, $
	plot_transf_selection : 0, $
	plot_transf_smooth : 0, $
	plot_transf_energy : 0, $
	plot_transf_phase : 0, $
	plot_transf_cscale : 0D, $
	plot_crosstr_selection : 0, $
	plot_crosstr_smooth :0, $
	plot_crosstr_energy : 0, $
	plot_crosstr_phase : 0, $
	plot_crosstr_cscale : 0D, $
	plot_coh_selection : 0, $
	plot_coh_all : 0, $
	plot_coh_avg : 0, $
	plot_coh_min : 0, $
	plot_mode_selection : 0, $
	plot_mode_cohlimit : 0., $
	plot_mode_powlimit : 0., $
	plot_mode_qlimit : 0., $
	plot_savepath : "", $
;NTI_WAVELET_MAIN OUTPUT:
	transf_timeax : ptr_new(0), $
	transf_freqax : ptr_new(0), $
	transf_scaleax : ptr_new(0), $
	transforms : ptr_new(0), $
	smoothed_apsds : ptr_new(0), $
	crosstransforms : ptr_new(0), $
	smoothed_crosstransforms : ptr_new(0), $
	coherences : ptr_new(0), $
	modenumbers : ptr_new(0), $
	qs : ptr_new(0), $
;Others:
	startpath : "", $ ;store source directory of nti_wavelet_gui.pro
	version : "" $
}

;SEARCH PATH FROM NTI_WAVELET_TOOLS_GUI STARTED:
;***********************************************

  ;call source of compiled procedures with help:
    help, /source_files, output=output
    out_ind_1 = strpos(output, 'nti_wavelet_gui.pro')
    out_1 = strsplit(output(where(out_ind_1 ne -1)), ' ', /extract)
    out_ind_2 = strpos(out_1, 'nti_wavelet_gui.pro')
    out_2 = out_1(where(out_ind_2 ne -1))

    datablock.startpath = file_dirname(out_2, /mark_directory)
    print, "Program will try to read required files from: "+datablock.startpath


  ;if startpath not finded, ask user:
;    if (index eq -1) then begin
;      res = dialog_message(['It is important to know, where nti_wavelet_gui.pro started from,',$
;	'but the program cannot initializing it, so you will select this path!'], /center)
;      startpath = dialog_pickfile(title = "Select directory!", /directory)
;    ;save path to structure
;      datablock.startpath = startpath
;    endif else begin
;      startpath = output_arr(index, 1)
;  ;save path to structure
;    datablock.startpath = file_dirname(startpath, /mark_directory)
;    print, "Program will try to read required files from: "+datablock.startpath
;    endelse

;READ VERSION:
;************
readme_ver = ""
readme_st = ""
;can we open readme.txt?
openr, unit, datablock.startpath+"readme.txt", /get_lun, error=error
if error ne 0 then begin
  print, "Readme file could not be opened at "+datablock.startpath+"readme.txt"
  datablock.version = "undefined"
endif else begin
  readf, unit, readme_ver
    readme_ver = strsplit(readme_ver, " ", /extract)
    datablock.version = readme_ver (3)
  readf, unit, readme_st
    readme_st = strsplit(readme_st, " ", /extract)
    readme_st = readme_st(1)
    if (readme_st eq 'unreleased') then begin
      ;check svn revision number
	svn_data = strarr(5)
	svn_path = filepath('entries', root_dir=datablock.startpath, subdirectory='.svn')
	; .svn directory found, but can we open it?
	openr,unit,svn_path,/get_lun,error=error
	if error ne 0 then begin 
	  print, 'Subversion file could not be opened at '+svn_path
	  datablock.version = datablock.version+" unreleased"
	endif else begin
	  readf,unit,svn_data
	  datablock.version = datablock.version+" - r"+svn_data[3]
	endelse
    endif
endelse


;Some minor setup:
print, "Reading files from: "+datablock.startpath
red_indicator = READ_BMP(datablock.startpath+'red.bmp',/rgb)
red_indicator = TRANSPOSE(red_indicator, [1,2,0])
green_indicator = READ_BMP(datablock.startpath+'green.bmp',/rgb)
green_indicator = TRANSPOSE(green_indicator, [1,2,0])


;Create structure to handle gui:
;*******************************
guiblock= { $
;Index variables:
;Dropdown menu values:
	cwt_family : ["Morlet"], $
	stft_window : ["Gauss"], $
	mode_type : ["Toroidal", "Poloidal"], $
	filter : ["Rel. pos."], $
	ctf_smooth : ["Energy", "Phase"], $
	coh_plot_type : ["All", "Average", "Minimum"], $
;Save/Load Parameters:
	loadfile_path : "", $
	savefile_path : "", $
;Other:
	red_indicator : red_indicator, $
	green_indicator : green_indicator $
}


;Create structure to store configuration for saving .cfg files:
;*************************************************************

cfgblock = { $ 
;Processing block:
	proc_transf_selection : 0, $
	proc_transf_cwt_selection : 0, $
	proc_transf_cwt_family : "", $
	proc_transf_cwt_order : 0L, $
	proc_transf_cwt_dscale : 0D, $
	proc_transf_stft_selection : 0, $
	proc_transf_stft_window : "", $
	proc_transf_stft_length : 0L, $
	proc_transf_stft_fres : 0L, $
	proc_transf_stft_step : 0L, $
	proc_transf_freq_min : 0D, $
	proc_transf_freq_max : 0D, $
	proc_crosstr_selection : 0, $
	proc_coh_selection : 0, $
	proc_coh_avg : 0L, $
	proc_mode_selection : 0, $
	proc_mode_type : "", $
	proc_mode_filter : "", $
	proc_mode_steps : 0L, $
	proc_mode_min : 0L, $
	proc_mode_max : 0L, $
;Visualization block:
	plot_linear_freqax : 0, $
	plot_transf_selection : 0, $
	plot_transf_smooth : 0, $
	plot_transf_energy : 0, $
	plot_transf_phase : 0, $
	plot_transf_cscale : 0D, $
	plot_crosstr_selection : 0, $
	plot_crosstr_smooth :0, $
	plot_crosstr_energy : 0, $
	plot_crosstr_phase : 0, $
	plot_crosstr_cscale : 0D, $
	plot_coh_selection : 0, $
	plot_coh_all : 0, $
	plot_coh_avg : 0, $
	plot_coh_min : 0, $
	plot_mode_selection : 0, $
	plot_mode_cohlimit : 0L, $
	plot_mode_powlimit : 0L, $
	plot_mode_qlimit : 0L, $
	plot_savepath : "" $
}


;If NTI_WAVELET_GUI.PRO started from MTR, add data to datablock
if keyword_set(input_structure) then begin
  datablock.expname=input_structure.expname
  datablock.shotnumber=input_structure.shotnumber
  *datablock.channels = input_structure.channels
  *datablock.data = input_structure.data
  *datablock.time = input_structure.time
  *datablock.theta = input_structure.theta
  *datablock.phi = input_structure.phi
  datablock.theta_type=input_structure.theta_type
  datablock.data_history=input_structure.data_history

  ;Calculate timerange, sample frequency and number of channels:
  datablock.timerange=[input_structure.time[0], input_structure.time[n_elements(input_structure.time)-1]]
  datablock.samplefreq=1d-3/((input_structure.time[n_elements(input_structure.time)-1]-input_structure.time[0])/double(n_elements(input_structure.time)-1))
  datablock.numofchann=n_elements(input_structure.channels)
endif

; Creates the GUI
nti_wavelet_gui_create

; Calls XMANAGER to handle user events
xmanager,'nti_wavelet_gui',nti_wavelet_gui_widg,event_handler='nti_wavelet_gui_event'

end
