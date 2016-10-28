pro plot_edicam_image,shot,img,thick=thick,charsize=charsize,$
  intensity=intensity,smlength=smlen,click=click

default,smlen,10
default,thick,1
default,charsize,1.2
default,intensity,1

;5968_compass_snapshot_8bit_2.jpg
file = 'd:\kstar\edicam_data\'+i2str(shot)+'\'+i2str(shot)+'_compass_snapshot_8bit_'+i2str(img)+'.jpg
read_jpeg,file,im
nx = (size(im))[1]
ny = (size(im))[2]
;im = reverse(im,1)
ind = indgen(nx/16)*16+6
im[ind,*] = im[ind+1,*]
if (smlen ne 0) then im = smooth(im,smlen)
plot,[0,nx-1],[0,ny-1],/nodata,xrange=[0,nx-1],xstyle=1,yrange=[0,ny-1],ystyle=1
otv,im*intensity
if (keyword_set(click)) then begin
  digxyadd,x,y,/data
  if (n_elements(x) ge 1) then oplot,x,y,psym=1,thick=3,symsize=2
endif
end