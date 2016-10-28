function wave, t, theta,omega,kay,p
s=cos(omega * t - kay * theta + p)
return,s

end

nt=10000
t=linspace(0,10e-3,nt)
dens=wave(t,0,2*!pi*1e3,10.,0)

p=!pi/2
v1=wave(t,0,2*!pi*1e3,10.,p) & sep=0.02
v2=wave(t,sep,2*!pi*1e3,10.,p)
e=- (v2-v1)/sep
plot,dens
oplot,e
plot,dens*e
mnflx=mean(dens*e)
print,'mean flux = ',mnflx

sn=fft(dens)
sv=fft(v1)
sv2=fft(v2)
sdens=fft(dens)

cc=sv * conj(sv2)
print,atan2(cc(10))
print,'---'

cc=sdens * conj(sv)
print,atan2(cc(10))
print,'---'

f=fft_t_to_f(t,/neg)
plot,f
kay=10.

kayf = f / 1e3 * 10.
result = total(-sn*conj(sv)*kayf*complex(0,1))
print,result

end


