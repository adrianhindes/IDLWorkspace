pro apd_init,errormess=errormess
@apdcam_common.pro

 errormess = ''
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

  apdcam_open,errormess=errormess
  error = long(0)
  R = CALL_EXTERNAL('CamControl.dll','idlDontSendTS', long(error), /CDECL)
end ; apd_init





pro temperature_test,file=file,time=time

; file: name of the PS file for output
; time: measurement time in s
@apdcam_common.pro

default,time,300
n_meas = time*5
apd_init,errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
end

apd_temps = fltarr(16)
for ii=0, 0 do begin
  window,ii
  start = 1
  for i=0,n_meas do begin
    print,i2str(i)+'/'+i2str(n_meas)
    ret = read_apd_register(PC_board,PC_REG_TEMP_SENSOR_1+8,length=2,error=e)
    if ((e ne '') or (n_elements(ret) lt 1)) then begin
      temp = -1
    endif else begin
      temp = float(ret)/10.
    endelse
    if (keyword_set(start)) then begin
        temp_array = temp
        start = 0
    endif else begin
      temp_array = [temp_array, temp]
      ind = where((temp_array gt 0) and (temp_array lt 25))
      if (ind[0] ge 0) then begin
        t = findgen(n_elements(temp_array))*0.2
        plotsymbol,0
        plot,t[ind],temp_array[ind],ystyle=1,xtitle='Time [s]',psym=8,thick=thick,charsize=charsize,xthick=thick,ythick=thick,charthick=thick
      endif
    endelse
    wait,0.2
  endfor
  ind = where(temp_array gt 0)
  print,i2str(ii)+'  Error: '+i2str(n_elements(temp_array)-n_elements(ind))+'  Mean:'+string(mean(temp_array[ind]),format='(F4.1)')+ $
     '  Variance: '+ string(sqrt(variance(temp_array[ind])),format='(F5.2)')
  if (defined(file)) then begin
    hardon
    thick=3
    charsize=1.5
    plotsymbol,0
    plot,t[ind],temp_array[ind],ystyle=1,xtitle='Time [s]',psym=8,thick=thick,charsize=charsize,xthick=thick,ythick=thick,charthick=thick
    hardfile,file
  endif


endfor


end