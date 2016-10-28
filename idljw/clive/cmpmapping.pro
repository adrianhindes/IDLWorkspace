readpatch,11433,p
getptsnew,rarr=r,zarr=z,str=p,bin=8

p.mapping='11433.297'
readmapping,p.mapping, mapstr
p.mapstr=mapstr

getptsnew,rarr=r2,zarr=z2,str=p,bin=8

iz0=value_locate(z(80/2,*),0)
plot,r(*,iz0)
oplot,r2(*,iz0),col=2
plot,r(*,iz0),r2(*,iz0)-r(*,iz0),yr=[-2,0]
iz1=value_locate(z2(80/2,*),0)
end

