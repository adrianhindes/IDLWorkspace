;+
; Name: pg_resample
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2004.09.23.
;
; Purpose: Fast resampling using Shannon, Whittaker sampling theorem
;
; Calling sequence:
;	xx=pg_resample(x, ttsize)
;
; Input:
;	x: data vector
;	ttsize: resampled size
;
; Output:
;	xx: resampled data vector
;
; Switches:
; time_domain: resampling in time domain (it takes up a lot of time, because
;              the double for loop)
;-

function pg_resample, xfix, ttsizefix, time_domain=time_domain

time_domain=keyword_set(time_domain)

x=double(xfix)
ttsize=ttsizefix

tsize=n_elements(x)

if tsize GT ttsize then print,'Reduced frequency bandwidth!'

if time_domain then begin

  xx=dindgen(ttsize)*0  ;initialize xx vector
  frac_sampl_time=double(tsize-1)/double(ttsize-1)  ;the fraction of the old and new sampling time

;resampling
  for t=0,ttsize-1 do begin
    for n=0,tsize-1 do begin
      xx(t)=xx(t)+x(n)*sinc(t*frac_sampl_time-n)
    end
  end

endif else begin

  xfft=fft(x,-1)
  xxfft=dcomplexarr(ttsize)

  fftbw=min([floor(ttsize/2d),floor(tsize/2d)])

  xxfft[0:fftbw]=xfft[0:fftbw]
  xxfft[ttsize-fftbw:ttsize-1]=xfft[tsize-fftbw:tsize-1]

  xx=double(fft(xxfft,1))

endelse

return, xx

end
