pro wedit_event,ev
common cbwedit,id
if ev.id eq id.save then begin
    i=widget_info(id.tabs,/tab_current)
    widget_control,id.tabarr(i).tab,get_value=data
    writecsv2,getenv('HOME')+'/idl/clive/settings/'+id.tabarr(i).fname,data
endif
if ev.id eq id.read then begin
    i=widget_info(id.tabs,/tab_current)
    readtextc,getenv('HOME')+'/idl/clive/settings/'+id.tabarr(i).fname,data,nskip=0
    widget_control,id.tabarr(i).tab,set_value=data,$
                   column_labels=data(*,0),row_labels=data(0,*)
    sz=size(data,/dim)
    widget_control,id.tabarr(i).tab,table_xsize=sz(0),table_ysize=sz(1)
endif

if ev.id eq id.addrow then begin
    i=widget_info(id.tabs,/tab_current)
    widget_control,id.tabarr(i).tab,get_value=data
    cij=widget_info(id.tabarr(i).tab,/table_edit_cell)
    cij2=widget_info(id.tabarr(i).tab,/table_select)

    j=cij(0)
    j=cij2(1)
    if j eq -1 then begin
        print,'abandon'
        return
    endif
    j+=1
    sz=size(data,/dim)
    data2=strarr(sz(0),sz(1)+1)
    data2(*,0:j-1)=data(*,0:j-1)
    data2(*,j)=data(*,j-1)
    if j ne sz(1) then data2(*,j+1:*)=data(*,j:*)
    widget_control,id.tabarr(i).tab,set_value=data2
    widget_control,id.tabarr(i).tab,table_ysize=sz(1)+1

endif

if ev.id eq id.delrow then begin
    i=widget_info(id.tabs,/tab_current)
    widget_control,id.tabarr(i).tab,get_value=data
    cij=widget_info(id.tabarr(i).tab,/table_edit_cell)
    cij2=widget_info(id.tabarr(i).tab,/table_select)

    j=cij(0)
    j=cij2(1)
    if j eq -1 then begin
        print,'abandon'
        return
    endif
;    j+=1
    sz=size(data,/dim)
    data2=strarr(sz(0),sz(1)-1)
    if j ne 0 then data2(*,0:j-1)=data(*,0:j-1)
    if j ne sz(1)-1 then data2(*,j:*)=data(*,j+1:*)
    widget_control,id.tabarr(i).tab,set_value=data2
    widget_control,id.tabarr(i).tab,table_ysize=sz(1)-1

endif

if ev.id eq id.addcol then begin
    i=widget_info(id.tabs,/tab_current)
    widget_control,id.tabarr(i).tab,get_value=data
    cij=widget_info(id.tabarr(i).tab,/table_edit_cell)
    cij2=widget_info(id.tabarr(i).tab,/table_select)

;    j=cij(0)
    j=cij2(0)
    if j eq -1 then begin
        print,'abandon'
        return
    endif
    j+=1
    sz=size(data,/dim)
    data2=strarr(sz(0)+1,sz(1))
    data2(0:j-1,*)=data(0:j-1,*)
    data2(j,*)=data2(j-1,*) ; copies col
    if j ne sz(0) then begin
        data2(j+1:*,*)=data(j:*,*)
    endif
    widget_control,id.tabarr(i).tab,set_value=data2
    widget_control,id.tabarr(i).tab,table_xsize=sz(0)+1

endif

if ev.id eq id.tabarr(0).tab then begin
   if ev.type eq 0 then if ev.x eq 0 then begin
      widget_control,id.tabarr(0).tab,get_value=data
      widget_control,id.tabarr(0).tab,row_labels=data(0,*)
   endif

endif

end

pro wedit
common cbwedit,id
tmp={top:0L,tab:0L,fname:''}
ntab=11
id={top:0L,tabs:0L,tabarr:replicate(tmp,ntab),save:0L,addrow:0L,addcol:0L,delrow:0L,read:0L}
id.tabarr(0).fname='log_shot.csv'
id.tabarr(1).fname='mapping.csv'
id.tabarr(2).fname='cell.csv'
id.tabarr(3).fname='wp.csv'
id.tabarr(4).fname='flc.csv'
id.tabarr(5).fname='demod.csv'
id.tabarr(6).fname='ancal.csv'
id.tabarr(7).fname='log_timing.csv'
id.tabarr(8).fname='log_nskip.csv'
id.tabarr(9).fname='log_flctiming.csv'
id.tabarr(10).fname='log_probe.csv'

id.top=widget_base(/column,title='wedit')

id.tabs = widget_tab(id.top)

path=getenv('HOME')+'/idl/clive/settings/'
for i=0,ntab-1 do begin
    readtextc,path+id.tabarr(i).fname,data,nskip=0
    id.tabarr(i).top = widget_base(id.tabs,/row, title=id.tabarr(i).fname)
    id.tabarr(i).tab=widget_table(id.tabarr(i).top,value=data,/editable,$
                             scr_xsize=20,scr_ysize=15,/scroll,units=2,$
                             /all_events,column_labels=data(*,0),$
                                 row_labels=data(0,*))
    inf=widget_info(id.tabarr(i).tab,/column_widths)
    if i eq 0 then begin
        inf(0)*=2
        widget_control,id.tabarr(i).tab,column_widths=inf
    endif

endfor
rw=widget_base(id.top,/row)
id.addrow=widget_button(rw,value='copy row after')
id.addcol=widget_button(rw,value='add col after')
id.delrow=widget_button(rw,value='del row')
id.save=widget_button(rw,value='save')
id.read=widget_button(rw,value='read')

widget_control,id.top,/realize
xmanager,'wedit',id.top,/no_block
;widget_control,id.tab,get_value=txt
;print,txt
;stop
end
