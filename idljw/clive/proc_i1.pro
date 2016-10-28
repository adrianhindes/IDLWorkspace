;goto,ee
v1=read_tiff('~/apic.tif',image_index=7)&v1=rotate(v1,2)

v2a=read_tiff('~/apic2.tif',image_index=0)&v2a=rotate(v2a,2)
v2=congrid(v2a,1024,1024)

v2p=logclipm(v2,eu=8,el=3)
window,0,ysize=1000
imgplot,v2p,/cb,pos=posarr(1,2,0),/iso
imgplot,logclipm(v1),/cb,pos=posarr(/next),/noer,/iso


retall
n=20
darr=fltarr(1024,1024,n)
for i=0,19 do begin
v1d=read_tiff('~/apic.tif',image_index=i)&v1d=rotate(v1d,2)
darr(*,*,i)=v1d
endfor

s=totaldim(darr,[0,0,1])
ee:

imgplot,logclipm(s),/cb
stop
imgplot,v2p,/cb

end
