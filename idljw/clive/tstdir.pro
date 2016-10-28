f0=100e3
n=10000
dt=1e-6
t=findgen(n) * dt

y1=sin(2*!pi*f0 *t)

y2 = sin(2*!pi*f0 *t - !pi/4)

plot,t,y1,xr=[0,30e-6]
oplot,t,y2,col=2

s1=fft(y1)
s2=fft(y2)
cc=s1 * conj(s2)

plot,abs(s1),/ylog
dum=max(abs(s1),imax)
print,cc(imax)
;positive, so positive phase means ball pen probe lags ball pen probe
end
