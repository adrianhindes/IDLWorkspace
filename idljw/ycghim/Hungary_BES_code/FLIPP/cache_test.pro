pro cache_test


; Generating a timevector
sampletime = 1d-6
starttime = 1.d0
time = dindgen(10000)*sampletime+starttime

; Generating two signals
signal_1 = sin(2*!pi*2e4*time)+randomn(seed,n_elements(time))
signal_2 = cos(2*!pi*2e4*time)+randomn(seed,n_elements(time))

; Adding the sin signal to the cache
signal_cache_add,time=time, data=signal_1, name='sin_signal',errormess=e
if (e ne '') then begin
  print,e
  return
endif

; Adding the cos signal. Here the timescale is given by starttime/sampletime
signal_cache_add,starttime=starttime, sampletime=sampletime, data=signal_2, name='cos_signal',errormess=e
if (e ne '') then begin
  print,e
  return
endif

; Listing the contents of the signal cache
signal_cache_list,list=list,errormess=e
if (e ne '') then begin
  print,e
  return
endif

; Showing the signals from the cache
window,0
show_rawsignal,0,'cache/sin_signal',trange=[1,1.001]
window,1
show_rawsignal,0,'cache/cos_signal',trange=[1,1.001]

; Showing auto- and crosscorrelations
window,2
crosscor_new,0,timerange=[1,1.01],ref='cache/sin_signal',plot='cache/sin_signal',trange=[-300,300],tres=1,/norm,/silent
wait,2
crosscor_new,0,timerange=[1,1.01],ref='cache/sin_signal',plot='cache/cos_signal',trange=[-300,300],tres=1,/norm,/silent


; Resampling one of the signals
sigproc_resample,'sin_signal',signal_name_out='sin_signal_resamp',sampletime_new=10e-6,errormess=e
if (e ne '') then begin
  print,e
  return
endif
window,3
show_rawsignal,0,'cache/sin_signal_resamp',trange=[1,1.001]

;Linear combination of the two signals
sigproc_lincomb,['sin_signal','cos_signal'],[1,2],signal_name_out='lincomb_signal',errormess=e
if (e ne '') then begin
  print,e
  return
endif
window,4
show_rawsignal,0,'cache/lincomb_signal',trange=[1,1.001]

; Removing the signals from cache
signal_cache_delete,/all
; This should be an error, as signals are deleted
show_rawsignal,0,'cache/sin_signal',trange=[1,1.001]
end