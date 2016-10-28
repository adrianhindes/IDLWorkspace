function rot_z, input, point, angle

;///////////////////////////////////////////
; rot_z: rotation around z axis at a given
;        coordinate (point) with alfa angle
;///////////////////////////////////////////
;INPUT:
;       input: coordinate which has to be rotated (3 coordinate vector)
;       point: the rotation is around the z axis
;              going through this point (3 coordinate vector)
;       angle: the angle of the rotation (+ is countercw. and in radians)
;OUTPUT:
;       output:coordinate of the rotated point
;///////////////////////////////////////////

  rotm = [[cos(angle), -sin(angle), 0],$
          [sin(angle),  cos(angle), 0],$
          [0,           0,          1]]
  transinp = input-point

  output = (rotm ## transinp) + point
  return, output
  
end