pro fou
N=1024 & t=findgen(N)
f=10*sin(2*!pi*t/32) + 20*randomn(seed,N)
;plot,f
 c=fft(f)
 plot,abs(c),title='Fourier Spectrum of f'
c(0:31)=0 & c(33:N-33)=0 & c(N-31:*)=0
ff=fft(c,/inverse)
plot,ff,title='Extracted Signal'
stop
end
