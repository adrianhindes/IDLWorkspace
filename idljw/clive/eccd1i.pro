;goto,ee2
tr=[1,8]
sh=9323 & freqshot=2. & tr2=[2,7];[2,7]

;sh=9326 & freqshot=10. & tr2=[2,7]
;sh=9327 & freqshot=10. & tr2=[4,6]
demodtype='sm2013mse'
newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype=demodtype,/cachewrite,/cacheread
tr=tr2
newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype=demodtype,nsm=1,nskip=1,/cachewrite,/cacheread
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
;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer
lv=cgetdata('\LV01',sh=sh,db='kstar')
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,col=2,ysty=8
ip=cgetdata('\RC01')
plot,ip.t,ip.v,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5+[-1,1]*10e4,ysty=1+4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=3
ec2=interpol(ec.v,ec.t,res.t)
f=fft_t_to_f(res.t)
isel=value_locate(f,freqshot)
sz=size(res.ang,/dim)
amp=complexarr(sz(0),sz(1))
amp2=amp
amp3=amp

;  a=''&read,'',a
;  if a ne '' then stop

ix=[intspace(fix(isel * 0.5),fix(isel * 0.8)),$
    intspace(fix(isel * 1.2),fix(isel * 1.5))]

fec2=fft(ec2)
ampref=fec2(isel)

for i=0,sz(0)-1 do begin
   for j=0,sz(1)-1 do begin
   dum=fft(res.ang(i,j,*))
   if finite(dum(0)) eq 0 then continue
;   plot,f,abs(dum),title=res.r1(i),/ylog
;   oplot,f(ix),abs(dum(ix)),psym=-4
;  plot,f,abs(fft(ec2)),col=2,/noer,/ylog
;  a=''&read,'',a
;  if a ne '' then stop
   amp(i,j)=dum(isel)
   amp2(i,j)=mean(abs(dum(ix)))
   amp3(i,j)=dum(0)
endfor
endfor
;plot,res.r1,abs(amp),yr=[0,.3],ysty=4
;oplot,res.r1,abs(amp2),col=2
;plot,res.r1,abs(amp3),col=3,/noer,ysty=4
;plot,res.r1,atan2(amp/ampref)*!radeg,col=4,/noer
idx=where(abs(amp2)) gt abs(amp)
ampf=amp
ampf(idx)=!values.f_nan
ee2:
;mkfig,'h:\img_four_'+string(sh,format='(I0)')+'.eps',xsize=13,ysize=9,font_size=9
contourn2,abs(ampf),res.r1,res.z1,/cb,zr=[0,0.2],pos=posarr(2,1,0),title=string(sh,freqshot,format=    '("amplitude: #",I0," f=",I0,"Hz")'),ysty=1,offx=1
contourn2,atan2(ampf/ampref)*!radeg,res.r1,res.z1,/cb,zr=[-180,180],pos=posarr(/next),title='phase',pal=-2,/noer,ysty=1,offx=1
endfig,/jp,/gs
end

