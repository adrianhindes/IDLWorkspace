pro csgn, d, t0=t0,sampdt=dtsamp,df=df,dt=dt,xr=xr,yr=yr,nohan=nohan,zr=zr

spectdata2,d,ps,t,f,t0=t0,fdig=1/dtsamp,dt=dt,df=df,nohan=nohan

contourn2,alog10(ps),t,f,xr=xr,yr=yr,/cb,zr=zr

end

