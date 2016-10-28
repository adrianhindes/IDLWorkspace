pro write_apd_register,panel,address,data,length=length,array=array,errormess=errormess

;***********************************************************
; write_apd_register.pro
; Write the contents of an APD register.
; panel: Panel (board) address (1: ADC, 2: control)
; address: Start address
; length: The size og the register in bytes
; data: Data byte array (LSB first)
; /array: Data is given as an array, each element is one by
;         Otherwise interpret data as a single value and write it to
;         a register having the number of bytes specified
;
; OUTPUT:
;   errormess: '' or error message
;***********************************************************

version = '3.0'

errormess = ''

default,length,1

if (not defined(panel)) then begin
  errormess = 'write_apd_register: panel (board) address is not set!'
  print,errormess
  return
endif

if (not defined(address)) then begin
  errormess = 'write_apd_register: register address is not set!'
  print,errormess
  return
endif

if (not defined(data)) then begin
  errormess = 'write_apd_register: data is not set!'
  print,errormess
  return
endif

data = long(data)

if (keyword_set(array)) then length = n_elements(data)

if (not keyword_set(array) and length gt 4) then begin
  errormess = 'Register length should be not more than 4 bytes.'
  print,errormess
  return
endif
if (length lt 1) then begin
  errormess = 'Register length should be >= 1.'
  print,errormess
  return
endif

data_bytes = bytarr(length)
if (keyword_set(array)) then begin
  for i=0,length-1 do begin
    data_bytes[i] = data[i] mod 256
  endfor
endif else begin
  for i=0,length-1 do begin
    data_bytes[i] = ishft(data[0],-(8*i)) mod 256
  endfor
endelse

error = long(0)
R = CALL_EXTERNAL('CamControl.dll','idlWritePDI', byte(panel), ulong(address), ulong(length), data_bytes, long(error), /CDECL)
if (error lt 0) then begin
  errormess = 'Communication error.'
  return
endif


end