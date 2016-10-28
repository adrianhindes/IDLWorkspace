;=======================================================================================
; 
; This is practice function for the linearly distributed random number
; It will return the mean value of the randomly generated numbers
;
;=======================================================================================
;
;<Input parameter>
;  1. t : The number of trial
;
;=======================================================================================
;
;<Output result>
;  Mean value of the generated numbers
;
;=======================================================================================


function random_linear,t
  seed = !NULL
  return, randomu(seed, t)
end


