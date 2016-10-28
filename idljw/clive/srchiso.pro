fils=file_search('/prl96lf/shaun_?????.spe',count=cnt)
;fils=file_search('/prl96lf/shaun_84198.spe',count=cnt)
n=n_elements(fils)
grat=strarr(n)
cwl=fltarr(n)
sh=lonarr(n)
for i=0,n-1 do begin
   
  spl=strsplit(fils(i),'_.',/extract)
  sh(i)=long(spl(1))
  err=0L
  catch,err
  if err ne 0 then continue
  cc:
  
  read_spe,fils(i),l,t,d,str=str
  if istag(str,'cwl') then begin
     cwl(i)=str.cwl
     grat(i)=str.grating
  endif
  print,i,n,cwl(i),grat(i)
endfor

end

