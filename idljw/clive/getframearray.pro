function getframearray, str
;for tif file
  fmt='(I0)'
  snum=string(str.sh,format=fmt)
  fil=str.path+'/'+str.tifpre+snum
  filtif=file_search(fil+'.tif',/fold_case)
  dum=query_tiff(filtif,info)
  desc=info.description
  s=strsplit(desc,';',/extr)
  ns=n_elements(s)
  if ns ne 2 then return,indgen(5000) else begin
     s2=strsplit(s(1),',',/extr)
     ivec=fix(s2)
     return,ivec
  endelse
     
end


