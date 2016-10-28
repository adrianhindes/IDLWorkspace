function getimg, num

path='~/kstartestimages'

fil=path+'/run'+string(num,format='(I0)')+'.tif'
print,findfile(fil)
d=read_tiff(fil,/verb)
slice=d
return,slice
end

rarr=[24];16];3,5,6,10,11,12]
ang=[0]
nrun=n_elements(rarr)
nx=1376

;d;at=fltarr(nx,nrun)
;for i=0,nrun-1 do begin
;    dat(*,i)
img=getimg(rarr(0))

sub=128
;cursor,dx,dy,/down
sz=size(img,/dim)
orig=sz/2
imgsub=img(orig(0)-sub/2:orig(0)+sub/2-1,$
           orig(1)-sub/2:orig(1)+sub/2-1)
imgplot,imgsub

fimgsub=fft(imgsub)



quadpp=fimgsub*0.
quadmm=fimgsub*0.
quadpm=fimgsub*0.
quadmp=fimgsub*0.
quadpp(0:sub/2,0:sub/2)=fimgsub(0:sub/2,0:sub/2)
quadmm(sub/2:sub-1,sub/2:sub-1)=fimgsub(sub/2:sub-1,sub/2:sub-1)
quadpm(0:sub/2,sub/2:sub-1)=fimgsub(0:sub/2,sub/2:sub-1)
quadmp(sub/2:sub-1,0:sub/2)=fimgsub(sub/2:sub-1,0:sub/2)

;goto,af
!p.multi=[0,2,3]
imgplot,imgsub
imgplot,alog10(abs(fimgsub))
imgplot,fft(quadpp,/inverse)
imgplot,fft(quadpm,/inverse)
imgplot,fft(quadmm,/inverse)
imgplot,fft(quadmp,/inverse)
!p.multi=0

af:

sig1=fft(quadpp,/inverse)
sig2=fft(quadpm,/inverse)
;endfor
;device,decomp=0
;tek_color
;plot,dat(*,0),yr=[0,2.5e4]
;for i=0,nrun-1 do oplot,dat(*,i),col=i+1

end
