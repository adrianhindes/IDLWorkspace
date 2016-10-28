;=======================================================================================
; 
; This is function that return the maximum number of input
;
;=======================================================================================
;
;<Input parameter>
;  1. A : array of numbers
;
;=======================================================================================
;
;<Output result>
;  Largest number that input has
;
;=======================================================================================


function maximum,A
  b=size(A) ; b[1] will have the number of data A has
  t=0
  for i=0,(b[1]-1) do begin
     if (A[i] lt t) then begin
        t=A[i]
     endif
  endfor 
  return, t
end


