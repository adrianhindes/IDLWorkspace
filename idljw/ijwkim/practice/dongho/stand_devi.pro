;=======================================================================================
; 
; This function will return the standard deviation of the given array
;
;=======================================================================================
;
;<Input parameter>
;  1. a : array of numbers
;
;=======================================================================================
;
;<Output result>
;  Standard deviation of given array
;
;=======================================================================================


function stand_devi,a
  b=size(a)
  s=0
  for i=0,(b[1]-1) do begin
     s=s+a[i]
  endfor
  m=s/b[1] ; mean value of the numbers
  sig=0
  for i=0,(b[1]-1) do begin
     sig=sig+(a[i]-m)*(a[i]-m)
  endfor
  sig=sig/b[1]
  sig=sqrt(sig)
  return, sig
end


