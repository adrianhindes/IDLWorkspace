pro modeling
xpixel=findgen(5120)*0.1
ypixel=findgen(1280)*0.1

;modeling 658 ignoring the filter effect
cw=[656.279,657.805,658.288,658.0]
restore,'Relative ratio of carbon 658 lines.save'  ;the ratio here does not include filter transmission effects
ew=hr(2)*cw(0)+c1r(2)*cw(1)+c2r(2)*cw(1)
ew1=c1r(2)/(c1r(2)+c2r(2))*cw(1)+c2r(2)/(c1r(2)+c2r(2))*cw(2)
l=20.0
l1=15.0
p=waveplatel(656.279,l,!pi/4)+waveplatel(656.279,l1,!pi/4)+displacer(656.279,1.0,!pi/4)-displacer(656.279,1.0,3*!pi/4)+displacer(656.279,1.25,!pi/4)-displacer(656.279,1.25,3*!pi/4)
p1=waveplatel(657.805,l,!pi/4)+waveplatel(657.805,l1,!pi/4)+displacer(657.805,1.0,!pi/4)-displacer(657.805,1.0,3*!pi/4)+displacer(657.805,1.25,!pi/4)-displacer(657.805,1.25,3*!pi/4)
p2=waveplatel(658.288,l,!pi/4)+waveplatel(658.288,l1,!pi/4)+displacer(658.288,1.0,!pi/4)-displacer(658.288,1.0,3*!pi/4)+displacer(658.288,1.25,!pi/4)-displacer(658.288,1.25,3*!pi/4)
p3=waveplatel(ew1,l,!pi/4)+waveplatel(ew1,l1,!pi/4)+displacer(ew1,1.0,!pi/4)-displacer(ew1,1.0,3*!pi/4)+displacer(ew1,1.25,!pi/4)-displacer(ew1,1.25,3*!pi/4)
p4=waveplatel(ew,l,!pi/4)+waveplatel(ew,l1,!pi/4)+displacer(ew,1.0,!pi/4)-displacer(ew,1.0,3*!pi/4)+displacer(ew,1.25,!pi/4)-displacer(ew,1.25,3*!pi/4)
p8=waveplatel(659.895,l,!pi/4)+waveplatel(659.895,l1,!pi/4)+displacer(659.895,1.0,!pi/4)-displacer(659.895,1.0,3*!pi/4)+displacer(659.895,1.25,!pi/4)-displacer(659.895,1.25,3*!pi/4)

;p5=dcomplex(hr(1)*cos(p)+c1r(1)*cos(p1)+c2r(1)*cos(p2),hr(1)*sin(p)+c1r(1)*sin(p1)+c2r(1)*sin(p2))
I1=800.0/(800+570)
I2=570.0/(800+570) ;ratio data from nist database

p5=dcomplex(I1*cos(p1)+I2*cos(p2),I1*sin(p1)+I2*sin(p2)); two carbon lines
rc1=0.02
r1=(1-rc1)*I1
r2=(1-rc1)*I2
pp1=dcomplex(rc1*cos(p)+r1*cos(p1)+r2*cos(p2),rc1*sin(p)+r1*sin(p1)+r2*sin(p2)) ;evaluation of hbeta contamination
d1=atan(pp1/p5,/phase)*180.0/!pi
stop
;p5_1=dcomplex(hr(3)*cos(p)+c1r(3)*cos(p1)+c2r(3)*cos(p2),hr(3)*sin(p)+c1r(3)*sin(p1)+c2r(3)*sin(p2))
;p5_2=dcomplex(hr(6)*cos(p)+c1r(6)*cos(p1)+c2r(6)*cos(p2),hr(6)*sin(p)+c1r(6)*sin(p1)+c2r(6)*sin(p2))
;p5_3=dcomplex(hr(9)*cos(p)+c1r(9)*cos(p1)+c2r(9)*cos(p2),hr(9)*sin(p)+c1r(9)*sin(p1)+c2r(9)*sin(p2))

;verification usging john's formula
r=findgen(21)*0.01-0.1
prd=make_array(512,128,21,/float)
for i=0,20 do begin
rc=r(i); ratio change
pp=dcomplex((I1+rc)*cos(p1)+(I2-rc)*cos(p2),(I1+rc)*sin(p1)+(I2-rc)*sin(p2)); two carbon lines
s1=atan(pp/p5,/phase)*180.0/!pi
prd(*,*,i)=s1
endfor
stop
ph1=dcomplex(cos(p1),sin(p1))
ph2=dcomplex(cos(p2),sin(p2))
del=(atan(ph1,/phase)-atan(ph2,/phase))/2 ;phase difference divided by 2
;del=(p1-p2)/2
pha=(p1+p2)/2
;pha=(atan(ph1,/phase)+atan(ph2,/phase))/2
;jumpimg, del
;jumpimg, pha
ph_1=atan((I1-I2)/(I1+I2)*tan(del),/phase)+pha;-2.7660*1e4 ;phase
cont=cos(del)/cos(atan((I1-I2)/(I1+I2)*tan(del),/phase))

I3=I1+rc
I4=I2-rc
ph3=dcomplex(cos(p1),sin(p1))
ph4=dcomplex(cos(p2),sin(p2))
del1=(atan(ph1,/phase)-atan(ph2,/phase))/2 ;phase difference divided by 2
;del=(p1-p2)/2
pha1=(p1+p2)/2
ph_2=atan((I3-I4)/(I3+I4)*tan(del1),/phase)+pha1 ;phase, careful offset deduction needed when doing compensation
ph=(ph_1-ph_2)*180/!pi

stop
;pp1=plot(rc, s1(125,63,*),xtitle='Relative ratio change', ytitle='Phase shift (degree)',title='Phase shift caused by relative ratio change')
;s2=atan(p5_2/p5,/phase)*180.0/!pi
;s3=atan(p5_3/p5,/phase)*180.0/!pi
;g=image(rebin(atan(p5,/phase)*180.0/!pi,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase of channel 1 of triple lines',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c=colorbar(target=g, orientation=1,title='Phase shift (degree)')
g1=image(rebin(s1,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling carbon line 658 phase shift of ratio changing by 0.1 ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c1=colorbar(target=g1, orientation=1,title='Phase shift (degree)')
g2=image(rebin(ph,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Calculation carbon line 658 phase shift of ratio changing by 0.1',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c2=colorbar(target=g2, orientation=1,title='Phase shift (degree)')
r=abs(ph_1)-abs(ph_2)
g3=image(rebin(r,5120,1280),xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling contrast shift of ratio change by 0.1',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c3=colorbar(target=g3, orientation=1,title='contrast shift')

;g.save, 'Modeling carbon line 658 phase shift of ratio changing by 0.1.png',resolution=100
;g1.save, 'Calculation carbon line 658 phase shift of ratio changing by 0.1.png', resolution=100
;g2.save, 'Modeling phase shift between channel 6 and 1.png',resolution=100
;g3.save, 'Modeling phase shift between channel 9 and 1.png',resolution=100
stop

p6=dcomplex(cos(p4),sin(p4))

p7=atan(p5/p6,/phase) ;phase shift between triple lines and effective wavelength
p9=dcomplex(cos(p8),sin(p8)) ;neon line
p10=atan(p9/p5,/phase) ;phase shift between triple lines and Neon line
jumpimg,p10
p11=atan(p6/p9,/phase)  ;Modeling phase shift between effective wavelength and Neon line
;g=image(rebin(real_part(p5),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling image of carbon 658 lines ignoring filter effect',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c=colorbar(target=g, orientation=1)
;g1=image(rebin(p7,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between triple lines and effective wavelength',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c1=colorbar(target=g1, orientation=1)
;g2=image(rebin(p10,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between triple lines and Neon line',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c2=colorbar(target=g2, orientation=1)
;
;
;g3=image(rebin(p11,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between effective wavelength and Neon line',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c3=colorbar(target=g3, orientation=1)

;g.save, 'Modeling image of carbon 658 lines ignoring filter effect.png' ,resolution=300
;g1.save,'Modeling phase shift between triple lines and effective wavelength.png',resolution=300
;g2.save, 'Modeling phase shift between triple lines and Neon line.png',resolution=300
;g3.save, 'Modeling phase shift between effective wavelength and Neon line.png',resolution=300


;modeling ignoring H alpha contamination and filter effect
p11=dcomplex(c1r(2)/(c1r(2)+c2r(2))*cos(p1)+c2r(2)/(c1r(2)+c2r(2))*cos(p2),c1r(2)/(c1r(2)+c2r(2))*sin(p1)+c2r(2)/(c1r(2)+c2r(2))*sin(p2))
p12=dcomplex(cos(p3),sin(p3)) ;effective wavelength
p13=atan(p11/p12,/phase)
p13=smooth(p13,1)
p14=atan(p11/p9,/phase)
jumpimg,p14


g4=image(rebin(p13,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between effective wavelength and two lines',min_value=1.94, max_value=1.98,xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c4=colorbar(target=g4, orientation=1)
g5=image(rebin(atan(p12/p9,/phase),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between effective wavelength and Neon line',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c5=colorbar(target=g5, orientation=1)
g6=image(rebin(p14,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift Neon line and  two line',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c6=colorbar(target=g6, orientation=1)
g7=image(rebin(real_part(p11),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling of carbon 658 line ignoring H alphs',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c7=colorbar(target=g7, orientation=1)

g4.save,'Modeling phase shift between effective wavelength and two lines.png',resolution=300
g5.save, 'Modeling phase shift between effective wavelength and Neon line.png',resolution=300
g6.save, 'Modeling phase shift Neon line and  two line.png', resolution=300
g7.save, 'Modeling of carbon 658 line ignoring H alphs.png',resolution=300

stop


;carbon 514 line modeling ignoring filter effect
restore, 'Carbon 514 line ratios.save'; wc(7):532, wc(8):514.5
ch=[1,3,6,9];pick up four channels
p15=make_array(512,128,4,/dcomplex)

p16=waveplate(wc(0),10.0,!pi/4)+waveplate(wc(0),2.2,!pi/4)+waveplate(wc(0),1.0,!pi/4)+displacer(wc(0),1.0,!pi/4)-displacer(wc(0),1.0,3*!pi/4)   ;7 514 lines
p16_1=waveplate(wc(1),10.0,!pi/4)+waveplate(wc(1),2.2,!pi/4)+waveplate(wc(1),1.0,!pi/4)+displacer(wc(1),1.0,!pi/4)-displacer(wc(1),1.0,3*!pi/4)
p16_2=waveplate(wc(2),10.0,!pi/4)+waveplate(wc(2),2.2,!pi/4)+waveplate(wc(2),1.0,!pi/4)+displacer(wc(2),1.0,!pi/4)-displacer(wc(2),1.0,3*!pi/4)
p16_3=waveplate(wc(3),10.0,!pi/4)+waveplate(wc(3),2.2,!pi/4)+waveplate(wc(3),1.0,!pi/4)+displacer(wc(3),1.0,!pi/4)-displacer(wc(3),1.0,3*!pi/4)
p16_4=waveplate(wc(4),10.0,!pi/4)+waveplate(wc(4),2.2,!pi/4)+waveplate(wc(4),1.0,!pi/4)+displacer(wc(4),1.0,!pi/4)-displacer(wc(4),1.0,3*!pi/4)
p16_5=waveplate(wc(5),10.0,!pi/4)+waveplate(wc(5),2.2,!pi/4)+waveplate(wc(5),1.0,!pi/4)+displacer(wc(5),1.0,!pi/4)-displacer(wc(5),1.0,3*!pi/4)
p16_6=waveplate(wc(6),10.0,!pi/4)+waveplate(wc(6),2.2,!pi/4)+waveplate(wc(6),1.0,!pi/4)+displacer(wc(6),1.0,!pi/4)-displacer(wc(6),1.0,3*!pi/4)

p17=waveplate(wc(7),10.0,!pi/4)+waveplate(wc(7),2.2,!pi/4)+waveplate(wc(7),1.0,!pi/4)+displacer(wc(7),1.0,!pi/4)-displacer(wc(7),1.0,3*!pi/4) ;532 nm line
p18=dcomplex(cos(p17),sin(p17))
p19=waveplate(wc(8),10.0,!pi/4)+waveplate(wc(8),2.2,!pi/4)+waveplate(wc(8),1.0,!pi/4)+displacer(wc(8),1.0,!pi/4)-displacer(wc(8),1.0,3*!pi/4) ;514.5 nm line



p20=dcomplex(cos(p19),sin(p19))

for i=0,3  do begin
  c=cr(ch(i),0)*cos(p16)+cr(ch(i),1)*cos(p16_1)+cr(ch(i),2)*cos(p16_2)+cr(ch(i),3)*cos(p16_3)+cr(ch(i),4)*cos(p16_4)+cr(ch(i),5)*cos(p16_5)+cr(ch(i),6)*cos(p16_6)
  s=cr(ch(i),0)*sin(p16)+cr(ch(i),1)*sin(p16_1)+cr(ch(i),2)*sin(p16_2)+cr(ch(i),3)*sin(p16_3)+cr(ch(i),4)*sin(p16_4)+cr(ch(i),5)*sin(p16_5)+cr(ch(i),6)*sin(p16_6)
  p15(*,*,i)=dcomplex(c,s)
  endfor
  

;s1=atan(p15(*,*,1)/p15(*,*,0),/phase)*180.0/!pi
;s2=atan(p15(*,*,2)/p15(*,*,0),/phase)*180.0/!pi
;s3=atan(p15(*,*,3)/p15(*,*,0),/phase)*180.0/!pi
;g=image(rebin(atan(p15(*,*,0),/phase)*180.0/!pi,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase of channel 1 of lines',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c=colorbar(target=g, orientation=1,title='Phase shift (degree)')
;g1=image(rebin(smooth(s1,7),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between channel 3 and 1 ',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c1=colorbar(target=g1, orientation=1,title='Phase shift (degree)')
;g2=image(rebin(smooth(s2,7),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between channel 6 and 1',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c2=colorbar(target=g2, orientation=1,title='Phase shift (degree)')
;g3=image(rebin(smooth(s3,7),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between channel 9 and 1',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
;c3=colorbar(target=g3, orientation=1,title='Phase shift (degree)')

;g.save, 'Modeling phase of channel 1 of lines.png',resolution=100
;g1.save, 'Modeling phase shift between channel 3 and 1.png', resolution=100
;g2.save, 'Modeling phase shift between channel 6 and 1.png',resolution=100
;g3.save, 'Modeling phase shift between channel 9 and 1.png',resolution=100


p17=waveplate(wc(7),10.0,!pi/4)+waveplate(wc(7),2.2,!pi/4)+waveplate(wc(7),1.0,!pi/4)+displacer(wc(7),1.0,!pi/4)-displacer(wc(7),1.0,3*!pi/4) ;532 nm line
p18=dcomplex(cos(p17),sin(p17))
p19=waveplate(wc(8),10.0,!pi/4)+waveplate(wc(8),2.2,!pi/4)+waveplate(wc(8),1.0,!pi/4)+displacer(wc(8),1.0,!pi/4)-displacer(wc(8),1.0,3*!pi/4) ;514.5 nm line
p20=dcomplex(cos(p19),sin(p19))
d1=wc(0:6)*cr(3,*)
ew2=total(d1)
p21=waveplate(ew2,10.0,!pi/4)+waveplate(ew2,2.2,!pi/4)+waveplate(ew2,1.0,!pi/4)+displacer(ew2,1.0,!pi/4)-displacer(ew2,1.0,3*!pi/4) ;effective wavelength
p22=dcomplex(cos(p21),sin(p21))

p23=atan(p16/p18,/phase)
jumpimg, p23

g=image(rebin(real_part(p15(*,*,1)),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling image of carbon 514 lines ignoring filter effect',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c=colorbar(target=g, orientation=1)
g1=image(rebin(p23,5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between lines and 532 nm line',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c1=colorbar(target=g1, orientation=1)
g2=image(rebin(atan(p15(*,*,1)/p20,/phase),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between lines and 514.5 nm line',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c2=colorbar(target=g2, orientation=1)
g3=image(rebin(atan(p15(*,*,1)/p22,/phase),5120,1280), xpixel, ypixel,rgb_table=4, axis_style=1, title='Modeling phase shift between lines and effective wavelength',xtitle='X pixel',ytitle='Y pixel',aspect_ratio=3.5)
c3=colorbar(target=g3, orientation=1)

g.save, 'Modeling image of carbon 514 lines ignoring filter effect.png' ,resolution=300
g1.save,'Modeling phase shift between lines and 532 nm line.png',resolution=300
g2.save, 'Modeling phase shift between lines and 514.5 nm line.png',resolution=300
g3.save, 'Modeling phase shift between lines and effective wavelength.png',resolution=300


stop









stop

end