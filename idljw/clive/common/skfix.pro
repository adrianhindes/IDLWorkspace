
;input parameters, with appropriate defaults:
;testt=.01  :: criterion on on convergence of entropy, scale is 0-1 generally, this measures the orthogonality of search directions in iteration proceudure
;dchi=0.1 :: when to stop reduceing chisq
;l2thres=0.1 :: some parameter ?  forgot.  can find in paper, I sent you
;drangemax=1e5 :: the maximum dynamic range of reconstruction
;svthres=1e3 :: the max condition number for doing some inverse procedure to find search directions, dont change



fname='indatab1.txt'

openr,lun,fname,/get_lun
readf,lun,na,nm
matrr=dblarr(na*nm)
rcoeffr=fltarr(nm)
acoefft=fltarr(na)
 readf,lun, matrr
 readf,lun,rcoeffr
 readf,lun,acoefft
readf,lun,dchi,testt,drangemax,svthres,l2thres
matr=reform(matrr,na,nm)
close,lun
free_lun,lun

;acoefft/=1e16
;rcoeffr/=1e16
;matr*=1e16
;acoefft(*)=1.
;drangemax=1000.

;rcoeffr(*)=1.
;matr(*)=0.
;for i=0,63 do matr(i,i)=1.
;plot,rcoeffr
;rcoeffr=matr ## acoefft+5
;oplot,rcoeffr,col=2
;rcoeffr/=3.
;matr/=3
;acoefft(*)=1.
acoefft=acoefft(54:*) & na=n_elements(acoefft)
matr=matr(54:*,*)

fname2='indatab2.txt'
openw,lun,fname2,/get_lun
printf,lun,na,nm
matrr=reform(matr,na*nm)
for i=0L,na*nm-1 do printf,lun,matrr(i)
for i=0L,nm-1 do printf,lun,rcoeffr(i)
for i=0L,na-1 do printf,lun,acoefft(i)
printf,lun,dchi,testt,drangemax,svthres,l2thres
close,lun
free_lun,lun

print,'end'
end

