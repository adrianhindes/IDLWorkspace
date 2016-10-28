pro fastchop_signal,shot,signal_names,timerange=timerange,background_subchannel=background_subchannel,$
   mask_signal=mask_signal,mask_background=mask_background,errormess=errormess

; Calculates the backgroud corrected signals from fast chopper measurements
; signal_names can be an array as well.

errormess = ''

default,data_source,fix(local_default('data_source'))
default,datapath,local_default('datapath')
default,background_subchannel,2
default,signal_names,defchannels(shot,data_source=data_source)

if (background_subchannel eq 1) then signal_subchannel = 2 else signal_subchannel=1

DEFLECTION_CONFIG,shot,DATA_SOURCE=data_source,param,DATAPATH=datapath,$
    PERIOD_TIME=period_time, ERRORMESS = errormess,/SILENT
if (errormess ne '') then begin
  print,errormess
  return
endif

ch_mask = local_default('radpulse_correction_channels')

n_signal = n_elements(signal_names)
for i=0, n_signal-1 do begin

  signal_name = signal_names[i]
  print,'Processing '+signal_name  & wait,0.1

  if (ch_mask ne '') then begin
    ch_mask = strsplit(ch_mask,',',/extract)
    n_mask = n_elements(ch_mask)
    found = 0
    for j=0,n_mask-1 do begin
      if (strmatch(signal_name,ch_mask[j],/fold_case)) then found = 1
    endfor
    if (keyword_set(found)) then begin
      config_radpulse_limit = local_default('radiation_pulse_limit')
      if (config_radpulse_limit ne '') then radpulse_limit = float(config_radpulse_limit)/3 else radpulse_limit = 0.
    endif
  endif

  signal = signal_name
  get_rawsignal,shot,signal,t,d,subchannel=signal_subchannel,subch_mask=mask_signal,trange=timerange,cache=signal_name,errormess=errormess,data_source=data_source
  if (errormess ne '') then begin
    print,errormess
    return
  endif

  output_sampletime = double(period_time)/2
  sigproc_resample,signal_name,sampletime=output_sampletime,signal_name_out=signal_name,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif

  if (keyword_set(found) and keyword_set(radpulse_limit)) then begin
    signal_cache_get,name=signal_name,data=signal_data,time=time,errormess=errormess
    if (errormess ne '') then begin
      print,errormess
      return
    endif
    filter_radiation_pulses,signal_data,data_source=data_source,limit=radpulse_limit,n_pulses=n_pulses,/subchannel
    signal_cache_add,name=signal_name,data=signal_data,time=time,errormess=errormess
    if (errormess ne '') then begin
      print,errormess
      return
    endif
  endif

  get_rawsignal,shot,signal,t,d,subchannel=background_subchannel,subch_mask=mask_background,trange=timerange,cache=i2str(shot)+'_'+signal_name+'_back',errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif

  back_signal_name = i2str(shot)+'_'+signal_name+'_back'
  sigproc_resample,i2str(shot)+'_'+signal_name+'_back',sampletime=output_sampletime,signal_name_out=back_signal_name,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif

  if (keyword_set(found) and keyword_set(radpulse_limit)) then begin
    signal_cache_get,name=back_signal_name,data=signal_data,time=time,errormess=errormess
    if (errormess ne '') then begin
      print,errormess
      return
    endif
    filter_radiation_pulses,signal_data,data_source=data_source,limit=radpulse_limit,n_pulses=n_pulses,/subchannel
    signal_cache_add,name=back_signal_name,data=signal_data,time=time,errormess=errormess
    if (errormess ne '') then begin
      print,errormess
      return
    endif
  endif

  sigproc_lincomb,[signal_name,i2str(shot)+'_'+signal_name+'_back'],[1,-1],signal_name_out=i2str(shot)+'_'+signal_name,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif
  signal_cache_delete,name=signal_name
endfor

beam_coordinates,shot,r,z,beam,data_source=data_source
  ;show_rawsignal,shot,'cache/'+signal_name
t = findgen(n_elements(beam))+1
signal_cache_add,time=t,data=beam,name='beam_coordinates',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

end