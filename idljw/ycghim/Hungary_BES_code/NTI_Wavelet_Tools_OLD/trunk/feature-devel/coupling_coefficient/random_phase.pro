;+
; NAME:
;	RANDOM_PHASE
;
; PURPOSE:
;	This procedure generate a harmonic oscillator with alternating phase.
;	More details in --http://deep.reak.bme.hu/~horla/download/2010_Horvath_TDK.pdf--
;
; CALLING SEQUENCE:
;	RANDOM_PHASE
;
; INPUTS:
;	dev:		the standard deviation of linear part of the phases
;	trange:		the time range of the reruned signal
;	sfreq:		the sample frequency
;	length:		the length of the window, where the phase is linerar
;
; OUTPUTS:
;	return value:	returns a vector with the phases
;	timeax:		the time axis of the retuned signal
;
; EXAMPLE:
;	result = random_phase(dev = 3d-1, trange = [0d, 1d-2], sfreq = 2d6, length = 50)
;
;-

function random_phase, dev = dev, trange = trange, sfreq = sfreq, length = length, timeax = timeax

;Setting defaults:
default, dev, 3d-1
default, trange, [0d, 1d-2]
default, sfreq, 2d6
default, length, 50

;Calculate timeax:
n = (trange(1) - trange(0))*sfreq
timeax = dindgen(n+1)/n*trange(1)

;Calculate number of windows:
wnum = long(floor(n/length))

;Calculate timeax of a window:
dt=(dindgen(length)+1)/sfreq

;Caulculate, random phases:
dphase=dev*randomn(seed,wnum,/NORMAL)

;Initialize vector of pahses:
phase=dindgen(n+1)*0
phase[0]=0

;Calculate the phases of the firs window:
phase[0:length-1] = dphase[0]*dt

;Calculate phases:
for i=1L,wnum-1 do begin
    phase[i*length:(i+1)*length-1]= phase[i*length-1]+dphase[i]*dt
end

;Return the result:
return, phase

end