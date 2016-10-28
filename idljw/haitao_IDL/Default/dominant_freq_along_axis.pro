pro dominant_freq_along_axis, shotno, channel

if n_elements(shotno) eq 0 then shotno=1434
if n_elements(channel) eq 0 then channel=8

begin_point=20000
end_point=250000
max_freq_arr=make_array(17)
for i=0,16 do begin

k=shotno+i
y=read_pmt_channel(k,channel,time=time)
delta_t=time[1]-time[0]
fnyq=1/(2*delta_t)
npts = n_elements(time)
power=make_array(npts/2+1, value=0.0)

power= abs( (fft(y))[0:npts/2] )
value_range=power[begin_point:end_point]
max_value=max(alog(value_range),index)

max_index=index
max_index=float(max_index)
max_value=float(max_value)


max_freq_arr(i)=(max_index+begin_point)/(npts*delta_t)
;max_freq_arr(i)=max_freq

position=findgen(17)

endfor
p=plot(position, max_freq_arr/1000)

stop
end