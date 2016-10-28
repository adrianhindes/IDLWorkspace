pro spatial_heterodyne_imaging_2D, image_dx, low_row,high_row

offset=read_tiff('C:\haitao\papers\study topics\H-1 projection\data\rs image data\black picture.tif',image_index=image_dx)

calibration_data_2d=read_tiff('C:\haitao\papers\study topics\H-1 projection\data\rs image data\calibration image.tif',image_index=image_dx)-2600
cal_fourier_2d=fft(calibration_data_2d,/center)
cal_fourier1_2d=cal_fourier_2d
;cal_fourier_2d[findgen(low_column),*]=0
;cal_fourier_2d[findgen(512-high_column)+high_column,*]=0
cal_fourier_2d[*,findgen(low_row)]=0
cal_fourier_2d[*,findgen(512-high_row)+high_row]=0

;cal_fourier1_2d[findgen(low_column),*]=0
;cal_fourier1_2d[findgen(512-high_column)+high_column,*]=0
cal_fourier1_2d[*,findgen(high_row)]=0
cal_fourier1_2d[*,findgen(512-high_row-80)+high_row+80]=0
cal_intensity_2d=fft(cal_fourier1_2d, /inverse,/center)

cal_complex_coherence=fft(cal_fourier_2d, /inverse,/center)
cal_contrast=2*abs(cal_complex_coherence)/abs(cal_intensity_2d)

experiment_data=read_tiff('C:\haitao\papers\study topics\H-1 projection\data\rs image data\shot77418.tif',image_index=image_dx)-offset-250
fourier_trans_2d=fft(experiment_data,/center)
fourier_trans1_2d=fourier_trans_2d
;fourier_trans_2d[findgen(low_column),*]=0
;fourier_trans_2d[findgen(512-high_column)+high_column,*]=0
fourier_trans_2d[*,findgen(low_row)]=0
fourier_trans_2d[*,findgen(512-high_row)+high_row]=0
complex_coherence=fft(fourier_trans_2d,/inverse,/center)


;fourier_trans1_2d[findgen(low_column),*]=0
;fourier_trans1_2d[findgen(512-high_column)+high_column,*]=0
fourier_trans1_2d[*,findgen(low_row-60)]=0
fourier_trans1_2d[*,findgen(512-low_row)+low_row]=0
intensity=fft(fourier_trans1_2d,/inverse,/center)



contrast=2*abs(complex_coherence)/abs(intensity)
contrast_diff=contrast/cal_contrast

coherence=complex_coherence/cal_complex_coherence
phase_diff=atan(imaginary(coherence),float(coherence))


;contrast_plot=image(contrast_diff, title='contrast diviation',rgb_table=2,axis_style=1)
;phase_plot=image(phase_diff,title='phase diviation',rgb_table=4,axis_style=1)
window,0,title='contrast'
imgplot,contrast_diff,zr=[0,1],/cb
window,1,title='phase'
imgplot,phase_diff*!radeg,zr=[-180,180],/cb




stop
end