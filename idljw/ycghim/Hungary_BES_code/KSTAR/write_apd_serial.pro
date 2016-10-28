pro write_apd_serial,board,serial

; board=1 --> ADC
; board=2 --> Control

if (board eq 1) then begin
  enable_reg = hex('26')
  enable_code = hex('93b2')
  serial_address = hex('03')
endif
if (board eq 2) then begin
  enable_reg = hex('88')
  enable_code = hex('cd')
  serial_address = hex('100')
endif

write_apd_register,board,enable_reg,enable_code,length=2
write_apd_register,board,serial_address,serial,length=2
write_apd_register,board,enable_reg,0,length=2
serial_r = read_apd_register(board,serial_address,length=2,error=e)
if (e ne '') then begin
  print,e
  return
endif
if (serial eq serial_r) then begin
  print,'Serial number written successfully.'
endif else begin
  print,'Serial number could not be written.'
endelse

end


