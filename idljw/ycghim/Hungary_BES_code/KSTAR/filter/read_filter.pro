function read_filter
; Reads the 8 filter coefficients from the camera

data = read_apd_register(1,hex('d0'),len=16,/array)
;print,data
coeff = lonarr(8)
for i=0,7 do begin
  coeff[i] = data[i*2] + data[i*2+1]*256L
  if (coeff[i] ge 32768L) then  coeff[i] = coeff[i]-65536L
endfor

return,coeff
end
