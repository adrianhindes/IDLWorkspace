pro fastdefl_signal,shot,signal_names,timerange=timerange,errormess=errormess,subch_mask_1=subch_mask_1,subch_mask_2=subch_mask_2

; Calculates the two subchannel signals from a fast deflection measurement
; There will be one measurement point per deflection period
; signal_names can be an array as well

default,shot,107253
default,timerange,[1,3.9]
default,signal_names,defchannels(shot)
default,data_source,fix(local_default('data_source'))
default,datapath,local_default('datapath')

DEFLECTION_CONFIG,shot,DATA_SOURCE=data_source,param,DATAPATH=datapath,$
    PERIOD_TIME=period_time, ERRORMESS = errormess,/SILENT
if (errormess ne '') then begin
  print,errormess
  return
endif

n_signal = n_elements(signal_names)
for i=0, n_signal-1 do begin
  signal_name = signal_names[i]
  print,'Processing '+signal_name

  signal = signal_name
  get_rawsignal,shot,signal,t,d,subchannel=1,trange=timerange,cache=i2str(shot)+'_'+signal_name+'_1',$
    subch_mask=subch_mask_1,errormess=errormess,data_source=data_source
  if (errormess ne '') then begin
    print,errormess
    return
  endif

  sigproc_resample,i2str(shot)+'_'+signal_name+'_1',sampletime=double(period_time),signal_name_out=i2str(shot)+'_'+signal_name+'_1',errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif

  get_rawsignal,shot,signal,t,d,subchannel=2,trange=timerange,cache=i2str(shot)+'_'+signal_name+'_2',$
    subch_mask=subch_mask_2,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif

  sigproc_resample,i2str(shot)+'_'+signal_name+'_2',sampletime=double(period_time),signal_name_out=i2str(shot)+'_'+signal_name+'_2',errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif
endfor

end
