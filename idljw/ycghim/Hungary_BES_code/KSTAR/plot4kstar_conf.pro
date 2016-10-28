pro plot4kstar_conf
hardon, /color
;Plot beam image on CCD image
device, decomposed=0
loadct, 3
fourcord_b=[[451,472,428,496],[318,387,364,341]]
fourcord_m=[[410,431,386,454],[186,255,231,208]]
oa_pic=[320,240]
calc_nbi_oa, shot=shot, oa_nbi=oa_11, oa_pic=[0,0], direction=2, fourcord=fourcord_b
calc_nbi_oa, shot=shot, oa_nbi=oa_12, oa_pic=[0,480], direction=2, fourcord=fourcord_b
calc_nbi_oa, shot=shot, oa_nbi=oa_21, oa_pic=[640,0], direction=2, fourcord=fourcord_b
calc_nbi_oa, shot=shot, oa_nbi=oa_22, oa_pic=[640,480], direction=2, fourcord=fourcord_b
oa_11=xyztocyl(oa_11)
oa_12=xyztocyl(oa_12)
oa_21=xyztocyl(oa_21)
oa_22=xyztocyl(oa_22)
cd, 'D:\KFKI\Measurements\KSTAR\Measurement'  
restore, 'cal/7715_CCD.sav'
xscale=1.5*(oa_11[0]-oa_21[0])*dindgen(640)/640.+oa_21[0]
yscale=1.5*(oa_11[1]-oa_22[1])*dindgen(480)/480.+oa_22[1]+230
contour, data_arr[150,*,*]<3000, xscale, yscale,  nlevels=100, /fill, /isotrop, xtitle='Minor radius [mm]',$
         ytitle='z [mm]', title='NBI beam with CCD 7715'
hardfile, '7715_beam_image.ps'

;plot vertical raw data and spectra



stop
;pix2cord_p=[[alfa_x2r,beta_x2r],[alfa_y2z,beta_y2z]]

end