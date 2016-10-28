;This is to filter our the neutron radiation spikes from the BES signal.
;Based on Sandor's filter_radiation_pulses.pro (see /IDL/FLIPP)
;Works for 2MHz bandwidth signal. (The shape of spikes depends on the bandwidth)

PRO bes_filter_radiation, signal, limit=limit

  if (not defined(limit)) then return
  if (limit le 0.0) then return

  if N_ELEMENTS(signal) lt 5 then return

  ; This is for KSTAR 2 Mhz measurements, but might be good for others
  ; diff = deriv(signal)
  diff = signal[1:n_elements(signal)-1]-signal[0:n_elements(signal)-2]
  n_pulses = 0

  ; Drop points when diff is one up, one down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6) ;??????? strange 'd' is not defined, '<' is not 'LT'. check with Sandor.
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind+4]
     n_pulses = n_pulses+n_elements(ind)
    endif
  endif

  ; Drop points with two up and one down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) ge limit) and (shift(diff,-3) lt -limit) )
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-7)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind+5]
      signal[ind+4] = signal[ind+5]
     n_pulses = n_pulses+n_elements(ind)
    endif
  endif

  ; Drop points with one up and two down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) lt -limit) and (shift(diff,-3) lt -limit) )
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-7)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind+5]
      signal[ind+4] = signal[ind+5]
     n_pulses = n_pulses+n_elements(ind)
    endif
  endif

  ; Drop points with one up, one within limit, one one down
  ind = where((shift(diff,-1) ge limit) and (shift(abs(diff),-2) lt limit) and (shift(diff,-3) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-7)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind+5]
      signal[ind+4] = signal[ind+5]
     n_pulses = n_pulses+n_elements(ind)
    endif
  endif


  return

END
