;-----------------------------------------------------------------------------
; Function : NICE_SMOOTH
; Author   : R.Martin
; Version  : 1.00
; Date     : 10.12.03
;-----------------------------------------------------------------------------
; NICE_SMOOTH
;
; Performs a boxcar averaging on a vector on an irregular grid
;
; Calling Sequence
;
; result=NICE_SMOOTH(data, x, dx)
;
; result     - Boxcarred array.
;
; data       - Vector array of points to be smoothed
; x          - Vector array index to data, must be monotonic
; dx         - width of boxcar window.
;
;-----------------------------------------------------------------------------
;

function nice_smooth,           $;
        data,			$;
        arg1,			$; List of data traces.
	arg2,                   $;
        remainder=remainder,    $;
        edge_truncate=edge

  if not_real(data) then $
    error_message, 'NICE_SMOOTH: DataArg must be a real array'

  dsize=size(data)
  if (dsize(0) ne 1) or (n_elements(data) le 1) then $
    error_message, 'NICE_SMOOTH: DataArg must be a vector'

  if (n_params() eq 2) then begin
    if (n_elements(arg1) ne 1) then $
      error_message, 'NICE_SMOOTH: NpntsArg must be scalar'

    if not_integer(arg1) then $
      error_message, 'NICE_SMOOTH: NpntsArg must be integer'

    if (arg1(0) lt 2) then $
      error_message, 'NICE_SMOOTH: NpntsArg must be .gt. 2'

    if (arg1(0) gt n_elements(data)) then $
      error_message, 'NICE_SMOOTH: NpntsArg must be .lt. SIZE(DataArg)'

    x=findgen(n_elements(data))
    dx=arg1(0)
  endif else begin
    if (n_params() ne 3) then $
      error_message, $
        'NICE_SMOOTH: Call Sequence result=NICE_SMOOTH(data, X, dX)'

    if (n_elements(arg2) ne 1) then $
      error_message, 'NICE_SMOOTH: dX must be a scalar'
    
    if not_real(arg2) then $
      error_message, 'NICE_SMOOTH: dX must be real'

    if (arg2(0) le 0.0) then $
      error_message, 'NICE_SMOOTH: dX must be .gt. 0'

    if not_real(arg1) then $
      error_message, 'NICE_SMOOTH: X must be a real array'

    if n_elements(arg1) ne n_elements(data) then $
      error_message, 'NICE_SMOOTH: X must be same size as DataArg'

    if (monotonic(arg1, /inc, /strict) eq 0) then $
      error_message, 'NICE_SMOOTH: X must be monotonically increasing'

    if (arg2(0) ge (max(arg1)-arg1(0))) then $
      error_message, 'NICE_SMOOTH: dX larger than span of X-array'

    x=arg1
    dx=arg2
  endelse

  idata=double(data)
  idata(0)=0
  idata(1:*)=total( /cumulative, (x(1:*)-x)*(data+data(1:*)))

  idata=interpol(idata, x, x+dx(0)*0.5) $
        -interpol(idata, x, (x-dx(0)*0.5))

  if keyword_Set(remainder) then return, data-idata/(2.0*dx(0))
  return, idata/(2.0*dx)

end

;-----------------------------------------------------------------------------
; Modification History
;
;

