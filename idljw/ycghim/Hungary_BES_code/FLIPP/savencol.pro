pro savencol,a,file,header=header
; Saves 1D or 2D array a in ASCII file
; File can be read by loadncol.pro
; Header is expected to be a string or string array. Each string in the
; array is written as one line into the header.

openw,l,file,/get_lun
if (defined(header)) then begin
  for i=0,n_elements(header)-1 do begin
    printf,l,header[i]
  endfor
endif
if ((size(a))(0) eq 2) then begin
  nr=(size(a))(1)
  nc=(size(a))(2)
  for i=0L,nr-1 do begin
    str=''
    for j=0,nc-1 do begin
      str=str+' '+string(a(i,j))
    endfor
    printf,l,str
  endfor
endif else begin
  nr=(size(a))(1)
  for i=0,nr-1 do printf,l,a(i)
endelse
close,l
free_lun,l
end
