function myread_ascii,fil,data_start=data_start,nex=nex,delim=delim

nex=3

openr,lun,fil,/get_lun
;lins=strarr(2e6)
ltmp=''
i=0L
while not eof(lun) do begin
   readf,lun,ltmp
;   lins(i)=ltmp
   if ltmp eq '' then break
   if i ge data_start then begin
      if i eq data_start then begin
         spl=float(strsplit(ltmp,delim,/extract))
         nex=n_elements(spl)
         array=fltarr(2e6,nex)
      endif
      spl=fltarr(nex)
      reads,ltmp,spl
      array(i-data_start,*)=spl

   endif
   i=i+1
endwhile
array=array(0:i-data_start-1,*)

return,array
end
