function cross_prod, input1, input2
;///////////////////////////////////////////
; cross_prod: calculate the cross product
;                of input1, input2
;///////////////////////////////////////////
;INPUT:
;       input1: first vector
;       input2: second vector
;OUTPUT:
;       the cross droduct of the above two vectors
;///////////////////////////////////////////
output=[input1[1]*input2[2]-input1[2]*input2[1],$
        input1[2]*input2[0]-input1[0]*input2[2],$
        input1[0]*input2[1]-input1[1]*input2[0]]
return, output

end