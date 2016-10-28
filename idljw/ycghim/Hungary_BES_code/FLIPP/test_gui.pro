; This is a test program do demonstrate how a GUI can be created
; which does some loop processing with the possibility of interruption
; and exit
;
; The program consists of several routines
; All shared variables should be listed in test_common.pro


;******************************************
;* TEST_EVENT.PRO                         *
;*                                        *
;* This is the event handler routine      *
;* This is called by IDL whenewer a user  *
;* interaction occurs                     *
;******************************************
pro test_event,event
@test_common.pro

if (event.ID eq startbutton_widg) then begin
  ;* This part is reached when the start button is pressed
  print,'Start button clicked.'
  ; We have to test whether a cycle is already running
  ; Failing to do so would start a new cycle, parallel to the other one which
  ; is interrupted by the user event
  if (cycle_running) then begin
    print,'Cycle is already running.'
    return
  endif
  count = 1
  stop_signal = 0
  cycle_running = 1
  print,'Cycle started'
  ; An infinite loop is started
  ; It will stop when the stop_signal flag is set by clicking the stop button or exit button
  while not stop_signal do begin
    print,'Count '+i2str(count)
    count = count+1
    wait,1
    ; We call widget event with /nowait so as it can handle user interaction
    ; IDL will call another instance of this test_event routine if a user event is waiting
    ; This program thread will resume when the widget_event finishes or no event is found.
    res = widget_event(test_widg,/nowait)
  endwhile
  print,'Cycle stopped'
  cycle_running = 0
  ; Calling cleanup if the program should exit
  if (exit_program) then test_cleanup
  return
endif

if (event.ID eq exitbutton_widg) then begin
  ; This handles the exit button
  print,'Exit button clicked.'
  ; If the cycle is running we are waiting for it to stop
  ; We cannot destroy the widget here, as the cycle would crash with an error
  if (cycle_running) then begin
    stop_signal = 1
    ; Signaling that program should be exitied.
    ; Exit will happen when the cycle stops
    exit_program = 1
    print,'Waiting for cycle to stop.'
    return
  endif

  ; Calling cleanup if the cycle was not running
  test_cleanup
  return
endif

if (event.ID eq stopbutton_widg) then begin
  ; This handles the stop button
  print,'STOP clicked.'
  ; It just sets the stop_signal flag
  stop_signal = 1
  return
endif

end

;*******************************************
;* TEST_CLEANUP.PRO                        *
;*                                         *
;* This is a cleanup routine. This should  *
;* be called wherever the program wants to *
;* exit.                                   *
;* All runnng processes should stop before *
;* calling this                            *
;*******************************************
pro test_cleanup
@test_common.pro

print,'Thank you for using this test.'

; Destroy the whole widget tree
widget_control,/destroy,test_widg

end


;********************************
;* TEST_GUI_CREATE              *
;*                              *
;* This routine creates the GUI *
;********************************
pro test_gui_create
@test_common.pro

; Set initial values
stop_signal = 0
cycle_running = 0
exit_program = 0

; Define the widget tree
test_widg=widget_base(title='test widget',$
          xoff=200,yoff=200,xsize=200,event_pro='test_event',col=1,resource_name='test')
startbutton_widg=widget_button(test_widg,value='START')
stopbutton_widg=widget_button(test_widg,value='STOP')
exitbutton_widg=widget_button(test_widg,value='EXIT')

; Create the widgets
; They are still inactive
widget_control,test_widg,/realize
end


;***************************************
;* TEST_GUI                            *
;*                                     *
;* This is the main program            *
;* It should be at the end of the file *
;* to ensure that all components are   *
;* compiled.                           *
;***************************************
pro test_gui
@test_common.pro

; Creates the GUI
test_gui_create

; Calls XMANAGER to handle user events
xmanager,'test_gui',test_widg,event_handler='test_event',/no_block

end
