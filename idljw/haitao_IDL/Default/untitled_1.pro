function waveplatel1, wavelength,wl,wr
alpha=make_array(512,512,/double)
del=make_array(512,512,/double)
phase_shift=make_array(512,512,/double) ;delay thickness in mm
;wavelength=532.0 ; wavelength in nm
delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
;delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(512,512,/double)
term2=make_array(512,512,/double)
term3=make_array(512,512,/double)
simulation=make_array(512,512,/double)
sita=0
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,511 do begin
  for j=0,511 do begin
  del(i,j)=atan((i-255)*sensor, (j-255)*sensor)+wr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-255)*sensor)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*wl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return , phase_shift
end

function waveplateb1, wavelength,wl,wr
alpha=make_array(512,512,/double)
del=make_array(512,512,/double)
phase_shift=make_array(512,512,/double) ;delay thickness in mm
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n1=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(512,512,/double)
term2=make_array(512,512,/double)
term3=make_array(512,512,/double)
simulation=make_array(512,512,/double)
sita=0
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,511 do begin
  for j=0,511 do begin
  del(i,j)=atan((i-255)*sensor, (j-255)*sensor)+wr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-255)*sensor)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*wl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return , phase_shift
end



function displacer1, wavelength,dl ,dr
alpha=make_array(512,512,/double)
del=make_array(512,512,/double)
phase_shift=make_array(512,512,/double)
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(512,512,/double)
term2=make_array(512,512,/double)
term3=make_array(512,512,/double)
simulation=make_array(512,512,/double)
sita=!pi/4
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,511 do begin
  for j=0,511 do begin
  del(i,j)=atan((i-255)*sensor, (j-255)*sensor)+dr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-255)*sensor)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*dl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return,phase_shift
end

function displacer2, wavelength,dl ,dr
alpha=make_array(2560,2160,/double)
del=make_array(2560,2160,/double)
phase_shift=make_array(2560,2160,/double)
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(2560,2160,/double)
term2=make_array(2560,2160,/double)
term3=make_array(2560,2160,/double)
simulation=make_array(2560,2160,/double)
sita=!pi/4
sensor=16.0*1e-6 ;sensor size in m
fl=85.0 ;focal length
for i=0,2559 do begin
  for j=0,2159 do begin
  del(i,j)=atan((i-255)*sensor, (j-255)*sensor)+dr+!pi/2
  alpha(i,j)=atan(sqrt(((i-255)*sensor)^2+((j-255)*sensor)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*dl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return,phase_shift
end




pro multi_delay,  d1,d2
d1=waveplateb1(657.805, 20.0, -!pi/4)*kbbo(657.805)-waveplatel1(657.805, 3.23, !pi/4)*klinbo3(657.805)+displacer1(657.805, 3.0, -!pi/4)*kbbo(657.805)
;d3=waveplateb1(659.895, 20.5, -!pi/4)*kbbo(659.895)-waveplatel1(659.895, 3.5, -!pi/4)*klinbo3(659.895)+displacer1(659.895, 3.0, -!pi/4)*kbbo(659.895)

d2=waveplateb1(657.805, 8.0, !pi/4)*kbbo(657.805)-waveplatel1(657.805, 1.46, -!pi/4)*klinbo3(657.805)+displacer1(657.805, 3.0, !pi/4)*kbbo(657.805)
stop
d4=waveplateb1(514.516, 15.28, !pi/4)*kbbo(514.516)-waveplatel1(514.516, 2.28, -!pi/4)*klinbo3(514.516)+displacer1(514.516, 3.0, !pi/4)*kbbo(514.516)-displacer1(514.516, 3.0, 3*!pi/4)*kbbo(514.516)
d5=waveplateb1(514.516, 15.28, 0)*kbbo(514.516)-waveplatel1(514.516, 2.28, !pi/2)*klinbo3(514.516)+displacer1(514.516, 3.0, 0)*kbbo(514.516)
d6=waveplateb1(514.516, 15.28, !pi/4)*kbbo(514.516)-waveplatel1(514.516, 2.28, -!pi/4)*klinbo3(514.516)+displacer1(514.516, 3.0, !pi/4)*kbbo(514.516)-displacer1(514.516, 3.0, 3*!pi/4)*kbbo(514.516)

stop



;m=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\multidelay3.tif')
;m1=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\mbackground3.tif')
fil='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\multidelay5.spe'
fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\mbackground5.spe'
read_spe, fil, lam, t,d3,texp=texp,str=str,fac=fac  & d3=float(d3)
m=d3
read_spe, fil1, lam, t,d4,texp=texp,str=str,fac=fac  & d4=float(d4)
m1=d4
m2=float(m)-float(m1)

han=hanning(512, 512, /double)

m2=m2*han
m3=fft(m2,/center)

p=waveplatel1(658.0,d1, !pi/4)+displacer1(658.0,3.0, !pi/4)
p1=waveplatel1(658.0,d2, -!pi/4)+displacer1(658.0,3.0, -!pi/4)
ss=cos(p+p1)+cos(p-p1)
ff=fft(ss,/center)

pp=waveplatel1(658.0,35.0, !pi/4)+displacer1(658.0,2.25, !pi/4)-displacer1(658.0,2.25, !pi/4+!pi/2)
d5=fft(cos(pp),/center)

pp1=displacer2(658.0,2.25, !pi/4)-displacer2(658.0,2.25, !pi/4+!pi/2)
d6=fft(cos(pp1),/center)


p2=waveplatel1(658.0,d1, 0)+displacer1(658.0,2.25, 0)-displacer1(658.0,2.25, !pi/2)
p3=waveplatel1(658.0,d2, !pi/4+!pi/4)+displacer1(658.0,2.25, !pi/4+!pi/4)-displacer1(658.0,2.25, !pi/2+!pi/4+!pi/4)
ss1=cos(p2+p3)+cos(p2-p3)
ff1=fft(ss1,/center)

deltb_n=bbo(658.0,kapa=kapa)
kapab=kapa
deltl_n=linbo3(658.0,kapa=kapa)
kapal=kapa
a=(waveplateb(658.0, 3.0, 0))*kapab
a1=(waveplatel(658.0, 3.0, 0))*kapal
a2=displacer(658.0, 5.0, 0)*kapab
a3=waveplateb(658.0, 20.0, -!pi/4)*kapab-waveplatel(658.0, 3.0, -!pi/4)*kapal+displacer(658.0, 3.0, -!pi/4)*kapab

a4=waveplateb(658.0, 8.0, !pi/4)*kapal-waveplatel(658.0, 1.0, !pi/4)*kapal+displacer(658.0, 3.0, !pi/4)*kapab

aa=waveplatel(658.0, 20.0, !pi/4)*kapal+waveplatel(658.0, 15.0, !pi/4)*kapal+displacer(658.0, 5.0, !pi/4)*kapab-displacer(658.0, 5.0, 3*!pi/4)*kapab

stop

w=waveplatel(658.0,d1, !pi/4)+displacer(658.0,2.25, !pi/4)-displacer(658.0,2.25, !pi/2+!pi/4)+waveplatel(658.0,d2, !pi/2)+displacer(658.0,2.25, !pi/2)-displacer(658.0,2.25, !pi/2+!pi/2)
w1=waveplatel(658.0,d1-d2, !pi/4)+displacer(658.0,2.25, !pi/4)-displacer(658.0,2.25, !pi/2+!pi/4)+displacer(658.0,2.25, !pi/2)-displacer(658.0,2.25, !pi/2+!pi/2)
w2=waveplatel(658.0,d1+d2, !pi/4+!pi/4)+displacer(658.0,2.25, !pi/4+!pi/4)-displacer(658.0,2.25, !pi/2+!pi/4+!pi/4)+displacer(658.0,2.25, !pi/2+!pi/4)-displacer(658.0,2.25, !pi/2+!pi/2+!pi/4)

w3=waveplatel(658.0,d1+d2, !pi/4)+displacer(658.0,3.0, !pi/4)-displacer(658.0,3.0, !pi/2+!pi/4)
w4=waveplatel(658.0,d1-d2, !pi/4+!pi/4)+displacer(658.0,3.0, !pi/4+!pi/4)-displacer(658.0,3.0, !pi/2+!pi/4+!pi/4)
s1=cos(w3)+cos(w4)

w5=displacer(658.0,3.0, !pi/4)+displacer(658.0,3.0, !pi/4+!pi/4)
w6=displacer(658.0,2.25, !pi/4)-displacer(658.0,2.25, !pi/2+!pi/4)+displacer(658.0,2.25, !pi/2)-displacer(658.0,2.25, !pi/2+!pi/2)


a1=waveplatel(660.0,d1, !pi/4)+displacer(660.0,2.25, !pi/4)-displacer(660.0,2.25, !pi/2+!pi/4)
a1_1=waveplatel(658.0,d1, !pi/4)+displacer(658.0,2.25, !pi/4)-displacer(658.0,2.25, !pi/2+!pi/4)
a2=waveplatel(660.0,d1+d2, !pi/2)+displacer(660.0,2.25, !pi/2)-displacer(660.0,2.25, !pi/2+!pi/2)
a2_1=waveplatel(658.0,d1+d2, !pi/4)+displacer(658.0,2.25, !pi/4)-displacer(658.0,2.25, !pi/2+!pi/4)
a3=waveplatel(660.0,d2, 0)+displacer(660.0,2.25, 0)-displacer(660.0,2.25, !pi/2)
a3_1=waveplatel(658.0,d2, 0)+displacer(658.0,2.25, 0)-displacer(658.0,2.25, !pi/2)
a4=waveplatel(660.0,d1-d2, !pi*3/4)+displacer(660.0,2.25, !pi*3/4)-displacer(660.0,2.25, !pi*3/4+!pi/2)
a4_1=waveplatel(658.0,d1-d2, !pi*3/4)+displacer(658.0,2.25, !pi*3/4)-displacer(658.0,2.25, !pi*3/4+!pi/2)
f1=cos(a1)+cos(a2)+cos(a3)+cos(a4)
f2=cos(a1_1)+cos(a2_1)+cos(a3_1)+cos(a4_1)
f=f1+f2
a5=displacer(660.0,2.25, !pi/4)-displacer(660.0,2.25, !pi/2+!pi/4)
a6=displacer(660.0,2.25, !pi/2)
f1=cos(a5)+cos(a6)

f3=cos(a1)+cos(a4)


stop
;experiments for two delay 35 mm and 13 mm
 restore, 'contrast change with ratio.save'
 index=where(abs(length-13.0) lt 0.06)
 index1=where(abs(length-35.0) lt 0.03)
 r=range(-0.1,0.1,0.01)
 g=image(reform(contem(index,*,*)), axis_style=1,temp, r, rgb_table=4,title='Contrast change with line ratio for 13 mm delay',xtitle='Temperature (eV)',ytitle='Ratio change',max_value=0.4,min_value=0.0,aspect_ratio=180) ; reference ratio ri1=800/(800+570),ri2=570/(800+570), ri1-ratio change
 c=colorbar(target=g, orientation=1)
 g1=image(reform(contem(index1,*,*)),axis_style=1, temp, r, rgb_table=4,title='Contrast change with line ratio for 35 mm delay',xtitle='Temperature (eV)',ytitle='Ratio change',aspect_ratio=180)
 c1=colorbar(target=g1, orientation=1)




stop
end