pro correlation
;------------------------------------
N = 1024                                 ;
frequency = 1000;10000   
dt = 1e-5                                ;
;-----------------------------------
t = findgen(N)
del_t = 1e-5                             ;10 microsecond
del_t = t*del_t                          ;time coordinate

;------------------------------------
;-------FREQUENCY--------------------
freq_lowest = 1/(n*dt)
N21 = N/2 +1
freq = indgen(n)
freq[n21] = n21 -n + findgen(n21-2)
freq = freq * freq_lowest
freq = shift(freq,-n21)


;------------------------------------
;---------SINGAL 1 & 2---------------
y = sin(2*!pi*frequency*del_t)

t_life= 0.0005

y1 = sin(2*!pi*frequency*del_t)*exp(-(del_t)^2/(t_life)^2)

;------------------------------------
;--------AUTO CORRELATION 1----------  
;---1st Method-----------------------
y_f = FFT(y)
G_1 = (y_f) * (CONJ(y_f))

C_1 = real_part(FFT(G_1, /inverse))

;------------------------------------
;A_CORRELATE
;---2nd Method-----------------------
;
a=indgen(2*N-3)-N+2   ;[-(N-2),(N-2)]
lag = a

result = A_CORRELATE(y ,lag)
;print,result

plot,lag,result


!P.MULTI = [0,1,2]
plot,shift(c_1,-n21)
plot,lag,result




stop


;;------------------------------------
;----AUTO POWER 1--------------------
power = ABS((y_f)*(CONJ(y_f)))

window,0,xsize=1000,ysize=1200
!P.MULTI = [0,1,3]
plot,del_t,y,title='Sinuosidal signal'
plot,shift(c_1,-n21),title='Auto correlation 1'
plot,freq,shift(power,-n21),/ylog,xtitle='frequency',title='AUTO POWER 1'

;------------------------------------
;------------------------------------
;------AUTO CORRELATION 2------------
y1_f = FFT(y1)
G_2 = (y1_f) * (CONJ(y1_f))

C_2 = FFT(G_2, /inverse)


;----------------------------------
;------AUTO POWER 2----------------
power1= ABS((y1_f)*CONJ(y1_f))

window,1,xsize=1000,ysize=1200
!P.MULTI = [0,1,3]
plot,del_t,y1,title='Damped signal'
plot,shift(c_2,-n21), title='Auto correlation 2'
plot,freq,shift(power1,-n21), /ylog, xtitle='frequency',title='AUTO POWER 2'






end
