write_apdcam_signature,serial
; Fills all necessary registers in the ADC adn control card

default,ADC_low_limit,0
default,ADC_high_limit,16000
default,ADC_block_gains,fltarr(4)+2000./16384.

if (not defined(serial)) then begin
  print,'Serial number is missing,'
  return
endif

print,'Writing data for APDCAM serial number '+i2str(serial)
if (not ask('Continue')) then return

apdcam_open,errormess=errormess
if (errormess ne '') then begin
  print,'Error'
  return
endif

ADC_board = 1
ADC_enable_reg = hex('26')
ADC_enable_code = hex('93b2')
ADC_serial_address = hex('03')
ADC_data_area = hex('100')

PC_board = 2
PC_enable_reg = hex('88')
PC_enable_code = hex('cd')
PC_serial_address = hex('100')
ADC_data_area = hex('200')

write_apd_register,ADC_board,enable_reg,enable_code,length=2
write_apd_register,ADC_board,serial_address,serial,length=2
product_code = 'AP'+i2str(serial,digits=4)
write_apd_register,ADC_data_area+hex('0'),byte(product_code),/array,length=6
write_apd_register,ADC_data_area+hex('6'),byte(ADC_low_limit),length=2
write_apd_register,ADC_data_area+hex('8'),byte(ADC_high_limit),length=2
for




end


