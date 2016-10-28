pro gaussian_convolution


pixel=1024
expt=3.5
low_wave=480
high_wave=492
;Greg's method
back_fil='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\7_24_2013 greg data\background\Heroic_100Frames_3p5ms\2013 July 26 12_56_54.spe'
read_spe, back_fil, lam, t,d,texp=texp,str=str,fac=fac
avg_back=make_array(pixel)
back_array=make_array(pixel,100)
 for i=0,99 do begin
  back_array(*,i)=float(d(*,*,i))
 endfor
 for j=0,pixel-1 do begin
avg_back(j)=mean(back_array(j,*))
endfor

cal_fil='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\7_24_2013 greg data\hydrogenLampHBeta\Heroic_100Frames_3p5ms\2013 July 26 12_54_30.spe'
read_spe, cal_fil, lam, t,d,texp=texp,str=str,fac=fac
cal_array=make_array(pixel,100)
avg_cal=make_array(pixel)
for i=0,99 do begin
  cal_array(*,i)=float(d(*,*,i))
  endfor
for j=1,pixel-1 do begin
  avg_cal(j)=mean(cal_array(j,*))
 endfor
 calibration=avg_cal-avg_back
 calibration[0:480]=0
 calibration[600:-1]=0
 ins_function=calibration
 pix_trans=low_wave+findgen(pixel)*(high_wave-low_wave)/(pixel-1)
 ;p=plot(pix_trans,calibration)

data_fil='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\7_24_2013 greg data\data\2013 July 24 15_34_07.spe'
read_spe, data_fil, lam, t,d,texp=texp,str=str,fac=fac
background=d(*,*,0)
data_arr=make_array(pixel,9)
avg_data=make_array(pixel)
for i=1,9 do begin
data_arr(*,i-1)=d(*,*,i)
endfor
for j=0,pixel-1 do begin
  avg_data(j)=mean(data_arr(j,*))
endfor
data=avg_data-background
data[0:480]=0
data[600:-1]=0
;p1=plot(pix_trans,data)
A=[5500,3,486.1,0]
X=pix_trans[480:600]
Y=data[480:600]
weights=1.0
;gfunct,x,a,tmp

;yfit=CURVEFIT(X, Y, weights, A, FUNCTION_NAME='gfunct')
;plot,yfit

;Clive's method

cal_data=avg_cal-avg_back
filter=where(pix_trans ge 485.0 and pix_trans le 487)
ifunc=cal_data
ifunc=ifunc-min(ifunc)
common cbgfunc3, ifunctmp
ifunctmp=ifunc
coff=[700,486.1,0.05,100]

;gfunc2,pix_trans(cal_fil),coff ,model
;compu_signal=convol(model,ifunc/total(ifunc))



pdata=avg_data-background
pdata=pdata-min(pdata)
;data_fil=where(pix_trans ge 486.25 and pix_trans le 486.75)
weights=pix_trans ge 485.6 and pix_trans le 487
curved_signal=curvefit(pix_trans,pdata,weights,coff, function_name='gfunc3',/noderivative,fita=fita)
;data_fft=fft(pdata(cal_fil))
;fun_fft=fft(ifunc)
;real_signal=data_fft/fun_fft

gfunc2,pix_trans,coff,real_signal
computed_signal=convol(real_signal, ifunc)


pict=plot(pix_trans,computed_signal/max(computed_signal),xrange=486+[-1,1],color='red',xtitle='wavelength(nm)',ytitle='normalized intensity',title=' signal comparision after shifting 0.55 nm',name='computed signal')
pict1=plot(pix_trans,pdata/max(pdata),xrange=486+[-1,1],color='blue',xtitle='wavelength(nm)',ytitle='normalized intensity',name='plasma signal',/current)
c=legend(target=[pict,pict1])







stop
end




