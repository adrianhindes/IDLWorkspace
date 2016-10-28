pro bes_camera_gui_event, event
@cmos_common.pro

  if event.ID eq plot_button_widg then begin
     widget_control, shot_widg, get_value=shot
     if defined(prev_shot) then begin
        if prev_shot ne shot then meas=0
     endif
     prev_shot=shot
     widget_control, smooth_widg, get_value=smooth_len
     widget_control, median_widg, get_value=median_width
     ;set times
     widget_control, start_time_widg, get_value=starttime
     widget_control, end_time_widg, get_value=endtime
     widget_control, offset_set_widg, get_value=offset_sub
     widget_control, offset_reverse_widg, get_value=reverse_offset
     t1=starttime
     t2=endtime
     if not (t1 eq 0 and t2 eq 0) then time=[t1,t2]
     widget_control, waittime_widg, get_value=waittime
     widget_control, overcalib_widg, get_value=overcalib
     show_kstar_bes_camera,shot,datapath=datapath,errormess=errormess,noplot=noplot,frame_times=frame_times,$
                           waittime=waittime,scale=scale,time=time,frame_numbers=frame_numbers,offset_frame=offset,data_arr=meas,$
                           thick=thick,charsize=charsize,smooth=smooth_len,median=median_width,calib=calib,$
                           overcalib=overcalib, frametime=frametime, exptime=exptime,reverse_offset=reverse_offset,$
                           offset_sub=offset_sub
  endif

  if event.ID eq make_movie_widg then begin
     widget_control, shot_widg, get_value=shot
     if defined(prev_shot) then begin
        if prev_shot ne shot then meas=0
     endif
     prev_shot = shot
     widget_control, smooth_widg, get_value=smooth_len
     widget_control, median_widg, get_value=median_width
     widget_control, mpeg_filename_widg, get_value=mpeg_filename
     ;set times
     
     show_kstar_bes_camera,shot,datapath=datapath,errormess=errormess,noplot=noplot,frame_times=frame_times,$
                           waittime=waittime,scale=scale,time=time,frame_numbers=frame_numbers,offset_frame=offset,data_arr=meas,$
                           thick=thick,charsize=charsize,mpeg_filename=mpeg_filename,smooth=smooth_len,median=median_width,calib=calib
  endif

  if event.ID eq show_oneframe_widg then begin
     widget_control, shot_widg, get_value=shot
     if defined(prev_shot) then begin
        if prev_shot ne shot then meas=0
     endif
     prev_shot = shot
     widget_control, smooth_widg, get_value=smooth_len
     widget_control, median_widg, get_value=median_width
     widget_control, frame_number_widg, get_value=frame_numbers
     widget_control, offset_frame_widg, get_value=offset
     widget_control, overcalib_widg, get_value=overcalib
     show_kstar_bes_camera,shot,datapath=datapath,errormess=errormess,noplot=noplot,frame_times=frame_times,$
                           waittime=waittime,scale=scale,time=time,frame_numbers=frame_numbers,offset_frame=offset,data_arr=meas,$
                           thick=thick,charsize=charsize,smooth=smooth_len,median=median_width,$
                           overcalib=overcalib, frametime=frametime, exptime=exptime
  endif

  if event.ID eq show_calib_image_widg then begin
     widget_control, shot_widg, get_value=shot
     shot=shot
     calib=1
     frame_number=0
     show_kstar_bes_camera,shot,datapath=datapath,errormess=errormess,noplot=noplot,frame_times=frame_times,$
                           waittime=waittime,scale=scale,time=time,frame_numbers=frame_numbers,offset_frame=offset,$
                           thick=thick,charsize=charsize,mpeg_filename=mpeg_filename,smooth=smooth_len,median=median_width,calib=calib
  endif
  if event.ID eq exit_button_widg then begin
     widget_control, cmos_widg, /destroy
  endif
end

pro show_kstar_bes_camera_gui, shot
  @cmos_common.pro
  cmos_widg=widget_base(frame=1,title='KSTAR CMOS plot',event_pro='bes_camera_gui_event',col=2,resource_name='kstar_control', xsize=1800, ysize=1180)
  cmos_settings_widg=widget_base(cmos_widg,col=1, /frame,xsize=150)
  shot_widg=       cw_field(cmos_settings_widg,          title='Shot:          ',value=shot, xsize=5, /integer, /return_events)
  start_time_widg= cw_field(cmos_settings_widg,          title='Start time:    ',value=2, xsize=5, /integer)
  end_time_widg=   cw_field(cmos_settings_widg,          title='End time:      ',value=10, xsize=5, /integer)
  frame_time_widg=cw_field(cmos_settings_widg,    title='Frame time:    ',value='', xsize=5, /integer)
  waittime_widg=cw_field(cmos_settings_widg,      title='Wait time:     ',value='', xsize=5, /integer)
  frame_number_widg=cw_field(cmos_settings_widg,  title='Frame #:       ',value='', xsize=5, /integer)
  offset_frame_widg=cw_field(cmos_settings_widg,  title='Offset frame #:',value='', xsize=5, /integer)
  offset_set_widg=cw_bgroup(cmos_settings_widg,'  Offset on/off ',/column,/nonexclusive)
  offset_reverse_widg=cw_bgroup(cmos_settings_widg,' Reverse offset ',/column,/nonexclusive)
  overcalib_widg=cw_bgroup(cmos_settings_widg, 'Overcalib on/off',/column,/nonexclusive)

  smooth_widg=cw_field(cmos_settings_widg, title='Smooth value:',value=5, xsize=5, /integer)
  median_widg=cw_field(cmos_settings_widg, title='Median filter:',value=5, xsize=5, /integer)

  plot_button_widg=widget_button(cmos_settings_widg,     value='Show all frames')
  show_oneframe_widg=widget_button(cmos_settings_widg,   value=' Show one frame')
  show_calib_image_widg=widget_button(cmos_settings_widg,value='Show calib frame')

  mpeg_frame=widget_base(cmos_settings_widg, /frame, col=1, title='MPEG file name')
  mpeg_filename_widg=cw_field(mpeg_frame,title='',value='CMOS_'+i2str(shot)+'.mpg', xsize=15)
  make_movie_widg=widget_button(mpeg_frame,value='Make MPEG movie')

  exit_button_widg=widget_button(cmos_settings_widg,     value='EXIT')


  plot_widg=widget_draw(cmos_widg,xsize=1312,ysize=1082,retain=2)
  
  widget_control, cmos_widg,/realize
  xmanager,'cmos',cmos_widg,event_handler='bes_camera_gui_event'
end
