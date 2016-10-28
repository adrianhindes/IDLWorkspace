function freqof,t,y,plot=plot,xr=xr,ylog=ylog
f=fft_t_to_f(t)
s=abs(fft(y-mean(y)))
n=n_elements(s)
dum=max(s(0:n/2),imax)
freq=f(imax)
print,'freq is',freq
if keyword_set(plot) then plot,f,s,ylog=ylog,xr=xr
;stop
return,freq
end
