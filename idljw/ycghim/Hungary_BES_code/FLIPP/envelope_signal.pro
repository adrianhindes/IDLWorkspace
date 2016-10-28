pro envelope_signal,shot,signal_orig,timerrange=timerange,data_source=data_source

signal = signal_orig
get_rawsignal,shot,signal,t,d,trange=timerange,sampletime=sampletime,data_source=data_source

n_orig = n_elements(d)
n = 2l^(fix(alog(n_orig)/alog(2))+1)
if (n-n_orig)/n_orig lt 0.1 then n = n*2
s = dblarr(n)
s[(n-n_orig)/2:(n-n_orig)/2+n_orig-1] = d
f = fft(s)
f = f[0:n/2]
f_sh = complex(-imaginary(f),double(f))
ind = n/2-1-lindgen(n_elements(f)-2)
f_trans = [f_sh, dcomplex(double(f_sh[ind]),-imaginary(f_sh[ind]))]
s_sh = fft(f_trans,/inv)
data = double(s)^2+double(s_sh)^2
data = data[(n-n_orig)/2:(n-n_orig)/2+n_orig-1]
starttime = t[0]
save,data,sampletime,starttime,file='data/'+i2str(shot,digit=5)+signal_orig+'_env.sav'
end