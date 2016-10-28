pro test_fastchop
; Program to test the capability of fast chopper signal processing
; Generates a background signal and a Li-beam signal and creates a fst chopping
; combined signal

period_n=20000l
period_sample=14l
mask_signal =     [5,6]
mask_background  = [12,13]
sampletime = 4d-7
period_time = period_sample*sampletime
int_signal = 15d-6
int_background = 50d-6
int_detector =0.5d-6
photon_noise = 0.05;  relative to mean signal

startup_time = max([int_signal,int_background,int_detector]*3)

signal = 1+0.45*randomn(seed,period_n*period_sample+(startup_time/sampletime))
signal = integ(signal,int_signal/sampletime)
signal = signal[startup_time/sampletime:n_elements(signal)-1]

background = 1.0+1.5*randomn(seed,period_n*period_sample+(startup_time/sampletime))
background = integ(background,int_background/sampletime)
background = background[startup_time/sampletime:n_elements(background)-1]

combined_signal = fltarr(n_elements(signal))
ind = lindgen(period_n)*period_sample
for i=0,period_sample/2-1 do begin
  combined_signal[ind+i] = signal[ind+i]+background[ind+i]
endfor

for i=period_sample/2,period_sample-1 do begin
  combined_signal[ind+i] = background[ind+i]
endfor

combined_signal = combined_signal+mean(combined_signal)*photon_noise*randomn(seed,n_elements(combined_signal))
combined_signal = integ(combined_signal,int_detector/sampletime)
time = dindgen(n_elements(combined_signal))*sampletime

ind_signal = lindgen(period_n)*n_elements(mask_signal)
outsignal = fltarr(period_n*n_elements(mask_signal))
time_signal = outsignal
ind_background = lindgen(period_n)*n_elements(mask_background)
outback = fltarr(period_n*n_elements(mask_signal))
time_background = outback

for i=0,n_elements(mask_signal)-1 do begin
  outsignal[ind_signal+i] = combined_signal[ind+mask_signal[i]]
  time_signal[ind_signal+i] = time[ind+mask_signal[i]]
endfor
for i=0,n_elements(mask_background)-1 do begin
  outback[ind_background+i] = combined_signal[ind+mask_background[i]]
  time_background[ind_background+i] = time[ind+mask_background[i]]
endfor

signal_cache_add,time=time,data=combined_signal,name='test_combined_signal',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

signal_cache_add,time=time,data=signal,name='test_signal_orig',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

signal_cache_add,time=time,data=signal+background,name='test_full_orig',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

signal_cache_add,time=time_signal,data=outsignal,name='test_signal_chop',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

signal_cache_add,time=time,data=background,name='test_background_orig',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

signal_cache_add,time=time_background,data=outback,name='test_background_chop',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

sigproc_resample,'test_signal_chop',sampletime=double(period_time)/2,signal_name_out='test_sigback',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

sigproc_resample,'test_background_chop',sampletime=double(period_time)/2,signal_name_out='test_background',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

sigproc_lincomb,['test_sigback','test_background'],[1,-1],signal_name_out='test_signal',errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

end



