;newdemodflclt,7757,frameoftime(7757,2.5),angt=ang1,dopc=dopc1,/only2,ix=ix2,iy=iy2,pp=p
newdemodflclt,7498,0,angt=ang1,dopc=dopc1,/only2,ix=ix2,iy=iy2,pp=p

;getptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,/plane,rxs=rxs,rys=rys,/calca
sz=size(r,/dim)
iz0=value_locate(z(sz(0)/2,*),0)
r1=r(*,iz0)
z1=z(sz(0)/2,*)

imgplot,ang1,-r1,z1


end
