pro readtextc,file,data,nskip=nskip
; reads in the filter files, checks whether the channels/filterscopes of 'ch' have filters installed.
; For those channels that have filters installed, it returns: the reduced channel list 'ch' and the reduced
; corresponding list of fibre bundles 'md', the (measured) central wavelength of the filter 'CWL',
; its bandwidth 'FWHM' and its peak transmission 'T'. Also the filter partnumber 'PN' is returned.


; check the installed filters

openr,lun,file,/get_lun
i=0
; read (and ignore) the first line (header)
for j=0,nskip-1 do begin
    lin = ''
    readf,lun,lin
endfor

while not eof(lun) do begin ; loop through the data lines
  ; read the data line
  lin = ''
  readf,lun,lin
  rec = strsplit(lin,',',/extr,/preserve_null)
  if i eq 0 then nf=n_elements(rec)
                                ; initialise the data array on the
                                ; first line, append the other lines
  rec1=strarr(nf)
  val=min([nf-1,n_elements(rec)-1])
  rec1(0:val)=rec(0:val)

  if i eq 0 then data = rec else data=[[data],[rec1]]
  i+=1
endwhile
nr = i  ; number of records 
close,lun
free_lun,lun

; convert to long integers (long needed because part no. are ~CWL in 10-3nm => ~660000)



end


