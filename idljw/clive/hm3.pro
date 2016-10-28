tr=[2.3,4.6]
sh=9397
cachewrite=1
cacheread=1
newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype='sm22013mse',cachewrite=cachewrite,cacheread=cacheread,/noid2

tr=[2.4,3.0]
newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype='sm22013mse',nsm=1,nskip=1,cachewrite=cachewrite,cacheread=cacheread,/noid2
sz=size(res.ang,/dim)
res.ang-=12
for i=0,n_elements(res.t)-1 do begin
   ref=res.ang(110,12,i)
;   res.ang(*,*,i)=res.ang(*,*,i)-ref
endfor

tmp=transpose(reform(res.ang(*,sz(1)/2,*)))
tmp2=transpose(reform(res.inten(*,sz(1)/2,*)))
ix=where(res.r1 gt -9999)
nsub=3
ix2=ix(indgen(n_elements(ix)/nsub)*nsub)


imgplot,tmp(*,ix),res.t,res.r1(ix),/cb,zr=[-20,30]/2,pos=posarr(1,4,0),pal=-2
imgplot,tmp2(*,ix),res.t,res.r1(ix),/cb,pos=posarr(/next),pal=-2,/noer,yr=[-240,-220]
plotm,res.t,tmp(*,ix2),pos=posarr(/next),yr=[-30,20],/noer,offy=-1,psym=-4
;ec=cgetdata('\POL_HA03',sh=sh,db='kstar');\TUBE07
de=cgetdata('\NE_INTER01',sh=sh,db='kstar');\TUBE07
ec=cgetdata('\NB11_VG2',sh=sh,db='kstar');\TUBE07
;        if aux eq 'nbi1_v' then daux=cgetdata('\NB11_VG1')


plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/next),/noer,/yno
plot,de.t,de.v,xr=!x.crange,pos=posarr(/curr),/noer,/yno,col=2
!x.range=0
;lv=cgetdata('\LV01',sh=sh,db='kstar')
;plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/curr),/noer,col=2
;;ip=cgetdata('\RC01')
;plot,ip.t,ip.v,xr=!x.crange,pos=posarr(/curr),/noer,col=3,yr=-7e5+[-1,1]*10e4,ysty=1


   a=''&read,'',a
i0=0
for i=0,n_elements(res.t)-1 do begin
   imgplot,res.ang(*,*,i0+i),title=res.t(i+i0),zr=[-10,15],pal=-2,pos=posarr(1,3,0)
   ii=indgen(12)*2
   plotm,res.ang(*,ii,i0+i),title=res.t(i),yr=[-10,15],psym=3,pos=posarr(/next),/noer
   idx=where(ec.t ge tr(0) and ec.t le tr(1))
   plot,ec.t(idx),ec.v(idx),xr=tr,pos=posarr(/next),/noer
   plot,de.t,de.v,xr=!x.crange,pos=posarr(/curr),/noer,/yno,col=2
   oplot,res.t(i)*[1,1],!y.crange,col=3
   a=''&read,'',a
   if a ne '' then stop
endfor


end

