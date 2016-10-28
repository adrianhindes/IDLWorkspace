function rot_general, input, axis, point, angle
;///////////////////////////////////////////
; rot_z: rotation around given axis going through a given
;        coordinate (point) with alfa angle
;///////////////////////////////////////////
;INPUT:
;       input: coordinate which has to be rotated (3 coordinate vector)
;       axis: the rotation is around this axis (3 coordinate vector)
;       point: the axis is going through this point
;       angle: the angle of the rotation (+ is countercw. and in radians)
;OUTPUT:
;       output: coordinate of the rotated point
;///////////////////////////////////////////

  ;the axis vector has to be normalised
  axis=axis/distance(axis,/length)
  uxu=dblarr(3,3)
  ux=dblarr(3,3)
  uxu=axis ## axis
  ux=[[0,        -axis[2], axis[1] ],$
      [axis[2],  0,        -axis[0]],$
      [-axis[1], axis[0],  0       ]]
  ;from: http://en.wikipedia.org/wiki/Rotation_matrix
  rotm=[[1,0,0],[0,1,0],[0,0,1]]*cos(angle)+sin(angle)*ux+(1-cos(angle))*uxu
  transinp = input-point
  output = (rotm ## transinp) + point
  return, output
end