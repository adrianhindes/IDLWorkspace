pro filter_radiation_pulses,signal,limit=limit,n_pulses=n_pulses,data_source=data_source,subchannel=subchannel,recursive=recursive

;******************************************************************************************
;* FILTER_RADIATION_PULSES.PRO                                                            *
;* This routine filters out individual peaks in the singal caused by gamma photons and    *
;* neutrons hitting the detector. This is now set up for the TEXTOR 2.5 MHz sampled       *
;* Li-BES signals. The algorithm or parameters might need to be changed for other sample   *
;* rates and bandwidth.                                                                   *
;* The present algorythm differentiates the signal and looks for positive and negative    *
;* following each other in a short time. The peaks are then replaced by signal values     *
;* before/after.                                                                          *
;* INPUT:                                                                                 *
;*   signal: the input signal as a onedimensional array                                   *
;*   limit: The limit to consider a pulse in the derivate bot in positive or negative     *
;*   direction                                                                            *
;*   subchannel: if not zero this is a subchannel (e.g. at TEXTOR Li-beam                 *
;*   recursive: Indicates that this is already a recursive call, will not call again      *
;* OUTPUT:                                                                                *
;*   signal: The modeified signal.                                                        *
;*   n_pulses: The number of pulses eliminated.                                           *
;******************************************************************************************

;default,data_source,-1
default,data_source,fix(local_default('data_source'))
default,subchannel,0


if (not defined(limit)) then return
if (limit le 0.0) then return

if n_elements(signal) lt 5 then return

if ((data_source eq 32) or (data_source eq 39) or (data_source eq 40)) then begin
  ; This is for KSTAR and EAST 2 Mhz measurements, but might be good for others
  ; diff = deriv(signal)
  diff = signal[1:n_elements(signal)-1]-signal[0:n_elements(signal)-2]
  n_pulses = 0

  ; Drop points when diff is one up, one down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6)
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

  ; Drop points with one up, one within limit, one down
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

  ; Drop points with one up, two within limit, one down
  ind = where((shift(diff,-1) ge limit) and (shift(abs(diff),-2) lt limit) and (shift(abs(diff),-3) lt limit) and (shift(diff,-4) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-7)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind]
      signal[ind+4] = signal[ind+7]
      signal[ind+5] = signal[ind+7]
      signal[ind+6] = signal[ind+7]
     n_pulses = n_pulses+n_elements(ind)
    endif
  endif

  if (not keyword_set(recursive)) then begin
    filter_radiation_pulses,signal,limit=limit,n_pulses=n_pulses1,data_source=data_source,subchannel=subchannel,/recursive
    n_pulses = n_pulses+n_pulses+1
  endif
  return
endif  ; KSTAR




If data_source eq 30 then begin
  ; This is for MAST BES
  diff = deriv(signal)
  n_pulses = 0
  signal_old=signal

  ;two points up, two points down
  ind = where((diff ge limit) and (shift(diff,-1) ge limit) and ((shift(diff,-2) lt -limit) or (shift(diff,-3) lt -limit)) )

  ;window, 0
   ;plot, diff[ind[0]-5:ind[0]+5], psym=1
  ; for i=1, n_elements(ind)-1 do oplot, diff[ind[i]-5:ind[i]+5], psym=1

  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6)

    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind+5]
      signal[ind+4] = signal[ind+5]
      n_pulses = n_pulses+n_elements(ind)
    endif
  endif

  ;window, 1
  ;plot, signal[ind[0]-5:ind[0]+5], psym=1
  ;for i=1, n_elements(ind)-1 do oplot, signal[ind[i]-5:ind[i]+5], psym=1

  ;one point up, middle point somewhere, one point down (smaller/narrower peak)
  ind = where((diff ge limit) and (shift(diff,-2) lt -limit))

  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6)

    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind+5]
      ;signal[ind+4] = signal[ind+5]
      n_pulses = n_pulses+n_elements(ind)
    endif
  endif

  ;one point peak in deriv one up, one dow n

  ind = where((diff ge limit) and (shift(diff,-1) lt -limit))

  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6)

    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind-1]
      signal[ind+2] = signal[ind+4]
      signal[ind+3] = signal[ind+4]
     ; the third is still affected

      n_pulses = n_pulses+n_elements(ind)
    endif
  endif
endif   ; MAST BES


; TEXTOR
If data_source eq 25 then begin

  diff = signal[1:n_elements(signal)-1]-signal[0:n_elements(signal)-2]
  n_pulses = 0

if (0) then begin

 ; Shape of a radiation pulses
 pulse = [0,1,0.55,0.25,0.1,0]
 pulse1 = [0.,0.75,1.,0.5,0]

 ; The time derivative of the pulse
 d_pulse = pulse[1:n_elements(pulse)-1]-pulse[0:n_elements(pulse)-2]
 d_pulse1 = pulse1[1:n_elements(pulse1)-1]-pulse1[0:n_elements(pulse1)-2]

 ; convolving the time derivative with the time derivative of the pulse
 diff_c = convol(diff,d_pulse)
 diff_c1 = convol(diff,d_pulse1)

 ; This is a convolution-based method
 ; Creating a mask to mark elements which are affected by pulses
 mask = lonarr(n_elements(signal),/nozero)
 mask[*] = 1
 ind = where((diff_c gt limit) or (diff_c1 gt limit))
 if (ind[0] ge 0) then begin
   mask[ind] = 0
   ; marking also elements one before and one after
   mask[(ind-1)>0] = 0
   mask[(ind+1)<(n_elements(mask)-1)] = 0
   ind_mask = where(mask ne 0)
   ; Index array for the elements of the signal
   ind_sel = lindgen(n_elements(signal))
   ; Keeping only the unaffected elements
   ind_sel_mask = ind_sel[ind_mask]
   signal_mask = signal[ind_mask]
   signal = interpol(signal_mask,ind_sel_mask,ind_sel,/quadratic)
   n_pulses = float(n_elements(signal)-n_elements(signal_mask))/2
 endif
 endif

  if (1) then begin
  ; This method looks for certain pulse shapes

  mask = lonarr(n_elements(signal),/nozero)
  mask[*] = 1

  if (subchannel eq 0) then begin

  ; Drop points when diff is one up, one down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      mask[ind+1] = 0
      mask[ind+2] = 0
      mask[ind+3] = 0
    endif
  endif

  ; Drop points with two up and one down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) ge limit) and (shift(diff,-3) lt -limit) )
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-7)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      mask[ind+1] = 0
      mask[ind+2] = 0
      mask[ind+3] = 0
      mask[ind+4] = 0
    endif
  endif

  ; Drop points with one up and two down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) lt -limit) and (shift(diff,-3) lt -limit) )
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-7)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      mask[ind+1] = 0
      mask[ind+2] = 0
      mask[ind+3] = 0
      mask[ind+4] = 0
    endif
  endif

  ; Drop points with one up, one within limit, one down
  ind = where((shift(diff,-1) ge limit) and (shift(abs(diff),-2) lt limit) and (shift(diff,-3) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-7)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      mask[ind+1] = 0
      mask[ind+2] = 0
      mask[ind+3] = 0
      mask[ind+4] = 0
    endif
  endif

 ind_mask = where(mask ne 0)
 if (n_elements(ind_mask) ne n_elements(mask)) then begin
   ; Index array for the elements of the signal
   ind_sel = lindgen(n_elements(signal))
   ; Keeping only the unaffected elements
   ind_sel_mask = ind_sel[ind_mask]
   signal_mask = signal[ind_mask]
   signal = interpol(signal_mask,ind_sel_mask,ind_sel,/quadratic)
   n_pulses = float(n_elements(signal)-n_elements(signal_mask))/2
 endif


  endif else begin  ; subchannel
  ; This part is designed for subchannels where samples are already summed ou for samples in one deflection period
  ; Drop points when diff is tow up, two down (this is for interpolated fast chopping signals
   ind = where((shift(diff,-1) ge limit) and  (shift(diff,-2) ge limit) and (shift(diff,-3) lt -limit) and (shift(diff,-4) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      mask[ind+2] = 0
      mask[ind+3] = 0
      mask[ind+4] = 0
    endif

   ind_mask = where(mask ne 0)
 if (n_elements(ind_mask) ne n_elements(mask)) then begin
   ; Index array for the elements of the signal
   ind_sel = lindgen(n_elements(signal))
   ; Keeping only the unaffected elements
   ind_sel_mask = ind_sel[ind_mask]
   signal_mask = signal[ind_mask]
   signal = interpol(signal_mask,ind_sel_mask,ind_sel)
   n_pulses = float(n_elements(signal)-n_elements(signal_mask))/2
 endif

  endif  ; else subchannel = 0


 endelse

endif



endif  ; TEXTOR Li-BES


if (data_source eq '') then begin
  ; unknown data source: single pulses are assumed
  diff = signal[1:n_elements(signal)-1]-signal[0:n_elements(signal)-2]
  n_pulses = 0

  ; Drop points when diff is one up, one down
  ind = where((shift(diff,-1) ge limit) and (shift(diff,-2) lt -limit))
  if (ind[0] ge 0) then begin
    indind = where(ind < n_elements(d)-6)
    if (indind[0] ge 0) then begin
      ind = ind[indind]
      signal[ind+1] = signal[ind]
      signal[ind+2] = signal[ind]
      signal[ind+3] = signal[ind+4]
     n_pulses = n_pulses+n_elements(ind)
    endif
  endif

  return
endif  ; unknown data source


end