;--------------------------------------------------------------------------
pro update_leds, led

smcdrv, action='status',status=status
stat = [status[0:3],status[5:*]]
; don't want to monitor 24V power
print,'Status vector:',stat
for i=0, n_elements(led)-1 do widget_control, led(i), set_value=stat(i)

end

;--------------------------------------------------------------------------

; $Id: xwheel.pro,v 1.0 1999/09/02 10:00:00 adam Exp $
;
; Copyright (c) 1999, Adam Last.  All rights reserved
;
;+
; NAME:
;	xwheel
;;
; INPUTS:  Required the xwheel.ini file in the current directory
;
; PROCEDURE:
;	Create the 2D tomographic wheel control widget and interface
;       to the low level stepper motor controller routine. 
;
; MODIFICATION HISTORY:
;	Programmed by Adam Last January 1999.
;-

PRO xwheel_ev, event

WIDGET_CONTROL, event.id, GET_UVALUE = eventval		

    IF N_ELEMENTS(eventval) EQ 0 THEN RETURN
    WIDGET_CONTROL, event.top, GET_UVALUE = Wheel
    killed = 0
    
;  This checks to see if one of the position buttons was pressed

    IF strmid(eventval, 0,6) EQ 'BUTTON' THEN BEGIN
        WIDGET_CONTROL, /Hourglass
    
;  Calculate amount to be moved.  Display status message.
        WIDGET_CONTROL, event.id, GET_VALUE = label
        buttonnum = fix(strmid(eventval, strlen(eventval)-2, 2))
        NumPos = Wheel.Num
        Amount = Wheel.Pos[buttonnum]-Wheel.Current
        
;  Wait for stepper motor controller to be ready.
        
        notready = 1
        WHILE notready DO BEGIN
            status=0            ;smcdrv, action='ready', status=status
            if status eq 0 THEN notready = 0
        END 
        
;  Give Move Command
        
        WIDGET_CONTROL, Wheel.Message, SET_VALUE = 'Moving Wheel' $
          +STRING(Amount)+' steps'
        smcdrv, val = amount
        print, amount
;  Wait for stepper motor controller to be ready and then
;  check status register.
        
; Update status panel
        update_leds, Wheel.led
        
        
        notready = 1
        WHILE notready DO BEGIN
            wait,1.
            smcdrv, action='status',status=status
            if not status(6) then notready=0
        END    
        
; Update status panel
        update_leds, Wheel.led
        
;  Update current position and status label widget.
        
        Wheel.Current = Wheel.Pos[buttonnum]
        WIDGET_CONTROL, Wheel.Message, SET_VALUE = 'Current Position = '+Label 
        WIDGET_CONTROL, event.top, SET_UVALUE = Wheel ;save Wheel position
        RETURN
    END

    CASE eventval OF
 
        "IncStep":begin
            		widget_control, wheel.StepSize_id, get_val = stepsize
                        smcdrv, val = StepSize
                        print, StepSize
                  end
        "IncStepB":begin
            		widget_control, wheel.StepSize_id, get_val = stepsize
                        smcdrv, val = -StepSize
                        print, StepSize
                  end
        "IncReset": Print,'Not installed'

        "DONE": begin
print, 'Quitting Xwheel Tomographics Wheel Controller'
           killed=1B
           WIDGET_CONTROL, event.top, /DESTROY		

        end

        "RESET": begin
            print, 'Hello!!!'
                                ;  Wheel Current is ...
            Amount = -Wheel.Current
            smcdrv, val = Amount
            print, 'resetting from',STRING(Wheel.Current)
            
;  This set of commands moves the ring CCW until the switch is triggered
            REPEAT BEGIN
                smcdrv, action='status', state=state
                smcdrv, val=-100
                print, 'repeating -100'
                ENDREP UNTIL (state = 44)
                print, 'Found limit switch'
                smcdrv, val=100

        end

        ELSE: MESSAGE, "Event User Value Not Found"		

    ENDCASE

; Update status panel
    if not killed then update_leds, Wheel.led

        
END ;============= end of xwheel event handling routine task =============



;------------------------------------------------------------------------------
;	procedure xwheel
;------------------------------------------------------------------------------

PRO xwheel, GROUP = GROUP, BLOCK=block

    IF(XRegistered("xwheel") NE 0) THEN RETURN		
    IF N_ELEMENTS(block) EQ 0 THEN block=0

@xwheel.ini                             

;  This section initialises a number of variables that are required
;  for the program.

    Numcols = FIX(NumPos/10)+1
    ButtonBase=intarr(Numcols+1)
    BaseData=intarr(NumPos+1, 2)
    UValueData=sindgen(NumPos+1)
    UValueData='BUTTON'+UValueData                                    
                 
;  The widget base and controls are created here.

    xwheelbase = WIDGET_BASE(TITLE = "xwheel", /ROW); UVALUE=wheel, /ROW)

;    ControlBase = WIDGET_BASE(xwheelBase, /COLUMN, /FRAME)
    TitleBase = widget_base(xwheelBase, /row, /frame)
    null = WIDGET_LABEL(TitleBase, VALUE='')
    null = WIDGET_LABEL(TitleBase, /ALIGN_CENTER, $
                 VALUE = '2D Tomographic Ring Controller', SCR_YSIZE=50)
    null = WIDGET_LABEL(TitleBase, VALUE='')
    
    StatusBase = WIDGET_BASE(xwheelBase, /COLUMN, /FRAME)

    Message = WIDGET_LABEL(StatusBase, $
                 VALUE='Current Position = Initial Position')
    ;null = WIDGET_BUTTON(ControlBase, VALUE = 'Position Control', UVALUE = 'PosCont')
    ;null = WIDGET_BUTTON(ControlBase, VALUE = 'Incremental Control', UVALUE = 'IncCont')
    null = WIDGET_BUTTON(StatusBase, VALUE = 'Reset Ring', UVALUE = 'RESET')
    null = WIDGET_BUTTON(StatusBase, VALUE = 'Quit', UVALUE = 'DONE')
    null = WIDGET_LABEL(StatusBase, VALUE='') 
    null = WIDGET_LABEL(StatusBase, VALUE = 'Programmed by Adam Last - February 1999')
    null = WIDGET_LABEL(StatusBase, VALUE = 'Changes can be made using the xwheel.ini file')
    
;  Base for Controls are done here

    led = lonarr(7)
    value_LED1 = 1
    LED(0) = cw_led(StatusBase, /square, $
                   right_label = 'External Power', siz = 12,  value = value_LED1)
    
    value_LED2 = 0
    LED(1) = cw_led(StatusBase, /square, $
                   right_label = 'CW Limit', siz = 12,  value = value_LED2)
    value_LED3 = 1
    LED(2) = cw_led(StatusBase, /square, $
                   right_label = 'CCW Limit', siz = 12,  value = value_LED3)
    
    value_LED4 = 0
    LED(3) = cw_led(StatusBase, /square, $
                   right_label = 'Module Active/New Command?', siz = 12,  value = value_LED4)
    value_LED5 = 1
    LED(4) = cw_led(StatusBase, /square, $
                   right_label = 'Driver Power', siz = 12,  value = value_LED5)
    
    value_LED6 = 0
    LED(5) = cw_led(StatusBase, /square, $
                   right_label = 'Module Active', siz = 12,  value = value_LED6)

    value_LED7 = 0
    LED(6) = cw_led(StatusBase, /square, $
                   right_label = 'Pause Mode', siz = 12,  value = value_LED7)

    ButtonBase[0] = WIDGET_BASE(xwheelBase, /ROW, /FRAME)
    FOR Col = 1, NumCols DO BEGIN
        ButtonBase[col] = WIDGET_BASE(ButtonBase[0], /COLUMN)
    END
   
    FOR LoopVar = 1, NumPos DO BEGIN
        col=FIX((LoopVar-1)/10)+1
        BaseData(LoopVar,1)=WIDGET_BUTTON(Buttonbase[col], $
                VALUE=LabelData[LoopVar], UVALUE=UValueData(LoopVar))
    END
    
;   Base for incremental Control done here

    IncBase = WIDGET_BASE(xwheelBase, /COLUMN, /FRAME)
    Null = WIDGET_LABEL(IncBase, VALUE = 'Incremental Control')
    Null = CW_FIELD(IncBase, TITLE = 'Initial Position', VALUE = 10, XSIZE = 5)
    Null = WIDGET_BUTTON(IncBase, VALUE = 'Reset to Initial', UVALUE = 'IncReset')
    StepSize_id = CW_FIELD(IncBase, TITLE = 'Step Size 0.09 *', VALUE = 20, $
                    XSIZE = 5)
    Null = WIDGET_BUTTON(IncBase, VALUE = 'Step Forwards', UVALUE = 'IncStep')
    IncPosLabel = WIDGET_LABEL(IncBase, VALUE = 'Position not set')
    Null = WIDGET_BUTTON(IncBase, VALUE = 'Step Backwards', UVALUE = 'IncStepB')

; This is where the structure that is passed in the Uvalue of the Main Base
; widget is initialized.
  
  wheel = {Num : NumPos, $
             Current : 0, $
             Pos : ValueData, $
             Init : 0, $
             PosBase : ButtonBase[0], $
             IncControlUp : 0, $
             StepSize_id: StepSize_id, $
             Message : Message,  $
             LED: led $
}

   
    WIDGET_CONTROL, xwheelBase, SET_UVALUE = wheel
    WIDGET_CONTROL, xwheelbase, /REALIZE			

    update_leds, wheel.led

    XManager, "xwheel", xwheelbase, $			
		EVENT_HANDLER = "xwheel_ev", $	
		GROUP_LEADER = GROUP, $			
		NO_BLOCK=(NOT(FLOAT(block)))		

END ;==================== end of xwheel main routine =======================
