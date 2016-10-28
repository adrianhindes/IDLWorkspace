pro cleanimg,r=r
default,r,7264;61;42;53;41
sm=1

img=getimg(r,pre='',index=0,sm=sm,info=info,/getinfo,fil=fil)
nimg=info.num_images


sz=size(img,/dim)
imgs=fltarr(sz(0),sz(1),nimg)
for i=0,nimg-1 do begin
img=getimg(r,pre='',index=i,sm=sm)
imgs(*,*,i)=img
print,i,nimg
endfor

clean_data_cube,imgs
for i=0,nimg-1 do begin
write_tiff,'~/mse_data/c'+string(r,format='(I0)')+'.tif',long(imgs(*,*,i)),/short,append=i gt 0
print,i,nimg,'w'
endfor
;stop
end
