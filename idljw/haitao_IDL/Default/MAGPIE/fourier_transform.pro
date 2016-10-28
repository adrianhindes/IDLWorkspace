pro fourier_transform, shotno, channel


if n_elements(shotno) eq 0 then shotno=1398
if n_elements(channel) eq 0 then channel=8

y=read_pmt_channel(shotno,channel,time=time)
delta_t=time[1]-time[0]
fnyq=1/(2*delta_t)
npts = n_elements(time)
power=make_array(npts/2, value=0.0)
power= abs( (fft(y))[1:npts/2] )
freq = (findgen(npts/2)+1)/(npts/2)*fnyq

;for channel=channel,15 do begin
p=plot(freq/1000, alog(power)>(-12)<(-6),xtitle='Freq(kHz)',ytitle='ln(Amplititude)');,layout=[4,4,channel+1],/current)
;endfor
stop
end
