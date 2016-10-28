pro skentwrite, matr, rcoeffr, testt=testt,acoefft=acoefft,dchi=dchi,chisq=chisq,drangemax=drangemax,svthres=svthres,l2thres=l2thres,path=path
na=n_elements(matr(*,0))
nm=n_elements(matr(0,*))

;suff=string(!starttime,format='(I0)')
suff='1'
default,path,'/home/cmichael/forte'
fname=path+'/indata'+suff+'.txt' 
fout=path+'/outdata'+suff+'.txt' 
fexec=path+'/a.out '+fname+' '+fout

openw,lun,fname,/get_lun
printf,lun,na,nm
matrr=reform(matr,na*nm)
for i=0L,na*nm-1 do printf,lun,matrr(i)
for i=0L,nm-1 do printf,lun,rcoeffr(i)
for i=0L,na-1 do printf,lun,acoefft(i)
printf,lun,dchi,testt,drangemax,svthres,l2thres
close,lun
free_lun,lun
print, 'printed data to fort\indata.txt'

spawn,fexec;                     ,/log_output


openr,lun,fout,/get_lun
readf,lun,na
readf,lun,acoefft
readf,lun,chisq
close,lun
free_lun,lun

end

