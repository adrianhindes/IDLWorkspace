;+
; NAME:
;	NTI_WAVELET_RIDGE_FOLLOWER
;
; PURPOSE:
;	This procedure is following ridge in input matrix.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_RIDGE_FOLLOWER, matrix $
;	[,xrange_index] [,xaxis] [,xrange_unit] $
;	[,start_index_y] [,yaxis] [,start_y] $
;	[,bandwidth] [,index_bandwidth] $
;	[,ridge_treshold] [,ridge_index] [,ridge_unit]
;
; INPUTS:
;	matrix:	2 dimensional matrix which will be investigated
;	xrange_index:	indices of the investigated range on the x axis, a two elements array (optional)
;	xaxis:	x axis (optional)
;	xrange_unit:	investigated range on the x axis in terms of the unit of xaxis, a two elements array (optional)
;	start_index_y:	the indices of the range on the y axis where the finding procedure starts (optional)
;	yaxis:	y axis (optional)
;	start_y:	range on the y axis in terms of the unit of yaxis where the finding procedure starts (optional)
;	bandwidth:	ridge is serached between the twice of this bandwidth in terms of the unit of yaxis (optional)
;	index_bandwidth:	size of bandwidth in datapoints (optional)
;	ridge_treshold:	ridge follower stops if ampltiude falls below the saved peak value times this treshold (optional)
;
; OUTPUTS:
;	ridge_index:	results in indices
;	ridge_unit:	results in terms of the unit of yaxis
;
;-
; EXAMPLE:
;  restore, '*\AUGD_23824_Loaded-with-MTR_processed.sav'
;  ctrans = *saved_datablock.crosstransforms
;  matrix = reform(abs(ctrans(5,*,*)))
;  nti_wavelet_ridge_follower, matrix, xaxis = timeax, yaxis = freqax, xrange_unit = [1.28,1.3], start_index_y = [120,130],$
;    bandwidth = 5, ridge_index=ridge_index, ridge_unit=ridge_unit

pro nti_wavelet_ridge_follower, $
  ;Inputs:
    matrix, $
  ;Optional inputs:
    xrange_index = xrange_index, xaxis = xaxis, xrange_unit = xrange_unit, $
    start_index_y = start_index_y, yaxis = yaxis,  start_y = start_y, $
    bandwidth = bandwidth, index_bandwidth = index_bandwidth, $
    ridge_treshold = ridge_treshold,$
  ;Outputs:
    ridge_index = ridge_index, ridge_unit = ridge_unit

;Setting defaults
;----------------

  ;Starting parameters of x axis:
  if nti_wavelet_defined(xaxis) then begin
    if nti_wavelet_defined(xrange_unit) then begin
      xrange_index = [where( min(xaxis - xrange_unit(0), /abs) eq (xaxis - xrange_unit(0)) ), $
	where( min(xaxis - xrange_unit(1), /abs) eq (xaxis - xrange_unit(1)) )]
    endif else begin
      nti_wavelet_default, xrange_index, [0, (size(matrix))(1)-1]
    endelse
  endif else begin
    nti_wavelet_default, xrange_index, [0, (size(matrix))(1)-1]
  endelse

  ;Starting parameters of y axis:
  if nti_wavelet_defined(yaxis) then begin
    if nti_wavelet_defined(start_y) then begin
      start_index_y = [where( min(yaxis - start_y(0), /abs) eq (yaxis - start_y(0)) ), $
	where( min(yaxis - start_y(1), /abs) eq (yaxis - start_y(1)) )]
    endif else begin
     nti_wavelet_default, start_index_y, [0, (size(matrix))(2)-1]
    endelse
  endif else begin
    nti_wavelet_default, start_index_y, [0, (size(matrix))(2)-1]
  endelse
  
  ;Bandwidth:
  if nti_wavelet_defined(bandwidth) then begin
    dy =  (yaxis(n_elements(yaxis)-1)-yaxis(0))/(n_elements(yaxis)-1)
    index_bandwidth = round(bandwidth/dy)
  endif else begin
    nti_wavelet_default, index_bandwidth, floor(start_index_y(1) - start_index_y(1))
  endelse
  
  ;Others:
  nti_wavelet_default, ridge_treshold, 0
  
;Finding ridge
;-------------

  ;Create vector to conain indices of ridge:
  sizeof = long(n_elements(matrix(*,0)))
  ridge_index = dblarr(sizeof)

  ;Define variables containg the index of ridge in two neighboring time instances:
  x1 = long(0)
  x2 = long(0)

  ;Find starting point
  x1 = (where(matrix(xrange_index(0), start_index_y(0):start_index_y(1)) eq $
    max(matrix(xrange_index(0), start_index_y(0):start_index_y(1)))))(0)
  x1 = start_index_y(0) + x1

  cont = 1	;indicator of continuing
  i = xrange_index(0)	;starting index
  peak = 0.	;define peak
  peak_noise = 0.	;define peak in noise
  
  ;Start finding maximum in each time instance:
  while ((i lt xrange_index(1))) do begin

    ridge_index(i) = x1
    if cont then begin
      ;Save value of the actual peak:
      if (matrix(i,ridge_index(i)) gt peak) then begin
	peak = matrix(i,ridge_index(i))
	peak_noise = ridge_treshold*peak
      endif
      ;If ampltiude falls below the saved peak value times the treshold parameter, the serach is stopped:
      if (matrix(i,ridge_index(i)) lt ridge_treshold*peak) then begin
	cont = 0
      endif
    endif

    ;If cont parameter is true the ridge following algorith continues normally:
    if (cont eq 1) then begin
      x2 = (where(matrix(i+1,(x1-index_bandwidth):(x1+index_bandwidth)) eq max(matrix(i+1,(x1-index_bandwidth):(x1+index_bandwidth)))))(0)
      x2 = x1-index_bandwidth+x2

      x1 = x2
      x2 = 0
    ;If cont parameter is false, finding new ridge is started in the initial yrange:
    endif else begin
      x2 = (where(matrix(i+1,start_index_y(0):start_index_y(1)) eq max(matrix(i+1,start_index_y(0):start_index_y(1)))))(0)
      x2 = start_index_y(0) + x2

      ;New index saved only when amplitude higher than the background noise
      if (matrix(i+1,x2) lt peak_noise) then begin
	x1 = 0
	x2 = 0
      endif else begin
	x1 = x2
	x2 = 0
	peak = 0.
	cont = 1
      endelse
    endelse

    i = i + 1
  endwhile

;Record last point:
ridge_index(i) = x1

;Calculate ridge in term of yaxis
if nti_wavelet_defined(yaxis) then begin
  ridge_unit = yaxis(ridge_index)
endif

end