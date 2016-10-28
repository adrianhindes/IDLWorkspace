function rpda, sn,pn,bt,et

;the data refers to Romanna's data 
;sn means the scan number,
;pn means the position number 
;bt means the begining time point
;et meas the ending time point
s=strtrim(string(sn),1)  
p=strtrim(string(pn),1)  
restore,'y:\binary files\28_02_2014\'+s+'\cal2.sav'    ;channel 0 is the reference channel
sen=make_array(16,/float)
for i=0,15 do begin
  sen(i)=max(reform(c_data(*,i)))
  endfor
sen=sen/max(sen)

f=600.0e3
;bt=0.10
;et=0.13
sp=round(bt*f)
ep=round(et*f-1)
restore,'Y:\binary files\28_02_2014\'+s+'\'+p+'.sav' 
a=round(et*f-bt*f)
fsp=make_array(a,16,/dcomplex)
;pow=make_array(a,16,/float)
fsp(*,0)=fft(p_data(sp:ep,0))
fi=size(fsp,/DIMENSIONS)
freq=findgen(fi(0)/2.0)/(time(1)-time(0))/fi(0)
for j=1,15 do begin
  
  p_data(sp:ep,j)= p_data(sp:ep,j);/sen(j)
  
  fsp(*,j)=fft(p_data(sp:ep,j))
 
  ;pow(*,j)=abs(fsp(*,j))
  ;pow(*,j)= pow(*,j)/max( pow(*,j))
  endfor

pow=alog10(abs(fsp))
;pow=pow/max(pow)
pow=pow(1:fi(0)/2.0,*)
fsp=fsp(1:fi(0)/2.0,*)
;for k=0,15 do begin
  ;pow(*,k)=pow(*,k)/abs(min(pow(*,k)))+1
  ;endfor
 ;g=image(rebin(pow,1500,480),rebin(freq,1500)/1000.0,findgen(480)*16.0/480.0,axis_style=1,rgb_table=5,aspect_ratio=1,xrange=[0,50],xtitle='Frequency/kHz',ytitle='Channel NO.',min_value=-3.5,max_value=-1.3)
pf={data:p_data,powe:pow,fre:freq,fco:fsp,tim:time}  ;powe means the power spectrum of the data, freq means the corresoing frequency, fco means the complex fourier spectrum ,p_data means the original data
return, pf
end

pro rpd
;power spectrum analysis
d=rpda(5,10,0.2,0.23)
pow=d.powe
freq=d.fre
for k=0,15 do begin
  pow(*,k)=pow(*,k)/abs(min(pow(*,k)))+1
  endfor
  imgpos=[0.15,0.15,0.80,0.80]
  colorpos=[0.82,0.32,0.85,0.62]
 g=image(rebin(pow,1500,480),rebin(freq,1500)/1000.0,findgen(480)*16.0/480.0,axis_style=1,position=imgpos,rgb_table=4,aspect_ratio=1.5,font_size=16,xrange=[0,50],xtitle='Frequency(kHz)',ytitle='Channel NO.',yrange=[1,15],min_value=0.0,max_value=1.0)
 c=colorbar(target=g,orientation=1,position=colorpos,textpos=1,font_size=16,title='Intensity(arb)')
 rawdata=d.data
 t=d.tim
 rawdata=rawdata/max(rawdata)
 
 g1=image(rebin(rawdata,15000,480),rebin(t,15000), findgen(480)*16.0/480,axis_style=1,position=imgpos,xtitle='Time(s)',ytitle='Channel No.',rgb_table=4,aspect_ratio=0.01,yrange=[1,15],font_size=16)
 c1=colorbar(target=g1,orientation=1,position=colorpos,textpos=1,title='Intensity(arb)',font_size=16)
 stop
; wavelet analysis
; d=rpda(5,12,0.2,0.23)
;d1=d.data
;time=d.tim
;dt=time(1)-time(0)
;wave = WAVELET(d2,dt,PERIOD=period,COI=coi,/PAD,SIGNIF=signif,FFT_THEOR=FFT_THEOR)
;d2=d1(*,6)
;wave = WV_CWT(d2, 'Morlet', /pad,6, SCALE=scale)
;t=findgen(n_elements(reform(d2)))*(time(1)-time(0))
;wavePower = ABS(wave^2)
;wfreq=1.0/dt/scale
;wavepower=wavepower/max(wavepower)
;;wavepower=wavepower(*,0:55)
;;wfreq=reverse(wfreq)
;;wfreq=wfreq(0:55)
;d=rebin(alog10(wavepower),45,132)
;d=-d/min(d)
;n_levels=100
;levels=reverse(-findgen(n_levels)/(n_levels-1))
;ct_number=2
;ct_indices=BYTSCL(levels)
;LOADCT, ct_number, RGB_TABLE=ct, /SILENT
;step_ct = CONGRID(ct[ct_indices, *], 256, 3)
;c=contour(d,rebin(time,45), rebin(wfreq/1000.0,132),position=[0.1,0.1,0.85,0.85],xtitle='Time/s',ytitle='Frequency/kHz',xrange=[0,0.29],$,
;axis_style=1,RGB_table=step_ct,RGB_indices=ct_indices,c_value=levels,yrange=[5,50],zrange=[-1,0],/fill)  ;make self-defined colortable
;;tick_labels=strtrim(string(fix(findgen(5))*0.2),2)
;tick_labels=['0','0.2','0.4','0.6','0.8']
;c1=colorbar(orientation=1,position=[0.88,0.25,0.91,0.75],RGB_table=step_ct,major=5,ticklen=0.1,TICKNAME = tick_labels,textpos=1,title='Intensity (arb)')
;

;Phase analysis arcoss chamber axis
phase=make_array(17,16,/float)
intensity=make_array(17,16,/float)
mfre=make_array(17,/float)
for i=1,17 do begin
   d=rpda(5,i,0.2,0.23)
   fsp=d.fco
   freq=d.fre
   fsp(0:600,0)=0
   fsp(700:*,0)=0
   index=where(abs(fsp(*,0)) eq max(abs(fsp(*,0))))
   ;mfre(i-1)=mean([freq(index),freq(index-1),freq(index+1),freq(index-2),freq(index+2)])
   mfre(i-1)=mean(freq((index-20):(index+20)))
   
  for j=0,15 do begin
   fsp(0:600,j)=0
   fsp(800:*,j)=0
   rf=fft(fsp(*,0),/inverse)
   ffsp=fft(fsp(*,j),/inverse)
   phase(i-1,j)=mean(atan(ffsp/rf,/phase))
   intensity(i-1,j)=mean(abs(ffsp^2))
   endfor
   endfor
 pos=[0.1,0.1,0.75,0.85]
;r=(indgen(640)/639.0)*6.4-3.4  ;
r=(findgen(640)/639.0)*15+1 ;
z=(indgen(850)/849.0)*47.0+8
 ;g=image(reverse(rebin(phase, 850,640)),z,r,xtitle='Chamber Axis(cm)',ytitle='Radius(cm)',axis_style=1,rgb_table=4,max_value=2.0,min_value=-2,position=pos,aspect_ratio=4,yrange=[-3,3])  
 ;c=colorbar(target=g,orientation=1,textpos=1,position=[0.85,0.30,0.88,0.60],title='Phase(radians)');for 16 channel phase
 g=image(reverse(rebin(phase, 850,640)),z,r,xtitle='Chamber Axis(cm)',ytitle='Radius(cm)',axis_style=1,rgb_table=4,max_value=2.0,min_value=-2,position=pos,aspect_ratio=1.5)  ;for 15 channel+1 reference channel phase
 c=colorbar(target=g,orientation=1,textpos=1,position=[0.85,0.33,0.88,0.63],title='$\Delta$ $\phi$(Radians)')
 stop
 intensity=intensity/max(intensity)
 g=image(reverse(rebin(intensity, 850,640)),z,r,xtitle='Chamber Axis(cm)',ytitle='Radius(cm)',axis_style=1,rgb_table=2,max_value=0.8,min_value=0,yrange=[-3,3],position=pos,aspect_ratio=8)  
 c=colorbar(target=g,orientation=1,textpos=1,position=[0.85,0.25,0.88,0.75],title='Intensity(arb)')
;save, mfre,filename='Peak frequency of scan 4.save'
restore,'Peak frequency of scan 4.save'
p=plot((findgen(17)/16)*47.0+8,reverse(mfre/1000.0),axis_style=1,xtitle='Chamber Axis(cm)',ytitle='Peak frequency(kHz)',color='red',xrange=[8,55],yrange=[20,25],name='1.5mT and 400A')

restore,'Peak frequency of scan 5.save'
pp=plot((findgen(17)/16)*47.0+8,reverse(mfre/1000.0),axis_style=1,xtitle='Chamber Axis(cm)',ytitle='Peak frequency(kHz)',xrange=[8,55],yrange=[20,25])

p1=plot((findgen(17)/16)*47.0+8,reverse(mfre/1000.0),axis_style=1,xtitle='Chamber Axis(cm)',ytitle='Peak frequency(kHz)',color='blue',xrange=[8,55],yrange=[20,25],name='1.5mT and 600A',/overplot)
l=legend(target=[p,p1],position=[0.9,0.9,0.93,0.93])
restore,'flux profile for 400 A and 50 A.save'
flux=struct.flux
;pos1=[0.10,0.30,0.90,0.70]

c=contour(congrid(flux,850,640),z,r ,c_value=[0.5,5.0,15.0,25.0,45.0,90.0],c_linestyle=3,axis_style=1,/overplot,transparency=50)
a=axis('Y',Location=[55,0],COORD_TRANSFORM=[3.4*15/6.4+0.01,15/6.4],title='Channel No.',textpos=1,tickvalues=findgen(15)+1,/data)




 


 stop 
end