;=======================================================================================
;
;  This function filters the original signal in frequency.
;
;=======================================================================================
;
;<Input parameters>
;  1. X: <1D floating array> contains the original signal to be filtered
;  2. dt: <floating> contains the time step of the data in [sec]
;  3. low_freq: <floating> contains the lower frequency cut-off for filtering in [Hz]
;  4. high_freq: <alogating> contains the higher frequency cut-off for filtering in [Hz]
;  5. graph: <keyword> If set, then graphical results is displayed comparing
;                              original and filtered signals
;
;=======================================================================================
;
;<Output result>  A structure is retured
;  results = {data:data, $
;             inx_nonzero_begin:inx_nonzero_begin, $
;	      inx_nonzero_end:inx_nonzero_end}
;
;    1. data: <1D floating array> contains the filtered signal whose number of elements is
;                                 the same as input signal, X
;    2. inx_nonzero_begin: <long>
;    3. inx_nonzero_end: <long>
;          because convol function is performed with CENTER keyword omitted, 
;          zeros are padded into the filtered_signal where i<fix(k/2) and i>(n-fix(k/2)-1)
;          where i is the index and k is the number of elements in filter_order, n is the
;          number of elements in org_signal
;
;=======================================================================================

function yc_freq_filter, X, dt, low_freq, high_freq, graph = graph

  Data = REFORM(X)
  Nyq_freq = 1.0/(2.0 * dt)	; in [Hz]

; Filtering the signal
; make sure low_freq and high_freq has meaningful numbers.
  if low_freq lt 0.0 then low_freq = 0.0
  if high_freq gt Nyq_freq then high_freq = Nyq_freq

  if low_freq eq 0.0 then $
    filter_order = (Nyq_freq/high_freq) * 1.5 $
  else $
    filter_order = (Nyq_freq/low_freq) * 1.5

  filter = digital_filter( (low_freq/Nyq_freq) > 0.0, (high_freq/Nyq_freq) < 1.0, 50, filter_order )
 
  filtered_Data = convol(Data, filter)

; because convol function is performed with CENTER keyword omitted, 
;  zeros are padded into the filtered_signal where i<fix(k/2) and i>(n-fix(k/2)-1)
;  where i is the index and k is the number of elements in filter_order, n is the
;  number of elements in org_signal
  k = n_elements(filter)
  n = n_elements(Data)
  inx_nonzero_begin = long(k/2)
  inx_nonzero_end = n - long(k/2) - 1

  result = {Data:filtered_Data, $
            inx_nonzero_begin:inx_nonzero_begin, $
            inx_nonzero_end:inx_nonzero_end}

  if KEYWORD_SET(graph) then begin
    nX = N_ELEMENTS(Data)
    fData = FFT(Data)
    fData = fData[0:nX/2]
    pData = ABS(fData * CONJ(fData))
    freq = LINDGEN(nX/2+1)/(nX*dt)

    ycplot, freq, pData, xtitle = 'Frequency [Hz]', ytitle = 'Power', title = 'Spectrum', /ylog, $
            legend = 'Original Data', out_base_id = oid

    fData = FFT(filtered_Data)
    fData = fData[0:nX/2]
    pData = ABS(fData * CONJ(fData))

    ycplot, freq, pData, oplot_id = oid, legend = 'Filtered Data'

    ycplot, [low_freq, low_freq], [min(pData, /nan), max(pData, /nan)], legend_item = 'Low Freq Cutoff', oplot_id = oid
    ycplot, [high_freq, high_freq], [min(pData, /nan), max(pData, /nan)], legend_item = 'High Freq Cutoff', oplot_id = oid
  endif

  RETURN, result

end