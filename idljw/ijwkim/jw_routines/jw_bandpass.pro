FUNCTION JW_BANDPASS, inputArray, lowFreq, highFreq,$
  IDEAL=idealFlag, $
  BUTTERWORTH=butterworthDimension, $
  GAUSSIAN=gaussianFlag

  COMPILE_OPT IDL2

  ON_ERROR, 2

  numberOfDimensions = SIZE(inputArray, /N_DIMENSIONS)
  dimensions = SIZE(inputArray, /DIMENSIONS)

  ;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Handle all the flags.
  ;;;;;;;;;;;;;;;;;;;;;;;;
  idealFlag = KEYWORD_SET(idealFlag)
  gaussianFlag = KEYWORD_SET(gaussianFlag)
  if N_ELEMENTS(butterworthDimension) eq 0 then butterworthFlag = 0 $
  else butterworthFlag = 1

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Respond to flag input or make changes.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  if (numberOfDimensions ne 2) then $
;    MESSAGE, 'Input must be a two dimensional array.'

  if TOTAL([idealFlag, butterworthFlag, gaussianFlag] ne 0) gt 1 then $
    MESSAGE, 'Only set one of IDEAL, BUTTERWORTH, or GAUSSIAN.'

  if TOTAL([idealFlag, butterworthFlag, gaussianFlag] ne 0) eq 0 then begin
    butterworthFlag = 1
    butterworthDimension = 1
  endif

  if N_ELEMENTS(lowFreq) eq 0 then $
    MESSAGE, 'Flow and Fhigh must be supplied.'
  if N_ELEMENTS(highFreq) eq 0 then $
    MESSAGE, 'Fhigh must be supplied.'
  if lowFreq gt 1 then $
    MESSAGE, 'Flow is out of range ([0,1]).'
  if highFreq lt 0 then $
    MESSAGE, 'Fhigh is out of range ([0,1]).'
  if highFreq lt lowFreq then $
    MESSAGE, 'Fhigh must be greater than Flow.'

  if butterworthFlag ne 0 && butterworthDimension le 0 then $
    MESSAGE, 'Butterworth dimension must be a positive value.'
    
  if lowFreq lt 0 then $
    lowFreq = 0.0
  if highFreq gt 1 then $
    highFreq = 1.0

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Here, we do the actual work.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  fourierTransform = FFT(inputArray, /CENTER)

  N = dimensions[0]
  X = (FINDGEN((N - 1)/2) + 1)
  is_N_even = (N MOD 2) EQ 0
  if (is_N_even) then $
;    D = [0.0, X, N/2, -N/2 + X] $
     D = [-N/2 + X, 0.0, X, N/2] $
  else $
    D = [ -(N/2 + 1) + X, 0.0, X]
;  D = DOUBLE(SHIFT(DIST(dimensions[0]), dimensions[0]/2+1))
  
  D /= MAX(D)

  W = DOUBLE(highFreq - lowFreq)
  D0 = DOUBLE(highFreq+lowFreq)/2.0d
  
;  Result = BANDPASS_FILTER(reform_channel1, 0.2, 1 , BUTTERWORTH=100.0)
;
;  fft_2 = abs(fft(result,-1))
;
;  data_size = size(result)
;  T = dt
;  N = data_size[1]
;  X = (FINDGEN((N - 1)/2) + 1)
;  is_N_even = (N MOD 2) EQ 0
;  if (is_N_even) then $
;    freq = [0.0, X, N/2, -N/2 + X]/(N*T) $
;  else $
;    freq = [0.0, X, -(N/2 + 1) + X]/(N*T)
;
;  fft_mean2 = fltarr(N)
;  for i = 0L, data_size[2]-1 do begin
;    fft_mean2 = fft_mean2 + fft_2(*,i)
;  endfor
;
;  fft_mean2 = fft_mean2/data_size[2]
;
;  ycplot, [-N/2+X,0.0,X,N/2]/(N*T), shift(fft_mean2,-N/2-1)

  if idealFlag eq 1 then begin
    H = MAKE_ARRAY(dimensions, VALUE=1)
    H[WHERE(lowFreq gt D or highFreq lt D)] = 0
  endif else if butterworthFlag ne 0 then begin
    if lowFreq ne 0 && highFreq ne 1 then begin
      H = 1.0d - (1.0 / (1 + ( (D*W) / (D^2-D0^2) ) ^ (2*butterworthDimension)))
    endif else if lowFreq eq 0 then begin
      H = 1.0d / (1 + ( D / highFreq ) ^ (2*butterworthDimension))
    endif else begin
      H = 1.0d / (1 + ( lowFreq / D ) ^ (2*butterworthDimension))
    endelse
  endif else begin
    if lowFreq ne 0 && highFreq ne 1 then begin
      H = exp(-(( (D^2 - D0^2) / (D*W) )^2))
    endif else if lowFreq eq 0 then begin
      H = exp(-( D^2 / (2*highFreq^2) ) )
    endif else begin
      H = 1.0d - exp(-( D^2 / (2*lowFreq^2) ) )
    endelse
  endelse
  ;; Hide any divide by zero errors
;  plot, H
  
  void = CHECK_MATH(MASK=16)

  resultFourier = H * fourierTransform
  
;  ycplot, freq_vector,fourierTransform
;  ycplot, freq_vector,resultFourier

  return, REAL_PART(FFT(resultFourier, /INVERSE, /CENTER))

end