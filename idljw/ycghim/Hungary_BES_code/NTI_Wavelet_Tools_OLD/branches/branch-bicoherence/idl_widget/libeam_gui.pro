;How this program works
;
;The GUI is created in libeam_gui_create
;
;The main program is libeam_gui. It calls libeam_gui_create and enters a loop calling
;libeam_gui_check_alive. This routine reads in status information and displays it the
;approproate windows. libeam_gui_check_alive switches the alive widget, so as one sees that the program is alive.
;
;libeam_gui_event is the event handler, it is called whenewer a user action occurs. It blocks all other processes
;therefore for longer lasting actions libeam_gui_check_alive should be called regularly. This also assures
;that stop button and exit button is handled.
;
;When the stop and exit button is pushed it only sets a flag. All cyclic actions should check for this and stop
;if the flag is set.
;
;   S. Zoletnik    08.10.2010




;******************************************
;* LIBEAM_GUI_EVENT.PRO                   *
;*                                        *
;* This is the event handler routine      *
;* This is called by IDL whenewer a user  *
;* interaction occurs                     *
;******************************************
pro libeam_gui_event,event
@libeam_gui_common.pro

if (event.ID eq ligui_choppermode_widg) then begin
  case event.index of
    0: begin          ; No chopping
         widget_control,ligui_chopsettings_widg,sensitive=0
         widget_control,ligui_deflsettings_widg,sensitive=0
       end
    1: begin           ; Camera chopping
         widget_control,ligui_chopsettings_widg,sensitive=0
         widget_control,ligui_deflsettings_widg,sensitive=0
       end
    2: begin           ; Fast chopping
         widget_control,ligui_chopsettings_widg,sensitive=1
         widget_control,ligui_deflsettings_widg,sensitive=0
       end
    3: begin           ; Fast deflection
         widget_control,ligui_chopsettings_widg,sensitive=0
         widget_control,ligui_deflsettings_widg,sensitive=1
       end
  endcase
  return
end ; ligui_choppermode_widg

;if (event.ID eq ligui_evalmode_widg) then begin
	;eval_buttons_old=eval_buttons
	;widget_control,ligui_evalmode_widg,get_value=eval_buttons
	;if (eval_buttons_old(0) EQ 0) and (eval_buttons(0) eq 1) then write_status_text, 'APD data plotting on'
	;write_status_text, i2str(eval_buttons)
;	;print, widget_info(ligui_evaluationblock_widg)
;	;print, eval_buttons
;	;write_status_text, i2str(eval_buttons)
	;return
;end

if (event.ID eq ligui_startbutton_widg) then begin
  ;* This part is reached when the start button is pressed
  print,'Start button clicked.'
  ; We have to test whether the measurement is already running
  ; Failing to do so would start a new measurement, parallel to the other one which
  ; is interrupted by the user event
  if (measurement_running) then begin
    print,'Measurement is already running.'
    return
  endif

  r = widget_info(ligui_choppermode_widg,/droplist_select)
  case r of
    0: begin          ; No chopping
         mode = 'None'
       end
    1: begin           ; Camera chopping
         mode = 'Chopping'
       end
    2: begin           ; Fast chopping
         mode = 'Fast_chopping'
       end
    3: begin           ; Fast deflection
         mode = 'Deflection'
      end
  endcase
  
  widget_control,ligui_cam_start_widg,get_value=camstart
  widget_control,ligui_cam_end_widg,get_value=camend
  widget_control,ligui_cam_exp_widg,get_value=camexp
  widget_control,ligui_apd_start_widg,get_value=ni_tstart
  widget_control,ligui_apd_end_widg,get_value=ni_tend
  widget_control,ligui_apd_exp_widg,get_value=ni_fsample
  widget_control,ligui_cam_wait_widg,get_value=waittime
  widget_control,ligui_chopstart_widg,get_value=fastchop_start
  widget_control,ligui_chopend_widg,get_value=fastchop_end
  widget_control,ligui_chopperiod_widg,get_value=fastchop_period
  widget_control,ligui_deflstart_widg,get_value=deflection_start
  widget_control,ligui_deflend_widg,get_value=deflection_end
  widget_control,ligui_deflperiod_widg,get_value=deflection_period
  
    r = widget_info(ligui_syncmode_widg,/droplist_select)
  case r of
    0: begin          ; TEXTOR 
         SYNC_CLOCK = 1
       end
    1: begin           ; INETRNAL
         SYNC_CLOCK = 0
       end
  endcase
  
      r = widget_info(ligui_niclockmode_widg,/droplist_select)
  case r of
    0: begin          ; EXTERNAL 
         ni_clock_source = 'EXT'
       end
    1: begin           ; INETRNAL
         ni_clock_source  = 'INT'
       end
  endcase
  
    r = widget_info(ligui_shotmode_widg,/droplist_select)
  case r of
    0: begin           ; Normal
	;default
       end
    1: begin           ; Calibration RST
	 self_trigger=0
         test=1
	 self_test=0
	 beam_test=1
       end
    2: begin           ; Calibration TEXTOR
         self_trigger=0
         test=0
	 self_test=0
	 beam_test=1
       end
    3: begin           ; Calibration rod
         self_trigger=1
         test=1
	 self_test=0
	 beam_test=0
       end
    4: begin           ; Measurement self test
         self_trigger=1
         test=0
	 self_test=1
	 beam_test=0
       end
    5: begin           ; Live preview (runs until stop button pressed or live reached)
         live=10000
       end
  endcase
  
  widget_control,ligui_evalmode_widg,get_value=eval_buttons
  if eval_buttons(1) eq 1 then cammovie_plot=1 else cammovie_plot=0
  if eval_buttons(0) eq 1 then simatic_plot=1 else simatic_plot=0
  ;if eval_buttons(2) eq 1 then apd_profile_plot=0 else apd_profile_plot=0
  
  meas_serv_gui,mode=mode,sync_clock=sync_clock,test=test,self_test=self_test,beam_test=beam_test, $
  live=live,self_trigger=self_trigger,/gui,deflection_period=deflection_period,deflection_start=deflection_start,$
  deflection_end=deflection_end,fastchop_start=fastchop_start,fastchop_end=fastchop_end,$
  fastchop_period=fastchop_period,camstart=camstart,camend=camend,camexp=camexp,ni_clock_source=ni_clock_source,$
  simatic_plot=simatic_plot,apd_profile_plot=apd_profile_plot,frames=frames,waittime=waittime,$
  timerange=timerange,channel_in=channel_in,cammovie_plot=cammovie_plot,$
  ni_tstart=ni_tstart, ni_tlength=ni_tend-ni_tstart, ni_fsample=ni_fsample
  
  stop_signal = 0

  return
  
endif

if (event.ID eq ligui_stopbutton_widg) then begin
  ;* This part is reached when the stop button is pressed
  print,'Stop button clicked.'
  stop_signal = 1
  return
endif

if (event.ID eq ligui_exitbutton_widg) then begin
  ; This handles the exit button
  print,'Exit button clicked.'
  exit_program = 1
  return
endif


if (event.ID eq ligui_alivebutton_widg) then begin
  ; This handles the exit button
  print,'Alive button clicked.'
endif

end

;*******************************************
;* LIBEAM_GUI_CLEANUP.PRO                  *
;*                                         *
;* This is a cleanup routine. This should  *
;* be called wherever the program wants to *
;* exit.                                   *
;* All runnng processes should stop before *
;* calling this                            *
;*******************************************
pro libeam_gui_cleanup
@libeam_gui_common.pro

print,'Thank you for flying the Libeam.'

; Destroy the whole widget tree
widget_control,/destroy,libeam_gui_widg

end

;*********************************
;* LIBEAM_GUI_READSTAT           *
;*                               *
;* This routine reads the status *
;*********************************
pro libeam_gui_readstat
@libeam_gui_common.pro
  ; Read shot number
  shot = read_shotnum(errorshot=errorshot)
  if (shot lt 0) then begin
    shot = '------'
  endif else begin
    shot = i2str(shot,digits=5)
  endelse
  widget_control,ligui_shotnumber_widg,set_value=shot
end

;********************************
;* LIBEAM_GUI_CREATE            *
;*                              *
;* This routine creates the GUI *
;********************************
pro libeam_gui_create
@libeam_gui_common.pro


; Define the widget tree
libeam_gui_widg=widget_base(title='TEXTOR Li-beam measurement',$
          xoff=0,yoff=0,event_pro='libeam_gui_event',col=1,resource_name='test_gui_widg') ;, /scroll, y_scroll_size=700, x_scroll_size=315)

ligui_startblock_widg = widget_base(libeam_gui_widg,column=3)
im = READ_BMP('startbutton.bmp',/rgb)
im = TRANSPOSE(im, [1,2,0])
ysize = (size(im))[2]
alive_im_1 = bytarr(ysize/5,ysize)+255
alive_im_1[ysize/5/4:ysize/5*3/4,ysize/4:ysize*3/4] = 0
alive_im_1 = CVTTOBM(alive_im_1,threshold=128)
alive_im_2 = bytarr(ysize/5,ysize)
alive_im_2[ysize/5/4:ysize/5*3/4,ysize/4:ysize*3/4] = 255
alive_im_2 = CVTTOBM(alive_im_2,threshold=128)
ligui_alivebutton_widg=widget_button(ligui_startblock_widg,value=alive_im_1,tooltip='Press to check status')
alive_im_stat = 0
ligui_startbutton_widg=widget_button(ligui_startblock_widg,value=im,/align_center,tooltip='Start the measurement')
im = READ_BMP('stopbutton.bmp',/rgb)
im = TRANSPOSE(im, [1,2,0])
ligui_stopbutton_widg=widget_button(ligui_startblock_widg,value=im,/align_center,tooltip='Stop the measurement')

ligui_statusblock_widg = widget_base(libeam_gui_widg,column=1,/frame)
ligui_shotnumber_widg = cw_field(ligui_statusblock_widg,title='Shot number:',value='000000',xsize=6,/string,/noedit,fieldfont='Times*bold*42')
ligui_statustext_widg=widget_text(ligui_statusblock_widg,xsize=40,ysize=5,value=' ',/scroll)

ligui_evaluationblock_widg = widget_base(libeam_gui_widg,row=2,/frame)
tmp = widget_label(ligui_evaluationblock_widg,value='Immediate data evaluation:')
;eval_buttons=[1,1,1]
eval_buttons=[1,0]
;ligui_evalmode_widg = cw_bgroup(ligui_evaluationblock_widg,['APD data','camera','simatic'],/row,/nonexclusive, set_value=eval_buttons)
ligui_evalmode_widg = cw_bgroup(ligui_evaluationblock_widg,['simatic','camera'],/row,/nonexclusive, set_value=eval_buttons)
ligui_cam_wait_widg = cw_field(ligui_evaluationblock_widg,title='Cam plot wait time [s]:',value='   ',xsize=5,/float)

ligui_modeblock_widg = widget_base(libeam_gui_widg,row=4,/frame )
tmp = widget_label(ligui_modeblock_widg,value='Shot mode:')
ligui_shotmode_widg = widget_droplist(ligui_modeblock_widg,value=['Normal','Calibration RST','Calibration TEXTOR','Calibration rod','Measurement self test','Live preview'])
tmp = widget_label(ligui_modeblock_widg,value='Chopper mode:')
ligui_choppermode_widg = widget_droplist(ligui_modeblock_widg,value=['No chopper','Camera sync.','Fast chop','Fast deflection'])
tmp = widget_label(ligui_modeblock_widg,value='Base timer sync:')
ligui_syncmode_widg = widget_droplist(ligui_modeblock_widg,value=['TEXTOR 1MHz','Internal'])
tmp = widget_label(ligui_modeblock_widg,value='NI clock source')
ligui_niclockmode_widg = widget_droplist(ligui_modeblock_widg,value=['External','Internal'])


ligui_camsettings_widg = widget_base(libeam_gui_widg,column=2,/frame)
tmp = widget_label(ligui_camsettings_widg,value='Camera settings')
ligui_camss_widg = widget_base(ligui_camsettings_widg,column=2)
ligui_cam_start_widg = cw_field(ligui_camsettings_widg,title='Start time [s]:',value='   ',xsize=5,/float)
ligui_cam_end_widg = cw_field(ligui_camsettings_widg,title='End time [s]::',value='   ',xsize=5,/float)
ligui_cam_exp_widg = cw_field(ligui_camsettings_widg,title='Exposure time [ms]:',value='   ',xsize=4,/float)

ligui_apdsettings_widg = widget_base(libeam_gui_widg,column=2,/frame)
tmp = widget_label(ligui_apdsettings_widg,value='APD settings')
ligui_apdss_widg = widget_base(ligui_apdsettings_widg,column=2)
ligui_apd_start_widg = cw_field(ligui_apdsettings_widg,title='Start time [s]:',value='   ',xsize=5,/float)
ligui_apd_end_widg = cw_field(ligui_apdsettings_widg,title='End time [s]::',value='   ',xsize=5,/float)
ligui_apd_exp_widg = cw_field(ligui_apdsettings_widg,title='Sampling fequecy [MHz]:',value='   ',xsize=4,/float)

ligui_chopsettings_widg = widget_base(libeam_gui_widg,column=1,/frame)
tmp = widget_label(ligui_chopsettings_widg,value='Fast chopper settings')
ligui_chopss_widg = widget_base(ligui_chopsettings_widg,column=2)
ligui_chopstart_widg = cw_field(ligui_chopss_widg,title='Start time [s]:',value='   ',xsize=5,/float)
ligui_chopend_widg = cw_field(ligui_chopss_widg,title='End time [s]:',value='   ',xsize=5,/float)
ligui_chopperiod_widg = cw_field(ligui_chopsettings_widg,title='Period time [us]:',value='   ',xsize=4,/float)

ligui_deflsettings_widg = widget_base(libeam_gui_widg,column=1,/frame)
tmp = widget_label(ligui_deflsettings_widg,value='Fast deflection settings')
ligui_deflss_widg = widget_base(ligui_deflsettings_widg,column=2)
ligui_deflstart_widg = cw_field(ligui_deflss_widg,title='Start time [s]:',value='   ',xsize=5,/float)
ligui_deflend_widg = cw_field(ligui_deflss_widg,title='End time [s]:',value='   ',xsize=5,/float)
ligui_deflperiod_widg = cw_field(ligui_deflsettings_widg,title='Period time [us]:',value='   ',xsize=4,/float)

ligui_exitbutton_widg=widget_button(libeam_gui_widg,value='EXIT')

; Create the widgets
; They are still inactive
widget_control,libeam_gui_widg,/realize

end   ;libeam_gui_create

;***************************************
;* LIBEAM_GUI_SETDEF.PRO               *
;*                                     *
;* Sets default values for the widgets *
;* Change defaults here.               *
;***************************************
pro libeam_gui_setdef
@libeam_gui_common.pro

widget_control,ligui_shotmode_widg,set_droplist_select=0;  ;Normal shot
widget_control,ligui_choppermode_widg,set_droplist_select=1;  ; Camera chopping
widget_control,ligui_syncmode_widg,set_droplist_select=0;  ; TEXTOR sync
widget_control,ligui_niclockmode_widg,set_droplist_select=0;  ; External apd clock

widget_control,ligui_cam_wait_widg,set_value=' 0.1';  ; Camera plot wait time: 0.1 s

widget_control,ligui_cam_start_widg,set_value='   0';  ; Camera start time: 0 s
widget_control,ligui_cam_end_widg,set_value='   5';  ; Camera end time: 5 s
widget_control,ligui_cam_exp_widg,set_value=' 12';  ; Camera exposure: 12 ms

widget_control,ligui_apd_start_widg,set_value='   0';  ; Camera start time: 0 s
widget_control,ligui_apd_end_widg,set_value='   5';  ; Camera end time: 5 s
widget_control,ligui_apd_exp_widg,set_value=' 2.5';  ; Camera exposure: 2.5 MHz

widget_control,ligui_chopstart_widg,set_value='    1';  ; Fast chopper start time: 1 s
widget_control,ligui_chopend_widg,set_value='    5';  ; Fast chopper end time: 5 s
widget_control,ligui_chopperiod_widg,set_value=' 4.0';  ; Fast chopper period time: 4 microsec

widget_control,ligui_deflstart_widg,set_value='    1';  ; Fast deflection start time: 1 s
widget_control,ligui_deflend_widg,set_value='    5';  ; Fast deflection end time: 5 s
widget_control,ligui_deflperiod_widg,set_value=' 2.4'  ; Fast deflection period time: 2.4 microsec


; Make calls to the event handling routine to set up the appearance of the widgets according to the defaults
r = widget_info(ligui_choppermode_widg,/droplist_select)
libeam_gui_event,{ID:ligui_choppermode_widg, index:r}
r = widget_info(ligui_shotmode_widg,/droplist_select)
libeam_gui_event,{ID:ligui_shotmode_widg, index:r}
r = widget_info(ligui_syncmode_widg,/droplist_select)
libeam_gui_event,{ID:ligui_syncmode_widg, index:r}
r = widget_info(ligui_niclockmode_widg,/droplist_select)
libeam_gui_event,{ID:ligui_syncmode_widg, index:r}

end ; libeam_gui_setdef


;***************************************
;* LIBEAM_GUI_CHECK_ALIVE              *
;*                                     *
;* This routine reads and displays     *
;* It also reverses the check sign     *
;***************************************
pro libeam_gui_check_alive
@libeam_gui_common.pro

if (alive_im_stat eq 0) then begin
  widget_control,ligui_alivebutton_widg,set_value=alive_im_2
  alive_im_stat = 1
endif else begin
  widget_control,ligui_alivebutton_widg,set_value=alive_im_1
  alive_im_stat = 0
endelse
libeam_gui_readstat
res = widget_event(libeam_gui_widg,/nowait)

end  ; libeam_gui_check_alive

;***************************************
;* STOP_MEASUREMENT	               *
;*                                     *
;* This function sends the stop signal *
;* with its return value.	       *
;***************************************

function stop_measurement
@libeam_gui_common.pro
  libeam_gui_check_alive
  return, stop_signal
end

;***************************************
;* WRITE_STATUS_TEXT                   *
;*                                     *
;* Writes text from the meas_serv_gui  *
;***************************************

pro write_status_text,str
@libeam_gui_common.pro
  libeam_gui_check_alive
  widget_control,ligui_statustext_widg,set_value=str
  return
end

;***************************************
;* LIBEAM_GUI                          *
;*                                     *
;* This is the main program            *
;* It should be at the end of the file *
;* to ensure that all components are   *
;* compiled.                           *
;***************************************
pro libeam_gui
@libeam_gui_common.pro

; Set initial values
stop_signal = 0
cycle_running = 0
exit_program = 0
measurement_running = 0


; Creates the GUI
libeam_gui_create
; Sets defaults
libeam_gui_setdef

; Calls XMANAGER to handle user events
xmanager,'libeam_gui',libeam_gui_widg,event_handler='libeam_gui_event',/no_block
while exit_program eq 0 do begin
  libeam_gui_check_alive
  wait,0.2
endwhile

libeam_gui_cleanup
end
