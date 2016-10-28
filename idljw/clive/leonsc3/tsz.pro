pro tsz_event,ev

common cbt, id

if ev.id eq id.top then begin
;help,/str,ev
widget_control,id.draw,scr_xsize=ev.x-200,scr_ysize=ev.y,xoffset=200
;widget_control,id.top,scr_xsize=ev.x,scr_ysize=ev.y
endif

end

pro tsz
common cbt, id
id={top:0L,draw:0L}

id.top=widget_base(/tlb_size_events)
c1=widget_base(id.top,/column)
dum=widget_text(c1,value='hey')
dum=widget_text(c1,value='hey')
dum=widget_text(c1,value='hey')
id.draw=widget_draw(id.top,xsize=1000,ysize=1000,x_scroll_size=100,y_scroll_size=100,xoffset=200)

widget_control,id.top,/realize

xmanager,'tsz',id.top

end
