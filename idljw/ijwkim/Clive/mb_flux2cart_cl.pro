pro mb_flux2cart_cl,rhop,thp,rp,zp,phi=phip

common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1
iwant=value_locate3(phiarr,phip)
ix=interpol(findgen(n_elements(rho1(*,0))),rho1(*,0),rhop)
iy=interpol(findgen(n_elements(theta1(0,*))),theta1(0,*),thp)
rp=interpolate(r1(*,*,iwant),ix,iy)*1000.
zp=interpolate(z1(*,*,iwant),ix,iy)*1000.
;stop
end


