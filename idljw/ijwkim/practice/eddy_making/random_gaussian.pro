;=======================================================================================
; 
; This is practice function for the normally distributed random number
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
;  Numbers that generated from the function
;
;=======================================================================================


function random_gaussian,t
  seed = !NULL
  return, randomn(seed, t)
end


