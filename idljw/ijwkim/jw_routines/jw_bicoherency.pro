
PRO jw_bicoherency, freq_filter=freq_filter, subwindow_npts=subwindow_npts, time_resolution=time_resolution, $
                     trange = trange, overlap=overlap, han=han, subtract_mean=subtract_mean

;all the input parameters are described as bispectrum.pro except
; shotnumber: <long> : KSTAR shotnumber
; ch: <string> : BES channels number, e.g.c '1-1', '3-4'
; time_resolution: <floating> in [sec] : time resolution for the bicoherency
; time_window: <two element vector> in [sec]: [tstart, tend]

  default, trange, [0.005, 0.045];+0.04;+0.01
;  default, trange, [0.02, 0.04]
  default, time_resolution, 0.020
    
;  shot_number = 88620
;  shot_number 87770, 87783, 87788, 88665, 88667, 88537(3-5)!!!!, 88527 fork->87775 something: 89504 ; 89899!!!
  shot_number = 90019;89988;89912;89901;87783;89691;89897;88665;89889;89571;88527
  a = getpar(shot_number,'isatfork',y=y1,tw=trange)
  b = getpar(shot_number,'vfloat',y=y2,tw=trange)
  c = getpar(shot_number,'mirnov',y=y3,tw=trange)
  diag_data1 = y1.v
  diag_time1 = y1.t
  diag_data2 = y2.v
  diag_time2 = y2.t
  diag_data3 = y3.v
  diag_time3 = y3.t

  
  d1 = jw_select_time(diag_time1,diag_data1,trange)
  d2 = jw_select_time(diag_time2,diag_data2,trange)
  d3 = jw_select_time(diag_time3,diag_data3,trange)

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
    temp_bicohe = jw_bispectrum(signal1, signal1, signal1, dt, freq_filter=freq_filter, subwindow_npts=512L, overlap=overlap, han=han, $
                             subtract_mean=subtract_mean, /verbose, plot_bispec=0, plot_bicohe=1, plot_power=0)
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
 
 bicohe_dim = size(bicohe,/dimension)
 bicohe_sim = dblarr(size(bicohe,/dimension))

 sum_bicohe = dblarr(size(freqx,/n_elements)*2L-1L)
 sum_freq = dblarr(size(freqx,/n_elements)*2L-1L)
 for i =0L, size(freqx,/n_elements)*1L-1L do begin
  j=0L
  index_a = dblarr(size(freqx,/n_elements)-floor((i+1.0)/2.0))
  index_b = dblarr(size(freqx,/n_elements)-floor((i+1.0)/2.0))
  a=0
  b=0
  while a le size(freqx,/n_elements)-2L do begin
    a = floor((i+1.0)/2.0)+j
    b = floor(i/2.0)-j
    index_a[j] = a
    index_b[j] = b
    j++
  endwhile
;  print, index_a
;  print, index_b+size(freqx,/n_elements)
  sum_bicohe[i] = total(bicohe[index_a,index_b+size(freqx,/n_elements)])/size(index_a,/n_elements)
  bicohe_sim[index_a,index_b+size(freqx,/n_elements)] = bicohe[index_a,index_b+size(freqx,/n_elements)]
  sum_freq[i] = (freqx[1]-freqx[0])*i
 endfor
 
 ycplot, sum_freq[where(sum_freq lt 300e3)], sum_bicohe[where(sum_freq lt 300e3)];, /ylog
  ycshade, bicohe_sim, freqx, freqy
 
; print, sum_freq[where(sum_freq lt 300e3)]
; print ,sum_bicohe[where(sum_freq lt 300e3)]
 
; sum_bicohe = 

END
