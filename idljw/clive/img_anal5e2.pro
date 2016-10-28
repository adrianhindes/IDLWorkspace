@simimg3
function getimg, num,sm=sm,index=index

path='~/kstartestimages'

fil=path+'/run'+string(num,format='(I0)')+'.tif'
print,findfile(fil)
d=read_tiff(fil,/verb,image_index=index)
slice=d
;stop
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
iarr=replicate(0,n_elements(rarr))
sm=2;4
presm=1
aoffs=0.

; new ones
;rarr=replicate(60,10)&iarr=intspace(0,9)
;rarr=[64,65]&iarr=[0,0]
;rarr=[64,replicate(66,9)]&iarr=[0,intspace(0,8)]
;rarr=[67,replicate(68,15)]&iarr=[0,intspace(0,14)]
rarr=replicate(69,15)&iarr=intspace(0,14)

;rarr=replicate(85,50)&iarr=intspace(0,49)

sm=1&presm=2&aoffs=-30+90
renorm=1

sim=0
sim=1&rarr=replicate(74,17)&iarr=intspace(0,17) & rarr=replicate(69,18)

angarr=shift(linspace(0,!pi,n_elements(iarr)),-1)
    

nrun=n_elements(iarr)


;d;at=fltarr(nx,nrun)
;for i=0,nrun-1 do begin
;    dat(*,i)

common cbssb,sz,pcent,p2cstore
;goto,aa

s3arr=fltarr(nrun)
s3arr2=fltarr(nrun)
pcent=fltarr(nrun)
;!p.multi=[0,4,4]
poslin,nrun,nx,ny
pos=posarr(nx,ny,0,msratx=5) & erase
for i=0,nrun-1 do begin

    if sim eq 1 then $
      img=simimg3(angarr(i),sm=presm)*8000. $
    else $
      img=getimg(rarr(i),sm=sm,index=iarr(i))


;    imgplot,img,/cb
;    wait,1
;    continue
    
    demod, img,c1,c2a,c2b,s3,idxng=idx,thres=0.05,pixfringe=20/presm/sm,aoffs=aoffs,wintype='sg',typthres='data';,/dopl
;    stop
;,sub=[512,384]
    sz=size(c1,/dim)
    ;,c1r,c2ar,c2br,p2a,p2b
    if i eq 0 then begin
        c1r=c1
        c2ar=c2a
        c2br=c2b

        s3store=fltarr(sz(0),sz(1),nrun)
        p2bstore=s3store
        p2astore=s3store
        p2cstore=s3store

    endif
    c2ac = c2a/c2ar
    c2bc = c2b/c2br

    sc2ac = float(c2ac)/abs(float(c2ac))
    sc2bc = float(c2bc)/abs(float(c2bc))

    cp2a=atan2(c2ac*sc2ac)
    cp2b=atan2(c2bc*sc2bc)
    cp2a(idx)=!values.f_nan
    cp2b(idx)=!values.f_nan


    c1c=c1/c1r
    sc1c = float(c1c)/abs(float(c1c))


    p2a=atan(abs(c1) * sc1c,2*abs(c2a)*sc2ac)
    p2b=atan(abs(c1) * sc1c,2*abs(c2b)*sc2bc)
    p2c=atan(abs(c1) * sc1c,(abs(c2b)*sc2bc + abs(c2a)*sc2ac) )

    p2a(idx)=!values.f_nan
    p2b(idx)=!values.f_nan
    p2c(idx)=!values.f_nan
    pcent(i)=p2c(sz(0)/2,sz(1)/2)

    p2astore(*,*,i)=p2a
    p2bstore(*,*,i)=p2b
    p2cstore(*,*,i)=p2b
    s3store(*,*,i)=cp2a

    s3arr(i)=s3(sz(0)/2,sz(1)/2)
    s3arr2(i)=s3(sz(0)/2*0.8,sz(1)/2*0.8)
;    stop

;    imgplot,s3,/cb,title=string(rarr(i),iarr(i),format='(I0,"_",I0)'),zr=[-0.2,0.2],pal=-2
;    imgplot,cp2b,/cb,title=string(rarr(i),iarr(i),format='(I0,"_",I0)'),zr=[-0.2,0.2],pal=-2


    imgplot,p2b,/cb,title=string(rarr(i),iarr(i),format='(I0,"_",I0)'),pos=pos,/noer,xsty=5,ysty=5 &    pos=posarr(/next)
    imgplot,p2a,/cb,title=string(rarr(i),iarr(i),format='(I0,"_",I0)'),pos=pos,/noer,xsty=5,ysty=5 & pos=posarr(/next)


   imgplot,p2c,/cb,title=string(rarr(i),iarr(i),format='(I0,"_",I0)'),pos=pos,/noer,xsty=5,ysty=5 & pos=posarr(/next)


endfor
!p.multi=0
stop

aa:
ca=[0.1,0.5]
ia=intspace(1,9)*0.1
ib=ia
na=n_elements(ia)
ia2=ia # replicate(1,na)
ib2=replicate(1,na) # ib
iaf=reform(ia2,n_elements(ia2))
ibf=reform(ib2,n_elements(ia2))
s3a=fltarr(na^2,nrun)
for i=0,na^2-1 do s3a(i,*)=p2cstore(iaf(i)*sz(0),ibf(i)*sz(1),*)

xx=phs_jump(pcent)/2 /2/!pi ; 2*!pi-
xxb=phs_jump(pcent)/2
plotm,xx,transpose(s3a),psym=-4
;plot,-phs_jump(pcent)/2/!pi,s3store(sz(0)*ca(0),sz(1)*ca(1),*),psym=-4,xticklen=1
stop
s1 = cos(2*(xxb(i0:*)-!pi/4))
s2 = sin(2*(xxb(i0:*)-!pi/4))

s3fit=reform(s3store(0.5*sz(0),0.5*sz(1),i0:*))
rc=regress(transpose([[s1],[s2]]),s3fit,yfit=s3fit2)
plot,s3fit,s3fit2
oplot,s3fit,s3fit,col=2
;

;plot,s3arr
;oplot,s3arr2,col=2
;stop
end
circtest
;linpolscan

end
