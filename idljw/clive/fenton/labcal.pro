; $Id: xwheel.pro,v 1.0 1999/09/02 10:00:00 adam Exp $
;
; Copyright (c) 1999, Adam Last.  All rights reserved
; Additional mucking about, Fenton Glass. Rights!? lol
;+
; NAME:
;	labcal
;;
; INPUTS:  Required the labcal.ini file in the current directory
;
; PROCEDURE:
;	Create the 2D tomographic wheel control widget and interface
;       to the low level stepper motor controller routine. 
;
; MODIFICATION HISTORY:
;	Programmed by Adam Last January 1999.
;       Additional modification for Laboratory Calibration routine by
;       Fenton Glass. June 1999.
;-

PRO labcal_ev, event

WIDGET_CONTROL, event.id, GET_UVALUE = eventval		

    IF N_ELEMENTS(eventval) EQ 0 THEN RETURN
    
;  This checks to see if one of the position buttons was pressed

    IF strmid(eventval, 0,6) EQ 'BUTTON' THEN BEGIN
    WIDGET_CONTROL, /Hourglass
    
;  Calculate amount to be moved.  Display status message.
    WIDGET_CONTROL, event.id, GET_VALUE = label
    buttonnum = fix(strmid(eventval, strlen(eventval)-2, 2))
    WIDGET_CONTROL, event.top, GET_UVALUE = Wheel
    NumPos = Wheel.Num
    Amount = Wheel.Pos[buttonnum]-Wheel.Current
    
;  Wait for stepper motor controller to be ready.

    notready = 1
    WHILE notready DO BEGIN
       status=0;smcdrv, action='ready', status=status
       if status eq 0 THEN notready = 0
    END 
    
;  Give Move Command

    WIDGET_CONTROL, Wheel.Message, SET_VALUE = 'Moving Wheel' $
                 +STRING(Amount)+' steps'
    smcdrv, val = amount
    print, amount
;  Wait for stepper motor controller to be ready and then
;  check status register.

    notready = 1
    WHILE notready DO BEGIN
      status=0;smcdrv, action='ready', status=status
      if status eq 0 THEN notready = 0
    END    
  
;  Update current position and status label widget.

    Wheel.Current = Wheel.Pos[buttonnum]
    WIDGET_CONTROL, Wheel.Message, SET_VALUE = 'Current Position = '+Label 
    WIDGET_CONTROL, event.top, SET_UVALUE = Wheel  ;save Wheel position
    RETURN
    END

    CASE eventval OF
 
        "DONE": WIDGET_CONTROL, event.top, /DESTROY		

        "RESET": BEGIN
        END
        "IncReset": Begin
    testbase = WIDGET_BASE(TITLE = "This is a test window", /ROW); UVALUE=wheel, /ROW)

    anotherBase = WIDGET_BASE(testbase, /COLUMN, /FRAME)
    null = WIDGET_LABEL(anotherBase, VALUE='')
    null = WIDGET_LABEL(anotherBase, /ALIGN_CENTER, $
                 VALUE = 'This window actually pops up to let you know that the Reset to Initial button is a placebo', SCR_YSIZE=50)
    null = WIDGET_LABEL(anotherBase, VALUE='')
    null = WIDGET_BUTTON(anotherBase, VALUE = 'Quit', UVALUE = 'DONE')
    widget_control, testbase, /realize
            end

        ELSE: MESSAGE, "Event User Value Not Found"		

    ENDCASE

END ;============= end of labcal event handling routine task =============



;------------------------------------------------------------------------------
;	procedure labcal
;------------------------------------------------------------------------------

PRO labcal, GROUP = GROUP, BLOCK=block

    IF(XRegistered("labcal") NE 0) THEN RETURN		
    IF N_ELEMENTS(block) EQ 0 THEN block=0

@labcal.ini                             

;  This section initialises a number of variables that are required
;  for the program.

    Numcols = FIX(NumPos/10)+1
    ButtonBase=intarr(Numcols+1)
    BaseData=intarr(NumPos+1, 2)
    UValueData=sindgen(NumPos+1)
    UValueData='BUTTON'+UValueData                                    
                 
;  The widget base and controls are created here.

    labcalbase = WIDGET_BASE(TITLE = "labcal", /ROW); UVALUE=wheel, /ROW)

    ControlBase = WIDGET_BASE(labcalBase, /COLUMN, /FRAME)
    null = WIDGET_LABEL(ControlBase, VALUE='')
    null = WIDGET_LABEL(ControlBase, /ALIGN_CENTER, $
                 VALUE = '2D Tomographic Ring Controller', SCR_YSIZE=50)
    null = WIDGET_LABEL(ControlBase, VALUE='')
    Message = WIDGET_LABEL(ControlBase, $
                 VALUE='Current Position = Initial Position')
    ;null = WIDGET_BUTTON(ControlBase, VALUE = 'Position Control', UVALUE = 'PosCont')
    ;null = WIDGET_BUTTON(ControlBase, VALUE = 'Incremental Control', UVALUE = 'IncCont')
    null = WIDGET_BUTTON(ControlBase, VALUE = 'Reset Ring', UVALUE = 'RESET')
    null = WIDGET_BUTTON(ControlBase, VALUE = 'Quit', UVALUE = 'DONE')
    null = WIDGET_LABEL(ControlBase, VALUE='') 
    null = WIDGET_LABEL(ControlBase, VALUE = 'Programmed by Adam Last - February 1999')
    null = WIDGET_LABEL(ControlBase, VALUE = 'Changes can be made using the labcal.ini file')
    null = cw_led(ControlBase, left_label='LED 1', value=1)

;  Base for Controls are done here
    
    ButtonBase[0] = WIDGET_BASE(labcalBase, /ROW, /FRAME)
    FOR Col = 1, NumCols DO BEGIN
        ButtonBase[col] = WIDGET_BASE(ButtonBase[0], /COLUMN)
    END
   
    FOR LoopVar = 1, NumPos DO BEGIN
        col=FIX((LoopVar-1)/10)+1
        BaseData(LoopVar,1)=WIDGET_BUTTON(Buttonbase[col], $
                VALUE=LabelData[LoopVar], UVALUE=UValueData(LoopVar))
    END
    
;   Base for incremental Control done here

    IncBase = WIDGET_BASE(labcalBase, /COLUMN, /FRAME)
    Null = WIDGET_LABEL(IncBase, VALUE = 'Incremental Control')
    Null = CW_FIELD(IncBase, TITLE = 'Initial Position', VALUE = 10, XSIZE = 5)
    Null = WIDGET_BUTTON(IncBase, VALUE = 'Reset to Initial', UVALUE = 'IncReset')
    Null = CW_FIELD(IncBase, TITLE = 'Step Size 0.09 *', VALUE = 20, XSIZE = 5)
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
             Message : Message}

   
    WIDGET_CONTROL, labcalBase, SET_UVALUE = wheel
    WIDGET_CONTROL, labcalbase, /REALIZE			

    XManager, "labcal", labcalbase, $			
		EVENT_HANDLER = "labcal_ev", $	
		GROUP_LEADER = GROUP, $			
		NO_BLOCK=(NOT(FLOAT(block)))		

END ;==================== end of labcal main routine =======================
