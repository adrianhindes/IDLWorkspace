function getslice, num

path='~/kstartestimages'

fil=path+'/run'+string(num,format='(I0)')+'.tif'
print,findfile(fil)
d=read_tiff(fil,/verb)
slice=d(*,520)
return,slice
end

rarr=[6,15];3,5,6,10,11,12]
fac =[0.5,1];0.5,0.5,1,1,1,1,1]
nrun=n_elements(rarr)
nx=1376
dat=fltarr(nx,nrun)
for i=0,nrun-1 do begin
    dat(*,i)=getslice(rarr(i))*fac(i)
endfor
device,decomp=0
tek_color
plot,dat(*,0),yr=[0,2.5e4]
for i=0,nrun-1 do oplot,dat(*,i),col=i+1

end
