function xyztocyl, input, inv=inv

;*****************************************************
;**                     xyztocyl                    **
;*****************************************************
;* This function returns the cylindrical coordinates *
;* of a given xyz points and can also do inverse     *
;* transformation                                    *
;* INPUT:                                            *
;*       input: xyz or R,z,phi coordinate array      *
;*       /inv: set if one wants to do inverse        *
;* OUTPUT:                                           *
;*       output: R,z,phi or xyz coordinate array,    * 
;*               respectively                        *
;*****************************************************

output=dblarr(3)
if not keyword_set(inv) then begin
  output[0] = sqrt(input[0]^2+input[1]^2)
  output[1] = input[2]
  if input[0] gt 0 and input[1] gt 0 then output[2] = atan(input[1]/input[0])
  if input[0] lt 0 and input[1] gt 0 then output[2] = acos(input[0]/sqrt(input[0]^2+input[1]^2))
  if input[0] gt 0 and input[1] lt 0 then output[2] = asin(input[1]/sqrt(input[0]^2+input[1]^2))+2*!pi
  if input[0] lt 0 and input[1] lt 0 then output[2] = atan(input[1]/input[0])+!pi
endif else begin
  output[0] = input[0]*cos(input[2])
  output[1] = input[0]*sin(input[2])
  output[2] = input[1]
endelse

return, output
end