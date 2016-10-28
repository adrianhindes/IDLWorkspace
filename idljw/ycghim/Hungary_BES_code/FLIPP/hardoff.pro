pro hardoff,printer

common hardcopy,original_device,filename

default,filename,''
if (filename eq '') then filename='idl.ps'

default,printer,getenv('PRINTER')
if (printer eq '') then begin
  print,'Enter printer name:'
  read,printer
endif
device,/close
set_plot,original_device
if (printer eq 'REMOTE_PRINTER') then  begin
  script = getenv('REMOTE_PRINT_SCRIPT')
  spawn,script+' '+'idl.ps'
endif else begin
  case (strupcase(!version.os)) of
    'HP-UX'  : spawn,'lp -d Postscript '+filename
    'LINUX'  : spawn,'lpr -P'+printer+' '+filename
    'AIX'  :   spawn,'lpr -P'+printer+' '+filename
    'IRIX'   : spawn,'lpr -PPShp '+filename
    'VMS'    : spawn,'print /queue='+printer+' '+filename
    else  : stop,'Unknown !version.os:',!version.os
  endcase
endelse
end





















