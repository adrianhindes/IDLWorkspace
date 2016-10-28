pro loaddata,file=file

common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1


default,file,'boozmn_wout_kh0.850-kv1.000fixed.nc'
fn='/home/cmichael/idl/'+file+'.sav'
restore,file=fn
file1=file
end
