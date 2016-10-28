
FUNCTION keyword_test, input, k1=i, k2=j

  default, i, 0
  default, j, 0

  print, i
  print, j  


;  print, i
;  print, j
;  print, keyword

  if keyword_set(input) then begin
    return, 1
  endif else begin
    return, 2
  endelse 

END

pro print_test, in
  print, in
end
