pro chirp_analysis_discrete

;Input:
trange = [0.63, 0.68]	; Time interval of interest
freq_max = 100.		; Downsampling data to this value [in kHz]
filter = [55., 100.]	; Filtering data under this frequency using FFT [in kHz]
blocksize = 512	; Blocksize
hann = 1		; Use Hanning window
denoise = 0.0		; Filtering WTN transform
downsampling = 0	; Downsmapling

;Restore data saved with MTR (via NTI Wavelet Tools)
restore, 'AUGD_28881_SXR_0.6s-0.7s.sav'

;Number of channels:
chnum = n_elements(channels)

;Cut ROI
data = data(where((timeax ge trange(0)) AND (timeax le trange(1))),*)
timeax = timeax(where((timeax ge trange(0)) AND (timeax le trange(1))))

;Downsampling
;(Dimensions of data vector must be powers of 2 for WTN transform)
if downsampling then begin
  length = n_elements(timeax)
  pow = floor(alog(length)/alog(2))
  data_resampled = fltarr(2.^pow, chnum)
  for i = 0, chnum-1 do begin
    data_resampled(*,i) = pg_resample(reform(data(*,i)),2.^pow)
  endfor
  timeax_resampled = timeax(0) + findgen(2.^pow)/(2.^pow-1)*(timeax(n_elements(timeax)-1) - timeax(0))	; New time axis
endif else begin
  data_resampled = data
  timeax_resampled = timeax
endelse

;Create frequency axis
freqax_resampled = findgen(floor(n_elements(data_resampled(*,0))/2.) + 1)
freqax_resampled = freqax_resampled/max(freqax_resampled)
dt = (timeax_resampled(n_elements(timeax_resampled)-1) - timeax_resampled(0))/(n_elements(timeax_resampled)-1)
fn = (1./dt/2.)
freqax_resampled = freqax_resampled*fn/1d3;	[in kHz]

;FFT filter
data_filtered = fltarr(n_elements(timeax_resampled), chnum)
for i = 0, chnum-1 do begin
  fft_data = fft(data_resampled(*,i))

  ;High pass filter
  ind = where(min((freqax_resampled-filter(0)), /abs) eq (freqax_resampled-filter(0)))	; where filter equals to freqax
  fft_data(0:ind-1) = complex(0)
  fft_data(n_elements(fft_data) - ind + 1:*) = complex(0)

  ;Low pass filter
  ind = where(min((freqax_resampled-filter(1)), /abs) eq (freqax_resampled-filter(1)))	; where filter equals to freqax
  fft_data(ind+1:n_elements(fft_data)-ind - 1) = complex(0)

  data_filtered(*,i) = fft(fft_data , /inverse)
  timeax_filtered = timeax_resampled
  freqax_filtered = freqax_resampled
endfor

;Denoising (using WTN transform)
data_wtn_filtered = data_filtered
if not(denoise eq 0) then begin
  for i = 0, chnum-1 do begin
    wtn_transform = wtn(data_filtered(*,i), 4)
    wtn_transform(where(abs(wtn_transform) lt denoise*abs(max(wtn_transform, /abs)))) = 0.
    data_wtn_filtered(*,i) = wtn(wtn_transform, 4, /inverse)
  endfor
endif
timeax_wtn_filtered = timeax_filtered

;Save data
data_tmp = data
data = data_wtn_filtered
timeax_tmp = timeax
timeax = timeax_wtn_filtered

save, filename = 'AUGD_28881_SXR_0.6s-0.7s_filtered.sav', $
  channels, coord_history, data, data_history, expname, phi, shotnumber, theta, timeax

data = data_tmp
timeax = timeax_tmp

;Create indices of channel pairs
channelpairs = intarr(2, (chnum*(chnum-1)))
k = 0
for i = 0L, chnum-1 do begin
  for j = 0L, chnum-1 do begin
    if not(i eq j) then begin
      channelpairs(0,k) = i
      channelpairs(1,k) = j
      k = k + 1
    endif
  endfor
endfor

hl_analyse, shotnumber, channels(channelpairs(0,0)), channels(channelpairs(1,0)),$
    blocksize = blocksize, hann = hann, timeax1 = timeax_filtered, timeax2 = timeax_filtered, $
    data1 = data_filtered(*,channelpairs(0,0)), data2 = data_filtered(*,channelpairs(1,0)), $
    ID = channels(channelpairs(0,0))+'-'+channels(channelpairs(1,0)), timp = timp, imp = imp, ccf = ccf

    timps = fltarr(n_elements(timp), n_elements(channelpairs(0,*)))
    timps(*,0) = timp
    timp = 0.
    imps = fltarr(n_elements(imp), n_elements(channelpairs(0,*)))
    imps(*,0) = imp
    imp = 0.
    ccfs = fltarr(n_elements(ccf), n_elements(channelpairs(0,*)))
    ccfs(*,0) = ccf
    ccf = 0.

;Calculate statistical functions:
for i = 1L, 0.5*n_elements(channelpairs)-1 do begin
  hl_analyse, shotnumber, channels(channelpairs(0,i)), channels(channelpairs(1,i)),$
      blocksize = blocksize, hann = hann, timeax1 = timeax_filtered, timeax2 = timeax_filtered, $
      data1 = data_filtered(*,channelpairs(0,i)), data2 = data_filtered(*,channelpairs(1,i)), $
      ID = channels(channelpairs(0,i))+'-'+channels(channelpairs(1,i)), timp = timp, imp = imp, ccf = ccf
      
      timps(*,i) = timp
      timp = 0.
      imps(*,i) = imp
      imp = 0.
      ccfs(*,i) = ccf
      ccf = 0.

endfor


pg_initgraph
loadct, 5

plot, timps(*,0), imps(*,0), psym = -7, xrange = [-0.02, 0.02], yrange = [-0.6, 1.]
oplot, timps(*,1), imps(*,1), psym = -7, color = 64
oplot, timps(*,2), imps(*,2), psym = -7, color = 128
oplot, timps(*,3), imps(*,3), psym = -7, color = 200

;for i = 0, 0.5*n_elements(channelpairs)-1 do begin
;  print, channels(channelpairs(0,i)), '-', channels(channelpairs(1,i)), timps(where( max(ccfs(*,i)) eq ccfs(*,i))) * 1000, ' us'
;endfor

stop

end