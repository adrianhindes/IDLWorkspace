pro stft_bicoh_fild_test

restore, 'feature-devel\stft_bicoh_test\AUGD_26941_FILD_2.560s-2.575s.sav'

;Run nti_wavelet_main
  nti_wavelet_main,$
  ; Input
    data=data, dtimeax=timeax, chpos=[0,0], expname=expname, shotnumber=shotnumber, $
    transf_selection=1, cwt_selection=0, stft_selection=1, $
    stft_length=100, stft_fres=400, stft_step=50, $
    freq_min=0, freq_max=50, $
    crosstr_selection=0, coh_selection=0, $
    transfer_selection=0, mode_selection=0, $
    bicoh_selection=1, bicoh_avr = 5, $
    ; Output
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, transfers=transfers, modenumbers=modenumbers, qs=qs, $
    channels=channels, channelpairs_used=channelpairs_used, $
    stft_window=stft_window, bicoherences = bicoherences

;Plot result
;-----------
loadct, 5
length = (size(bicoherences))(2)
for i = 0L, length-1 do begin
  contour, abs(reform(bicoherences(0,i,*,*))), /fill, nlevels=60
  wait, 0.1
endfor
for i = 0L, length-1 do begin
  contour, abs(reform(bicoherences(1,i,*,*))), /fill, nlevels=60
  wait, 0.1
endfor

end