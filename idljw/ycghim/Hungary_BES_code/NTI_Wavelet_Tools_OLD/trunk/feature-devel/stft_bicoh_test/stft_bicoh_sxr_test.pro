pro stft_bicoh_sxr_test, print = print

nti_wavelet_default, print, 1

;Load data
restore, 'feature-devel\stft_bicoh_test\AUGD_24006_SXR-J_053-1.58s-1.68s.sav'

;Parameters
stft_length=50
stft_fres=200
stft_step=200
freq_min=0
freq_max=50
bicoh_avr = 30

;Run nti_wavelet_main
  nti_wavelet_main,$
  ; Input
    data=data, dtimeax=timeax, chpos=[0,0], expname=expname, shotnumber=shotnumber, $
    transf_selection=1, cwt_selection=0, stft_selection=1, $
    stft_length=stft_length, stft_fres=stft_fres, stft_step=stft_step, $
    freq_min=freq_min, freq_max=freq_max, $
    crosstr_selection=0, coh_selection=0, $
    transfer_selection=0, mode_selection=0, $
    bicoh_selection=1, bicoh_avr = bicoh_avr, $
    ; Output
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, transfers=transfers, modenumbers=modenumbers, qs=qs, $
    channels=channels, channelpairs_used=channelpairs_used, $
    stft_window=stft_window, bicoherences = bicoherences

;Save result
;-----------
save, data, timeax, freqax, expname, shotnumber, stft_window, stft_length, stft_fres, stft_step, $
    freq_min, freq_max, bicoh_avr, transforms, smoothed_apsds, channels, channelpairs_used, $
    bicoherences, $
    filename='feature-devel\stft_bicoh_test\AUGD_24006_SXR-J_053-1.58s-1.68s_bicoherence.sav'

;Print result
;------------

if print then begin
  
  stft_bicoh_plot, bicoherences=bicoherences, timeax=timeax, freqax=freqax, $
  times=[1.64,1.65], freqs=freqs, $
  expname=expname, shotnumber=shotnumber, channels=channels, $
  stft_window=stft_window, stft_length=stft_length, $
  stft_fres=stft_fres, stft_step=stft_step, $
  bicoh_avr=bicoh_avr

endif else begin

;Plot result
;-----------
  loadct, 5
  length = (size(bicoherences))(2)
  for i = 0L, length-1 do begin
    contour, abs(reform(bicoherences(0,i,*,*))), freqax, freqax(0:n_elements(freqax)/2-1), $
    xrange=[0,freq_max], xtitle='Frequency1 [kHz]', ytitle='Frequency2 [kHz]', /fill, nlevels=60, $
    charsize=2,charthick=2
    xyouts, 0.25, 0.83, pg_num2str(timeax(i))+' s',charsize=2,charthick=2, /normal
    xyouts, 0.7, 0.83, expname+' #'+nti_wavelet_i2str(shotnumber)+'!C !C'+channels(0),charsize=1.5,charthick=2, /normal
    wait, 0.5
  endfor

  window,1
  i=30
  contour, abs(reform(bicoherences(0,i,*,*))), freqax, freqax(0:n_elements(freqax)/2-1),xrange=[0,freq_max], xtitle='Frequency1 [kHz]', ytitle='Frequency2 [kHz]', /fill, nlevels=60, charsize=2,charthick=2
  xyouts, 0.25, 0.83, pg_num2str(timeax(i))+' s',charsize=2,charthick=2, /normal
  xyouts, 0.7, 0.83, expname+' #'+nti_wavelet_i2str(shotnumber)+'!C !C'+channels(0),charsize=1.5,charthick=2, /normal

endelse



end