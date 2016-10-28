 d=getimgnew('registration',0,db='d3d',str=str)     

getptsnew,pts=pts,str=str,bin=16,/d3d30l,rarr=rarr,zarr=zarr,/plane,ix=ix,iy=iy,rxs=rxs,rys=rys,/calca

imgplot,d,/cb,title='30R'
contour,rarr,ix,iy,/noer,nl=10,c_lab=replicate(1,10)
contour,zarr,ix,iy,/noer,nl=10,c_lab=replicate(1,10)

save,rxs,rys,rarr,xarr,ix,iy,file='~/reg_30l.sav',/verb
end


;,ix=ix1,iy=iy1,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang,plane=plane,calca=calca,rxs=rxs,rys=rys,distback=distback,dobeam2=dobeam2,detx=detx,dety=dety,pptsonly=ptsonly,lene=lene,nl=nl,nx=nx,ny=ny,leno=leno
