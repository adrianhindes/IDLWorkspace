pro sigproc_lincomb,signal_names,weights,signal_name_out=signal_name_out,$
                     errorproc=errorproc,errormess=errormess


;***********************************************************************************
;* PRO SIGPROC_LINCOMB                         S. Zoletnik    17.08.2008           *
;*---------------------------------------------------------------------------------*
;* Calculates the oinear combination of several signals in the signal cache.       *
;* The signals must have parts with a common timevector                            *
;* The output signal is stored in the signal cache by name signal_name_out.        *
;* Arguments:                                                                      *
;* INPUT:                                                                          *
;*  signal_names: Names of the signals (string array).                             *
;*  weights: Weight factors for the signals (numeric array)                        *
;*  signal_name_out: The name of the outpur signal.                                *
;* OUTPUT:                                                                         *
;*  errorproc: Name of error processing routine to call on error                   *
;*  errormess: Error message. '' if no error occured.                              *
;***********************************************************************************

errormess = ''

; Checking input arguments
if (not defined(signal_names)) then begin
  errormess = 'Error in SIGPROC_LINCOMB.PRO: Signal name(s) must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif
if (size(signal_names,/type) ne 7) then begin
  errormess = 'Error in SIGPROC_LINCOMB.PRO: Signals name(s) must be string.'
  return
endif
if (not defined(weights)) then begin
  errormess = 'Error in SIGPROC_LINCOMB.PRO: weights must be defined.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif
if (n_elements(weights) ne n_elements(signal_names)) then begin
  errormess = 'Error in SIGPROC_LINCOMB.PRO: weights must have same number of elements as signal_names.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif

n_sig = n_elements(signal_names)

; Loop through signals
for i=0,n_sig-1 do begin
  ; Get signal from the cache
  signal_cache_get,time=time,data=data,name=signal_names[i],errormess=errormess
  if (errormess ne '') then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif
    return
  endif

  if (i eq 0) then begin
    ; Save the time vector if this is the first signal
    outtime = time
    outsig = data*weights[0]
  endif else begin
    ; Determine mean timestep
    mean_step = double(outtime[n_elements(outtime)-1]-outtime[0])/(n_elements(outtime)-1)
    eq_limit = mean_step*1d-2;
    ; Check that the time vectors are identical
    if (total(abs(time-outtime) ge eq_limit) ne 0) then begin
      ; Try to find sub-intervals with identical timescales
      if (time[0] lt outtime[0]) then begin
        ind_start = where(abs(time-outtime[0]) lt eq_limit)
        ind_start = ind_start[0]
        if (ind_start lt 0) then begin
          errormess = 'Error in SIGPROC_LINCOMB.PRO: At least part of time vector of signals must be identical.'
          if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess,/forward
          endif
          return
        endif else begin
          ind = where(abs(outtime-time[ind_start:n_elements(time)-1]) lt eq_limit)
          ; If there are at least 2 identical timepoints
          if (n_elements(ind) ge 2) then begin
            outtime = outtime[0:n_elements(ind)-1]
            outsig = outsig[0:n_elements(ind)-1]
            time = time[ind_start+ind]
            data = data[ind_start+ind]
          endif
        endelse
      endif else begin
        ind_start = where(abs(outtime-time[0]) lt eq_limit)
        ind_start = ind_start[0]
        if (ind_start lt 0) then begin
          errormess = 'Error in SIGPROC_LINCOMB.PRO: At least part of time vector of signals must be identical.'
          if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess,/forward
          endif
          return
        endif else begin
          ind = where(abs(time-outtime[ind_start:n_elements(outtime)-1]) lt eq_limit)
          ; If there are at least 2 identical timepoints
          if (n_elements(ind) ge 2) then begin
            time = time[0:n_elements(ind)-1]
            data = data[0:n_elements(ind)-1]
            outtime = outtime[ind_start+ind]
            outsig = outsig[ind_start+ind]
          endif
        endelse
      endelse
    endif
    outsig = outsig + data*weights[i]
  endelse
endfor


; Saving signal
signal_cache_add,time=outtime,data=outsig,name=signal_name_out,errormess=errormess
if (errormess ne '') then begin
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif
  return
endif


end