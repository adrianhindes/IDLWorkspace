pro fourier_test
x=findgen(1000000)*0.000001-0.5
;x[0:5000]-=1
y=0.2*exp(-(6*!pi*x-0.5)^2/0.004)
y1=0.4*exp(-(6*!pi*x)^2/0.004)
y3=y+y1
f=fft(y)
f1=fft(y1)
f2=fft(y3)
freq=findgen(500)/1000/0.001
phase=atan(f,/phase)
phase1=atan(f1,/phase)
net_phase=phase-phase1

x1=findgen(1000)


stop
end
