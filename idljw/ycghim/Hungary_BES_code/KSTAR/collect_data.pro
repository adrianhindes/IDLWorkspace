pro collect_data,ADC_mult=ADC_mult,ADC_div=ADC_div,samplediv=samplediv,meastime=meastime,$
    bits=bits,trigger=trigger,samplenumber_out=samplecount,channel_masks=channel_masks,status=status,$
    sampletime=sampletime,errormess=errormess,nowait=nowait
; INPUT:
;  trigger: trigger time in sec. <0 means immediate, >=0 external trigger relative to Ip start
;  meastime: Measurementtime in sec.
;  ADC_mult, ADC_div: ADC PLL parameters
;  samplediv: Sample frequency divider for resampling
;  bits: ADC resolution
;  channel_masks: Array of four integers with bit mask for 4x8 channels. 1 enables.
;  /nowait: Do nto wait for data, return immediately after starting measuremant

; OUTPUT:
;   samplenumber_out: The measured sample number
;   sampletime: The sampling period time
;   status: 1: Measurement finished
;           0: Measurement not finished (aborted)
  errormess = ''
  default,ADC_mult,20
  default,ADC_div,40
  default,stream_div,10
  default,stream_mult,30
  default,samplediv,5
  default,meastime,5
  default,bits,12
  default,channel_masks,[255,255,255,255]
  default,trigger,-1  ; If <0 then manual start, otherwise delay

  status = 0

  nch = 0
  for chi = 0,3 do begin
    mask = 1
    val = intarr(8)
    for i=0,7 do begin
      if ((channel_masks[chi] and mask) ne 0) then begin
        nch = nch+1
      endif
      mask = ishft(mask,1)
    endfor
  endfor

  adclk = 20.0*ADC_mult/ADC_div
  sclk = adclk/samplediv
  sampletime = 1./(sclk*1e6)

  baseclock_period = 1./20E6; 20 MHz internal clock

  samplecount = long(meastime/sampletime)
  ;widget_control,message_widget,set_value='Starting measurement program'

  openw,unit,'data\apd_idl_meas.txt',/get_lun,error=error
  if (error ne 0) then begin
    for i=0,30 do begin
      wait,1
      openw,unit,'data\apd_idl_meas.txt',/get_lun,error=error
      if (error eq 0) then break
    endfor
  endif
  if (error ne 0) then begin
    errormess = 'Error writing measurement control file'
    return
  endif
  printf,unit,'Open 10.123.13.101'
  printf,unit,'SetTiming '+i2str(ADC_mult)+' '+i2str(ADC_div)+' '+' '+i2str(stream_mult)+' '+i2str(stream_div)
  printf,unit,'Sampling '+i2str(samplediv)+' 0'
  alldata = long(samplecount)*nch*2
  primbuf = float(alldata) /10
  if (primbuf lt 4e6) then  primbuf = 4e6
  printf,unit,'Allocate '+i2str(samplecount)+' '+i2str(bits)+' '+i2str(channel_masks[0])+' '+i2str(channel_masks[1])+$
      ' '+i2str(channel_masks[2])+' '+i2str(channel_masks[3])+' '+i2str(primbuf/float(alldata)*100 > 5)
  printf,unit,'Arm 0 '+i2str(samplecount)+' 0'
  if (trigger ge 0) then begin
    ; For triggered operation
    printf,unit,'Trigger 1 0 0 '+i2str(long(float(trigger)/baseclock_period))+' TriggerDesc.txt'
    printf,unit,'Start'
    printf,unit,'Wait 10000000'
  endif else begin
    ; For non-triggered mode
    printf,unit,'Trigger 0 0 0 0 TriggerDesc.txt'
    printf,unit,'Start'
    printf,unit,'Wait '+i2str(sampletime*samplecount*1000+1000)
  endelse
  printf,unit,'Save'
  printf,unit,'Close'
  close,unit & free_lun,unit
  cmd = 'cd data & del /f Channel*.dat & APDtest.exe apd_idl_meas.txt'
  spawn,cmd,/nowait,/hide
  if (not keyword_set(nowait)) then begin
    wait,2
    while 1 do begin
      ; Check for data file
      spawn,'dir data\Channel*.dat',res,err
      if (err eq '') then begin
      ; Data is available
        ;wait 2 seconds to ensure all data are written
        wait,2
        status = 1
        break
      endif
      wait,1
    endwhile
  endif else begin ; wait
    status = 1
  endelse
end  ; collect_data

