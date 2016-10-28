;+
; Name: pg_retrigger
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2004.09.30.
;
; Purpose: Shift signal in time with a fraction of the sample time
;
; Calling sequence:
;	xx=pg_retrigger(x, fraction)
;
; Input:
;	x: data vector
;	fraction: time2=time1-fraction*sampletime
;
; Output:
;	xx: timeshifted data vector
;
;-

function pg_retrigger, xfix, fractionfix

x=xfix
fraction=fractionfix
xsize=n_elements(x)

xfft=fft(x,-1)

fftbw=xsize/2d

phase=dblarr(xsize)

phase[0:ceil(fftbw)-1]=fraction*findgen(ceil(fftbw))/(floor(fftbw))*!PI
phase[xsize-floor(fftbw):xsize-1]=fraction*(findgen(floor(fftbw))-floor(fftbw))/floor(fftbw)*!PI

xxfft=xfft*exp(-1*dcomplex(0,phase))

xx=float(fft(xxfft,1))

return, xx

end
