;=======================================================================================
;
;  This function calculates the biased or unbiased correlation/covariance between 
;       input signal X and Y.
;  This is modified version of IDL c_correlate to accommodate unbiased correlation.
;  Usual IDL c_correlate only calcualtes biased correlation/covariance.
;
;=======================================================================================
;
;<Input parameters>
;  1. X: <1D floating array> contains the signal X
;  2. Y: <1D floating array> contains the signal Y
;  3. Lag: <1D Long Array> contains the indices for the lag
;  4. Unbiased: If set, then correlation/covariance is calculated with unbiased normalization factor.
;  5. Const_npts: If set, then use the same number of data points for different time lags.
;                 Note: If this keyword is set, then Unbiased keyword does not matter because 
;                       the number of data points for each Lag is always the same.
;                       i.e. It will always calculate the unbiased covariance/correlation.
;  6. inx_Ycenter: <long> If Const_npts is set, then inx_Ycenter is advised to be provided.
;                         However, inx_Ycenter is not provided with Const_npts set, then 
;                                  inx_Ycenter is assumed to be 0.
;                         This is the index of Y where X[0:nX-1]*Y[inx_Ycenter:inx_Ycenter+nX-1] corresponds to the
;                                              zero time-lag covariance/correlation. 
;  7. Covariance: If set, then covariance is calculated.
;  8. Double: If set, then the calculation is done with double precision. 
;
;=======================================================================================
;
;<Output result>  
;  Correlation/Covariance array
;
;=======================================================================================


function yc_correlate, X, Y, Lag, Unbiased = Unbiased, Const_npts = Const_npts, inx_Ycenter = in_inx_Ycenter, $ 
                                  Covariance = Covariance, Double = doubleIn

  compile_opt idl2
  on_error, 2

  typeX = SIZE(X, /TYPE)
  typeY = SIZE(Y, /TYPE)
  nX = N_ELEMENTS(X)
  nY = N_ELEMENTS(Y)

; check length
  if ( (nX lt 2) or (nY lt 2) ) then $
    MESSAGE, "X and Y arrays must contain 2 or more elements."

; check the keywords
  if KEYWORD_SET(Const_npts) then begin
    if not KEYWORD_SET(in_inx_Ycenter) then $
      inx_Ycenter = 0L $
    else $
      inx_Ycenter = LONG(in_inx_Ycenter)

    min_Lag = MIN(Lag, MAX = max_Lag)
    if (inx_Ycenter + min_Lag) lt 0 then $
      MESSAGE, "Y arrays are too small to calculate requested Lags."
    if (inx_Ycenter + nX + max_Lag) gt nY then $
      MESSAGE, "Y arrays are too small to calculate requested Lags."

  endif else begin
    if (nX ne N_ELEMENTS(Y)) then $
      MESSAGE, "X and Y arrays must have the smae number of elements."
  endelse

  isComplex = (typeX eq 6) or (typeX eq 9) or (typeY eq 6) or (typeY eq 9)

;If the DOUBLE keyword is not set, then the internal precision and results are identical to the type of input.
  useDouble = (N_ELEMENTS(doubleIn) eq 1) ? KEYWORD_SET(doubleIn) : (typeX eq 5 or typeY eq 5) or (typeX eq 9 or typeY eq 9)

  nLag = N_ELEMENTS(Lag)
  Cross = useDouble ? (isComplex ? DCOMPLEXARR(nLag) : DBLARR(nLag)) : (isComplex ? COMPLEXARR(nLag) : FLTARR(nLag))

  if KEYWORD_SET(Const_npts) then begin
    Xd = X - TOTAL(X, Double = useDouble) / nX	;Deviations in X
    for k = 0L, nLag - 1 do begin
      inx_Ystart = inx_Ycenter + Lag[k]
      inx_Yend = inx_Ystart + nX - 1
      temp_Y = REFORM(Y[inx_Ystart:inx_Yend])
      Yd = temp_Y - TOTAL(temp_Y, Double = useDouble) / nX	;Deviatinos in Y
      Cross[k] = TOTAL(Xd * Yd) / nX
      if NOT KEYWORD_SET(Covariance) then begin
      ;Covariance keyword is NOT set, thus calcualte correlations.
      ;If TOTAL(Xd^2)*TOTAL(Yd^2) is 0, then Cross[k] = 0.0 since normalization cannot be performed. i.e. dividing by 0.0 is not defined.
        norm = SQRT(TOTAL(Xd^2)*TOTAL(Yd^2))/nX
        if norm eq 0.0 then $
          Cross[k] = 0.0 $
        else $
          Cross[k] = Cross[k] / norm
      endif
    endfor
  endif else begin
    Xd = X - TOTAL(X, Double = useDouble) / nX 	;Deviations in X
    Yd = Y - TOTAL(Y, Double = useDouble) / nX	;Deviations in Y
    if KEYWORD_SET(Unbiased) then begin
      for k = 0L, nLag - 1 do begin
      ;normalisation factor is different from IDL c_correlate.
      ;this procedures procides a 'unbiased' correlation values.
        Cross[k] = (Lag[k] ge 0) ? $
                   TOTAL(Xd[0:nX-Lag[k]-1L] * Yd[Lag[k]:*])/(nX-ABS(Lag[k])) : $
                   TOTAL(Yd[0:nX+Lag[k]-1L] * Xd[-Lag[k]:*])/(nX-ABS(Lag[k]))
      endfor
    endif else begin
      for k = 0L, nLag - 1 do begin
      ;normalisation factor is same as IDL c_correlate.
      ;this procedures procides a 'biased' correlation values.
        Cross[k] = (Lag[k] ge 0) ? $
                   TOTAL(Xd[0:nX-Lag[k]-1L] * Yd[Lag[k]:*])/nx : $
                   TOTAL(Yd[0:nX+Lag[k]-1L] * Xd[-Lag[k]:*])/nx
      endfor
    endelse

    if NOT KEYWORD_SET(Covariance) then begin
    ;Covariance keyword is NOT set, thus calcualte correlations.
    ;If TOTAL(Xd^2)*TOTAL(Yd^2) is 0, then Cross[*] = 0.0 since normalization cannot be performed. i.e. dividing by 0.0 is not defined.
      norm = SQRT(TOTAL(Xd^2)*TOTAL(Yd^2))/nX
      if norm eq 0.0 then $
        Cross[*] = 0.0 $
      else $
        Cross = TEMPORARY(Cross) / norm
    endif
  endelse

  return, useDouble ? Cross : $
                      (isComplex ? COMPLEX(Cross) : FLOAT(Cross))

end