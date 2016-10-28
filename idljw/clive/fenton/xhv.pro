@data_plot:[moss_control]sy127drv
@data_plot:[moss_control]xhv_allocation
@data_plot:[moss_control]read_sy127
@data_plot:[moss_control]write_sy127
; $Id: xhv.pro,v 1.0 1999/09/02 10:00:00 adam Exp $
;
; Copyright (c) 1999, Adam Last.  All rights reserved
;
;+
; NAME:
;	xhv
;
; INPUTS:  Required the xhv.ini file in the current directory
;
; PROCEDURE:
;	Create an IDL Widget Setup to control the High Voltage Power
;        Supply.
;
; MODIFICATION HISTORY:
;	Programmed by Adam Last January 1999
;			     February 1999
;-

;=====================================================================
;  This routine is to update the voltage scales.
;  hv is a structure with the status and voltage or the channels
;  Pointers to the DrawWidgets, the ButtonWidgets and the indices of the 
;  draw widgets.
  
PRO xhv_update, hv, nowrite=nowrite;,  map = map

  disp = intarr(hv.Xsize,hv.YSize)
  xx = intarr(hv.Xsize)  &  xx(*)=1
  widget_control,  hv.xhvbase,  update = 0
  changed =  where(hv.Old_Voltage ne hv.Voltage or hv.Old_Onstat ne hv.Onstat)
  n_c =  n_elements(changed)
;  print, 'Changed:', changed
;  print, 'Old_onstat:', hv.old_onstat
;  print, 'onstat:', hv.onstat
;  print, 'Old_volts:', hv.old_voltage
;  print, 'volts:', hv.voltage

  if changed(0) ne -1 then begin
     FOR l = 0, n_c - 1 DO BEGIN
; FOR k = 0, hv.NumChan - 1 DO BEGIN
        k =  changed(l)
        WIDGET_CONTROL, hv.numbase[k], SET_VALUE = STRING(hv.Voltage[k])
;        IF hv.OnStat[k] EQ 1 THEN stcolour = 32  ELSE stcolour = 112 
        IF hv.OnStat[k] EQ 1 THEN stcolour = 3  ELSE stcolour = 2 
        height = (float(hv.Voltage[k])/hv.fullVolt*hv.YSize)<hv.Ysize
        yy = intarr(hv.Ysize)
        if height gt 0 then yy(0:height-1) = stcolour
        wset, hv.Drawindex[k]
        tv, xx#yy
     END
; update when finished
     widget_control,  hv.xhvbase,  update = 1
     
; store Old_ settings
     hv.Old_Voltage =  hv.Voltage 
     hv.Old_Onstat = hv.Onstat
     
;    widget_control, hv.auto_id, set_button=hv.auto_enable
     
; add a call to write the values to the latest MDSlus shot
     if not keyword_set(nowrite) and hv.auto_enable eq 1 then begin
;        print,'write_voltage:',hv.voltage
;        print,'write_state:',hv.OnStat
        write_sy127, hv.Voltage, hv.OnStat, quiet=1, status=status
     end
     
; update allocation table
     if xregistered('XHV_ALLOCATION', /noshow) then $
      xhv_allocation_update, hv.TavleIndex
     
; save changes
     WIDGET_CONTROL, hv.xhvbase, SET_UVALUE = hv;,  map = map
  end

END

; ------------------- END of UPDATE Routine ---------------

; ----------------Beginning of XHV init -------------
pro XHV_init,  hv
; 
; read database for voltages, on_states and set
;
  shotno =  hv.shotno  
  voltage = read_sy127(state=state, shotno=shotno, status=status)
  if not status then begin
     print, "Invalid read status from database at shot "$
      +strtrim(shotno,2)
     return
  end

  Print, 'Please wait while we initialize the SY127 ...'
  if n_elements(voltage) ne hv.NumChan then $
   stop,'Channel number conflict'
  hv.Voltage = voltage
  hv.OnStat = state
  sy127drv, action = 'SETALL', param = 0, AR = hv.voltage
;  set on/off state
  FOR Lp = 0, hv.Numchan -1 DO BEGIN
     IF hv.OnStat[Lp] EQ 1 then $
      sy127drv, action = 'CHON', Channel = Lp else $
      sy127drv, action = 'CHOFF', Channel = Lp 
  END
  
end
; ------------------- END of XHV_init ---------------


; ----------------Beginning of Event handling -------------


PRO xhv_ev, event

WIDGET_CONTROL, event.id, GET_UVALUE = eventval		

    IF N_ELEMENTS(eventval) EQ 0 THEN RETURN

; These lines put up an hourglass cursor and load the control structure.
	
	WIDGET_CONTROL, /Hourglass
    	WIDGET_CONTROL, event.top, GET_UVALUE = hv   

;  This routine deals with the case where one of the draw widgets
;  is clicked on and hence a channel must be turned on or off

    IF strmid(eventval, 0, 4) EQ 'Draw' THEN BEGIN
      IF event.type EQ 0 THEN BEGIN
    	
    	num = fix(strmid(eventval, strlen(eventval)-2, 2))
    	OnSt = hv.OnStat[num]
	OldSt = OnSt
;  This is the code which interfaces with sy127drv.pro    	
    	CASE OldSt OF
    	0 : BEGIN 
    		OnSt= 1
		sy127drv, action = 'CHON', Channel = num
		END
    	1 : BEGIN
    		OnSt = 0
		sy127drv, action = 'CHOFF', Channel = num   	
    		END
    	ENDCASE
    	hv.OnStat[num] = OnSt
    	WIDGET_CONTROL, event.top, SET_UVALUE = hv
        xhv_update, hv  	
    	
      ENDIF	
      RETURN
    END

;  This is the button handling code

    IF strmid(eventval, 0, 6) EQ 'Button' THEN BEGIN
    	hv.SelStat[fix(strmid(eventval, strlen(eventval)-2, 2))] = event.select
    	WIDGET_CONTROL, event.top, SET_UVALUE = hv	
  	RETURN
    END


    CASE eventval OF
 
        "DONE": BEGIN
		PRINT, "Exiting High voltage Widget"
		WIDGET_CONTROL, event.top, /DESTROY		
	END

        "RESET": BEGIN
        END

	"ON": BEGIN	
		FOR Lp = 0, hv.Numchan -1 DO BEGIN
		    	IF hv.selStat[Lp] EQ 1 THEN begin
		    		hv.OnStat[Lp] = 1
		    		sy127drv, action = 'CHON', Channel = Lp	
			ENDIF
		END
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
		xhv_update, hv		
;                print, 'Returning from select on'
	END

	"OFF": BEGIN	
		FOR Lp = 0, hv.Numchan -1 DO BEGIN
		    	IF hv.selStat[Lp] EQ 1 THEN BEGIN
		    		hv.OnStat[Lp] = 0
				sy127drv, action = 'CHOFF', Channel = Lp
			ENDIF
		END
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
		xhv_update, hv		
	END
	
	"ALLOFF": BEGIN	
		FOR Lp = 0, hv.Numchan -1 DO BEGIN
		    		hv.OnStat[Lp] = 0
				;sy127drv, action = 'CHOFF', Channel = Lp
		END
		sy127drv, action = 'ALLOFF'
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
		xhv_update, hv		
	END
	
	"SET": BEGIN	
		WIDGET_CONTROL, hv.setbase, GET_VALUE = volts
		FOR Lp = 0, hv.Numchan -1 DO BEGIN
		    	IF hv.selStat[Lp] EQ 1 THEN begin
		    		hv.Voltage[Lp] = volts
			sy127drv, action='SETV', channel = Lp,val = volts
			END
		END
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
		xhv_update, hv		
	END
	
        "UPDATE": BEGIN	
;  Read in voltages from data system		
                array = intarr(hv.NumChan)
		sy127drv, action = 'READALL', param = 0, AR = array
                hv.Voltage = array
;  Read in Status register
		sy127drv, action = 'READALL', param = 7, AR = array
                hv.OnStat = (array AND 4)/4
		print ,array, hv.Voltage
		
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
		xhv_update, hv		
	END
;  the following routines SALL, SNONE and INVERT affect the selected channels
;  on the widget but not the actual high voltage supply.


;        "Auto":begin
;                    hv.auto_enable = event.select
;                    WIDGET_CONTROL, event.top, SET_UVALUE = hv
;                    xhv_update, hv		
;                 end

;        "Save": begin	;always save to model at shot -1
;                    write_sy127, hv.Voltage, hv.OnStat, $
;                      quiet=1, status=status, shotno = -1
;                end

        "Restore": begin
           		xhv_init,  hv
                        WIDGET_CONTROL, event.top, SET_UVALUE = hv
                        xhv_update,  hv
                   end

	"Allocation": BEGIN	
		if not xregistered('XHV_ALLOCATION') then begin
                    XHV_ALLOCATION, event.top, top=top, group=event.top
                    hv.TableIndex = top
                    WIDGET_CONTROL, event.top, SET_UVALUE = hv
                end 
	END

	"SALL": BEGIN	
		
		FOR Lp = 0, hv.Numchan -1 DO BEGIN
		    	WIDGET_CONTROL, hv.selbase[Lp], SET_BUTTON = 1
		    	hv.selstat[Lp] = 1
		END
		;xhv_update, hv		
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
	END

	"SNONE": BEGIN	
		
		FOR Lp = 0, hv.Numchan -1 DO BEGIN
		    	WIDGET_CONTROL, hv.selbase[lp], SET_BUTTON = 0
		    	hv.selstat[lp] = 0
		END
		;xhv_update, hv		
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
	END
	
	"INVERT": BEGIN	
		
		FOR Lp = 0, hv.Numchan -1 DO BEGIN
		    	IF hv.selstat[lp] EQ 1 THEN new = 0 ELSE new = 1 
		    	WIDGET_CONTROL, hv.selbase[lp], SET_BUTTON = new
		    	hv.selstat[lp] = new
		END
		;xhv_update, hv		
		WIDGET_CONTROL, event.top, SET_UVALUE = hv
	END

        ELSE: MESSAGE, "Event User Value Not Found => "+eventval		

    ENDCASE

END ;============= end of xhv event handling routine task =============



;------------------------------------------------------------------------------
;	procedure xhv
;------------------------------------------------------------------------------

PRO xhv, GROUP = GROUP, BLOCK=block, debug=debug

    IF(XRegistered("xhv") NE 0) THEN RETURN		
    IF N_ELEMENTS(block) EQ 0 THEN block=0

;  This section initialises a number of variables that are required
;  for the program.
    Xsize=15
    YSize = 50
    NumChan = 20
    NumCols = 10
    NumRows = NumChan / NumCols
    DrawBase = intarr(NumChan)		;Array contains addresses to draw widgets
    DrawIndex = intarr (NumChan)		;Index of Draw Widgets
    SelectBase = intarr(NumChan)		;Bases of buttons
    NumBase = intarr(NumChan)           ;Array of Bases for readouts
    Voltage = intarr(NumChan)		;Array for channel voltage status
    OnStat = intarr(NumChan)		;Array for channel on/off status
    SelStat = intarr(Numchan)		;Array for button status
    FullVolt = 2500.
    stemp = sindgen(NumChan)
    DrUval = 'Draw' + stemp
    BuUval = 'Button' + stemp          
    
;  Check High Voltage supply is on and connected.
    Stat = 0
;    xhvstatus, stat = stat
    Stat = 1
    if stat EQ 0 THEN BEGIN
    print, 'Error starting High Voltage Controller'

    ENDIF ELSE BEGIN
       

;;  Read in voltages from hv crate		
;    sy127drv, action = 'READALL', param = 0, AR = Voltage, debug=debug
;;  Read in Status register
;    sy127drv, action = 'READALL', param = 7, AR = OnStat, debug=debug
;    OnStat = (OnStat AND 4)/4


;  The widget base and controls are created here.

;    LoadCT, 12                                ;Loads pallette
    tek_color

;    xhvbase = WIDGET_BASE(TITLE = "xhv - High Voltage Control", /ROW); UVALUE=wheel, /ROW)
    xhvbase = WIDGET_BASE(TITLE = "xhv - High Voltage Control", /column); UVALUE=wheel, /ROW
;    ControlBase = WIDGET_BASE(xhvBase, /COLUMN)
    ControlBase = WIDGET_BASE(xhvBase, /row)
     
    TopBase = WIDGET_BASE(ControlBase, /ROW, /FRAME)
    null = WIDGET_BUTTON(TopBase, VALUE = 'Dismiss',$
                         xsize=150, ysize=50, UVALUE = 'DONE')
    null = WIDGET_LABEL(TopBase, /ALIGN_CENTER, $
                 VALUE = '    SY127 HV Controller    ', SCR_YSIZE=50)
    
    ControlBasetemp = WIDGET_BASE(ControlBase, /ROW,  /GRID)

;    ControlBase0 = WIDGET_BASE(ControlBasetemp, /COLUMN)
;    null = WIDGET_LABEL(ControlBase0, /ALIGN_CENTER, $
;                        VALUE = 'DATABASE', SCR_YSIZE=30)

    ControlBase1 = WIDGET_BASE(ControlBasetemp, /COLUMN)
    null = WIDGET_LABEL(ControlBase1, /ALIGN_CENTER, $
                        VALUE = 'CHANNEL', SCR_YSIZE=30)

    ControlBase2 = WIDGET_BASE(ControlBasetemp, /COLUMN)    
    null = WIDGET_LABEL(ControlBase2, /ALIGN_CENTER, $
                        VALUE = 'ACTION', SCR_YSIZE=30)
   
  
;    ControlBase02 = WIDGET_BASE(ControlBase0, /COLUMN) 
;    shotno = -1L
;    shotno_id = CW_FIELD(ControlBase02, TITLE = 'Shotno', VALUE = shotno, $
;    			/INTEGER, XSIZE = 5)
;    null = WIDGET_BUTTON(ControlBase02, VALUE = 'Allocation table', $
;                         UVALUE = 'Allocation')
;    null = WIDGET_BUTTON(ControlBase02, VALUE = 'Restore settings', $
;                         UVALUE = 'Restore')
;    null = WIDGET_BUTTON(ControlBase02, VALUE = 'Save settings', $
;                         UVALUE = 'Save')
;    ControlBase01 = WIDGET_BASE(ControlBase0, /nonexclusive, /COLUMN)    
;    auto = WIDGET_BUTTON(ControlBase01, VALUE = 'AutoSave',UVALUE = 'Auto')

    ;Message = WIDGET_LABEL(ControlBase, $
;                 VALUE='Initialising')
    setbase = CW_FIELD(ControlBase2, TITLE = 'Voltage', VALUE = 0, $
    			/INTEGER, XSIZE = 5)
    null = WIDGET_BUTTON(ControlBase2, VALUE = 'Set', UVALUE = 'SET')
    null = WIDGET_BUTTON(ControlBase2, VALUE = 'On', UVALUE = 'ON')
    null = WIDGET_BUTTON(ControlBase2, VALUE = 'Off', UVALUE = 'OFF')
    null = WIDGET_BUTTON(ControlBase2, VALUE = 'Update', UVALUE = 'UPDATE') 
    
    null = WIDGET_BUTTON(ControlBase1, VALUE = 'Select All', UVALUE = 'SALL')
    null = WIDGET_BUTTON(ControlBase1, VALUE = 'Select None', UVALUE = 'SNONE')
    null = WIDGET_BUTTON(ControlBase1, VALUE = 'Invert Selection', UVALUE = 'INVERT')  
    null = WIDGET_BUTTON(ControlBase1, VALUE = 'All Off', UVALUE = 'ALLOFF')  
    null = WIDGET_BUTTON(ControlBase1, VALUE = 'Allocation table', $
                         UVALUE = 'Allocation')
;    null = WIDGET_BUTTON(ControlBase2, VALUE = 'Update', UVALUE =
                                ;    'UPDATE') 
;    null = WIDGET_BUTTON(ControlBase1, VALUE = 'Dismiss', UVALUE = 'DONE')
    
 
    
   
    
;  Base for Voltage Displays are done here 
    DrawBases = intarr(3)
    DrawBases[0] = WIDGET_BASE(xhvBase, /COLUMN, /FRAME )
    DrawBases[1] = WIDGET_BASE(DrawBases[0], /ROW, SPACE = 0)
    DrawBases[2] = WIDGET_BASE(DrawBases[0], /ROW, SPACE = 0)
    
    FOR LoopVar = 0, NumChan - 1 DO BEGIN
         
        row = FIX((LoopVar)/10)+1
        Temp = WIDGET_BASE(DrawBases[row], /COLUMN);, SCR_XSIZE = XSize * 3.5) 
        DrawBase[LoopVar] = WIDGET_DRAW(Temp, $
        				/BUTTON_EVENTS, $
                                        UVALUE = DrUval[LoopVar], $
;                                        RETAIN = 2, $
                                        SCR_XSIZE = XSize, $
                                        SCR_YSIZE = YSize, $
                                        FRAME = 3)
                                   
        Temp2 = WIDGET_BASE(Temp, /NONEXCLUSIVE)
        SelectBase[LoopVar] = WIDGET_BUTTON(Temp2, $; SCR_XSIZE = 3*XSize, $
        		/ALIGN_LEFT, $
        		VALUE = strmid(stemp[LoopVar], $
                        strlen(stemp[LoopVar])-2,2), $
        		UVALUE = BuUval[LoopVar] )
        NumBase[LoopVar] = WIDGET_LABEL(Temp, value = '     ',  xsize = 70)
    END
    
    
    
    WIDGET_CONTROL, xhvbase, /REALIZE ;,  map = 0
    
    FOR LoopVar = 0, NumChan - 1 DO BEGIN
         WIDGET_CONTROL, DrawBase[LoopVar], GET_VALUE = index
         Drawindex[LoopVar] = index
    END

; This is where the structure that is passed in the Uvalue of the Main Base
; widget is initialized.
  
hvcont = {OnStat : OnStat, $
	SelStat : SelStat, $
	Voltage : Voltage, $
        Old_voltage: voltage, $
        Old_onstat: onstat, $
        shotno:  -1L,  $
        xhvBase: xhvBase,  $
	DrawBase : DrawBase, $
	FullVolt : FullVolt, $
	DrawIndex : DrawIndex, $
        TableIndex: -1L, $	; the allocation table 
	SelBase : SelectBase, $
;        auto_id: auto, $
        auto_enable: 1, $	;auto update database
;        shotno_id: shotno_id, $
	Xsize : XSize, $
	YSize : YSize, $
	NumChan : NumChan, $
	SetBase : SetBase, $
        NumBase : NumBase}
	
    WIDGET_CONTROL, xhvBase, SET_UVALUE = hvcont  	
    
; read database and initialise voltages etc.
 widget_control, /hourglass
    XHV_init,  hvcont

    xhv_update, hvcont, /nowrite
  
    XManager, "xhv", xhvbase, $			
		EVENT_HANDLER = "xhv_ev", $	
		GROUP_LEADER = GROUP, $			
		NO_BLOCK=(NOT(FLOAT(block)))		
    END

END ;==================== end of xhv main routine =======================
