pro write_apd_facttable,board,data

; board=1 --> ADC
; board=2 --> Control

if (board eq 1) then begin
  enable_reg = hex('26')
  enable_code = hex('93b2')
  fact_offset = hex('100')
endif
if (board eq 2) then begin
  enable_reg = hex('88')
  enable_code = hex('cd')
  serial_address = hex('200')
endif

write_apd_register,board,enable_reg,enable_code,length=2
write_apd_register,board,fact_offset,data,/array,length=n_elements(data)
write_apd_register,board,enable_reg,0,length=2
data_r = read_apd_register(board,fact_offset,length=n_elements(data),/array,error=e)
if (e ne '') then begin
  print,e
  return
endif
if ((where(data ne data_r))[0] lt 0) then begin
  print,'Faxtory calibration table written successfully.'
endif else begin
  print,'Factory calibration table could not be written.'
endelse

end


