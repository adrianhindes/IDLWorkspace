function num_commas, txt
nc=0
len=strlen(txt(0))
pos=0
while pos lt len do begin
    pos=(strpos(txt,',',pos))(0)
    if pos eq -1 then goto,done
    pos=pos+1
    nc=nc+1
endwhile
done:
return,nc
end

       

function text_to_array, txt,err

on_ioerror, after

nc=num_commas(txt)
val=fltarr(nc+1)
reads,txt,val
goto, ok
after:
err=1
return,0
ok:
err=0
return, val
end




pro cw_array_setvalue, id, value
wfield=widget_info(id,/child)

widget_control, id, get_uvalue=format
nv=n_elements(value)
if nv gt 1 then begin
    txtnvm1=string(nv-1,format='(I0)')
    fmt='('+txtnvm1+'('+format+',", "),'+format+')'
endif else begin
    fmt='('+format+')'
endelse

vtext=string(value,format=fmt)
widget_control, wfield, set_value=vtext
widget_control, wfield, set_uvalue=value
end

function cw_array_event, ev

if tag_names(ev,/struct) eq 'WIDGET_KBRD_FOCUS' then begin
    wbase=ev.id
    wfield=widget_info(wbase,/child)
endif else begin
    wfield=ev.id
    wbase=widget_info(wfield,/parent)
endelse

widget_control, wfield, get_value=vtext

value=text_to_array(vtext,err)
if err eq 1 then begin
    value=cw_array_getvalue(wbase)
    cw_array_setvalue, wbase, value
    ret=0
endif else begin
    cw_array_setvalue, wbase,value
    widget_control, wfield, set_uvalue=value
    ret={id:wbase,top:wbase,handler:ev.handler}
endelse

return, ret
end


function cw_array_getvalue, id
wfield=widget_info(id,/child)

ev={WIDGET_KBRD_FOCUS, ID:id, TOP:id, HANDLER:0L, ENTER:0 }
e2=cw_array_event( ev)


widget_control, wfield, get_uvalue=value
return, value
end


function cw_array, base, value=value,_EXTRA=_EXTRA,format=format

default, format,'(G0)'

wbase=widget_base(base,func_get_value='cw_array_getvalue',$
                 pro_set_value='cw_array_setvalue',$
                 event_func='cw_array_event',$
                 /kbrd_focus_events, uvalue=format)
wfield=cw_field(wbase,/string,_EXTRA=_EXTRA,/return_events)

if keyword_set(value) then cw_array_setvalue,wbase,value
return, wbase
end







