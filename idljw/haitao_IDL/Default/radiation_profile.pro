pro radiation_profile, shotno, channel

if n_elements(shotno) eq 0 then shotno=1398
if n_elements(channel) eq 0 then channel=0

direct_array=make_array(1000,16)
radiation_arr=make_array(510000,16)
begin_time=0.1
end_time=0.5
power_arr=make_array((end_time-begin_time)*1e6/2+1,16)
maximum_value=make_array(16)
for j=0,15 do begin
c=channel+j
y_calibration=read_pmt_channel(1566,c,time=time)
direct_array(*,j)=read_pmt_channel(1566,j,time=time)
maximum_value(j)=max(y_calibration)
endfor
normal_max=maximum_value/max(maximum_value)

for i=0,15  do begin 
k=channel+i
y_data=read_pmt_channel(shotno,k,time=time)
npts=n_elements(time)
delta_t=time(1)-time(0)
radiation_arr(*,i)=y_data/normal_max(i)


power=abs(fft(radiation_arr(*,i)))
power=power[begin_time*1e6:end_time*1e6]
dp=(end_time-begin_time)*1e6
power_arr(*,i)=power(0:dp/2)

;end_point=end_time*time
;sample=y_data[begin_time*npts:end_time*npts-1]
;sample_number=n_elements(sample)
;power=(abs(fft(sample)))[0:sample_number/2]
;power_arr(*,i)=power
endfor
power1=transpose(power_arr)
channel_arr=findgen(15)
x=findgen(510)
y=findgen(160)*0.1
channel_arr=findgen(16)
freq=findgen(sample_number/2+1)/(sample_number*delta_t)
ima=image(rebin(radiation_arr,510,160),rgb_table=5, x, y,aspect_ratio=12,layout=[1,2,1],axis_style=1,xtitle='time(ms)',ytitle='channelno',title='shotno'+shotno)
ima1=image(alog(power1)>(-12)<(-1),rgb_table=5, channel_arr, freq/1000,aspect_ratio=0.05,layout=[1,2,2],axis_style=1,xrange=[0,15],yrange=[0,100],xtitle='channel',ytitle='Frequency(kHz)',/current)

stop
end
