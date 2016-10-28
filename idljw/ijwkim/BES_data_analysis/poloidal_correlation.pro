pro poloidal_correlation

;channel1_8 = bes_read_data(7821, '1-8', trange=[1.3, 4.6])
;
;channel2_6 = bes_read_data(7821, '2-6', trange=[1.3, 4.6])
;
;channel3_4 = bes_read_data(7821, '3-4', trange=[1.3, 4.6])
;
;channel4_2 = bes_read_data(7821, '4-2', trange=[1.3, 4.6])

dt = 5e-07
life_time = 15e-06
subwindow = life_time*100

;shot_number= 9127, channel 4-6, 3-6, 2-6 ,1-6, time: 3.4-3.8sec
shot_number = 9127
time_start = 3.4
time_end = 3.8

freq_filter = [0.01, 1.0]

channel_number1 = '4-1'
channel_number2 = '3-1'
channel_number3 = '2-1'
channel_number4 = '1-1'

sample = bes_read_data(shot_number, channel_number1, trange=[0, 5])
;ycplot,sample.tvector,sample.data

channel1 = bes_read_data(shot_number, channel_number1, trange=[time_start, time_end])

channel2 = bes_read_data(shot_number, channel_number2, trange=[time_start, time_end])

channel3 = bes_read_data(shot_number, channel_number3, trange=[time_start, time_end])

channel4 = bes_read_data(shot_number, channel_number4, trange=[time_start, time_end])

;ycplot,channel1.tvector,channel1.data
;ycplot,channel2.tvector,channel2.data
;ycplot,channel3.tvector,channel3.data
;ycplot,channel4.tvector,channel4.data

print, variance(channel1.data(101:1000))/mean(channel1.data(101:1000))
print, variance(channel2.data(101:1000))/mean(channel2.data(101:1000))
print, variance(channel3.data(101:1000))/mean(channel3.data(101:1000))
print, variance(channel4.data(101:1000))/mean(channel4.data(101:1000))

;print, subwindowsize

subwindow_size = floor(subwindow/dt)
subwindow_number = floor(size(channel1.data,/N_ELEMENTS)/subwindow_size)

print, subwindow_number

;asdf = randomn(seed,size(channel1.data,/N_ELEMENTS))
;reform_channel2 = reform(asdf(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])

reform_channel1 = reform(channel1.data(1:subwindow_number*subwindow_size)/mean(channel1.data(1:subwindow_number*subwindow_size)),[subwindow_size,subwindow_number])
reform_channel2 = reform(channel2.data(1:subwindow_number*subwindow_size)/mean(channel2.data(1:subwindow_number*subwindow_size)),[subwindow_size,subwindow_number])
reform_channel3 = reform(channel3.data(1:subwindow_number*subwindow_size)/mean(channel3.data(1:subwindow_number*subwindow_size)),[subwindow_size,subwindow_number])
reform_channel4 = reform(channel4.data(1:subwindow_number*subwindow_size)/mean(channel4.data(1:subwindow_number*subwindow_size)),[subwindow_size,subwindow_number])

;reform_channel1 = reform(JW_BANDPASS(channel1.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])
;reform_channel2 = reform(JW_BANDPASS(channel2.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])
;reform_channel3 = reform(JW_BANDPASS(channel3.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])
;reform_channel4 = reform(JW_BANDPASS(channel4.data(1:subwindow_number*subwindow_size), 0.0, 0.8 , BUTTERWORTH=100.0),[subwindow_size,subwindow_number])

;result = dblarr(subwindow_size,subwindow_number)
for i = 0L, subwindow_number-1 do begin
  reform_channel1(*,i) = JW_BANDPASS(reform_channel1(*,i), freq_filter[0], freq_filter[1] , BUTTERWORTH=50.0)
  reform_channel2(*,i) = JW_BANDPASS(reform_channel2(*,i), freq_filter[0], freq_filter[1] , BUTTERWORTH=50.0)
  reform_channel3(*,i) = JW_BANDPASS(reform_channel3(*,i), freq_filter[0], freq_filter[1] , BUTTERWORTH=50.0)
  reform_channel4(*,i) = JW_BANDPASS(reform_channel4(*,i), freq_filter[0], freq_filter[1] , BUTTERWORTH=50.0)
endfor


;reform_channel1 = JW_BANDPASS(reform_channel1, 0.2, 1 , BUTTERWORTH=100)
;reform_channel2 = JW_BANDPASS(reform_channel2, 0.2, 1 , BUTTERWORTH=100)
;reform_channel3 = JW_BANDPASS(reform_channel3, 0.2, 1 , BUTTERWORTH=100)
;reform_channel4 = JW_BANDPASS(reform_channel4, 0.2, 1 , BUTTERWORTH=100)


xcorr_lag = [-(subwindow_size-1):subwindow_size-1:1]
correlation11 = dblarr(subwindow_number,subwindow_size*2-1)
correlation12 = dblarr(subwindow_number,subwindow_size*2-1)
correlation13 = dblarr(subwindow_number,subwindow_size*2-1)
correlation14 = dblarr(subwindow_number,subwindow_size*2-1)

for i = 0L, subwindow_number-1 do begin
  correlation11(i,*) = yc_correlate(reform_channel1(*,i),reform_channel1(*,i),xcorr_lag)
  correlation12(i,*) = yc_correlate(reform_channel1(*,i),reform_channel2(*,i),xcorr_lag)
  correlation13(i,*) = yc_correlate(reform_channel1(*,i),reform_channel3(*,i),xcorr_lag)
  correlation14(i,*) = yc_correlate(reform_channel1(*,i),reform_channel4(*,i),xcorr_lag)
endfor

corr_value = dblarr(4,subwindow_number)

fit_points = [where((xcorr_lag LT -1)*(xcorr_lag GT -5)), where((xcorr_lag GT 1)*(xcorr_lag LT 5)) ]

for i = 0L, subwindow_number-1 do begin
  corr_fit = jw_quad_fit(xcorr_lag[fit_points],correlation11[i,fit_points] )
  corr_value[0,i] = corr_fit[2]
  envelope02 = sqrt((hilbert(correlation12[i,*]))^2.0 + correlation12[i,*]^2.0)
  corr_value[1,i] = envelope02[where(xcorr_lag EQ 0)]
  envelope03 = sqrt((hilbert(correlation13[i,*]))^2.0 + correlation13[i,*]^2.0)
  corr_value[2,i] = envelope03[where(xcorr_lag EQ 0)]
  envelope04 = sqrt((hilbert(correlation14[i,*]))^2.0 + correlation14[i,*]^2.0)
  corr_value[3,i] = envelope04[where(xcorr_lag EQ 0)]
endfor

ycplot,[0:3:1] ,[mean(corr_value[0,*]), mean(corr_value[1,*]), mean(corr_value[2,*]), mean(corr_value[3,*])], error=[stddev(corr_value[0,*])/sqrt(subwindow_number), stddev(corr_value[1,*])/sqrt(subwindow_number), stddev(corr_value[2,*])/sqrt(subwindow_number), stddev(corr_value[3,*])/sqrt(subwindow_number)]


corr_avg13 = total(correlation13,1)/subwindow_number
;ycplot, xcorr_lag,corr_avg13

corr_avg11 = total(correlation11,1)/subwindow_number
ycplot, xcorr_lag,corr_avg11

ycplot, xcorr_lag*dt, total(correlation11,1)/subwindow_number
ycplot, xcorr_lag*dt, total(correlation12,1)/subwindow_number
ycplot, xcorr_lag*dt, total(correlation13,1)/subwindow_number
ycplot, xcorr_lag*dt, total(correlation14,1)/subwindow_number

;stop

mean_xcorr01 = total(correlation11,1)/subwindow_number
mean_xcorr02 = total(correlation12,1)/subwindow_number
mean_xcorr03 = total(correlation13,1)/subwindow_number
mean_xcorr04 = total(correlation14,1)/subwindow_number

;stop

ycplot, xcorr_lag*dt*1e6, mean_xcorr01, out_base_id = oid
envelope01 = sqrt((hilbert(mean_xcorr01))^2.0 + mean_xcorr01^2.0)
ycplot, xcorr_lag*dt*1e6, envelope01, oplot_id = oid

;corr_fit = jw_quad_fit(xcorr_lag([where((xcorr_lag LT -1)*(xcorr_lag GT -5)), where((xcorr_lag GT 1)*(xcorr_lag LT 5)) ]),mean_xcorr01([where((xcorr_lag LT -1)*(xcorr_lag GT -5)), where((xcorr_lag GT 1)*(xcorr_lag LT 5)) ]) )
;fitted = asdf[0]*(xcorr_lag([where((xcorr_lag GT -5)*(xcorr_lag LT 5))])-asdf[1])^2+asdf[2]
;ycplot, xcorr_lag, mean_xcorr01, out_base_id = oid
;ycplot, xcorr_lag([where((xcorr_lag GT -5)*(xcorr_lag LT 5))]), fitted, oplot_id = oid
;ycplot, xcorr_lag*dt*1e6, mean_xcorr02, oplot_id = oid

ycplot, xcorr_lag*dt*1e6, mean_xcorr02, out_base_id = oid
envelope02 = sqrt((hilbert(mean_xcorr02))^2.0 + mean_xcorr02^2.0)
ycplot, xcorr_lag*dt*1e6, envelope02, oplot_id = oid

ycplot, xcorr_lag*dt*1e6, mean_xcorr03, out_base_id = oid
envelope03 = sqrt((hilbert(mean_xcorr03))^2.0 + mean_xcorr03^2.0)
ycplot, xcorr_lag*dt*1e6, envelope03, oplot_id = oid

ycplot, xcorr_lag*dt*1e6, mean_xcorr04, out_base_id = oid
envelope04 = sqrt((hilbert(mean_xcorr04))^2.0 + mean_xcorr04^2.0)
ycplot, xcorr_lag*dt*1e6, envelope04, oplot_id = oid


end