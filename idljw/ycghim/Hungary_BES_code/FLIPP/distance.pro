function distance, input1, input2, length=length

;*////////////////////////////////////////////////////////////*
;*                      distance                              *
;*////////////////////////////////////////////////////////////*
;*This function gives the distance between to points          *
;**INPUT:                                                     *
;*       input1: a point                                      *
;*       input2: another point                                *
;*       /length: if set, gives the length of vector input1   *
;*OUTPUT:                                                     *
;*       output: the distance between the two points          *
;*////////////////////////////////////////////////////////////*

  if not (keyword_set(length)) then begin
    if (n_elements(input1) ne n_elements(input2)) then return, -1
    output = 0
    for i=0,n_elements(input1)-1 do output += (input1[i]-input2[i])^2
    output = sqrt(output)
    return, output
  endif else begin
    output=0
    for i=0,n_elements(input1)-1 do output += input1[i]^2
    output = sqrt(output)
    return, output
  endelse
  
end