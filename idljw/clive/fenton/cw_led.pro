; Copyright (c) 1995, M.I.T.
;	Unauthorized reproduction prohibited.
;+
; NAME: CW_LED
;
; PURPOSE: Compound led widget.  Displays two state values (on and off)
;
; CATEGORY:
;	Compound widgets.
;
; CALLING SEQUENCE:
;	widget = CW_LED(parent)
;
; INPUTS:
;       PARENT - The ID of the parent widget.
;
; KEYWORD PARAMETERS:
;	TOP_LABEL = string
;       LEFT_LABEL = string
;       RIGHT_LABEL = string
;       VALUE = 0 or 1
;	UVALUE - Supplies the user value for the widget.
;       NOEVENT - if set no widget events will be generated. 
;
; OUTPUTS:
;       The ID of the created widget is returned.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;
; PROCEDURE:
;	WIDGET_CONTROL, id, SET_VALUE=value can be used to change the
;		current value displayed by the widget.
;
;	WIDGET_CONTROL, id, GET_VALUE=var can be used to obtain the current
;		value displayed by the widget.
;
; MODIFICATION HISTORY:
;    5/15/95  JAS original version
;-


PRO led_set_value, id, value

	; This routine is used by WIDGET_CONTROL to set the value for
	; your compound widget.  It accepts one variable.  
	; You can organize the variable as you would like.  If you have
	; more than one setting, you may want to use a structure that
	; the user would need to build and then pass in using 
	; WIDGET_CONTROL, compoundid, SET_VALUE = structure.

	; Return to caller.
  ON_ERROR, 2

	; Retrieve the state.
  stash = WIDGET_INFO(id, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY

	; Set the value here.
  WIDGET_CONTROL, state.id, get_value =  window
  state.selected = value

        tek_color
        if value eq 0 then col = 2 else col = 3
        im =  intarr(state.size, state.size) 
        if not state.square then begin
           x = (findgen(state.size)-state.size/2)
           unit =  replicate(1., state.size)
           xx =  x#unit
           yy = transpose(xx)
           radius = sqrt(xx^2+yy^2)
           circ =  where(radius le state.size/2.)
           im(circ) = col
        end else im(*) = col

        wset, window
        tv, im

  WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY

END



FUNCTION led_get_value, id

	; This routine is by WIDGET_CONTROL to get the value from 
	; your compound widget.  As with the set_value equivalent,
	; you can only pass one value here so you may need to load
	; the value by using a structure or array.

	; Return to caller.
  ON_ERROR, 2

	; Retrieve the structure from the child that contains the sub ids.
  stash = WIDGET_INFO(id, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY
	; Get the value here

  ans = state.selected
  WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY

        ; Return the value here.
  return, ans
END

;-----------------------------------------------------------------------------

FUNCTION led_event, ev
  parent=ev.handler
  stash = WIDGET_INFO(parent, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY
  if (not state.display_only) then begin
    sel = ev.select
    state.selected = sel
    if (state.noevent) then $
      retval = 0 $
    else  $
      retval = { ID:parent, TOP:ev.top, HANDLER:0L, select:sel }
    WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
    RETURN, retval
  endif else begin
    WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
    return, 0
  endelse
END

;-----------------------------------------------------------------------------

FUNCTION cw_led, parent, $
                 UVALUE = uval, $
                 value = value, $
                 top_label = top_label, $
                 bottom_label=bottom_label, $
                 right_label=right_label, $
                 left_label=left_label, $
		 noevent = noevent, frame = frame, $
                 size = size,  square = square, $
                 display_only = display_only

  IF (N_PARAMS() EQ 0) THEN MESSAGE, 'Must specify a parent for Cw_Led'

  ON_ERROR, 2					;return to caller

	; Defaults for keywords
  IF NOT (KEYWORD_SET(uval))  THEN uval = 0
  if NOT (KEYWORD_SET(value)) then value = 0 else value = 1
  default,  display_only,  1
  default,  size,  10
  default,  square,  0B
  default,  frame,  2

;  sz = size(right_label)
;  if (sz(1) eq 0) then right_label = '' 
  state = { id:0L, selected:0 , display_only:display_only, noevent:keyword_set(noevent),  size: size,  square:square}

  if (keyword_set(left_label)) then  begin

    mainbase = WIDGET_BASE(parent, UVALUE = uval, $
                           EVENT_FUNC = "led_event", $
                           FUNC_GET_VALUE = "led_get_value", $
                           PRO_SET_VALUE = "led_set_value", /row)
    label = widget_label(mainbase, value = left_label)
    state.id = WIDGET_DRAW(mainbase,SCR_XS=Size, SCR_YS =Size, FRAME=frame)

  endif else if (keyword_set(right_label)) then  begin

     mainbase = WIDGET_BASE(parent, UVALUE = uval, $
                            EVENT_FUNC = "led_event", $
                            FUNC_GET_VALUE = "led_get_value", $
                            PRO_SET_VALUE = "led_set_value", /row)
    state.id = WIDGET_DRAW(mainbase,SCR_XS=Size, SCR_YS =Size, FRAME=frame)
    label = widget_label(mainbase, value = right_label)

  endif else if (keyword_set(top_label)) then begin

    mainbase = WIDGET_BASE(parent, UVALUE = uval, $
                           EVENT_FUNC = "led_event", $
                           FUNC_GET_VALUE = "led_get_value", $
                           PRO_SET_VALUE = "led_set_value", /column)
    label = widget_label(mainbase, value = top_label)
    state.id = WIDGET_DRAW(mainbase,SCR_XS=Size, SCR_YS =Size, FRAME=frame)

   endif else begin

      mainbase = WIDGET_BASE(parent, UVALUE = uval, $
                             EVENT_FUNC = "led_event", $
                             FUNC_GET_VALUE = "led_get_value", $
                             PRO_SET_VALUE = "led_set_value")
      state.id = WIDGET_DRAW(mainbase,SCR_XS=Size, SCR_YS =Size, FRAME=frame)
      label = widget_label(mainbase, value = bottom_label)

  endelse

  state.selected = keyword_set(value)

  WIDGET_CONTROL, WIDGET_INFO(mainbase, /CHILD), SET_UVALUE=state, /NO_COPY
;  widget_control,  mainbase, /realize
;  widget_control,  mainbase, set_value = value

  RETURN, mainbase

END

;---------------------------------------------------------------

PRO test_cw_led_event,  event

help, /str,  event

led =  widget_info(event.top, /child)

widget_control,  led, get_value = val
val =  (val+1) mod 2
widget_control,  led,  set_value = val

end


PRO test_cw_led

parent =  widget_base(/row)
led =  cw_led(parent, $
                 value = 0, $
                 top_label = 'Test_LED', $
		 noevent = noevent, $
                 display_only = display_only )
btn =  widget_button(parent, value = 'Toggle')


widget_control,  parent, /realize

xmanager, 'test_cw_led', parent

end
