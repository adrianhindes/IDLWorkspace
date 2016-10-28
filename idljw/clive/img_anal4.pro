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

function hat, th0, thw, ang,sgexp=sgexp
;rval1= ang gt th0-thw/2 and ang lt th0+thw/2
; make exp-6
default,sgexp,4
rval1 = exp( - ((ang - th0)/thw)^sgexp)
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

sub=128*2
;cursor,dx,dy,/down
sz=size(img,/dim)
orig=sz/2
imgsub=img(orig(0)-sub/2:orig(0)+sub/2-1,$
           orig(1)-sub/2:orig(1)+sub/2-1)

ix=findgen(sub)/sub-0.5
wx=cos(!pi*ix)
;wx=hat(0,1.,!pi*ix,sgexp=6.)
wy=wx
plot,wx
wait,1
win=transpose(wx) ## (wy)
imgsub*=win
;imgplot,imgsub


getfftix, [sub,sub],ix,iy,ix2,iy2, ang2

fimgsub=fft(imgsub)

;retall

!p.multi=[0,4,4]
a0=75*!dtor
a1=-60*!dtor
a2=30*!dtor
r0=12.9 * sub/128
r1=r0*sqrt(2) 
r2=r1

rad=r0/2
fimgsub(0,0)=0.
contourn2,(abs(fimgsub)),/cb,/iso
goto,nopl
oplot,ix*tan(a0)
oplot,ix*tan(a0)+sub

oplot,ix*tan(a1)
oplot,ix*tan(a1)+sub

oplot,ix*tan(a2)
oplot,ix*tan(a2)+sub

oplot,sqrt(r0^2-ix^2)
oplot,sub-sqrt(r0^2-ix^2)

oplot,sqrt(r1^2-ix^2)
oplot,sub-sqrt(r1^2-ix^2)
nopl:
;contourn2, hatper(a0, 5*!dtor, ang2),/iso,/cb


;!p.multi=0&retall
rr0 = sqrt((ix2-r0*cos(a0))^2 + $
      (iy2-r0*sin(a0))^2)
f0= hat(0,rad,rr0)

rr1 = sqrt((ix2-r1*cos(a1))^2 + $
      (iy2-r1*sin(a1))^2)
f1= hat(0,rad,rr1)

rr2 = sqrt((ix2-r2*cos(a2))^2 + $
      (iy2-r2*sin(a2))^2)
f2= hat(0,rad,rr2)

contourn2,(abs(fimgsub) * f0),/iso,/cb,title='f0'
contourn2,(abs(fimgsub) * f1),/iso,/cb,title='f1'
contourn2,(abs(fimgsub) * f2),/iso,/cb,title='f2'

contourn2,float(fft((fimgsub) ,/inverse)),/iso,/cb




c1=(fft((fimgsub) * f0,/inverse))
c2a=(fft((fimgsub) * f1,/inverse))
c2b=(fft((fimgsub) * f2,/inverse))

contourn2,float(c1),/iso,/cb
contourn2,float(c2a),/iso,/cb
contourn2,float(c2b),/iso,/cb

contourn2,abs(c1),/cb,/iso
contourn2,abs(c2a),/cb,/iso
contourn2,abs(c2b),/cb,/iso
contourn2,sin(0.5*atan(abs(c1),2*abs(c2a))),/cb,/iso,pal=-2

!p.multi=0

end
