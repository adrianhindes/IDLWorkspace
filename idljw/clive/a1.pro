

pro a1,sh,freqshot,tr2,ex,outr=outr,want=want,out2r=out2r,rout=rout,nostop=nostop,lvonly=lvonly,rxs=rxs,rys=rys,docalc=docalc,scal=scal
default,scal,1.
tr=tr2


if !version.os eq 'Win32' then begin
   base='C:\dstore\demod'
endif else base='~'

demodtype='sm32013mse'
if not keyword_set(docalc) then goto,ee

;if sh eq 13366 then begin
;   mdsopen,'mse_2015_prc',sh
;endif

;tr=tr2
if (sh ge 9323 and sh le 9327 ) then begin
   newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype=demodtype,/cachewrite,cacheread=0
;tr=tr2
   newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype=demodtype,nsm=1,nskip=1,/cachewrite,cacheread=0


;   res1=temporary(res);,demodtype=demodtype
;   newdemodflcshot,sh,tr,/only2,rresref=res1,res=res,nsm=1,nskip=1,/cachewrite
endif else if sh ge 13366 then begin
;ash
   newdemodashshot,sh,tr,res=res,cacheread=1,tskip=1,/cachewrite;demodtype=demodtype,

endif else begin
   newdemodflcshot,sh,tr,/only2,res=res,nskip=1,cacheread=0,demodtype=demodtype,tskip=1,/cachewrite
;   newdemodflcshot,sh,tr,/only2,res=res,/cachewrite,nskip=1,cacheread=1,demodtype=demodtype


endelse



save,res,file=base+'/resx'+ex+string(sh,format='(I0)')+'.sav'
stop
ee:
restore,file=base+'/resx'+ex+string(sh,format='(I0)')+'.sav'
;if sh eq 13366 then res.ang=res.ang*!dtor
if sh eq 11004 or sh eq 11003 then begin
   tsub=[2.45,2.475,5.775,5.80,5.825]
   i0=[-1,-2,-1,-2,-3]
   i1=[2,1,3,2,1]
   if sh eq 11003 then begin
      tsub=[tsub,4.00]
      i0=[i0,-1]
      i1=[i1,1]
   endif

endif

if sh eq 11433 and ex eq 'a' then begin
   tsub=[3.425,3.455]
   i0=[-1,2]
   i1=[2,1]
endif

if sh eq 11433 and ex eq 'b' then begin
   tsub=[5.585, 5.615]
   i0=[-1,2]
   i1=[2,1]
endif

if sh eq 13491 then begin
   idx=where(finite(res.ang) eq 0)
   res.ang(idx)=0.
endif



;if sh eq 13491 and ex eq 'a' then begin
;   tsub=[4.430,4.440,4.55,4.560]
;   i0=[-1,-2,-1,-2]
;   i1=[2 ,1, 2,1]
;endif


nn=n_elements(tsub)
for j=0,nn-1 do begin
   iw=value_locate(res.t,tsub(j))
   res.ang(*,*,iw)=0.5 * (res.ang(*,*,iw+i1(j)) + res.ang(*,*,iw + i0(j)))
   res.inten(*,*,iw)=0.5 * (res.inten(*,*,iw+i1(j)) + res.inten(*,*,iw + i0(j)))
endfor

imax=fltarr(n_elements(res.t))
for i=0,n_elements(res.t)-1 do begin
   imax(i)=max(res.inten(*,*,i),/nan)
endfor


;stop
;stop
if sh gt 10000 and sh le 13300 then res.ang=(res.ang - 55+90) else if sh lt 10000 then res.ang=(res.ang - 8.)
;if sh eq 13
tmp=transpose(reform(res.ang(*,38,*)));-55
ix=where(res.r1 gt -210 and res.r1 lt -165)
nsub=3
ix2=ix(indgen(n_elements(ix)/nsub)*nsub)

;mkfig,'~/im_thist_'+string(sh,format='(I0)')+'.eps',xsize=13,ysize=20,font_size=9
;contourn2,tmp(*,ix),res.t,res.r1(ix),nl=21,[-20,20]/2,pos=posarr(1,3,0,cny=0.1,cnx=0.1),pal=2,offx=1,$
 ;       title='MSE polarisation angle #'+string(sh,format='(I0)'),ytitle='-R (cm)'

imgplot,tmp(*,ix),res.t,res.r1(ix),zr=[-20,20]/2,pos=posarr(1,3,0,cny=0.1,cnx=0.1),pal=-2,offx=1,$
        title='MSE polarisation angle #'+string(sh,format='(I0)'),ytitle='-R (cm)',ysty=1;,xr=[4.5,5.2]

;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
nb=cgetdata('\NB11_I0',sh=sh,db='kstar')
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
if (ex eq 'a' and sh eq 11433) or (sh eq 11434) then ec=cgetdata('\ECH_VFWD1',sh=sh,db='kstar')

if sh eq 13366 or sh eq 13368 then begin
tdum=10. + findgen(1e6)*1e-6
ec={t:tdum,v : -cos(2*!pi*10. * (tdum))+1}
endif

lv=cgetdata('\LV23',sh=sh,db='kstar')

ecv=interpolo(ec.v,ec.t,lv.t)

f=fft_t_to_f(lv.t,/neg)
s1=fft(ecv)
mxharmv=10/2
wid = 0.5
wid2 = 0.1
s1f=s1*0
t1=fft(lv.v)
t1f=t1*0.
for iharm=-mxharmv,mxharmv do begin
filt = exp(-(f-freqshot*iharm)^2 / (freqshot * wid)^2)
;oplot,f,filt,col=2
s1f+= s1 * filt
if iharm eq 0 then widq=wid else widq=wid2
filt = exp(-(f-freqshot*iharm)^2 / (freqshot * widq)^2)
t1f+= t1 * filt
endfor
;plot,f,abs(s1),/ylog,xr=[-20,20],psym=4
;oplot,f,abs(s1f),col=2
ecf=fft(s1f,/inverse)
lvf=fft(t1f,/inverse)

plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer,title='ECCD drive'
oplot,lv.t,ecf,col=2,thick=2
plot,nb.t,nb.v,xr=!x.crange,pos=posarr(/curr),/noer,col=2,xsty=4,ysty=4

;plot,lv.t,ecv,xr=tr,pos=posarr(1,2,0),xsty=1

;plot,lv.t,lv.v,xr=tr,pos=posarr(/next),/noer,xsty=1

;stop
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,ysty=8,title='Current  loop voltage',ytitle='loop voltage (V)'
oplot,lv.t,lvf,col=2,thick=2
oplot,!x.crange,[0,0]
ip=cgetdata('\RC01')
plot,ip.t,ip.v/100e3,xr=!x.crange,pos=posarr(/curr),/noer,col=3;,yr=-7e5/100e3+[-1,1]*10e4/100e3,ysty=1+4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=3,ytitle='current (x100kA)'
if not keyword_set(nostop) then stop
endfig,/gs,/jp


;stop
ec2=interpol(ec.v,ec.t,res.t)
f=fft_t_to_f(res.t)
isel=value_locate3(f,freqshot)
sz=size(res.ang,/dim)
amp=complexarr(sz(0),sz(1))
amp2=amp
amp3=amp

ampq=amp
amp2q=amp
amp3q=amp

ampr=amp
amp2r=amp
amp3r=amp

;  a=''&read,'',a
;  if a ne '' then stop

ix=[intspace(fix(isel * 0.5),fix(isel * 0.8)),$
    intspace(fix(isel * 1.2),fix(isel * 1.5))]

fec2=fft(ec2)
ampref=fec2(isel)
;stop
tmpp=res.ang
kern=fltarr(5,3,1)+1.
if sh eq 11004 or sh eq 11003 then kern=fltarr(10,5,1)+1.
if sh eq 9323 and ex eq 'b' then kern=fltarr(10,5,1)+1.
;if sh eq 9326 then kern=fltarr(10,5,1)+1.
if sh eq 9326 then kern=fltarr(3,5,1)+1.

if sh eq 13366 then kern=fltarr(10,5,1)+1.
if sh eq 13394 then kern=fltarr(10,5,1)+1.
if sh eq 13492 then kern=fltarr(10,5,1)+1.
if sh eq 13494 then kern=fltarr(10,5,1)+1.

for i=0,sz(2)-1 do tmpp(*,*,i)=convol(res.ang(*,*,i),kern/total(kern))

tmpq=tmpp*0
mu0=4*!pi*1e-7
for j=0,sz(1)-1 do for k=0,sz(2)-1 do begin
   tmpq(*,j,k)=-deriv(res.r1*0.01,tmpp(*,j,k)) / mu0 ;;! minus sign because "negative r"
endfor

tmpq2=tmpq
tmpp2=tmpp
tmpr=res.inten/max(res.inten)
tmpr2=tmpr*0


mxharm=5
if freqshot eq 10 then mxharm=2
if freqshot eq 2 then mxharm=9;10
for i=0,sz(0)-1 do begin
    for j=0,sz(1)-1 do begin
   dum=fft(reform(tmpp(i,j,*)))
   if finite(dum(0)) eq 0 then continue
   dum2=dum*0 &
   for iharm=0,mxharm do dum2(isel*iharm)=dum(isel*iharm)* ((iharm eq 0) ? 0.5 : 1)
   tmpp2(i,j,*)=float(fft(dum2,/inverse))*2

;if i eq -69 and j eq 31 then begin
;if i eq -69 and j eq 76/2 then begin
if i eq 58 and j eq 33 then begin
;if 1 eq 1  then begin
;   mkfig,'~/fplot.eps',xsize=15,ysize=11,font_size=12
   plot,f,abs(dum),/ylog,xr=[0,50],$
        pos=posarr(1,2,0),title='Fourier Domain',xtitle='F (Hz)'
   oplot,f(ix),abs(dum(ix)),psym=4;,title=string(res.r1(i),res.z1(j))
  plot,f,abs(fft(ec2)),col=2,/noer,/ylog,pos=posarr(/curr),xr=!x.crange,$
       ysty=4
  plot,res.t,tmpp(i,j,*),xtitle='time',ytitle='angle (deg)',$
       pos=posarr(/next),/noer,title='time domain'
  plot,res.t,ec2,xr=!x.crange,col=2,pos=posarr(/curr),/noer,ysty=4
;  wait,.1
;   a=''&read,'',a
  endfig,/gs,/jp
;  stop
endif
;  if a ne '' then stop
   amp(i,j)=dum(isel)
   amp2(i,j)=mean(abs(dum(ix)))
   amp3(i,j)=dum(0)
   print,i,j
endfor
endfor

for i=0,sz(0)-1 do begin
    for j=0,sz(1)-1 do begin
   dum=fft(reform(tmpq(i,j,*)))
   if finite(dum(0)) eq 0 then continue
   dum2=dum*0 &
   for iharm=0,mxharm do dum2(isel*iharm)=dum(isel*iharm)* ((iharm eq 0) ? 0.5 : 1)
   tmpq2(i,j,*)=float(fft(dum2,/inverse))*2

;   plot,f,abs(dum),title=res.r1(i),res.z1(j),/ylog
;   oplot,f(ix),abs(dum(ix)),psym=-4
;  plot,f,abs(fft(ec2)),col=2,/noer,/ylog
;   a=''&read,'',a
;  if a ne '' then stop
   ampq(i,j)=dum(isel)
   amp2q(i,j)=mean(abs(dum(ix)))
   amp3q(i,j)=dum(0)
   print,i,j
endfor
endfor

nt=n_elements(res.t)
for i=0,sz(0)-1 do begin
    for j=0,sz(1)-1 do begin
       num=findgen(nt)
       mask=(num le 19 or num ge 40)
   dum=fft(reform(tmpr(i,j,*)))
   if finite(dum(0)) eq 0 then continue
   dum2=dum*0 &
   for iharm=0,mxharm do dum2(isel*iharm)=dum(isel*iharm) * ((iharm eq 0) ? 0.5 : 1)
   tmpr2(i,j,*)=float(fft(dum2,/inverse))*2

;   plot,f,abs(dum),title=res.r1(i),res.z1(j),/ylog
;   oplot,f(ix),abs(dum(ix)),psym=-4
;  plot,f,abs(fft(ec2)),col=2,/noer,/ylog
;   a=''&read,'',a
;  if a ne '' then stop

   ampr(i,j)=dum(isel)
   amp2r(i,j)=mean(abs(dum(ix)))
   amp3r(i,j)=dum(0)
   print,i,j
endfor
endfor


tref = tr(0);+0.5 + 25e-3;+0.1
tmp2old=tmpp2
ix=value_locate3(res.t,tref)
for i=0,n_elements(res.t)-1 do begin
   tmpp2(*,*,i)=tmp2old(*,*,i) - tmp2old(*,*,ix)
endfor

tmp2old=tmpq2
ix=value_locate3(res.t,tref)
for i=0,n_elements(res.t)-1 do begin
   tmpq2(*,*,i)=tmp2old(*,*,i) - tmp2old(*,*,ix)
endfor

tmp2old=tmpr2
dtmpr2=tmpr*0
dtmpr=dtmpr2
ix=value_locate(res.t,tref)
for i=1,n_elements(res.t)-1 do begin
   dtmpr2(*,*,i)=(tmp2old(*,*,i) - tmp2old(*,*,i-1)) / tmp2old(*,*,i-1)
   dtmpr(*,*,i)=(tmpr(*,*,i) - tmpr(*,*,i-1)) / tmpr(*,*,i-1)
endfor

;ampr = tmpr2(*,*,1) * (sh ge 9328 ? (-1) : 1)


;this to check sign -- appears "negative current"
; so negative contributes to be in phase effectively
;positive field
;imgplot,tmpp(*,*,0),res.r1,res.z1,pal=-2
;imgplot,tmpq(*,*,0),res.r1,res.z1,pal=-2


ee2:

;mkfig,'~/img_four_1d_'+string(sh,format='(I0)')+'.eps',xsize=13,ysize=20,font_size=9
;mkfig,'~/eccdan_'+ex+string(sh,format='(I0)')+'.eps',xsize=25,ysize=18,font_size=12
;stop

doimgplot=0

;if sh eq 11003 then doimgplot=1

if doimgplot eq 1 then begin
   readpatch,sh,p
;stop

   newdemod, img,cars, sh=sh,demodtype=demodtype,ixo=ixo,iyo=iyo,ifr=30,/doload

;,noinit=noinit,slist=slist,$
;stat=stat,quiet=quiet,dmat=dmat,kx=kx,ky=ky,kz=kza,istat=istat,doload=doload,$
;cacheread=cacheread,cachewrite=cachewrite,noload=noload,noid2=noid2,db=db,onlyp;lot=onlyplot,svec=svec,ordermag=ordermag
;stop
   getptsnew,rarr=r2,zarr=z2,str=p,ix=ixo,iy=iyo
   crit=abs(amp3r);/max(abs(amp3r))
   crit=(crit-min(crit))/(max(crit)-min(crit))
   idx=where(crit lt 0.15)
   amp(idx)=0.


dirbase='/home/cam112/ikstarcp/my2'

dirmod=''
if sh eq 11003 then dirmod=''

dir=dirbase+'/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod
if sh eq 11003 then tw=3.45
if sh eq 9323 then tw=4.6

twr=((round(tw*1000/5)*5)) / 1000.
fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
gfile=dir+'/g'+fspec
g=readg(gfile)

psi=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag)
psi=sqrt(psi)
zr=[-.2,.2]

mkfig,'~/modimga.eps',xsize=6.5,ysize=6,font_size=8
contourn2,abs(amp),r2,z2,/cb,/iso,zr=[0,zr(1)],/nonicelev,yr=[-30,30],ysty=1
contour,psi,g.r*100,g.z*100,lev=[.3,.6,1],/overplot
endfig,/gs,/jp
stop

mkfig,'~/modimg.eps',xsize=6.5,ysize=11,font_size=8
contourn2,float(amp),r2,z2,/cb,pal=-2,pos=posarr(1,2,0,cnx=0.1,cny=0.1,fx=0.5,msraty=5),/iso,zr=zr,/nonicelev,yr=[-30,30],ysty=1,title='real part pitch angle modulation (deg)',xtitle='R(cm)',ytitle='Z(cm)',offx=1,xr=[150,230],xsty=1
contour,psi,g.r*100,g.z*100,lev=[.3,.6,1],/overplot

contourn2,imaginary(amp),r2,z2,/cb,pal=-2,pos=posarr(/next),/iso,/noer,zr=zr,/nonicelev,yr=[-30,30],ysty=1,title='imaginary part',xtitle='R(cm)',ytitle='Z(cm)',offx=1,xr=[150,230],xsty=1
contour,psi,g.r*100,g.z*100,lev=[.3,.6,1],/overplot
endfig,/gs,/jp
stop
endif
imgplot,abs(amp),res.r1,res.z1,/cb,zr=[0,.3]*scal ,pos=posarr(3,3,0),title='amp main peak',xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
imgplot,abs(amp2),res.r1,res.z1,/cb,zr=[0,.3]*scal ,pos=posarr(/next),/noer,title='amp frequencies nearby main peak peak',xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
imgplot,atan2(amp/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),/noer,title='phase main peak',pal=-2,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1

imgplot,abs(ampq),res.r1,res.z1,/cb,zr=[0,6e6]*4*scal/9 ,pos=posarr(/next),title='amp current main peak',/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1,offx=1.

imgplot,atan2(ampq/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),title='phase current main peak',pal=-2,/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
xyouts,0.5,0.95,string('#',sh,format='(A,I0)'),/norm

imgplot,(tmpr(*,*,1)-tmpr(*,*,0))/tmpr(*,*,0) *   (sh ge 9328 ? (1) : 1) ,res.r1,res.z1,/cb ,pos=posarr(/next),title='inten diff',/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1,offx=1.,pal=-2,zr=[-1,1]*0.05
;imgplot,atan2(-ampr/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),title='phase inten main peak',pal=-2,/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1

;stop

endfig,/jp

;return

if not keyword_set(nostop) then stop

!p.thick=3

ivert=n_elements(res.z1)/2;value_locate(res.z1,0)
plot,res.r1,abs(amp(*,ivert)),yr=[0,1/scal],pos=posarr(1,3,0),title='amplitude of fourier component vs -radius #'+string(sh,format='(I0)'),xtitle='-radius (cm)'
oplot,res.r1,abs(amp2(*,ivert)),col=2
legend,['signal at carrier freq','signal just outside carrier freq'],textcol=[1,2],/right,box=0
plot,res.r1,atan2(amp(*,ivert)/ampref)*!radeg,/noer,pos=posarr(/next),/nodata,xtitle='-radius (cm)',title='phase (deg) of signal at carrier freq vs radius'
oplot,res.r1,atan2(amp(*,ivert)/ampref)*!radeg,col=4
plot,res.r1,abs(amp3(*,ivert)),/noer,pos=posarr(/next),/nodata,xtitle='-radius(cm)',title='amplitude of dc angle vs radius (deg)'
oplot,res.r1,abs(amp3(*,ivert)),col=3
!p.thick=0

if not keyword_set(nostop) then stop
default,want,'jmid'
if want eq 'jmid' then begin
   outr=abs(ampq(*,ivert))
   out2r=atan2(ampq(*,ivert)/ampref);*!radeg
endif
if want eq 'bmid' then begin
   outr=abs(amp(*,ivert))
   out2r=atan2(amp(*,ivert)/ampref);*!radeg
endif

if want eq 'imid' then begin
   outr=abs(ampr(*,ivert))
   out2r=atan2(ampr(*,ivert)/ampref);*!radeg
endif

if want eq 'depmid' then begin
   dumdum=dtmpr2(*,ivert,1) * (sh ge 9328 ? (1) : 1)
;   if sh ne 11003 and sh ne 11004 then dumdum=dtmpr2(*,ivert,1)
   if sh eq 10997 and ex eq ex then dumdum=dtmpr2(*,ivert,1)
   outr=abs(dumdum)
   out2r=atan2(dumdum);*!radeg
endif

idx=where(res.r1 gt -163.)
if sh eq 9323 then idx=where(res.r1 gt -164.)

outr(idx)=!values.f_nan
out2r(idx)=!values.f_nan


;stop
iz0=value_locate3(res.z1,0)
imgplot,transpose(reform(tmpp2(*,iz0,*))),res.t,res.r1,/cb,pal=-2,pos=posarr(1,1,0),xr=tr(0)+[0,1],zr=[-1,1]
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4
if not keyword_set(nostop) then stop

imgplot,transpose(reform(tmpq2(*,iz0,*))),res.t,res.r1,/cb,pal=-2,zr=[-1,1]/10.,pos=posarr(1,1,0),xr=tr(0)+[0,1]
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4
if not keyword_set(nostop) then stop

imgplot,transpose(reform(dtmpr2(*,iz0,*))),res.t,res.r1,/cb,pal=-2,pos=posarr(1,1,0),zr=[-0.05,0.05],xr=tr(0)+[0,1]
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4
if not keyword_set(nostop) then stop


rout=res.r1
if istag(res,'rxs') then rxs=res.rxs
if istag(res,'rxs') then rys=res.rys

end
