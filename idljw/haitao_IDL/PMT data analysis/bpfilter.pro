pro bpfilter,r1,c1,r2,c2

;LRC bandpass filter
f=findgen(1000)*100.0
w=2*!pi*f
lc=10.0*1e-3
c=3.4*1e-9;4.3*1e-9;5.3*1e-9;6.3*1e-9;
r=50.0

w0=1.0/sqrt(lc*c)
f0=w0/2/!pi
q=sqrt(lc/r^2/c)
wl=w0*sqrt(1+1.0/4/q^2)-w0/2.0/q
fl=wl/2/!pi
wu=w0*sqrt(1+1.0/4/q^2)+w0/2.0/q
fu=wu/2/!pi
Hw=1.0/dcomplex(1.0,q*(w/w0-w0/w))
plot, f/1000.0,abs(hw),xrange=[10,30]

stop





;back to back bandpass filter
f=findgen(100)*1000
w=2*!pi*f
w1=1.0/r1/c1
w2=1.0/r2/c2

k=1.0/(1+w1/w2)
q=sqrt(w1/w2)/(1+w1/w2)
w0=sqrt(w1*w2)

Hw=k/dcomplex(1.0,q*(w/w0-w0/w))


stop
end
