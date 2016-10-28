pro calibration_data, image_dx, column,lowfreq,highfreq

withoutdelay=read_tiff('C:\haitao\papers\study topics\H-1 projection\data\test image1.tif',image_index=image_dx)
withdelay=read_tiff('C:\haitao\papers\study topics\H-1 projection\data\test image2.tif',image_index=image_dx)
pick_data1=withdelay(column,*)-2500
fourier_trans1=fft(pick_data1)
intensity_fft1=fourier_trans1
intensity_fft1[lowfreq:512-lowfreq]=0
intensity1=fft(intensity_fft1,-1)
fourier_trans1[0:lowfreq]=0
fourier_trans1[highfreq:-1]=0
complex_coherence1=fft(fourier_trans1, -1)



pick_data=withoutdelay(column,*)-2500
fourier_trans=fft(pick_data)
intensity_fft=fourier_trans
intensity_fft[lowfreq:512-lowfreq]=0
intensity=fft(intensity_fft,-1)
fourier_trans[0:lowfreq]=0
fourier_trans[highfreq:-1]=0
complex_coherence=fft(fourier_trans, -1)
contrast=2*abs(complex_coherence)/intensity
p=plot(contrast,xtitle='x',ytitle='contrast')
angle=atan(imaginary(complex_coherence),float(complex_coherence))
;phase=plot(angle,xtitle='x',ytitle='phase/radians')
coherence_diff=complex_coherence1/complex_coherence
angle_diff=atan(imaginary(coherence_diff),float(coherence_diff))
phase_diff=plot(angle_diff,xtitle='x',ytitle='phase/radians')
stop
end