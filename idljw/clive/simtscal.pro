function expwav, t,f,trise
tp=(t mod (1/f)) / (1/f)
idx=where(tp lt 0.5)
trisep = trise * f
w=t*0
w(idx) = 1-exp(-tp(idx)/trisep)

idx=where(tp ge 0.5)

tpm=tp-0.5
w(idx) = exp(-tpm(idx)/trisep) - (exp(-0.5/trisep))

;plot,t,f

;stop
return,w
end

function getp, trise
nt=1600
t=linspace(0,4,nt)
print,'ay'
f=2.
;trise=2e-3
w=expwav(t,f,trise)
s=fft(w)
freq=fft_t_to_f(t)
ival=value_locate3(freq,f)
;plot,freq,abs(s),/ylog,xr=[0,10]
;plot,t,w,xr=[0,1/f]

p=atan2(s(ival))+!pi/2
return,p
end

nt=100
trarr=linspace(2e-3,4*250e-3,nt)
p=fltarr(nt)
for i=0,nt-1 do p(i)=getp(trarr(i))

plot,trarr,p*!radeg

end
