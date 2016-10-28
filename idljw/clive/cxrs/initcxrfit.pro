@mygaussbgfit
@mygaussfit
@fittoit
pro initcxrfit, sh=sh,carscal=carscal5,carshite=carswhite,pc=pc,kzv=kzv



db='c'

loadcxrdat,sh=sh,img=cal,type='cal',cars=carscal
demodcxrssub, cal, carscal,sh=sh,db=db,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,/just,kz=kz
correctphase, sh,carscal, carscal5, db=db,shload=shload,thx=thx,thy=thy,pc=pc,kzv=kzv

;white light
loadcxrdat,sh='cxrstest4_tuni_white_cxrsfilter',img=white,type='whiteandcal'
loadcxrdat,sh='cxrstest4_tuni_lasertr',img=whitelasertr,type='whiteandcal'
demodcxrssub, whitelasertr, carswhitelasertr,sh='cxrstest4_tuni_lasertr',db='k2',demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,/just
correctphase, 'cxrstest4_tuni_lasertr',carswhitelasertr, carswhitelasertr5, db='k2',shload=88888,thx=thx,thy=thy
demodcxrssub, white, carswhite,carswhitelasertr5,sh='cxrstest4_tuni_white_cxrsfilter',db='k2',demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=1
;;;


end
