pro carbonII_514_modeling

line=[[513.294, 0.1417],$
      [513.328 ,0.1417],$
      [513.726 ,0.0493],$
      [513.917 ,0.0495],$
      [514.349 ,0.1359],$
      [514.516 ,0.3275],$
      [515.109 ,0.1544]]
high_limit=524
low_limit=504
delta=0.001
wave_range=range(low_limit,high_limit,delta)
n1=(high_limit-low_limit)/delta+1
normal_wave1=(wave_range-line(0,0))/line(0,0)
normal_wave2=(wave_range-line(0,1))/line(0,1)
normal_wave3=(wave_range-line(0,2))/line(0,2)
normal_wave4=(wave_range-line(0,3))/line(0,3)
normal_wave5=(wave_range-line(0,4))/line(0,4)
normal_wave6=(wave_range-line(0,5))/line(0,5)
normal_wave7=(wave_range-line(0,6))/line(0,6)
n=4000
temp=findgen(n)*0.01+0.01

contrast_temp=make_array(n1/50+1,n,/float)

for i=0,n-1 do begin
  fun1=line(1,0)*exp(-normal_wave1^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun2=line(1,1)*exp(-normal_wave2^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun3=line(1,2)*exp(-normal_wave3^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun4=line(1,3)*exp(-normal_wave4^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun5=line(1,4)*exp(-normal_wave5^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun6=line(1,5)*exp(-normal_wave6^2/2/temp(i)*1.68*1e8*12*8*alog(2))
  fun7=line(1,6)*exp(-normal_wave7^2/2/temp(i)*1.68*1e8*12*8*alog(2))
 
  fun=fun1+fun2+fun3+fun4+fun5+fun6+fun7
  
;contrast1=abs(fft(fun1))
;contrast2=abs(fft(fun2))
;contrast3=abs(fft(fun3))
;contrast4=contrast1+contrast2+contrast3
c=abs(fft(fun))
c=c/max(c)
contrast=c[0:n1/50]
contrast_temp(*,i)=contrast
  endfor 
 delta1=normal_wave6(1)-normal_wave6(0)
wave_delay=findgen( n1/50+1)/(n1*delta1) 
wave_average=line(0,5)
delta_n_b=bbo(wave_average,kapa=kapa)
kapa_b=kapa
delta_n_l=linbo3(wave_average,kapa=kapa)
kapa_l=kapa
length=wave_delay/kapa_b*wave_average*1e-6/abs(delta_n_b)
g=image(contrast_temp,wave_delay, temp, title=' Modeling of CarbonII line 514 nm ',xtitle='Wave delay',ytitle='Spiece temperature (eV)' ,rgb_table=5,axis_style=1,aspect_ratio=230)
;noisy_one=noise_pick(contrast_temp, 0.8,ITERATIONS=100)
;g1=image(noisy_one,length, temp, title=' Noisy modeling of CarbonII line 514 nm  ',xtitle='Crystal BBO length (mm)',ytitle='Spiece temperature (eV)' ,rgb_table=5,axis_style=1,aspect_ratio=20)
cb=colorbar(target=g, orientation=1)
contrast_temp514=contrast_temp    
p=plot(temp, contrast_temp(129,*),title='Contrat variation with temperature',xtitle='Temperature(eV)',ytitle='Contrast');single dealy proposed for 514 lines
p1=plot(wave_delay, 1.0/(contrast_temp514(*,2000)*wave_delay), title='Phase (velocity) error variation with wave delays at 20 eV',xtitle='Wave delay', ytitle='1.0/(contrast*delay)',xrange=[0,8000])
save, contrast_temp514, length, temp,wave_delay, filename='carbon514 modeling.save '   
stop
end