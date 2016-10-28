function getimg, num,sm=sm

path='~/kstartestimages'

fil=path+'/run'+string(num,format='(I0)')+'.tif'
print,findfile(fil)
d=read_tiff(fil,/verb)
slice=d

if keyword_set(sm) then begin
    sz=size(d,/dim)
    sz2=sz / sm
;    d2=fltarr(sz2(0),sz2(1))
    slice=congrid(slice,sz2(0),sz2(1))
;    stop
endif
    
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
ix=findgen(nx)
iy=findgen(ny)
i1=where(ix gt nx/2)
ix(i1)=ix(i1)-nx
i2=where(iy gt ny/2)
iy(i2)=iy(i2)-ny

ix/=nx
iy/=ny

ix2=ix # replicate(1,ny)
iy2=replicate(1,nx) # iy
ang2=atan(float(iy2),float(ix2))

end


pro demod, img,c1,c2a,c2b,s3,c1r,c2ar,c2br,p2a,p2b,win=win,idxng=idxng,sub=sub,wintype=wintype,sgexp=sgexp,sgmul=sgmul,pixfringe=pixfringe,thres=thres,typthres=typthres,calcref=calcref,doplot=doplot
default,thres,0.1
default,typthres,'data'

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

a0=75*!dtor
a1=-60*!dtor
a2=30*!dtor
default,pixfringe,20 ; pcoedgew 105 lens , 10 is for pixvision w 50mm lens
r0=1./pixfringe
r1=r0*sqrt(2) 
r2=r1

rad=r0/2*0.8
fimgsub(0,0)=0.

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


c1=(fft((fimgsub) * f0,/inverse))
print,'done ifft circ'

c2a=(fft((fimgsub) * f1,/inverse))
print,'done ifft lin1'
c2b=(fft((fimgsub) * f2,/inverse))
print,'done ifft lin2'

c1r=(fft((fimgsub) * f0r,/inverse))
print,'done ifft circref'

if keyword_set(calcref) then begin
    c2ar=(fft((fimgsub) * f1r,/inverse))
    c2br=(fft((fimgsub) * f2r,/inverse))
    p2a=atan2(c2a/c2ar)
    p2b=atan2(c2b/c2br)
endif

c1c=c1/c1r

sc1c = float(c1c)/abs(float(c1c))

s3=sin(atan(abs(c1) * sc1c,2*abs(c2a)))
stop
;idxng=where(win lt thres)
cmb=sqrt(abs(c2a)^2+abs(c2b)^2)
if typthres eq 'data' then $
  idxng=where(cmb/max(cmb) lt thres)
if typthres eq 'win' then $
  idxng=where(win lt thres)

s3(idxng)=!values.f_nan
if not keyword_set(doplot) then goto,nopl
!p.multi=[0,4,4]

ixs=shift(ix,szs(0)/2-1)
iys=shift(iy,szs(1)/2-1)
fimgsubs=shift(fimgsub,szs(0)/2-1,szs(1)/2-1)

xr=[-1,1]*2.5*r0&yr=[-1,1]*2.5*r0

imgplot,alog10(abs(fimgsubs)),ixs,iys,xr=xr,yr=yr,/iso,/cb

;,xr=[0,50],yr=[sub-50,sub-1]
oplot,ixs,ixs*tan(a0)
oplot,ixs,ixs*tan(a1)

oplot,ixs,ixs*tan(a2)

oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f0)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f0',xr=xr,yr=yr
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f1)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f1',xr=xr,yr=yr
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f2)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f2',xr=xr,yr=yr
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)


;stop
imgplot,float(fft((fimgsub) ,/inverse)),/iso,/cb

;stop

imgplot,float(c1),/iso,/cb
imgplot,float(c2a),/iso,/cb
imgplot,float(c2b),/iso,/cb

imgplot,abs(c1),/cb,/iso
imgplot,abs(c2a),/cb,/iso
imgplot,abs(c2b),/cb,/iso
imgplot,s3,/cb,/iso



!p.multi=0
stop
nopl:

end

pro circtest
;rarr=[23,24,26,27,29,30,32,31];16];3,5,6,10,11,12]
;rarr=[26,29,32]
;rarr=[33,34]
;rarr=[35,39,38] ; no window, contiguous
;rarr=[36,40,37] ; window,contiguous
;rarr=[45,46,47];win img
;rarr=[44,43,42] ;nowin img
;rarr=[44,45]; nowin/win

;rarr=[49,48]; nowin/win

;rarr=[54,55]
rarr=[50,51,52,53,54]


nrun=n_elements(rarr)


;d;at=fltarr(nx,nrun)
;for i=0,nrun-1 do begin
;    dat(*,i)

s3arr=fltarr(nrun)
s3arr2=fltarr(nrun)
pcent=fltarr(nrun)
!p.multi=[0,2,3]
for i=0,nrun-1 do begin
    sm=4
    img=getimg(rarr(i),sm=sm)
    demod, img,c1,c2a,c2b,s3,idxng=idx,thres=0.01,pixfringe=20/sm;,sub=[512,384]
    sz=size(c1,/dim)
    ;,c1r,c2ar,c2br,p2a,p2b
    if i eq 0 then begin
        c1r=c1
        c2ar=c2a
        c2br=c2b
    endif
    c2ac = c2a/c2ar
    c2bc = c2b/c2br
    p2a=atan2(c2ac)
    p2b=atan2(c2bc)
    p2a(idx)=!values.f_nan
    p2b(idx)=!values.f_nan
    pcent(i)=p2b(sz(0)/2,sz(1)/2)

    s3arr(i)=s3(sz(0)/2,sz(1)/2)
    s3arr2(i)=s3(sz(0)/2*0.8,sz(1)/2*0.8)
;    stop
    imgplot,s3,/cb,title=rarr(i),zr=[0,.3]
;    stop
endfor
!p.multi=0
stop
;plot,s3arr
;oplot,s3arr2,col=2
;stop
end
circtest
;linpolscan

end
