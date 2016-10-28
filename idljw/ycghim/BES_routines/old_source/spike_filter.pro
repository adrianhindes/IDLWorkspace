
function spike_filter, signal, thresh, debug=debug

; Radiation 'spike' filter based on RMKI algorithm coded in 'mast_filter.pro'
; written as subroutine by ARF on 17.01.12

  default, debug, 0

; Save original signal
  fsignal=signal

; Differentiate signal
  diff = deriv(fsignal)

; Number of filtered pulses
  n_pulses = 0

; One point where diff > thresh, one mid-point and either of next two with diff < -thresh
  ind = where((diff ge thresh) and ((shift(diff, -2) lt -thresh) or (shift(diff, -3) lt -thresh)), count)

  if count gt 0 then begin

    if debug then begin
      window, 0
      plot, diff[ind[0]-5:ind[0]+5], yr=[-.6, .6]
      for i=1, n_elements(ind)-1 do $
        oplot, diff[ind[i]-5:ind[i]+5]
    endif

    if (ind[0] ge 0) then begin

      indind = where(ind < n_elements(diff)-6)

; Replace points 1 and 2 with point just before spike and 3 and 4 with point after

      if (indind[0] ge 0) then begin
        ind = ind[indind]
        fsignal[ind+1] = fsignal[ind]
        fsignal[ind+2] = fsignal[ind]
        fsignal[ind+3] = fsignal[ind+5]
        fsignal[ind+4] = fsignal[ind+5]
        n_pulses = n_pulses+n_elements(ind)
      endif

    endif

    if debug then begin
      window, 1
      plot, fsignal[ind[0]-5:ind[0]+5], yr=[-2., 0.]
      for i=1, n_elements(ind)-1 do $
        oplot, fsignal[ind[i]-5:ind[i]+5]
      for i=0, n_elements(ind)-1 do $
        oplot, signal[ind[i]-5:ind[i]+5]
    endif

  endif

  if debug then stop

; One point where diff > thresh and either of next two where diff < -thresh
  ind = where((diff ge thresh) and ((shift(diff, -1) lt -thresh) or (shift(diff, -2) lt -thresh)), count)

  if count gt 0 then begin

    if debug then begin
      window, 0
      plot, diff[ind[0]-5:ind[0]+5], yr=[-.6, .6]
      for i=0, n_elements(ind)-1 do $
        oplot, diff[ind[i]-5:ind[i]+5]
    endif

    if (ind[0] ge 0) then begin

      indind = where(ind < n_elements(diff)-6)

; Replace points 1 with point just before spike and 2 and 3 with point after

      if (indind[0] ge 0) then begin
        ind = ind[indind]
        fsignal[ind+1] = fsignal[ind]
        fsignal[ind+2] = fsignal[ind+4]
        fsignal[ind+3] = fsignal[ind+4]
        n_pulses = n_pulses+n_elements(ind)
      endif

    endif

    if debug then begin
      window, 1
      plot, fsignal[ind[0]-5:ind[0]+5], yr=[-2., 0.]
      for i=1, n_elements(ind)-1 do $
        oplot, fsignal[ind[i]-5:ind[i]+5]
      for i=0, n_elements(ind)-1 do $
        oplot, signal[ind[i]-5:ind[i]+5]
    endif

  endif

  if debug then stop

  return, fsignal
  
end