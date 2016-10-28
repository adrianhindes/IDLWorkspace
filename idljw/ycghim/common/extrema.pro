; This function finds the local maximum and/or minimum.
; The routine is copied from https://www.astro.washington.edu/docs/idl/cgi-bin/getpro/libarary23.html?EXTREMA


function extrema, x, $
                  min_only = mino, max_only = maxo, ceiling = ceil, threshold = tre, signature = sig, number = num
;
; NAME:
;       EXTREMA
; VERIONS:
;       3.0
; PURPOSE:
;       Finding all local minima and maxima in a vector, x.
; CALLING SEQUENCE:
;       Result = extrema(x, [, keywords])
; INPUTS:
;      X: Numerical vector, at least three elements.
; OPTIONAL INPUT PARAMETERS:
;      None.
; KEYWORD PARAMETERS:
;      /MIN_ONLY
;        Switch.  If set, EXTREMA finds only local minima.
;      /MAX_ONLY
;        Switch.  If set, EXTREMA finds only local maxima.
;      THRESHOLD
;        A nennegative value.  If provided, entries which differ by less than THRESHOLD are considered equal.
;                              Defulat value is 0.
;      /CEILING
;        Switch.  Determines how resutls for extended extrema (few consecutive elements with the same value) are returend.
;                 See explanation in OUTPUTS.
;      SIGNATURE
;        Optional outpus, see below.
;      NUMBER
;        Optional output, see below.
; OUTPUTS:
;      Returns the indices of the elements corresponding to local maxima and/or minima.  If no extrema are found, returns -1.
;      In case of extended extrema, returns midpoint index.  For example, if x = [3, 7, 7, 7, 4, 2, 2, 5] then extrema(x) = [2,5].
;      Note that for the second extremum the result was rounded downwards since (5+6)/2 = 5 in integer division.  This can be changed
;      using the keyword CEILING which forces upward rouding, i.e. extrema(x, /ceiling) = [2, 6] for x above.
; OPTIONAL OUTPUT PARAMETERS:
;     SIGNATURE
;        The name of the variable to receive the signature of the extrema, i.e. +1 for each maximum and -1 fo each minimum.
;     NUMEBR
;        the name of the variable to receive the number of extrema found.  Note that if MIN_ONLY or MAX_ONLY is set, only the minima or maxima,
;        respectively, are counted.
;
;

  ON_ERROR, 1

  siz = SIZE(x)
  if siz(0) ne 1 then $
    MESSAGE, 'X must be a vector!' $
  else if siz(1) lt 3 then $
    MESSAGE, 'At least 3 elements are needed!'

  len = siz(1)
  res = REPLICATE(0l, len)
  sig = res
  if ( KEYWORD_SET(mino) and NOT KEYWORD_SET(maxo) ) then $
    both = 0 $
  else if ( KEYWORD_SET(maxo) and NOT KEYWORD_SET(mino) ) then $
    both = 0 $
  else $
    both = 1

  cef = KEYWORD_SET(ceil)

  if KEYWORD_SET(tre) then $
    threshold = ABS(tre) $
  else $
    threshold = 0.0

  xn = [0, x[1:*]-x[0:len-2]]	;vector containing x[i] - x[i-1] from i = 1 to len-1, and xn[i] = 0.0 for i = 0.
  if threshold gt 0 then begin
    tem = WHERE(ABS(xn) lt threshold, ntem)
    if ntem gt 0 then xn[tem] = 0.0
  endif 

  xp = SHIFT(xn, -1)
  xn = xn[1:len-2]
  xp = xp[1:len-2]

  if KEYWORD_SET(mino) or both then begin
    fir = WHERE(xn lt 0 and xp ge 0, nfir) + 1
    sec = WHERE(xn le 0 and xp gt 0, nsec) + 1
    if ( (nfir gt 0) and ARRAY_EQUAL(fir, sec) ) then begin
      res[fir] = fir
      sig[fir] = -1
    endif else begin
      if nfir le nsec then begin
        for i = 0l, nfir -1 do begin
          j = (WHERE(sec ge fir[i]))[0]
          if j ne -1 then begin
            ind = (fir[i] + sec[j] + cef)/2
            res[ind] = ind
            sig[ind] = -1
          endif
        endfor
      endif else begin
        for i = 0l, nsec - 1 do begin
          j = (WHERE(fir le sec[i], nj))[(nj-1) > 0]
          if j ne -1 then begin
            ind = (sec[i] + fir[j] + cef)/2
            res[ind] = ind
            sig[ind] = -1
          endif
        endfor
      endelse
    endelse
  endif

  if KEYWORD_SET(maxo) or both then begin
    fir = WHERE(xn gt 0 and xp le 0, nfir) + 1
    sec = WHERE(xn ge 0 and xp lt 0, nsec) + 1
    if ( (nfir gt 0) and ARRAY_EQUAL(fir, sec) ) then begin
      res[fir] = fir
      sig[fir] = 1
    endif else begin
      if nfir le nsec then begin
        for i = 0l, nfir - 1 do begin
          j = (WHERE(sec ge fir[i]))[0]
          if j ne -1 then begin
            ind = (fir[i] + sec[j] + cef)/2
            res[ind] = ind
            sig[ind]  = 1
          endif
        endfor
      endif else begin
        for i = 0l, nsec - 1 do begin
          j = (WHERE(fir le sec[i], nj))[(nj-1) > 0]
          if j ne -1 then begin
            ind = (sec[i] + fir[j] + cef)/2
            res[ind] = ind
            sig[ind] = 1
          endif
        endfor
      endelse
    endelse
  endif

  res = WHERE(res gt 0, num)
  sig = sig[res > 0]

  RETURN, res

end

