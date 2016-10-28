;goto,ee2
tr=[1,8]
sh=9323 & freqshot=2. & tr2=[2,7]

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

;mkfig,'~/im_thist_'+string(sh,format='(I0)')+'.eps',xsize=13,ysize=20,font_size=9
contourn2,tmp(*,ix),res.t,res.r1(ix),nl=21,zr=[-20,20]/2,pos=posarr(1,3,0,cny=0.1,cnx=0.1),pal=2,offx=1,$
        title='MSE polarisation angle #'+string(sh,format='(I0)'),ytitle='-R (cm)'
;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer,title='ECCD drive'
lv=cgetdata('\LV01',sh=sh,db='kstar')
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,ysty=8,title='Current  loop voltage',ytitle='loop voltage (V)'
ip=cgetdata('\RC01')
plot,ip.t,ip.v/100e3,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5/100e3+[-1,1]*10e4/100e3,ysty=1+4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=3,ytitle='current (x100kA)' 

endfig,/gs,/jp

ec2=interpol(ec.v,ec.t,res.t)
f=fft_t_to_f(res.t)
isel=value_locate(f,freqshot)
sz=size(res.ang,/dim)
amp=complexarr(sz(0))
amp2=amp
amp3=amp

stop
;  a=''&read,'',a
;  if a ne '' then stop

ix=[intspace(fix(isel * 0.5),fix(isel * 0.8)),$
    intspace(fix(isel * 1.2),fix(isel * 1.5))]

fec2=fft(ec2)
ampref=fec2(isel)

for i=0,sz(0)-1 do begin
   dum=fft(tmp(*,i))
   if finite(dum(0)) eq 0 then continue
   plot,f,abs(dum),title=res.r1(i),/ylog
   oplot,f(ix),abs(dum(ix)),psym=-4
  plot,f,abs(fft(ec2)),col=2,/noer,/ylog
;  a=''&read,'',a
;  if a ne '' then stop
   amp(i)=dum(isel)
   amp2(i)=mean(abs(dum(ix)))
   amp3(i)=dum(0)
endfor
ee2:

mkfig,'~/img_four_1d_'+string(sh,format='(I0)')+'.eps',xsize=13,ysize=20,font_size=9
!p.thick=3
plot,res.r1,abs(amp),yr=[0,.3],pos=posarr(1,3,0),title='amplitude of fourier component vs -radius #'+string(sh,format='(I0)'),xtitle='-radius (cm)'
oplot,res.r1,abs(amp2),col=2
legend,['signal at carrier freq','signal just outside carrier freq'],textcol=[1,2],/right,box=0
plot,res.r1,atan2(amp/ampref)*!radeg,/noer,pos=posarr(/next),/nodata,xtitle='-radius (cm)',title='phase (deg) of signal at carrier freq vs radius'
oplot,res.r1,atan2(amp/ampref)*!radeg,col=4
plot,res.r1,abs(amp3),/noer,pos=posarr(/next),/nodata,xtitle='-radius(cm)',title='amplitude of dc angle vs radius (deg)'
oplot,res.r1,abs(amp3),col=3
!p.thick=0
endfig,/gs,/jp
end

