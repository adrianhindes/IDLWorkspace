pro write_filter,coeff
; Writes the 8 filter coefficients into the register

coeff_w = long(coeff)

data = intarr(16)
for i=0,7 do begin
  if (coeff_w[i] lt 0) then coeff_w = 65536+coeff_w
  ;data[i*2]= coeff_w[i] mod 256
  ;data[i*2+1] = coeff_w[i]/256
  write_apd_register,1,hex('d0')+i*2,coeff_w[i] mod 256
  wait,0.1
  write_apd_register,1,hex('d0')+i*2+1,coeff_w[i] / 256
  wait,0.1
endfor
;write_apd_register,1,hex('d0'),data,/array
;print,read_apd_register(1,hex('d0'),len=16,/array)

end