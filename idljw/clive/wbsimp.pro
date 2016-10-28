n=600
x=findgen(n)/n

freq=100;.5

y=cos(2*!pi*x* freq+0*!dtor)
win=1.;hanning(n)

plot,x,y

f=findgen(10*n)/10.;fft_t_to_f(x)
s=complexarr(10*n)
for i=0,10*n-1 do s(i)=total(y*win*exp(complex(0,1)*f(i)*x*2*!pi))
;s=fft(y*win)
!p.multi=[0,2,2]
plot,f,abs(s),xr=freq+[-10,10];,xr=[0,20]
plot,f,atan2(s),xr=freq+[-10,10]
oplot,f,f*0.5*2*!pi mod (2*!pi),col=2
plot,f,float(s),xr=freq+[-10,10],yr=max(abs(s))*[-1,1]
oplot,f,imaginary(s),col=2
!p.multi=0
end
