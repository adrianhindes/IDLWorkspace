pro calccut,img,px,py,nnx,nny,doplot=doplot


;imgplot,img,/cb
img2=img & idx=where(finite(img) eq 0) & if idx(0) ne -1 then img2(idx)=0.
sx=totaldim(img2,[0,1])
sy=totaldim(img2,[1,0])

;plot,sx,pos=posarr(2,1,0)
;plot,sy,pos=posarr(/next),/noer

sz=size(img,/dim)
nx=sz(0)
ny=sz(1)
bl=fltarr(2,2,2)
tr=fltarr(2,2,2)
pc=fltarr(2,2,2)

ix=findgen(nx/2)+nx/4
iy=findgen(ny/2)+ny/4

dum=min(sx(ix),imin) & pcx=ix(imin)
dum=min(sy(iy),imin) & pcy=iy(imin)


nnx=min([pcx-1 - 0 + 1, nx-1 - (pcx+1) + 1])
nny=min([pcy-1 - 0 + 1, ny-1 - (pcy+1) + 1])

xx=[-nnx,-1,1,nnx] + pcx
yy=[-nny,-1,1,nny] + pcy
;stop
px=fltarr(2,2,2,2)
py=px
for i=0,1 do for j=0,1 do for i2=0,1 do for j2=0,1 do begin
   px(i,j,i2,j2) = xx(2*i+i2)
   py(i,j,i2,j2) = yy(2*j+j2)
endfor
;    pc(i,j,0) = pcx + (2*i-1) *(nnx/2.+1)
;    pc(i,j,1) = pcy + (2*j-1) *(nny/2.+1)
;    bl(i,j,*)=pc(i,j,*)-[nnx/2.,nny/2.]
;    tr(i,j,*)=pc(i,j,*)+[nnx/2.,nny/2.]
; endfor


if keyword_set(doplot) then begin
imgplot,img,/cb
plots,pcx,pcy,psym=4
ln1=[0,1,1,0,0]
ln2=[0,0,1,1,0]

 for i=0,1 do for j=0,1 do begin
    xd=fltarr(5)
    yd=xd
    for k=0,4 do begin
       xd(k)=px(i,j,ln1(k),ln2(k))
       yd(k)=py(i,j,ln1(k),ln2(k))
    endfor
   oplot,xd,yd
 endfor

endif

end



