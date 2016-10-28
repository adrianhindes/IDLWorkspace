pro demod, img,c1,c2a,c2b,s3,c1r,c2ar,c2br,p2a,p2b,win=win,idxng=idxng,sub=sub,wintype=wintype,sgexp=sgexp,sgmul=sgmul,pixfringe=pixfringe,thres=thres,typthres=typthres,calcref=calcref,doplot=doplot,aoffs=aoffs
default,thres,0.1
default,typthres,'data'
default,aoffs,0.

default,wintype,'cos'

;cursor,dx,dy,/down
sz=size(img,/dim)
orig=sz/2
if keyword_set(sub) then begin
    imgsub=img(orig(0)-sub(0)/2:orig(0)+sub(0)/2-1,$
               orig(1)-sub(1)/2:orig(1)+sub(1)/2-1)
endif else imgsub=img

szs=size(imgsub,/dim)
ix=findgen(szs(0))/szs(0)-0.5
iy=findgen(szs(1))/szs(1)-0.5

if wintype eq 'cos' then begin
    wx=cos(!pi*ix)
    wy=cos(!pi*iy)
endif 
if wintype eq 'sg' then  begin
    default,sgmul,1.
    default,sgexp,6.
    wx=hat(0,sgmul,!pi*ix,sgexp=sgexp)
    wy=hat(0,sgmul,!pi*iy,sgexp=sgexp)
endif

if wintype eq 'none' then begin
    wx=replicate(1.,szs(0))
    wy=replicate(1.,szs(1))
endif

win=transpose(wy) ## (wx)
imgsub*=win

getfftix, szs,ix,iy,ix2,iy2, ang2

fimgsub=fft(imgsub)
print,'done forward fft'
;retall

a0=75*!dtor+aoffs*!dtor
a1=-60*!dtor+aoffs*!dtor
a2=30*!dtor+aoffs*!dtor
default,pixfringe,20 ; pcoedgew 105 lens , 10 is for pixvision w 50mm lens
r0=1./pixfringe
r1=r0*sqrt(2) 
r2=r1

rad=r0/2*0.5*0.5
;fimgsub(0,0)=0.

rr00 = sqrt((ix2)^2 + $
      (iy2)^2)
f00= hat(0,rad,rr00)

rr0 = sqrt((ix2-r0*cos(a0))^2 + $
      (iy2-r0*sin(a0))^2)
f0= hat(0,rad,rr0)


rr1 = sqrt((ix2-r1*cos(a1))^2 + $
      (iy2-r1*sin(a1))^2)
f1= hat(0,rad,rr1)

rr2 = sqrt((ix2-r2*cos(a2))^2 + $
      (iy2-r2*sin(a2))^2)
f2= hat(0,rad,rr2)


dum=max(abs(fimgsub)*f0,i0)
dum=max(abs(fimgsub)*f1,i1)
dum=max(abs(fimgsub)*f2,i2)

f0r=f0*0 & f0r(i0)=1.
f1r=f1*0 & f1r(i1)=1.
f2r=f2*0 & f2r(i2)=1.

c0=(fft((fimgsub) * f00,/inverse))

c1=(fft((fimgsub) * f0,/inverse))
print,'done ifft circ'

c2a=(fft((fimgsub) * f1,/inverse))
print,'done ifft lin1'
c2b=(fft((fimgsub) * f2,/inverse))
print,'done ifft lin2'

;c1r=(fft((fimgsub) * f0r,/inverse))
;print,'done ifft circref'

if keyword_set(calcref) then begin
    c2ar=(fft((fimgsub) * f1r,/inverse))
    c2br=(fft((fimgsub) * f2r,/inverse))
    p2a=atan2(c2a/c2ar)
    p2b=atan2(c2b/c2br)
endif

;c1c=c1/c1r

sc1c = 1.;float(c1c)/abs(float(c1c))

s3a=sin(atan(abs(c1) * sc1c,2*abs(c2a)))
s3b=sin(atan(abs(c1) * sc1c,2*abs(c2b)))
s3c=sin(atan(abs(c1) * sc1c,abs(c2a)+abs(c2b)))
;stop
;idxng=where(win lt thres)
cmb=sqrt(abs(c2a)^2+abs(c2b)^2)
if typthres eq 'data' then $
  idxng=where(cmb/max(cmb) lt thres)
if typthres eq 'win' then $
  idxng=where(win lt thres)

s3a(idxng)=!values.f_nan
s3b(idxng)=!values.f_nan
s3c(idxng)=!values.f_nan
if not keyword_set(doplot) then goto,nopl
;!p.multi=[0,4,4]
pos=posarr(4,3,0)&erase

ixs=shift(ix,szs(0)/2-1)
iys=shift(iy,szs(1)/2-1)
fimgsubs=shift(fimgsub,szs(0)/2-1,szs(1)/2-1)

xr=[-1,1]*2.5*r0&yr=[-1,1]*2.5*r0

imgplot,alog10(abs(fimgsubs)),ixs,iys,xr=xr,yr=yr,/iso,/cb,zr=[-2,0],pos=pos,/noer&pos=posarr(/next)

;,xr=[0,50],yr=[sub-50,sub-1]
oplot,ixs,ixs*tan(a0),col=4
oplot,ixs,ixs*tan(a1)

oplot,ixs,ixs*tan(a2)

oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f0)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f0',xr=xr,yr=yr,pos=pos,/noer&pos=posarr(/next)
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f1)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f1',xr=xr,yr=yr,pos=pos,/noer&pos=posarr(/next)
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f2)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f2',xr=xr,yr=yr,pos=pos,/noer&pos=posarr(/next)
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)


;stop
;imgplot,float(fft((fimgsub) ,/inverse)),/iso,/cb,pos=pos,/noer&pos=posarr(/next)

;stop

;imgplot,float(c1),/iso,/cb,pos=pos,/noer&pos=posarr(/next)
;imgplot,float(c2a),/iso,/cb,pos=pos,/noer&pos=posarr(/next)
;imgplot,float(c2b),/iso,/cb,pos=pos,/noer&pos=posarr(/next)
nl=10
imgplot,abs(c0),/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='c0'&pos=posarr(/next)
imgplot,abs(c1),/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='d2'&pos=posarr(/next)
imgplot,abs(c2a),/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='d1+d2'&pos=posarr(/next)
imgplot,abs(c2b),/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='d1-d2'&pos=posarr(/next)
imgplot,abs(c2a)+abs(c2b),/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='d1+d2 plus d1-d2'&pos=posarr(/next)

imgplot,s3a,/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='s3/d1+d2'&pos=posarr(/next)
imgplot,s3b,/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='s3/d1-d2'&pos=posarr(/next)
imgplot,s3c,/cb,/iso,pos=pos,/noer,/cont,/rev,nl=nl,title='s3/d1+d2 plus d1-d1'&pos=posarr(/next)


!p.multi=0
stop
nopl:
s3=s3a

end
