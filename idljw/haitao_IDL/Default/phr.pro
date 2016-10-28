pro phr

deltb_n=bbo(658.0,kapa=kapa)
kapab=kapa
deltl_n=linbo3(658.0,kapa=kapa)
kapal=kapa
ri1=800.0/(800.0+570.0)
ri2=570.0/(800.0+570.0)
line=[[657.805,ri1],$
     [658.288 ,ri2]]
rs=findgen(21)*0.01-float(0.1)
ps_ratio=make_array(512,512,21) ;phase shift with ratio
p=waveplatel1(line(0,0), 20.0, -!pi/4)*kapal+displacer1(line(0,0), 5.0, -!pi/4)*kapab+waveplateb1(line(0,0), 1.0, -!pi/4)*kapab
p_1=waveplatel1(line(0,1), 20.0, -!pi/4)*kapal+displacer1(line(0,1), 5.0, -!pi/4)*kapab+waveplateb1(line(0,1), 1.0, -!pi/4)*kapab
p0=(waveplatel1(line(0,0), 7.5, !pi/4)*kapal+displacer1(line(0,0), 5.0, !pi/4))*kapab
p0_1=(waveplatel1(line(0,1), 7.5, !pi/4)*kapal+displacer1(line(0,1), 5.0, !pi/4))*kapab
d=dcomplex((ri1)*cos(p+p0)+(ri2)*cos(p_1+p0_1),ri1*sin(p+p0)+ri2*sin(p_1+p0_1)) ;reference phase
;d2=dcomplex(ri1*cos(p1-p2)+ri2*cos(p1_1-p2_1),ri1*sin(p1-p2)+ri2*sin(p1_1-p2_1))


for i=0,20 do begin
p1=waveplatel1(line(0,0), 20.0, -!pi/4)*kapal+displacer1(line(0,0), 5.0, -!pi/4)*kapab+waveplateb1(line(0,0), 1.0, -!pi/4)*kapab
p1_1=waveplatel1(line(0,1), 20.0, -!pi/4)*kapal+displacer1(line(0,1), 5.0, -!pi/4)*kapab+waveplateb1(line(0,1), 1.0, -!pi/4)*kapab
p2=(waveplatel1(line(0,0), 7.5, !pi/4)*kapal+displacer1(line(0,0), 5.0, !pi/4))*kapab
p2_1=(waveplatel1(line(0,1), 7.5, !pi/4)*kapal+displacer1(line(0,1), 5.0, !pi/4))*kapab
r1=ri1-rs(i)
r2=ri2+rs(i)
d1=dcomplex((r1)*cos(p1+p2)+(r2)*cos(p1_1+p2_1),r1*sin(p1+p2)+r2*sin(p1_1+p2_1))
;d2=dcomplex(ri1*cos(p1-p2)+ri2*cos(p1_1-p2_1),ri1*sin(p1-p2)+ri2*sin(p1_1-p2_1))
ps_ratio(*,*,i)=atan(d1/d,/phase)*180.0/!pi
save,rs,ps_ratio,filename='Phase compensation for ratio change.save'
endfor
;index=where(abs(rs-r)lt 0.01)
stop
end