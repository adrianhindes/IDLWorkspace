
PRO bes_bicoherency, shotnumber, ch, $
                     freq_filter=freq_filter, subwindow_npts=subwindow_npts, time_resolution=time_resolution, $
                     time_window = time_window, overlap=overlap, han=han, subtract_mean=subtract_mean

;all the input parameters are described as bispectrum.pro except
; shotnumber: <long> : KSTAR shotnumber
; ch: <string> : BES channels number, e.g.c '1-1', '3-4'
; time_resolution: <floating> in [sec] : time resolution for the bicoherency
; time_window: <two element vector> in [sec]: [tstart, tend]

  default, time_resolution, 0.05
  default, time_window, [0.0, 5.0] 

; Read the BES data
  bes_data_org = bes_read_data(shotnumber, ch)
  if bes_data_org.err LT 0 then begin
    PRINT, bes_data_org.errmsg
    RETURN
  endif

  bes_data = bes_data_org.data
  bes_time = bes_data_org.tvector
  dt = 0.5e-6

  ntvector = (time_window[1]-time_window[0])/time_resolution
  tvector = FINDGEN(ntvector)*time_resolution + time_window[0] + time_resolution/2.0

; Generate bicoherency
  for i=0L, ntvector-1 do begin
    str = string(i+1, format='(i0)') + '/' + string(ntvector, format='(i0)')
    PRINT, str
    inx = WHERE( (bes_time GE (time_window[0]+i*time_resolution)) AND $
                 (bes_time LT (time_window[0]+(i+1)*time_resolution)) )
    signal = bes_data[inx]
    temp_bicohe = bispectrum(signal, dt, freq_filter=freq_filter, subwindow_npts=subwindow_npts, overlap=overlap, han=han, $
                             subtract_mean=subtract_mean, /verbose, plot_bispec=0, plot_bicohe=0, plot_power=0 )
    if i eq 0 then begin
      freqx = temp_bicohe.freqx
      freqy = temp_bicohe.freqy
      bicohe = FLTARR(N_ELEMENTS(freqx), N_ELEMENTS(freqy), ntvector)
      bicohe_noise = FLTARR(ntvector)
    endif    
    bicohe[*, *, i] = temp_bicohe.bicoherency
    bicohe_noise[i] = temp_bicohe.bicoherency_noise_floor
  endfor

;  ycshade, 

stop

END
