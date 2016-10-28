function bandpass_filter_data,data,sampletime=sampletime,filter_low=filter_low,filter_high=filter_high,$
        filter_order=filter_order,errormess=errormess,silent=silent,verbose=verbose,normalize=normalize,$
        filter_symmetric=symmetric

;***********************************************************************
;*  FUNCTION BANDPASS_FILTER_DATA          S. Zoletnik 2.06.2010       *
;***********************************************************************
;* Filters a signal for a frequency band with a FIR filter             *
;*                                                                     *
;* INPUT:                                                              *
;*   data: The data vector (1D)                                        *
;*   sampletime: The sampling time if the data in seconds              *
;*   filter_low: The low frequency limit (default:0)                   *
;*   filter_high: The high frerquency limit (deault (1/sampletime)/2)  *
;*   filter_order: The filter order (default: set to the needs)        *
;*   /silent: Do not print error message                               *
;*   /verbose: Print messages about the setting of paramteters         *
;*   /normalize: Use /normalize keyword in convol call                 *
;*   /symmetric: Use a symmetric (that is non-deterministic)           *
;*               response function                                     *
;* OUTPUT:                                                             *
;*   errormess: '' or error message                                    *
;*   return value is the filtered signal                               *
;***********************************************************************

errormess = ''

; Default lower bandwidth is 0
default,filter_low,0.
default,symmetric,1

; Return error if sampletime is not set
if (not defined(sampletime)) then begin
  errormess = 'Missing sampletime parameter in bandpass_filter.pro.'
  if (not keyword_set(silent)) then print,errormess
  return,0
endif

f_nyquist = 1.0/double(sampletime)/2.
default,filter_high,f_nyquist
filter_high = double(filter_high)

; Determine the filter order if not set explicitely
if (not keyword_set(filter_order)) then begin
  if (filter_low ne 0) then begin
    filter_order = (f_nyquist/filter_low)*1.5
  endif else begin
    filter_order = long((f_nyquist/filter_high)*1.5)
  endelse
  if (keyword_set(verbose)) then print,'Filter order: '+i2str(filter_order)
endif

if (not defined(data)) then begin
  errormess = 'Missing data in bandpass_filter.pro.'
  if (not keyword_set(silent)) then print,errormess
  return,0
endif
if (n_elements(data) lt filter_order*2) then begin
  errormess = 'Too short data array in bandpass_filter.pro.'
  if (not keyword_set(silent)) then print,errormess
  return,0
endif

; If the bandpass includes the full signal bandpass than do nothing
if (filter_high ge f_nyquist) and (filter_low eq 0) then return,data


kernel = digital_filter((filter_low/f_nyquist) > 0,(filter_high/f_nyquist) < 1,50,filter_order)
if (not keyword_set(symmetric)) then begin
  ; Keeping only deterministic elements
  ; This will introduce a  phase shift, but one cannot have 0 phase shift and deterministic response at the same time
  kernel = kernel[long(n_elements(kernel)/2):n_elements(kernel)-1]*2
  return,convol(data,kernel,normalize=normalize,center=0)
endif
return,convol(float(data),kernel,normalize=normalize)

end