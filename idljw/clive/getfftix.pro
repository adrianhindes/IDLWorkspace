pro getfftix, sz,ix,iy,ix2,iy2, ang2
nx=sz(0)
ny=sz(1)
ix=findgen(nx)
iy=findgen(ny)
i1=where(ix gt nx/2)
ix(i1)=ix(i1)-nx
i2=where(iy gt ny/2)
iy(i2)=iy(i2)-ny

ix/=nx
iy/=ny

ix2=ix # replicate(1,ny)
iy2=replicate(1,nx) # iy
ang2=atan(float(iy2),float(ix2))

end
