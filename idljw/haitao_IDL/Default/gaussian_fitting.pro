pro gaussian_fitting ,image_dx,nterm,low_point,high_point

data=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\spectrometer\2013 July 18 15_48_07.tif',image_index=image_dx)
ins_data=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\spectrometer\2013 July 22 14_05_50.tif',image_index=image_dx)
sam_ins=ins_data(*,350)
weights=1.0/SAM_INS
cur_fit=curvefit(findgen(1024),sam_ins,WEIGHTS)
sam_ins[0:low_point]=0
sam_ins[high_point:-1]=0
insx=max(sam_ins)
sam_ins=sam_ins/insx


sam_data=data(*,350)
sam_data[0:low_point]=0
sam_data[high_point:-1]=0
sam_max=max(sam_data)
sam_data=sam_data/sam_max

sam_gauss=gaussfit(findgen(1024),sam_data,coff,nterms=nterm)
fitsignal=convol(sam_gauss,sam_ins)

p=plot(fitsignal)


p1=plot(sam_data)
print,'center length :',coff(1)
print,'FWHM :',2*sqrt(2*alog(2))*coff(2)
;gauss=make_array(1024,736)
;coff=make_array(nterm,736)
;for i=0,735 do begin
;gauss(*,i)=gaussfit(findgen(1024),data(*,i),coff,nterms=nterm)
;endfor

;gauss_2d=image(gauss, rgb_table=4,axis_style=1)



stop
end