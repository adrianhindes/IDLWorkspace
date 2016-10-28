pro mb_cart2flux_cl, rp,zp,rhop, thp,phi=phip
common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1
iwant=value_locate3(phiarr,phip)
ix=interpol(findgen(n_elements(rout)),rout,rp)
iy=interpol(findgen(n_elements(zout)),zout,zp)
rhop=interpolate(rhogrid3(*,*,iwant),ix,iy)
rcthp=interpolate(rcthgrid3(*,*,iwant),ix,iy)
rsthp=interpolate(rsthgrid3(*,*,iwant),ix,iy)
thp=atan(rsthp,rcthp)

end
