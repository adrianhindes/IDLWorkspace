pro sta

;fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 07-02-2014\4 carieers one.SPE'

fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-02-2014\sta49.tif'
;read_spe, fil1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
dnf=read_tiff(fil1,image_index=1)

;dnf=d
;fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 07-02-2014\calibration 3 07-2-2014.SPE'
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-02-2014\cal25.tif'
;read_spe, fil2, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
bnf=read_tiff(fil2)




;bnf=d
;dd=dnf-bnf
;dd1=abs(fft(dd,/center))
;p=image(dd1,max_value=50,min_value=0,rgb_table=4,title='Four carriers system fourier plane' ,xtitle='X pixel',ytitle='Y pixel',layout=[1,2,1],aspect_ratio=0.4)    ;four carriers system with 25mm and 15 mm linbo3
;p1=image(alog(dd1),rgb_table=4,title='Four carriers system fourier plane in alog scale' ,xtitle='X pixel',ytitle='Y pixel',layout=[1,2,2],/current,aspect_ratio=0.4)
han=hanning(400,400)
con=make_array(400,400,400,/float)
coh=make_array(400,400,400,/dcomplex)
pha=make_array(400,400,400,/float)
data=make_array(400,400,400,/float)
for i=0,399 do begin
  dnf1=read_tiff(fil1,image_index=i)-bnf
  data(*,*,i)=dnf1(200:599, 200:599)
  endfor
 ;john 's method
  for i=0,399 do begin
  dnf1=read_tiff(fil1,image_index=i)-bnf
  data(*,*,i)=dnf1(200:599, 200:599)
  endfor

 ;john's method
 ;phase=make_array(100,400,/float)
 ;phase1=make_array(100,400,/float)
 ;for i=0,399 do begin
  ;d1=reform(total(data(200:299, 10:20,i),2))
  ;d11=reform(total(data(200:299, 30:40,i),2))
  ;d2=fft(d1)
  ;d21=fft(d11)
 ; d2(0:5)=0&d2(7:*)=0
 ; d21(0:5)=0&d21(7:*)=0
 
 ; d3=fft(d2,/inverse)
 ; d31=fft(d21,/inverse)
 ; d4=atan(d3,/phase)
  ;d41=atan(d31,/phase)
  ;phase(*,i)=d4
  ;phase1(*,i)=d41
  ;endfor
  
for j=0,399 do begin
  df=fft(data(*,*,j)*han,/center)
  dfd=df
;df(findgen(150),*)=0.
; df(findgen(400-170)+170,*)=0.
; dfd(findgen(190),*)=0
; dfd(findgen(400-210)+210,*)=0.
  df(findgen(170),*)=0. ; suitable for 3.0 mm Linbo3
  df(findgen(400-190)+190,*)=0.
  dfd(findgen(190),*)=0
  dfd(findgen(400-210)+210,*)=0.
  c=fft(df,/inverse,/center)
  dc=fft(dfd,/inverse,/center)
  con(*,*,j)=2*abs(c)/abs(dc)
  coh(*,*,j)=c
  endfor
  
  for t=0,399 do begin
    pha(*,*,t)=atan(coh(*,*,t),/phase)
    endfor

tt=read_csv('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-02-2014\temp49.csv')
for i=0,1028 do begin
 d=tt.field1
if (d(i) lt 10) then tt.field1(i)=tt.field1(i)+12.0 ;for time duration from morning to afternoon
endfor
time=tt.field1*3600+tt.field2*60+tt.field3
time=time-time(0)
temp=tt.field5
phase=pha(200,200,*)

phase=reform(phase)
;phase(163:*)=phase(163:*)+!pi*2.0 ;fot shot50,3mm Linbo3,temp from 31.1 to 34.39 to 38.27
;phase(310:*)=phase(310:*)+!pi*2.0
phase(274:*)=phase(274:*)+!pi*2.0 ; for shot 49 20mm BBO 
phase=phase-phase(0)
plot, time(0:200)/60.0,smooth(phase(0:200),20,/edge_mirror)
p=plot(time(190:390)/60.0-time(190)/60.0,smooth(phase(190:390),20,/edge_mirror)-phase(190),xtitle='Time(min)',ytitle='$\Delta$ $\phi$(Radians)');\\'for thesis
stop
;phase(148:-1)=phase(148:-1)-2*!pi
;phase(276:-1)=phase(276:-1)-2*!pi
;phase(288:-1)=phase(288:-1)-2*!pi
;phase=reform(mean(phase,dimension=1))
;phase=reform(mean(phase,dimension=1))
phase1=pha(101,101,*)
;phase1=reform(mean(phase1,dimension=1))
;phase1=reform(mean(phase1,dimension=1))
;phase1(138:-1)=phase1(138:-1)-2*!pi
;phase1(156:-1)=phase1(156:-1)-2*!pi
;phase1(279:-1)=phase1(279:-1)-2*!pi
;phase1(294:-1)=phase1(294:-1)-2*!pi
phase2=pha(299,299,*)
;phase2(226:*)=phase2(226:*)-2*!pi
;phase2=reform(mean(phase2,dimension=1))
;phase2=reform(mean(phase2,dimension=1))
;phase2(142:-1)=phase2(142:-1)-2*!pi
;phase2(170:-1)=phase2(170:-1)-2*!pi
;phase2(283:-1)=phase2(283:-1)-2*!pi
;phase2(304:-1)=phase2(304:-1)-2*!pi
contrast=con(200:201,200:201,*)
contrast=reform(mean(contrast,dimension=1))
contrast=reform(mean(contrast,dimension=1))
contrast1=con(100:101,100:101,*)
contrast1=reform(mean(contrast1,dimension=1))
contrast1=reform(mean(contrast1,dimension=1))
contrast2=con(300:301,300:301,*)
contrast2=reform(mean(contrast2,dimension=1))
contrast2=reform(mean(contrast2,dimension=1))

phase=reform(phase)
phase1=reform(phase1)
phase2=reform(phase2)
;p=plot(findgen(400)*12.5, smooth(contrast(0:399),40,/EDGE_MIRROR),title='Contrast variation with time',xtitle='Time/s',ytitle='Contrast',layout=[1,3,1],yrange=[0.35,0.55],name='Center point')  
;p0=plot(findgen(400)*12.5, smooth(contrast1(0:399),40,/EDGE_MIRROR),title='Contrast variation with time',xtitle='Time/s',ytitle='Contrast',color='red',layout=[1,3,1],yrange=[0.35,0.55],name='Left point ',/current)  
;p00=plot(findgen(400)*12.5, smooth(contrast2(0:399),40,/EDGE_MIRROR),title='Contrast variation with time',xtitle='Time/s',ytitle='Contrast',color='blue',layout=[1,3,1],yrange=[0.35,0.55],name='Right point',/current)  
;l=legend(target=[p,p0,p00])
p1=plot(findgen(400)*12.5,smooth((phase(0:399)-phase(0))*180.0/!pi,40,/EDGE_MIRROR),title='Phase variation with time',xtitle='Time/s',ytitle='Phase shift(degree)',yrange=[-10,80],layout=[1,3,2],name='Center point',/current)
;p11=plot(findgen(400)*12.5,smooth((phase1(0:399)-phase1(0))*180.0/!pi,40,/EDGE_MIRROR),title='Phase variation with time',xtitle='Time/s',ytitle='Phase shift(degree)',layout=[1,3,2],yrange=[-10,80],name='Left point',color='red',/current)
;p12=plot(findgen(400)*12.5,smooth((phase2(0:399)-phase2(0))*180.0/!pi,40,/EDGE_MIRROR),title='Phase variation with time',xtitle='Time/s',ytitle='Phase shift(degree)',layout=[1,3,2],yrange=[-10,80],color='blue',name='Right point',/current)
;l=legend(target=[p1,p11,p12])
;time1=findgen(536)*10.0

;temp1=replicate(temp(0),120)
;temp1=[temp1,temp]
;temp1=temp(0:120)
;temp2=temp(180:459)
;temp=[temp1,temp2]
p2=plot(time(0:400)*1.25, temp(0:400), title='Temp variation with time',xtitle='Time/s',ytitle='Temperature(degree)',yrange=[32,45],xrange=[0,5000],layout=[1,3,3],/current)

 stop
  end
  
