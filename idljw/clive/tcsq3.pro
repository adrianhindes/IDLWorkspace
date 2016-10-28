;d=getimgnew('cal_1',db='ctest',0)*1. - getimgnew('cal_1bg',db='ctest',0)*1.
dtype='basics'

fac=0.9

db='c5test'&fil='cal_23' & filbg='cal_22'+'bg'&fr=0
;db='c5test'&fil='cal_24' & filbg=fil+'bg'&fr=0
;db='c2test'&fil='cal_25' & filbg='cal_24'+'bg'&fr=0&dtype='basicsv'
;db='c5test'&fil='cal_26' & filbg='cal_26'+'bg'&fr=0&dtype='basics'&fac=fac*2
;db='c2test'&fil='cal_27' & filbg='cal_26'+'bg'&fr=0&dtype='basicsv'&fac=fac*2


d=getimgnew(fil,db=db,fr)*1. - getimgnew(filbg,db=db,0)*1.
;if n_elements(fac) eq 0 then fac=1.
newdemod,d,cars,sh=fil,db=db,doplot=1,demodtype=dtype,lam=530.e-9*fac,kz=kz
stop
zeta=abs(cars(*,*,1))/abs(cars(*,*,0))*2
imgplot,zeta,/cb,zr=[0,1]


end


