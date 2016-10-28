cd,'/nas/MSE_2014_DATA'
sharr=intspace(11125,11200)
nsh=n_elements(sharr)
nfr=fltarr(nsh)
for i=0,nsh-1 do begin
   nfr(i)=query_seg_images('mse_2014',sharr(i),'.PCO_CAMERA:IMAGES')
   print,i,sharr(i),nfr(i)

   if nfr(i) gt 100 then begin
      cmd='mv MSE_2014_'+string(sharr(i),format='(I0)')+'_Images.TDMS* tdms_converted/'
;      print,cmd
      spawn,cmd
;      stop
   endif

endfor

end
