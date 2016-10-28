pro cohdemo,low_column,high_column,low_row,high_row

;tomography
;hydroen
;constant
c=3.0*1e8 
m=1.67*1e-27 
k=1.38*1e-23
hbeta=486.133 
L1=5.0 ;length in mm
L2=50 ;length in mm
delta_n=linbo3(hbeta, kapa=kapa)
H_kapa=kapa
Tc_h1=2*m*(hbeta*1e-9)^2*c^2/(L1*1e-3)^2/k/H_kapa^2/delta_n^2/!pi^2/4/11600.0 ;5 mm linbo3
Tc_h2=2*m*(hbeta*1e-9)^2*c^2/(L2*1e-3)^2/k/H_kapa^2/delta_n^2/!pi^2/4/11600.0 ;50 linbo3
;carbon658 chariactraisatic temperature
delta_n=linbo3(658.0, kapa=kapa)
Tc_c1=2*12*m*(658.0*1e-9)^2*c^2/(25.0*1e-3)^2/k/kapa^2/delta_n^2/!pi^2/4/11600.0 ;25 mm linbo3
Tc_c2=2*12*m*(658.0*1e-9)^2*c^2/(35.0*1e-3)^2/k/kapa^2/delta_n^2/!pi^2/4/11600.0 ;35 mm linbo3
;carbon514 chariactraisatic temperature
delta_n=linbo3(514.5, kapa=kapa)
Tc_514=2*6*m*(514.5*1e-9)^2*c^2/(13.0*1e-3)^2/k/kapa^2/delta_n^2/!pi^2/4/11600.0 ;10 mm linbo3+3.2 mm bbo


;calibration
fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-03-2014\calibration 13 08-03-2014.SPE'
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-03-2014\calibration 14 08-03-2014.SPE'
;fil1=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 28-01-2014\heat filter for 660 nm line.tif')
;fil2=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 28-01-2014\background for heating.tif')



read_spe, fil2, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
offset=d

read_spe, fil1, lam, t,d,texp=texp,str=str,fac=fac  & d=float(d)

calibration_data_2d=d-offset
han=hanning(512,512)
cal_fourier_2d=fft(calibration_data_2d*han,/center)
imgplot, abs(cal_fourier_2d), /cb, zr=[0,100]
cal_fourier1_2d=cal_fourier_2d
;retanglar demodulation
cal_fourier_2d[findgen(low_column),*]=0
cal_fourier_2d[findgen(512-high_column)+high_column,*]=0       ;2.0 mm savart plate 235:245,250:260
;cal_fourier_2d[*,findgen(low_row)]=0
;cal_fourier_2d[*,findgen(128-high_row)+high_row]=0

cal_fourier1_2d[findgen(high_column+25),*]=0
cal_fourier1_2d[findgen(512-high_column-55)+high_column+55,*]=0
;cal_fourier1_2d[*,findgen(low_row)]=0
;cal_fourier1_2d[*,findgen(512-high_row)+high_row]=0
cal_intensity_2d=fft(cal_fourier1_2d, /inverse,/center)

;circular demodulation
;center_column=(low_column+high_colu mn)/2
;center_row=(low_row+high_row)/2
;radius=(high_column-low_column)/2
;for m=0,511 do begin
  ;for n=0,127 do begin
    ;if ((m-center_column)^2+(n-center_row)^2) gt radius^2 then begin 
     ; cal_fourier_2d(m,n)=0 
      ;endif
      ;endfor
      ;endfor
      
;cal_fourier1_2d[findgen(high_column),*]=0
;cal_fourier1_2d[findgen(512-high_column-60)+high_column+60,*]=0
;center_column1=(2*high_column-low_column)/2
;center_row1=(low_row+high_row)/2
;for m=0,511 do begin
  ;for n=0,127 do begin
   ; if ((m-center_column1)^2+(n-center_row1)^2) gt radius^2 then begin 
      ;cal_fourier1_2d(m,n)=0 
      ;endif
      ;endfor
     ; endfor

cal_intensity_2d=fft(cal_fourier1_2d, /inverse,/center)
cal_complex_coherence=fft(cal_fourier_2d, /inverse,/center)
cal_contrast=2*abs(cal_complex_coherence)/abs(cal_intensity_2d)

;cal1=cal_complex_coherence ;calibration 5,6
;cal1_c=cal_contrast
;cal2=cal_complex_coherence ;calibration 1,1
;cal2_c=cal_contrast
;save, cal2, cal2_c,filename='calibration 2.save'

;restore, 'calibration 1.save'
;restore, 'calibration 2.save'
;g=image(rebin(cal_contrast-cal2_c,5120,1280), findgen(5120)*0.1,findgen(1280)*0.1,xtitle='Xpixel',rgb_table=4,axis_style=1,ytitle='Ypixel',title='Contrast shift between two calbration',max_value=0.15,min_value=-0.15,layout=[1,2,1],aspect_ratio=2)
;c=colorbar(target=g, orientation=1)
;g1=image(rebin(atan(cal_complex_coherence/cal2,/phase),5120,1280),findgen(5120)*0.1,findgen(1280)*0.1, rgb_table=4,axis_style=1,xtitle='Xpixel',ytitle='Ypixel',title='Phase shift between two calbration (radians)',min_value=-0.3,max_value=0.3,layout=[1,2,2],aspect_ratio=2,/current)
;c1=colorbar(target=g1, orientation=1)

;phase correction
;restore, 'Phase shift between line 532 and 514.5.save'
;save, cal_contrast, filename='contrast for 5.0 mm displacer.save'
;save, cal_contrast, filename='contrast for two 5 mm displacer.save'
stop
;readfile
fil3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81046.SPE'  ; ring:6494, freq:7.0 Mhz
fil3_1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81047.SPE'
fil3_2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81048.SPE'
fil3_3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81049.SPE'
fil3_4='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81050.SPE'

fil3_5='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81121.SPE' ;ring: around 6494, frep :7
fil3_6='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81124.SPE'
fil3_7='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81125.SPE'
fil3_8='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81126.SPE'
fil3_9='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81127.SPE'

fil3_10='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81135.SPE';ring: around 6494, frep :7
fil3_11='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81136.SPE'
fil3_12='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81137.SPE'
fil3_13='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81138.SPE'
fil3_14='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81139.SPE'

fil3_15='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81114.SPE';ring: around 6494, frep :7
fil3_16='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81115.SPE'
fil3_17='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81117.SPE'
fil3_18='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81118.SPE'
fil3_19='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81119.SPE'

fil3_20='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81029.SPE';ring: around 6494, frep :7
fil3_21='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81031.SPE'
fil3_22='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81033.SPE'
fil3_23='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81034.SPE'
fil3_24='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 24-10-2013\md_81035.SPE'

fil3_25='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81130.SPE';ring: around 6494, frep :7
fil3_26='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81131.SPE'
fil3_27='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81132.SPE'
fil3_28='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81133.SPE'
fil3_29='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81134.SPE'

fil3_30='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 16-10-2013\md_80682.SPE';ring: around 3989,freq :4.5
fil3_31='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 16-10-2013\md_80776.SPE'
fil3_32='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 16-10-2013\md_80705.SPE'
;fil3_33='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 16-10-2013\md_80838.SPE'
fil3_34='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 16-10-2013\md_80811.SPE'
fil3_35='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 16-10-2013\md_80841.SPE';ring: around 6494,freq :7.0


;c 514nm 10 delay line
fil1_arr=[fil3,fil3_1,fil3_2,fil3_3,fil3_4]
;h 486 nm 5 delay
fil2_arr=[fil3_5,fil3_6,fil3_7,fil3_8,fil3_9]
;carnon 658 nm 35 delay
fil3_arr=[fil3_10,fil3_11,fil3_12,fil3_13,fil3_14]
;carbon 514 13 delay
fil4_arr=[fil3_15,fil3_16,fil3_17,fil3_18,fil3_19]
;h 486nm with 15 delay
fil5_arr=[fil3_20,fil3_21,fil3_22,fil3_23,fil3_24]
;carbon 658nm with 25 mm delay
fil6_arr=[fil3_25,fil3_26,fil3_27,fil3_28,fil3_29]
;carbo 658 nm with 25 mm delay on 24/10
fil7_arr=[fil3_30,fil3_31,fil3_32,fil3_34,fil3_35]

contrast_arr=make_array(512,128,6,5,/float)
phase_arr=make_array(512,128,6,5,/float)
phase_c=make_array(512,128,6,5,/float)
tem_arr=make_array(512,128,6,5,/float)
data_arr=make_array(512,128,6,5,/float)
intensity_arr=make_array(512,128,6,5,/float)


;data from 11-12-2013
restore, 'data of i equals 3990.save'
restore, 'data of i equals 4190.save'
restore, 'data of i equals 4390.save'
restore, 'data of power equals 18.save'
restore, 'data of power equals 11.save'
restore, 'data of power equals 6.save'
restore, 'data of power equals 25.save'
restore, 'contrast offset for 658 lines with 35 mm delay.save'
restore,'data for probe.save';07-02-2014
restore, 'compensation contrast for 10 mm savart plate.save'
;demodulation
for i=0,4 do begin
read_spe, pfile(i), lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
for j=0,5 do begin
experiment_data=d(*,*,j+2)-d(*,*,12)
data_arr(*,*,j,i)=experiment_data
fourier_trans_2d=fft(experiment_data*han,/center)
fourier_trans1_2d=fourier_trans_2d
;retangular demodulation
fourier_trans_2d[findgen(low_column),*]=0
fourier_trans_2d[findgen(512-high_column)+high_column,*]=0
;fourier_trans1_2d[*,findgen(low_row)]=0
;fourier_trans1_2d[*,findgen(128-high_row)+high_row]=0

fourier_trans1_2d[findgen(high_column),*]=0
fourier_trans1_2d[findgen(512-high_column-50)+high_column+50,*]=0
fourier_trans1_2d[findgen(high_column),*]=0
;fourier_trans1_2d[*,findgen(50)]=0
;fourier_trans1_2d[*,findgen(128-80)+80]=0

;circular demodulation
;for m=0,511 do begin
  ;for n=0,127 do begin
    ;if ((m-center_column)^2+(n-center_row)^2) gt radius^2 then begin 
      ;fourier_trans1_2d(m,n)=0 
      ;endif
      ;endfor
      ;endfor
      
;for m=0,511 do begin
  ;for n=0,127 do begin
    ;if ((m-center_column1)^2+(n-center_row1)^2) gt radius^2 then begin 
     ;fourier_trans1_2d(m,n)=0 
      ;endif
      ;endfor
      ;endfor

intensity=fft(fourier_trans1_2d,/inverse,/center)
complex_coherence=fft(fourier_trans_2d,/inverse,/center)
contrast=2*abs(complex_coherence)/abs(intensity)
contrast_diff=contrast/cal_contrast

coherence=complex_coherence/cal_complex_coherence
phase_diff=atan(imaginary(coherence),float(coherence))

contrast_arr(*,*,j,i)=contrast_diff
phase_arr(*,*,j,i)=phase_diff
;phase_arr(210:*,*,j,i)=phase_arr(210:*,*,j,i)-!pi
phase_c(*,*,j,i)=phase_arr(*,*,j,i)
jumpimg, phase_c(*,*,j,i)
phase_c(*,*,j,i)=phase_c(*,*,j,i);+ps514
phase_c(*,*,j,i)=atan(cos(phase_c(*,*,j,i)), sin(phase_c(*,*,j,i)))
intensity_arr(*,*,j,i)=intensity
tem_arr(*,*,j,i)=-alog(contrast_arr(*,*,j,i)/ccontrast)*tc_c2

endfor
endfor
;temp3990=tem_arr
;save, temp3990,filename='temp data when power equals 3990.save'
stop
restore, 'temp data when i equals 4190.save'
t4190=[temp4190(260,80,4,0),temp4190(260,80,4,1), temp4190(260,80,4,2),temp4190(260,80,4,3)]
p4190=[power4190(0),power4190(1),power4190(2),power4190(3)]
restore, 'temp data when i equals 4390.save'
t4390=[temp4390(260,80,4,0),temp4390(260,80,4,2), temp4390(260,80,4,3),temp4390(260,80,4,4)]
p4390=[power4390(0),power4390(2),power4390(3),power4390(4)]
restore,'temp data when i equals 3990.save'
t3990=[temp3990(260,80,4,0),temp3990(260,80,4,1), temp3990(260,80,4,3)]
p3990=[power3990(0),power3990(1),power3990(3)]
restore, 'temp data when power equals 6.save'
restore,'temp data when power equals 11.save'
t11=[temp11(260,80,4,0),temp11(260,80,4,1)]
i11=[i11(0),i11(1)]
restore,'temp data when power equals 18.save'
;for shot91532 and 81554
;c=[3992, 3790]
;t=[temp18(260,80,4,0),temp3990(260,80,4,2)]
;p=plot(c, t, title='Comparison of shot81532 and 81554', symbol='*',xtitle='Current (A)', ytitle='Temperature (eV)')
stop
ypixel=findgen(81)+40
p3=plot(Ypixel,temp4390(260,40:120,4,0),xtitle='Ypixel',ytitle='Temperature(eV)', title='Temperature varition with pixels when i equals 4190',name='power=6.43',yrange=[5,20],color='red')
;p4=plot(Ypixel,temp4190(260,40:120,4,1),xtitle='Ypixel',ytitle='Temperature(eV)', title='Temperature varition with pixels when i equals 4190',name='power=11.65',yrange=[5,20],color='blue',/current)
p5=plot(Ypixel,temp4390(260,40:120,4,2),xtitle='Ypixel',ytitle='Temperature(eV)', title='Temperature varition with pixels when i equals 4190',name='power=11.7',yrange=[5,20],color='green',/current)
p6=plot(Ypixel,temp4390(260,40:120,4,3),xtitle='Ypixel',ytitle='Temperature(eV)', title='Temperature varition with pixels when i equals 4190',name='power=17.85',yrange=[5,20],color='orange',/current)
p7=plot(Ypixel,temp4390(260,40:120,4,4),xtitle='Ypixel',ytitle='Temperature(eV)', title='Temperature varition with pixels when i equals 4390',name='power=18.02',yrange=[5,20],color=121,/current)
l=legend(target=[p3,p5,p6],position=[0.90,0.90,0.95,0.95],/AUTO_TEXT_COLOR)



;p=plot(p3990,t3990,xtitle='P_RF_Net(kw)',ytitle='Temperature(eV)', title='Temperature varition with power',yrange=[8,14],xrange=[5,20],name='i=3990',color='red')
;p1=plot(p4190,t4190,xtitle='P_RF_Net(kw)',ytitle='Temperature(eV)', title='Temperature varition with power',yrange=[8,14],xrange=[5,20],name='i=4190',color='blue',/current)
;p2=plot(p4390,t4390,xtitle='P_RF_Net(kw)',ytitle='Temperature(eV)', title='Temperature varition with power',yrange=[8,14],xrange=[5,20],name='i=4390',color='green',/current)
;l=legend(target=[p,p1,p2],position=[0.90,0.90,0.95,0.95],/AUTO_TEXT_COLOR)
;
p=plot(i18,temp18(260,80,4,*),ytitle='Temperature(eV)', title='Temperature varition with current',name='power=18',yrange=[6,16],xrange=[3800,4800],color='red')
p1=plot(i11,t11,ytitle='Temperature(eV)', title='Temperature varition with current',name='power=11',yrange=[6,16],xrange=[3800,4800],color='blue',/current)
p2=plot(i6,temp6(260,80,2,0:2),ytitle='Temperature(eV)', title='Temperature varition with current',name='power=6',yrange=[6,16],xrange=[3800,4800],color='green',/current)
l=legend(target=[p,p1,p2],position=[0.90,0.90,0.95,0.95],/AUTO_TEXT_COLOR)
stop



;graphics
;xpixel=50+findgen(401)
power_h=[10.8,28.9,33.8,36.4,45]
power_h1=[10.8,20.0,28.8,36.3,45.0]
power_c=[10.8,20.0,28.8,36.3,45.0]


m=4
n=1
;window, 1, title='raw image'
;imgplot, data_arr(*,*,m,n),/cb
;window, 2, title='contrast'
;imgplot, contrast_arr(*,*,m,n),/cb,zr=[0,1]
;window, 3, title='intensity'
;imgplot, intensity_arr(*,*,m,n),/cb
;window ,4, title='phase'
;imgplot, phase_arr(*,*,m,n)-1,/cb,zr=[-0.5,0.5]
xpixel=findgen(401)+50
ypixel=findgen(610)*0.1+55
power=findgen(500)*0.07+10
d=reform(contrast_arr(260,55:115,3,*))
;g=image(rebin(d,610,500),ypixel,power,max_value=0.8, min_value=0.4,xtitle='Y pixel', ytitle='P_RF_Net(kw)',title='Contrast distribution of carbon 514nm line with 13 mm delay',axis_style=1, rgb_table=4,aspect_ratio=1.5)
;c=colorbar(target=g, orientation=1)
xpixel=findgen(3410)*0.1+50
ypixel=findgen(8100)*0.01+35
;g1=image(rebin(data_arr(*,*,3,3),5120,1280),xpixel, ypixel,rgb_table=5,axis_style=1,aspect_ratio=3, xtitle='Xpixel', ytitle='Ypixel', title='Raw data picture')
;g2=image(intensity_arr(*,*,3,3),rgb_table=4, xtitle='Xpixel', ytitle='Ypixel', title=' Intensity(brightness) distribution')
;g3=image(Contrast_arr(*,*,3,3),rgb_table=4, xtitle='Xpixel', ytitle='Ypixel', title=' Contrast distribution')
;d1=phase_arr(80:420,35:115,3,4)
;g4=image(rebin(d1,3410,8100)+0.2,xpixel, ypixel,axis_style=1,rgb_table=4, max_value=0.5,min_value=-0.5,xtitle='Xpixel', ytitle='Ypixel', title='Hbeta line phase distribution of RF power 45 kw',aspect_ratio=3.5)
;c=colorbar(target=g4, orientation=1)

intensity_h=intensity_arr
data_h=data_arr
;save, intensity_h,data_h,cal_intensity_2d,offset, filename='Intensity distribution of Hbeta line.save'
xp=findgen(3310)*0.1+50
yp=findgen(410)*0.1+55
cp=phase_arr(*,*,3,3)
cp1=cp(50:380,60:100)
cp2=phase_c(*,*,3,3)
cp3=cp2(50:380,60:100)
;g5=image(rebin(cp1,3310,410),xp,yp,axis_style=1,rgb_table=4,aspect_ratio=3.5,max_value=1,min_value=-1,title='Phase distribution of line 514 of measurement',xtitle='X Pixel',ytitle='Y Pixel',layout=[1,2,1])
;c5=colorbar(target=g5,orientation=1,/border)
;g6=image(rebin(cp3,3310,410)-1.2,xp,yp,axis_style=1,rgb_table=4,aspect_ratio=3.5,max_value=0.5,min_value=-0.5,title='Phase distribution of line 514 after phase correction',xtitle='X Pixel',ytitle='Y Pixel',layout=[1,2,2],/current)
;c6=colorbar(target=g6,orientation=1,/border)
contrast_658_25=contrast_arr
phase_658_25=phase_arr
data_658_25=data_arr
intensity_658_25=intensity_arr
temp_658_25=tem_arr
;save, contrast_658_25,phase__25,data_658_25, intensity_658_25,power,filename='658 nm with 25 mm delay 24_10_2013.save'
restore, 'contrast offset for 514 lines with 13 mm delay.save'

restore,'658 nm with 35 mm delay 29_10_2013.save'
restore, '486 nm with 5 mm delay 29_10_2013.save'
restore, '514 nm with 13 mm delay 29_10_2013.save'
power=[10.8,20.0,28.8,36.3,45.0]
power1=[3.08,8.06,11.27,17.56]
p=plot(power, -alog(contrast_514_13(265, 80, 3, *)/oc_514(265,80))*Tc_514, title ='Temperature variation with power',xtitle='P_RF_Net(kw)', ytitle='Temperature (eV)',yrange=[0,18],color='blue',name='514 nm lines with 13 mm delay',xrange=[0,40])
p1=plot(power, -alog(contrast_658_35(265, 80, 3, *)/oc_658(265,80))*Tc_c2, title ='Temperature variation with power',xtitle='P_RF_Net(kw)', ytitle='Temperature (eV)',yrange=[0,18], color='red',name='658 nm lines with 35 mm delay',xrange=[0,40],/current)
p2=plot(power, -alog(contrast_486_5(265, 80, 3, *))*Tc_h1, title ='Temperature variation with power',xtitle='P_RF_Net(kw)', ytitle='Temperature (eV)',yrange=[0,35],name='486 nm line with 5 mm delay',color='green',xrange=[0,40],/current)
p3=plot(power1, -alog(contrast_658_25(265, 80, 3, 0:3))*Tc_c1, title ='Temperature variation with power',xtitle='P_RF_Net(kw)', ytitle='Temperature (eV)',yrange=[0,35], name='658 nm line with 25 mm delay',color='orange',xrange=[0,40],/current)
l=legend(target=[p,p1,p2,p3],position=[0.90,0.90,0.95,0.95],/AUTO_TEXT_COLOR) 
stop
end