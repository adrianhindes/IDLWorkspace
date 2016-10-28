pro imval

read_gif, 'xwhim.gif', xwhim
tv, xwhim

end

pro widgtest

    xwheelbase = WIDGET_BASE(TITLE = "xwheel", /column); UVALUE=wheel, /ROW)

;    ControlBase = WIDGET_BASE(xwheelBase, /COLUMN, /FRAME)
    TitleBase = widget_base(xwheelBase, /column, /frame)
;    null = WIDGET_LABEL(TitleBase, VALUE='')
    null = WIDGET_LABEL(TitleBase, /ALIGN_CENTER, $
                 VALUE = '2D Tomographic Ring Controller', SCR_YSIZE=50)
;    null = WIDGET_LABEL(TitleBase, VALUE='')

    ActiveBase = widget_base(xwheelbase, /row, /frame)
    FirstBase = widget_base(ActiveBase, /column, /frame)
    null = widget_button(Firstbase, value='First Button')
    null = widget_button(firstbase, value='Second Button')
    
    StatusBase = WIDGET_BASE(ActiveBase, /COLUMN, /FRAME)

    Message = WIDGET_LABEL(StatusBase, $
                 VALUE='Current Position = Initial Position')
    ;null = WIDGET_BUTTON(ControlBase, VALUE = 'Position Control', UVALUE = 'PosCont')
    ;null = WIDGET_BUTTON(ControlBase, VALUE = 'Incremental Control', UVALUE = 'IncCont')
    null = WIDGET_BUTTON(StatusBase, VALUE = 'Reset Ring', UVALUE = 'RESET')
    null = WIDGET_BUTTON(StatusBase, VALUE = 'Quit', UVALUE = 'DONE')
    null = WIDGET_LABEL(StatusBase, VALUE='') 
    null = WIDGET_LABEL(StatusBase, VALUE = 'Programmed by Adam Last - February 1999')
    null = WIDGET_LABEL(StatusBase, VALUE = 'Changes can be made using the xwheel.ini file')

    SecondBase = widget_base(ActiveBase, /column, /frame)
;    read_gif, 'xwhim.gif', xwhim
    null = widget_draw(SecondBase, pro_set_value='imval') 

;    WIDGET_CONTROL, xwheelBase, SET_UVALUE = wheel
    WIDGET_CONTROL, xwheelbase, /REALIZE			


end
