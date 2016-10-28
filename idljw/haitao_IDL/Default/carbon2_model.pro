pro carbon_sline_model

k=1.38*1e-23
ms=12*1.67*1e-27
c=3*1e8


line=[[659.9, 0.555366],$
      [465.025, 0.333592],$
      [465.147, 0.111044]]
wave1=line(0,0)
no1=1.68227
derio1=-0.134
ne1=1.56075
derie1=-0.0962
del1=ne1-no1
kapa1=1-wave1*(derie1-derio1)*1e-3/del1
weight1=line(1,0)


wave2=line(0,1)
no2=1.68223
derio2=-0.134 
ne2= 1.56072
derie2=-0.0960 
del2=ne2-no2
kapa2=1-wave2*(derie2-derio2)*1e-3/del2
weight2=line(1,1)


wave3=line(0,2)
no3=1.68222
derio3=-0.133 
ne3= 1.56071
derie3=-0.0960 
del3=ne3-no3
kapa3=1-wave3*(derie3-derio3)*1e-3/del3
weight3=line(1,2)

n=2000
n1=9000
 tem=findgen(n)*0.01+2
 thickness=findgen(n1)*0.01
 
ts1=ms*(wave1*1e-9)^2*c^2/k/2/(!pi*kapa1*del1*thickness*1e-3)^2/11600
contrast1=make_array(n1,n)
for i=0,n-1 do begin
  for j=0,n1-1 do begin
    contrast1(j,i)=exp(-tem(i)/ts1(j))
    endfor   
endfor

;for i=0,n-1 do begin
  ;contrast1(*,i)=contrast1(*,i)*cos(2*!pi*thickness*1e-3*del1/(wave1*1e-9))
  ;endfor
  
ts2=ms*(wave2*1e-9)^2*c^2/k/2/(!pi*kapa2*del2*thickness*1e-3)^2/11600  
contrast2=make_array(n1,n)
for i=0,n-1 do begin
  for j=0,n1-1 do begin
    contrast2(j,i)=weight2*exp(-tem(i)/ts2(j))
    endfor   
endfor
;for i=0,n-1 do begin
  ;contrast2(*,i)=contrast1(*,i)*cos(2*!pi*thickness*1e-3*del2/(wave2*1e-9))
  ;endfor
  

ts3=ms*(wave3*1e-9)^2*c^2/k/2/(!pi*kapa3*del3*thickness*1e-3)^2/11600  
contrast3=make_array(n1,n)
for i=0,n-1 do begin
  for j=0,n1-1 do begin
    contrast3(j,i)=weight3*exp(-tem(i)/ts3(j))
    endfor   
endfor
;for i=0,n-1 do begin
  ;contrast3(*,i)=contrast3(*,i)*cos(2*!pi*thickness*1e-3*del3/(wave3*1e-9))
  ;endfor
  


contrast=contrast1
g=image(abs(contrast), thickness, tem, title='Modeling of single line 464.74 nm', xtitle='BBO thickness (nm)', ytitle='Spieces temperature (eV)',rgb_table=5, axis_style=1,aspect_ratio=5)
c=colorbar(target=g,orientation=1)
stop
end
