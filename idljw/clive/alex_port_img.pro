bg=[0,15]
dat=[20,49]
for i=bg(0),bg(1) do begin
   tmp=read_tiff('~/f16.tif',image_index=i)*1.0
   if i eq bg(0) then d0=tmp else d0+=tmp
   imgplot,tmp,/cb,title=i&wait,0.5
endfor
d0/=(bg(1)-bg(0)+1)

for i=dat(0),dat(1) do begin
   tmp=read_tiff('~/f16.tif',image_index=i)*1.0
   if i eq dat(0) then d1=tmp else d1+=tmp
   imgplot,tmp,/cb,title=i&wait,0.5
endfor
d1/=(dat(1)-dat(0)+1)

d=d1-d0
imgplot,d,/cb

end

