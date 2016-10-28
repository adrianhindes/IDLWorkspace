;goto,ee
tr=[1,8]
sh=9327
newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype='sm2013mse',/cachewrite,/cacheread
tr=[4,6]
newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype='sm2013mse',nsm=1,nskip=1,/cachewrite,/cacheread
ee:
for i=tr(0),tr(1)-1 do begin
   tw=i+0.5
   iw=value_locate(res.t,tw)
   res.ang(*,*,iw)=0.5 * (res.ang(*,*,iw+1) + res.ang(*,*,iw-1))
endfor

tmp=transpose(reform(res.ang(*,35,*)))-12
ix=where(res.r1 gt -210 and res.r1 lt -170)
nsub=3
ix2=ix(indgen(n_elements(ix)/nsub)*nsub)
imgplot,tmp(*,ix),res.t,res.r1(ix),/cb,zr=[-20,20]/2,pos=posarr(1,3,0),pal=-2
plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer
lv=cgetdata('\LV01',sh=sh,db='kstar')
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/curr),/noer,col=2
ip=cgetdata('\RC01')
plot,ip.t,ip.v,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5+[-1,1]*10e4,ysty=1
ec2=interpol(ec.v,ec.t,res.t)
f=fft_t_to_f(res.t)
isel=value_locate(f,10.)
sz=size(res.ang,/dim)
amp=complexarr(sz(0))
amp2=amp
amp3=amp
  a=''&read,'',a
  if a ne '' then stop

ix=[intspace(fix(isel * 0.5),fix(isel * 0.8)),$
    intspace(fix(isel * 1.2),fix(isel * 1.5))]

for i=0,sz(0)-1 do begin
   dum=fft(tmp(*,i))
   if finite(dum(0)) eq 0 then continue
   plot,f,abs(dum),title=res.r1(i),/ylog
   oplot,f(ix),abs(dum(ix)),psym=-4
  plot,f,abs(fft(ec2)),col=2,/noer,/ylog
  a=''&read,'',a
  if a ne '' then stop
   amp(i)=dum(isel)
   amp2(i)=mean(abs(dum(ix)))
   amp3(i)=dum(0)
endfor
plot,res.r1,abs(amp),yr=[0,.3],ysty=4
oplot,res.r1,abs(amp2),col=2
plot,res.r1,abs(amp3),col=3,/noer,ysty=4
plot,res.r1,atan2(amp2)*!radeg,col=4,/noer


end

