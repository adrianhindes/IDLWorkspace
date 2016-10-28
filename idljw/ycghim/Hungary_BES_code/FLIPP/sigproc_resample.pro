pro sigproc_resample,signal_name_in,signal_name_out=signal_name_out,sampletime_new=sampletime_new,$
                     equidistant=equidistant,errorproc=errorproc,errormess=errormess


;***********************************************************************************
;* PRO SIGPROC_RESAMPLE                        S. Zoletnik    17.08.2008           *
;*---------------------------------------------------------------------------------*
;* Processes a signal in the signal cache by by resampling it.                     *
;* This procedure is applicable to situations where the output sampling rate is    *
;* lower than the original sampling rate. This procedure is applicable to          *
;* non-equidistantly sampled signals as well.                                      *
;* Equidistant time intervals are taken starting from the first sample             *
;* and the samples and their sampling times in each one are averaged.              *
;* If /equidistant is set the signal wil be linearly interpolated to an            *
;* equidistant series of timepoints, otherwise the interval means are used.        *
;* If no samples are found in some inerval they are interpolated.                  *                                                                           *
;* The output signal is stored in the signal cache by name signal_name_out.        *
;* Arguments:                                                                      *
;* INPUT:                                                                          *
;*  signal_name_in: Name of the signal (string).                                   *
;*  sampletime_new: The new sample time [s]                                        *
;*  signal_name_out: The name of the outpur signal.                                *
;*  /equidistant: Interpolates to timepoints at sampletime_new steps from the mean *
;*                sample times in the first time interval.                         *
;* OUTPUT:                                                                         *
;*  errorproc: Name of error processing routine to call on error                   *
;*  errormess: Error message. '' if no error occured.                              *
;***********************************************************************************

errormess = ''

; Checking input arguments
if (not defined(signal_name_in)) then begin
  errormess = 'Error in SIGPROC_RESAMPLE.PRO: Signal name must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif
if (size(signal_name_in,/type) ne 7) then begin
  errormess = 'Error in SIGPROC_RESAMPLE.PRO: Name must be a string.'
  return
endif
if (not defined(sampletime_new)) then begin
  errormess = 'Error in SIGPROC_RESAMPLE.PRO: sampletime_new must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif

; Converting sampletime to double
s_new = double(sampletime_new)

; Get signal from the cache
signal_cache_get,time=time,data=data,starttime=starttime,sampletime=sampletime,name=signal_name_in,errormess=errormess
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif

default,sampletime,min(time[1:n_elements(time)-1]-time[0:n_elements(time)-1])
if (not finite(sampletime)) then sampletime = time[1]-time[0]

tmin = min(time)
tmax = max(time)
ni = long(round((tmax-tmin)/s_new))

outsig = 0

; Assume that all output intervals will contain equal number of original samples
; Number of original samples in an output sample
;nsamp = long(n_elements(time)/ni)
nsamp = round(s_new/sampletime)
; Number of sample periods
nper = long(n_elements(time)/nsamp)
; The start times of the output periods
outtime = dindgen(nper)*s_new+tmin
; Time difference between first sample in each period and start of output time intervals
tdiff = time[lindgen(nper)*nsamp] - outtime[0:nper-1]
; Comparison margin to avoid problems from number precision
if (finite(sampletime)) then begin
  margin = sampletime/2;
endif else begin
  margin = s_new/nsamp;
endelse
; The indices where the first sample is not in the interval
ind1 = where((tdiff lt -margin) or (tdiff gt s_new+margin))
; Time difference between last sample in each period and start of output time intervals
tdiff = time[lindgen(nper)*nsamp+nsamp-1] - outtime[0:nper-1]
; The indices where the last sample is not in the interval
ind2 = where((tdiff lt -margin) or (tdiff gt s_new+margin))
if ((ind1[0] lt 0) and (ind2[0] lt 0)) then begin
  ; There are equal number of samples in each period
  time = time[0:nper*nsamp-1]
  outtime_real = dblarr(nper)
  outsig = fltarr(nper)
  ind = lindgen(nper)*nsamp
  for i=0,nsamp-1 do begin
    outsig = outsig + data[ind+i]
    outtime_real = outtime_real + time[ind+i]
  endfor
  outtime_real = outtime_real/nsamp
  outtime = outtime_real
  outsig = outsig/nsamp
endif else begin
  ; There is a variable number of samples per output sample

  ; The time delay between consequtive samples
  td_sample = time[1:n_elements(time)-1]-time[0:n_elements(time)-2]
  ; Select those where the time step is considerably larger than the sampletime (what is by default the minimum timestep)
  ind_jump = where(td_sample gt sampletime*1.5)
  ; Check whether the jumps occur after an identical length of a group of samples
  ; This will be the indices where the jump is different from the first jump
  ind_not = where((ind_jump[1:n_elements(ind_jump)-1]-ind_jump[0:n_elements(ind_jump)-2]) ne (ind_jump[1]-ind_jump[0]))
  if (ind_not[0] lt 0) then begin
    ; We have groups of samples and the goups are of of equal length
    ; Withing the groups the samples follow each other with sampletime
     ; The time between the first and last jump time
     tspan = time[ind_jump[n_elements(ind_jump)-1]]-time[ind_jump[0]]
     ; Checking whenter this time is close to an integer multiple of the new sampling time
     if (abs(tspan-round(tspan/s_new)*s_new)  lt sampletime*0.5) then begin
      ; The period time of the sample groups is an integer multiple of the new sample time
      sample_n_group = ind_jump[1]-ind_jump[0]
      ; If the signal starts with part of a group we drop the leading samples before the first group
      if (ind_jump[0] ne sample_n_group-1) then begin
        time = time[ind_jump[0]+1:n_elements(time)-1]
        data = data[ind_jump[0]+1:n_elements(data)-1]
      endif
      ; The number of groups in the original sample
      nper = long(n_elements(time)/sample_n_group)
      ; Cutting the sample for full groups
      time = time[0:nper*sample_n_group-1]
      data = data[0:nper*sample_n_group-1]
      ; The number of output samples
      nper_out = long((time[nper*sample_n_group-1]-time[0])/s_new)
      ; The number of new samples with cover one period of the groups
      groups_per_output = round((time[ind_jump[1]]-time[ind_jump[0]])/s_new)

      outsig = fltarr(nper_out)
      ; Array for the real outtime, that is the mean sampling times in the new time intervals
      outtime_real = dblarr(nper_out)
      ind = lindgen(nper_out)*sample_n_group
      ind_out = lindgen(nper_out)*groups_per_output
      for i=0,sample_n_group-1 do begin
        outsig[ind_out] = outsig[ind_out]+data[ind+i]
        outtime_real[ind_out] = outtime_real[ind_out]+time[ind+i]
      endfor
      outsig = outsig/sample_n_group
      outtime_real = outtime_real/sample_n_group
      mask = intarr(nper_out)
      mask[ind_out] = sample_n_group
    endif
  endif
  if (n_elements(outsig) eq 1) then begin
    ; No structure is found in the data, looping through the new sample periods
    ; This might take some time
    if (not keyword_set(silent)) then begin
      errormess = 'Warning in SIGPROC_RESAMPLE.PRO: No structure found in samples, processing might take a long time.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif
    endif
    tmin = min(time)
    tmax = max(time)
    ni = long(round((tmax-tmin)/s_new))
    outtime = sindgen(ni)*s_new+tmin
    outtime_real = dblarr(ni)
    outsig = fltarr(ni)
    ; this will contain the number of elements averaged per output sample
    mask = intarr(ni)
    ; Shifting the boundaries by a small fraction of the sampletime to avoid problems from number precision
    margin = s_new*1e-3
    ; Averaging the samples in each box and recording the number of samples in each
    for i=0l,ni-1 do begin
      t1 = double(i)*s_new+tmin
      t2 = t1+s_new
      ind = where((time ge t1-margin) and (time lt t2-margin))
      if (ind[0] ge 0) then begin
        ; The number of samples
        mask[i] = n_elements(ind)
        ; The mean signal
        outsig[i] = mean(data[ind])
        outtime_real[i] = mean(time[ind])
      endif
    endfor
  endif

  ; Checking whether there is a new sample without data
  ind = where(mask eq 0)
  if (ind[0] lt 0) then begin
    ; If no mising samples then checking equidistant sampling
    d = outtime_real[1:n_elements(outtime_real)-1]-outtime_real[0:n_elements(outtime_real)-2]
    ind1 = where(abs(d-d[0]) gt sampletime*0.1)
  endif
  ; If there are missing samples or equidistant sampling is requested and the time vector is not equidistant
  ; then interpolating is needed
  if ((ind[0] ge 0) or (keyword_set(equidistant) and (ind1[0] ge 0))) then begin
    outtime = outtime_real[0]+dindgen(n_elements(outtime_real))*s_new
    if (ind[0] lt 0) then begin
      ; No missing samples
      outsig = interpol(outsig,outtime_real,outtime)
    endif else begin
      ind = where(mask ne 0)
      outsig = interpol(outsig[ind],outtime_real[ind],outtime)
    endelse
  endif else begin
    outtime = outtime_real
  endelse
endelse  ; variable number of samples

; Saving signal
signal_cache_add,time=outtime,data=outsig,sampletime=s_new,starttime=outtime[0],name=signal_name_out,errormess=errormess
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif


end