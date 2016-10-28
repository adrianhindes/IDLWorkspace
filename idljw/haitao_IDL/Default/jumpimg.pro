
pro jumpimg,img

ny=n_elements(img(0,*))
nx=n_elements(img(*,0))
imgj=img

vslice=img(nx/2,*)
ift=where(finite(vslice) eq 1)
jvslice=vslice
jvslice(ift)=phs_jump(vslice(ift))
jvslice2=jvslice - jvslice(ny/2) + vslice(ny/2)
pdif=jvslice2 - vslice


for i=0,ny-1 do begin
    ift=where(finite(imgj(*,i)) eq 1)
    if ift(0) eq -1 then continue
    imgj(ift,i) = phs_jump(img(ift,i))
    imgj(*,i)=imgj(*,i) - imgj(nx/2,i)+img(nx/2,i) + pdif(i)
endfor

img=imgj
end
