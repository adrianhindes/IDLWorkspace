@phs_jump
pro loaddata,file=file

common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1


default,file,'boozmn_wout_kh0.850-kv1.000fixed.nc'
fn='/home/cmichael/idl/'+file+'.sav'
restore,file=fn
file1=file
end


pro mb_flux2cart,rhop,thp,rp,zp,phi=phip

common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1
iwant=value_locate3(phiarr,phip)
ix=interpol(findgen(n_elements(rho1(*,0))),rho1(*,0),rhop)
iy=interpol(findgen(n_elements(theta1(0,*))),theta1(0,*),thp)
rp=interpolate(r1(*,*,iwant),ix,iy)*1000.
zp=interpolate(z1(*,*,iwant),ix,iy)*1000.
end

loaddata
common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1


contour,sqrt(rhogrid3(*,*,2)),rout*1e3,zout*1e3,/iso,xr=[1000,1400],yr=[-150,250],pos=posarr(2,1,0),lev=linspace(0,.98,5)

rhosel=.56^2 ; for 240/250
;rhosel=.76^2 ; for 260
rhosel=0.95^2
np=2
span=0.
start=25.*!dtor & xform=7./5.;4./3.;7./5.

;start=-135.*!dtor & xform=1.5;3./2.;7./5.;4./3.;7./5.




;th0 =  2*!pi+(-105.44)*!dtor * (7./5.) +start; approx for transform of 7/5.

th0 =  bmod( (360-105.44)*!dtor * (xform) +start ); approx for transform of 7/5.

print,'th0=',th0*!radeg
; other at -105.44deg, Z=118 (-519,-1879,118)

mb_flux2cart,rhosel,bmod(start+ xform*7.2*!dtor),rb,zb,phi=7.2*!dtor
plots,rb,zb,psym=4

db=rb-(1112-44.)
contour,sqrt(rhogrid3(*,*,5)),rout*1e3,zout*1e3,/iso,xr=[1000,1400],yr=[-100,300],/noer,pos=posarr(/next),lev=linspace(0,.98,5)


;;note that in martijns program I was using the subtraction for droop:
;th=float(th(idx)) -0.7


mb_flux2cart,replicate(rhosel,np),linspace(th0,th0+span*!dtor,np),r,z,phi=-105.44*!dtor
oplot,r,z,psym=4


th0 =  bmod( (-105.44)*!dtor * (xform) +start ); approx for transform of 7/5.

print,'th0=',th0*!radeg

mb_flux2cart,replicate(rhosel,np),linspace(th0,th0+span*!dtor,np),r,z,phi=-105.44*!dtor
oplot,r,z,psym=4,col=2



end
