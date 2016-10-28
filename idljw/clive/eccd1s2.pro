tr=[1,8]
;sh=9324 & freqshot=2. & tr2=[2,7]
sh=9323 & freqshot=2. &tr2=[2,6.9751];2+[2,2.9751];[2,6.975];[4.5,6.475];[2,3];7]

;sh=9326 & freqshot=10. & tr2=[2,7]
;sh=9327 & freqshot=10. & tr2=[4,6]
newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype='sm2013mse',/cachewrite,/cacheread
tr=tr2
newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype='sm2013mse',nsm=1,nskip=1,/cachewrite,/cacheread
ee:
for i=tr(0),tr(1)-1 do begin
   tw=i+0.5
   iw=value_locate(res.t,tw)
   res.ang(*,*,iw)=0.5 * (res.ang(*,*,iw+1) + res.ang(*,*,iw-1))
endfor

row0=30;40;30
nrow=20.
tmp1=transpose(reform(res.ang(*,row0,*)))-12
for j=1,nrow do tmp1+=transpose(reform(res.ang(*,row0+j,*)))-12
tmp1 = tmp1/nrow
tmp=tmp1


ix=where(res.r1 gt -220 and res.r1 lt -160)
nsub=3
ix2=ix(indgen(n_elements(ix)/nsub)*nsub)
contourn2,tmp(*,ix),res.t,res.r1(ix),zr=[-20,20],pos=posarr(1,3,0,cny=0.1,cnx=0.1),pal=-2,offx=1,/cb,$
        title='MSE polarisation angle',ytitle='-R (cm)'
;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer,title='ECCD drive'
lv=cgetdata('\LV01',sh=sh,db='kstar')
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,ysty=8,title='Current  loop voltage',ytitle='loop voltage (V)'
ip=cgetdata('\RC01')
plot,ip.t,ip.v/100e3,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5/100e3+[-1,1]*10e4/100e3,ysty=1+4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=3,ytitle='current (x100kA)' 
ec2=interpol(ec.v,ec.t,res.t)
f=fft_t_to_f(res.t)
isel=value_locate(f,freqshot)
sz=size(res.ang,/dim)
amp=complexarr(sz(0))
amp2=amp
amp3=amp

;stop
;  a=''&read,'',a
;  if a ne '' then stop

ix=[intspace(fix(isel * 0.5),fix(isel * 0.8)),$
    intspace(fix(isel * 1.2),fix(isel * 1.5))]

fec2=fft(ec2)
ampref=fec2(isel)

tmp2=tmp
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
   dum2=dum*0 &
   for iharm=1,5 do dum2(isel*iharm)=dum(isel*iharm)
   tmp2(*,i)=float(fft(dum2,/inverse))*2
;stop
endfor


tref = tr(0)
tmp2old=tmp2
ix=value_locate(res.t,tref)
for i=0,n_elements(res.t)-1 do begin
   tmp2(i,*)=tmp2old(i,*) - tmp2old(ix,*)
endfor


ix=where(res.r1 gt -220 and res.r1 lt -160)


;mkfig,'~/img_td_'+string(sh,format='(I0)')+'.eps',xsize=13,ysize=20,font_size=9

current=tmp2
nt=n_elements(res.t)
for i=0,nt-1 do begin
   tmpvar=smooth(nonans(tmp2(i,*)),5);3);5);3)
;   tmpvar=nonans(tmp2(i,*))
   current(i,*)=-deriv(tmpvar)
endfor

contourn2,tmp2(*,ix),res.t,res.r1(ix),zr=[-20.,20.]/20.,pos=posarr(1,4,0,cny=0.1,cnx=0.1),pal=-2,offx=1,/cb,/box,$
        title='MSE polarisation angle',ytitle='-R (cm)',xr=tr(0)+[0,0+2./freqshot]

contourn2,current(*,ix),res.t,res.r1(ix),pos=posarr(/next),pal=-2,offx=1,/cb,/box,$
        title='current',ytitle='-R (cm)',xr=tr(0)+[0,0+2./freqshot],/noer,zr=[-.1,.1]/1.

;iw=value_locate(res.r1,-190.)
;sumc=current(*,iw)

iww=where(res.r1 ge -200 and res.r1 le -180)
sumc=total(current(*,iww),2)/n_elements(iww)
sumv=total(tmp2(*,iww),2)/n_elements(iww)

iww=where(res.r1 ge -172 and res.r1 le -168)
sumc2=total(current(*,iww),2)/n_elements(iww)


;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer,title='ECCD drive//curr'

plot,res.t,sumc,xr=!x.crange,pos=posarr(/curr),col=2,/noer,ysty=4,xsty=4,yr=minmax([sumc,sumc2])
oplot,res.t,sumc2,col=2,linesty=2
plot,res.t,sumv,xr=!x.crange,pos=posarr(/curr),col=3,/noer,ysty=4,xsty=4
lv=cgetdata('\LV01',sh=sh,db='kstar')
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,ysty=8,title='Current  loop voltage',ytitle='loop voltage (V)'
ip=cgetdata('\RC01')
plot,ip.t,ip.v/100e3,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5/100e3+[-1,1]*10e4/100e3,ysty=1+4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=3,ytitle='current (x100kA)' 

endfig,/gs,/jp

stop

plot,res.r1,abs(amp),yr=[0,.3],ysty=4
oplot,res.r1,abs(amp2),col=2
plot,res.r1,abs(amp3),col=3,/noer,ysty=4
plot,res.r1,atan2(amp/ampref)*!radeg,col=4,/noer

end

