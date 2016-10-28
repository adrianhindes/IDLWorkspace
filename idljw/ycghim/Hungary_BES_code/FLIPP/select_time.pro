PRO SELECT_TIME,shot,channel_in,TRANGE=trange,TIMERANGE=timerange,NOCALIBRATE=nocalibrate,   $
    DATA_SOURCE=data_source,AFS=afs,ERRORPROC=errorproc,         $
    AUTO_CHOPPER=auto_chopper,NOSELECT=noselect,          $
    FILE=fn,ON_NAME=on_name,OFF_NAME=off_name,INTTIME=inttime,NOPLOT=noplot,    $
    MIN_ON_TIME=min_on_time,MIN_OFF_TIME=min_off_time,          $
    ON_DELAY_1=on_delay1,ON_DELAY_2=on_delay2,          $
    OFF_DELAY_1=off_delay1,OFF_DELAY_2=off_delay2,$
    on_times=on_times,off_times=off_times,nofile=nofile,$
    DATA_ARRAY=rawdata,TIME_ARRAY=time,sampletime=sampletime,$
    ERRORMESS=errormess, silent=silent, DATAPATH=datapath, LEVEL=level, noquery=noquery


; ****************** select_time.pro ****************** S. Zoletnik ************
;
; Selects a set of time intervals for processing fluctuation data
; Two basic modes of operation are available. If /auto_chopper is not set than
; all intervals are selected using the mouse, otherwise a set of chopper-on and
; chopper-off time intervals will be selected automatically. In this latter case
; two timefiles are written.
; All timefiles are written to directory time/
;
; INPUT
;   shot:    shot number
;   channel_in:     channel number (or name) for plotting data and
;      finding chopper on-off times
;   trange or timerange:        initial time range
;   /nocalibrate:   do not use calibrated signal
;   data_source:    see zztcorr.pro
;   /afs:    get data from afs
;   errorproc:      name of error procedure
;   /auto_chopper:  automatically find beam on/off time intervals
;   /noselect:      do not select time interval within trange, use all
;      trange for finding chopper intervals automatically
;   fn:        name of the written timefiles
;   on_name:      name of beam-on timefile
;   off_name:    name of beam-off timefile
;   inttime:      integration time in microsec for plotting signal
;   /noplot:      do not plot time intervals (after selecting them)
;   min_on_time:    minimum length of beam-on time intervals  [ms]
;   min_off_time:   minimum length of beam-on time intervals  [ms]
;   on_delay_1:     delay for starting beam-on time interval after beam-on  [ms]
;   on_delay_2:     time from end of beam-on time interval before beam-off  [ms]
;   off_delay_1, ..._2: see above   [ms]
;   /nofile:            Do not write output file, just select intervals and return in
;                       on_times=...off_times=
;   data_array:         The vector to use
;   time_array:          The time vector to use
;   sampletime:         Sampling time of data in xxx_arr (sec)
;   /silent:            Do not print error message.
;   datapath:       Directory with the data (see get_rawsignal.pro)
;   level:          The cut level between beam-on and beam-off times (default: (min+max)/2)
; OUTPUT
;   on_times: returns the intervals selected for on times [t1,t2,t1,t2...]
;   off_times: returns the off times [t1,t2,t1,t2...]
;   errormess: error message or ''
;*******************************************************************************


if (defined(timerange) and not defined(trange)) then trange=timerange

default,datapath,local_default('datapath')

fn = ''
IF (KEYWORD_SET(auto_chopper)) THEN BEGIN
  DEFAULT,min_on_time,4.                 ; ms
  DEFAULT,min_off_time,4.               ; ms
  d = local_default('select_time/off_delay_1',/silent)
  if (d ne '') then default,off_delay1,float(d) else DEFAULT,off_delay1,0.3 ; ms
  d = local_default('select_time/off_delay_2',/silent)
  if (d ne '') then default,off_delay2,float(d) else DEFAULT,off_delay2,0.3 ; ms
  d = local_default('select_time/on_delay_1',/silent)
  if (d ne '') then default,on_delay1,float(d) else DEFAULT,on_delay1,0.3   ; ms
  d = local_default('select_time/on_delay_2',/silent)
  if (d ne '') then default,on_delay2,float(d) else DEFAULT,on_delay2,0.3   ; ms
ENDIF


if (not keyword_set(rawdata) or not keyword_set(time)) then begin
  if (not defined(channel_in)) then begin
    def = DEFCHANNELS(shot,DATA_SOURCE=data_source)
    channel_in = def[CLOSEIND(def,15)]
  endif

  IF ((SIZE(channel_in))(1) NE 7) THEN channel = 'Li-'+I2STR(channel_in)       $
          ELSE channel = channel_in
  IF (STRMID(channel,0,3) EQ 'Li-') THEN                 $
    IF (data_source EQ 3) OR (data_source EQ 5)           $
     THEN DEFAULT,inttime,0.3 ELSE DEFAULT,inttime,0.03   $
       ELSE DEFAULT,inttime,0.             ; ms

  ; This is some old W7-AS stuff
  IF (channel EQ 'W00') THEN READ_W00,shot,time,rawdata          $
  ELSE GET_RAWSIGNAL,shot,channel,time,rawdata,SAMPLETIME=sampletime,     $
      TRANGE=trange,DATA_NAMES=data_names,NOCALIBRATE=nocalibrate,   $
      DATA_SOURCE=data_source,AFS=afs,ERRORMESS=errormess,DATAPATH=datapath
  if (errormess ne '') then begin
    print,errormess
    return
  endif
endif


time_min = MIN(time,MAX=time_max) & DEFAULT,trange,[time_min,time_max]
trange = trange & sampletime = sampletime


nsum = ROUND(inttime/(sampletime/1e-6))
if ((nsum mod 2) ne 1) then nsum = nsum+1
if (nsum gt 1) then begin
  data = SMOOTH(rawdata,nsum)
  ind = lindgen(long(n_elements(data)/nsum)-1)*nsum+fix(nsum/2)
  data = data[ind]
  time = time[ind]
endif else begin
  data = rawdata
endelse
data_min = MIN(data,MAX=data_max)
default,yrange,[data_min,data_max]

IF (NOT KEYWORD_SET(auto_chopper)) THEN BEGIN          ; manual

  IF KEYWORD_SET(noselect) THEN PRINT,'The /noselect switch has only effect '+  $
              'when /autochopper is set, too'

  PLOT,time,data,                $
    TITLE=I2STR(shot)+'  '+channel+'('+data_names(data_source)+')',       $
    XTITLE='Time [s]',XRANGE=trange,XSTYLE=1,          $
    YRANGE=yrange,YSTYLE=1

  intn = 0 & stop = 0 & t1 = 0 & t2 = trange(0)
  WHILE (stop EQ 0) DO BEGIN
    ok = 0
    WHILE (NOT ok) DO BEGIN
      PRINT,'Click at the beginning of the time interval '+I2STR(intn+1)+   $
           ' with the LEFT mouse button.'
      PRINT,'Click the RIGHT mouse button IF you wish no more intervals.'
      x1 = -1000 & y1 = 0 & DIGXY,x1,y1,/DATA      ; <-- start time
      IF (x1 NE -1000) THEN BEGIN          ; <-- new interval
        IF (x1 LT t2(intn)) THEN x1 = t2(intn)
        IF (x1 LT trange(1)) THEN BEGIN
          PRINT,'Click at end of the time interval '+I2STR(intn+1)+     $
            ' with the LEFT mouse button.'
      x2 = -1000 & y2 = 0 & DIGXY,x2,y2,/DATA   ; <-- end time
      IF (x2 NE -1000) THEN BEGIN
        IF (x2 GT trange(1)) THEN x2 = trange(1)
        IF (x2 GT x1) THEN BEGIN
          PRINT,'***** Interval #'+I2STR(intn+1)+' :['+         $
          STRING(x1,FORMAT='(F8.3)')+' -'+STRING(x2,FORMAT='(F8.3)')+' ms]'
            if not keyword_set(noquery) then a=ASK('Is it OK?') else a=1
            IF a THEN BEGIN
              t1 = [t1,x1] & t2 = [t2,x2]
              intn = intn+1 & ok = 1
              OPLOT,[t1(intn),t1(intn)],yrange,THICK=2,LINE=2
              OPLOT,[t2(intn),t2(intn)],yrange,THICK=2,LINE=2
              wait,0.5
            ENDIF
        ENDIF ELSE PRINT,'!!!!!!!!!! Bad end time !!!!!!!!!!'  ; x2 < x1
          ENDIF
        ENDIF ELSE PRINT,'!!!!!!!!!! Bad start time !!!!!!!!!!' ; x1 > trange(1)
      ENDIF ELSE BEGIN
        ok = 1 & stop = 1          ; <-- no more intervals
      ENDELSE
    ENDWHILE                   ; --> ok=1
  ENDWHILE                 ; --> stop=1

  t1 = t1 & t2 = t2

  IF (intn EQ 0) THEN BEGIN
    PRINT,'No intervals selected!'
    RETURN
  ENDIF
ind = lindgen(n_elements(t1)-1)*2
on_times = fltarr((n_elements(t1)-1)*2)
on_times[ind] = t1[1:n_elements(t1)-1]
on_times[ind+1] = t2[1:n_elements(t1)-1]

if (not keyword_set(nofile)) then begin
  IF (NOT KEYWORD_SET(on_name)) THEN BEGIN
    IF ((data_source EQ 3) OR (data_source EQ 5))             $
    THEN fn = 'AUG_'+I2STR(shot,digits=5)+'on.time'          $
    ELSE fn = I2STR(shot)+'on.time'
    PRINT,'Enter name of timefile (in directory time/) ['+fn+']:'
    txt='' & READ,txt
    IF (txt NE '') THEN fn = txt
  ENDIF ELSE BEGIN
    fn = on_name
  ENDELSE

  OPENW,unit,'time/'+fn,/get_lun
  FOR i=1,intn DO PRINTF,unit,t1(i),t2(i)
  CLOSE,unit & FREE_LUN,unit
  PRINT,'File time/'+fn+' is written.'
endif
ENDIF ELSE BEGIN                 ; auto_chopper

  IF (NOT KEYWORD_SET(noselect)) THEN BEGIN     ; selecting t1 and t2


    PLOT,time,data,                  $
    TITLE=I2STR(shot)+'  '+channel+'('+data_names(data_source)+')',       $
    XTITLE='Time [s]',XRANGE=trange,XSTYLE=1,          $
    YRANGE=yrange,YSTYLE=1

    ok = 0
    WHILE (NOT ok) DO BEGIN
      PRINT,'Click at the beginning of the time interval to process'+     $
         ' with the LEFT mouse button.'
      x1 = -1000 & y1 = 0 & DIGXY,x1,y1,/data      ; <-- start time
      IF (x1 NE -1000) THEN BEGIN
        IF (x1 LT trange(0)) THEN x1 = trange(0)
        IF (x1 LT trange(1)) THEN BEGIN
          PRINT,'Click at end of the time interval to process'+        $
            ' with the LEFT mouse button.'
          x2 = -1000 & y2 = 0 & DIGXY,x2,y2,/data     ; <-- end time
          IF (x2 NE -1000) THEN BEGIN
        IF (x2 GT trange(1)) THEN x2 = trange(1)
            IF (x2 GT x1) THEN BEGIN
              PRINT,'Interval selected: ['+           $
                STRING(x1,FORMAT='(F8.3)')+' -'+STRING(x2,FORMAT='(F8.3)')+' ms]'
              if not keyword_set(noquery) then a=ASK('Is it OK?') else a=1
              IF (a) THEN BEGIN
                t1 = x1 & t2 = x2 & ok = 1
            OPLOT,[t1,t1],yrange,THICK=2,LINE=2
            OPLOT,[t2,t2],yrange,THICK=2,LINE=2
                wait,0.5
              ENDIF
            ENDIF ELSE PRINT,'!!!!!!!!!! Bad end time !!!!!!!!!!'   ; x2 < x1
          ENDIF
        ENDIF ELSE PRINT,'!!!!!!!!!! Bad start time !!!!!!!!!!' ; x1 > trange(1)
      ENDIF ELSE BEGIN
        if (x1 eq -1000) then return
        break
      ENDELSE
    ENDWHILE                   ; --> ok=1
  ENDIF ELSE BEGIN
    t1 = trange(0) & t2 = trange(1)
  ENDELSE

  IF (NOT KEYWORD_SET(noselect)) THEN BEGIN
    if (x1 eq -1000) then return
  ENDIF

  index = WHERE(time GT (t1 > time_min) AND time LT (t2 < time_max))
  time = time(index) & data = data(index) & n = N_ELEMENTS(index)
  maxd = MAX(data,MIN=mind)
  default,level,(maxd+mind)/2.
  on_off = (data GT level)

  i1 = 0L
  WHILE (i1 LT n-1) DO BEGIN
    act_on_off = on_off(i1)
    inverse_index = WHERE(on_off(i1:n-1) NE act_on_off)
    IF (inverse_index(0) GE 0) THEN i2 = inverse_index(0)+i1-1 ELSE i2 = n-1
    interval = time(i2)-time(i1)
    IF ((act_on_off EQ 0) AND (interval GT min_off_time*1e-3)) THEN BEGIN
      ti1 = (time(i1)+off_delay1*1e-3)
      ti2 = (time(i2)-off_delay2*1e-3)
      IF (NOT DEFINED(off_times_1)) THEN BEGIN
        off_times_1 = ti1
        off_times_2 = ti2
      ENDIF ELSE BEGIN
        off_times_1 = [off_times_1,ti1]
        off_times_2 = [off_times_2,ti2]
      ENDELSE
    ENDIF
    IF ((act_on_off EQ 1) AND (interval GT min_on_time*1e-3)) THEN BEGIN
      ti1 = (time(i1)+on_delay1*1E-3)
      ti2 = (time(i2)-on_delay2*1E-3)
      IF (NOT DEFINED(on_times_1)) THEN BEGIN
        on_times_1 = ti1
        on_times_2 = ti2
      ENDIF ELSE BEGIN
        on_times_1 = [on_times_1,ti1]
        on_times_2 = [on_times_2,ti2]
      ENDELSE
    ENDIF
    i1 = i2+1
  ENDWHILE

  IF (NOT DEFINED(on_times_1)) THEN BEGIN
    errormess = 'No on times found!  No timefiles are written.'
    if (not keyword_set(silent)) then PRINT,errormess
    RETURN
  ENDIF
  IF (NOT DEFINED(off_times_1)) THEN BEGIN
    errormess = 'No off times found!  No timefiles are written.'
    if (not keyword_set(silent)) then PRINT,errormess
    RETURN
  ENDIF
  PRINT,I2STR(N_ELEMENTS(on_times_1))+' beam-on and '+          $
    I2STR(N_ELEMENTS(off_times_1))+' beam-off time intervals are found.'
  ind = lindgen(n_elements(on_times_1))*2
  on_times = fltarr(n_elements(on_times_1)*2)
  on_times[ind] = on_times_1
  on_times[ind+1] = on_times_2
  ind = lindgen(n_elements(off_times_1))*2
  off_times = fltarr(n_elements(off_times_1)*2)
  off_times[ind] = off_times_1
  off_times[ind+1] = off_times_2

  if (not keyword_set(nofile)) then begin
  IF (NOT KEYWORD_SET(on_name)) THEN BEGIN
    IF (data_source EQ 3) OR (data_source EQ 5)           $
    THEN def_on_name='AUG_'+I2STR(shot,digits=5)+'on.time'        $
    ELSE def_on_name=I2STR(shot,digits=5)+'on.time'
    PRINT,'Enter beam-on timefile name ['+def_on_name+']:'
    on_name = ''
    READ,on_name
    IF (on_name EQ '') THEN on_name = def_on_name
  ENDIF

  OPENW,unit,'time/'+on_name,/get_lun
  intn = N_ELEMENTS(on_times_1)
  FOR i=0,intn-1 DO PRINTF,unit,on_times_1(i),on_times_2(i)
  CLOSE,unit & FREE_LUN,unit
  PRINT,'File time/'+on_name+' is written.'

  IF (NOT KEYWORD_SET(off_name)) THEN BEGIN
    IF (data_source EQ 3) OR (data_source EQ 5)           $
    THEN def_off_name = 'AUG_'+I2STR(shot,digits=5)+'off.time'     $
    ELSE def_off_name = I2STR(shot,digits=5)+'off.time'
    PRINT,'Enter beam-off timefile name ['+def_off_name+']:'
    off_name = ''
    READ,off_name
    IF (off_name EQ '') THEN off_name = def_off_name
  ENDIF
  OPENW,unit,'time/'+off_name,/GET_LUN
  intn = N_ELEMENTS(off_times_1)
  FOR i=0,intn-1 DO PRINTF,unit,off_times_1(i),off_times_2(i)
  CLOSE,unit & FREE_LUN,unit
  PRINT,'File time/'+off_name+' is written.'

  IF (NOT KEYWORD_SET(noplot)) THEN               $
    SHOW_TIMES,shot,channel,TIMEFILES=[on_name,off_name],   $
       NOCALIBRATE=nocalibrate,DATA_SOURCE=data_source,AFS=afs
  endif
ENDELSE

RETURN
END

