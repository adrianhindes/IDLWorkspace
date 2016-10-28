pro f1,which,outr=outr,out2r=out2r,want=want,rout=rout,nostop=nostop,lvonly=lvonly
;tr=[1,8]
;tr=[1,7]

if which eq '9323' then begin
sh=9323 & freqshot=2. & tr2=[2,7]
ex=''
endif

if which eq '9326' then begin
sh=9326 & freqshot=10. & tr2=[2,7]
ex=''
endif

if which eq '9324' then begin
sh=9324 & freqshot=2. & tr2=[2,7]
ex=''
endif

;sh=9326 & freqshot=10. & tr2=[2,7]
;sh=9327 & freqshot=10. & tr2=[4,6]

if which eq '10997b' then begin
sh=10997 & freqshot=2.5 & tr2=[2.5,4.9];miyoung 2.7T, co, 2 beams
ex='b'

endif


if which eq '10997c' then begin
sh=10997 & freqshot=2.5 & tr2=[7.9,10.3];miyoung 2.7T, co, 2 beams
ex='c'
endif


if which eq '11004' then begin
ex=''
sh=11004 & freqshot=2 & tr2=[2,6];counter
endif

if which eq '11003' then begin
ex=''
sh=11003 & freqshot=2 & tr2=[2,6];co

endif


if which eq '11433a' then begin
ex='a'
sh=11433 & freqshot=2.5 & tr2=[2.2,4.21];co

endif


if which eq '11433b' then begin
ex='b'
sh=11433 & freqshot=2.5 & tr2=[4.205,6.215];co

endif


if which eq '11433c' then begin
ex='c'
sh=11433 & freqshot=2.5 & tr2=[6.185,8.195];co

endif




if which eq '11434a' then begin
ex='a'
sh=11434 & freqshot=2.5 & tr2=[3.215, 5.225];co

endif

if which eq '11434b' then begin
ex='b'
sh=11434 & freqshot=2.5 & tr2=[3.215, 7.205];co

endif


a1,sh,freqshot,tr2,ex,outr=outr,out2r=out2r,want=want,rout=rout,nostop=nostop,lvonly=lvonly

;p=out2r
;dum=-[[cos(p*!dtor)],[sin(p*!dtor)]]
;pp=atan(dum(*,1),dum(*,0))
;out2r=pp

end


pro a1,sh,freqshot,tr2,ex,outr=outr,want=want,out2r=out2r,rout=rout,nostop=nostop,lvonly=lvonly

tr=tr2


if !version.os eq 'Win32' then begin
   base='C:\dstore\demod'
endif else base='~'

goto,ee

demodtype='sm32013mse'
if not (sh ge 9323 and sh le 9327 ) then begin
   newdemodflcshot,sh,tr,/only2,res=res,/cachewrite,nskip=1,cacheread=1,demodtype=demodtype
endif

;tr=tr2
if (sh ge 9323 and sh le 9327 ) then begin
   newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype=demodtype,/cachewrite,cacheread=0
;tr=tr2
   newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype=demodtype,nsm=1,nskip=1,/cachewrite,cacheread=0


;   res1=temporary(res);,demodtype=demodtype
;   newdemodflcshot,sh,tr,/only2,rresref=res1,res=res,nsm=1,nskip=1,/cachewrite
endif


save,res,file=base+'/resx'+ex+string(sh,format='(I0)')+'.sav'
;stop
ee:
restore,file=base+'/resx'+ex+string(sh,format='(I0)')+'.sav'
;stop
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


nn=n_elements(tsub)
for j=0,nn-1 do begin
   iw=value_locate(res.t,tsub(j))
   res.ang(*,*,iw)=0.5 * (res.ang(*,*,iw+i1(j)) + res.ang(*,*,iw + i0(j)))
endfor
;stop

if sh gt 10000 then res.ang=res.ang - 55 else res.ang=(res.ang - 8.)
tmp=transpose(reform(res.ang(*,38,*)));-55
ix=where(res.r1 gt -210 and res.r1 lt -165)
nsub=3
ix2=ix(indgen(n_elements(ix)/nsub)*nsub)

;mkfig,'~/im_thist_'+string(sh,format='(I0)')+'.eps',xsize=13,ysize=20,font_size=9
;contourn2,tmp(*,ix),res.t,res.r1(ix),nl=21,zr=[-20,20]/2,pos=posarr(1,3,0,cny=0.1,cnx=0.1),pal=2,offx=1,$
 ;       title='MSE polarisation angle #'+string(sh,format='(I0)'),ytitle='-R (cm)'

imgplot,tmp(*,ix),res.t,res.r1(ix),zr=[-20,20]/2,pos=posarr(1,3,0,cny=0.1,cnx=0.1),pal=-2,offx=1,$
        title='MSE polarisation angle #'+string(sh,format='(I0)'),ytitle='-R (cm)',ysty=1

;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
nb=cgetdata('\NB11_I0',sh=sh,db='kstar')
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
if (ex eq 'a' and sh eq 11433) or (sh eq 11434) then ec=cgetdata('\ECH_VFWD1',sh=sh,db='kstar')
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
plot,ip.t,ip.v/100e3,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5/100e3+[-1,1]*10e4/100e3,ysty=1+4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=3,ytitle='current (x100kA)'
if not keyword_set(nostop) then stop
endfig,/gs,/jp

ec2=interpol(ec.v,ec.t,res.t)
f=fft_t_to_f(res.t)
isel=value_locate(f,freqshot)
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
for i=0,sz(2)-1 do tmpp(*,*,i)=convol(res.ang(*,*,i),kern/total(kern))

tmpq=tmpp*0
for j=0,sz(1)-1 do for k=0,sz(2)-1 do begin
   tmpq(*,j,k)=-deriv(tmpp(*,j,k)) ;;! minus sign because "negative r"
endfor
tmpq2=tmpq
tmpp2=tmpp
tmpr=res.inten/max(res.inten)
tmpr2=tmpr*0
;stop

mxharm=5
if freqshot eq 10 then mxharm=2
if freqshot eq 2 then mxharm=10
for i=0,sz(0)-1 do begin
    for j=0,sz(1)-1 do begin
   dum=fft(reform(tmpp(i,j,*)))
   if finite(dum(0)) eq 0 then continue
   dum2=dum*0 &
   for iharm=0,mxharm do dum2(isel*iharm)=dum(isel*iharm)
   tmpp2(i,j,*)=float(fft(dum2,/inverse))*2

if i eq -69 and j eq 31 then begin
;   mkfig,'~/fplot.eps',xsize=15,ysize=11,font_size=12
   plot,f,abs(dum),/ylog,xr=[0,10],$
        pos=posarr(1,2,0),title='Fourier Domain',xtitle='F (Hz)'
;   oplot,f(ix),abs(dum(ix)),psym=4;,title=string(res.r1(i),res.z1(j))
  plot,f,abs(fft(ec2)),col=2,/noer,/ylog,pos=posarr(/curr),xr=!x.crange,$
       ysty=4
  plot,res.t,tmpp(i,j,*),xtitle='time',ytitle='angle (deg)',$
       pos=posarr(/next),/noer,title='time domain'
  plot,res.t,ec2,xr=!x.crange,col=2,pos=posarr(/curr),/noer,ysty=4
   a=''&read,'',a
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
   for iharm=0,mxharm do dum2(isel*iharm)=dum(isel*iharm)
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


for i=0,sz(0)-1 do begin
    for j=0,sz(1)-1 do begin
   dum=fft(reform(tmpr(i,j,*)))
   if finite(dum(0)) eq 0 then continue
   dum2=dum*0 &
   for iharm=0,mxharm do dum2(isel*iharm)=dum(isel*iharm)
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


tref = tr(0);+0.1
tmp2old=tmpp2
ix=value_locate(res.t,tref)
for i=0,n_elements(res.t)-1 do begin
   tmpp2(*,*,i)=tmp2old(*,*,i) - tmp2old(*,*,ix)
endfor

tmp2old=tmpq2
ix=value_locate(res.t,tref)
for i=0,n_elements(res.t)-1 do begin
   tmpq2(*,*,i)=tmp2old(*,*,i) - tmp2old(*,*,ix)
endfor

tmp2old=tmpr
ix=value_locate(res.t,tref)
for i=1,n_elements(res.t)-1 do begin
   tmpr2(*,*,i)=(tmp2old(*,*,i) - tmp2old(*,*,i-1)) / tmp2old(*,*,i-1)
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
imgplot,abs(amp),res.r1,res.z1,/cb,zr=[0,.3] ,pos=posarr(3,3,0),title='amp main peak',xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
imgplot,abs(amp2),res.r1,res.z1,/cb,zr=[0,.3] ,pos=posarr(/next),/noer,title='amp frequencies nearby main peak peak',xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
imgplot,atan2(amp/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),/noer,title='phase main peak',pal=-2,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1

imgplot,abs(ampq),res.r1,res.z1,/cb,zr=[0,.02] ,pos=posarr(/next),title='amp current main peak',/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1,offx=1.

imgplot,atan2(ampq/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),title='phase current main peak',pal=-2,/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
xyouts,0.5,0.95,string('#',sh,format='(A,I0)'),/norm

imgplot,(tmpr(*,*,1)-tmpr(*,*,0))/tmpr(*,*,0) *   (sh ge 9328 ? (1) : 1) ,res.r1,res.z1,/cb ,pos=posarr(/next),title='inten diff',/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1,offx=1.,pal=-2,zr=[-1,1]*0.05
;imgplot,atan2(-ampr/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),title='phase inten main peak',pal=-2,/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1



endfig,/jp

;return

if not keyword_set(nostop) then stop

!p.thick=3

ivert=value_locate(res.z1,0)
plot,res.r1,abs(amp(*,ivert)),yr=[0,.3],pos=posarr(1,3,0),title='amplitude of fourier component vs -radius #'+string(sh,format='(I0)'),xtitle='-radius (cm)'
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
   dumdum=tmpr2(*,ivert,1) * (sh ge 9328 ? (1) : 1)
   outr=abs(dumdum)
   out2r=atan2(dumdum);*!radeg
endif




;stop
iz0=value_locate3(res.z1,0) 
imgplot,transpose(reform(tmpp2(*,iz0,*))),res.t,res.r1,/cb,pal=-2,pos=posarr(1,1,0),xr=tr(0)+[0,1],zr=[-1,1]
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4
if not keyword_set(nostop) then stop

imgplot,transpose(reform(tmpq2(*,iz0,*))),res.t,res.r1,/cb,pal=-2,zr=[-1,1]/10.,pos=posarr(1,1,0),xr=tr(0)+[0,1]
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4
if not keyword_set(nostop) then stop

imgplot,transpose(reform(tmpr2(*,iz0,*))),res.t,res.r1,/cb,pal=-2,pos=posarr(1,1,0),zr=[-0.05,0.05],xr=tr(0)+[0,1]
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4
if not keyword_set(nostop) then stop

rout=res.r1

end

pro cmp,items,want=want,yr=yr,dostop=dostop
nostop= keyword_set(dostop) eq 0
txt1=items(0)
if n_elements(items) gt 1 then txt2=items(1)
if n_elements(items) gt 2 then txt3=items(2)

if items(0) eq 'eccd_cocntr' then begin
   txt1='11003'
   txt2='11004'
endif

if items(0) eq 'ech_cocntr' then begin
   txt1='11433a'
   txt2='11434a'
endif
if items(0) eq 'ech_eccd' then begin
   txt1='11433a'
   txt2='11433c'
endif
if items(0) eq 'eccd_freq' then begin
   txt1='9323'
   txt2='9326'
endif

if items(0) eq 'respos1' then begin
   txt1='9323'
   txt2='11003'
endif

if items(0) eq 'respos2' then begin
   txt1='11003'
   txt2='10997b'
endif

if items(0) eq 'respos3' then begin
   txt1='10997b'
   txt2='10997c'
endif


default,want,'jmid'
default,xr,[-220,-165]
if want eq want then default,yr,[0,.04]

;want='imid'
f1,txt1,outr=a,out2r=p,want=want,rout=rout,nostop=nostop
if n_elements(txt2) ne 0 then $
   f1,txt2,outr=a2,out2r=p2,want=want,rout=rout,nostop=nostop

if n_elements(txt3) ne 0 then $
   f1,txt3,outr=a3,out2r=p3,want=want,rout=rout,nostop=nostop

plot,rout,a,pos=posarr(2,2,0),yr=yr,xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2,col=2
if n_elements(txt3) ne 0 then oplot,rout,a3,col=3

;p+=25*!dtor
;p2+=25*!dtor
plot,rout,p*!radeg,pos=posarr(/next),/noer,psym=4,xr=xr,xsty=1,yr=[-180,180],ysty=1
if n_elements(txt2) ne 0 then oplot,rout,p2*!radeg,col=2,psym=4
if n_elements(txt3) ne 0 then oplot,rout,p3*!radeg,col=3,psym=4
oplot,!x.crange,[0,0]
;oplot,!x.crange,[1,1]*(-20)
;oplot,!x.crange,[1,1]*(160)


plot,rout,a*cos(p),pos=posarr(/next),/noer,title='cos',yr=[-1,1]*yr(1),xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2*cos(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout,a3*cos(p3),col=3
oplot,!x.crange,[0,0]


plot,rout,a*sin(p),pos=posarr(/next),/noer,title='sin',yr=[-1,1]*yr(1),xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2*sin(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout,a3*sin(p3),col=3
oplot,!x.crange,[0,0]

stop

end


pro cmpflux,items,want=want,yr=yr,dostop=dostop,xr=xr
nostop= keyword_set(dostop) eq 0
txt1=items(0)
if n_elements(items) gt 1 then txt2=items(1)
if n_elements(items) gt 2 then txt3=items(2)

if items(0) eq 'eccd_cocntr' then begin
   txt1='11003'
   txt2='11004'
endif

if items(0) eq 'ech_cocntr' then begin
   txt1='11433a'
   txt2='11434a'
endif
if items(0) eq 'ech_eccd' then begin
   txt1='11433a'
   txt2='11433c'
endif
if items(0) eq 'eccd_freq' then begin
   txt1='9323'
   txt2='9326'
endif

if items(0) eq 'respos1' then begin
   txt1='9323'
   txt2='11003'
endif

if items(0) eq 'respos2' then begin
   txt1='11003'
   txt2='10997b'
endif

if items(0) eq 'respos3' then begin
   txt1='10997b'
   txt2='10997c'
endif





default,want,'jmid'
default,xr,[-220,-165]
if want eq want then default,yr,[0,.04]

;want='imid'

dirmod=''
dirbase='/home/cam112/ikstarcp/my2'
sh=long(strmid(txt1,0,5))
if sh eq 11434 then sh=11433
if sh eq 11004 then sh=11003
if sh eq 10997 then sh=11003

if sh eq 11003 then dirmod=''

dir=dirbase+'/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod
if sh eq 11433 then tw=5.345
if sh eq 11003 then tw=3.45
if sh eq 9323 then tw=4.6
twr=((round(tw*1000/5)*5)) / 1000.
fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
gfile=dir+'/g'+fspec
g=readg(gfile)

psi=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag) ;& psi=sqrt(psi)
iz0=value_locate(g.z,0)
rfine=linspace(min(g.r),max(g.r),64*10+1)
psi1=spline(g.r,psi(*,iz0),rfine) & psi1=sqrt(psi1)

iax=value_locate3(rfine,g.rmaxis)
psia=psi1(iax+1:*) & ra=rfine(iax+1:*)
psib=psi1(0:iax-1) & rb=rfine(0:iax-1)

nn=50
psig=linspace(min(psi1),0.7,nn)

rag=interpolo(ra,psia,psig)
rbg=interpolo(rb,psib,psig)



;interpolo(a,-rout,

;stop


f1,txt1,outr=a,out2r=p,want=want,rout=rout,nostop=nostop
if n_elements(txt2) ne 0 then $
   f1,txt2,outr=a2,out2r=p2,want=want,rout=rout,nostop=nostop

if n_elements(txt3) ne 0 then $
   f1,txt3,outr=a3,out2r=p3,want=want,rout=rout,nostop=nostop


wset2,0

plot,rout,a,pos=posarr(2,2,0),yr=yr,xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2,col=2
if n_elements(txt3) ne 0 then oplot,rout,a3,col=3

;p+=25*!dtor
;p2+=25*!dtor
plot,rout,p*!radeg,pos=posarr(/next),/noer,psym=4,xr=xr,xsty=1,yr=[-180,180],ysty=1
if n_elements(txt2) ne 0 then oplot,rout,p2*!radeg,col=2,psym=4
if n_elements(txt3) ne 0 then oplot,rout,p3*!radeg,col=3,psym=4
oplot,!x.crange,[0,0]
;oplot,!x.crange,[1,1]*(-20)
;oplot,!x.crange,[1,1]*(160)


plot,rout,a*cos(p),pos=posarr(/next),/noer,title='cos',yr=[-1,1]*yr(1),xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2*cos(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout,a3*cos(p3),col=3
oplot,!x.crange,[0,0]


plot,rout,a*sin(p),pos=posarr(/next),/noer,title='sin',yr=[-1,1]*yr(1),xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2*sin(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout,a3*sin(p3),col=3
oplot,!x.crange,[0,0]


wset2,1
oval=!values.f_nan

plot,psig,interpolo(a,-rout*.01,rag,oval=oval),pos=posarr(2,2,0),yr=yr,xsty=1
oplot,psig,interpolo(a,-rout*.01,rbg,oval=oval),linesty=2
;if n_elements(txt2) ne 0 then oplot,rout,a2,col=2
if n_elements(txt3) ne 0 then oplot,rout,a3,col=3

;p+=25*!dtor
;p2+=25*!dtor
plot,psig,interpolo(p*!radeg,-rout*0.01,rag,oval=oval),pos=posarr(/next),/noer,psym=4,xsty=1,yr=[-180,180],ysty=1
oplot,psig,interpolo(p*!radeg,-rout*0.01,rbg,oval=oval),psym=5
;if n_elements(txt2) ne 0 then oplot,rout,p2*!radeg,col=2,psym=4
if n_elements(txt3) ne 0 then oplot,rout,p3*!radeg,col=3,psym=4
oplot,!x.crange,[0,0]
;oplot,!x.crange,[1,1]*(-20)
;oplot,!x.crange,[1,1]*(160)


plot,psig,interpolo(a*cos(p),-rout*0.01,rag,oval=oval),pos=posarr(/next),/noer,title='cos',yr=[-1,1]*yr(1),xsty=1,ysty=1
oplot,psig,interpolo(a*cos(p),-rout*0.01,rbg,oval=oval),linesty=2
if want eq 'jmid' then sgn=1
if want eq 'bmid' then sgn=-1
oplot,psig,interpolo(a*cos(p),-rout*0.01,rag,oval=oval) + sgn*interpolo(a*cos(p),-rout*0.01,rbg,oval=oval),linesty=3,thick=3
if n_elements(txt2) ne 0 then begin
oplot,psig,interpolo(a2*cos(p2),-rout*0.01,rag,oval=oval),col=2
oplot,psig,interpolo(a2*cos(p2),-rout*0.01,rbg,oval=oval),linesty=2,col=2
oplot,psig,interpolo(a2*cos(p2),-rout*0.01,rag,oval=oval) + sgn*interpolo(a2*cos(p2),-rout*0.01,rbg,oval=oval),linesty=3,thick=3,col=2


endif

if n_elements(txt3) ne 0 then oplot,rout,a3*cos(p3),col=3
oplot,!x.crange,[0,0]


plot,psig,interpolo(a*sin(p),-rout*0.01,rag,oval=oval),pos=posarr(/next),/noer,title='sin',yr=[-1,1]*yr(1),xsty=1,ysty=1
oplot,psig,interpolo(a*sin(p),-rout*0.01,rbg,oval=oval),linesty=2
oplot,psig,interpolo(a*sin(p),-rout*0.01,rag,oval=oval) + sgn*interpolo(a*sin(p),-rout*0.01,rbg,oval=oval),linesty=3,thick=3

if n_elements(txt2) ne 0 then begin
oplot,psig,interpolo(a2*sin(p2),-rout*0.01,rag,oval=oval),col=2
oplot,psig,interpolo(a2*sin(p2),-rout*0.01,rbg,oval=oval),linesty=2,col=2
oplot,psig,interpolo(a2*sin(p2),-rout*0.01,rag,oval=oval) + sgn*interpolo(a2*sin(p2),-rout*0.01,rbg,oval=oval),linesty=3,thick=3,col=2
endif

if n_elements(txt3) ne 0 then oplot,rout,a3*sin(p3),col=3
oplot,!x.crange,[0,0]


stop

end

;cmpflux,'11434a'
;end
