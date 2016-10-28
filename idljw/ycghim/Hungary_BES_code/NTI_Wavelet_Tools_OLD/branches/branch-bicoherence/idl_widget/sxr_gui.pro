pro sxr_plot_event

  erase
  plot,dindgen(1000)

end

;=============================================================================================================================================

pro sxr_gui_event,event
@sxr_gui_common.pro

if (event.ID eq sxr_gui_startbutton_widg) then begin
  ;* This part is reached when the start button is pressed
  sxr_addmessage, addtext='Start button clicked!'
  ; We have to test whether the measurement is already running
  ; Failing to do so would start a new measurement, parallel to the other one which
  ; is interrupted by the user event
  if (measurement_running) then begin
    sxr_addmessage, addtext='Measurement is already running.'
    return
  endif

  measurement_running=1

  r = widget_info(sxr_gui_channelname_widg,/droplist_select)
  case r of
    0: begin
         channel = 'I'
       end
    1: begin
         channel = 'J'
       end
    2: begin
         channel = 'K'
       end
    3: begin
         channel = 'L'
      end
  endcase

  widget_control,sxr_gui_shotnumber_widg,get_value=shotnumber
  widget_control,sxr_gui_channelnum_widg,get_value=channelnum
  widget_control,sxr_gui_blocksize_widg,get_value=blocksize
  blocksize=long(blocksize)
  blocksize=blocksize[0]
  widget_control,sxr_gui_trange1_widg,get_value=trange1
  trange1=double(trange1)
  widget_control,sxr_gui_trange2_widg,get_value=trange2
  trange2=double(trange2)

  ch = 'AUG_SXR/'+channel+'_'+channelnum
  print,ch
  sxr_bicoherence, shotnumber, ch, [trange1,trange2], blocksize, hann=0, frequency=30
  
  sxr_plot_event
  
endif

  ;exit button
if (event.ID eq sxr_gui_exitbutton_widg) then begin
  ; This handles the exit button
  print,'Exit button clicked.'
  exit_program = 1
  return
endif

end



pro sxr_gui_create
@sxr_gui_common.pro


; Define the widget tree
sxr_gui_widg=widget_base(title='Calculate bicoherence of AUG-SXR signals',$
          xoff=0,yoff=0,event_pro='sxr_gui_event',col=1,resource_name='sxr_gui_widg') ;, /scroll, y_scroll_size=700, x_scroll_size=315)

sxr_gui_startblock_widg = widget_base(sxr_gui_widg,column=1)
im = READ_BMP('/home/horla/svn-sandbox/NTI_Wavelet_Tools/branches/branch-bicoherence/idl_widget/startbutton.bmp',/rgb)
im = TRANSPOSE(im, [1,2,0])
ysize = (size(im))[2]
sxr_gui_startbutton_widg=widget_button(sxr_gui_startblock_widg,value=im,/align_center,tooltip='Evaluate!')
sxr_gui_statustext_widg=widget_text(sxr_gui_startblock_widg,xsize=40,ysize=5,value=' ',/scroll)
sxr_gui_shotnumber_widg = cw_field(sxr_gui_startblock_widg,title='Shot number:',xsize=6,/string,fieldfont='Times*bold*42')

sxr_gui_channel_widg = widget_base(sxr_gui_startblock_widg, title='Channel',column=2)
sxr_gui_channelname_widg = widget_droplist(sxr_gui_channel_widg,value=['I','J','K','L'])
sxr_gui_channelnum_widg = cw_field(sxr_gui_channel_widg,title='Channel number',/string)

sxr_gui_other_widg = widget_base(sxr_gui_startblock_widg)
sxr_gui_blocksize_widg = cw_field(sxr_gui_other_widg,title='Blocksize',/string)

sxr_gui_trange_widg = widget_base(sxr_gui_startblock_widg,column=1,/frame)
tmp = widget_label(sxr_gui_trange_widg,value='Time Range:')
sxr_gui_trange1_widg = cw_field(sxr_gui_trange_widg,/string, title='Start time')
sxr_gui_trange2_widg = cw_field(sxr_gui_trange_widg,/string, title='End time')

sxr_gui_exitbutton_widg=widget_button(sxr_gui_widg,value='EXIT')



sxr_plot_widg=widget_base(title='Plot',xoff=100,yoff=100,event_pro='sxr_plot_event',col=1)
sxr_dataplot_widg=widget_draw(sxr_plot_widg,xsize=1100,ysize=600,retain=2)


; Create the widgets
; They are still inactive
widget_control,sxr_gui_widg,/realize
widget_control,sxr_plot_widg,/realize


end


pro sxr_gui_setdef
@sxr_gui_common.pro

  widget_control,sxr_gui_channelname_widg,set_droplist_select=1
  widget_control,sxr_gui_shotnumber_widg,set_value='24006'
  widget_control,sxr_gui_channelnum_widg,set_value='053'
  widget_control,sxr_gui_blocksize_widg,set_value='128'
  widget_control,sxr_gui_trange1_widg,set_value='1.61'
  widget_control,sxr_gui_trange2_widg,set_value='1.64'

end

;*******************************************
;* SXR_ADDMESSAGE.PRO                      *
;*                                         *
;* This extends the existing statustext    *
;* and prints to the measurement window    *
;*******************************************
pro sxr_addmessage, addtext=addtext
@sxr_gui_common.pro
  widget_control,sxr_gui_statustext_widg,get_value=statustext
  statustext=[addtext,statustext]
  widget_control,sxr_gui_statustext_widg,set_value=statustext
  return
end

pro sxr_gui_cleanup
@sxr_gui_common.pro

print,'Thank you!'

; Destroy the whole widget tree
widget_control,/destroy,sxr_gui_widg

end

pro sxr_gui
@sxr_gui_common.pro

; Set initial values

measurement_running = 0
exit_program = 0
;cycle_running = 0
;stop_signal = 0

; Creates the GUI
sxr_gui_create
; Sets defaults
sxr_gui_setdef

; Calls XMANAGER to handle user events
xmanager,'sxr_gui',sxr_gui_widg,event_handler='sxr_gui_event',/no_block
while exit_program eq 0 do begin
  res = widget_event(sxr_gui_widg,/nowait)
  wait,0.2
endwhile

sxr_gui_cleanup
end
