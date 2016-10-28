
;goto,ee

filter_memory, 13501,istart=frameoftime(13501,5.4),iend=frameoftime(13501,6.6),nmedian=5,nstddev=2
newdemodashshot,13501,[5.5,6.5],res=res,/cachewrite,filter=1


ee:

kern=fltarr(3,11,1)+1.

ang=res.ang
sz=size(ang,/dim)

for i=0,sz(2)-1 do ang(*,*,i)=convol(res.ang(*,*,i),kern/total(kern))
;imgplot,ang(*,*,0)
array=transpose(reform(ang(*,sz(1)/2,*)))
array2=array
for i=0,sz(0)-1 do array2(*,i)=array(*,i)-array(0,i)
mkfig,'~/steeth2.eps',xsize=28,ysize=18,font_size=10

;plotm,res.t+.01,array2,pos=posarr(1,1,0),xsty=1,xticklen=1,xtickstyle=3,offy=0.15;,xr=[5.5,5.6]+.05,xsty=1,xti

plotm,res.t+.01,array,pos=posarr(1,1,0),xsty=1,xticklen=1,xtickstyle=3;,xr=[5.5,5.6]+.05,xsty=1,xti

d=cgetdata('\ECE48',sh=13501)
plot,d.t,d.v,xr=!x.crange,pos=posarr(1,3,2),/noer,/ynozero,xsty=1

d=cgetdata('\NB11_I0',sh=13501)
plot,d.t,d.v,xr=!x.crange,pos=posarr(1,3,2),/noer,/ynozero,xsty=1,COL=3
d=cgetdata('\NB12_I0',sh=13501)
plot,d.t,d.v,xr=!x.crange,pos=posarr(1,3,2),/noer,/ynozero,xsty=1,COL=4

endfig,/gs,/jp
end
