function defined,var,nullarray=nullarray
; returns 1 if variable exists otherwise 0
; /null: return 0 if array is set to 0

if (((size(var))(0) eq 0) and ((size(var))(1) eq 0)) then begin
  return,0
endif else begin
  if (keyword_set(nullarray)) then $
       if ((where(var ne 0))(0) lt 0) then return,0
  return,1
endelse
end
