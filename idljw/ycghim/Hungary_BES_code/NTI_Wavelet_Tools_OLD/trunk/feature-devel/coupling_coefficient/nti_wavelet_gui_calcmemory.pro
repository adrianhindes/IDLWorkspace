;+
; NAME:
;	NTI_WAVELET_GUI_CALCMEMORY
;
; PURPOSE:
;	This procedure predicts the memory to be used for the calculations,
;	and prints out to NTI Wavelet Tools Graphical User Interface.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_CALCMEMORY
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
;-


pro nti_wavelet_gui_calcmemory
@nti_wavelet_gui_common.pro

nti_wavelet_gui_readconfig, /processing

temp=where(*datablock.channels_ind, channel_num); Calculate number of used channels
time_num=n_elements(*datablock.time)/(0.5*datablock.samplefreq/datablock.proc_transf_freq_max)

if datablock.proc_transf_cwt_selection then begin
  freq_min=max([datablock.proc_transf_freq_min*1000,max([1,datablock.proc_coh_avg])*datablock.proc_transf_cwt_order*2/(datablock.timerange(1)-datablock.timerange(0))]) ; in Hz
  start_scale=datablock.proc_transf_cwt_order/!PI
  max_scale=datablock.proc_transf_cwt_order/freq_min/2/!PI*datablock.samplefreq*1000
  nscale=ceil(pg_log2(max_scale/start_scale)/datablock.proc_transf_cwt_dscale)+1 ; Calculate nscale from minimum frequency
  transform_memory=8*time_num*nscale
endif else begin
  transform_memory=8*time_num/float(datablock.proc_transf_stft_step)*datablock.proc_transf_stft_fres
endelse

memory=0
if datablock.proc_transf_selection OR defined(*datablock.transforms, /nullarray) then memory=memory+transform_memory*channel_num
if datablock.proc_crosstr_selection OR defined(*datablock.crosstransforms, /nullarray) then memory=memory+transform_memory*datablock.channelpairs_select_num
if datablock.proc_coh_selection OR defined(*datablock.coherences, /nullarray) then memory=memory+transform_memory*(datablock.channelpairs_select_num*1.5+channel_num)
if datablock.proc_mode_selection OR defined(*datablock.modenumbers, /nullarray) then memory=memory+transform_memory*(datablock.channelpairs_select_num+2)

;ROUNDING VALUE OF MEMEORY
  ;convert value to GB:
    memory=memory/(2D^30)
  ;round to two decimal:
    memory=100*memory
    memory=round(memory)
    memory=1D-2*memory
  ;convert to string:
    memory = string(memory)
  ;search position of decimal:
    pos = strpos(memory, '.')
  ;cut the zeros from the end of string
    memory = strmid(memory, 0, pos+3)

widget_control, nti_wavelet_gui_process_buttons_memory_widg, set_value = memory

end