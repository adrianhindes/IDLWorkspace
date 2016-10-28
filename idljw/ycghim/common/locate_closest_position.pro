
function locate_closest_position, array, value
; returns index of array, returns -1 if failed.

  if (N_ELEMENTS(array) lt 2) or (N_ELEMENTS(value) ne 1) then $
    return, -1

  test_value = value[0]
  test_array = REFORM(array)

  inx1 = WHERE(test_array ge test_value, count1)
  inx2 = WHERE(test_array le test_value, count2)

  if count1 lt 1 then begin
    return_inx = N_ELEMENTS(test_array)-1
  endif else if count2 lt 1 then begin
    return_inx = 0
  endif else begin
    inx1 = inx1[0]
    inx2 = inx2[count2-1]
    return_inx = ( ABS(test_array[inx1]-test_value) ge ABS(test_array[inx2]-test_value) ) ? inx2 : inx1
  endelse

  return, return_inx

end