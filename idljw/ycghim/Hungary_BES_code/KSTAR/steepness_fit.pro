function steepness_fit, x, p
  if n_elements(p) gt 1 then begin
    print, 'Only 1 parameter is allowed!'
    return, -1
  endif
  
  return, p[0]*x  
end