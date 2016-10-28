
function create_nice_plot_range, min_range, max_range

  if min_range ge max_range then begin
    min_number = max_range
    max_number = min_range
  endif else begin
    min_number = min_range
    max_number = max_range
  endelse

  range = max_number - min_number
  if range eq 0 then begin
    avg = (max_number + min_numer)/2.0
    min_number = min_number - avg * 0.1
    max_number = max_number + avg * 0.1
  endif

  if min_number eq 0.0 then begin
    min_number = min_number - range * 0.1
  endif

  if max_number eq 0.0 then begin
    max_number = max_number + range * 0.1
  endif

  min_sign = (min_number lt 0.0) ? -1.0 : 1.0
  max_sign = (max_number lt 0.0) ? -1.0 : 1.0

  min_number = ABS(min_number)
  max_number = ABS(max_number)

  if min_number lt 1.0 then begin
    min_step = 10.0^FIX(ALOG10(min_number)-1)
  endif else begin
    min_step = 10.0^FIX(ALOG10(min_number))
  endelse

  if max_number lt 1.0 then begin
    max_step = 10.0^FIX(ALOG10(max_number)-1)
  endif else begin
    max_step = 10.0^FIX(ALOG10(max_number))
  endelse

  temp = min_sign*(findgen(10)+1.0) * min_step
  inx = WHERE(temp le min_sign*min_number, count)
  if count gt 0 then begin
    inx_locator = (min_sign lt 0) ? 0 : count-1
    min_number = temp[inx[inx_locator]]
  endif else begin
    min_step = min_step * 10.0
    temp = min_sign * (findgen(10)+1.0) * min_step
    inx = WHERE(temp le min_sign*min_number, count)
    inx_locator = (min_sign lt 0) ? 0 : count-1
    min_number = temp[inx[inx_locator]]
  endelse

  temp = max_sign*(findgen(10)+1.0) * max_step
  inx = WHERE(temp ge max_sign*max_number, count)
  if count gt 0 then begin
    inx_locator = (max_sign lt 0) ? count-1 : 0
    max_number = temp[inx[inx_locator]]
  endif else begin
    max_step = max_step * 10.0
    temp = max_sign * (findgen(10)+1.0) * max_step
    inx = WHERE(temp ge mag_sign*max_number, count)
    inx_locator = (max_sign lt 0) ? count-1 : 0
    max_number = temp[inx[inx_locator]]
  endelse

  return, [min_number, max_number]

end