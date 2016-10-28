function signal, I, Izeta, kx


signal = I+Izeta*cos(kx)

;ifg = cos(2*!pi*20*findgen(1000)/1000.)
;print, "Phase = ", (atan(fft(signal),/phase))[20]
;abs of fft of signal = fringe
return, signal
end