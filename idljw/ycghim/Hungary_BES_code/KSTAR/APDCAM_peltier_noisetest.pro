pro apdcam_peltier_noisetest,plotchannel=plotchannel,hv_val=hv_val,time=t,data=d

; Runs a low frequency test measurement while switching on/off Peltier cooling. The
; reference temperature of the detector should be set before running this test.

adc_mult=20
adc_div=40
samplediv=1000
meastime=10
bits=14
default,HV_val,380

DAC_VALUE=200
default,plotchannel,findgen(32)+1

; Init APDCAM

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

  print,'Opening APDCAM...'
  wait,0.1
  apdcam_open,errormess=errormess
  error = long(0)
  R = CALL_EXTERNAL('CamControl.dll','idlDontSendTS', long(error), /CDECL)

  wait,0.5
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
    txt[4] = 'Comminucation error (Control).'
  endif else begin
    if (ishft(ret[0],-5) ne 2) then begin
      txt[4] = 'No Control board present.'
    endif else begin
      ret1 = read_apd_register(PC_board,PC_REG_BOARD_SERIAL,length=2,error=e)
      if (e ne '') then begin
        txt[4] = 'Comminucation error (Control).'
      endif else begin
        txt[4] = 'Control:'
        txt[5] = '  S/N:'+ i2str(ret1)
        txt[6] = '  Fw Ver:'+ string(float(ret[2]+256L*ret[3])/100,format='(F5.2)')
        found[1] = 1
      endelse
    endelse
  endelse

  for i=0,6 do print,txt[i]
  if (total(found) eq 2) then begin
    print,'APDCAM found.'
  endif else begin
    print,'APDCAM not found.'
    return
  endelse


print,'Writing offset values...'
for ii=0,31 do begin
  write_apd_register,ADC_board,ADC_REG_DAC1+ii*2,DAC_VALUE,len=2,error=e
  if (e ne '') then begin
    print,'Communication error.'
    return
  endif
  wait,0.05
endfor
print,'...done'

  ; Enable HV
  print,'Enabling HV...'
  write_apd_register,PC_board,PC_REG_HVENABLE,hex('AB'),length=1,errormess=errormess
  if (errormess ne '') then begin
    print,'Communication error.'
    return
  endif
  ret = read_apd_register(PC_board,PC_REG_HVENABLE,length=1,error=e)
  if (e ne '') then begin
    print,'Communication error.'
    return
  endif else begin
    if (ret[0] eq hex('AB')) then begin
      print,'...done'
    endif else begin
      print,'Error writing HV enable register.'
      return
    endelse
  endelse

  print,'Setting HV value to '+i2str(HV_val)
  val = fix(fix(HV_val)/HV_CALFAC)
  write_apd_register,PC_board,PC_REG_HV1SET,val,length=2,errormess=errormess
  if (errormess ne '') then begin
    print,'Communication error.'
    return
  endif
  wait,1
  ret = read_apd_register(PC_board,PC_REG_HV1SET,length=4,/array,error=e)
  if (e ne '') then begin
      print,'Error reading HV value.'
      return
  endif else begin
    HV_act = i2str((ret[0]+256*ret[1])*HV_CALFAC)
  endelse
  print,'HV is '+i2str(HV_act)

  print,'Switching HV on'
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    print,'Communication error.'
    return
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret or hex('01')),length=1,errormess=errormess
    if (errormess ne '') then begin
      print,'Communication error.'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    print,'Communication error.'
    return
  endif else begin
    if ((ret[0] and hex('01')) ne 0) then begin
      print,'...done'
    endif else begin
      print,'Error writing HV-on bit.'
      return
    endelse
  endelse

wait, 1
  ; switching Peltier off
  write_apd_register,PC_board,PC_REG_P_GAIN,intarr(6),length=6,/array,errormess=errormess
  if (errormess ne '') then begin
    print,'Communication error.'
    return
  endif
  peltier = 0

print,'Measuring...' & wait,0.1
collect_data,ADC_mult=adc_mult,ADC_div=adc_div,samplediv=samplediv,meastime=meastime,samplenumber_out=sample_n,$
status=status,sampletime=sampletime,channel_masks=channel_masks,bits=bits,/nowait
if (status eq 0) then begin
  print,'Error in measurement.'
  return
endif
for i=0,round(meastime)+1 do begin
  ;wait,1
  if (peltier eq 0) then begin
    print,'Peltier on' & wait,0.01
    ; switching Peltier on
    write_apd_register,PC_board,PC_REG_P_GAIN,fix(50),length=2,errormess=errormess
    if (errormess ne '') then begin
      print,'Communication error.'
      return
    endif
    peltier = 1
  endif else begin
    print,'Peltier off' & wait,0.01
    ; switching Peltier off
    write_apd_register,PC_board,PC_REG_P_GAIN,intarr(6),length=6,/array,errormess=errormess
    if (errormess ne '') then begin
      print,'Communication error.'
      return
    endif
    peltier = 0
  endelse

  for j=1,10 do begin
    wait,0.2
    ret = read_apd_register(PC_board,PC_REG_PELT_CTRL,length=2,error=e)
    if (e ne '') then begin
      print,'Communication error.'
      return
    endif
    print,'Peltier ctrl: '+i2str(ret)
  endfor
endfor

  print,'Switching HV off...'
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    print,'Communication error.'
    return
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret and hex('FE')),length=1,errormess=errormess
    if (errormess ne '') then begin
      print,'Communication error.'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    print,'Communication error.'
    return
  endif else begin
    if ((ret[0] and hex('01')) eq 0) then begin
      print,'...done'
    endif else begin
      print,'Error writing HV-on bit.'
      return
    endelse
  endelse

  apdcam_close

for i=0,n_elements(plotchannel)-1 do  begin
  print,'Reading data ' & wait,0.1
  datafile = dir_f_name('data','Channel'+i2str(plotchannel[i]-1,digit=2)+'.dat')
  openr,unit,datafile,/get_lun,error=error
  if (error ne 0) then begin
    errormess = 'Error opening file: '+datafile
    print,errormess
    return
  endif
  a = assoc(unit,intarr(sample_n),0)
  d = float(reform(a[0]))/(2.^bits)*2000
  close,unit & free_lun,unit
  t = dindgen(sample_n)*sampletime
  plot,t,integ(d,t,15e-3),ystyle=1,title='Channel '+i2str(plotchannel[i])+'  smoothed to 15 ms',xtitle='Time',ytitle='Signal [mV]'
  signal_cache_add,data=d,sampletime=sampletime,start=0,name='s'+i2str(plotchannel[i])
  if (i ne n_elements(plotchannel)-1) then begin
    if (not ask('Continue')) then break
  endif
endfor


end