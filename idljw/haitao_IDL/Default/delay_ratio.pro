pro delay_ratio

temp=15.0
line=[657.805,658.288]
r=(findgen(100)+1.0)*0.05
high_limit=665.0
low_limit=650.0
delta=0.005
wave_range=range(low_limit,high_limit,delta)
n1=(high_limit-low_limit)/delta+1
nw=double((wave_range-line(0))/line(0))
ws=(line(1)-line(0))/line(0)
ub=5.788*1e-5 ; bohr magneton ev/T
 h=4.1357*1e-15 ;planck constant ev.s
 c=3.0*1e8 ;light velocity m/s
 b=0.5 ; magnetci field T
 ;normal zeeman effect
 ws1=double(ub*b*(line(0)*1e-9)^2/(h*c)*1e9 )/line(0);wavelength shift for line 1
 ws2=double(ub*b*(line(1)*1e-9)^2/(h*c)*1e9)/line(1)
delay=findgen(8000)
cont=make_array(n1/8+1,100)
cont=make_array(8000,100)
dellam=(line(1)-line(0))/line(0)
for j=0,7999 do begin
for i=0,99 do begin
  swidth=temp/(1.68*1d8*12.0*8.0*double(alog(2.0)))
  
  cont(j,i)=abs(exp(-!pi^2*swidth*delay(j)^2)*(r(i)*cos(2*!pi*dellam*delay(j))+1)
  endfor
  endfor
  
stop





for i=0,99  do begin
  fun1=0.5*exp(-nw^2/2/temp*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun1_1=0.25*exp(-(nw-ws1)^2/2/temp*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun1_2=0.25*exp(-(nw+ws1)^2/2/temp*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun2=0.5*r(i)*exp(-(nw-ws)^2/2/temp*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun2_1=0.25*r(i)*exp(-(nw-ws+ws2)^2/2/temp*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun2_2=0.25*r(i)*exp(-(nw-ws-ws2)^2/2/temp*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun=fun1+fun1_1+fun1_2+fun2+fun2_1+fun2_2
  f=fft(fun)
  c=abs(f)
  c=c/max(c)
  cont(*,i)=c(0:n1/8)
  endfor
   delta1=nw(1)-nw(0)
 wave_delay=findgen( n1/8+1)/(n1*delta1) 
 delta_n=linbo3(line(0),kapa=kapa)
kapa_l=kapa
index=where(abs(wave_delay-2100) lt 1.0)
stop
pr=reform(cont(index,*))
;index1=where(abs(pr-con)lt 0.1)

;length=wave_delay/kapa_l*line(0)*1e-6/abs(delta_n)
;index=where(abs(length-35) lt 0.03);delay of 35 mm , ct is aroudn 18.5
index1=where(abs(length-15.0) lt 0.12);Linbo3 delay for 25 mm, c_t is around 36 eV 
stop
end