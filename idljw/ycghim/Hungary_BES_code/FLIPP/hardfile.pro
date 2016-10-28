pro hardfile,file

common hardcopy,original_device,filename

default,filename,''
if (filename eq '') then filename='idl.ps'
device,/close
cgfixps, filename
set_plot,original_device
if (keyword_set(file)) then begin
  if (!version.os eq 'Win32') then   spawn,'move '+filename+' '+file
  if ((strupcase(!version.os) eq 'LINUX') or (strupcase(!version.os) eq 'SUNOS')) then spawn,'mv '+filename+' '+file
  if (strupcase(!version.os) eq 'VMS') then spawn,'rename '+filename+' '+file
endif
end



