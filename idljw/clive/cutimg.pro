pro cutimg, img, px,py,cut2,str=str
nnx=px(0,0,1,1)-px(0,0,0,0)+1
nny=py(0,0,1,1)-py(0,0,0,0)+1

cut=make_array(nnx,nny,2,2,value=img(0,0))
for i=0,1 do for j=0,1 do begin
   cut(*,*,i,j) = img(px(i,j,0,0):px(i,j,1,1),py(i,j,0,0):py(i,j,1,1))
endfor
cut2=reform(cut,nnx,nny,4)
;pos=posarr(2,2,0)
;for i=0,3 do begin
;   imgplot,cut2(*,*,i),pos=pos,noer=i gt 0
;   pos=posarr(/next)
;endfor



end
