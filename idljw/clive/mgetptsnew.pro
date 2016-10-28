pro mgetptsnew,pts=pts,doback=doback,str=str,ix=ix1,iy=iy1,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang,plane=plane,calca=calca,rxs=rxs,rys=rys,distback=distback,mixfactor=mixfactor,dobeam2=dobeam2

if not keyword_set(mixfactor) then $
   getptsnew,pts=pts,doback=doback,str=str,ix=ix1,iy=iy1,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang,plane=plane,calca=calca,rxs=rxs,rys=rys,distback=distback,dobeam2=dobeam2 $
else begin
   getptsnew,pts=pts,doback=doback,str=str,ix=ix1,iy=iy1,bin=bin,rarr=rarr1,zarr=zarr1,cdir=cdir,ang=ang,plane=plane,calca=calca,rxs=rxs1,rys=rys1,distback=distback
   getptsnew,pts=pts,doback=doback,str=str,ix=ix1,iy=iy1,bin=bin,rarr=rarr2,zarr=zarr2,cdir=cdir,ang=ang,plane=plane,calca=calca,rxs=rxs2,rys=rys2,distback=distback,/dobeam2
   rxs = (1-mixfactor) * rxs1 + mixfactor * rxs2
   rys = (1-mixfactor) * rys1 + mixfactor * rys2
   rarr = (1-mixfactor) * rarr1 + mixfactor * rarr2
   zarr = (1-mixfactor) * zarr1 + mixfactor * zarr2
   sz=size(rarr1,/dim)
;   mkfig,'~/rposcmp.eps',xsize=13,ysize=10,font_size=11
;   plot,rarr1(*,sz(1)/2),/yno,ytitle='R value (cm)',xtitle='x pix in image (downsamped)'
;   oplot,rarr2(*,sz(1)/2),col=2
;   legend,['beam1','beam2'],textcol=[1,2],/right,box=0
;endfig,/gs,/jp
;   stop
endelse




end
