pro time_freq_distribution, shotno, channel

if n_elements(shotno) eq 0 then shotno=1398
if n_elements(channel) eq 0 then channel=8



y=read_pmt_channel(shotno,channel,time=time)
delta_t=time[1]-time[0]
;fnyq=1/(2*delta_t)
npts = n_elements(time)
dp=make_array(npts,16)
for i=0,15 do begin
  dp(*,i)=read_pmt_channel(shotno,i,time=time)
  endfor


N=51
N1=npts/N
time_axis=510*(findgen(N)+1)/N

;fft_transform=make_array(N1/2,N, value=0.0)
power=make_array(N1/2+1,N, value=0.0)

;divided_data=make_array(N1/2, N, value=0.0)
;for j=0, N-1 do begin
;divided_data(*,j)=y[j*N1:((j+1)*N1-1-N1/2)]
;endfor

for j=0,N-1 do begin
  data = y[j*N1:((j+1)*N1-1)] 
  power[*,j] = abs( (fft(data))[0:N1/2] )
  ;power[*,j] = (fft(data))[0:N1/2] 
endfor

;power=(abs(fft_transform))^2
freq = findgen(N1/2+1)/(N1*delta_t)
;!p.multi=[0,4,4]
;for channel=channel,15 do begin
;channel_num=channel+1
ima=contour(transpose(alog(power))>(-11)<(-3),rgb_table=4,axis_style=1, time_axis, freq/1000, xrange=[0,500],yrange=[0,100],xtitle='Time (ms)', ytitle='Freq (kHz)')
;ima=image(transpose(alog(power))>(-13)<0,rgb_table=4, time_axis, freq/1000, xtitle='Time (ms)', ytitle='Freq (kHz)', yrange=[0,100],xrange=[0,500]);,layout=[4,4,channel+1],/current,/fill)
;endfor
stop
end
;contour, transpose(alog(power))>(-9)<0, time_axis, freq/1000, nlev=20,/fill,$
   ; xtitl='Time (ms)', ytitl='Freq (kHz)', yrange=[0,100],xrange=[0,500],/yst
    

 
;transform_rotation=rotate(power,4)

;fx=transform_rotation<1e-6>0


