function calculate_mse_geometric_parameters, geom, image_coords=image_coords

; calculate the beam divergence
xi = atan( geom.v[*,*,2],modulus(geom.v[*,*,0:1]) )

; reversig sign of Br gives agreement with direct numerical calculation!
; this is the approximate form

; this is the form without beam divergence
; denominator: Br, Bz, Bphi
d1 = cos(geom.omega)*sin(geom.psi)*sin(xi) + cos(geom.alpha)*cos(geom.psi)*cos(xi)
d2 = -sin(geom.gamma)*sin(geom.psi)*cos(xi)
d3 = -(sin(geom.omega)*sin(geom.psi)*sin(xi) + sin(geom.alpha)*cos(geom.psi)*cos(xi))

; numerator
n1 = sin(geom.omega)*sin(xi)
n2 = -cos(geom.gamma)*cos(xi)
n3 = cos(geom.omega)*sin(xi)

;rgrid = geom.interp.rgrid
;zgrid = geom.interp.zgrid
idx = geom.interp.indices

if keyword_Set(image_coords) then $
  return, {n1:n1, n2:n2, n3:n3, d1:d1, d2:d2, d3:d3, xi:xi} else $
  
  return, {n1:n1[idx], n2:n2[idx], n3:n3[idx], d1:d1[idx], d2:d2[idx], d3:d3[idx], xi:xi[idx]}


end

