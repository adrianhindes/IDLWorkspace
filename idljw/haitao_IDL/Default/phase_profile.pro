pro phase_profile, shotno, channel

;find mode 1 frequency
y=read_pmt_channel(1674,0,time=time)
delta_t=time[1]-time[0]
fnyq=1/(2*delta_t)
npts = n_elements(time)
power=make_array(npts/2, value=0.0)
power= abs( (fft(y))[1:npts/2] )
freq = (findgen(npts/2)+1)/(npts/2)*fnyq
power1=power[10000:14000]
maximum= max(power1,index)
dom_freq=(10000.0+index)/(npts/2)*fnyq
dom_freq1=fix(dom_freq)
print, 'mode1 frequency is :',fix(dom_freq)




begin_time=0.1
end_time=0.5
sam_number=(end_time-begin_time)*1e6+1
data_arr=make_array(sam_number,16)
phase_array=make_array(sam_number,16,/complex)

for i=0,15  do begin 
k=channel+i
y_data=read_pmt_channel(shotno,k,time=time)
data_arr(*,i)=y_data[(begin_time/delta_t):(end_time/delta_t)]
fft_trans=fft(data_arr(*,i))
freq_ind=dom_freq1*sam_number*delta_t
fft_trans(0:(freq_ind-100))=0
fft_trans((freq_ind+100):-1)=0
inv_fft=fft(fft_trans,/inverse)
phase_array(*,i)=atan(inv_fft,/phase)
endfor

p=image(phase_array)
stop
end




