; sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
;       filt:{type:'hat'},$
;       aoffs:60.,$
;       c1offs:180,$
;       c2offs:0,$
;       c3offs:0,$
;       fracbw:1.0,$
;       pixfringe:10.,$
;       typthres:'data',$
;       thres:0.1}
      
      
pro demodcs, img,outs, sets,doplot=doplot,zr=zr,noopl=noopl,newfac=newfac,linalong=linalong,save=save,override=override,downsamp=downsamp,exists=exists,testexists=testexists,rfac=rfac,dofifth=dofifth,r5fac=r5fac,plotwin=plotwin
;winset, filtset,otherset

if keyword_set(save) then begin
    home=getenv('HOME')
    home=home+'/tmp'  ;     if getenv('HOST') eq 'scucomp2.anu.edu.au' then
    if getenv('HOST') eq 'scucomp1.anu.edu.au' then home='/scratch/cam112'
    spawn,'hostname',host
    if host eq 'ikstar.nfri.re.kr' then home='/home/users/cmichael/tmp'

    fn=string(home,'/demod/',save.txt,save.shot,save.ix,format='(A,A,A,"_",I0,"_",I0,".hdf")')

    dum=file_search(fn,count=cnt)

    if cnt ne 0 and keyword_set(testexists) then begin
        exists=1
        return
    endif
    if cnt eq 0 and keyword_set(testexists) then begin
        exists=0
        return
    endif

    if cnt ne 0 and not keyword_set(override) then begin
;        restore,file=fn,/verb
        hdfrestoreext,fn,outs
        return
    endif
endif





    

default,newfac,1.
;c1,c2a,c2b,s3,c1r,c2ar,c2br,p2a,p2b,win=win,idxng=idxng,sub=sub,wintype=wintype,sgexp=sgexp,sgmul=sgmul,pixfringe=pixfringe,thres=thres,typthres=typthres,calcref=calcref,doplot=doplot,aoffs=aoffs,zr=zr,noopl=noopl,fracbw=fracbw

;default,thres,0.1
;default,typthres,'data'
;default,aoffs,0.

;default,wintype,'cos'

;cursor,dx,dy,/down
sz=size(img,/dim)
orig=sz/2

if istag(sets,'sub') then begin
    imgsub=img(orig(0)-sets.sub(0)/2:orig(0)+sets.sub(0)/2-1,$
               orig(1)-sets.sub(1)/2:orig(1)+sets.sub(1)/2-1)
endif else imgsub=img

szs=size(imgsub,/dim)
ix=findgen(szs(0))/szs(0)-0.5
iy=findgen(szs(1))/szs(1)-0.5

wx=hats(0,.5,ix,set=sets.win,dopl=doplh)
wy=hats(0,.5,iy,set=sets.win,dopl=doplh)
if keyword_set(plotwin) then begin
    plot,wx
    stop
endif

win=transpose(wy) ## (wx)
imgsub*=win

getfftix, szs,ix,iy,ix2,iy2, ang2

fimgsub=fft(imgsub)
print,'done forward fft'
;retall

a3=75*!dtor+sets.aoffs*!dtor+sets.c3offs*!dtor
a5=a3 + !pi/2

a1=-60*!dtor+sets.aoffs*!dtor+sets.c1offs*!dtor
a2=30*!dtor+sets.aoffs*!dtor+sets.c2offs*!dtor

;default,pixfringe,20 ; pcoedgew 105 lens , 10 is for pixvision w 50mm lens
r0=1./sets.pixfringe
default, rfac, sqrt(2) 
r1=r0*rfac
default,r5fac,rfac
r5=r0*r5fac
r2=r1
;default,fracbw,0.5
rad=r0/2 * sets.fracbw; for half harmonic no contam
;fimgsub(0,0)=0.

rr4 = sqrt((ix2)^2 + (iy2)^2 )
doplh=0
f4= hats(0,rad,rr4,set=sets.filt,dopl=doplh)

if keyword_set(dofifth) then begin
    rr5 = sqrt((ix2-r5*cos(a5))^2 + $
               (iy2-r5*sin(a5))^2)
    f5= hats(0,rad,rr5,set=sets.filt,dopl=doplh)
endif

rr3 = sqrt((ix2-r0*cos(a3))^2 + $
      (iy2-r0*sin(a3))^2)
f3= hats(0,rad,rr3,set=sets.filt,dopl=doplh)


rr1 = sqrt((ix2-r1*cos(a1))^2 + $
      (iy2-r1*sin(a1))^2)
f1= hats(0,rad,rr1,set=sets.filt,dopl=doplh)

rr2 = sqrt((ix2-r2*cos(a2))^2 + $
      (iy2-r2*sin(a2))^2)
f2= hats(0,rad,rr2,set=sets.filt,dopl=doplh)


c4=(fft((fimgsub) * f4,/inverse))
print,'done ifft intens'

c3=(fft((fimgsub) * f3,/inverse))
print,'done ifft circ'

if keyword_set(dofifth) then begin
    c5=(fft((fimgsub) * f5,/inverse))
    print,'done ifft circ fifth'
endif

c1=(fft((fimgsub) * f1,/inverse))
print,'done ifft lin1'
c2=(fft((fimgsub) * f2,/inverse))
print,'done ifft lin2'


;cmb=sqrt(abs(c1)^2+abs(c2)^2)
if sets.typthres eq 'data' then $
  idxng=where(abs(c4)/max(abs(c4)) lt sets.thres)
if sets.typthres eq 'win' then $
  idxng=where(win lt sets.thres)

if keyword_set(dofifth) then c5(idxng)=!values.f_nan
c4(idxng)=!values.f_nan
c1(idxng)=!values.f_nan
c2(idxng)=!values.f_nan
c3(idxng)=!values.f_nan

if keyword_set(downsamp) then begin
    szz=sz/sets.pixfringe
    c1=congrid(c1,szz(0),szz(1))
    c2=congrid(c2,szz(0),szz(1))
    c3=congrid(c3,szz(0),szz(1))
    c4=congrid(c4,szz(0),szz(1))
    if keyword_set(dofifth) then c5=congrid(c5,szz(0),szz(1))
endif



outs={c1:c1,c2:c2,c3:c3,c4:c4};},$
;      idxng:idxng}
if keyword_set(dofifth) then outs=create_struct(outs,'c5',c5)

if not keyword_set(doplot) then goto,nopl
;!p.multi=[0,4,4]


s3a=sin(atan(abs(c3) ,2*abs(c1)))
s3b=sin(atan(abs(c3) ,2*abs(c2)))
s3c=sin(atan(abs(c3) ,abs(c1)+abs(c2)))

if keyword_set(linalong) then pos=posarr(2,1,0) else if not keyword_set(dofifth) then pos=posarr(4,3,0) else pos=posarr(4,4,0)
erase

;ixs=shift(ix,(szs(0)/2-1))
;iys=shift(iy,(szs(1)/2-1))

;ixs=shift(ix,(szs(0)/2))
;iys=shift(iy,(szs(1)/2))

ixs=shift(ix,((szs(0)-1)/2))
iys=shift(iy,((szs(1)-1)/2))
fimgsubs=shift(fimgsub,(szs(0)-1)/2,(szs(1)-1)/2)

r0c=r0;0.1
xr=[-1,1]*2.5*r0c*newfac&yr=[-1,1]*2.5*r0c*newfac

imgplot,alog10(abs(fimgsubs)),ixs,iys,xr=xr,yr=yr,/iso,/cb,zr=zr,pos=pos,/noer&pos=posarr(/next)


if keyword_set(linalong) then begin
if finite(linalong) eq 0 then begin
    oplot,ixs,ixs*tan(a3),col=4
    oplot,ixs,sqrt(r0^2-ixs^2)
    oplot,ixs,-sqrt(r0^2-ixs^2)

    imgplot,abs(c3),/cb,/iso,pos=pos,/noer,cont=cont,nl=nl,title='c3'&pos=posarr(/next)

    return
endif
nn=1000
rr=linspace(0,.5,nn)
oplot,rr*cos(linalong),rr*sin(linalong),col=4

iix=interpol(findgen(sz(0)),ixs,rr*cos(linalong))
iiy=interpol(findgen(sz(1)),iys,rr*sin(linalong))
zz=interpolate(fimgsubs,iix,iiy)
plot,rr,alog10(abs(zz)),pos=pos,/noer

return
endif



;,xr=[0,50],yr=[sub-50,sub-1]

if not keyword_set(noopl) then oplot,ixs,ixs*tan(a3),col=4
if not keyword_set(noopl) then oplot,ixs,ixs*tan(a1)

if not keyword_set(noopl) then oplot,ixs,ixs*tan(a2)

if not keyword_set(noopl) then oplot,ixs,sqrt(r0^2-ixs^2)
if not keyword_set(noopl) then oplot,ixs,-sqrt(r0^2-ixs^2)

if not keyword_set(noopl) then oplot,ixs,sqrt(r1^2-ixs^2)
if not keyword_set(noopl) then oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f3)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f3',xr=xr,yr=yr,pos=pos,/noer,zr=zr&pos=posarr(/next)
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f1)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f1',xr=xr,yr=yr,pos=pos,/noer,zr=zr&pos=posarr(/next)
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

imgplot,shift((alog10( abs(fimgsub * f2)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f2',xr=xr,yr=yr,pos=pos,/noer,zr=zr&pos=posarr(/next)
oplot,ixs,sqrt(r0^2-ixs^2)
oplot,ixs,-sqrt(r0^2-ixs^2)

oplot,ixs,sqrt(r1^2-ixs^2)
oplot,ixs,-sqrt(r1^2-ixs^2)

if keyword_set(dofifth) then begin
    imgplot,shift((alog10( abs(fimgsub * f5)>1e-5 )), szs(0)/2-1,szs(1)/2-1),ixs,iys,/iso,/cb,title='f5',xr=xr,yr=yr,pos=pos,/noer,zr=zr&pos=posarr(/next)
    oplot,ixs,sqrt(r5^2-ixs^2)
    oplot,ixs,-sqrt(r5^2-ixs^2)

endif

;stop
;imgplot,float(fft((fimgsub) ,/inverse)),/iso,/cb,pos=pos,/noer&pos=posarr(/next)

;stop

;imgplot,float(c1),/iso,/cb,pos=pos,/noer&pos=posarr(/next)
;imgplot,float(c2a),/iso,/cb,pos=pos,/noer&pos=posarr(/next)
;imgplot,float(c2b),/iso,/cb,pos=pos,/noer&pos=posarr(/next)
nl=2
cont=0
if keyword_set(dofifth) then imgplot,abs(c5),/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='c5',zr=zraa&pos=posarr(/next)

imgplot,abs(c4),/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='c0',zr=zraa&pos=posarr(/next)
imgplot,abs(c3),/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='c3'&pos=posarr(/next)
imgplot,abs(c1),/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='c1'&pos=posarr(/next)
imgplot,abs(c2),/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='c2'&pos=posarr(/next)
imgplot,abs(c1)+abs(c2),/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='c1+c2'&pos=posarr(/next)

imgplot,s3a,/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='s3/c1'&pos=posarr(/next)
imgplot,s3b,/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='s3/c2'&pos=posarr(/next)
;imgplot,s3c,/cb,/iso,pos=pos,/noer,cont=cont,/rev,nl=nl,title='s3/c1+c2'&pos=posarr(/next)


!p.multi=0
stop
nopl:

if n_elements(fn) ne 0 then hdfsaveext,fn,outs

;if n_elements(fn) ne 0 then save,outs,file=fn,/verb,/compress

end
