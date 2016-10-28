function read_apd_register,panel,address,length=length,array=array,errormess=errormess

;**************************************************************
; read_apd_register.pro
; Read the contents of a register in the APD camera
; INPUT:
;  panel: The board (panel) address
;  address: The address
;  length: The number of bytes to read
;  /array: Return the 1-byte numbers as array.
;          Otherwise it will be returned as a single number, LSB first.
;          Maximum 4 byte registers will be returned in this case in
;            an long64 number
;**************************************************************
default,panel,2
default,address,0
default,length,1

errormess = ''
version = '3.0'

;print,'read_apd_register.pro....version:'+version

if (not defined(panel)) then begin
  errormess = 'read_apd_register: panel (board) address is not set!'
  print,errormess
  return,0
endif

if (not defined(address)) then begin
  errormess = 'read_apd_register: register address is not set!'
  print,errormess
  return,0
endif

if (not keyword_set(array) and length gt 4) then begin
  errormess = 'Register length should be not more than 4 bytes.'
  print,errormess
  return,0
endif
if (length lt 1) then begin
  errormess = 'Register length should be >= 1.'
  print,errormess
  return,0
endif

res_num = bytarr(length)

; read data ...
error = long(0)
R = CALL_EXTERNAL('CamControl.dll','idlReadPDI', byte(panel), ulong(address), ulong(length), res_num, long(error), /CDECL)
if (error lt 0) then begin
  errormess = 'Communication error.'
  return,0
endif

if (keyword_set(array)) then begin
  if (n_elements(res_num) lt length) then begin
    errormess = 'Received too less values from readpdi. ('+i2str(n_elements(res_num))+' instead of '+i2str(length)+')'
  endif
  return,res_num
endif
res_num_1 = long64(0)
for i=0,n_elements(res_num)-1 do begin
  res_num_1 = res_num_1 + ishft(long64(res_num[i]),i*8)
endfor
if (n_elements(res_num) lt length) then begin
  errormess = 'Received too less values from readpdi. ('+i2str(n_elements(res_num))+' instead of '+i2str(length)+')'
endif
return,res_num_1


end