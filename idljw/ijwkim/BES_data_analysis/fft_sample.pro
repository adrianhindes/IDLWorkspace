pro fft_sample


  dt = 5e-07
  life_time = 15e-06
  subwindow = life_time*500

  ;shot_number= 9127, channel 4-6, 3-6, 2-6 ,1-6, time: 3.4-3.8sec
  shot_number = 9127
  time_start = 3.0
  time_end = 3.8

  channel_number1 = '1-6'
  channel_number2 = '2-6'
  channel_number3 = '3-6'
  channel_number4 = '4-6'

;  sample1 = bes_read_data(shot_number, channel_number1, trange=[0, 5])
;  sample2 = bes_read_data(shot_number, channel_number2, trange=[0, 5])
;  sample3 = bes_read_data(shot_number, channel_number3, trange=[0, 5])
;  sample4 = bes_read_data(shot_number, channel_number4, trange=[0, 5])
;  ycplot,sample1.tvector,sample1.data
;  ycplot,sample2.tvector,sample2.data
;  ycplot,sample3.tvector,sample3.data
;  ycplot,sample4.tvector,sample4.data

  channel1 = bes_read_data(shot_number, channel_number1, trange=[time_start, time_end])

  channel2 = bes_read_data(shot_number, channel_number2, trange=[time_start, time_end])

  channel3 = bes_read_data(shot_number, channel_number3, trange=[time_start, time_end])

  channel4 = bes_read_data(shot_number, channel_number4, trange=[time_start, time_end])

  ycplot,channel1.tvector,channel1.data
  ycplot,channel2.tvector,channel2.data
  ycplot,channel3.tvector,channel3.data
  ycplot,channel4.tvector,channel4.data

  print, variance(channel1.data(101:1000))/mean(channel1.data(101:1000))
  print, variance(channel2.data(101:1000))/mean(channel2.data(101:1000))
  print, variance(channel3.data(101:1000))/mean(channel3.data(101:1000))
  print, variance(channel4.data(101:1000))/mean(channel4.data(101:1000))

  ;print, subwindowsize

  subwindow_size = floor(subwindow/dt)
  subwindow_number = floor(size(channel1.data,/N_ELEMENTS)/subwindow_size)

  print, subwindow_number
;JW_BANDPASS(channel1.data(1:subwindow_number*subwindow_size), 0.5, 1 , BUTTERWORTH=100.0)
  reform_channel1 = reform(channel1.data(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])
  reform_channel2 = reform(channel2.data(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])
  reform_channel3 = reform(channel3.data(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])
  reform_channel4 = reform(channel4.data(1:subwindow_number*subwindow_size),[subwindow_size,subwindow_number])

fft_channel1 = abs(fft(reform_channel1,-1))
  
  data_size = size(reform_channel1) 
  T = dt
  N = data_size[1]
  X = (FINDGEN((N - 1)/2) + 1)
  is_N_even = (N MOD 2) EQ 0
  if (is_N_even) then $
    freq = [0.0, X, N/2, -N/2 + X]/(N*T) $
  else $
    freq = [0.0, X, -(N/2 + 1) + X]/(N*T)

  fft_mean = fltarr(N)
  for i = 0L, data_size[2]-1 do begin
    fft_mean = fft_mean + fft_channel1(*,i)
  endfor
  
  fft_mean = fft_mean/data_size[2]

ycplot, [-N/2+X,0.0,X,N/2]/(N*T), shift(fft_mean,-N/2-1), out_base_id = oid

freq2 = [-N/2+X,0.0,X,N/2]/(N*T)
shifted_fft = shift(fft_mean,-N/2-1)
;shifted_fft[where(abs(freq2) LT 10.0^5)] = 0

frequency_filter = (erf(0.5*10.0^(-4)*(freq2-10.0^5))+1)/2 + (-erf(0.5*10.0^(-4)*(freq2+10.0^5))+1)/2

ycplot, freq2, shifted_fft*frequency_filter

;;;; bandpass filter check
result = dblarr(data_size[1],data_size[2])
for i = 0L, data_size[2]-1 do begin
  result(*,i) = JW_BANDPASS(reform_channel1(*,i), 0.2, 0.8 , BUTTERWORTH=20.0)
endfor
;Result = BANDPASS_FILTER(reform_channel1, 0.2, 1 , BUTTERWORTH=100.0)
;result = reform_channel1

fft_2 = abs(fft(result,-1))

data_size = size(result)
T = dt
N = data_size[1]
X = (FINDGEN((N - 1)/2) + 1)
is_N_even = (N MOD 2) EQ 0
if (is_N_even) then $
  freq = [0.0, X, N/2, -N/2 + X]/(N*T) $
else $
  freq = [0.0, X, -(N/2 + 1) + X]/(N*T)

fft_mean2 = fltarr(N)
for i = 0L, data_size[2]-1 do begin
  fft_mean2 = fft_mean2 + fft_2(*,i)
endfor

fft_mean2 = fft_mean2/data_size[2]

ycplot, [-N/2+X,0.0,X,N/2]/(N*T), shift(fft_mean2,-N/2-1), oplot =oid

ycplot, [-N/2+X,0.0,X,N/2]/(N*T),  shift(fft_mean,-N/2-1)-shift(fft_mean2,-N/2-1)



;ycplot, [-N/2+X,0.0,X,N/2]/(N*T), shift(fft_channel1,-N/2-1), /ylog
;ycplot, fft_channel1-shift(shift(fft_channel1,-N/2-1),N/2+1)

stop
end
