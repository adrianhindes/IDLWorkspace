PRO CAL_LI_CHANNELS,shotNo,TIMERANGE=timerange,bshotNo,BTIMERANGE=btimerange,	$
			TEST=test,CHANNELS=channels


; ********************** cal_textor.pro **************** 10.10.2000 ******
;                                            S. Zoletnik   KFKI-RMKI
; shotNo: shot into gas
; bshotNo: background shot (no Li-beam)
; timerange: timerange for processing [start,end] sec
; btimerange: timerange for background signal processing [start,end] sec
; /test: use test shot (data_source=9) otherwise use data_source=7
; channels: channels to use
; /add: add calibration for some channels
; 
; Calibration data is saved in cal/textor.cal as 3 column ASCII file:
;          channel baseline cal-factor(multiplier for signal)
;
; **********************************************************************


DEFAULT,test,0
DEFAULT,channels,[1,2,3,4,5,6]
DEFAULT,calfile,DIR_F_NAME('cal','Li'+I2STR(shotNo)+'.cal')
DEFAULT,noise_tau,1.667E-3						; [s]

IF (KEYWORD_SET(test)) THEN BEGIN
  data_source = 9
  DEFAULT,shot,2216
  DEFAULT,bshot,2217
  DEFAULT,timerange,[0,0.1]
  DEFAULT,btimerange,timerange
ENDIF ELSE data_source = 7

n_ch = N_ELEMENTS(channels)
caldata = FLTARR(3,n_ch)

ch = 0
GET_RAWSIGNAL,shotNo,channels(ch),time,ch_data,DATA_SOURCE=data_source,$
    /NOCALIBRATE,TRANGE=timerange,SAMPLETIME=dt
n_point = N_ELEMENTS(time) & data = FLTARR(n_ch,n_point) & sum_data = FLTARR(n_point)
data(ch,*) = ch_data
sum_data = sum_data+ch_data
FOR ch=1,n_ch-1 DO BEGIN
  GET_RAWSIGNAL,shotNo,channels(ch),time,ch_data,DATA_SOURCE=data_source,$
    /NOCALIBRATE,TRANGE=timerange,SAMPLETIME=dt
  data(ch,*) = ch_data
  sum_data = sum_data+ch_data
ENDFOR

n_noise = 2*CEIL(noise_tau/dt/2.)+1

FIND_CHOPPER_TIMING,time,sum_data,TIMERANGE=timerange,n_period,period,up_shift
cut_n = 3 & win_n = ROUND(period)/2-(2*cut_n-1)

time1 = time(up_shift) & time2 = time(up_shift+FLOOR(period*5))
WINDOW,0
PLOT,time,SMOOTH(sum_data,n_noise),XRANGE=[time1,time2],/XSTYLE
STOP

FOR ch=0,n_ch-1 DO BEGIN
  PRINT,'Processing channel '+I2STR(channels(ch))
  caldata(0,ch) = channels(ch)
;  caldata(1,ch) = total(db)/n_elements(db)
  ch_data = data(ch,*) & ch_data = ch_data(0:n_point-1)
  up_sum = 0 & down_sum = 0
  win_start0 = up_shift+cut_n & win_end = win_start0+win_n-1
  up_sum = up_sum+TOTAL(ch_data(win_start0:win_end))
  IF up_shift GE cut_n THEN BEGIN
    win_end0 = win_start0-2*cut_n
    IF win_end0 GE win_n-1 THEN BEGIN
      win_start = win_end0-win_n+1
      down_sum = down_sum+TOTAL(ch_data(win_start:win_end0))
    ENDIF ELSE BEGIN
      down_sum = down_sum+TOTAL(ch_data(0:win_end0))
      win_start = up_shift+FLOOR(n_period*period+0.5)-cut_n-win_n+1
      win_end = win_start+win_n-win_end0-1
      down_sum = down_sum+TOTAL(ch_data(win_start:win_end))
    ENDELSE
  ENDIF ELSE BEGIN
    win_end = up_shift+FLOOR(n_period*period+0.5)-cut_n & win_end = win_end-win_n+1
    down_sum = down_sum+TOTAL(ch_data(win_start:win_end))
  ENDELSE
  FOR j=2,n_period DO BEGIN
    win_end = up_shift+FLOOR((j-1)*period+0.5)-cut_n & win_start = win_end-win_n+1
    down_sum = down_sum+TOTAL(ch_data(win_start:win_end))
    win_start = win_end+2*cut_n & win_end = win_start+win_n-1
    up_sum = up_sum+TOTAL(ch_data(win_start:win_end))
  ENDFOR
  sig_sum = up_sum-down_sum
  caldata(2,ch) = 1./sig_sum
  PLOT,time,SMOOTH(ch_data,n_noise)/sig_sum,XRANGE=[time1,time2],/XSTYLE
  STOP
ENDFOR
caldata(2,*) = caldata(2,*)/MAX(caldata(2,*))
PRINT,caldata(2,*)

STOP

openw,unit,calfile,/get_lun
for i=0,n_channels-1 do begin
  if (caldata(0,i) gt 0) then begin
    printf,unit,caldata(0,i),caldata(1,i),caldata(2,i)
  endif
endfor
close,unit & free_lun,unit

RETURN
END
    






