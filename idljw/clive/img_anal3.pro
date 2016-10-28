function getimg, num

path='~/kstartestimages'

fil=path+'/run'+string(num,format='(I0)')+'.tif'
print,findfile(fil)
d=read_tiff(fil,/verb)
slice=d
return,slice
end

function hatper, th0, thw, ang
ang2=ang+2*!pi
ang3=ang-2*!pi
rval1= ang gt th0-thw/2 and ang lt th0+thw/2
rval2= ang2 gt th0-thw/2 and ang2 lt th0+thw/2
rval3= ang3 gt th0-thw/2 and ang3 lt th0+thw/2
rval=rval1+rval2+rval3
return,rval
end

function hat, th0, thw, ang
rval1= ang gt th0-thw/2 and ang lt th0+thw/2
return,rval1
end

pro getfftix, sz,ix,iy,ix2,iy2, ang2
nx=sz(0)
ny=sz(1)
ix=indgen(nx)
iy=indgen(ny)
i1=where(ix gt nx/2)
ix(i1)=ix(i1)-nx
i2=where(iy gt ny/2)
iy(i2)=iy(i2)-ny
ix2=ix # replicate(1,ny)
iy2=replicate(1,nx) # iy
ang2=atan(float(iy2),float(ix2))

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

getfftix, [sub,sub],ix,iy,ix2,iy2, ang2

!p.multi=[0,4,3]
a0=75*!dtor
a1=-60*!dtor
a2=30*!dtor
fimgsub(0,0)=0.
contourn2,(abs(fimgsub)),/cb,/iso

oplot,ix*tan(a0)
oplot,ix*tan(a0)+sub

oplot,ix*tan(a1)
oplot,ix*tan(a1)+sub

oplot,ix*tan(a2)
oplot,ix*tan(a2)+sub


;contourn2, hatper(a0, 5*!dtor, ang2),/iso,/cb

wid=5*!dtor

contourn2,alog10(abs(fimgsub) * hatper(a0, wid, ang2)),/iso,/cb
contourn2,alog10(abs(fimgsub) * hatper(a1, wid, ang2)),/iso,/cb
contourn2,alog10(abs(fimgsub) * hatper(a2, wid, ang2)),/iso,/cb

contourn2,float(fft((fimgsub) ,/inverse)),/iso,/cb
contourn2,float(fft((fimgsub) * hatper(a0, wid, ang2),/inverse)),/iso,/cb
contourn2,float(fft((fimgsub) * hatper(a1, wid, ang2),/inverse)),/iso,/cb
contourn2,float(fft((fimgsub) * hatper(a2, wid, ang2),/inverse)),/iso,/cb

;contourn2,atan2(fft((fimgsub) * hatper(a0, wid, ang2),/inverse)),/iso,/cb,pal=-2
;contourn2,atan2(fft((fimgsub) * hatper(a1, wid, ang2),/inverse)),/iso,/cb,pal=-2
;contourn2,atan2(fft((fimgsub) * hatper(a2, wid, ang2),/inverse)),/iso,/cb,pal=-2
c1=abs(fft((fimgsub) * hatper(a0, wid, ang2),/inverse))

c2a=abs(fft((fimgsub) * hatper(a1, wid, ang2),/inverse))
c2b=abs(fft((fimgsub) * hatper(a2, wid, ang2),/inverse))

contourn2,c1,/cb,/iso
contourn2,c2a,/cb,/iso
contourn2,c2b,/cb,/iso
contourn2,sin(atan(c1,2*c2b)/2),/cb,/iso,pal=-2

!p.multi=0

end
