function parabolic_fit, x, p
  if n_elements(p) gt 3 then begin
    print, 'Only 3 parameter is allowed!'
    return, -1
  endif
  
  return, p[0]*x^2+p[1]*x+p[2]  
end