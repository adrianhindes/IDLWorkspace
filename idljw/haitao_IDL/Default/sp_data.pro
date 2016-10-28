pro sp_data
;carbon line 658 nm with 35 mm delay from experiments 29-10-2013
fil4=
fil5='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 29-10-2013\spectrometer\2013 October 29 17_10_01.spe'
fil6='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81541.spe'
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


c658=[fil4,fil5,fil6, fil7,fil8] ; carbon 658 lines with 35 mm delay
c514=[fil9,fil10,fil11, fil12,fil13] 
restore, 'sp data when i equals 3990.save' ;sp data when i_ring keep unchanged
restore, 'sp data when power equals 18.save'
sp_658=make_array(1024,10,11,5,/double)
lam658=make_array(1024,5,/float)
sp_514=make_array(1024,10,11,5,/double)
lam514=make_array(1024,5,/float)
l1=make_array(624,/float)
pix=[findgen(200),findgen(424)+600]
for i=0,4 do begin
read_spe, ps_18(i), lam, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
lam658(*,i)=lam
d1=reverse(d1,1)
for m=0,9 do begin
  for n=0,10 do begin
    ;offset=(mean(d1(0:200,m,n))+mean(d1(600:1023,m,n)))/2
    l1(0:200)=d1(0:200,m,n)
    l1(200:623)=d1(600:1023,m,n)
    l2=linfit(pix,l1)
    l3=l2(0)+l2(1)*findgen(1024)
     d1(*,m,n)=d1(*,m,n)-l3
    endfor 
    endfor
sp_658(*,*,*,i)=d1(*,*,0:10)

read_spe, c514(i), lam, t,d1,texp=texp,str=str,fac=fac & d1=float(d1)
d1=reverse(d1,1)
lam514(*,i)=lam
for m=0,9 do begin
  for n=0,10 do begin
     l1(0:400)=d1(0:400,m,n)
    l1(400:623)=d1(800:1023,m,n)
    l2=linfit(pix,l1)
    l3=l2(0)+l2(1)*findgen(1024)
     ;offset1=(mean(d1(800:1023,m,n))+mean(d1(0:400,m,n)))/2
    d1(*,m,n)=d1(*,m,n)-l3
    endfor 
    endfor
sp_514(*,*,*,i)=d1
endfor
sp_658=sp_658(*,*,3:7,*)
sp_514=sp_514(*,*,0:5,*)
sp_658=total(sp_658,3)
sp_514=total(sp_514,3)
lam658=mean(lam658,dimension=2)
lam514=mean(lam514,dimension=2)

fil19='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-11-2013\2013 November 08 11_48_27.spe' ;658nm spectrometer calibration 
fil20='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-11-2013\2013 November 08 11_52_30.spe' ;535nm spectrometer calibration
fil21='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 08-11-2013\2013 November 08 11_33_16.spe' ;white source
read_spe, fil19, lam2, t,d2,texp=texp,str=str,fac=fac & d2=float(d2)
read_spe, fil20, lam3, t,d3,texp=texp,str=str,fac=fac & d3=float(d3)
d2=total(d2,3)
d3=total(d3,3)
;line 514 spectrometer spatial shift correction
spx=make_array(10,/float)
for i=1,9 do begin
  p=reform(d3(*,i))
  p=p-mean(p(200:400))
  q=max(p,index)
  spx(i)=index
  endfor
spx(0)=spx(1)
spx=spx-spx(0)
;spx=make_array(10,/float)
;spx1=make_array(10,/float)
rha=make_array(10,5,/float)
for m=0,9 do begin
for k=0,4 do begin
st=k
for j=0,9 do begin
a1=total(sp_514(420+spx(j):420+spx(j)+50,*,st),1);ratio for first carbon 514 line
a2=total(sp_514(470+spx(j):470+spx(j)+120,*,st),1) ;ratio for middle carbon 514 lines
a3=total(sp_514(590+spx(j):590+spx(j)+50,*,st),1) ;ratio for last carbon 514 line
endfor
;line 658 spectrometer spatial shift calibration
spx1=make_array(10,/float)
for i=1,9 do begin
  p=reform(d2(*,i))
  p=p-mean(p(0:200))
  q=max(p,index)
  spx1(i)=index
  endfor
  spx1(0)=spx1(1)
spx1=spx1-spx1(0)
for j=0,9 do begin
b1=total(sp_658(200+spx1(j):200+spx1(j)+150,*,st),1) ;ratio for H alpha line
b2=total(sp_658(450+spx1(j):450+spx1(j)+70,*,st),1) ;ratio for first carbon 658 line 
b3=total(sp_658(520+spx1(j):520+spx1(j)+70,*,st),1)  ;ratio for second carbon 658 line
endfor


channel=findgen(10)+1
;p=plot(channel,a1/(a1+a2+a3),xtitle='Channel No.',ytitle='Relative ratio',title='514 lines relative intensity ratio',yrange=[0,1],color='red',name='First line')
;p1=plot(channel,a2/(a1+a2+a3),xtitle='Channel No.',ytitle='Relative ratio',title='514 lines relative intensity ratio',yrange=[0,1],color='blue',name='Middle lines',/current)
;p2=plot(channel,a3/(a1+a2+a3),xtitle='Channel No.',ytitle='Relative ratio',title='514 lines relative intensity ratio',yrange=[0,1],color='green',name='Last line',/current)
;l=legend(target=[p,p1,p2],position=[0.90,0.85,0.95,0.9],/AUTO_TEXT_COLOR) 
rha(*,k)=b1/(b1+b2+b3)
;p=plot(channel,b2/(b1+b2+b3),xtitle='Channel No.',ytitle='Relative ratio',title='658 lines relative intensity ratio of power ',yrange=[0,1],color='red',name='657.805 nm')
;p1=plot(channel,b3/(b1+b2+b3),xtitle='Channel No.',ytitle='Relative ratio',title='658 lines relative intensity ratio',yrange=[0,1],color='blue',name='658.288 nm',/current)
;p2=plot(channel,b1/(b1+b2+b3),xtitle='Channel No.',ytitle='Relative ratio',title='658 lines relative intensity ratio',yrange=[0,1],color='green',name='656.279 nm',/current)
;l=legend(target=[p,p1,p2],position=[0.90,0.85,0.95,0.9],/AUTO_TEXT_COLOR) 


endfor
endfor
p3=plot(i18, rha(2,*), xtitle='i_ring(A)',ytitle='H alpha ratio',title='H alpha ratio vatiation with i when power equals 18')


p3=plot(channel,b2/(b2+b3),xtitle='Channel No.',ytitle='Relative intensity',title='Relative intensity of two carbon lines',yrange=[0,1],color='red',name='line 657.805 nm')
p4=plot(channel,b3/(b2+b3),xtitle='Channel No.',ytitle='Relative intensity',title='Relative intensity of two carbon lines',color='blue',yrange=[0,1],name='line 658.288 nm',/current)
l=legend(target=[p3,p4],position=[0.90,0.85,0.95,0.9],/AUTO_TEXT_COLOR)
stop
;t=total(reform(sp_658(*,*,st)),1)
;p5=plot(channel, t/max(t), title='Relative total intensity of different channels',xtitle='Channel NO.',yrange=[0,1],ytitle='Relative intensity')

;p2.save, '658 lines relative intensity ratio.png', resolution=100
;p4.save, 'Relative intensity of two carbon lines.png',resolution=100
;p5.save, 'Relative total intensity of different channels.png', resolution=100


p6=plot(lam514, sp_658(*,0,2), xtitle='Wavelengh/nm',ytitle='Intensity', layout=[3,2,1])
for i =0, 5 do begin
p5=plot(lam514, sp_658(*,i,2), xtitle='Wavelengh/nm',ytitle='Intensity', layout=[3,2,i+1],/current)
  endfor 
;p1=plot(lam658, sp_658(*,9,2), xtitle='Wavelengh/nm',ytitle='Intensity', yrange=[0,1*5000])

stop
end