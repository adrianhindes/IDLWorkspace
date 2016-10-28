pro read_carbonlines

file1='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\carbon lines\2013 August 08 13_25_58.spe'
read_spe, file1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d) 
d_465=d
lam_465=lam
pix=1024
low_wavelength1=458
high_wavelength1=471
pix_trans1=findgen(pix)*(high_wavelength1-low_wavelength1)/(pix-1)+low_wavelength1
data1=mean(d_465,dimension=3)
p1=plot(pix_trans1, data1/max(data1),xrange=[458,471],color='blue',title='Profile of line 465 nm',xtitle='Wavelength (nm)', ytitle='Relative intensity')


file2='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\carbon lines\2013 August 08 13_28_41.spe'
read_spe, file2, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d_514=d
lam_514=lam
low_wavelength2=508
high_wavelength2=519
pix_trans2=findgen(pix)*(high_wavelength2-low_wavelength2)/(pix-1)+low_wavelength2
data2=mean(d_514,dimension=3)
;p2=plot(pix_trans2, data2/max(data2),xrange=[508,519],title='Profile of line 514 nm',xtitle='Wavelength (nm)', ytitle='Relative intensity')


file3='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\carbon lines\2013 August 08 13_29_21.spe'
read_spe, file3, lam, t,d,texp=texp,str=str,fac=fac & d=float(d) 
lam2=lam
d_658=d
pix=1024
low_wavelength3=654
high_wavelength3=662
pix_trans3=findgen(pix)*(high_wavelength3-low_wavelength3)/(pix-1)+low_wavelength3
data3=mean(d_658,dimension=3)
data3=data3/max(data3)
cal_lam=lam2-0.36
;p3=plot(cal_lam, data3,title='Profile of line Carbon lines',xrange=[654,662],xtitle='Wavelength (nm)',color='blue' ,ytitle='Relative intensity',name='Carbon lines')
data4=data3[0:350]
ind=max(data4,index)
ha=cal_lam(index)
ha_I=data3(index)
data5=data3[0:550]
ind1=max(data5,index)
carbon1=cal_lam(index)
carbon1_I=data3(index)
data6=data3[550:*]
ind2=max(data6,index)
carbon2=cal_lam(index+550)
carbon2_I=data3(index+550)
lam_arr=[ha, carbon1, carbon2]
R_I=[ha_I,carbon1_I, carbon2_I]

;658 nm filter
filter_658='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\658 filter.spe'
read_spe, filter_658, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d=d/max(d)
lam1=lam
lam_index=where((lam1 gt 654 )and(lam1 lt 662))
lam1=lam1(lam_index)
d=d(lam_index)
trans_arr=interpol(d,lam1,lam_arr,/QUADRATIC)
;p4=plot(lam1, d,name='filter profile',color='red',/current)
;l=legend(target=[p3,p4],position=[0.90,0.88,0.95,0.93])
Ratio1=R_I*trans_arr
Ratio=ratio1/total(ratio1)
save, lam_arr, ratio, filename='spectrometer data.save'

; 514 nm filter
filter_514='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\514 filter.spe'
read_spe, filter_514, lam, t,d5,texp=texp,str=str,fac=fac&d5=float(d5)
d5=d5/max(d5)
lam5=lam
fil_514_ind=where((lam5 lt 520)  and (lam5 gt 508) )
d_filter_514=d5(fil_514_ind)
lam_filter_514=lam5(fil_514_ind)


;carbon line 658 nm with 35 mm delay from experiments 29-10-2013
fil4='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_07_10.spe'
fil5='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_10_01.spe'
fil6='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_13_03.spe'
fil7='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_15_39.spe'
fil8='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_16_24.spe'
;carbon line 514 nm with 13 mm delay from experiments 29-10-2013
fil9='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 14_48_44.spe'
fil10='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 14_55_27.spe'
fil11='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 14_59_52.spe'
fil12='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_01_23.spe'
fil13='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_02_32.spe'
; Hbeat line with 5 mm delay from experiments 29-10-2013
fil14='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_30_18.spe'
fil15='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_57_40.spe'
fil16='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 15_58_41.spe'
fil17='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 16_01_04.spe'
fil18='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 16_02_24.spe'




;carbon 658 line and H alpha contamination
fil_658line=[fil4,fil5,fil6, fil7,fil8]
spectrum_658=make_array(1024,10,11,5,/float)
for i=0,4 do begin
read_spe, fil_658line(i), lam, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
spectrum_658(*,*,*,i)=d1
endfor


;spatial spectrum distritution
;for t=0, 9 do begin
;d9=reverse(spectrum_658(*,t,3,4))
;t=string(t)
;p10=plot(lam,d9/max(d9),title=strtrim('Carbon line 658 profile of channel')+' '+strtrim(t,1)+' '+strtrim('of power 47 kw',1),color='blue',xrange=[654,662],yrange=[0,1],xtitle='wavelength/nm', ytitle='Normalized intensity',name='Carbon line')
;p11=plot(lam1, d,xrange=[654,662],yrange=[0,1],color='red',name='filter profile',/current)
;l=legend(target=[p10,p11],position=[0.90,0.88,0.95,0.93])
;p11.save, strtrim('Carbon line 658 profile of channel')+' '+strtrim(t,1)+' '+strtrim('of power 47 kw.png',1)
;t=uint(t)
;endfor

;Hafa contanimaton with power increasing
r_haf=make_array(5,/float)
for i=0,4 do begin
d2=spectrum_658(*,1,3,i)
;p5=plot(lam,reverse(d2/max(d2)), color='blue',title='Carbon line profile of power 46.8 kw ',xtitle='wavelength/nm',ytitle='Normalized intensity',name='carbon lines')
;p6=plot(lam1, d, xrange=[654,662],color='red',name='Filter profile',/current)
;l=legend(target=[p5,p6],position=[0.90,0.88,0.95,0.93])
d2=reverse(d2)/max(d2)
d3=d2(0:400)
d_haf=where(d3 eq max(d3))
haf_trans=interpol(d,lam1,lam(d_haf),/quadratic)
d4=d2(400:520)
d_c1=where(d4 eq max(d4))
c1_trans=interpol(d,lam1,lam(d_c1+400),/quadratic)
d5=d2(520:620)
d_c2=where(d5 eq max(d5))
c2_trans=interpol(d,lam1,lam(d_c2+520),/quadratic)
r_haf(i)=d3(d_haf)*haf_trans/(d4(d_c1)*c1_trans+d5(d_c2)*c2_trans)
endfor
power=[7.8, 16.7,26.4,37.1,46.8]
;p=plot(power,r_haf,title='Halfa line raiton variation with RF power',xtitle='P_RF_Net(kw)',ytitle='Halfa line/Carbnon line Intensity Raito')


;carbon 514 line spectrum variation with power
;spectrum_514=make_array(1024,10,11,5,/float)
;fil_514line=[fil9,fil10,fil11,fil12,fil13]
;for j=0,4 do begin
  ;read_spe, fil_514line(j), lam2, t,d5,texp=texp,str=str,fac=fac & d5=float(d5)
;spectrum_514(*,*,*,j)=d5 
;endfor
;for m=0, 9 do begin
;d6=reverse(spectrum_514(*,m,3,4))
;m=string(m)
;p7=plot(lam2,d6/max(d6),title=strtrim('Carbon line 514 profile of channel')+' '+strtrim(m,1)+' '+strtrim('of power 46 kw',1),color='blue',xrange=[508,520],yrange=[0,1],xtitle='wavelength/nm', ytitle='Normalized intensity',name='Carbon line')
;p8=plot(lam_filter_514, d_filter_514,xrange=[508,520],yrange=[0,1],color='red',name='filter profile',/current)
;l=legend(target=[p7,p8],position=[0.90,0.88,0.95,0.93])
;p8.save, strtrim('Carbon line 514 profile of channel')+' '+strtrim(m,1)+' '+strtrim('of power 46 kw.png',1)
;m=uint(m)
;endfor


;Hbeta line spectrum variation with power
spectrum_486=make_array(1024,10,11,5,/float)
fil_486line=[fil14,fil15,fil16,fil17,fil18]
for k=0,4 do begin
  read_spe, fil_486line(k), lam3, t,d7,texp=texp,str=str,fac=fac & d7=float(d7)
spectrum_486(*,*,*,k)=d7 
endfor
;for n=0, 9 do begin
;d8=reverse(spectrum_486(*,n,3,4))
;m=string(n)
;p9=plot(lam3,d8/max(d8),title=strtrim('Hbeta line profile of channel')+' '+strtrim(n,1)+' '+strtrim('of power 46 kw',1),color='blue',xrange=[480,492],yrange=[0,1],xtitle='wavelength/nm', ytitle='Normalized intensity',name='Carbon line')
;p8=plot(lam_filter_514, d_filter_514,xrange=[508,520],yrange=[0,1],color='red',name='filter profile',/current)
;l=legend(target=[p7,p8],position=[0.90,0.88,0.95,0.93])
;p9.save, strtrim('Hbeta line profile of channel')+' '+strtrim(n,1)+' '+strtrim('of power 46 kw.png',1)
;m=uint(n)
;endfor

fil19='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\md_81125.SPE'
read_spe, fil19, lam7, t,d11,texp=texp,str=str,fac=fac&d11=float(d11)

xpixel=findgen(512)
ypixel=findgen(128)
channel=findgen(10)
;channel position compared with camera data
restore , 'Intensity distribution of Hbeta line.save'
xc=reform(cal_intensity_2d(260,*))
xc=xc/max(xc)
x1=intensity_h(260,*,1,2)-d11(260,*,1)
x1=x1/max(x1)
p10=plot(ypixel, x1,color='blue', name='camera data',title='Plasma data', xrange=[0,127],yrange=[0,1],xtitle='Y pixel',ytitle='Normalized intensity',layout=[2,2,1])
s=make_array(10,/float)
mv=make_array(10,/float)
for i=0,9 do begin
  mv(i)=mean(reform(spectrum_486(200:400,i,1,2)))
  q=mv(i)
  s(i)=total(reform(spectrum_486(*,i,1,2))-q)
  endfor
p11=plot(channel,s/max(s), xtitle='Channel No.',ytitle='Normalized intensity',yrange=[0,1],axis_style=1,symbol='o',color='red',title='spectrometer data',SYM_FILL_COLOR='red',layout=[2,2,2],/current)
;l=legend(target=[p10,p11],position=[0.90,0.88,0.95,0.93])


;flow infromation extracted from spectrometer data
x2=make_array(10,/float)
for j=0,9 do begin
  spectrum_486(*,j,1,2)=reverse(spectrum_486(*,j,1,2))
  m=max(reform(spectrum_486(*,j,1,2)),index)
  x2(j)=lam3(index)
  ;x2(j)=interpol(lam3,spectrum_486(*,j,1,2),m,/quadratic)
  endfor
;p12=plot(channel, x2, xtitle='Channel No',ytitle='Peak wavelegth', title='Peak wavelenth shifts with channel of Hbeta(486.133) line', symbol='o')

;intrisic shifts of spectrometer
x3=make_array(10,/float)
x4=make_array(10,/float)
fil19='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-11-2013\2013 November 08 11_48_27.spe' ;658nm
fil20='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-11-2013\2013 November 08 11_52_30.spe' ;535nm
fil21='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-11-2013\2013 November 08 11_33_16.spe' ;white source
read_spe, fil19, lam4, t,d8,texp=texp,str=str,fac=fac & d8=float(d8)
read_spe, fil20, lam5, t,d9,texp=texp,str=str,fac=fac & d9=float(d9)
read_spe, fil21, lam6, t,d10,texp=texp,str=str,fac=fac & d10=float(d10)
for m=0,9 do begin
  d8(*,m,1)=reverse(d8(*,m,1))
  n=max(reform(d8(*,m,1)),index)
  x3(m)=lam4(index)
  x4(m)=total(d10(*,m,1)-mean(reform(d10(200:400,m,1))))
  endfor
;p13=plot(channel,x3,xtitle='Channel No',ytitle='Peak wavelegth', title='Peak wavelenth shifts with channel of 660nm(cold) line', symbol='o')
u=s/max(s)*max(x4)/x4
u=u/max(u)
p13=plot(channel,x4/max(x4), xtitle='Channel No.', ytitle='Normalized intensity',axis_style=1,symbol='o',color='green',title='White lingth data',SYM_FILL_COLOR='red',layout=[2,2,3],/current)
p14=plot(channel(1:*),u(1:*), xtitle='Channel No.', ytitle='Normalized intensity',axis_style=1,symbol='o',color='green',title='Corrected spectrometer data',SYM_FILL_COLOR='red',layout=[2,2,4],/current)
;l=legend(target=[p10,p11],position=[0.90,0.88,0.95,0.93])

stop


end