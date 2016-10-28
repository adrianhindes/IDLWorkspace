;d=getimgnew('cal_1',db='ctest',0)*1. - getimgnew('cal_1bg',db='ctest',0)*1.

;db='ctest'&fil='cal_1' & filbg=fil+'bg'&fr=0
;db='c4test'&fil='cal_19' & filbg=fil+'bg'&fr=0
;db='c2test'&fil='cal_15' & filbg='cal_16bg'&fr=0
db='c3test'&fil='cal_18' & filbg='cal_18bg'&fr=0
;db='c3test'&fil='cal_20' & filbg=fil+'bg'&fr=0
;db='c6test'&fil='cal_32' & filbg='cal_28'+'bg'&fr=0
;db='c7test'&fil='cal_33' & filbg='cal_33'+'bg'&fr=0

d=getimgnew(fil,db=db,fr)*1. - getimgnew(filbg,db=db,0)*1.

;d=read_tiff('~/quadinstall.tif',image_index=0)

newdemod,d,cars,sh=fil,db=db,doplot=1,demodtype='basicsv',lam=530.e-9,kz=kz
;stop
zeta=abs(cars(*,*,1))/abs(cars(*,*,0))*2
imgplot,zeta,/cb,zr=[0,1]


end


