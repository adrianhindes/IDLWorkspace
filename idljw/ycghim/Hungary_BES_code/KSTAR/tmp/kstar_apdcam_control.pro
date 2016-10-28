
pro check_errors
@apdcam_common.pro
; Reads both boards' error register and displays the values in the main control panel
; Also checks for interrupt

  if (keyword_set(offline)) then return
  ret = read_apd_register(PC_board,PC_REG_ERRORCODE,length=1,error=e)
  widget_control,apd_pc_error_widg,set_value=i2str(ret)
  ret = read_apd_register(ADC_board,ADC_REG_ERRORCODE,length=1,error=e)
  widget_control,apd_adc_error_widg,set_value=i2str(ret)

  irqCount = long(0)
;  R = CALL_EXTERNAL('CamControl.dll','idlGetPDIIrqCount', long(irqCount), /CDECL)
  apd_intcount = apd_intcount + irqCount
  widget_control,apd_intcount_widg,set_value=i2str(apd_intcount)
end  ; check_errors


pro read_apd_timing
@apdcam_common.pro

if (keyword_set(offline)) then return

widget_control,/hourglass

  ret = read_apd_register(ADC_board,ADC_REG_CONTROL,length=1,error=e)
  if (e ne '') then begin
    ret = 0
  endif
  val = intarr(8)
  mask = 1
  for i=0,7 do begin
    if ((ret and mask) ne 0) then val[i] = 1 else val[i] = 0
    mask = ishft(mask,1)
  endfor
  widget_control,apd_control_widg,set_value=val

  ret = read_apd_register(ADC_board,ADC_REG_TRIGGER,length=1,error=e)
  if (e ne '') then begin
    ret = 0
  endif
  val = intarr(3)
  mask = 1
  for i=0,2 do begin
    if ((ret and mask) ne 0) then val[i] = 1 else val[i] = 0
    mask = ishft(mask,1)
  endfor
  widget_control,apd_trigger_widg,set_value=val
  ret = read_apd_register(ADC_board,ADC_REG_ADCCLKMUL,length=4,/array,error=e)
  if (e ne '') then begin
    txt1 = 'Err'
    txt2 = 'Err'
    txt3 = 'Err'
    txt4 = 'Err'
  endif else begin
    txt1 = i2str(ret[0])
    txt2 = i2str(ret[1])
    txt3 = i2str(ret[2])
    txt4 = i2str(ret[3])
  endelse
  widget_control,apd_pllmult_widg,set_value=txt1
  widget_control,apd_plldiv_widg,set_value=txt2
  widget_control,apd_streammult_widg,set_value=txt3
  widget_control,apd_streamdiv_widg,set_value=txt4

  ret = read_apd_register(ADC_board,ADC_REG_EXTCLKMUL,length=2,/array,error=e)
  if (e ne '') then begin
    txt1 = 'Err'
    txt2 = 'Err'
  endif else begin
    txt1 = i2str(ret[0])
    txt2 = i2str(ret[1])
  endelse
  widget_control,apd_extclkmult_widg,set_value=txt1
  widget_control,apd_extclkdiv_widg,set_value=txt2

  meas_samplenum = read_apd_register(ADC_board,ADC_REG_SAMPLECNT,length=4,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(meas_samplenum)
  endelse
  widget_control,apd_samplenum_widg,set_value=txt

  val = read_apd_register(ADC_board,ADC_REG_ADSAMPLEDIV,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(val/7)
  endelse
  widget_control,apd_samplediv_widg,set_value=txt

  ret = read_apd_register(ADC_board,ADC_REG_MAXVAL11,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(ret and hex('3fff'))
  endelse
  widget_control,apd_triglevel_widg,set_value=txt
  v=intarr(2)
  if ((ret and hex('8000')) ne 0) then v[0] = 1
  if ((ret and hex('4000')) ne 0) then v[1] = 0 else v[1] = 1
  widget_control,apd_inttrig_opt_widg,set_value=v

  ret = read_apd_register(ADC_board,ADC_REG_OVDLEVEL,length=3,error=e,/array)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(ret[0]+long(ret[1] and hex('3F'))*256)
  endelse
  widget_control,apd_ovdlevel_widg,set_value=txt
  v = intarr(3)
  if ((ret[1] and hex('80')) ne 0) then v[0]= 1
  if ((ret[1] and hex('40')) ne 0) then v[1]= 1
  if ((ret[2] and hex('01')) ne 0) then v[2] = 1
  widget_control,apd_ovdstat_widg,set_value=v

  ret = read_apd_register(ADC_board,ADC_REG_OVDTIME,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(ret)
  endelse
  widget_control,apd_ovdtime_widg,set_value=txt

  ret = read_apd_register(ADC_board,ADC_REG_TRIGDELAY,length=4,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(ret)
  endelse
  widget_control,apd_trigdelay_widg,set_value=txt

  ret = read_apd_register(ADC_board,ADC_REG_RINGBUFSIZE,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(ret)
  endelse
  widget_control,apd_ringbufsize_widg,set_value=txt

  filt = read_filter()
  for i=1,5 do begin
    widget_control,apd_filtercoeff_widg[i-1],set_value=i2str(filt[i-1])
  endfor

  widget_control,apd_filtercoeff_int_widg,set_value=i2str(filt[5])

  widget_control,apd_filterdiv_widg,set_value=i2str(filt[7])

  ret = read_apd_register(ADC_board,ADC_REG_AD1TESTMODE,length=4,/array,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = i2str(ret[0])
  endelse
  ; We assume that all the test pattern registers contain the same setting.
  ; This control program writes always the same settings.
  widget_control,apd_testpattern_widg,set_value=txt

  ret = read_apd_register(ADC_board,ADC_REG_STATUS1,length=2,error=e,/array)
  v = intarr(3)
  if ((ret[0] and hex('01')) ne 0) then v[0]= 1
  if ((ret[0] and hex('02')) ne 0) then v[1]= 1
  if ((ret[1] and hex('04')) ne 0) then v[2] = 1
  widget_control,apd_clksatus_widg,set_value=v
end  ; read_apd_timing


pro read_apd_temps
@apdcam_common.pro

  if (keyword_set(offline)) then return

  widget_control,/hourglass
  ret = read_apd_register(PC_board,PC_REG_TEMP_SENSOR_1,length=32,/array,error=e)
  for i=0,15 do begin
    if ((e ne '') or (n_elements(ret) lt 32)) then begin
      txt = 'Err'
    endif else begin
      txt = string(float(ret[i*2]+ret[i*2+1]*256L)/10.,format='(F4.1)')
      apd_temps[i] = ret[i*2]+ret[i*2+1]*256L
    endelse
    widget_control,apd_temps_widg[i],set_value=txt
  endfor

  ; Calculating fan controls
  for i=0,2 do begin
    txt = string(total(float(apd_temp_weights[*,i])*apd_temps)/total(float(apd_temp_weights[*,i]))/10.,format='(F4.1)')
    widget_control,apd_fancontrol_widg[i],set_value=txt
  endfor

  ; Calculating peltier control
  txt = string(total(float(apd_temp_weights[*,3])*apd_temps)/total(float(apd_temp_weights[*,3]))/10.,format='(F4.1)')
  widget_control,apd_pelt_control_widg,set_value=txt


  ; Reading fan speeds
  ret = read_apd_register(PC_board,PC_REG_FAN1_SPEED,length=6,/array,error=e)
  for i=0,2 do begin
    if (e ne '') then begin
      txt = 'Err'
    endif else begin
      txt = i2str(ret[i*2])
    endelse
    widget_control,apd_fanspeed_widg[i],set_value=txt
  endfor

  ; Reading limits/references
  ; Fan1 set value
  ret = read_apd_register(PC_board,PC_REG_FAN1_TEMP_SET,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(ret/10.0,format='(F4.1)')
  endelse
  widget_control,apd_fanlimit_widg[0],set_value=txt

  ; Fan1 temp diff
  ret = read_apd_register(PC_board,PC_REG_FAN1_TEMP_DIFF,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(ret/10.0,format='(F4.1)')
  endelse
  widget_control,apd_fan1_diff_widg,set_value=txt

  ; Fan2 limit
  ret = read_apd_register(PC_board,PC_REG_FAN2_TEMP_LIMIT,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(ret/10.0,format='(F4.1)')
  endelse
  widget_control,apd_fanlimit_widg[1],set_value=txt

  ; Fan3 limit
  ret = read_apd_register(PC_board,PC_REG_FAN3_TEMP_LIMIT,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(ret/10.0,format='(F4.1)')
  endelse
  widget_control,apd_fanlimit_widg[2],set_value=txt

  ; Peltier set (ref) value
  ret = read_apd_register(PC_board,PC_REG_DETECTOR_TEMP_SET,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(ret/10.,format='(F4.1)')
  endelse
  widget_control,apd_pelt_ref_widg,set_value=txt

  ; Peltier output value
  ret = read_apd_register(PC_board,PC_REG_PELT_CTRL,length=2,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    if ((ret and hex('8000')) ne 0) then ret = -(32768L-(ret and hex('7fff')))
    txt = string(ret,format='(I6)')
  endelse
  widget_control,apd_pelt_out_widg,set_value=txt

  ; Peltier P Gain
  ret = read_apd_register(PC_board,PC_REG_P_GAIN,length=6,/array,error=e)
  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(float(ret[0]+ret[1]*256L)/100,format='(F6.2)')
  endelse
  widget_control,apd_pelt_pfact_widg,set_value=txt

  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(float(ret[2]+ret[3]*256L)/100,format='(F6.2)')
  endelse
  widget_control,apd_pelt_ifact_widg,set_value=txt

  if (e ne '') then begin
    txt = 'Err'
  endif else begin
    txt = string(float(ret[4]+ret[5]*256L)/100,format='(F6.2)')
  endelse
  widget_control,apd_pelt_dfact_widg,set_value=txt

end ; read_apd_temps


pro read_apd_weights
@apdcam_common.pro

  if (keyword_set(offline)) then return

  widget_control,/hourglass

  if (fanmode[0] eq 0) then begin
    ret = read_apd_register(PC_board,PC_REG_FAN1_CONTROL_WEIGHTS_1,length=32,/array,error=e)
    j = 0
    for i=0,15 do begin
      if (e ne '') then begin
        txt = 'Err'
      endif else begin
        txt = i2str(ret[i*2]+ret[i*2+1]*256L)
        apd_temp_weights[i,j] = ret[i*2]+ret[i*2+1]*256L
      endelse
      widget_control,apd_weights_widg[i,j],set_value=txt
    endfor
    ; Calculating fan controls
    txt = string(total(float(apd_temp_weights[*,j])*apd_temps)/total(float(apd_temp_weights[*,j]))/10.,format='(F4.1)')
    widget_control,apd_fancontrol_widg[j],set_value=txt
  endif

  if (fanmode[1] eq 0) then begin
    ret = read_apd_register(PC_board,PC_REG_FAN2_CONTROL_WEIGHTS_1,length=32,/array,error=e)
    j = 1
    for i=0,15 do begin
      if (e ne '') then begin
          txt = 'Err'
      endif else begin
        txt = i2str(ret[i*2]+ret[i*2+1]*256L)
        apd_temp_weights[i,j] = ret[i*2]+ret[i*2+1]*256L
      endelse
      widget_control,apd_weights_widg[i,j],set_value=txt
    endfor
    ; Calculating fan controls
    txt = string(total(float(apd_temp_weights[*,j])*apd_temps)/total(float(apd_temp_weights[*,j]))/10.,format='(F4.1)')
    widget_control,apd_fancontrol_widg[j],set_value=txt
  endif

  if (fanmode[2] eq 0) then begin
    ret = read_apd_register(PC_board,PC_REG_FAN3_CONTROL_WEIGHTS_1,length=32,/array,error=e)
    j = 2
    for i=0,15 do begin
      if (e ne '') then begin
          txt = 'Err'
      endif else begin
        txt = i2str(ret[i*2]+ret[i*2+1]*256L)
        apd_temp_weights[i,j] = ret[i*2]+ret[i*2+1]*256L
      endelse
      widget_control,apd_weights_widg[i,j],set_value=txt
    endfor
    ; Calculating fan controls
    txt = string(total(float(apd_temp_weights[*,j])*apd_temps)/total(float(apd_temp_weights[*,j]))/10.,format='(F4.1)')
    widget_control,apd_fancontrol_widg[j],set_value=txt
  endif

  ret = read_apd_register(PC_board,PC_REG_TEMP_CONTROL_WEIGHTS_1,length=32,/array,error=e)
  for i=0,15 do begin
    if (e ne '') then begin
      txt = 'Err'
    endif else begin
      txt = i2str(ret[i*2]+ret[i*2+1]*256L)
      apd_temp_weights[i,3] = ret[i*2]+ret[i*2+1]*256L
    endelse
    widget_control,apd_weights_widg[i,3],set_value=txt
  endfor

  read_apd_temps
end  ; read_apd_weight



pro read_apd_hv
@apdcam_common.pro

  if (keyword_set(offline)) then return

  widget_control,/hourglass

  ret = read_apd_register(PC_board,PC_REG_HV1MAX,length=4,/array,error=e)
  if (e ne '') then begin
    txt1 = 'Err '
    txt2 = 'Err '
  endif else begin
    txt1 = i2str((ret[0]+256*ret[1])*HV_CALFAC)
    txt2 = i2str((ret[2]+256*ret[3])*HV_CALFAC)
  endelse
  widget_control,apd_hv1max_widg,set_value=txt1
  widget_control,apd_hv2max_widg,set_value=txt2

  ret = read_apd_register(PC_board,PC_REG_HV1MON,length=4,/array,error=e)
  if (e ne '') then begin
    txt1 = 'Err '
    txt2 = 'Err '
  endif else begin
    txt1 = i2str((ret[0]+256*ret[1])*HV_CALFAC)
    txt2 = i2str((ret[2]+256*ret[3])*HV_CALFAC)
  endelse
  widget_control,apd_hv1mon_widg,set_value=txt1
  widget_control,apd_hv2mon_widg,set_value=txt2

  ret = read_apd_register(PC_board,PC_REG_HV1SET,length=4,/array,error=e)
  if (e ne '') then begin
    txt1 = 'Err '
    txt2 = 'Err '
  endif else begin
    txt1 = i2str((ret[0]+256*ret[1])*HV_CALFAC)
    txt2 = i2str((ret[2]+256*ret[3])*HV_CALFAC)
  endelse
  widget_control,apd_hv1val_widg,set_value=txt1
  widget_control,apd_hv2val_widg,set_value=txt2

  widget_control,apd_hvmess_widg,set_value=' '

  ret = read_apd_register(PC_board,PC_REG_SHMODE,length=1,error=e)
  widget_control,apd_shmode_widg,set_value=[ret]

  ret = read_apd_register(PC_board,PC_REG_CALLIGHT,length=2,error=e)
  if (e ne '') then begin
    txt1 = 'Err '
  endif else begin
    txt1 = i2str(ret)
  endelse
  widget_control,apd_callight_widg,set_value=txt1

  ret = read_apd_register(ADC_board,ADC_REG_SPAREIO,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Communication error.'
  endif else begin
    val = fix(ret)
  endelse
  widget_control,apd_spareio1_widg,set_droplist_select=val mod 2
  widget_control,apd_spareio2_widg,set_droplist_select=val/2 mod 2
end  ; read_apd_hv


pro get_apd_dac,message_widget
@apdcam_common.pro

  if (keyword_set(offline)) then return

widget_control,/hourglass

  val = read_apd_register(ADC_board,ADC_REG_DAC1,length=64,/array,error=e)
  if (e ne '') then begin
    widget_control,message_widget,set_value='Error reading DAC settings.'
    return
  endif
  for i=0,31 do begin
    widget_control,apd_dac_widg[i],set_value=i2str(long(val[i*2])+256*long(val[i*2+1]))
  endfor
  widget_control,message_widget,set_value=' '
end  ; get_apd_dac


pro set_apd_dac,message_widget
@apdcam_common.pro

  if (keyword_set(offline)) then return


widget_control,/hourglass

dac_array = bytarr(64)
for i=0,31 do begin
  widget_control,apd_dac_widg[i],get_value=tmp
  dac_array[i*2] = (long(tmp) mod 256)
  dac_array[i*2+1] = (long(tmp)/256)
endfor

for ii=0,31 do begin
  write_apd_register,ADC_board,ADC_REG_DAC1+ii*2,dac_array[ii*2:ii*2+1],/array,error=e
  wait,0.05
endfor
if (e ne '') then begin
  widget_control,message_widget,set_value='Error writing DAC settings.'
  return
endif else begin
  widget_control,message_widget,set_value='DAC values set.'
endelse
end  ; set_apd_dac

function apd_find
; Returns 1 if both cards found
@apdcam_common.pro

  if (keyword_set(offline)) then return,0


  widget_control,/hourglass

  txt = strarr(7)
  found = [0,0]
  ret = read_apd_register(ADC_board,0,length=7,/array,error=e)
  if (e ne '') then begin
    txt[0] = 'Comminucation error (ADC).'
  endif else begin
    if (ishft(ret[0],-5) ne 1) then begin
      txt[0] = 'No ADC board present.'
    endif else begin
      txt[0] = 'ADC:'
      txt[1] = '  S/N:'+ i2str(ret[3]+256L*ret[4])
      txt[2] = '  MC Ver:'+ i2str(ret[2])+'.'+i2str(ret[1])
      txt[3] = '  FPGA Ver:'+ i2str(ret[5]+256L*ret[6])
      found[0] = 1
    endelse
  endelse
  ret = read_apd_register(PC_board,0,length=4,/array,error=e)
  if (e ne '') then begin
    txt[4] = 'Communication error (Control).'
  endif else begin
    if (ishft(ret[0],-5) ne 2) then begin
      txt[4] = 'No Control board present.'
    endif else begin
      ret1 = read_apd_register(PC_board,PC_REG_BOARD_SERIAL,length=2,error=e)
      if (e ne '') then begin
        txt[4] = 'Communication error (Control).'
      endif else begin
        txt[4] = 'Control:'
        txt[5] = '  S/N:'+ i2str(ret1)
        txt[6] = '  Fw Ver:'+ string(float(ret[2]+256L*ret[3])/100,format='(F5.2)')
        found[1] = 1
      endelse
    endelse
  endelse
  widget_control,apd_id_widg,set_value=txt
  check_errors
  if (total(found) eq 2) then begin
    return,1
  endif else begin
    return,0
  endelse
end  ; apd_find

function do_apd_measurement,message_widget,ADC_mult=ADC_mult,ADV_div=ADC_div,samplediv=samplediv,$
  bits=bits,channel_masks=channel_masks,samplecount=samplecount,data_out=data_out,time_out=time_out,sampletime=sampletime,$
  load_only=load_only
;************************************************
; DO_APD_MEASUREMENT
; /load_only: Load last measurement only, do no measure
; Returns 0: error
;         1: OK
;************************************************
@apdcam_common.pro

  if (keyword_set(offline)) then load_only=1


default,ADC_mult,20
default,ADC_div,40
default,stream_div,10
default,stream_mult,30
default,samplecount,50000


signal_cache_delete,name='adc*'

;widget_control,apd_stopmeas_widg,set_value=[0]
bytes_per_sample = read_apd_register(ADC_board,ADC_REG_BPSCH1,length=4,/array,error=e)
channel_masks = read_apd_register(ADC_board,ADC_REG_CHENABLE1,length=4,/array,error=e)
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


bits_w = read_apd_register(ADC_board,ADC_REG_RESOLUTION,length=1,error=e)
case bits_w of
  0: bits = 14
  1: bits = 12
  2: bits = 8
  else: begin
    widget_control,message_widget,set_value='Invalid bits per pixel value.'
    return,0
  end
endcase

samplediv = read_apd_register(ADC_board,ADC_REG_ADSAMPLEDIV,length=2,error=e)
if (e ne '') then begin
  widget_control,message_widget,set_value='Communication error.'
  return,0
endif
samplediv=samplediv/7

if (samplecount eq 0) then begin
  widget_control,message_widget,set_value='Sample count 0.'
  return,0
endif

adclk = 20.0*ADC_mult/ADC_div
sclk = adclk/samplediv
sampletime = 1./(sclk*1e6)

case bits of
  8: res = 2
  12: res = 1
  14: res = 0
endcase

if (not keyword_set(load_only)) then begin

  widget_control,message_widget,set_value='Starting measurement program'

  openw,unit,'data\apd_idl_meas.txt',/get_lun,error=error
  printf,unit,'Open 10.123.13.101'
  printf,unit,'SetTiming '+i2str(ADC_mult)+' '+i2str(ADC_div)+' '+' '+i2str(stream_mult)+' '+i2str(stream_div)
  printf,unit,'Sampling '+i2str(samplediv)+' 0'
  alldata = long(samplecount)*nch*2
  primbuf = float(alldata) /10
  if (primbuf lt 4e6) then  primbuf = 4e6
  printf,unit,'Allocate '+i2str(samplecount)+' '+i2str(bits)+' '+i2str(channel_masks[0])+' '+i2str(channel_masks[1])+$
      ' '+i2str(channel_masks[2])+' '+i2str(channel_masks[3])+' '+i2str(primbuf/float(alldata)*100 > 5)
  printf,unit,'Arm 0 '+i2str(samplecount)+' 0'
  ; For triggered operation
  ;printf,unit,'Trigger 1 0 0 0 TriggerDesc.txt'
  ;printf,unit,'Start'
  ;printf,unit,'Wait 100000000'
  ; For non-triggered mode
  printf,unit,'Trigger 1 0 0 0 TriggerDesc.txt'
  printf,unit,'Waitclock -1'
  printf,unit,'Start'
  printf,unit,'Wait '+i2str(sampletime*samplecount*1000+1000)
  printf,unit,'Save '+i2str(samplecount)
  ;printf,unit,'Pause'
  printf,unit,'Close'
  close,unit & free_lun,unit
  if (strupcase(!version.os) eq 'WIN32') then begin
    cmd = 'cd data & del Channel*.dat & APDtest.exe apd_idl_meas.txt'
  endif else begin
;    cmd = 'cd data ; rm Channel*.dat; APDTest apd_idl_meas.txt'
     cmd = 'cd data ; APDTest apd_idl_meas.txt'
  endelse 
  spawn,cmd
  widget_control,message_widget,set_value='Measurement done'
  samplecount_proc = long(samplecount)
endif ; if not load_only

if (keyword_set(load_only)) then begin
  channel_masks = lonarr(4)
  widgets = [apd_ch1_widg,apd_ch2_widg,apd_ch3_widg,apd_ch4_widg]
  for iblock=0,3 do begin
    widget_control,widgets[iblock],get_value=v
    val = 0l
    mask = 1l
    for i=0,7 do begin
      if (v[i] ne 0) then val = val or mask
      mask = ishft(mask,1)
    endfor
    channel_masks[iblock] = val
  endfor

  widget_control,apd_pllmult_widg,get_value=v
  ADC_mult = fix(v[0])
  widget_control,apd_plldiv_widg,get_value=v
  ADC_div = fix(v[0])
  widget_control,apd_samplediv_widg,get_value=v
  samplediv = fix(v[0])
  widget_control,apd_resolution_widg,get_value=v
  bits = fix(v[0])
  widget_control,apd_samplenum_widg,get_value=txt
  samplecount = long(txt[0])

  adclk = 20.0*ADC_mult/ADC_div
  sclk = adclk/samplediv
  sampletime = 1./(sclk*1e6)

  samplecount_proc = long(samplecount)
endif

load_apd_data,file=file,sampletime=sampletime,data=data_out,time_out=time_out,channel_masks=channel_masks,$
   bits=bits,samplecount=samplecount_proc,errormess=errormess,/no_crc
if (errormess ne '') then begin
  widget_control,message_widget,set_value=errormess
  return,0
endif


start_adc = 1
stop_adc = 4
for adc=start_adc,stop_adc do begin
  channels = 0
  m = hex('01')
  for i=0,7 do begin
    if ((m and channel_masks[adc-1]) ne 0) then begin
      channels = channels+1
      if (channels eq 1) then begin
        channel_list = i
      endif else begin
        channel_list = [channel_list,i]
      endelse
    endif
    m = ishft(m,1)
  endfor

  if (channels eq 0) then continue

  for i=0,channels-1 do begin
    data = reform(data_out[(adc-1)*8+channel_list[i],*])
    signal_cache_add,data=data,time=time_out,name='ADC'+i2str((adc-1)*8+channel_list[i]+1),errormes=e
    if (e ne '') then begin
      widget_control,message_widget,set_value='e'
    endif
  endfor   ; channel

endfor  ; adc


  widget_control,message_widget,set_value='Measurement finished.'


  return,1



end  ; do_apd_measurement


pro collect_data,ADC_mult=ADC_mult,ADC_div=ADC_div,samplediv=samplediv,meastime=meastime,$
    bits=bits,trigger=trigger,samplenumber_out=samplecount,channel_masks=channel_masks,status=status,nowidget=nowidget
@apdcam_common.pro
; INPUT:
;  trigger: trigger time in sec. <0 means immediate, >=0 external trigger relative to Ip start
;  meastime: Measurementtime in sec.
;  ADC_mult, ADC_div: ADC PLL parameters
;  samplediv: Sample frequency divider for resampling
;  bits: ADC resolution
;  channel_masks: Array of four integers with bit mask for 4x8 channels. 1 enables.
; OUTPUT:
;   samplenumber_out: The measured sample number
;   status: 1: Measurement finished
;           0: Measurement not finished (aborted)

  default,ADC_mult,20
  default,ADC_div,40
  default,stream_div,10
  default,stream_mult,30
  default,samplediv,5
  default,meastime,16
  default,bits,12
  default,trigger,-1  ; If <0 then manual start, otherwise delay
  default,channel_masks,[255,255,255,255]

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
  fname = dir_f_name('data','apd_idl_meas.txt')
  openw,unit,fname,/get_lun,error=error
  if (error ne 0) then begin
    for i=0,30 do begin
      wait,1
      openw,unit,fname,/get_lun,error=error
      if (error eq 0) then break
    endfor
  endif
  if ((error ne 0) and (not keyword_set(nowidget))) then begin
    widget_control,kstar_status_widg,set_value='Error writing measurement control file'
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
    printf,unit,'Waitclock -1'
    printf,unit,'Trigger 1 0 0 '+i2str(long(float(trigger)/baseclock_period))+' TriggerDesc.txt'
    printf,unit,'Start'
    printf,unit,'Wait 100000000'
  endif else begin
    ; For non-triggered mode
    printf,unit,'Trigger 0 0 0 0 TriggerDesc.txt'
    printf,unit,'Start'
    printf,unit,'Wait '+i2str(sampletime*samplecount*1000+1000)
  endelse
  printf,unit,'Save ' +i2str(samplecount)
  printf,unit,'Close'
  close,unit & free_lun,unit
  if (strupcase(!version.os) eq 'WIN32') then begin  
    cmd = 'cd data & del Channel*.dat & APDtest.exe apd_idl_meas.txt'
    spawn,cmd,/nowait
  endif else begin
    cmd = 'cd data ; rm Channel*.dat ;./APDTest apd_idl_meas.txt &'
    spawn,cmd
  endelse
  wait,2
  while 1 do begin
    ; Check for data file
    if (strupcase(!version.os) eq 'WIN32') then begin
      spawn,'dir data\Channel31.dat',res,err
    endif else begin
      spawn,'ls data/Channel31.dat',res,err
    endelse
    if (err eq '') then begin
      ; Data is available
      ;wait 20 seconds to ensure all data are written
      wait,10
      status = 1
      break
    endif
    if (not keyword_set(nowidget)) then begin
      ; Process widget events
      res = widget_event(apd_widg,/nowait)
      res=widget_event(kstar_widg,/nowait)
      if (keyword_set(kstar_stop_flag)) then break
    endif
    wait,1
  endwhile
  ;widget_control,message_widget,set_value='Measurement done'
end  ; collect_data


pro get_apd_offset
@apdcam_common.pro

ret = do_apd_measurement(apd_offset_mess_widg,data_out=measdata,samplecount=meas_samplenum,sampletime=sampletime)
if (ret eq 0) then return
n = (size(measdata))[2]
n = n-5
for i=0,31 do begin
  ;fluc_correlation,0,timer=[0,n*sampletime],ref='cache/ADC'+i2str(i+1),fres=1e3,outfscale=f,outpower=p,interv=1
  ;
  widget_control,apd_offs_act_widg[i],set_value=i2str(mean(measdata[i,0:n]))
  widget_control,apd_rmsHF_act_widg[i],set_value=string(sqrt(variance(measdata[i,0:n]-integ(measdata[i,0:n],16./(sampletime/1e-6)))),format='(F5.1)')
  widget_control,apd_rmsLF_act_widg[i],set_value=string(sqrt(variance(integ(measdata[i,0:n],16./(sampletime/1e-6)))),format='(F5.1)')
  widget_control,apd_pp_act_widg[i],set_value=i2str(max(measdata[i,0:n])-min(measdata[i,0:n]))
endfor

end

pro apd_data_event,event
;**********************************************
;*         apd_data_event                   *
;**********************************************
@apdcam_common.pro
if ((event.ID eq apd_meas_widg) or (event.ID eq apd_meas_load_widg)) then begin
  if (event.ID eq apd_meas_widg) then begin
    bits = 14
    if (meas_samplenum le 0) then begin
      widget_control,apd_meas_mess_widg,set_value='No sample number is set.'
      return
    endif
  endif else begin
    load_only = 1
    widget_control,apd_samplenum_widg,get_value=v
    meas_samplenum = long(v)
  endelse
  if (do_apd_measurement(apd_meas_mess_widg,data_out=data_out,time_out=time_out,bits=bits,$
    channel_masks=channel_masks,samplecount=meas_samplenum,load_only=load_only) eq 0) then return

  wset,plot_window
  erase
  xstep=0.9/4
  ystep=0.9/8
  xrange=[min(time_out),max(time_out)]
  for iadc=0,3 do begin
    for ich=0,7 do begin
      if ((channel_masks[iadc] and ishft(1,ich)) ne 0) then begin
        if (ich eq 7) then begin
          xtickname=''
          xtitle=' Time [s]'
        endif else begin
          xtickname=replicate('  ',20)
          xtitle = ''
        endelse
        if (iadc eq 0) then ytickname='' else ytickname=replicate('  ',20)

        plot,time_out,data_out[iadc*8+ich,*],xrange=xrange,xstyle=1,/noerase,$
          pos=[0.09+iadc*xstep,0.98-(ich+1)*ystep,0.09+(iadc+0.8)*xstep,0.98-(ich+0.2)*ystep],$
          yrange=[-2^(bits-4),2^bits+2^(bits-4)],ystyle=1,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,charsize=0.8,$
          title=i2str(iadc*8+ich+1)
      endif
    endfor
  endfor

  meas_timerange = [min(time_out),max(time_out)]

endif

if (event.ID eq apd_power_widg) then begin
  apd_plot_power
endif

if (event.ID eq apd_gaintest_widg) then begin
  if (meas_samplenum le 0) then begin
    widget_control,apd_meas_mess_widg,set_value='No sample number is set.'
    return
  endif

  wset,plot_window
  !p.background = 2L^24-1
  !p.color = 0
  erase
  widget_control,apd_gain_v1_widg,get_value=v1
  v1 = fix(v1)
  widget_control,apd_gain_v2_widg,get_value=v2
  v2 = fix(v2)
  widget_control,apd_gain_light_widg,get_value=light
  light = fix(light)

  v_act = v1
  n_gain = 0
  while v_act le v2 do begin
    widget_control,apd_meas_mess_widg,set_value='Measuring background, voltage: '+i2str(v_act)

    ret = read_apd_register(PC_board,PC_REG_TEMP_SENSOR_1+8,length=2,error=e)
    if (e ne '') then begin
      widget_control,apd_meas_mess_widg,set_value='Comm. reading temperature.'
      return
    endif
    if (n_gain eq 0) then begin
      temps = float(ret)/10
    endif else begin
      temps = [temps,float(ret)/10]
    endelse
    ; Setting voltage
    val = fix(fix(v_act)/HV_CALFAC)
    write_apd_register,PC_board,PC_REG_HV1SET,val,length=2,errormess=errormess
    if (errormess ne '') then begin
      widget_control,apd_meas_mess_widg,set_value='Comm. error setting voltage.'
      return
    endif
    ;waiting for voltage to stabilise
    wait,2
    read_apd_hv

    ; Setting light to 0
    write_apd_register,PC_board,PC_REG_CALLIGHT,0,length=2,errormess=errormess
    if (errormess ne '') then begin
     widget_control,apd_meas_mess_widg,set_value='Comm. error setting light level'
     return
    endif
    read_apd_hv

    ; Doing offset measurement
    if (do_apd_measurement(apd_meas_mess_widg,data_out=data_out,time_out=time_out,bits=bits,channel_masks=channel_masks,$
      samplecount=meas_samplenum,sampletime=sampletime) eq 0) then return
    if (n_gain ne 0) then begin
      offsets_old = offsets
      noise_offsets_old = noise_offsets
    endif
    offsets = fltarr(32,n_gain+1)
    noise_offsets = fltarr(32,n_gain+1)
    if (n_gain ne 0) then begin
      offsets[*,0:n_gain-1] = offsets_old
      noise_offsets[*,0:n_gain-1] = noise_offsets_old
    endif
    offsets[*,n_gain] = total(data_out,2)/(size(data_out))[2]

    for i=0,31 do begin
      data_filt = bandpass_filter_data(float(reform(data_out[i,*])),sampletime=sampletime,filter_low=1e4,filter_high=5e6,$
        errormess=errormess,/silent,/filter_symmetric)
      if (errormess ne '') then begin
        widget_control,apd_meas_mess_widg,set_value='Error filtering data: '+errormess
        return
      endif
      noise_offsets[i,n_gain] = sqrt(variance(data_filt))
    endfor

    ; Setting light
    write_apd_register,PC_board,PC_REG_CALLIGHT,light,length=2,errormess=errormess
    if (errormess ne '') then begin
     widget_control,apd_meas_mess_widg,set_value='Comm. error setting light level'
     return
    endif
    read_apd_hv

    ; Doing light measurement
    if (do_apd_measurement(apd_meas_mess_widg,data_out=data_out,time_out=time_out,bits=bits,channel_masks=channel_masks,samplecount=meas_samplenum) eq 0) then return
    if (n_gain ne 0) then begin
      signals_old = signals
      noise_signals_old = noise_signals
    endif
    signals = fltarr(32,n_gain+1)
    noise_signals = fltarr(32,n_gain+1)
    if (n_gain ne 0) then begin
      signals[*,0:n_gain-1] = signals_old
      noise_signals[*,0:n_gain-1] = noise_signals_old
    endif
    signals[*,n_gain] = total(data_out,2)/(size(data_out))[2]
    for i=0,31 do begin
      data_filt = bandpass_filter_data(float(reform(data_out[i,*])),sampletime=sampletime,filter_low=1e4,filter_high=5e6,$
        errormess=errormess,/silent,/filter_symmetric)
      if (errormess ne '') then begin
        widget_control,apd_meas_mess_widg,set_value='Error filtering data: '+errormess
        return
      endif
      noise_signals[i,n_gain] = sqrt(variance(data_filt))
    endfor

    ret = read_apd_register(PC_board,PC_REG_HV1MON,length=2,error=e)
    if (e ne '') then begin
      widget_control,apd_meas_mess_widg,set_value='Comm. error reading voltage.'
      return
    endif
    volt_set = ret*HV_CALFAC

    if (n_gain eq 0) then begin
      volts = volt_set
    endif else begin
      volts = [volts,volt_set]
    endelse

    if (v_act lt 250) then begin
      v_act = v_act+50
    endif else begin
      if (v_act lt 350) then begin
        v_act = v_act+20
      endif else begin
        v_act = v_act+10
      endelse
    endelse
    n_gain = n_gain+1
  endwhile

  ; Setting voltage to minimum
  val = fix(fix(v1)/HV_CALFAC)
  write_apd_register,PC_board,PC_REG_HV1SET,val,length=2,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_meas_mess_widg,set_value='Comm. error setting voltage.'
    return
  endif
  wait,1
  read_apd_hv

  save,signals,offsets,data,noise_signals,noise_offsets,bits,volts,light,temps,file='gaintest.sav'

  hardon
  proc_apdcam_gaintest,thick=3
  hardfile,'Gain_test.ps'
  spawn,'start Gain_test.ps'

endif
check_errors
end  ; apd_data_event

pro apd_plot_power
;**********************************************
;*         apd_plot_power                     *
;* Plots power spectra of data in cache       *
;**********************************************
@apdcam_common.pro
  if (not defined(meas_timerange)) then return

  wset,plot_window
  !p.background = 2L^24-1
  !p.color = 0
  erase
  xstep=0.9/4
  ystep=0.9/8
  ch_mask = intarr(32)
  widget_control,apd_ftype_log_widg,get_value=v
  widget_control,apd_frange1_widg,get_value=frange1
  frange1=float(frange1)
  widget_control,apd_frange2_widg,get_value=frange2
  frange2=float(frange2)
  widget_control,apd_fres_widg,get_value=fres
  fres=float(fres[0])
  frange = [frange1,frange2]
  widget_control,apd_prange1_widg,get_value=prange1
  prange1=float(prange1)
  widget_control,apd_prange2_widg,get_value=prange2
  prange2=float(prange2)
  prange=[prange1,prange2]
  if (v[0] ne 0) then begin
    ftype = 1
  endif else begin
    ftype = 0
  endelse
  for iadc=0,3 do begin
    for ich=0,7 do begin
      chn = iadc*8+ich+1
        widget_control,apd_meas_mess_widg,set_value='Calculating power, ch '+i2str(chn)
        fluc_correlation,0,timerange=meas_timerange,refchan='cache/ADC'+i2str(chn),fres=fres,frange=frange,ftype=ftype,outpower=p,outfscale=f,$
            errormess=e,/noplot,/silent,interval_n=1
        if (e eq '') then begin
          if (not defined(p_vect)) then begin
            p_vect = fltarr(32,n_elements(p))
          endif
          p_vect[chn-1,*] = p
          ch_mask[chn-1] = 1
        endif else begin
          ; widget_control,apd_meas_mess_widg,set_value=e
        endelse
    endfor
  endfor
  if (total(ch_mask) ne 0) then begin
    for iadc=0,3 do begin
      first = 1
      for ich=7,0,-1 do begin
        chn = iadc*8+ich+1
        if (ch_mask[chn-1] ne 0) then begin
          if (first) then begin
            xtickname=''
            xtitle=' f [Hz]'
          endif else begin
            xtickname=replicate('  ',20)
            xtitle = ''
          endelse
          first = 0
          ;if (iadc eq 0) then ytickname='' else ytickname=replicate('  ',20)
         ytickname = ''
          plot,f,p_vect[chn-1,*],xrange=frange,xstyle=1,xtype=1,/noerase,$
          pos=[0.09+iadc*xstep,0.98-(ich+1)*ystep,0.09+(iadc+0.8)*xstep,0.98-(ich+0.2)*ystep],$
          yrange=prange,ystyle=1,ytype=1,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,charsize=0.8,$
          title=i2str(chn)
        endif
      endfor
    endfor
  endif
end

pro apd_offset_event,event
;**********************************************
;*         apd_offset_event                   *
;**********************************************
@apdcam_common.pro

widget_control,/hourglass

if (event.ID eq apd_getoffs_widg) then begin
  get_apd_offset
endif

if (event.ID eq apd_setdac_widg) then begin
  set_apd_dac,apd_offset_mess_widg
endif

if (event.ID eq apd_setalldac_same_widg) then begin
  widget_control,apd_setalldac_same_widg,get_value=val
  for i=0,31 do begin
    widget_control,apd_dac_widg[i],set_value=val
  endfor
  set_apd_dac,apd_offset_mess_widg
endif

if (event.ID eq apd_getdac_widg) then begin
  get_apd_dac,apd_offset_mess_widg
endif

for i=0,31 do begin
  if (event.ID eq apd_dac_widg[i]) then begin
    widget_control,apd_dac_widg[i],get_value=val
    write_apd_register,ADC_board,ADC_REG_DAC1+i*2,long(val),length=2,error=e
    if (e ne '') then begin
      widget_control,apd_offset_mess_widg,set_value='Communication error.'
      return
    endif
    widget_control,apd_offset_mess_widg,set_value='DAC value set.'
  endif
endfor

check_errors
end  ; apd_offset_event

pro read_apd_channels
@apdcam_common.pro

v = read_apd_register(ADC_board,ADC_REG_CHENABLE1,len=4,/array,error=e)
if (e ne '') then v = [0,0,0,0]
for chi = 0,3 do begin
  mask = 1
  val = intarr(8)
  for i=0,7 do begin
    if ((v[chi] and mask) ne 0) then begin
      val[i] = 1
    endif else begin
      val[i] = 0
    endelse
    mask = ishft(mask,1)
  endfor
  case chi of
    0: widget_control,apd_ch1_widg,set_value=val
    1: widget_control,apd_ch2_widg,set_value=val
    2: widget_control,apd_ch3_widg,set_value=val
    3: widget_control,apd_ch4_widg,set_value=val
  endcase
endfor

v = read_apd_register(ADC_board,ADC_REG_RESOLUTION,len=1,error=e)
case v of
  0: val = '14'
  1: val = '12'
  2: val = '8'
  else: val = '??'
endcase
if (e ne '') then val = '??'
widget_control,apd_resolution_widg,set_value=val

end ; read_apd_channels

pro apd_channels_event,event
@apdcam_common.pro

if (event.ID eq apd_ch1_widg) then begin
  widget_control,event.ID,get_value=v
  val = 0
  mask = 1
  for i=0,7 do begin
    if (v[i] ne 0) then val = val or mask
    mask = ishft(mask,1)
  endfor
  write_apd_register,ADC_board,ADC_REG_CHENABLE1,val,len=1,errormess=errormess
endif

if (event.ID eq apd_ch2_widg) then begin
  widget_control,event.ID,get_value=v
  val = 0
  mask = 1
  for i=0,7 do begin
    if (v[i] ne 0) then val = val or mask
    mask = ishft(mask,1)
  endfor
  write_apd_register,ADC_board,ADC_REG_CHENABLE2,val,len=1,errormess=errormess
endif
if (event.ID eq apd_ch3_widg) then begin
  widget_control,event.ID,get_value=v
  val = 0
  mask = 1
  for i=0,7 do begin
    if (v[i] ne 0) then val = val or mask
    mask = ishft(mask,1)
  endfor
  write_apd_register,ADC_board,ADC_REG_CHENABLE3,val,len=1,errormess=errormess
endif
if (event.ID eq apd_ch4_widg) then begin
  widget_control,event.ID,get_value=v
  val = 0
  mask = 1
  for i=0,7 do begin
    if (v[i] ne 0) then val = val or mask
    mask = ishft(mask,1)
  endfor
  write_apd_register,ADC_board,ADC_REG_CHENABLE4,val,len=1,errormess=errormess
endif

if (event.ID eq apd_challon_widg) then begin
  widget_control,apd_ch1_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_ch2_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_ch3_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_ch4_widg,set_value=[1,1,1,1,1,1,1,1]
  write_apd_register,ADC_board,ADC_REG_CHENABLE1,[255,255,255,255],/array,errormess=errormess
endif

if (event.ID eq apd_challoff_widg) then begin
  widget_control,apd_ch1_widg,set_value=[0,0,0,0,0,0,0,0]
  widget_control,apd_ch2_widg,set_value=[0,0,0,0,0,0,0,0]
  widget_control,apd_ch3_widg,set_value=[0,0,0,0,0,0,0,0]
  widget_control,apd_ch4_widg,set_value=[0,0,0,0,0,0,0,0]
  write_apd_register,ADC_board,ADC_REG_CHENABLE1,[0,0,0,0],/array,errormess=errormess
endif

if (event.ID eq apd_resolution_widg) then begin
  widget_control,event.ID,get_value=v
    v = fix(v)
    val = -1
    case v of
      8: val = 2
      12:val = 1
      14: val = 0
      else: val = -1
    endcase
    if (val ge 0) then begin
      write_apd_register,ADC_board,ADC_REG_RESOLUTION,val,len=1,errormess=errormess
    endif else begin
      widget_control,event.ID,set_value='??'
    endelse
endif


check_errors
end ;apd_channels_event





pro apd_event,event
;**********************************************
;*                apd_event                   *
;**********************************************
@apdcam_common.pro

if (event.ID eq apd_find_widg) then begin
  if (apd_find()) then begin
    read_apd_timing
    read_apd_hv
    get_apd_dac,apd_offset_mess_widg
    read_apd_weights
    read_apd_channels

  endif
  return
endif

if (event.ID eq apd_getoffs_widg) then begin
  get_apd_offset
endif

if (event.ID eq apd_hvread_widg) then begin
  read_apd_hv
endif

if (event.ID eq apd_hvenable_widg) then begin
  write_apd_register,PC_board,PC_REG_HVENABLE,hex('AB'),length=1,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  ret = read_apd_register(PC_board,PC_REG_HVENABLE,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    if (ret[0] eq hex('AB')) then begin
      widget_control,apd_hvmess_widg,set_value=' '
      widget_control,apd_hvedstat_widg,set_value='HV Enabled'
    endif else begin
      widget_control,apd_hvmess_widg,set_value='Error HV enable ('+i2str(ret[0])+')'
    endelse
  endelse
  read_apd_hv
endif

if (event.ID eq apd_hvdisable_widg) then begin
  write_apd_register,PC_board,PC_REG_HVENABLE,hex('00'),length=1,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  ret = read_apd_register(PC_board,PC_REG_HVENABLE,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    if (ret[0] eq hex('00')) then begin
      widget_control,apd_hvmess_widg,set_value=' '
      widget_control,apd_hvedstat_widg,set_value='HV Disabled'
    endif else begin
      widget_control,apd_hvmess_widg,set_value='Error HV disable ('+i2str(ret[0])+')'
    endelse
  endelse
  read_apd_hv
endif

if (event.ID eq apd_hv1on_widg) then begin
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret or hex('01')),length=1,errormess=errormess
    if (errormess ne '') then begin
      widget_control,apd_hvmess_widg,set_value='Comm. error'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    if ((ret[0] and hex('01')) ne 0) then begin
      widget_control,apd_hvmess_widg,set_value='HV1 on.'
    endif else begin
      widget_control,apd_hvmess_widg,set_value='Error HV1 on.'
    endelse
  endelse
  read_apd_hv
endif

if (event.ID eq apd_hv1off_widg) then begin
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret and hex('FE')),length=1,errormess=errormess
    if (errormess ne '') then begin
      widget_control,apd_hvmess_widg,set_value='Comm. error'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    if ((ret[0] and hex('01')) eq 0) then begin
      widget_control,apd_hvmess_widg,set_value='HV1 off.'
    endif else begin
      widget_control,apd_hvmess_widg,set_value='Error HV1 off.'
    endelse
  endelse
  read_apd_hv
endif

if (event.ID eq apd_hv2on_widg) then begin
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret or hex('02')),length=1,errormess=errormess
    if (errormess ne '') then begin
      widget_control,apd_hvmess_widg,set_value='Comm. error'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    if ((ret[0] and hex('02')) ne 0) then begin
      widget_control,apd_hvmess_widg,set_value='HV2 on.'
    endif else begin
      widget_control,apd_hvmess_widg,set_value='Error HV2 on.'
    endelse
  endelse
  read_apd_hv
endif

if (event.ID eq apd_hv2off_widg) then begin
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret and hex('FD')),length=1,errormess=errormess
    if (errormess ne '') then begin
      widget_control,apd_hvmess_widg,set_value='Comm. error'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
  endif else begin
    if ((ret[0] and hex('02')) eq 0) then begin
      widget_control,apd_hvmess_widg,set_value='HV2 off.'
    endif else begin
      widget_control,apd_hvmess_widg,set_value='Error HV2 off.'
    endelse
  endelse
  read_apd_hv
endif


if (event.ID eq apd_hv1val_widg) then begin
  widget_control,apd_hv1val_widg,get_value=r
  val = fix(fix(r)/HV_CALFAC)
  write_apd_register,PC_board,PC_REG_HV1SET,val,length=2,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  read_apd_hv
endif

if (event.ID eq apd_hv2val_widg) then begin
  widget_control,apd_hv2val_widg,get_value=r
  val = fix(fix(r)/HV_CALFAC)
  write_apd_register,PC_board,PC_REG_HV2SET,val,length=2,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  read_apd_hv
endif

if ((event.ID eq apd_shopen_widg)) then begin
  write_apd_register,PC_board,PC_REG_SHSTATE,1,length=1,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
endif

if ((event.ID eq apd_shclose_widg)) then begin
  write_apd_register,PC_board,PC_REG_SHSTATE,0,length=1,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
endif

if ((event.ID eq apd_shmode_widg)) then begin
  widget_control,event.ID,get_value=val
  write_apd_register,PC_board,PC_REG_SHMODE,fix(val),length=1,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
endif

if (event.ID eq apd_hv1max_widg) then begin
  widget_control,apd_hv1max_widg,get_value=val
  write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('CD'),length=1,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  write_apd_register,PC_board,PC_REG_HV1MAX,long(long(val)/HV_CALFAC),length=2,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('0'),length=1,errormess=errormess
  ret = read_apd_register(PC_board,PC_REG_HV1MAX,length=2,/array,error=e)
  if (e ne '') then begin
    txt1 = 'Err '
  endif else begin
    txt1 = i2str((ret[0]+256*ret[1])*HV_CALFAC)
  endelse
  widget_control,apd_hv1max_widg,set_value=txt1
endif

if (event.ID eq apd_hv2max_widg) then begin
  widget_control,apd_hv2max_widg,get_value=val
  write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('CD'),length=1,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  write_apd_register,PC_board,PC_REG_HV2MAX,long(long(val)/HV_CALFAC),length=2,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
  write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('0'),length=1,errormess=errormess
  ret = read_apd_register(PC_board,PC_REG_HV2MAX,length=2,/array,error=e)
  if (e ne '') then begin
    txt1 = 'Err '
  endif else begin
    txt1 = i2str((ret[0]+256*ret[1])*HV_CALFAC)
  endelse
  widget_control,apd_hv2max_widg,set_value=txt1
endif

if ((event.ID eq apd_reset_widg)) then begin
  write_apd_register,ADC_board,ADC_REG_RESET,hex('CD'),length=1,errormess=errormess
  read_apd_timing
  read_apd_hv
  get_apd_dac,apd_offset_mess_widg
  read_apd_weights
endif

if ((event.ID eq apd_pc_reset_widg)) then begin
  write_apd_register,PC_board,PC_REG_RESET,hex('CD'),length=1,errormess=errormess
  read_apd_hv
  read_apd_weights
endif

if (event.ID eq apd_callight_widg) then begin
  widget_control,apd_callight_widg,get_value=r
  val = fix(r)
  write_apd_register,PC_board,PC_REG_CALLIGHT,val,length=2,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='Comm. error'
    return
  endif
endif

;Setting mirror_position from mirror_pos

if (event.ID eq apd_spareio1_widg) then begin
  widget_control,apd_spareio1_widg,get_value=r
  val = long(r)
  cmd='/home/bes/Software/adj_stepmotor/adj_stepmotor 1 '+strtrim(val,2)
  spawn, cmd
  while 1 do begin
     spawn, '~/Software/read_motor_pos/read_motor_pos',pos
     mirror_pos=long(strmid(pos[0],6,5))
     widget_control,apd_hvmess_widg,set_value='Mirror position: '+strtrim(mirror_pos,2)
     if long(mirror_pos) eq long(val) then begin
        widget_control,apd_hvmess_widg,set_value='Mirror position set!'
        break
     endif
     wait,1
  endwhile
   stepmotor_pos, pos=mirror_pos, R=rad_pos, /calc_R
   widget_control,apd_spareio7_widg,set_value=long(rad_pos)
endif

;Setting mirror_position from R

if (event.ID eq apd_spareio7_widg) then begin
   widget_control,apd_spareio7_widg,get_value=r
   val = long(r)
   stepmotor_pos, pos=mirror_pos, R=val, /noquery, error=error
   if not error then begin
      widget_control,apd_spareio1_widg,set_value=long(mirror_pos)
      cmd='/home/bes/Software/adj_stepmotor/adj_stepmotor 1 '+strtrim(mirror_pos,2)
      spawn, cmd
      while 1 do begin
         spawn, '~/Software/read_motor_pos/read_motor_pos',pos
         act_pos=long(strmid(pos[0],6,5))
         widget_control,apd_hvmess_widg,set_value='Mirror position: '+strtrim(act_pos,2)
         if long(act_pos) eq long(mirror_pos) then begin
            widget_control,apd_hvmess_widg,set_value='Mirror position set!'
            break
         endif
         wait,1
      endwhile
      
   endif else begin
      widget_control,apd_hvmess_widg,set_value='Error calculating the mirror position from R!'
   endelse
endif

;Setting filter position
if (event.ID eq apd_spareio2_widg) then begin
  widget_control,apd_spareio2_widg,get_value=r
  val = long(r)
  cmd='/home/bes/Software/adj_stepmotor/adj_stepmotor 3 '+strtrim(val,2)
  spawn, cmd
  while 1 do begin
     spawn, '~/Software/read_motor_pos/read_motor_pos',pos
     filter_pos=long(strmid(pos[2],6,4))
     widget_control,apd_hvmess_widg,set_value='Filter position: '+strtrim(filter_pos,2)
     if long(filter_pos) eq long(val) then begin
        widget_control,apd_hvmess_widg,set_value='Filter position set!'
        break
     endif
     wait,1
  endwhile
endif

;Horizontal setting

if (event.ID eq apd_spareio4_widg) then begin
  val = 30000
  cmd='/home/bes/Software/adj_stepmotor/adj_stepmotor 4 '+strtrim(val,2)
  spawn, cmd
  while 1 do begin
     spawn, '~/Software/read_motor_pos/read_motor_pos',pos
     apdcam_pos=long(strmid(pos[3],6,5))
     widget_control,apd_hvmess_widg,set_value='APDCAM position: '+strtrim(apdcam_pos,2)
     if long(apdcam_pos) eq long(val) then begin
        widget_control,apd_hvmess_widg,set_value='APDCAM position set!'
        break
     endif
     wait,1
  endwhile
  widget_control,apd_spareio6_widg,set_value=val
endif

;Vertical setting

if (event.ID eq apd_spareio5_widg) then begin
   val=12150
   cmd='/home/bes/Software/adj_stepmotor/adj_stepmotor 4 '+strtrim(val,2)
   spawn, cmd
   while 1 do begin
      spawn, '~/Software/read_motor_pos/read_motor_pos',pos
      apdcam_pos=long(strmid(pos[3],6,5))
      widget_control,apd_hvmess_widg,set_value='APDCAM position: '+strtrim(apdcam_pos,2)
      if long(apdcam_pos) eq long(val) then begin
         widget_control,apd_hvmess_widg,set_value='APDCAM position set!'
         break
      endif
      wait,1
   endwhile
   widget_control,apd_spareio6_widg,set_value=val
endif

if (event.ID eq apd_spareio6_widg) then begin
   widget_control,apd_spareio6_widg,get_value=r
   val = long(r)
   cmd='/home/bes/Software/adj_stepmotor/adj_stepmotor 4 '+strtrim(val,2)
   spawn, cmd
   while 1 do begin
      spawn, '~/Software/read_motor_pos/read_motor_pos',pos
      apdcam_pos=long(strmid(pos[3],6,5))
      widget_control,apd_hvmess_widg,set_value='APDCAM position: '+strtrim(apdcam_pos,2)
      if long(apdcam_pos) eq long(val) then begin
         widget_control,apd_hvmess_widg,set_value='APDCAM position set!'
         break
      endif
      wait,1
   endwhile
endif





;if (event.ID eq apd_spareio1_widg) or (event.ID eq apd_spareio2_widg) then begin
;  val1 = widget_info(apd_spareio1_widg,/droplist_select)
;  val2 = widget_info(apd_spareio2_widg,/droplist_select)
;  val = val1+val2*2
;  write_apd_register,ADC_board,ADC_REG_SPAREIO,val,length=1,errormess=errormess
;  if (errormess ne '') then begin
;    widget_control,apd_hvmess_widg,set_value='Comm. error'
;    return
;  endif
;endif

if (event.ID eq stop_widg) then begin
    program_running = 0
    return
endif

check_errors
end  ; END apd_event

pro main
  kstar_apdcam_control
end



pro apd_init
@apdcam_common.pro
  ADC_board = 1
  PC_board = 2
  ADC_REG_MC_VERSION = hex('01')
  ADC_REG_SERIAL = hex('03')
  ADC_REG_FPGA_VERSION = hex('05')
  ADC_REG_STATUS1 = hex('08')
  ADC_REG_STATUS2 = hex('09')
  ADC_REG_CONTROL = hex('0B')
  ADC_REG_ADSAMPLEDIV = hex('1C')
  ADC_REG_ADCCLKMUL = hex('0C')
  ADC_REG_ADCCLKDIV = hex('0D')
  ADC_REG_STREAMCLKMUL = hex('0E')
  ADC_REG_STREAMCLKDIV = hex('0F')
  ADC_REG_EXTCLKMUL = hex('2E')
  ADC_REG_EXTCLKDIV = hex('2F')
  ADC_REG_STREAMCONTROL = hex('10')
  ADC_REG_SAMPLECNT = hex('11')
  ADC_REG_CHENABLE1 = hex('15')
  ADC_REG_CHENABLE2 = hex('16')
  ADC_REG_CHENABLE3 = hex('17')
  ADC_REG_CHENABLE4 = hex('18')
  ADC_REG_RINGBUFSIZE = hex('19')
  ADC_REG_RESOLUTION = hex('1B')
  ADC_REG_AD1TESTMODE = hex('20')
  ADC_REG_AD2TESTMODE = hex('21')
  ADC_REG_AD3TESTMODE = hex('22')
  ADC_REG_AD4TESTMODE = hex('23')
  ADC_REG_MAXVAL11 = hex('70')
  ADC_REG_ACTSAMPLECH1 = hex('B0')
  ADC_REG_ACTSAMPLECH2 = hex('B4')
  ADC_REG_ACTSAMPLECH3 = hex('B8')
  ADC_REG_ACTSAMPLECH4 = hex('BC')
  ADC_REG_DAC1 = hex('30')
  ADC_REG_TRIGGER = hex('1E')
  ADC_REG_OVDLEVEL = hex('C0')
  ADC_REG_OVDSTATUS = hex('C2')
  ADC_REG_OVDTIME = hex('c3')
  ADC_REG_RESET = hex('25')
  ADC_BIT_CTRL_EXTCLOCK = hex('01')
  ADC_BIT_CTRL_CLOCKOUT_ENABLE = hex('02')
  ADC_BIT_CTRL_TRIGGER_LH = hex('08')
  ADC_BIT_CTRL_TRIGGER_HL = hex('10')
  ADC_BIT_CTRL_TRIGGER_MAX = hex('20')
  ADC_BIT_CTRL_PREAMBLE = hex('80')
  ADC_REG_TRIGDELAY = hex('C5')
  ADC_REG_COEFF_01 = hex('D0')
  ADC_REG_COEFF_INT = hex('DA')
  ADC_REG_BPSCH1 = hex('28')
  ADC_REG_ERRORCODE = hex('24')
  ADC_REG_SPAREIO = hex('0A')

  PC_REG_BOARD_SERIAL = hex('0100')
  PC_REG_FW_VERSION = hex('0002')
  PC_REG_HV1SET = hex('56')
  PC_REG_HV2SET = hex('58')
  PC_REG_HV1MON = hex('04')
  PC_REG_HV2MON = hex('06')
  PC_REG_HV1MAX = hex('102')
  PC_REG_HV2MAX = hex('104')
  PC_REG_HVENABLE = hex('60')
  PC_REG_HVON = hex('5E')
  PC_REG_SHSTATE = hex('82')
  PC_REG_SHMODE = hex('80')
  PC_REG_TEMP_SENSOR_1 = hex('0C')
  PC_REG_TEMP_CONTROL_WEIGHTS_1 = hex('10A')
  PC_REG_FAN1_CONTROL_WEIGHTS_1 = hex('12A')
  PC_REG_FAN2_CONTROL_WEIGHTS_1 = hex('14A')
  PC_REG_FAN3_CONTROL_WEIGHTS_1 = hex('16A')
  PC_REG_FAN1_SPEED = hex('6C')
  PC_REG_FAN1_TEMP_SET = hex('72')
  PC_REG_FAN1_TEMP_DIFF = hex('74')
  PC_REG_FAN2_TEMP_LIMIT = hex('76')
  PC_REG_FAN3_TEMP_LIMIT = hex('78')
  PC_REG_PELT_CTRL = hex('2C')
  PC_REG_DETECTOR_TEMP_SET = hex('6A')
  PC_REG_P_GAIN = hex('50')
  PC_REG_I_GAIN = hex('52')
  PC_REG_D_GAIN = hex('54')
  PC_REG_RESET = hex('84')
  PC_REG_FACTORY_WRITE = hex('88')
  PC_REG_ERRORCODE = hex('86')
  PC_REG_CALLIGHT = hex('7A')

  HV_CALFAC = 120./1000.; Volt/digit

  Mirror_Positions = ['Remote','Close']
  Camera_Select_States = ['APDCAM','EDICAM']

  apd_temp_weights = lonarr(16,4) ; The actual control weights
  apd_temps = lonarr(16)  ; The actual temps
  fanmode = intarr(3) ; 0: auto, 1: manual

  error = long(0)
;  R = CALL_EXTERNAL('CamControl.dll','idlDontSendTS', long(error), /CDECL)

end ; apd_init



pro apd_temp_event,event
@apdcam_common.pro

  if (event.ID eq apd_readtemp_widg) then begin
    read_temp_flag = 1
    while (read_temp_flag) do begin
      read_apd_temps
      read_temp_flag = 0
    endwhile
  endif

  if (event.ID eq apd_readweights_widg) then begin
    read_apd_weights
    return
  endif

  for j=0,2 do begin
    for i=0,15 do begin
      if (event.ID eq apd_weights_widg[i,j]) then begin
        widget_control,apd_weights_widg[i,j],get_value=r
        write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('CD'),length=1,errormess=errormess
        case j of
          0: write_apd_register,PC_board,PC_REG_FAN1_CONTROL_WEIGHTS_1+i*2,long(r),length=2,errormess=errormess
          1: write_apd_register,PC_board,PC_REG_FAN2_CONTROL_WEIGHTS_1+i*2,long(r),length=2,errormess=errormess
          2: write_apd_register,PC_board,PC_REG_FAN3_CONTROL_WEIGHTS_1+i*2,long(r),length=2,errormess=errormess
        endcase
        apd_temp_weights[i,j] = long(r)
        write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('0'),length=1,errormess=errormess
      endif
    endfor
  endfor

  for i=0,15 do begin
    if (event.ID eq apd_weights_widg[i,3]) then begin
      widget_control,apd_weights_widg[i,3],get_value=r
      write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('CD'),length=1,errormess=errormess
      write_apd_register,PC_board,PC_REG_TEMP_CONTROL_WEIGHTS_1+i*2,long(r),length=2,errormess=errormess
      apd_temp_weights[i,3] = long(r)
      write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('0'),length=1,errormess=errormess
    endif
  endfor

  for i=0,2 do begin
    if (event.ID eq apd_fanmode_widg[i]) then begin
      if (event.index eq 1) then begin
        fanmode[i] = 1    ; Manual mode
        widget_control,apd_fanspeed_widg[i],editable=1
        for j=0,15 do begin
          widget_control,apd_weights_widg[j,i],editable=0,set_value='0'
        endfor
        val = intarr(16)
        write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('CD'),length=1,errormess=errormess
        case i of
          0: write_apd_register,PC_board,PC_REG_FAN1_CONTROL_WEIGHTS_1,val,length=16,/array,errormess=errormess
          1: write_apd_register,PC_board,PC_REG_FAN2_CONTROL_WEIGHTS_1,val,length=16,/array,errormess=errormess
          2: write_apd_register,PC_board,PC_REG_FAN3_CONTROL_WEIGHTS_1,val,length=16,/array,errormess=errormess
        endcase
        write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('0'),length=1,errormess=errormess
      endif else begin
        fanmode[i] = 1  ; Auto mode
        widget_control,apd_fanspeed_widg[i],editable=1
        for j=0,15 do begin
          widget_control,apd_weights_widg[j,i],editable=1,set_value=i2str(apd_temp_weights[j,i])
        endfor
        val = reform(apd_temp_weights[*,i])
        write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('CD'),length=1,errormess=errormess
        case i of
          0: write_apd_register,PC_board,PC_REG_FAN1_CONTROL_WEIGHTS_1,val,length=16,/array,errormess=errormess
          1: write_apd_register,PC_board,PC_REG_FAN2_CONTROL_WEIGHTS_1,val,length=16,/array,errormess=errormess
          2: write_apd_register,PC_board,PC_REG_FAN3_CONTROL_WEIGHTS_1,val,length=16,/array,errormess=errormess
        endcase
        write_apd_register,PC_board,PC_REG_FACTORY_WRITE,hex('0'),length=1,errormess=errormess
      endelse
      read_apd_temps
    endif
  endfor

  for i=0,2 do begin
    if (event.ID eq apd_fanspeed_widg[i]) then begin
      widget_control,apd_fanspeed_widg[i],get_value=val
      write_apd_register,PC_board,PC_REG_FAN1_SPEED+i*2,long(val),errormess=errormess
    endif
  endfor

  for i=0,2 do begin
    if (event.ID eq apd_fanlimit_widg[i]) then begin
      widget_control,apd_fanlimit_widg[i],get_value=val
      case i of
        0: write_apd_register,PC_board,PC_REG_FAN1_TEMP_SET,long(float(val)*10),len=2,errormess=errormess
        1: write_apd_register,PC_board,PC_REG_FAN2_TEMP_LIMIT,long(float(val)*10),len=2,errormess=errormess
        2: write_apd_register,PC_board,PC_REG_FAN3_TEMP_LIMIT,long(float(val)*10),len=2,errormess=errormess
      endcase
    endif
  endfor

  if (event.ID eq apd_fan1_diff_widg) then begin
    widget_control,apd_fan1_diff_widg,get_value=val
    write_apd_register,PC_board,PC_REG_FAN1_TEMP_DIFF,long(float(val)*10),len=2,errormess=errormess
  endif

  if (event.ID eq apd_pelt_ref_widg) then begin
    widget_control,apd_pelt_ref_widg,get_value=val
    write_apd_register,PC_board,PC_REG_DETECTOR_TEMP_SET,long(float(val)*10),len=2,errormess=errormess
  endif

  if (event.ID eq apd_pelt_pfact_widg) then begin
    widget_control,apd_pelt_pfact_widg,get_value=val
    write_apd_register,PC_board,PC_REG_P_GAIN,long(float(val)*100),len=2,errormess=errormess
  endif

  if (event.ID eq apd_pelt_ifact_widg) then begin
    widget_control,apd_pelt_ifact_widg,get_value=val
    write_apd_register,PC_board,PC_REG_I_GAIN,long(float(val)*100),len=2,errormess=errormess
  endif

  if (event.ID eq apd_pelt_dfact_widg) then begin
    widget_control,apd_pelt_dfact_widg,get_value=val
    write_apd_register,PC_board,PC_REG_D_GAIN,long(float(val)*100),len=2,errormess=errormess
  endif

  check_errors
end  ; apd_temp_event

pro apd_timing_event,event
@apdcam_common.pro

if (event.ID eq apd_control_widg) then begin
  widget_control,apd_control_widg,get_value=v
  val = 0
  mask = 1
  for i=0,7 do begin
    if (v[i] ne 0) then val = val or mask
    mask = ishft(mask,1)
  endfor
  write_apd_register,ADC_board,ADC_REG_CONTROL,val,len=1,errormess=errormess
endif

if (event.ID eq apd_trigger_widg) then begin
  widget_control,apd_trigger_widg,get_value=v
  val = 0
  mask = 1
  for i=0,2 do begin
    if (v[i] ne 0) then val = val or mask
    mask = ishft(mask,1)
  endfor
  write_apd_register,ADC_board,ADC_REG_TRIGGER,val,len=1,errormess=errormess
endif

if (event.ID eq apd_pllmult_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_ADCCLKMUL,fix(v),len=1,errormess=errormess
endif
if (event.ID eq apd_plldiv_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_ADCCLKDIV,fix(v),len=1,errormess=errormess
endif
if (event.ID eq apd_streammult_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_STREAMCLKMUL,fix(v),len=1,errormess=errormess
endif
if (event.ID eq apd_streamdiv_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_STREAMCLKDIV,fix(v),len=1,errormess=errormess
endif
if (event.ID eq apd_extclkmult_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_EXTCLKMUL,fix(v),len=1,errormess=errormess
endif
if (event.ID eq apd_extclkdiv_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_EXTCLKDIV,fix(v),len=1,errormess=errormess
endif
if (event.ID eq apd_trigdelay_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_TRIGDELAY,ulong(v),len=4,errormess=errormess
endif
if (event.ID eq apd_ringbufsize_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_RINGBUFSIZE,ulong(v),len=2,errormess=errormess
endif
if (event.ID eq apd_samplenum_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_SAMPLECNT,long(v),len=4,errormess=errormess
  meas_samplenum = long(v)
endif

if (event.ID eq apd_samplediv_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_ADSAMPLEDIV,long(v)*7,len=2,errormess=errormess
  meas_samplediv = long(v)
endif

if ((event.ID eq apd_triglevel_widg) or (event.ID eq apd_inttrig_opt_widg)) then begin
  widget_control,apd_triglevel_widg,get_value=v
  widget_control,apd_inttrig_opt_widg,get_value=vopt
  val = long64(v)
  if (vopt[0] ne 0) then val = val or hex('8000')
  if (vopt[1] eq 0) then val = val or hex('4000')
  varr = intarr(64)
  for i=0,31 do begin
    write_apd_register,ADC_board,ADC_REG_MAXVAL11+i*2,val,len=2,errormess=errormess
    wait,0.05
  endfor
endif

if ((event.ID eq apd_ovdlevel_widg) or (event.ID eq apd_ovdstat_widg)) then begin
  widget_control,apd_ovdlevel_widg,get_value=v
  widget_control,apd_ovdstat_widg,get_value=vstat
  val = long64(v)
  if (vstat[0] ne 0) then val = val or hex('8000')
  if (vstat[1] ne 0) then val = val or hex('4000')
  write_apd_register,ADC_board,ADC_REG_OVDLEVEL,val,len=2,errormess=errormess
  if (vstat[2] eq 0) then val = 0 else val = 1
  write_apd_register,ADC_board,ADC_REG_OVDSTATUS,val,len=1,errormess=errormess
endif

if (event.ID eq apd_ovdtime_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_OVDTIME,long(v),len=2,errormess=errormess
endif

for i=1,5 do begin
  if (event.ID eq apd_filtercoeff_widg[i-1]) then begin
    widget_control,event.ID,get_value=v
    coeff = read_filter()
    coeff[i-1] = long(v)
    write_filter,coeff
    widget_control,apd_filterfreq_widg,set_value='??'
  endif
endfor

if (event.ID eq apd_filtercoeff_int_widg) then begin
  widget_control,event.ID,get_value=v
  coeff = read_filter()
  coeff[5] = long(v)
  write_filter,coeff
  widget_control,apd_filterfreq_int_widg,set_value='??'
endif

if (event.ID eq apd_filterfreq_widg) or (event.ID eq apd_filterfreq_int_widg) or $
    (event.ID eq apd_filtergain_widg) then begin
    widget_control,apd_filtergain_widg,get_value=gain
    gain = fix(gain[0]) ; Set this to 1,2,3,4....
    widget_control,apd_pllmult_widg,get_value=mult
    mult = fix(mult[0])
    widget_control,apd_plldiv_widg,get_value=div
    div = fix(div[0])
    f_adc = 20.0*mult/div
    Nyquist_freq = f_adc/2
    widget_control,apd_filterfreq_widg,get_value=freq
    freq = float(freq[0])
    if (freq eq 0) then return
    widget_control,apd_filterfreq_int_widg,get_value=f_recurs
    f_recurs = float(f_recurs[0])
    if (f_recurs eq 0) then return
    tau = f_adc/f_recurs/2/!pi
    c = exp(-1./double(tau))
    c = long(c*4096)
    order = 5
    r = digital_filter(0,freq/(f_adc/2)<1,50,order)
    s1 = fltarr(order*10)
    s1[2*order]=1000
    s2=convol(s1,r)
    coeff1 = s2[2*order:3*order-1]
    coeff=fix(coeff1/total(coeff1)*(4096-c)/16)*2^gain
    filt = read_filter()
    for i=0,4 do begin
      filt[i] = coeff[i]
      widget_control,apd_filtercoeff_widg[i],set_value = i2str(filt[i])
    endfor
    filt[5] = c
    filt[7] = 8+gain
    widget_control,apd_filtercoeff_int_widg,set_value = i2str(filt[5])
    widget_control,apd_filterdiv_widg,set_value = i2str(filt[7])

    write_filter,filt
endif

if (event.ID eq apd_filterdiv_widg) then begin
  widget_control,event.ID,get_value=v
  filt = read_filter()
  filt[7] = v
  write_filter,filt
endif

if (event.ID eq apd_testpattern_widg) then begin
  widget_control,event.ID,get_value=v
  write_apd_register,ADC_board,ADC_REG_AD1TESTMODE,[fix(v),fix(v),fix(v),fix(v)],len=4,/array,errormess=errormess
endif

read_apd_timing
check_errors

end

pro kstar_event,event
@apdcam_common.pro

  if (event.ID eq kstar_start_widg) then begin
    if (keyword_set(meas_running)) then return
    meas_running = 1
    channel_masks = [255,255,255,255]
    ADC_mult=20
    ADC_div=40
    samplediv=5
    meastime=16
    trigger=0
    bits=12
    kstar_stop_flag=0
    ;**************************
    ;M. Lampert
    ;**************************

    dac_offset=600
    ext_clock=1 ;external clock in MHz
    int_clock=20
    extclkdiv=1
    extclkmul=20;
    
    widget_control,kstar_status_widg,set_value='Setting DAC values!'

    dac_array = bytarr(64)
    for i=0,31 do begin
       tmp=dac_offset
       dac_array[i*2] = (long(tmp) mod 256)
       dac_array[i*2+1] = (long(tmp)/256)
    endfor
    
    for ii=0,31 do begin
       write_apd_register,ADC_board,ADC_REG_DAC1+ii*2,dac_array[ii*2:ii*2+1],/array,error=e
       wait,0.05
    endfor
    write_apd_register,PC_board,PC_REG_CALLIGHT,0,length=2,errormess=errormess ;Turn off the calibration light

    ret = read_apd_register(PC_board,PC_REG_HV1MON,length=4,/array,error=e)
    hv=(ret[0]+256*ret[1])*HV_CALFAC
    if (hv lt 300) then begin
       widget_control,kstar_status_widg,set_value='HV is not set, HV:'+strtrim(hv,2)+'. Returning...'
       kstar_stop_flag=1
       wait, 2
    endif else begin
       widget_control,kstar_status_widg,set_value='HV is set to '+strtrim(hv,2)+'V. Measurement starting...'
       kstar_stop_flag = 0
       wait, 2
    endelse
    ;*****************

    while kstar_stop_flag eq 0 do begin
 
; Starting routine to read shotnumber


;       spawn, 'cat /usr/local/epics/siteApp/current_shot.txt', shot
;       shot1=long(shot)
;       shot2=shot1
;       while shot2[0] eq shot1[0] do begin
;          spawn, 'cat /usr/local/epics/siteApp/current_shot.txt', shot
;          shot2=long(shot)
;          widget_control,kstar_status_widg,set_value='Waiting for new shot'
;          if (not keyword_set(nowidget)) then begin
;             ; Process widget events
;             res=widget_event(apd_widg,/nowait)
;             res=widget_event(kstar_widg,/nowait)
;             if (keyword_set(kstar_stop_flag)) then break
;          endif
;         wait,1
;       endwhile
;       print, 'New shot'
;       widget_control,kstar_status_widg,set_value='Shot sequence started!

;       wait,1
      
       ;*******************
       ;M. Lampert
       ;*******************
;This part will wait for clock before the trigger.
       bl=0
       i3=0

       while not bl do begin
          write_apd_register,ADC_board,ADC_REG_EXTCLKMUL,fix(extclkmul/2),len=1,errormess=errormess
          wait,0.05
          write_apd_register,ADC_board,ADC_REG_EXTCLKDIV,fix(extclkdiv*2),len=1,errormess=errormess
          wait,0.05
          write_apd_register,ADC_board,ADC_REG_EXTCLKMUL,fix(extclkmul),len=1,errormess=errormess
          wait,0.05
          write_apd_register,ADC_board,ADC_REG_EXTCLKDIV,fix(extclkdiv),len=1,errormess=errormess
          widget_control,kstar_status_widg,set_value='Waiting for external clock'
          wait,2
          ret = read_apd_register(ADC_board,ADC_REG_STATUS1,length=2,error=e,/array)
          if e eq '' then begin
             if ((ret[1] and hex('04')) ne 0) then bl = 1
          endif else begin
             widget_control,kstar_status_widg,set_value='Comm. error'
          endelse
          if (not keyword_set(nowidget)) then begin
             ; Process widget events
             res=widget_event(apd_widg,/nowait)
             res=widget_event(kstar_widg,/nowait)
             if (keyword_set(kstar_stop_flag)) then break
          endif
       endwhile

       if (keyword_set(kstar_stop_flag)) then break
       widget_control,kstar_status_widg,set_value='External clock found!'
       wait, 0.5


;check whether the APD HV is on or not, and if not switch it back
       ret = read_apd_register(PC_board,PC_REG_HV1MON,length=4,/array,error=e)
;       hv=(ret[0]+256*ret[1])*HV_CALFAC
;       if (hv lt 300) then begin
;          widget_control,kstar_status_widg,set_value='HV is not set, setting it ...'
          write_apd_register,PC_board,PC_REG_HVENABLE,hex('AB'),length=1,errormess=errormess
          if (errormess ne '') then begin
             widget_control,apd_hvmess_widg,set_value='Comm. error'
             return
          endif
          ret = read_apd_register(PC_board,PC_REG_HVENABLE,length=1,error=e)
          if (e ne '') then begin
             widget_control,apd_hvmess_widg,set_value='Comm. error'
          endif else begin
             if (ret[0] eq hex('AB')) then begin
                widget_control,apd_hvmess_widg,set_value=' '
                widget_control,apd_hvedstat_widg,set_value='HV Enabled'
             endif else begin
                widget_control,apd_hvmess_widg,set_value='Error HV enable ('+i2str(ret[0])+')'
             endelse
          endelse
          read_apd_hv
          
          ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
          if (e ne '') then begin
             widget_control,apd_hvmess_widg,set_value='Comm. error'
          endif else begin
             write_apd_register,PC_board,PC_REG_HVON,(ret or hex('01')),length=1,errormess=errormess
             if (errormess ne '') then begin
                widget_control,apd_hvmess_widg,set_value='Comm. error'
                return
             endif
          endelse
          ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
          if (e ne '') then begin
             widget_control,apd_hvmess_widg,set_value='Comm. error'
          endif else begin
             if ((ret[0] and hex('01')) ne 0) then begin
                widget_control,apd_hvmess_widg,set_value='HV1 on.'
             endif else begin
                widget_control,apd_hvmess_widg,set_value='Error HV1 on.'
             endelse
          endelse
          read_apd_hv
          
;       endif

       ;*******************

       widget_control,kstar_status_widg,set_value='Measurement running'
       widget_control,kstar_shot_widg,get_value=shotnumber
       collect_data,ADC_mult=ADC_mult,ADC_div=ADC_div,samplediv=samplediv,meastime=meastime,trigger=trigger,$
                    samplenumber_out=samplenumber,bits=bits,channel_masks=channel_masks,status=meas_status

                                ; Aborting on error
       if meas_status eq 0 then kstar_stop_flag = 1       
       if (meas_status ne 0) then begin

          ;***** M. Lampert *****
          ;For CCDCAM calibration measurement
          widget_control,kstar_status_widg,set_value='PCOCAM calibration measurement'
                                ;Turn on the calibration light
          intensity=4000
          write_apd_register,PC_board,PC_REG_CALLIGHT,intensity,length=2,$
                             errormess=errormess
          ;Get filter out put screen in
          cmd='/home/bes/Software/BESset/bes_set 0 1'
          spawn, cmd
         ;Reading shotnumber from EPICS created file
          spawn, 'cat /usr/local/epics/siteApp/current_shot.txt', shot
          shotnumber=long(shot[0])
          ;**********************

                                ; Creating shot dir
          shotdir = i2str(shotnumber)
          shotdir_new = shotdir
          cmd = 'mkdir '+dir_f_name('data',shotdir)
          spawn,cmd,result,err
          if (err ne '') then begin
             i=1
             while (err ne '') do begin
                shotdir_new = shotdir+'_'+i2str(i)
                cmd = 'mkdir '+dir_f_name('data',shotdir_new)
                spawn,cmd,result,err
                i=i+1
             endwhile
             widget_control,kstar_status_widg,set_value='Shot directory already present, creating new version.'
             wait,2
          endif
          
          widget_control,kstar_status_widg,set_value='Writing configuration file'
          ;Read the motor positions from the stepmotor controller
          spawn, '~/Software/read_motor_pos/read_motor_pos',pos

          mirror_pos=long(strmid(pos[0],6,5))
          focus_pos=long(strmid(pos[1],6,5))
          filter_pos=long(strmid(pos[2],6,4))
          apd_pos=long(strmid(pos[3],6,5))

          widget_control,apd_spareio1_widg,set_value=mirror_pos
          widget_control,apd_spareio2_widg,set_value=filter_pos
          widget_control,apd_spareio6_widg,set_value=apd_pos

          widget_control,apd_spareio3_widg,get_value=filter_temp
         
          ret = read_apd_register(PC_board,PC_REG_HV1MON,length=2,error=e)
          if (e ne '') then begin
             ret = -1
          endif
          volt_set = ret*HV_CALFAC
          
          ret = read_apd_register(PC_board,PC_REG_TEMP_SENSOR_1+4*2,length=2,error=e)
          if (e ne '') then begin
             ret = -1
          endif
          temp = float(ret)/10

          write_shot_config_kstar,shotnumber,ADC_mult=ADC_mult,ADC_div=ADC_div,samplediv=samplediv,samplenumber=samplenumber,$
                                  bits=bits,trigger=trigger,channel_masks=channel_masks,mirror_pos=mirror_pos,filter_pos=filter_pos,$
                                  filter_temp=filter_temp, apd_pos=apd_pos, hv=volt_set,detector_temp=temp,datapath=dir_f_name('data',shotdir_new)
          wait, .5
          widget_control,kstar_status_widg,set_value='Moving data to shot directory'
          

                                ; Copying data
          if (strupcase(!version.os) eq 'WIN32') then begin
             cmd = 'move '+dir_f_name('data','Channel*.dat')+' '+dir_f_name('data',shotdir_new)
          endif else begin
             cmd = 'mv '+dir_f_name('data','Channel*.dat')+' '+dir_f_name('data',shotdir_new)
          endelse
          spawn,cmd

          widget_control,kstar_status_widg,set_value='Doing spatial calibration'
          calibrate_kstar_spatial, shotnumber, mirrorpos=mirror_pos, apdpos=apd_pos

          widget_control,kstar_status_widg,set_value='Copying data to BES03'
          
                                ; Copying data
          if (strupcase(!version.os) eq 'WIN32') then begin
             widget_control,kstar_status_widg,set_value='Cannot copy to Remote PC'
          endif else begin
             cmd = 'scp -r data/'+shotdir_new+' bes@BES03:/media/BES03D/Data/APDCAM'
          endelse
          spawn,cmd
          wait,1
          widget_control,kstar_status_widg,set_value='Plotting results'
          wset,kstar_plot_window
          ;show_rawsignal,shotnumber,'bes-1-8',yrange=[-0.02,1],/nocalib
          show_all_kstar_bes,shotnumber, yrange=[-0.02,1], /nocalib
          
          widget_control,kstar_shot_widg,set_value=shotnumber+1

          wait, 15
          intensity=0
          write_apd_register,PC_board,PC_REG_CALLIGHT,intensity,length=2,errormess=errormess ;Turn off the calibration light
          for i=0,14 do begin
             widget_control,kstar_status_widg,set_value='Putting filter back, getting screen out. Waiting for '+strtrim(15-i,2)+'s.'
             wait, 1
          endfor
          cmd='/home/bes/Software/BESset/bes_set 1 0' ;Put filter in
          spawn, cmd
       endif                    ; If data is available
       res=widget_event(apd_widg,/nowait)
       res=widget_event(kstar_widg,/nowait)
    endwhile
    meas_running = 0
    widget_control,kstar_status_widg,set_value='Measurement stopped'
  endif

  if (event.ID eq kstar_stop_widg) then begin
    kstar_stop_flag = 1
    if (strupcase(!version.os) eq 'WIN32') then begin
      spawn,'taskkill /F /im APDtest.exe',/hide
    endif else begin
      spawn,'killall APDTest'
    endelse
  endif
end

;*****************************************
;*       kstar_apdcam_control            *
;* /offline: do not look for camera      *
;*****************************************
pro kstar_apdcam_control,offline=offline_in
@apdcam_common.pro

program_running = 1
if (defined(offline_in)) then offline = offline_in
version = '1.00'

apd_init

font='Arial*11'
apd_widg=widget_base(title='APDCAM Main window (V'+version+')',$
          xoff=0,yoff=200,event_pro='apd_event',col=1,resource_name='apd')
apd_find_widg=widget_button(apd_widg,value='FIND')
apd_id_widg = widget_text(apd_widg,xsize=25,ysize=7,value='Not connected')
apd_reset_widg = widget_button(apd_widg,value='ADC FACT. RESET')
apd_adc_error_widg = cw_field(apd_widg,title='ADC Error:',value='',/int,xsize=3,/return_events)
apd_pc_reset_widg = widget_button(apd_widg,value='CONTROL FACT. RESET')
apd_pc_error_widg = cw_field(apd_widg,title='PC Error:',value='',/int,xsize=3,/return_events)
apd_intcount_widg = cw_field(apd_widg,title='Interrupt count:',value='0',/int,xsize=3)
apd_intcount = 0
stop_widg=widget_button(apd_widg,value='EXIT')
widget_control,apd_widg,/realize

apd_hv_widg=widget_base(title='APDCAM HV,shutter,light',xoff=0,yoff=500,event_pro='apd_event',col=1,resource_name='apd_control')
apd_control_hv_widg = widget_base(apd_hv_widg,column=1,frame=1)
apd_hvlabel_widg=widget_label(apd_control_hv_widg,value='HV Settings',/align_center)
apd_hvread_widg=widget_button(apd_control_hv_widg,value='READ HV status')
apd_control_hv1_widg = widget_base(apd_control_hv_widg,column=2)
apd_hv1val_widg = cw_field(apd_control_hv1_widg,title='HV1 set:',value='',/int,xsize=4,/return_events)
apd_hv1mon_widg = cw_field(apd_control_hv1_widg,title='HV1 act:',value=' ?? ',/int,xsize=4,/noedit)
apd_hv1max_widg = cw_field(apd_control_hv1_widg,title='HV1 max:',xsize=4,value=' ?? ',/return_events)
apd_control_hv1onoff_widg = widget_base(apd_control_hv1_widg,column=2)
apd_hv1on_widg=widget_button(apd_control_hv1onoff_widg,value='ON1')
apd_hv1off_widg=widget_button(apd_control_hv1onoff_widg,value='OFF1')
apd_hv2val_widg = cw_field(apd_control_hv1_widg,title='HV2 set:',value='',/int,xsize=4,/return_events)
apd_hv2mon_widg = cw_field(apd_control_hv1_widg,title='HV2 act:',value=' ?? ',/int,xsize=4,/noedit)
apd_hv2max_widg = cw_field(apd_control_hv1_widg,title='HV2 max:',xsize=4,value=' ?? ',/return_events)
apd_control_hv2onoff_widg = widget_base(apd_control_hv1_widg,column=2)
apd_hv2on_widg=widget_button(apd_control_hv2onoff_widg,value='ON2')
apd_hv2off_widg=widget_button(apd_control_hv2onoff_widg,value='OFF2')
apd_control_hved_widg = widget_base(apd_control_hv_widg,column=2)
apd_hvenable_widg=widget_button(apd_control_hved_widg,value='HV Enable',tooltip='Enables HV output.')
apd_hvdisable_widg=widget_button(apd_control_hved_widg,value='HV Disable',tooltip='Disables HV output.')
apd_hvedstat_widg=widget_text(apd_control_hv_widg,xsize=20,ysize=1,value='HV Disabled')

apd_control_shutter_widg = widget_base(apd_hv_widg,column=1,frame=1)
apd_shutlabel_widg=widget_label(apd_control_shutter_widg,value='Shutter control',/align_center)
apd_shutter_widg = widget_base(apd_control_shutter_widg,column=2)
apd_shopen_widg=widget_button(apd_shutter_widg,value='Open')
apd_shclose_widg=widget_button(apd_shutter_widg,value='Close')
apd_shmode_widg = cw_bgroup(apd_control_shutter_widg,['External control'],/column,/nonexclusive)

apd_callight_base_widg = widget_base(apd_hv_widg,column=1,frame=1)
apd_callight_txt_widg=widget_label(apd_callight_base_widg,value='Calibration light control',/align_center)
apd_callight_widg = cw_field(apd_callight_base_widg,title='Intensity:',value='',/int,xsize=4,/return_events)

apd_spareio_base_widg = widget_base(apd_hv_widg,column=1,frame=1)
apd_spareio_txt_widg=widget_label(apd_spareio_base_widg,value='Control outputs',/align_center)
;apd_spareio_base_widg1 = widget_base(apd_spareio_base_widg,column=2)
;apd_spareio1_widg = widget_droplist(apd_spareio_base_widg1,value=Mirror_Positions)
;apd_spareio2_widg =widget_droplist(apd_spareio_base_widg1,value=Camera_Select_States)
apd_spareio_base_widg1 = widget_base(apd_spareio_base_widg,column=1)
apd_spareio1_widg = cw_field(apd_spareio_base_widg1, title='Mirror position:',value=72000, /long,xsize=5,/return_events)
apd_spareio7_widg = cw_field(apd_spareio_base_widg1, title='Radial position [mm]:',value=2230, /long,xsize=5,/return_events)
apd_spareio2_widg = cw_field(apd_spareio_base_widg1, title='Filter position:',value=1255, /long,xsize=5,/return_events)
apd_spareio3_widg = cw_field(apd_spareio_base_widg1, title='Filter temperature:',value=50, /long,xsize=5,/return_events)
apd_spareio6_widg = cw_field(apd_spareio_base_widg1, title='APDCAM position',value=30000, /long,xsize=5,/return_events)
apd_control_apdcam_pos = widget_base(apd_spareio_base_widg1,column=2)
apd_spareio4_widg=widget_button(apd_control_apdcam_pos,value='Horizontal')
apd_spareio5_widg=widget_button(apd_control_apdcam_pos,value='Vertical')

apd_hvmess_widg=widget_text(apd_hv_widg,xsize=20,ysize=1,value=' ')

widget_control,apd_hv_widg,/realize

                                ;Read the motor positions from the stepmotor controller
spawn, '~/Software/read_motor_pos/read_motor_pos',pos

mirror_pos=long(strmid(pos[0],6,5))
focus_pos=long(strmid(pos[1],6,5))
filter_pos=long(strmid(pos[2],6,4))
apd_pos=long(strmid(pos[3],6,5))

widget_control,apd_spareio1_widg,set_value=mirror_pos
widget_control,apd_spareio2_widg,set_value=filter_pos
widget_control,apd_spareio6_widg,set_value=apd_pos

stepmotor_pos, pos=mirror_pos, R=rad_pos, /calc_R
widget_control,apd_spareio7_widg,set_value=long(rad_pos)

apd_offs_widg=widget_base(title='APD offset',xoff=100,yoff=0,event_pro='apd_offset_event',col=1)
apd_offs1_widg = widget_base(apd_offs_widg,column=33,frame=1,/grid)
apd_offs_act_widg = lonarr(32)
apd_rmsHF_act_widg = lonarr(32)
apd_rmsLF_act_widg = lonarr(32)
apd_pp_act_widg = lonarr(32)
apd_dac_widg = lonarr(32)
tmp = widget_label(apd_offs1_widg,value=' ',/align_center)
tmp = widget_label(apd_offs1_widg,value='Mean:',/align_center)
tmp = widget_label(apd_offs1_widg,value='HF:',/align_center)
tmp = widget_label(apd_offs1_widg,value='LF:',/align_center)
tmp = widget_label(apd_offs1_widg,value='PP:',/align_center)
tmp = widget_label(apd_offs1_widg,value='DAC:',/align_center)
for i=1,32 do begin
  tmp = widget_label(apd_offs1_widg,value=i2str(i),/align_center)
  apd_offs_act_widg[i-1] = widget_text(apd_offs1_widg,xsize=5,ysize=1,value=' ')
  apd_rmsHF_act_widg[i-1] = widget_text(apd_offs1_widg,xsize=5,ysize=1,value=' ')
  apd_rmsLF_act_widg[i-1] = widget_text(apd_offs1_widg,xsize=5,ysize=1,value=' ')
  apd_pp_act_widg[i-1] = widget_text(apd_offs1_widg,xsize=5,ysize=1,value=' ')
  apd_dac_widg[i-1] = widget_text(apd_offs1_widg,xsize=5,ysize=1,value=' ',/editable)
endfor

apd_offs_control_widg=widget_base(apd_offs_widg,col=5)
apd_getoffs_widg=widget_button(apd_offs_control_widg,value='Meas data')
apd_getdac_widg=widget_button(apd_offs_control_widg,value='Get DAC values')
apd_setdac_widg=widget_button(apd_offs_control_widg,value='Set all DAC outputs')
apd_setalldac_same_widg=cw_field(apd_offs_control_widg,title='Set all DAC values to:',value='  ?? ',xsize=5,/string,/return_events)
apd_offset_mess_widg=widget_text(apd_offs_control_widg,xsize=80,ysize=1,value=' ')

widget_control,apd_offs_widg,/realize

apd_data_widg=widget_base(title='APD data',xoff=100,yoff=100,event_pro='apd_data_event',col=1)
apd_dataplot_widg=widget_draw(apd_data_widg,xsize=1100,ysize=700,retain=2)
apd_data1_widg=widget_base(apd_data_widg,row=1)
apd_meas_widg=widget_button(apd_data1_widg,value='Measure')
apd_countbase_widg = widget_base(apd_data1_widg,col=5)
tmp = widget_label(apd_countbase_widg,value='Sample counts:')
apd_meas_count_widg = lonarr(4)
for i=0,3 do begin
  apd_meas_count_widg[i] = widget_text(apd_countbase_widg,value=' ?? ',xsize=8,ysize=1)
endfor
apd_meas_mess_widg=widget_text(apd_data1_widg,xsize=80,ysize=1,value=' ')
apd_meas_load_widg=widget_button(apd_data1_widg,value='Load last measurement')
;apd_stopmeas_widg = cw_bgroup(apd_data1_widg,['Stop measurement'],/column,/nonexclusive,/frame)
apd_power_widg=widget_button(apd_data1_widg,value='Plot power')
apd_data3_widg = widget_base(apd_data_widg,column=2)
apd_data2_widg=widget_base(apd_data3_widg,row=1)
apd_gaintest_base_widg = widget_base(apd_data2_widg,row=1,/frame)
apd_gain_v1_widg=cw_field(apd_gaintest_base_widg,title='Volt min:',value='150',xsize=3,/string)
apd_gain_v2_widg=cw_field(apd_gaintest_base_widg,title='Volt max:',value='350',xsize=3,/string)
apd_gain_light_widg = cw_field(apd_gaintest_base_widg,title='Light:',value=' 100',xsize=4,/string)
apd_gaintest_widg=widget_button(apd_gaintest_base_widg,value='Gain test')
apd_powerpara_widg=widget_base(apd_data3_widg,row=1,/frame)
apd_frange1_widg = cw_field(apd_powerpara_widg,title='Freq. range[Hz]:',value=' 1e2',xsize=6,/string)
apd_frange2_widg = cw_field(apd_powerpara_widg,title='',value=' 1e6',xsize=6,/string)
apd_fres_widg = cw_field(apd_powerpara_widg,title='Freq. res.[Hz]:',value=' 10',xsize=5,/string)
apd_ftype_log_widg = cw_bgroup(apd_powerpara_widg,['Log. fres'],/nonexclusive,set_value=[1])
apd_prange1_widg = cw_field(apd_powerpara_widg,title='Power. range:',value=' 1e-6',xsize=6,/string)
apd_prange2_widg = cw_field(apd_powerpara_widg,title='',value=' 1e-1',xsize=6,/string)

widget_control,apd_data_widg,/realize
widget_control,apd_dataplot_widg,get_value=plot_window

apd_temp_widg=widget_base(title='APD temperature',xoff=200,yoff=400,event_pro='apd_temp_event',col=2)
apd_temp1_widg=widget_base(apd_temp_widg,col=5,/grid_layout)
apd_temps_widg = lindgen(16)
tmp = widget_label(apd_temp1_widg,value='',/align_center)
tmp = widget_label(apd_temp1_widg,value='',/align_center)
tmp = widget_label(apd_temp1_widg,value='',/align_center)
tmp = widget_label(apd_temp1_widg,value='',/align_center)
tmp = widget_label(apd_temp1_widg,value='',/align_center)
tmp = widget_label(apd_temp1_widg,value='Temps',/align_center)
for i=0,15 do begin
  name = i2str(i+1,digit=2)
  case i of
    0: name = 'ADC1'
    1: name = 'ADC2'
    2: name = 'ADC3'
    3: name = 'ADC4'
    4: name = 'Detector'
    5: name = 'Analog panel'
    6: name = 'Detector housing'
    7: name = 'Peltier heatsink'
    8: name = 'PC card heatsink'
    14: name = 'FPGA'
    else: name = i2str(i+1,digit=2)
  endcase
  apd_temps_widg[i] = cw_field(apd_temp1_widg,title=name+':',value=' ?? ',xsize=5,/noedit,/string)
endfor
apd_weights_widg = lonarr(16,4)
apd_fanspeed_widg = lonarr(3)
apd_fanlimit_widg = lonarr(3)
apd_fancontrol_widg = lonarr(3)
apd_fanmode_widg = lonarr(3)
for j=0,3 do begin
  if (j lt 3) then begin
    tmp = widget_label(apd_temp1_widg,value='Fan'+i2str(j+1),/align_center)
    apd_fanmode_widg[j] = widget_droplist(apd_temp1_widg,value=['Auto','Manual'])
    if (j eq 0) then begin
      apd_fanspeed_widg[j] = cw_field(apd_temp1_widg,title='Speed:',value=' ?? ',xsize=5,/string,/return_events)
      widget_control,apd_fanspeed_widg[j],editable=0
      apd_fan1_diff_widg = cw_field(apd_temp1_widg,title='Diff:',value=' ?? ',xsize=5,/string,/return_events)
      apd_fanlimit_widg[j] = cw_field(apd_temp1_widg,title='Ref:',value=' ?? ',xsize=5,/string,/return_events)
      apd_fancontrol_widg[j] = cw_field(apd_temp1_widg,title='Ctrl:',value=' ?? ',xsize=5,/noedit,/string,/return_events)
    endif else begin
      apd_fanspeed_widg[j] = cw_field(apd_temp1_widg,title='Speed:',value=' ?? ',xsize=5,/string,/return_events)
      widget_control,apd_fanspeed_widg[j],editable=0
      tmp = widget_label(apd_temp1_widg,value='',xsize=5)
      apd_fanlimit_widg[j] = cw_field(apd_temp1_widg,title='Limit:',value=' ?? ',xsize=5,/string,/return_events)
      apd_fancontrol_widg[j] = cw_field(apd_temp1_widg,title='Ctrl:',value=' ?? ',xsize=5,/noedit,/string,/return_events)
    endelse
  endif else begin
    tmp = widget_label(apd_temp1_widg,value='Peltier',/align_center)
    tmp = widget_label(apd_temp1_widg,value='',xsize=5)
    apd_pelt_out_widg = cw_field(apd_temp1_widg,title='Out:',value=' ?? ',xsize=6,/noedit,/string)
    apd_pelt_ref_widg = cw_field(apd_temp1_widg,title='Ref:',value=' ?? ',xsize=5,/string,/return_events)
    tmp = widget_label(apd_temp1_widg,value='',xsize=5)
    apd_pelt_control_widg = cw_field(apd_temp1_widg,title='Ctrl:',value=' ?? ',xsize=5,/noedit,/string)
  endelse
  for i=0,15 do begin
    apd_weights_widg[i,j] = widget_text(apd_temp1_widg,xsize=4,ysize=1,value=' ',/editable)
  endfor
endfor
apd_temp2_widg=widget_base(apd_temp_widg,col=5)
apd_readtemp_widg = widget_button(apd_temp2_widg,value='Read Temps')
;apd_stoptemp_widg = widget_button(apd_temp2_widg,value='Stop Read Temps')
apd_readweights_widg = widget_button(apd_temp2_widg,value='Read Weights')

apd_temp3_widg = widget_base(apd_temp_widg,col=1)
tmp = widget_label(apd_temp3_widg,value='Peltier PID',/align_center)
apd_pelt_pfact_widg = cw_field(apd_temp3_widg,title='P:',value=' ?? ',xsize=6,/string,/return_events)
apd_pelt_ifact_widg = cw_field(apd_temp3_widg,title='I:',value=' ?? ',xsize=6,/string,/return_events)
apd_pelt_dfact_widg = cw_field(apd_temp3_widg,title='D:',value=' ?? ',xsize=6,/string,/return_events)

widget_control,apd_temp_widg,/realize

apd_timing_widg=widget_base(title='APD Timing',xoff=800,yoff=200,event_pro='apd_timing_event',col=1)
apd_timing1_widg=widget_base(apd_timing_widg,col=2)
apd_pllmult_widg = cw_field(apd_timing1_widg,title='ADC CLK mult:',value=' ?? ',xsize=3,/string,/return_events)
apd_plldiv_widg = cw_field(apd_timing1_widg,title='ADC CLK div:',value=' ?? ',xsize=3,/string,/return_events)
apd_streammult_widg = cw_field(apd_timing1_widg,title='STREAM CLK mult:',value=' ?? ',xsize=3,/string,/return_events)
apd_streamdiv_widg = cw_field(apd_timing1_widg,title='STREAM CLK div:',value=' ?? ',xsize=3,/string,/return_events)
apd_extclkmult_widg = cw_field(apd_timing_widg,title='EXT CLK mult:',value=' ?? ',xsize=3,/string,/return_events)
apd_timing1a_widg=widget_base(apd_timing_widg,col=2)
apd_extclkdiv_widg = cw_field(apd_timing1a_widg,title='EXT CLK div:',value=' ?? ',xsize=3,/string,/return_events)
apd_samplediv_widg = cw_field(apd_timing1a_widg,title='Sample div/7:',value=' ?? ',xsize=4,/string,/return_events)
apd_clksatus_widg = cw_bgroup(apd_timing1a_widg,['ADC PLL locked','STREAM PLL locked', 'EXCTCLK PLL locked'],/column,/nonexclusive,/frame)

apd_timing2_widg=widget_base(apd_timing_widg,col=3)
apd_control_widg = cw_bgroup(apd_timing2_widg,['Ext Clock','Ext clock EN', 'Ext sample','Sample out','Filt. EN','Reserved','Rev. bitorder','Preamble'],/column,/nonexclusive,/frame)
apd_timing3_widg=widget_base(apd_timing2_widg,col=1,/frame)
tmp = widget_label(apd_timing3_widg,value='FIR Filter')
apd_filtercoeff_widg = lonarr(5)
for i=1,5 do begin
  apd_filtercoeff_widg[i-1] = cw_field(apd_timing3_widg,title='Coeff'+i2str(i),value=' ?? ',xsize=5,/string,/return_events)
endfor
apd_timing4_widg=widget_base(apd_timing2_widg,col=1,/frame)
tmp = widget_label(apd_timing4_widg,value='Int Filter')
apd_filtercoeff_int_widg = cw_field(apd_timing4_widg,title='Coeff',value=' ?? ',xsize=5,/string,/return_events)
apd_filterdiv_widg = cw_field(apd_timing4_widg,title='Filter div',value=' ?? ',xsize=2,/string,/return_events)
apd_filterfreq_widg = cw_field(apd_timing_widg,title='FIR Freq.[MHz]',value=' ?? ',xsize=6,/string,/return_events)
apd_filterfreq_int_widg = cw_field(apd_timing_widg,title='Rec. Freq.[MHz]',value=' ?? ',xsize=6,/string,/return_events)
apd_filtergain_widg = cw_field(apd_timing_widg,title='Filter gain [0,1..]',value='3 ',xsize=2,/string,/return_events)


apd_triggerbase_widg = widget_base(apd_timing_widg,column=2,/frame)
apd_trigger_widg = cw_bgroup(apd_triggerbase_widg,['Trig +','Trig -', 'Max. trig'],/column,/nonexclusive,/frame)
apd_triglevel_widg = cw_field(apd_triggerbase_widg,title='Trigger level:',value=' ?? ',xsize=6,/string,/return_events)
apd_ringbufsize_widg = cw_field(apd_triggerbase_widg,title='Ring buffer:',value=' ?? ',xsize=4,/string,/return_events)
apd_inttrig_opt_widg = cw_bgroup(apd_triggerbase_widg,['Int trig en','+ trig'],/column,/nonexclusive,/frame)
apd_trigdelay_widg = cw_field(apd_triggerbase_widg,title='Trigger delay:',value=' ?? ',xsize=10,/string,/return_events)
apd_ovd_widg = widget_base(apd_timing_widg,column=2)
apd_ovdlevel_widg = cw_field(apd_ovd_widg,title='Overload level:',value=' ?? ',xsize=5,/string,/return_events)
apd_ovdtime_widg = cw_field(apd_ovd_widg,title='Overload time[mics]:',value=' ?? ',xsize=6,/string,/return_events)
apd_ovdstat_widg = cw_bgroup(apd_ovd_widg,['Overload En', 'OVR +', 'OVERLOAD'],/column,/nonexclusive,/frame)
apd_timing5_widg=widget_base(apd_timing_widg,col=2)
apd_samplenum_widg = cw_field(apd_timing5_widg,title='Sample N:',value='  ??  ',xsize=8,/string,/return_events)
apd_testpattern_widg = cw_field(apd_timing5_widg,title='Test pattern:',value='  ??  ',xsize=2,/string,/return_events)
apd_readtiming_widg = widget_button(apd_timing_widg,value='Read Timing')
widget_control,apd_timing_widg,/realize

apd_channels_widg=widget_base(title='APD Channels and resolution',xoff=1000,yoff=200,event_pro='apd_channels_event',col=1)
apd_channels1_widg = widget_base(apd_channels_widg,colum=4)
apd_ch1_widg = cw_bgroup(apd_channels1_widg,['1','2', '3','4','5','6','7','8'],/column,/nonexclusive)
apd_ch2_widg = cw_bgroup(apd_channels1_widg,['9','10', '11','12','13','14','15','16'],/column,/nonexclusive)
apd_ch3_widg = cw_bgroup(apd_channels1_widg,['17','18', '19','20','21','22','23','24'],/column,/nonexclusive)
apd_ch4_widg = cw_bgroup(apd_channels1_widg,['25','26', '27','28','29','30','31','32'],/column,/nonexclusive)
apd_channels2_widg = widget_base(apd_channels_widg,colum=2)
apd_challon_widg = widget_button(apd_channels2_widg,value='Set all on')
apd_challoff_widg = widget_button(apd_channels2_widg,value='Set all off')
apd_resolution_widg = cw_field(apd_channels_widg,title='Bits:',value='??',xsize=2,/string,/return_events)
widget_control,apd_channels_widg,/realize

kstar_widg=widget_base(title='KSTAR APDCAM control',xoff=200,yoff=600,event_pro='kstar_event',col=1,resource_name='kstar_control')
kstar_dataplot_widg=widget_draw(kstar_widg,xsize=1300,ysize=800,retain=2)
kstar_buttons_widg=widget_base(kstar_widg,row=1)
kstar_shot_widg = cw_field(kstar_buttons_widg,title='Shot:',value='0000',xsize=5,/integer,/return_events)
kstar_start_widg = widget_button(kstar_buttons_widg,value='Start measurement')
kstar_stop_widg = widget_button(kstar_buttons_widg,value='STOP measurement')
kstar_status_widg = widget_label(kstar_buttons_widg,value='Idle                                                                     ')
widget_control,kstar_widg,/realize
widget_control,kstar_dataplot_widg,get_value=kstar_plot_window

if (not keyword_set(offline)) then begin
  if (apd_find()) then begin
    read_apd_timing
    read_apd_hv
    get_apd_dac,apd_offset_mess_widg
    read_apd_weights
    read_apd_channels
    read_apd_channels
    offs = 600
    for i=0,31 do begin
      widget_control,apd_dac_widg[i],set_value=i2str(offs)
      write_apd_register,ADC_board,ADC_REG_DAC1+i*2,offs,length=2,error=e
    endfor

  endif
endif else begin
  widget_control,apd_pllmult_widg,set_value='20'
  widget_control,apd_plldiv_widg,set_value='40'
  widget_control,apd_samplediv_widg,set_value='5'
  widget_control,apd_samplenum_widg,set_value='100000'
  widget_control,apd_ch1_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_ch2_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_ch3_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_ch4_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_resolution_widg,set_value='12'
endelse
xmanager,'apdcam',apd_widg,event_handler='apd_event',/no_block
while program_running do begin
  if program_running then res=widget_event(apd_widg,/nowait)
  if program_running then res=widget_event(kstar_widg,/nowait)
  if program_running then res=widget_event(apd_channels_widg,/nowait)
  if program_running then res=widget_event(apd_timing_widg,/nowait)
  if program_running then res=widget_event(apd_temp_widg,/nowait)
  if program_running then res=widget_event(apd_offs_widg,/nowait)
  if program_running then res=widget_event(apd_data_widg,/nowait)
  if program_running then res=widget_event(apd_hv_widg,/nowait)
  wait,0.1
endwhile
  widget_control,/destroy,apd_widg
  widget_control,/destroy,apd_hv_widg
  widget_control,/destroy,apd_offs_widg
  widget_control,/destroy,apd_data_widg
  widget_control,/destroy,apd_temp_widg
  widget_control,/destroy,apd_timing_widg
  widget_control,/destroy,apd_channels_widg
  widget_control,/destroy,kstar_widg
end
