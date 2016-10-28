pro fft_of_spectrum, lambda, width

lambda=float(lambda)
n=1000000
wavelength=findgen(n)*0.1/n+lambda-0.05
normal_wave=(wavelength-lambda)/lambda
;normal_wave1=(wavelength-lambda-0.5)/(lambda+0.5)
normal_width=width/lambda
raw_I=exp(-(normal_wave/normal_width)^2/2.0/!pi)
raw_I1=exp(-((normal_wave-1e-5)/normal_width)^2/2.0/!pi)
raw_I2=exp(-(normal_wave/normal_width*1.5)^2/2.0/!pi)
del=(max(normal_wave)-min(normal_wave))/n
wave_delay=findgen(n/2+1)/(n*del)


;bbo_delta=bbo(lambda,kapa=kapa)
;non_linear=normal_wave+kapa*normal_wave^2
;linear=findgen(n)*(max(non_linear)-min(non_linear))/n+min(non_linear)
;I=interpol(raw_I, normal_wave, linear)

;signal1=real_part(self_coherence1)
;sf=fft(signal1)


self_coherence=fft(raw_I,/inverse)
phase=atan(self_coherence,/phase)
self_coherence1=fft(raw_I1,/inverse)
signal1=real_part(self_coherence1)
sf=fft(signal1)
phase1=atan(self_coherence1,/phase)
self_coherence2=fft(raw_I2,/inverse)
intefergram=real_part(self_coherence)/max(abs(self_coherence))
contrast=abs(self_coherence)/max(abs(self_coherence))
intefergram1=real_part(self_coherence1)/max(abs(self_coherence1))
contrast1=abs(self_coherence1)/max(abs(self_coherence1))
intefergram2=real_part(self_coherence2)/max(abs(self_coherence2))
contrast2=abs(self_coherence2)/max(abs(self_coherence2))

contrast=abs(self_coherence)
bbo_delta=bbo(lambda,kapa=kapa)


bbo_thick=wave_delay*lambda*1e-6/kapa/abs(bbo_delta) ;thickness in mm


stop
end 