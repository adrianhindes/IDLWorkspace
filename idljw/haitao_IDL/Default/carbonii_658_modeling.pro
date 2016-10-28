pro carbonII_658_modeling

;restore, 'spectrometer data.save'
;hafa_i=(findgen(10)+1)*ratio(0)
;carbon1_i=(1-hafa_i)*(ratio(1)/(ratio(1)+ratio(2)))
;carbon2_i=(1-hafa_i)*(ratio(2)/(ratio(1)+ratio(2)))

;data from clive
ri1=800.0/(800.0+570.0)
ri2=570.0/(800.0+570.0)


line=[[657.805,ri1],$
     [658.288 ,ri2]]


rt=make_array(10,/double)
vr=0
rha=0.0 
ri1=(1-rha)*ri1-vr
ri2=(1-rha)*ri2+vr
rt=ri1/ri2
wha=656.279  ;h alpha wavelength

 ;zeeman splitting
 ub=5.788*1e-5 ; bohr magneton ev/T
 h=4.1357*1e-15 ;planck constant ev.s
 c=3.0*1e8 ;light velocity m/s
 b=0.5 ; magnetci field T
 ;normal zeeman effect
 ws1=double(ub*b*(line(0,0)*1e-9)^2/(h*c)*1e9 );wavelength shift for line 1
 ws2=double(ub*b*(line(0,1)*1e-9)^2/(h*c)*1e9)
 
line1_1=line(0,0)-ws1
line1_2=line(0,0)+ws1
ri1_1=ri1*1/4
ri1_2=ri1*1/4
ri1=ri1*1/2

line2_1=line(0,1)-ws1
line2_2=line(0,1)+ws1
ri2_1=ri2*1/4
ri2_2=ri2*1/4
ri2=ri2*1/2

high_limit=665.0
low_limit=650.0
delta=0.005
wave_range=range(low_limit,high_limit,delta)
n1=(high_limit-low_limit)/delta+1
normal_wave1=double((wave_range-line(0,0))/line(0,0))
normal_wave1_1=double((wave_range-line1_1)/line(0,0))
normal_wave1_2=double((wave_range-line1_2)/line(0,0))
normal_wave2=double((wave_range-line(0,1))/line(0,0))
normal_wave2_1=double((wave_range-line2_1)/line(0,0))
normal_wave2_2=double((wave_range-line2_2)/line(0,0))
normal_wave3=double((wave_range-wha)/wha)

n=4000
temp=findgen(n)*0.01+0.01
temp=double(temp)

contrast_temp=make_array(n1/8+1,n,/double)
phase_arr=make_array(n1/8+1,n,/double)

 for i=0,n-1 do begin
  fun1=ri1*exp(-normal_wave1^2/2/temp(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun1_1=ri1_1*exp(-normal_wave1_1^2/2.0/temp(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun1_2=ri1_2*exp(-normal_wave1_2^2/2.0/temp(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun2=ri2*exp(-normal_wave2^2/2.0/temp(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun2_1=ri2_1*exp(-normal_wave2_1^2/2.0/temp(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun2_2=ri2_2*exp(-normal_wave2_2^2/2.0/temp(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun3=rha*exp(-normal_wave3^2/2.0/temp(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
  fun=fun2+fun1_1+fun1_2+fun2+fun2_1+fun2_2+fun3
  
;contrast1=abs(fft(fun1))
;contrast2=abs(fft(fun2))
;contrast3=abs(fft(fun3))
;contrast4=contrast1+contrast2+contrast3
f=fft(fun)
phase=atan(f,/phase)
phase=phase[0:n1/8]
phase_arr(*,i)=phase
c=abs(f)
c=c/max(c)
contrast=c[0:n1/8]
contrast_temp(*,i)=contrast
 endfor 


delta1=normal_wave1(1)-normal_wave1(0)
wave_delay=findgen( n1/8+1)/(n1*delta1) 
wave_reference=line(0,0)
;delta_n=bbo(wave_reference,kapa=kapa)
;kapa_b=kapa
delta_n=linbo3(wave_reference,kapa=kapa)
kapa_l=kapa
length=wave_delay/kapa_l*wave_reference*1e-6/abs(delta_n)
index=where(abs(length-35) lt 0.03);delay of 35 mm , ct is aroudn 18.5
index1=where(abs(length-25) lt 0.06);Linbo3 delay for 25 mm, c_t is around 36 eV

stop

;contrast_temp0=contrast_temp
contrast_temp_1=contrast_temp
;save,  contrast_temp0, filename='contrast without h alpha.save'
restore,'contrast without h alpha.save'
rt_1=ri1/ri2
;save, contrast_temp_1, rt_1,filename='contrast change with ratio-1.save'

restore, 'contrast change with ratio1.save'
restore, 'contrast change with ratio2.save'
restore, 'contrast change with ratio3.save'
restore, 'contrast change with ratio4.save'
restore, 'contrast change with ratio5.save'
restore, 'contrast change with ratio6.save'
restore, 'contrast change with ratio7.save'
restore, 'contrast change with ratio8.save'
restore, 'contrast change with ratio9.save'
restore, 'contrast change with ratio10.save'
restore,'contrast change with ratio-1.save'
restore,'contrast change with ratio-2.save'
restore,'contrast change with ratio-3.save'
restore,'contrast change with ratio-4.save'
restore,'contrast change with ratio-5.save'
restore,'contrast change with ratio-6.save'
restore,'contrast change with ratio-7.save'
restore,'contrast change with ratio-8.save'
restore,'contrast change with ratio-9.save'
restore,'contrast change with ratio-10.save'

rs=findgen(21)*0.01-0.1; ratio shift of first carbon line
rt=[rt_10,rt_9,rt_8,rt_7,rt_6,rt_5,rt_4,rt_3,rt_2,rt_1,800.0/570.0, rt1, rt2,rt3,rt4,rt5,rt6,rt7,rt8,rt9,rt10];ratio of two lines
rt=double(rt)
contem=make_array(n1/8+1,n,21, /double)
contem(*,*,0)=contrast_temp_10
contem(*,*,1)=contrast_temp_9
contem(*,*,2)=contrast_temp_8
contem(*,*,3)=contrast_temp_7
contem(*,*,4)=contrast_temp_6
contem(*,*,5)=contrast_temp_5
contem(*,*,6)=contrast_temp_4
contem(*,*,7)=contrast_temp_3
contem(*,*,8)=contrast_temp_2
contem(*,*,9)=contrast_temp_1
  contem(*,*,10)=contrast_temp0
  contem(*,*,11)=contrast_temp1
  contem(*,*,12)=contrast_temp2
  contem(*,*,13)=contrast_temp3
  contem(*,*,14)=contrast_temp4
  contem(*,*,15)=contrast_temp5
  contem(*,*,16)=contrast_temp6
  contem(*,*,17)=contrast_temp7
  contem(*,*,18)=contrast_temp8
  contem(*,*,19)=contrast_temp9
  contem(*,*,20)=contrast_temp10
;save,contem, rt,temp, length , filename='contrast change with ratio.save'

stop
p=plot(temp,-alog(contrast_temp(index,*)/contrast_temp0(index,*))*18.5,title='Temperature change caused by 10% H alpha contamination of 35 mm delay',xtitle='Temperature', ytitle='Temperature change')
g=image(contrast_temp, length, temp, rgb_table=4, axis_style=1,title='Contrast variation with temperature including without H alpha contamination',xtitle='Length of Linbo3',ytitle='Temperature (eV)',aspect_ratio=2.5)
c=colorbar(target=g, orientation=1)

stop
end


index=where(abs(length-46) lt 0.02)
for i=0,9 do begin
  phase_arr(*,5,i)=phase_arr(*,5,i)-phase_arr(*,5,0)
  endfor
re=reform(phase_arr(*, 5,*))
imgplot, reform(phase_arr(*,5,*)), length, hafa_i/(1-hafa_i),/cb , title='Phase shift refer to initial with hafa ratio for 0.5 eV', xtitle='LN length/mm',ytitle='Hafa/Carbon Ratio',zr=[0,2]
p=plot(hafa_i/(1-hafa_i),re(index,*),title='Phase shift refer to initial for 0.5 eV with 46 mm length', xtitle='Hafa/carbon Ratio',ytitle=' Phase shift/radian')
g=image(reform(contrast_temp(*,*,0)),length, temp, title=' Modeling of Carbon line 658 nm ',xtitle='Crystal BBO length',ytitle='Spiece temperature (eV)' ,rgb_table=5,axis_style=1,aspect_ratio=1.5)   
cb=colorbar(target=g, orientation=1)


L=45
wave_delay_l=uint(l*abs(delta_n)/wave_reference*kapa/1e-6*(n1*delta1))
L_temp=contrast_temp(wave_delay_l,*)
save,temp,L_temp,filename='L_temp1.save'
contrast_temp658=contrast_temp
length658=length
save, contrast_temp658, length658, filename='carbon658 modeling.save'
     
     
     
stop
end