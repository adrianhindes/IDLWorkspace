;*********************************
;* APD_SETMAX_HV1	             *
;*                               *
;* This routine sets the maximal *
;* HV1 to GUI value				 *
;*********************************
pro apd_setmax_HV1
@apdcam_common.pro
	if not(keyword_set(offline)) then begin
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
	endif else begin
	  return
	endelse
end

;*********************************
;* APD_SET_HV1	             	 *
;*                               *
;* This routine sets the HV1 to  *
;* GUI value  					 *
;*********************************
pro apd_set_HV1
@apdcam_common.pro
	if not(keyword_set(offline)) then begin
	  widget_control,apd_hv1val_widg,get_value=r
	  val = fix(fix(r)/HV_CALFAC)
	  write_apd_register,PC_board,PC_REG_HV1SET,val,length=2,errormess=errormess
	  if (errormess ne '') then begin
	    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
	    return
	  endif
	  read_apd_hv
  	endif else begin
	  return
	endelse
end

;*********************************
;* APD_ENABLE_HV	               *
;*                               *
;* This routine enables the HV   *
;*********************************
pro apd_enable_HV
@apdcam_common.pro
	  ;enabling HV
	if not(keyword_set(offline)) and (keyword_set(HV_enable)) then begin
      write_apd_register,PC_board,PC_REG_HVENABLE,hex('AB'),length=1,errormess=errormess
      if (errormess ne '') then begin
        statustext='Comm. error'
        apd_addmessage,addtext=statustext
        widget_control,apd_hvmess_widg,set_value=statustext
        return
      endif
      ret = read_apd_register(PC_board,PC_REG_HVENABLE,length=1,error=e)
      if (e ne '') then begin
        statustext='Comm. error'
        apd_addmessage,addtext=statustext
        widget_control,apd_hvmess_widg,set_value=statustext
      endif else begin
        if (ret[0] eq hex('AB')) then begin
          statustext='  '
          apd_addmessage,addtext=statustext
          widget_control,apd_hvmess_widg,set_value=statustext
          statustext='HV Enabled'
          apd_addmessage,addtext=statustext
          widget_control,apd_hvmess_widg,set_value=statustext
        endif else begin
          statustext='Error HV enable ('+i2str(ret[0])+')'
          apd_addmessage,addtext=statustext
          widget_control,apd_hvmess_widg,set_value=statustext
        endelse
      endelse
      read_apd_hv
   	endif else begin
	  return
	endelse
end ;end enabling HV

;*********************************
;* APD_TURNON_HV1	             *
;*                               *
;* This routine turns on the     *
;* HV in APD 1			         *
;*********************************
pro apd_turnon_HV1
@apdcam_common.pro
	if not(keyword_set(offline)) and (keyword_set(HV_enable)) then begin
	  ;turning on HV
      ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
      if (e ne '') then begin
        statustext='HV Comm. error'
        apd_addmessage,addtext=statustext
        widget_control,apd_hvmess_widg,set_value=statustext
      endif else begin
        write_apd_register,PC_board,PC_REG_HVON,(ret or hex('01')),length=1,errormess=errormess
        if (errormess ne '') then begin
          statustext='HV Comm. error'
          apd_addmessage,addtext=statustext
          widget_control,apd_hvmess_widg,set_value=statustext
          return
        endif
      endelse
      ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
      if (e ne '') then begin
        statustext='HV Comm. error'
        apd_addmessage,addtext=statustext
        widget_control,apd_hvmess_widg,set_value=statustext
      endif else begin
        if ((ret[0] and hex('01')) ne 0) then begin
          statustext='HV1 on.'
          apd_addmessage,addtext=statustext
          widget_control,apd_hvmess_widg,set_value=statustext
        endif else begin
          statustext='Error HV1 on.'
          apd_addmessage,addtext=statustext
          widget_control,apd_hvmess_widg,set_value=statustext
        endelse
      endelse
      read_apd_hv
   	endif else begin
	  return
	endelse
end ;end turning on HV

;*********************************
;* APD_TURNOFF_HV1	             *
;*                               *
;* This routine turns off the    *
;* HV in APD 1			             *
;*********************************
pro apd_turnoff_HV1
@apdcam_common.pro
	if not(keyword_set(offline)) then begin
	  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
	  if (e ne '') then begin
	    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
	  endif else begin
	    write_apd_register,PC_board,PC_REG_HVON,(ret and hex('FE')),length=1,errormess=errormess
	    if (errormess ne '') then begin
	      widget_control,apd_hvmess_widg,set_value='HV Comm. error'
	      return
	    endif
	  endelse
	  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
	  if (e ne '') then begin
	    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
	  endif else begin
	    if ((ret[0] and hex('01')) eq 0) then begin
	      widget_control,apd_hvmess_widg,set_value='HV1 off.'
	    endif else begin
	      widget_control,apd_hvmess_widg,set_value='Error HV1 off.'
	    endelse
	  endelse
	  read_apd_hv
   	endif else begin
	  return
	endelse
end

;*********************************
;* APD_FIND(function)            *
;*                               *
;* This routine looks for the    *
;* ADC cards in the apdcam       *
;* Returns 1 if both cards found *
;*********************************
function apd_find
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
  widget_control,apd_id_widg,set_value=txt
  check_errors
  if (total(found) eq 2) then begin
    return,1
  endif else begin
  	statustext=['ERROR finding the camera,','for details check main window']
    apd_addmessage,addtext=statustext
    return,0
  endelse
end  ; apd_find

;***************************************
;* apd_parameters_set.PRO              *
;*                                     *
;* This reads the GUI parameters, and  *
;* loads them on the APDCAM            *
;* If something is set by default, that*
;* parameter should be added here     *
;* either                              *
;***************************************
pro apd_parameters_set
@apdcam_common.pro

waittime=0.1

widget_control,apd_pllmult_widg,get_value=v
write_apd_register,ADC_board,ADC_REG_ADCCLKMUL,fix(v),len=1,errormess=errormess
wait,waittime

widget_control,apd_plldiv_widg,get_value=v
write_apd_register,ADC_board,ADC_REG_ADCCLKDIV,fix(v),len=1,errormess=errormess
wait,waittime

widget_control,apd_extclkmult_widg,get_value=v
write_apd_register,ADC_board,ADC_REG_EXTCLKMUL,fix(v),len=1,errormess=errormess
wait,waittime

widget_control,apd_extclkdiv_widg,get_value=v
write_apd_register,ADC_board,ADC_REG_EXTCLKDIV,fix(v),len=1,errormess=errormess
wait,waittime

widget_control,apd_samplediv_widg,get_value=v
write_apd_register,ADC_board,ADC_REG_ADSAMPLEDIV,long(v)*7,len=2,errormess=errormess
meas_samplediv = long(v)
wait,waittime

widget_control,apd_trigdelay_widg,get_value=v
write_apd_register,ADC_board,ADC_REG_TRIGDELAY,ulong(v),len=4,errormess=errormess
wait,waittime

widget_control,apd_samplenum_widg,get_value=v
write_apd_register,ADC_board,ADC_REG_SAMPLECNT,long(v),len=4,errormess=errormess
meas_samplenum = long(v)
wait,waittime

widget_control,apd_trigger_widg,get_value=v
val = 0
mask = 1
for i=0,2 do begin
  if (v[i] ne 0) then val = val or mask
  mask = ishft(mask,1)
endfor
write_apd_register,ADC_board,ADC_REG_TRIGGER,val,len=1,errormess=errormess
wait,waittime
print, val

widget_control,apd_control_widg,get_value=v
val = 0
mask = 1
for i=0,7 do begin
  if (v[i] ne 0) then val = val or mask
  mask = ishft(mask,1)
endfor
write_apd_register,ADC_board,ADC_REG_CONTROL,val,len=1,errormess=errormess
wait,waittime
print, val

set_apd_dac,apd_offset_mess_widg
wait,waittime

apd_setmax_HV1
wait,waittime

apd_set_HV1
wait,waittime

end

;***************************************
;* set_textor_defaults.PRO             *
;*                                     *
;* Sets default values for the textor  *
;* measurement                         *
;* Change defaults here.               *
;***************************************
pro set_textor_defaults;,meas_mode=meas_mode
@apdcam_common.pro
    ;setting up textor cxrs defaults
  default,meas_mode,'self_test'

  if meas_mode EQ 'startup' then begin
  ;(external 1MHz clock, 1MHz sampling freq., 0-1s)
  	test=0
  	selftest=0

    starttime=0
    endtime=5
    sampling_freq_in=1
    extclkmult=20
    extclkdiv=1
    pllmult=20
    plldiv=40
    streammult=30
    streamdiv=10
    samplediv=10

    timingcontrol_array=[0,0,0,0,0,0,0,1]
    trig_array=[1,0,0]

    filterfreq=0.5
    filterfreq_int=1

    setalldac_same=900

    sampling_freq=sampling_freq_in*1e6
    trigerdelay=ext_clock_sign_freq*1e6*extclkmult/float(extclkdiv)*starttime
    samplediv=ext_clock_sign_freq*1e6*extclkmult/float(extclkdiv)*pllmult/float(plldiv)/sampling_freq
    meas_samplenum=sampling_freq*(endtime-starttime)

    ;libeam_gui_event,{ID:ligui_choppermode_widg, index:0}
  endif

  if meas_mode EQ 'test' then begin
	test=1
	self_test=0

	starttime=0
    endtime=0.1
    sampling_freq_in=1
    extclkmult=20
    extclkdiv=1
    pllmult=20
    plldiv=40
    streammult=30
    streamdiv=10
    ;samplediv=10

    timingcontrol_array=[0,0,0,0,0,0,0,1]
    ;trig_array=[1,0,0]
    trig_array=[0,0,0]

    filterfreq=1
    filterfreq_int=1

    setalldac_same=900

    sampling_freq=sampling_freq_in*1e6
    trigerdelay=int_clock_sign_freq*1e6*starttime
    samplediv=int_clock_sign_freq*1e6*pllmult/float(plldiv)/sampling_freq
    meas_samplenum=sampling_freq*(endtime-starttime)
    ;libeam_gui_event,{ID:ligui_choppermode_widg, index:1}
  endif

  if meas_mode EQ 'self_test' then begin
  	test=0
	self_test=1

	starttime=0
    endtime=0.1
    sampling_freq_in=1
    extclkmult=20
    extclkdiv=1
    pllmult=20
    plldiv=40
    streammult=30
    streamdiv=10
    ;samplediv=10

    timingcontrol_array=[0,0,0,0,0,0,0,1]
    trig_array=[0,0,0]

    filterfreq=1
    filterfreq_int=1

    setalldac_same=900

    sampling_freq=sampling_freq_in*1e6
    trigerdelay=int_clock_sign_freq*1e6*starttime
    samplediv=int_clock_sign_freq*1e6*pllmult/float(plldiv)/sampling_freq
    meas_samplenum=sampling_freq*(endtime-starttime)

    ;apd_gui_event,{ID:ligui_choppermode_widg, index:2}
  endif


    widget_control,apd_start_widg,set_value=starttime
    widget_control,apd_end_widg,set_value=endtime
    widget_control,apd_exp_widg,set_value=sampling_freq_in
    widget_control,apd_extclkmult_widg,set_value=fix(extclkmult)
    widget_control,apd_extclkdiv_widg,set_value=fix(extclkdiv)
    widget_control,apd_pllmult_widg,set_value=fix(pllmult)
    widget_control,apd_plldiv_widg,set_value=fix(plldiv)
    widget_control,apd_samplediv_widg,set_value=fix(samplediv)
    widget_control,apd_streammult_widg,set_value=fix(streammult)
    widget_control,apd_streamdiv_widg,set_value=fix(streamdiv)
    widget_control,apd_trigdelay_widg,set_value=long(trigerdelay)
    widget_control,apd_samplenum_widg,set_value=long(meas_samplenum)

    widget_control,apd_trigger_widg,set_value=trig_array
    widget_control,apd_control_widg,set_value=timingcontrol_array

    widget_control,apd_filterfreq_widg,set_value=filterfreq
    widget_control,apd_filterfreq_int_widg,set_value=filterfreq_int

    widget_control,apd_setalldac_same_widg,set_value=i2str(setalldac_same)
    for i=0,31 do begin
      widget_control,apd_dac_widg[i],set_value=i2str(setalldac_same)
    endfor
;stop
	widget_control,apd_hv1max_widg,set_value=HV1_max
	wait,0.1
	widget_control,apd_hv1mon_widg,get_value=HV1_measured
	wait,0.1
	widget_control,apd_hv1val_widg,set_value=HV1_cycle
	wait,0.1

  val=intarr(2)
  if HV_enable EQ 0 then begin
    val[0]=0
  endif else begin
    if HV_enable EQ 1 then begin
      val[0]=1
    endif
  endelse
  if shutter_open_enable EQ 0 then begin
   val[1]=0
  endif else begin
    if shutter_open_enable EQ 1 then begin
      val[1]=1
    endif
  endelse

  widget_control,apd_hv_shutter_chkbox_widg,set_value=val

end

;***************************************
;* APDCAM_SETDEF.PRO                   *
;*                                     *
;* Sets default values for the widgets *
;* after starting the program          *
;* Change defaults here for offline    *
;* mode, and in 7et_textor_defaults    *
;* for measurement mode                *
;***************************************
pro apdcam_setdef;,meas_mode=meas_mode
@apdcam_common.pro

if (not keyword_set(offline)) then begin
;stop
  if (apd_find()) then begin
    read_apd_timing
    read_apd_hv
    get_apd_dac,apd_offset_mess_widg
    read_apd_weights
    read_apd_channels
  endif
  if keyword_set(load_textor_defaults)then begin
    set_textor_defaults;,meas_mode=meas_mode
    apd_parameters_set
  endif
endif else begin
  set_textor_defaults;,meas_mode=meas_mode
endelse

end ; APDCAM_SETDEF.pro

;*******************************************
;* APD_ADDMESSAGE.PRO                      *
;*                                         *
;* This extends the existing statustext    *
;* and prints to the measurement window    *
;*******************************************
pro apd_addmessage, addtext=addtext
@apdcam_common.pro
  widget_control,apd_statustext_widg,get_value=statustext
  statustext=[addtext,statustext]
  widget_control,apd_statustext_widg,set_value=statustext
  return
end

;*******************************************
;* APD_CLEANUP.PRO                         *
;*                                         *
;* This is a cleanup routine. This should  *
;* be called wherever the program wants to *
;* exit.                                   *
;* All runnng processes should stop before *
;* calling this                            *
;*******************************************
pro apd_cleanup
@apdcam_common.pro
    widget_control,/destroy,apd_measurement_widg
    widget_control,/destroy,apd_widg
    widget_control,/destroy,apd_hv_widg
    widget_control,/destroy,apd_offs_widg
    widget_control,/destroy,apd_data_widg
    widget_control,/destroy,apd_temp_widg
    widget_control,/destroy,apd_timing_widg
    widget_control,/destroy,apd_channels_widg
    apdcam_close
    print,'EXIT command arrived. See you somewhere else in timespace!'
    return
end

;***************************************
;* STOP_MEASUREMENT                    *
;*                                     *
;* This function sends the stop signal *
;* with its return value.              *
;***************************************
function stop_measurement
@apdcam_common.pro
  apd_check_alive
  return, stop_signal
end

;***************************************
;* APD_CHECK_ALIVE                     *
;*                                     *
;* This routine calls the event        *
;* handler routines                    *
;* It also reverses the check sign     *
;***************************************
pro apd_check_alive
@apdcam_common.pro

if (alive_im_stat eq 0) then begin
  widget_control,apd_alivebutton_widg,set_value=alive_im_2
  alive_im_stat = 1
endif else begin
  widget_control,apd_alivebutton_widg,set_value=alive_im_1
  alive_im_stat = 0
endelse
if (not keyword_set(test)) and (not keyword_set(self_test)) then apd_readstat
;apd_readstat
res = widget_event(apd_measurement_widg,/nowait)
res = widget_event(apd_timing_widg,/nowait)
res = widget_event(apd_hv_widg,/nowait)
res = widget_event(apd_offs_widg,/nowait)
res = widget_event(apd_widg,/nowait)
res = widget_event(apd_data_widg,/nowait)
res = widget_event(apd_channels_widg,/nowait)
res = widget_event(apd_temp_widg,/nowait)

end  ; apd_check_alive

;*********************************
;* APD_READSTAT                  *
;*                               *
;* This routine reads the        *
;* shotnumber                    *
;*********************************
pro apd_readstat
@apdcam_common.pro
  ; Read shot number
  shotnumber = read_shotnum(errorshot=errorshot)
  if (shotnumber lt 0) then begin
    shotnumber = '------'
  endif else begin
    shotnumber = i2str(shotnumber,digits=5)
  endelse
  widget_control,apd_shotnumber_widg,set_value=shotnumber
end ; end of apd_readstat

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
  R = CALL_EXTERNAL('CamControl.dll','idlGetPDIIrqCount', long(irqCount), /CDECL)
  apd_intcount = apd_intcount + irqCount
  widget_control,apd_intcount_widg,set_value=i2str(apd_intcount)
end  ; check_errors

;*********************************
;* READ_APD_TIMING.PRO           *
;*                               *
;* This routine reads the        *
;* settings of the timing from   *
;* the apdcam                    *
;*********************************
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
  if ((ret[0] and hex('01')) ne 0) then v[0] = 1
  if ((ret[0] and hex('02')) ne 0) then v[1] = 1
  if ((ret[1] and hex('04')) ne 0) then v[2] = 1
  widget_control,apd_clksatus_widg,set_value=v
end  ; read_apd_timing


;*********************************
;* READ_APD_TEMPS.PRO            *
;*                               *
;* This routine reads the        *
;* settings of the temperature   *
;* control from the apdcam       *
;*********************************
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

;*********************************
;* READ_APD_WEIGHTS.PRO          *
;*                               *
;* This routine reads the        *
;* settings of the fan           *
;* control from the apdcam       *
;*********************************
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

;*********************************
;* READ_APD_HV.PRO               *
;*                               *
;* This routine reads the        *
;* settings of the HV, shutter   *
;* and the calibration lights    *
;* from the apdcam               *
;*********************************
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

end  ; read_apd_hv

;*********************************
;* GET_APD_DAC.PRO               *
;*                               *
;* This routine reads the        *
;* settings of the DAC from the  *
;* apdcam                        *
;*********************************
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

;*********************************
;* SET_APD_DAC.PRO               *
;*                               *
;* This routine writes the       *
;* settings of the DAC from the  *
;* GUI to the apdcam             *
;*********************************
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

;*********************************
;* GET_APD_OFFSET.PRO            *
;*                               *
;* This routine makes a          *
;* measurement to calculate the  *
;* offset of each detector       *
;*********************************
pro get_apd_offset
@apdcam_common.pro

ret = do_apd_measurement(apd_offset_mess_widg,data_out=measdata,samplecount=meas_samplenum-2000,sampletime=sampletime)
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
end ;get_apd_offset

;*********************************
;* APD_MEAS_EVENT.PRO            *
;*                               *
;* This routine handles the      *
;* events of the measurement     *
;* Also makes plots in the data  *
;* window                        *
;*********************************
pro apd_meas_event,event
@apdcam_common.pro

if (event.ID eq apd_exit_widg) then begin
  print,'Exit button clicked.'
  if not(keyword_set(offline)) then begin
	  apd_turnoff_HV1
	  write_apd_register,PC_board,PC_REG_SHSTATE,0,length=1,errormess=errormess
	  if (errormess ne '') then begin
		apd_addmessage,addtext='Error closing shutter'
	   	return
	  endif
  endif
  exit_program = 1
  return
  ;apd_cleanup
endif

if (event.ID eq apd_alivebutton_widg) then begin
  ; This handles the exit button
  statustext='Alive button clicked.'
  apd_addmessage,addtext=statustext
endif

if (event.ID eq apd_stopbutton_widg) then begin
  ;* This part is reached when the stop button is pressed
  statustext='Stop button clicked.'
  apd_addmessage,addtext=statustext
  if not(cycle_running) then begin
      statustext='Measurement cycle is not running.'
      apd_addmessage,addtext=statustext
  endif else begin
	  stop_signal=1
	  cycle_running=0
	  measurement_running=0
  endelse
  return
endif

if (event.ID eq apd_loadtextor_widg) then begin
  meas_mode='startup'
  set_textor_defaults;,meas_mode='startup'
  apd_parameters_set
  statustext='Default TEXTOR parameters loaded'
  apd_addmessage,addtext=statustext
  return
endif

if (event.ID eq apd_startbutton_widg) then begin
  if (cycle_running) then begin
    statustext='Measurement cycle is already running.'
    apd_addmessage,addtext=statustext
    return
  endif else begin
    statustext='Start button clicked.'
    apd_addmessage,addtext=statustext
    cycle_running=1
	stop_signal=0
    if not(defined(offline)) then begin
    	;turn HV on
    	widget_control,apd_hv1val_widg,set_value=HV1_meas
    	wait,0.1
		apd_set_HV1
		wait,0.1
		apd_enable_HV
		wait,0.1
		apd_turnon_HV1
		wait,0.1
		if shutter_open_enable EQ 1 then begin
			;open shutter
			write_apd_register,PC_board,PC_REG_SHSTATE,1,length=1,errormess=errormess
	  		if (errormess ne '') then begin
	    		apd_addmessage,addtext='Error opening shutter'
	    		return
	  		endif
	  	endif else begin
	  		apd_addmessage,addtext='Shutter opening disabled!'
	  	endelse
    endif ;not offline

    ;shotnumber handling
    ;stop
    if keyword_set(test) then begin
       restore, 'calib_shotnum.sav'
       calib_shotnum=calib_shotnum+1
       ;save, filename='calib_shotnum.sav', calib_shotnum
       shotnumber=calib_shotnum
    endif else begin
      if keyword_set(self_test) then begin
         shotnumber=1
      endif else begin
         newshotnum=read_shotnum(errorshot=errorshot)
         IF (n_elements(errorshot) NE 0) THEN BEGIN
            statustext='The Shot number server is not available'
            apd_addmessage,addtext=statustext
            statustext='Check network or try making testhot'
            apd_addmessage,addtext=statustext
            statustext=['Have a nice day anyway :)']
            apd_addmessage,addtext=statustext
            ;newshotnum=1
            stop_signal=1
            cycle_running=0
            return
         ENDIF

         restore, 'last_created_shotnum.sav'

         IF (newshotnum NE shotnumber) THEN BEGIN
            shotnumber=newshotnum
            statustext='New shotnum arrived'
            apd_addmessage,addtext=statustext
         ENDIF ELSE BEGIN
            statustext='No new shotnum'
            apd_addmessage,addtext=statustext
         ENDELSE



      endelse
   endelse
   SAVE, FILENAME='last_created_shotnum.sav', shotnumber;,test
   statustext='Current shotnr: '+i2str(shotnumber)
   apd_addmessage,addtext=statustext
   widget_control,apd_shotnumber_widg,set_value=shotnumber
   ;end shotnumber handling

   if make_dirs(shotnumber,errormess=errormess,appliance=appliance,datapath=datapath) EQ -1 then begin
   	statustext=errormess
    apd_addmessage,addtext=statustext
    cycle_running=0
    stop_signal=1
    return
   endif else begin
    statustext='Directory structure ready.'
    apd_addmessage,addtext=statustext

  	;starting measurement cycle
    while (1) do begin

      ;stop
      bits = 14
      if ((meas_samplenum le 0) OR not(defined(meas_samplenum))) then begin
        statustext='No sample number is set.'
        widget_control,apd_meas_mess_widg,set_value=statustext
        apd_addmessage,addtext=statustext
        statustext='Stopping measurement.'
        apd_addmessage,addtext=statustext
        stop_signal=1
        cycle_running=0
        return
      endif

  	  if (do_apd_measurement(apd_meas_mess_widg,data_out=data_out,time_out=time_out,bits=bits,$
          channel_masks=channel_masks,samplecount=meas_samplenum-5000,load_only=load_only) eq 0) then begin
          statustext='Measurement failed, beter luck next time dude!:)'
          widget_control,apd_meas_mess_widg,set_value=statustext
          stop_signal=1
          cycle_running=0
          return
      endif else begin

		save,filename=datapath+'\'+i2str(shotnumber)+'_data.sav',time_out,data_out,bits,channel_masks,samplecount
		statustext='Data saved to: '+datapath+'\'
    	apd_addmessage,addtext=statustext

		if keyword_set(test) then begin
	       ;calib_shotnum=calib_shotnum+1
	       save, filename='calib_shotnum.sav', calib_shotnum
	    endif

		;saving configuration
		widget_control,apd_meas_mess_widg,set_value='Reading and saving settings of the camera'
    	write_apdcam_config

    ;plotting data
    restore,filename='apd_map_2.sav'
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
    	      chn=apd_map[iadc,ich]
    	      if (iadc eq 0) then ytickname='' else ytickname=replicate('  ',20)
			  ;plot,time_out,data_out[iadc*8+ich,*],xrange=xrange,xstyle=1,/noerase,$
			  plot,time_out,data_out[chn-1,*],xrange=xrange,xstyle=1,/noerase,$
    	      pos=[0.09+iadc*xstep,0.98-(ich+1)*ystep,0.09+(iadc+0.8)*xstep,0.98-(ich+0.2)*ystep],$
    	      yrange=[-2^(bits-4),2^bits+2^(bits-4)],ystyle=1,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,charsize=0.8,$
    	      title=i2str(iadc*8+ich+1)
    	    endif
    	  endfor
    	endfor

    	  meas_timerange = [min(time_out),max(time_out)]

	      if (keyword_set(test) OR keyword_set(self_test)) then begin
	          statustext='Measurement cycle stops after 1 cycle in test and selftest mode!'
	          apd_addmessage,addtext=statustext
	          cycle_running=0
	          measurement_running=0
	          stop_signal=1
	      endif else begin
	          statustext='Resarting, and getting ready the system for the next shot...'
	          apd_addmessage,addtext=statustext
	          newshotnum=read_shotnum(errorshot=errorshot)

    		  restore, 'last_created_shotnum.sav'

    		  IF (newshotnum NE shotnumber) THEN BEGIN
       			shotnumber=newshotnum
      			statustext='New shotnum arrived'
       			apd_addmessage,addtext=statustext
       			SAVE, FILENAME='last_created_shotnum.sav', shotnumber
       		  	if make_dirs(shotnumber,errormess=errormess,appliance=appliance,datapath=datapath) EQ -1 then begin
   					tatustext=errormess
    				apd_addmessage,addtext=statustext
    				cycle_running=0
    				top_signal=1
    				return
   			    endif else begin
    				statustext='Directory structure ready.'
    				apd_addmessage,addtext=statustext
    		  	endelse
    		  ENDIF ELSE BEGIN
       			statustext='No new shotnum'
      			apd_addmessage,addtext=statustext
      	        cycle_running=0
	            measurement_running=0
	            stop_signal=1
    	      ENDELSE

	      endelse
	    endelse

      if (stop_measurement()) then begin
        statustext='Measurement aborted.'
        apd_addmessage,addtext=statustext
        widget_control,apd_hv1val_widg,set_value=HV1_cycle
		apd_set_HV1
		;apd_turnoff_HV1
        wait,0.5
        ;close shutter
        write_apd_register,PC_board,PC_REG_SHSTATE,0,length=1,errormess=errormess
  		if (errormess ne '') then begin
    		apd_addmessage,addtext='Error closing shutter'
    		return
  		endif
        cycle_running=0
        measurement_running=0
        stop_signal=0
        break
      endif
    endwhile

   endelse
  endelse
endif

if (event.ID eq apd_hv_shutter_chkbox_widg) then begin
  widget_control,event.ID,get_value=val
  if val[0] EQ 0 then begin
    HV_enable=0
  endif else begin
    if val[0] EQ 1 then begin
      HV_enable=1
    endif
  endelse
  if val[1] EQ 0 then begin
   shutter_open_enable=0
  endif else begin
    if val[1] EQ 1 then begin
      shutter_open_enable=1
    endif
  endelse
endif
if (event.ID eq apd_measmode_widg) then begin
  r = widget_info(apd_measmode_widg,/droplist_select)
  case r of
    0: begin          ; Startup and default TEXTOR measurement settings (ext.clk.,ext.trig.,textor shotnumber)
    	 meas_mode = 'startup'
         set_textor_defaults;,meas_mode = 'startup'
         apd_parameters_set
       end
    1: begin           ; test settings (int.clk.,ext.trigger,calibration shotnumber)
    	 meas_mode = 'test'
         set_textor_defaults;,meas_mode = 'test'
         apd_parameters_set
       end
    2: begin           ; self test settings (int.clk.,no wait for trigger, shotnumber=1)
    	 meas_mode = 'self_test'
         set_textor_defaults;,meas_mode = 'self_test'
         apd_parameters_set
       end
  endcase
endif

if ((event.ID eq apd_start_widg) OR (event.ID eq apd_end_widg) OR (event.ID eq apd_exp_widg)) then begin
  ;read_apd_timing ;to be sure, that we have correct data in the gui

  widget_control,apd_start_widg,get_value=starttime
  widget_control,apd_end_widg,get_value=endtime
  widget_control,apd_exp_widg,get_value=sampling_freq_in
  widget_control,apd_extclkmult_widg,get_value=extclkmult
  widget_control,apd_extclkdiv_widg,get_value=extclkdiv
  widget_control,apd_pllmult_widg,get_value=pllmult
  widget_control,apd_plldiv_widg,get_value=plldiv
  widget_control,apd_samplediv_widg,get_value=samplediv
  widget_control,apd_streammult_widg,get_value=streammult
  widget_control,apd_streamdiv_widg,get_value=streamdiv
  widget_control,apd_trigdelay_widg,get_value=i2strtrigerdelay
  widget_control,apd_samplenum_widg,get_value=meas_samplenum

  widget_control,apd_trigger_widg,get_value=trig_array
  widget_control,apd_control_widg,get_value=timingcontrol_array
  if (starttime GT endtime) then begin
    statustext='End time must be greater than start time!'
    apd_addmessage,addtext=statustext
    widget_control,apd_start_widg,set_value='0'
    widget_control,apd_end_widg,set_value='1'
    return
  endif

  if (sampling_freq_in GT max_sampl_freq) then begin
    statustext='Maximal sampling frequecy is '+i2str(max_sampl_freq)+'MHz!'
    apd_addmessage,addtext=statustext
    widget_control,apd_exp_widg,set_value='1'
    return
  endif

  if (starttime LT 0) then begin
    statustext='Start time must be GE 0!'
    apd_addmessage,addtext=statustext
    widget_control,apd_start_widg,set_value='0'
    return
  endif

  if timingcontrol_array[0] EQ 1 then clock_sign_freq=ext_clock_sign_freq*float(extclkmult)/float(extclkdiv)
  if timingcontrol_array[0] EQ 0 then clock_sign_freq=int_clock_sign_freq

  sampling_freq=float(sampling_freq_in)*1e6
  trigerdelay=clock_sign_freq*1e6*float(starttime)
  samplediv=clock_sign_freq*1e6*float(pllmult)/float(plldiv)/sampling_freq
  meas_samplenum=sampling_freq*(float(endtime)-float(starttime))
  widget_control,apd_start_widg,set_value=starttime
  widget_control,apd_end_widg,set_value=endtime
  widget_control,apd_exp_widg,set_value=sampling_freq_in
  widget_control,apd_samplediv_widg,set_value=long(samplediv)
  widget_control,apd_trigdelay_widg,set_value=long(trigerdelay)
  widget_control,apd_samplenum_widg,set_value=long(meas_samplenum)

  apd_parameters_set
  ;stop
  return
endif


end ;apd_meas_event

;*********************************
;* APD_DATA_EVENT.PRO            *
;*                               *
;* This routine handles the      *
;* events of the data evaluation *
;* widget.                       *
;* Also makes plots in the       *
;* data window                   *
;*********************************
pro apd_data_event,event
@apdcam_common.pro

;if ((event.ID eq apd_startbutton_widg) or (event.ID eq apd_meas_load_widg)) then begin
if (event.ID eq apd_meas_load_widg) then begin
    load_only = 1
    widget_control,apd_samplenum_widg,get_value=v
    meas_samplenum = long(v)
    restore, 'last_created_shotnum.sav'
    ;stop
  if (do_apd_measurement(apd_meas_mess_widg,data_out=data_out,time_out=time_out,bits=bits,$
    channel_masks=channel_masks,samplecount=meas_samplenum-5000,load_only=load_only) eq 0) then return

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

endif ;end of apd_meas_load_widg event

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
      widget_control,apd_meas_mess_widg,set_value='HV Comm. error setting voltage.'
      return
    endif
    ;waiting for voltage to stabilise
    wait,2
    read_apd_hv

    ; Setting light to 0
    write_apd_register,PC_board,PC_REG_CALLIGHT,0,length=2,errormess=errormess
    if (errormess ne '') then begin
     widget_control,apd_meas_mess_widg,set_value='HV Comm. error setting light level'
     return
    endif
    read_apd_hv

    ; Doing offset measurement
    if (do_apd_measurement(apd_meas_mess_widg,data_out=data_out,time_out=time_out,bits=bits,channel_masks=channel_masks,$
      samplecount=meas_samplenum-2000,sampletime=sampletime) eq 0) then return
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
     widget_control,apd_meas_mess_widg,set_value='HV Comm. error setting light level'
     return
    endif
    read_apd_hv

    ; Doing light measurement
    if (do_apd_measurement(apd_meas_mess_widg,data_out=data_out,time_out=time_out,bits=bits,channel_masks=channel_masks,samplecount=meas_samplenum-2000) eq 0) then return
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
      widget_control,apd_meas_mess_widg,set_value='HV Comm. error reading voltage.'
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
    widget_control,apd_meas_mess_widg,set_value='HV Comm. error setting voltage.'
    return
  endif
  wait,1
  read_apd_hv

  save,signals,offsets,data,noise_signals,noise_offsets,bits,volts,light,temps,file='gaintest.sav'

  hardon
  proc_apdcam_gaintest,thick=3
  hardfile,'Gain_test.ps'
  spawn,'start Gain_test.ps'

endif; end of apd_gaintest_widg
check_errors
end  ; apd_data_event

;**********************************************
;*         apd_plot_power                     *
;* Plots power spectra of data in cache       *
;**********************************************
pro apd_plot_power
@apdcam_common.pro
  restore,filename='apd_map_2.sav'

	restore,'default_path.sav'
	if test EQ 0 then begin
	datapath=default_path+i2str(shotnumber)+'\results\'
	plotpath=default_path+i2str(shotnumber)+'\plots\'
	endif else begin
		if test EQ 1 then begin
			datapath=default_path+'calibration\'+i2str(shotnumber)+'\results\'
			plotpath=default_path+'calibration\'+i2str(shotnumber)+'\plots\'
		endif
	endelse
	;stop

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

  if STRUPCASE(FILE_SEARCH(datapath+'spect.sav')) EQ STRUPCASE(datapath+'spect.sav') then begin
	restore,filename=datapath+'spect.sav'

  endif else begin
	  if (v[0] ne 0) then begin
	    ftype = 1
	  endif else begin
	    ftype = 0
	  endelse
	  for iadc=0,3 do begin
	    for ich=0,7 do begin
	      chn = iadc*8+ich+1
	      widget_control,apd_meas_mess_widg,set_value='Calculating power, ch '+i2str(chn)
	      fluc_correlation,0,timerange=meas_timerange,refchan='cache/ADC'+i2str(chn),fres=fres,frange=frange,ftype=ftype,outpower=p,outfscale=f,errormess=e,/noplot,/silent,interval_n=1
	      if (e eq '') then begin
	        if (not defined(p_vect)) then begin
	          p_vect = fltarr(32,n_elements(p))
	        endif
	        p_vect[chn-1,*] = p
	        ch_mask[chn-1] = 1
	      endif else begin
	        widget_control,apd_meas_mess_widg,set_value=e
	      endelse
	    endfor
	  endfor
	  save, filename=datapath+'spect.sav',f,p_vect,ch_mask
  endelse

;stop
  if (total(ch_mask) ne 0) then begin
    for iadc=0,3 do begin
      first = 1
      for ich=7,0,-1 do begin
       	;chn = iadc*8+ich+1
       	chn=apd_map[iadc,ich]
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

hardon
	for iadc=0,3 do begin
      first = 1
      for ich=7,0,-1 do begin
        ;chn = iadc*8+ich+1
        chn=apd_map[iadc,ich]
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
          pos=[0.09+iadc*xstep,0.95-(ich+1)*ystep,0.09+(iadc+0.8)*xstep,0.98-(ich+0.2)*ystep],$
          yrange=prange,ystyle=1,ytype=1,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,charsize=0.8,$
          title=i2str(chn)
        endif
      endfor
endfor
print,plotpath+i2str(shotnumber)+'_spectplot.ps'
hardfile,plotpath+i2str(shotnumber)+'_spectplot.ps'

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

if (event.ID eq apd_ch_cxrs_widg) then begin
  widget_control,apd_ch1_widg,set_value=[1,0,0,0,0,0,0,0]
  widget_control,apd_ch2_widg,set_value=[1,1,1,1,1,1,1,1]
  widget_control,apd_ch3_widg,set_value=[1,0,0,0,0,0,0,0]
  widget_control,apd_ch4_widg,set_value=[1,0,0,0,0,0,0,0]
  write_apd_register,ADC_board,ADC_REG_CHENABLE1,[1,255,1,1],/array,errormess=errormess
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

;*********************************
;* APD_EVENT.PRO                 *
;*                               *
;* This routine handles the      *
;* events of the APD main widget *
;*********************************
pro apd_event,event
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
  apd_enable_HV
endif

if (event.ID eq apd_hv1on_widg) then begin
  apd_turnon_HV1
endif

if (event.ID eq apd_hv1off_widg) then begin
  apd_turnoff_HV1
endif

if (event.ID eq apd_hv2on_widg) then begin
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret or hex('02')),length=1,errormess=errormess
    if (errormess ne '') then begin
      widget_control,apd_hvmess_widg,set_value='HV Comm. error'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
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
    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
  endif else begin
    write_apd_register,PC_board,PC_REG_HVON,(ret and hex('FD')),length=1,errormess=errormess
    if (errormess ne '') then begin
      widget_control,apd_hvmess_widg,set_value='HV Comm. error'
      return
    endif
  endelse
  ret = read_apd_register(PC_board,PC_REG_HVON,length=1,error=e)
  if (e ne '') then begin
    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
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
	apd_set_HV1
endif

if (event.ID eq apd_hv2val_widg) then begin
  widget_control,apd_hv2val_widg,get_value=r
  val = fix(fix(r)/HV_CALFAC)
  write_apd_register,PC_board,PC_REG_HV2SET,val,length=2,errormess=errormess
  if (errormess ne '') then begin
    widget_control,apd_hvmess_widg,set_value='HV Comm. error'
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
	apd_setmax_HV1
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

check_errors
end  ; END apd_event

;*********************************
;* APD_INIT.PRO                  *
;*                               *
;* This routine handles the data *
;* conversion between the        *
;* programme variables and the   *
;* apdcam registers              *
;*********************************
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

  apd_temp_weights = lonarr(16,4) ; The actual control weights
  apd_temps = lonarr(16)  ; The actual temps
  fanmode = intarr(3) ; 0: auto, 1: manual

  apdcam_open,errormess=errormess
  error = long(0)
  R = CALL_EXTERNAL('CamControl.dll','idlDontSendTS', long(error), /CDECL)

end ; apd_init

;*********************************
;* APD_TEMP_EVENT.PRO                 *
;*                               *
;* This routine handles the      *
;* events of the temperature     *
;* widget.                        *
;*********************************
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

;*********************************
;* APD_TIMING_EVENT.PRO          *
;*                               *
;* This routine handles the      *
;* events of the timing widget   *
;*********************************
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

end ;apd_timing_event.pro

;*****************************************
;* APDCAM_CREATE.PRO                     *
;* this rutine crates the GUI            *
;*****************************************
pro apdcam_create
@apdcam_common.pro

version = '2.00'

apd_init

font='Arial*11'

;*****************************************
;* Creating the main window              *
;*****************************************
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

widget_control,apd_widg,/realize

;*****************************************
;* Creating the HV window                *
;*****************************************
apd_hv_widg=widget_base(title='APDCAM HV,shutter,light',xoff=0,yoff=500,event_pro='apd_event',col=1,resource_name='apd_create')
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

apd_hvmess_widg=widget_text(apd_hv_widg,xsize=20,ysize=1,value=' ')

widget_control,apd_hv_widg,/realize

;*****************************************
;* Creating the offset window            *
;*****************************************
apd_offs_widg=widget_base(title='APD offset',xoff=100,yoff=0,event_pro='apd_offset_event',col=1,/scroll)
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

;*****************************************
;* Creating the data evaluation window   *
;*****************************************
apd_data_widg=widget_base(title='APD data',xoff=100,yoff=100,event_pro='apd_data_event',col=1)
apd_dataplot_widg=widget_draw(apd_data_widg,xsize=1100,ysize=600,retain=2)
apd_data1_widg=widget_base(apd_data_widg,row=1)
;apd_meas_widg=widget_button(apd_data1_widg,value='Measure')
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

;*****************************************
;* Creating the temperature window       *
;*****************************************
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

;*****************************************
;* Creating the timing window            *
;*****************************************
apd_timing_widg=widget_base(title='APD Timing',xoff=800,yoff=200,event_pro='apd_timing_event',col=2)
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
;apd_samplenum_widg = cw_field(apd_timing5_widg,title='Sample N:',value='  ??  ',xsize=8,/string,/return_events)
apd_samplenum_widg = cw_field(apd_timing5_widg,title='Sample N (not editable):',value='  ??  ',xsize=8,/string)
apd_testpattern_widg = cw_field(apd_timing5_widg,title='Test pattern:',value='  ??  ',xsize=2,/string,/return_events)
apd_readtiming_widg = widget_button(apd_timing_widg,value='Read Timing')
widget_control,apd_timing_widg,/realize

;*****************************************
;* Creating the channel selection window *
;*****************************************
apd_channels_widg=widget_base(title='APD Channels and resolution',xoff=1000,yoff=200,event_pro='apd_channels_event',col=1)
apd_channels1_widg = widget_base(apd_channels_widg,colum=4)
apd_ch1_widg = cw_bgroup(apd_channels1_widg,['1','2', '3','4','5','6','7','8'],/column,/nonexclusive)
apd_ch2_widg = cw_bgroup(apd_channels1_widg,['9','10', '11','12','13','14','15','16'],/column,/nonexclusive)
apd_ch3_widg = cw_bgroup(apd_channels1_widg,['17','18', '19','20','21','22','23','24'],/column,/nonexclusive)
apd_ch4_widg = cw_bgroup(apd_channels1_widg,['25','26', '27','28','29','30','31','32'],/column,/nonexclusive)
apd_channels2_widg = widget_base(apd_channels_widg,colum=3)
apd_challon_widg = widget_button(apd_channels2_widg,value='Set all on')
apd_challoff_widg = widget_button(apd_channels2_widg,value='Set all off')
apd_ch_cxrs_widg = widget_button(apd_channels2_widg,value='Setup for cxrs')
apd_resolution_widg = cw_field(apd_channels_widg,title='Bits:',value='??',xsize=2,/string,/return_events)
widget_control,apd_channels_widg,/realize


;*****************************************
;* Creating the measurement window       *
;*****************************************
apd_measurement_widg=widget_base(title='APDCAM Measurement Startblock (V'+version+')',$
          xoff=0,yoff=0,event_pro='apd_meas_event',col=1,resource_name='apd_measurement')
apd_startblock_widg = widget_base(apd_measurement_widg,column=3)
im = READ_BMP('startbutton.bmp',/rgb)
im = TRANSPOSE(im, [1,2,0])
ysize = (size(im))[2]
alive_im_1 = bytarr(ysize/5,ysize)+255
alive_im_1[ysize/5/4:ysize/5*3/4,ysize/4:ysize*3/4] = 0
alive_im_1 = CVTTOBM(alive_im_1,threshold=128)
alive_im_2 = bytarr(ysize/5,ysize)
alive_im_2[ysize/5/4:ysize/5*3/4,ysize/4:ysize*3/4] = 255
alive_im_2 = CVTTOBM(alive_im_2,threshold=128)
apd_alivebutton_widg=widget_button(apd_startblock_widg,value=alive_im_1,tooltip='Press to check status')
alive_im_stat = 0
apd_startbutton_widg=widget_button(apd_startblock_widg,value=im,/align_center,tooltip='Start the measurement')
im = READ_BMP('stopbutton.bmp',/rgb)
im = TRANSPOSE(im, [1,2,0])
apd_stopbutton_widg=widget_button(apd_startblock_widg,value=im,/align_center,tooltip='Stop the measurement')

apd_loadtextor_widg=widget_button(apd_measurement_widg,value='Load default TEXTOR parameters')

apd_hv_shutter_widg = widget_base(apd_measurement_widg,colum=2)
apd_hv_shutter_chkbox_widg = cw_bgroup(apd_hv_shutter_widg,['Enable APD HV','Enable Shutter'],colum=2,/nonexclusive)

apd_statusblock_widg = widget_base(apd_measurement_widg,column=1,/frame)
apd_shotnumber_widg = cw_field(apd_statusblock_widg,title='Shot number:',value='000000',xsize=6,/string,/noedit,fieldfont='Times*bold*42')
apd_statustext_widg=widget_text(apd_statusblock_widg,xsize=40,ysize=10,value=' ',/scroll)

apd_modeblock_widg = widget_base(apd_measurement_widg,row=1,/frame,/align_center )
tmp = widget_label(apd_modeblock_widg,value='Measurement mode:')
apd_measmode_widg = widget_droplist(apd_modeblock_widg,value=['TEXTOR(ext.clk.,ext.trig,shotnum)','Test(int.clk.,ext.trig,testshotnum)','Self test(int.clk.,no trig.,shotnum1)'],/frame)

apdsettings_widg = widget_base(apd_measurement_widg,column=2,/frame)
;apdss_widg = widget_base(apdsettings_widg,column=1)
tmp = widget_label(apdsettings_widg,value='APD settings')
;apdss_widg = widget_base(apdsettings_widg,column=2)
apd_exp_widg = cw_field(apdsettings_widg,title='Sampling fequecy [MHz]:',value='   ',xsize=4,/float,/return_events)
apd_start_widg = cw_field(apdsettings_widg,title='Start time [s]:',value='   ',xsize=5,/float,/return_events)
apd_end_widg = cw_field(apdsettings_widg,title='End time [s]:',value='   ',xsize=5,/float,/return_events)

apd_exit_widg=widget_button(apd_measurement_widg,value='EXIT')
widget_control,apd_measurement_widg,/realize

end ;apd_create

;***************************************
;* APDCAM_CONTROL                      *
;*                                     *
;* This is the main program            *
;* It should be at the end of the file *
;* to ensure that all components are   *
;* compiled.                           *
;*/offline: do not look for camera     *
;***************************************
pro apdcam_control, offline=offline_in, load_textor_defaults=load_textor_defaults_in
@apdcam_common.pro

default,appliance,'textor'
;default,default_path,'d:\APDCAM\'+appliance+'\'
default,load_textor_defaults_in,1
default,ext_clock_sign_freq,1 ;(external TEXTOR clock signal frequency [MHz])
default,int_clock_sign_freq,20 ;internal clock frequency [MHz]
default,max_sampl_freq,2 ;Maximal sampling freqency frequency [MHz]
;default,HV1_max,400
;default,HV1_cycle,250
;default,HV1_meas,330
;stop
restore,'default_path.sav'

if (defined(offline_in)) then offline = offline_in
if (defined(load_textor_defaults_in)) then load_textor_defaults = load_textor_defaults_in

; Set initial values
HV1_max=400
HV1_cycle=250
HV1_meas=330
test=0
self_test=0
shutter_open_enable=1
HV_enable=1
stop_signal = 0
cycle_running = 0
exit_program = 0
measurement_running = 0

; Creates the GUI
  apdcam_create
  apdcam_setdef
  read_apd_timing

; turning on HV on start
;stop
  apd_enable_HV
  apd_turnon_HV1

; Calls XMANAGER to handle user events
xmanager,'apdcam_control',apd_measurement_widg,event_handler='apd_meas_event',/no_block
while exit_program eq 0 do begin
  apd_check_alive
  wait,0.5
endwhile

apd_cleanup

end