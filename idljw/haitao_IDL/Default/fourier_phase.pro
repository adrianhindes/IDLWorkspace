pro fourier_phase

x=findgen(1000)*0.001
x[500:*]-=1
y=100*exp(-(x-0.2)^2/0.001)
ys=100*exp(-(x-0.1)^2/0.001)
f1=fft(ys)
f=fft(y)
a1=atan(f,/phase)
a2=atan(f1,/phase)
a=atan(f1/f, /phase)


freq=findgen(100)*0.01
y1=(x^2-1)*complex(cos(6*!pi*x),sin(6*!pi*x))
y2=(x^2-1)*complex(cos(6*!pi*x-!pi/4),sin(6*!pi*x-!pi/4))
y3=y1/y2
angle1=atan(y1,/phase)
angle2=atan(y2,/phase)
angle=angle1-angle2
angle3=atan(y3,/phase)
stop
end
