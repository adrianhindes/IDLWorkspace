
PRO magpie_bicoherency, freq_filter=freq_filter, subwindow_npts=subwindow_npts, time_resolution=time_resolution, $
                     trange = trange, overlap=overlap, han=han, subtract_mean=subtract_mean

;all the input parameters are described as bispectrum.pro except
; shotnumber: <long> : KSTAR shotnumber
; ch: <string> : BES channels number, e.g.c '1-1', '3-4'
; time_resolution: <floating> in [sec] : time resolution for the bicoherency
; time_window: <two element vector> in [sec]: [tstart, tend]

  default, trange, [0.000, 0.300];+0.01
;  default, trange, [0.02, 0.04]
  default, time_resolution, 0.300
    
;  shot_number = 88620
; shot_number 87770, 87783, 87788, 88665, 88667, 88537(3-5)!!!!, 88527 fork->87775
  shot_number =  3673;;2740 ;2065;670      3445??? 3673????
;  d1 = magpie_data('probe_isat', shot_number)
;  d2 = magpie_data('probe_vfloat', shot_number)
;  d3 = magpie_data('single_pmt', shot_number)
  d1 = phys_quantity(shot_number)
  diag_data3 = d1.vplasma
  diag_time3 = d1.tvector
  diag_data1 = d1.isat
  diag_time1 = d1.tvector
  diag_data2 = d1.isat_rot
  diag_time2 = d1.tvector

  
  d1 = select_time(diag_time1,diag_data1,trange)
  d2 = select_time(diag_time2,diag_data2,trange)
  d3 = select_time(diag_time3,diag_data3,trange)

;;;;;;;;;;; test ;;;;;;;;;;;;;;;
;  dt = 0.000001
;  d1 = test_signal(trange, dt)
;  diag_time1 = d1.tvector
;  diag_data1 = d1.yvector
;  diag_time2 = d1.tvector
;  diag_data2 = d1.yvector
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  
; Frequency filter the signal
  dt = d1.tvector[1]-d1.tvector[0]
;  t_size = round(time_resolution/dt)
;  fs = 1.0/dt
;  df = 1.0/(n_elements(d1.tvector)*dt)
;  freq_vector = (dindgen(fs/df)-floor(fs/df/2))*df
;
;  high_pass = freq_filter[0]/(fs/2)
;  low_pass = freq_filter[1]/(fs/2)

  ntvector = (trange[1]-trange[0])/time_resolution
  tvector = d1.tvector

; Generate bicoherency

  i=0
  inx = WHERE( (diag_time1 GE (trange[0]+i*time_resolution)) AND $
        (diag_time1 LT (trange[0]+(i+1)*time_resolution)) )
  t_size = n_elements(inx)

  for i=0L, ntvector-1 do begin
    str = string(i+1, format='(i0)') + '/' + string(ntvector, format='(i0)')
    PRINT, str
    inx = inx+i*t_size
    signal1 = diag_data1[inx]
    signal2 = diag_data2[inx]
    signal3 = diag_data3[inx]
    temp_bicohe = jw_bispectrum(signal3, signal3, signal3, dt, freq_filter=freq_filter, subwindow_npts=512L, overlap=overlap, han=han, $
                             subtract_mean=subtract_mean, /verbose, plot_bispec=0, plot_bicohe=1, plot_power=1)
    print, 'signal # : ',n_elements(signal)
    if i eq 0 then begin
      freqx = temp_bicohe.freqx
      freqy = temp_bicohe.freqy
      bicohe = FLTARR(N_ELEMENTS(freqx), N_ELEMENTS(freqy), ntvector)
      bicohe_noise = FLTARR(ntvector)
    endif    
    bicohe[*, *, i] = temp_bicohe.bicoherency
    bicohe_noise[i] = temp_bicohe.bicoherency_noise_floor
  endfor

 ycshade, bicohe, freqx, freqy
 ycplot, diag_time, diag_data

END
