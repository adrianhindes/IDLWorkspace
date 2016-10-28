;d=getimgnew('cal_1',db='ctest',0)*1. - getimgnew('cal_1bg',db='ctest',0)*1.
d=getimgnew('cal_17',db='c2test',0)*1. - getimgnew('cal_16bg',db='c2test',0)*1.


newdemod,d,cars,sh='cal_1',db='c2test',doplot=1,demodtype='basic',lam=530.e-9,kz=kz
zeta=abs(cars(*,*,1))/abs(cars(*,*,0))*2
imgplot,zeta,/cb,zr=[0,1]


end


