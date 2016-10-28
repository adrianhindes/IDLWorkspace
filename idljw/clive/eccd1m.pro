;goto,eb
;goto,ee2

;sh=9323 & freqshot=2. & tr2=[2,7]
;sh=9324 & freqshot=2. & tr2=[2,7]
sh=11003 & freqshot=2. & tr2=[2,6]

;sh=10997 & freqshot=2.5 & tr2=[2.5,4.9];miyoung 2.7T, co, 2 beams

;sh=10997 & freqshot=10 & tr2=[4.9,5.9];miyoung 2.7T, co, 2 beams;zposlower

;sh=10997 & freqshot=2.5 & tr2=[7.9,10.3];miyoung 2.7T, co, 2 beams

;sh=10997 & freqshot=10 & tr2=[10.3,10.7];miyoung 2.7T, co, 2 beams, Z POS HIGHER

;sh=10997 & freqshot=2.5 &  tr2=[2.5,4.9]
;sh=9326 & freqshot=10. & tr2=[2,7]
;sh=9327 & freqshot=10. & tr2=[4,6]

;sh=11433 & freqshot=2.5 & tr2=[6.185,8.195];co

;sh=11433 & freqshot=2.5 & tr2=[2.2,4.21];co

;sh=11434 & freqshot=2.5 & tr2=[3.215, 5.225];co

;sh=11004 & freqshot=2 & tr2=[2,6];counter


tr=tr2

getece,sh,res,tr=tr,/alt

eb:
;res.r1=findgen(48)
;tmp=transpose(reform(res.ang(*,35,*)))-12
;ix=where(res.r1 gt -240 and res.r1 lt -160)
ix=findgen(48)
tmp=res.ang
nsub=3
ix2=ix(indgen(n_elements(ix)/nsub)*nsub)
imgplot,tmp(*,ix),res.t,res.r1(ix),/cb,pos=posarr(1,3,0),pal=-2
;plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-20,10],/noer,offy=-1
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
;ec=cgetdata('\ECH_VFWD1',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer
lv=cgetdata('\LV23',sh=sh,db='kstar')
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,col=2,ysty=8
ip=cgetdata('\RC01')
plot,ip.t,ip.v,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5+[-1,1]*10e4,ysty=1+4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=3
;stop
ec2=interpol(ec.v,ec.t,res.t)
f=fft_t_to_f(res.t)
isel=value_locate3(f,freqshot)
sz=size(res.ang,/dim)
amp=complexarr(sz(1))
amp2=amp
amp3=amp

;  a=''&read,'',a
;  if a ne '' then stop

ix=[intspace(fix(isel * 0.5),fix(isel * 0.8)),$
    intspace(fix(isel * 1.2),fix(isel * 1.5))]

fec2=fft(ec2)
ampref=fec2(isel)

for i=0,sz(1)-1 do begin
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

ix=intspace(48,71)
ix=intspace(0,47)
ix=ix(sort(res.r1(ix)))

;ix=sort(res.r1)
;n=n_elements(ix)
;if sh eq 11003 then isub=where(setcompl(findgen(n),[n-9,n-8,n-7,n-6]))
;isub=where(setcompl(findgen(n),[6+8,8+8,n-8]))
;ix=ix(isub)
;mkfig,'h:\eceft_'+string(sh,format='(I0)')+'.eps',xsize=12,ysize=9,font_size=9
pos=posarr(1,1,0,cnx=0.1,cny=0.1)
plot,res.r1(ix),abs(amp(ix)),ysty=8,ytitle='amplittude',title=string(sh,freqshot,format=    '("ECE : #",I0," f=",I0,"Hz")'),pos=pos,thick=3
legend,['amplitude','noise level','phase'],linesty=[0,2,0],col=[1,1,4],box=0
oplot,res.r1(ix),abs(amp2(ix)),linesty=2,thick=3
plot,res.r1(ix),abs(amp3(ix)),col=3,/noer,ysty=4,xsty=4,pos=pos
itime=value_locate(res.t,tr(1))
oplot,res.r1(ix),res.ang(itime,ix),col=5,psym=-4

plot,res.r1(ix),atan2(amp(ix)/ampref)*!radeg,col=4,/noer,ysty=4,xsty=4,pos=pos,yr=[-50,50]*5/5.,thick=3

axis,!x.crange(1),!y.crange(0),ytitle='Phase (deg)',yaxis=1,col=4
endfig,/gs,/jp

end

