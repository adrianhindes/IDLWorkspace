function magpie_get_points, degree=degree, radius=radius
  
  rot_probe_radius = 0.0285; %[m]
  x_rot_mid = 0.0
  y_rot_mid = 0.03
  
  r = radius
  const1 = r^2.+x_rot_mid^2.+y_rot_mid^2.
  const2 = x_rot_mid
  const3 = y_rot_mid
  r2 = rot_probe_radius
  
  if KEYWORD_SET(degree) then begin
    return, 0
  endif else if KEYWORD_SET(radius) then begin
    sqrt_value = sqrt(-const1^2.*const2^2.+4*const2^4.*r^2+4*const2^2.*const3^2.*r^2.+2*const1*const2^2.*r2^2.-const2^2.*r2^4.)
    y1 = (const1*const3-const3*r2^2.-sqrt_value)/(2*(const2^2.+const3^2.))
    x1 = sqrt(r^2.-y1^2.)
    y2 = (const1*const3-const3*r2^2.+sqrt_value)/(2*(const2^2.+const3^2.))
    x2 = -sqrt(r^2.-y2^2.)
    result = CREATE_STRUCT('x', [x1, x2], 'y', [y1, y2])
    return, result
  end
end