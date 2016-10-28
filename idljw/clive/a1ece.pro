

pro a1ece,sh,freqshot,tr2,ex,outr=outr,want=want,out2r=out2r,rout=rout,nostop=nostop,lvonly=lvonly

tr=tr2



common cba1ece, res,t,v,shr,trr
if n_elements(shr) ne 0  then if sh eq shr and trr(0) eq tr(0) and trr(1) eq tr(1) then goto,no
 getece, sh,res,t,v,tr=tr,alt=alt,timeres=2e-3
shr=sh
trr=tr
no:
tmp=res.v


ix=res.ix

contourn2,res.v(*,ix),res.t,res.rr,pos=posarr(1,3,0,cny=0.1,cnx=0.1),offx=1,/cb,title='ECE #'+string(sh,format='(I0)'),ytitle='-R (cm)',ysty=1

;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
nb=cgetdata('\NB11_I0',sh=sh,db='kstar')
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
if (ex eq 'a' and sh eq 11433) or (sh eq 11434) then ec=cgetdata('\ECH_VFWD1',sh=sh,db='kstar')
lv=cgetdata('\LV23',sh=sh,db='kstar')

if sh eq 13366 then begin
tdum=10. + findgen(1e6)*1e-6
ec={t:tdum,v : -cos(2*!pi*10. * (tdum))+1}
endif

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
isel=value_locate3(f,freqshot)
sz=[n_elements(res.rr)]
amp=complexarr(sz(0))
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
tmpp=res.v(*,res.ix)
tmpp2=tmpp*0
;kern=fltarr(5,3,1)+1.
;if sh eq 11004 or sh eq 11003 then kern=fltarr(10,5,1)+1.
;for i=0,sz(2)-1 do tmpp(*,*,i)=convol(res.ang(*,*,i),kern/total(kern))

;tmpq=tmpp*0
;for j=0,sz(1)-1 do for k=0,sz(2)-1 do begin
;   tmpq(*,j,k)=-deriv(tmpp(*,j,k)) ;;! minus sign because "negative r"
;endfor
;tmpq2=tmpq
;tmpp2=tmpp
;tmpr=res.inten/max(res.inten)
;tmpr2=tmpr*0
;stop

mxharm=5
if freqshot eq 10 then mxharm=2*5
if freqshot eq 2 or freqshot eq 2.5 then mxharm=10*5
for i=0,sz(0)-1 do begin
;    for j=0,sz(1)-1 do begin
   dum=fft(reform(tmpp(*,i)))
   if finite(dum(0)) eq 0 then continue
   dum2=dum*0 &
   for iharm=0,mxharm do dum2(isel*iharm)=dum(isel*iharm)
   tmpp2(*,i)=float(fft(dum2,/inverse))*2

if i eq 25 then begin
;   mkfig,'~/fplot.eps',xsize=15,ysize=11,font_size=12
   plot,f,abs(dum),/ylog,xr=[0,10],$
        pos=posarr(1,2,0),title='Fourier Domain',xtitle='F (Hz)'
;   oplot,f(ix),abs(dum(ix)),psym=4;,title=string(res.r1(i),res.z1(j))
  plot,f,abs(fft(ec2)),col=2,/noer,/ylog,pos=posarr(/curr),xr=!x.crange,$
       ysty=4
  plot,res.t,tmpp(*,i),xtitle='time',ytitle='angle (deg)',$
       pos=posarr(/next),/noer,title='time domain'
  plot,res.t,ec2,xr=!x.crange,col=2,pos=posarr(/curr),/noer,ysty=4
;stop
;   a=''&read,'',a
  endfig,/gs,/jp
;  stop
endif
;  if a ne '' then stop
   amp(i)=dum(isel)
   amp2(i)=mean(abs(dum(ix)))
   amp3(i)=dum(0)
   print,i
endfor

tref = tr(0);+0.1
tmp2old=tmpp2
ix=value_locate3(res.t,tref)
for i=0,n_elements(res.t)-1 do begin
   tmpp2(i,*)=tmp2old(i,*) - tmp2old(ix,*)
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
;; imgplot,abs(amp),res.r1,res.z1,/cb,zr=[0,.3] ,pos=posarr(3,3,0),title='amp main peak',xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
;; imgplot,abs(amp2),res.r1,res.z1,/cb,zr=[0,.3] ,pos=posarr(/next),/noer,title='amp frequencies nearby main peak peak',xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
;; imgplot,atan2(amp/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),/noer,title='phase main peak',pal=-2,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1

;; imgplot,abs(ampq),res.r1,res.z1,/cb,zr=[0,.02] ,pos=posarr(/next),title='amp current main peak',/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1,offx=1.

;; imgplot,atan2(ampq/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),title='phase current main peak',pal=-2,/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1
;; xyouts,0.5,0.95,string('#',sh,format='(A,I0)'),/norm

;; imgplot,(tmpr(*,*,1)-tmpr(*,*,0))/tmpr(*,*,0) *   (sh ge 9328 ? (1) : 1) ,res.r1,res.z1,/cb ,pos=posarr(/next),title='inten diff',/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1,offx=1.,pal=-2,zr=[-1,1]*0.05
;; ;imgplot,atan2(-ampr/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180] ,pos=posarr(/next),title='phase inten main peak',pal=-2,/noer,xr=[-220,-160],yr=[-20,40],xsty=1,ysty=1



;; endfig,/jp

;return

;if not keyword_set(nostop) then stop

!p.thick=3

;ivert=value_locate(res.z1,0)
plot,res.rr,abs(amp(*)),pos=posarr(1,3,0),title='amplitude of fourier component vs -radius #'+string(sh,format='(I0)'),xtitle='-radius (cm)'
oplot,res.rr,abs(amp2(*)),col=2
legend,['signal at carrier freq','signal just outside carrier freq'],textcol=[1,2],/right,box=0
plot,res.rr,tmpp2(2,*)>0,/noer,pos=posarr(/curr),col=3,thick=3

plot,res.rr,atan2(amp(*)/ampref)*!radeg,/noer,pos=posarr(/next),/nodata,xtitle='-radius (cm)',title='phase (deg) of signal at carrier freq vs radius'
oplot,res.rr,atan2(amp(*)/ampref)*!radeg,col=4
plot,res.rr,abs(amp3(*)),/noer,pos=posarr(/next),/nodata,xtitle='-radius(cm)',title='amplitude of dc angle vs radius (deg)'
oplot,res.rr,abs(amp3(*)),col=3
!p.thick=0

if not keyword_set(nostop) then stop

if want eq 'dif2ece' then begin
   itfrom=4;6;3
   outr=abs(tmpp2(itfrom,*))
   out2r=atan2(tmpp2(itfrom,*))
endif

if want eq 'modece' then begin

   outr=abs(amp(*))
   out2r=atan2(amp(*)/ampref);*!radeg
endif

if want eq 'modece0' then begin

   outr=abs(amp3(*))
   out2r=outr*0.
endif


;iz0=value_locate3(res.z1,0) 
contourn2,tmpp2(*,*),res.t,res.rr,/cb,pal=-2,pos=posarr(1,1,0),xr=tr(0)+[0,1/freqshot];,zr=[-300,300]
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4
if not keyword_set(nostop) then stop

rout=-res.rr*100

end
