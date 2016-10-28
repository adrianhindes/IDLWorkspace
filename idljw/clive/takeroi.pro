pro takeroi,fil=fil,roi=roi1,path=path,format=format
default,format,'normal'
default,path,'~/mse_data'
if format eq 'alternative' then begin
    sz1=[2560,2160]
    sz2=[1920,1080]
    off1=(sz1-sz2)/2
    off=[off1(0),off1(0),off1(1),off1(1)]
    roi=roi1+off
    print,'new roi=',roi
endif else roi=roi1

d=read_tiff(path+'/'+fil+'.tif')
d=d(roi(0)-1:roi(1)-1,roi(2)-1:roi(3)-1)
write_tiff,path+'/'+fil+string(roi1(0),roi1(1),roi1(2),roi1(3),format='(I0,"_",I0,"_",I0,"_",I0)')+'.tif',d,/verb,/short
end

