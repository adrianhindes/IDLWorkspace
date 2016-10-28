pro sigproc_bandpower,signal_name_in,signal_name_out=signal_name_out,filter_low=filter_low,filter_high=filter_high,$
                     filter_order=filter_order,filter_symmetric=filter_symmetric,inttime=inttime,$
                     resample=resample,errorproc=errorproc,errormess=errormess


;***********************************************************************************
;* PRO SIGPROC_BANDPOWER                        S. Zoletnik    14.05.2009          *
;*---------------------------------------------------------------------------------*
;* Filters a signal with a bandpass filter takes its sqare and integrates.         *
;* A FIR filter is used se the digital_filter IDL program.                         *
;* Arguments:                                                                      *
;* INPUT:                                                                          *
;*  signal_name_in: Name of the signal (string).                                   *
;*  filter_low: lower frequency of the band [Hz]                                   *
;*  filter_high: upper frequency of the band [Hz]                                  *
;*  filter order: The order of a non-recursive filter  (def: 100)                  *
;*  filter_symmetric: Symmetric or asymmetric filter response function.            *
;*                   Use filter_symmetric=0 to use asymmetric filter,              *
;*                   filter_symmetric=1 to use symmetric filter.                   *
;*  inttime: The integration time of the final integration [s]                     *
;*  resample: Resample to this time resolution. This must be a multiple of the     *
;*            sampletime of the original signal.                                   *
;*  signal_name_out: The name of the outpur signal.                                *
;* OUTPUT:                                                                         *
;*  errorproc: Name of error processing routine to call on error                   *
;*  errormess: Error message. '' if no error occured.                              *
;***********************************************************************************

errormess = ''

; Checking input arguments
if (not defined(signal_name_in)) then begin
  errormess = 'Error in SIGPROC_BANDPOWER.PRO: Signal name must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif
if (size(signal_name_in,/type) ne 7) then begin
  errormess = 'Error in SIGPROC_BANDPOWER.PRO: Name must be a string.'
  return
endif
if (not defined(filter_low)) then begin
  errormess = 'Error in SIGPROC_BANDPOWER.PRO: filter_low must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif
if (not defined(filter_high)) then begin
  errormess = 'Error in SIGPROC_BANDPOWER.PRO: filter_high must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif
default,filter_order,100
if (not defined(inttime)) then begin
  errormess = 'Error in SIGPROC_BANDPOWER.PRO: inttime must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif

; Get signal from the cache
signal_cache_get,time=time,data=data,starttime=starttime,sampletime=sampletime,name=signal_name_in,errormess=errormess
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif

default,sampletime,(time[n_elements(time)-1]-time[0])/(n_elements(time)-1)
if (not finite(sampletime)) then sampletime = (time[n_elements(time)-1]-time[0])/(n_elements(time)-1)

data = bandpass_filter_data(data,sampletime=sampletime,$
           filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
           filter_symmetric=filter_symmetric,errormess=errormess)
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif

time = time[filter_order:n_elements(data)-filter_order-1]
data = data[filter_order:n_elements(data)-filter_order-1]
data = integ(data^2,inttime/sampletime)

; Saving signal
signal_cache_add,time=time,data=data,name=signal_name_out,errormess=errormess
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif

if (keyword_set(resample)) then begin
  resample = round(double(resample)/double(sampletime))*sampletime
  sigproc_resample,signal_name_out,signal_name_out=signal_name_out,sampletime_new=resample,$
                     errorproc=errorproc,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif
endif

end