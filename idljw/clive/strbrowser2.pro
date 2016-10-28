pro flattenwid,wid,tab,lev=lev
tabel={tabels2,value:0,nlev:0,lev:replicate(-1,20)}
ntags=n_tags(wid)
for i=0,ntags-1 do begin
    if size(wid.(i),/type) eq 8 then begin
        if n_elements(lev) eq 0 then levc=[i] else levc=[lev,i]
        flattenwid,wid.(i),tab,lev=levc
    endif else begin
        if n_elements(lev) eq 0 then begin
            tabel.nlev=1
            tabel.lev(0)=i
        endif else begin
            tabel.nlev=n_elements(lev)+1
            tabel.lev(0:n_elements(lev)-1)=lev
            tabel.lev(n_elements(lev))=i
        endelse
        tabel.value=wid.(i)
        if n_elements(tab) eq 0 then tab=tabel else tab=[tab,tabel]
    endelse
endfor
end


function create_struct2,a,b,c
if n_elements(a) eq 0 then return,create_struct(b,c) else return,create_struct(a,b,c)
end

pro getleaf,str,tabel,leaf
x=tabel.lev
nlev=tabel.nlev
if nlev eq 1 then leaf=str.(x(0))
if nlev eq 2 then leaf=str.(x(0)).(x(1))
if nlev eq 3 then leaf=str.(x(0)).(x(1)).(x(2))
if nlev eq 4 then leaf=str.(x(0)).(x(1)).(x(2)).(x(3))
if nlev eq 5 then leaf=str.(x(0)).(x(1)).(x(2)).(x(3)).(x(4))
if nlev eq 6 then leaf=str.(x(0)).(x(1)).(x(2)).(x(3)).(x(4)).(x(5))
if nlev eq 7 then leaf=str.(x(0)).(x(1)).(x(2)).(x(3)).(x(4)).(x(5)).(x(6))
if nlev eq 8 then leaf=str.(x(0)).(x(1)).(x(2)).(x(3)).(x(4)).(x(5)).(x(6)).(x(7))
end



pro strbrowser2_event,ev
common strbrowser3cb,strcb,id,wid,tab
common ms,leaf

help,/str,ev
idx=where(ev.id eq tab.value)
print,idx
;nprod=strcb.coords.nx*strcb.coords.ny*strcb.coords.nz
;nx=strcb.coords.nx
;ny=strcb.coords.ny
;nz=strcb.coords.nz
if idx(0) ne -1 then begin
    getleaf,strcb,tab(idx(0)),leaf
    ndim=   size(leaf,/n_dim) 
    dim=   size(leaf,/dim)     
;    for j=0,ndim-1 do begin
;        if dim(j) eq nprod then begin
;            if j eq 0 and ndim gt 1 then  dimnew=[nx,ny,nz,dim(1:*)] else $
;              if j eq 0 and ndim eq 1 then dimnew=[nx,ny,nz] else $
;              if j eq ndim-1 then dimnew=[dim(0:ndim-2),nx,ny,nz] else $
;              dimnew=[dim(0:j-1),nx,ny,nz,dim(j+1:*)]
;            leaf=reform(leaf,dimnew)
;        endif
;    endfor

    help,leaf,output=text
    widget_control,id.textarea,set_value=text
    widget_control,id.plotarea,get_value=win
    wset,win
    if size(leaf,/n_dim) gt 0 and n_elements(leaf) lt 10000 then begin
        if size(leaf,/n_dim) eq 1 then plot,leaf
        if size(leaf,/n_dim) eq 2 then contourn2,leaf,/cb
    endif


        
endif

end

pro adel, base, str,wid,lev=lev

ntags=n_tags(str)
tagnames=tag_names(str)
for i=0,ntags-1 do begin
    if size(str.(i),/type) eq 8 then begin
        tmp=widget_tree(base,value=tagnames(i),/folder)
;        wid=create_struct2(wid,tagnames(i),tmp)
        if n_elements(wid2) ne 0 then dum=temporary(wid2)
        adel,tmp,str.(i),wid2
        wid=create_struct2(wid,tagnames(i),wid2)
    endif else begin
        tmp=widget_tree(base,value=tagnames(i))
        wid=create_struct2(wid,tagnames(i),tmp)
    endelse
        print,tagnames(i)
endfor
end


    
pro strbrowser2,str

common strbrowser3cb,strcb,id,wid,tab
id={top:0L,tree:0L,textarea:0L,plotarea:0L,wid:0L,tab:0L};,index:0L}
strcb=str
id.top=widget_base(/row)

id.tree=widget_tree(id.top,value='root',/folder)
if n_elements(wid) ne 0 then dum=temporary(wid)
if n_elements(tab) ne 0 then dum=temporary(tab)

;id.tree=cw_treestructure(id.top,value=str)
adel,id.tree,str,wid
flattenwid,wid,tab
col2=widget_base(id.top,/column)
id.textarea=widget_text(col2,xsize=60)
;id.index=widget_text(col2,xsize=60)
id.plotarea=widget_draw(id.top,xsize=400,ysize=500)

widget_control,id.top,/realize
xmanager,'strbrowser2',id.top,/no_block
end
