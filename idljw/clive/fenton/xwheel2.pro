;-----------------------------------------------------------------------
pro imval

read_gif, 'xwhim.gif', xwhim
tv, xwhim

end

;--------------------------------------------------------------------------
pro update_leds, led

smcdrv, action='status',status=status
;stat = [status[0:3],status[5:*]]
stat=status
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
common main, speed
WIDGET_CONTROL, event.id, GET_UVALUE = eventval		

    print, eventval
    IF N_ELEMENTS(eventval) EQ 0 THEN RETURN
    WIDGET_CONTROL, event.top, GET_UVALUE = Wheel
    killed = 0
    
;  This checks to see if one of the position buttons was pressed

    IF strmid(eventval, 0,3) EQ 'POS' THEN BEGIN
        WIDGET_CONTROL, /Hourglass
    
;  Calculate amount to be moved.  Display status message.
        WIDGET_CONTROL, event.id, GET_VALUE = label
        NewPos = float(strmid(eventval, 3, strlen(eventval)-3))
        NewPosDeg=NewPos*18/12000
;        print, buttonnum
        NumPos = Wheel.Num
        print, NumPos
;stop
        Amount = NewPos-Wheel.Current
        if Amount lt 0 then 
        AmountDeg = Amount*18/12000
        print, Amount + ' steps'
        print, AmountDeg + ' degrees'
        

;  Wait for stepper motor controller to be ready.
        
        smcdrv, action='atest', state=astate
        print, astate
        print, not float(astate)
;        notready = 1
        WHILE astate DO BEGIN
;            status=0            ;smcdrv, action='ready', status=status
            print, 'SMC24B not ready ...'
            wait, 1
            smcdrv, action='atest', state=astate
            print, astate
;            if status eq 0 THEN notready = 0
        END 
        
;  Give Move Command
        
        WIDGET_CONTROL, Wheel.Message, SET_VALUE = 'Moving Wheel: ' $
          +strtrim(STRING(AmountDeg),1)+' degrees'
        if NewPos eq 0 then to_lim, 'CW', fast=1
        if NewPos gt 133000 then to_lim, 'CCW', fast=1  else smcdrv, val = amount
        print, amount

; Update status panel
        update_leds, Wheel.led

;  Wait for stepper motor controller to be ready and then
;  check status register.

        wait, abs(amount)/speed + 2
; Update status panel
;        update_leds, Wheel.led
        
        
;        notready = 1
;        WHILE notready DO BEGIN
;            wait,1.
;            smcdrv, action='status',status=status
;            if not status(6) then notready=0
;        END    
        
; Update status panel
        update_leds, Wheel.led
        
;  Update current position and status label widget using degrees of
;  wheel rotation
        
        Wheel.Current = NewPos
        print, 'Position= '+string(NewPosDeg)
        WIDGET_CONTROL, Wheel.Message, SET_VALUE = 'Position = '+strtrim(string(NewPosDeg),1)+' deg' 
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

PRO xwheel2, GROUP = GROUP, BLOCK=block
common main, speed

    IF(XRegistered("xwheel") NE 0) THEN RETURN		
    IF N_ELEMENTS(block) EQ 0 THEN block=0

@xwheel2.ini                             
default, stepper, 'STEPPER_2'

;  This section initialises a number of variables that are required
;  for the program.
;  The variables and typical values are below...
;
;NumPos  = 6
;InitialPosition = 0
;LabelData = ['Fully Off (0 degrees)', $
;	   'I: -45 degrees', $
;	   'II: -90 degrees', $
;	   'III: -135 degrees', $
;	   'IV: -180 degrees', $
;	   'Fully On (-200 degrees)']
;ValueData = [0, 29970, 59940, 89910, 119880, 134000]
;stepper motor speed (in steps/second)

speed=450

;    Numcols = FIX(NumPos/10)+1
;    ButtonBase=intarr(Numcols+1)
;    BaseData=intarr(NumPos+1, 2)
;    UValueData=sindgen(NumPos+1)
;    UValueData='BUTTON'+UValueData                                    
                 
;  The widget base and controls are created here.

    xwheelbase = WIDGET_BASE(TITLE = "xwheel", /column); UVALUE=wheel, /ROW)

;    ControlBase = WIDGET_BASE(xwheelBase, /COLUMN, /FRAME)
    TitleBase = widget_base(xwheelBase, /column, /align_center)
;    null = WIDGET_LABEL(TitleBase, VALUE='')
    null = WIDGET_LABEL(TitleBase, /ALIGN_CENTER, $
                 VALUE = '2D Tomographic Ring Controller', SCR_YSIZE=50)
    null = WIDGET_BUTTON(TitleBase, VALUE = 'Quit', UVALUE = 'DONE')
;    null = WIDGET_LABEL(TitleBase, VALUE='')
    
    ActiveBase = WIDGET_BASE(xwheelBase, /row, /FRAME)
    StatusBase = widget_base(ActiveBase, /column, /frame)
;    null = WIDGET_BUTTON(ControlBase, VALUE = 'Position Control', UVALUE = 'PosCont')
;    null = WIDGET_BUTTON(ControlBase, VALUE = 'Incremental Control', UVALUE = 'IncCont')
;    null = WIDGET_BUTTON(StatusBase, VALUE = 'Reset Ring', UVALUE = 'RESET')
;    null = WIDGET_BUTTON(StatusBase, VALUE = 'Quit', UVALUE = 'DONE')
;    null = WIDGET_LABEL(StatusBase, VALUE='') 
;    null = WIDGET_LABEL(StatusBase, VALUE = 'Programmed by Adam Last - February 1999')
;    null = WIDGET_LABEL(StatusBase, VALUE = 'Changes can be made using the xwheel.ini file')

;    smcdrv, action='status',status=status
;    stat = [status[0:3],status[5:*]]
;    ; don't want to monitor 24V power
;    print,'Status vector:',stat
;    for i=0, n_elements(led)-1 do widget_control, led(i), set_value=stat(i)

    led = lonarr(8)
    value_LED1 = 1
    LED(0) = cw_led(StatusBase, /square, $
                   right_label = 'External Power', siz = 12,  value = value_LED1)
    value_LED2 = 0
    LED(1) = cw_led(StatusBase, /square, $
                   right_label = 'CW Limit (Fully Off)', siz = 12,  value = value_LED2)
    value_LED3 = 1
    LED(2) = cw_led(StatusBase, /square, $
                   right_label = 'CCW Limit (Fully On)', siz = 12,  value = value_LED3)
    value_LED4 = 0
    LED(3) = cw_led(StatusBase, /square, $
                   right_label = 'Module Active/New Command?', siz = 12,  value = value_LED4)
    value_LED5 = 1
    LED(4) = cw_led(StatusBase, /square, $
                   right_label = '24V Power Output', siz = 12,  value = value_LED5)
    value_LED6 = 1
    LED(5) = cw_led(StatusBase, /square, $
                   right_label = 'Driver Power', siz = 12,  value = value_LED6)
    value_LED7 = 0
    LED(6) = cw_led(StatusBase, /square, $
                   right_label = 'Module Active', siz = 12,  value = value_LED7)
    value_LED8 = 0
    LED(7) = cw_led(StatusBase, /square, $
                   right_label = 'Pause Mode', siz = 12,  value = value_LED8)

    null = widget_draw(StatusBase, pro_set_value='imval', /align_center) 
    null = WIDGET_LABEL(StatusBase, VALUE='')    
;    null = WIDGET_LABEL(StatusBase, VALUE='')  
;    null = WIDGET_LABEL(StatusBase, VALUE='')  
    Message = WIDGET_LABEL(StatusBase, VALUE='Initial Position', xsize=200)
;    ButtonBase[0] = WIDGET_BASE(ActiveBase, /ROW, /FRAME)
;    FOR Col = 1, NumCols DO BEGIN
;        ButtonBase[col] = WIDGET_BASE(ButtonBase[0], /COLUMN)
;    END
;   
;    FOR LoopVar = 1, NumPos DO BEGIN
;        col=FIX((LoopVar-1)/10)+1
;        BaseData(LoopVar,1)=WIDGET_BUTTON(Buttonbase[col], $
;                VALUE=LabelData[LoopVar], UVALUE=UValueData(LoopVar))
;    END
    
;   Base for Controls are done here 

    ButtonBase = widget_base(ActiveBase, /column, /frame)
    PosButton=bytarr(numpos)

    StrValDat='POS'+string(ValueData)
    for i=0, numpos-1 do begin
        PosButton(i) =widget_button(ButtonBase, Value=LabelData(i), uvalue=StrValDat(i))
        end

;    IncBase = WIDGET_BASE(ActiveBase, /COLUMN, /FRAME)
;    Null = WIDGET_LABEL(ButtonBase, VALUE = 'Incremental Control')
    Null = CW_FIELD(ButtonBase, TITLE = 'Decrease by (degrees)', VALUE = 10, XSIZE = 5)
    Null = WIDGET_BUTTON(ButtonBase, VALUE = 'Activate Decrease', UVALUE = 'IncStepB')
;    Null = WIDGET_BUTTON(IncBase, VALUE = 'Reset to Initial', UVALUE = 'IncReset')
;    StepSize_id = CW_FIELD(IncBase, TITLE = 'Step Size 0.09 *', VALUE = 20, XSIZE = 5)
    StepSize_id = 7
    Null = CW_FIELD(ButtonBase, TITLE = 'Increase by (degrees)', VALUE = 10, XSIZE = 5)
    Null = WIDGET_BUTTON(ButtonBase, VALUE = 'Activate Increase', UVALUE = 'IncStep')
;    IntBase = widget_base(ButtonBase, /row)
    null = widget_button(ButtonBase, value = 'Pause', uvalue='Pause')
    null = widget_button(ButtonBase, value = 'Resume', uvalue='Resume')
;    IncPosLabel = WIDGET_LABEL(IncBase, VALUE = 'Position not set')
;    Null = WIDGET_BUTTON(IncBase, VALUE = 'Step Backwards', UVALUE = 'IncStepB')

; This is where the structure that is passed in the Uvalue of the Main Base
; widget is initialized.
  
  wheel = {Num : NumPos, $
             Current : 0, $
             Pos : StrValDat, $
             Init : 0, $
             PosBase : ButtonBase, $
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
