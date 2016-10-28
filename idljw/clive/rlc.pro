i=complex(0,1)
n=2000L
f=linspace(0,20e6,n)
w=2*!pi*f


w0=2*!pi*7.5e6
;w=1/srt(lc)
;c=1e-9
l=68e-6
c=(1/w0 )^2 / l

seriesr=20000.

xc=1/i/w/c
xl=i*w*l
imp=(1/xc+1/xl)^(-1)

imptot = imp +seriesr

xfer = imp / imptot

plot,f,abs(xfer)
j=value_locate(f,7e6)
oplot,f(j)*[1,1],!y.crange

print,abs(xfer(j))
end
