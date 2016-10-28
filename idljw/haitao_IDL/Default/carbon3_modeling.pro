pro carbon3_modeling

line=[[464.742, 0.555366],$
     [465.025, 0.333592],$
     [465.147, 0.111044]]
high_limit=500
low_limit=400
delta=0.001
wave_range=range(low_limit,high_limit,delta)
n1=(high_limit-low_limit)/delta+1
normal_wave1=(wave_range-line(0,0))/line(0,0)
normal_wave2=(wave_range-line(0,1))/line(0,1)
normal_wave3=(wave_range-line(0,2))/line(0,2)
n=2000
temp=findgen(n)*0.01+1

contrast_temp=make_array(n1/80+1,n,/float)

for i=0,n-1 do begin
  fun1=line(1,0)*exp(-normal_wave1^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun2=line(1,1)*exp(-normal_wave2^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun3=line(1,2)*exp(-normal_wave3^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  
  fun=fun1+fun2+fun3
  
;contrast1=abs(fft(fun1))
;contrast2=abs(fft(fun2))
;contrast3=abs(fft(fun3))
;contrast4=contrast1+contrast2+contrast3
c=abs(fft(fun))
c=c/max(c)
contrast=c[0:n1/80]
contrast_temp(*,i)=contrast
  endfor 
 delta1=normal_wave1(1)-normal_wave1(0)
wave_delay=findgen( n1/80+1)/(n1*delta1) 
wave_average=mean(line(0,*))
;delta_n=bbo(wave_average,kapa=kapa)
delta_n=linbo3(wave_average,kapa=kapa)
length=wave_delay/kapa*wave_average*1e-6/abs(delta_n)
g=image(contrast_temp,length, temp, title=' Modeling of triple Carbon lines ',xtitle='Crystal BBO length (mm)',ytitle='Spiece temperature (eV)' ,rgb_table=4,axis_style=1,aspect_ratio=0.8)   
cb=colorbar(target=g, orientation=1)
     
     
     
stop
end