function loadncol,file,n,headerline=headn,cutzero=cutzero,silent=silent,$
  tmpfile=tmpfile,text=text,errormess=errormess,block_line_n=block_line_n,$
  line_number=line_number,csv=csv,format=format

; ************************** LOADNCOL.PRO *************** 28.07.2000 ******************
;                                                 Written by S. Zoletnik
; This function reads numbers arranged in rows and columns from and ASCII file.
; This program replaces and old version which used unix systems calls to determine
; the number of lines and columns. The present version uses only IDL file operations
; this it shoudl be system-independent.
;   Each line should     contain exactly the same amount of numbers. A file header can be
; handled if the headerline argument gives the number of header lines.
;   The return value is a 2D array of float numbers, first index is line number, second
; is column. In case of error 0 is returned
;
; INPUT:
;   file: name of file (string)
;   n: number of columns (optional, if not given will be determined from first non-header
;      line
;   headerline: number of header lines
;   text: The header text is returned in this variable (string array)
;   /cutzero: omit trailing lines with all zeros
;   /silent: DO not print info and error messages
;   errormess: error message or ''  (string)
;   tmpfile: not used, kept for compatibility with all loadncol
;   line_number: The number of data lines to read (this excludes the header lines).
;   /csv: Comma separated file. On each line the elements are separated by comma and not whitespace
;   format: The data format of elements: 'int', 'long', 'float', 'string'
; ***************************************************************************************

default,headn,0
default,block_line_n,10l
block_line_n=long(block_line_n)
default,format,'float'

if (not keyword_set(csv)) then begin
  separator = ' '
endif else begin
  separator = ','
endelse

errormess=''

if (!version.os eq 'Win32') then begin
  while (strpos(file,'/') ge 0) do begin
    strput,file,'\',strpos(file,'/')
  endwhile
endif

openr,unit,file,/get_lun,error=error
if (error ne 0) then begin
  errormess = 'Cannot open file '+file
       if (not keyword_set(silent)) then print,errormess
       return,0
endif

if (headn ne 0) then begin
  on_ioerror,err
  text=strarr(headn)
  txt='a'
  for i=1,headn do begin
    readf,unit,txt
    text(i-1)=txt
  endfor
endif

line_counter=long(0)
while (not eof(unit)) do begin
  txt=''
  readf,unit,txt
  if (not keyword_set(csv)) then begin
    txt=strcompress(strtrim(txt,2))
  endif
  if (strcompress(txt,/remove_all) ne '') then begin
    ;if not empty line
    txt_arr=str_sep(txt,separator)
    if (not keyword_set(n)) then n=n_elements(txt_arr)
    if (line_counter eq 0) then begin
      if (not keyword_set(silent)) then begin
        print,'Reading '+string(n,format='(I2)')+' columns from file '+file
      endif
      if (strupcase(format) eq 'FLOAT') then begin
        data=fltarr(block_line_n,n)
      endif
      if (strupcase(format) eq 'INT') then begin
        data=intarr(block_line_n,n)
      endif
      if (strupcase(format) eq 'LONG') then begin
        data=lonarr(block_line_n,n)
      endif
      if (strupcase(format) eq 'STRING') then begin
        data=strarr(block_line_n,n)
      endif
      if (not defined(data)) then begin
        errormess='Unknown format code in loadncol. Valid: float, int, long, string.'
        if (not keyword_set(silent)) then print,errormess
        close,unit & free_lun,unit
        return,0
      endif
      act_line_n=block_line_n
    endif
    if (line_counter ge act_line_n) then begin
      data1=data
      if (strupcase(format) eq 'FLOAT') then begin
        data=fltarr(act_line_n+block_line_n,n)
      endif
      if (strupcase(format) eq 'INT') then begin
        data=intarr(act_line_n+block_line_n,n)
      endif
      if (strupcase(format) eq 'LONG') then begin
        data=lonarr(act_line_n+block_line_n,n)
      endif
      if (strupcase(format) eq 'STRING') then begin
        data=strarr(act_line_n+block_line_n,n)
      endif
      data(0:act_line_n-1,*)=data1
      act_line_n=act_line_n+block_line_n
    endif
    if (strupcase(format) eq 'FLOAT') then begin
      data_arr=float(txt_arr)
    endif
    if (strupcase(format) eq 'INT') then begin
      data_arr=fix(txt_arr)
    endif
    if (strupcase(format) eq 'LONG') then begin
      data_arr=long(txt_arr)
    endif
    if (strupcase(format) eq 'STRING') then begin
      data_arr=txt_arr
    endif
    if (n_elements(data_arr) ne n) then begin
      errormess='Line '+i2str(line_counter+1)+': Number of data in line is different from expected.'
      if (not keyword_set(silent)) then print,errormess
      close,unit & free_lun,unit
      return,0
    endif
    data(line_counter,*)=data_arr
    line_counter=line_counter+1
  endif
  if defined(line_number) then begin
    if (line_counter ge line_number) then break
  endif
endwhile
close,unit & free_lun,unit
if (line_counter eq 0) then begin
  errormess = 'No data found in file '+file
  if (not keyword_set(silent)) then print,errormess
  return,0
endif

data=data(0:line_counter-1,*)

if (keyword_set(cutzero)) then begin
  nn = total(data(*,0) ne 0)
  data=data(0:nn-1,*)
endif


return,data

err:
  if (line_counter eq 0) then begin
  errormess = 'Error reading from file '+file
       if (not keyword_set(silent)) then print,errormess
       close,unit & free_lun,unit
       return,0
  endif else begin
    data=data(0:line_counter-1,*)
    if (keyword_set(cutzero)) then begin
      nn = total(data(*,0) ne 0)
      data=data(0:nn-1,*)
    endif
    return,data
  endelse
end
