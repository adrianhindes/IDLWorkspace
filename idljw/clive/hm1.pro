tr=[1.3,2.6]
sh=9392
cachewrite=1
cacheread=0
newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype='sm22013mse',cachewrite=cachewrite,cacheread=cacheread,/noid2
tr=[2.1,2.2]
newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype='sm22013mse',nsm=1,nskip=1,cachewrite=cachewrite,cacheread=cacheread,/noid2
sz=size(res.ang,/dim)
tmp=transpose(reform(res.ang(*,sz(1)/2,*)))-12
ix=where(res.r1 gt -9999)
nsub=3
ix2=ix(indgen(n_elements(ix)/nsub)*nsub)

imgplot,tmp(*,ix),res.t,res.r1(ix),/cb,zr=[-20,30]/2,pos=posarr(1,3,0),pal=-2
plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-30,20],/noer,offy=-1,psym=-4
ec=cgetdata('\TUBE07',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer
!x.range=0
;lv=cgetdata('\LV01',sh=sh,db='kstar')
;plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/curr),/noer,col=2
;;ip=cgetdata('\RC01')
;plot,ip.t,ip.v,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5+[-1,1]*10e4,ysty=1


   a=''&read,'',a
i0=value_locate(res.t,2.10)
for i=0,20 do begin
   imgplot,res.ang(*,*,i0+i)-12,title=res.t(i+i0),zr=[-10,15]
   a=''&read,'',a
endfor


end

