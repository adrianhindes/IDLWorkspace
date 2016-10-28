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

x=xfix
ttsize=ttsizefix

time_domain=keyword_set(time_domain)
tsize=n_elements(x)

type = size(x, /type)

case type of 
    4: double = 0
    5: double = 1
    else: begin
      print, "Invalid type of argument!'
    end
endcase

if tsize GT ttsize then print,'Reduced frequency bandwidth!'


;RESAMPLING IN TIME DOMAIN:
;-------------------------
if time_domain then begin

  if double then begin	;initialize xx vector
    xx=dindgen(ttsize)*0
  endif else begin
    xx=findgen(ttsize)*0
  endelse

  frac_sampl_time=double(tsize-1)/double(ttsize-1)  ;the fraction of the old and new sampling time

;resampling
  for t=0,ttsize-1 do begin
    for n=0,tsize-1 do begin
      xx(t)=xx(t)+x(n)*nti_wavelet_sinc(t*frac_sampl_time-n)
    end
  end


;RESAMPLING IN FREQUENCY DOMAIN:
;------------------------------
endif else begin

  ;CHECK PRIME FACTORS OF VECTORS's LENGTH:
  sum_prime_factors = total(nti_wavelet_prime_factor(n_elements(x)))
  if ((sum_prime_factors ge 5d4) and (sum_prime_factors lt 1d5)) then begin
    print, "--- WARNING! ---"
    print, "Resampling can run even 2 minutes, because the large prime factors of data vector's length!"
    print, "The prime factors of data vector's length:"
    print, nti_wavelet_prime_factor(n_elements(x))
    print, "Working ..."
  endif
  if (sum_prime_factors ge 1d5) then begin
    print, "--- WARNING! ---"
    print, "Resampling can run at least 2 minutes, even several hours because the large prime factors of data vector's length!"
    print, "The prime factors of data vector's length:"
    print, nti_wavelet_prime_factor(n_elements(x))
    print, "Working ..."
  endif

  xfft=fft(x,-1, double = double)
  xxfft=dcomplexarr(ttsize)

  fftbw=min([floor(ttsize/2d),floor(tsize/2d)])

  xxfft[0:fftbw]=xfft[0:fftbw]
  xxfft[ttsize-fftbw:ttsize-1]=xfft[tsize-fftbw:tsize-1]

  if double then begin
    xx=double(fft(xxfft,1, double = double))
  endif else begin
    xx=float(fft(xxfft,1, double = double))
  endelse

endelse

return, xx

end
