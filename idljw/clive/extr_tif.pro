pro extr_tif, sh, twant=twant,db=db,compress=compress,path=path,frame=frame

default,compress,1;lzw (I think is lossless?)
n=n_elements(twant)
if n gt 1 then  fmt=string("(",n-1,'(G0,","),G0)',format='(A,I0,A)') else $
   fmt='(G0)'
desc1=string(twant,format=fmt)
desc2=string(frameoftime(sh,twant,db=db),format=fmt)
desc=desc1+";"+desc2
readpatch,sh,str,db=db
str.rotate=0 ;;; dont adjust image here bt do roi it
for i=0,n-1 do begin
  if keyword_set(frame) then  d=getimgnew(sh,twant(i),db=db,str=str,/noloadstr) else   d=getimgnew(sh,db=db,twant=twant(i),str=str,/noloadstr)
   default,path,str.path
   fname=path+'/'+db+string(sh,format='(I0)')+'.tif'

   write_tiff,fname,d,/long,append=i gt 0,desc=(i eq 0 ? desc : 0),compress=compress
endfor
print,fname
print,desc
end

