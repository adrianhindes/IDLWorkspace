function findidx, str, strarr
n=n_elements(strarr)
idx=-1
for i=0,n-1 do begin
    if str eq strarr[i] then idx=i
endfor
return,idx
end


pro loadwidget, id, fname,struct=struct

;err=0
;catch,err
;if err ne 0 then begin
;    stop
;    return
;endif


if not keyword_set(struct) then begin
    catch,err
    if err ne 0 then return
    restore, file=(fname)
    print, 'restored'
; variable name "str" is retrieved from file fname
endif else begin
    str=fname
endelse

ntags_str=n_tags(str)
tagnames_str=tag_names(str)
ntags_id=n_tags(id)
tagnames_id=tag_names(id)

for i=0,ntags_str-1 do begin
    ididx=findidx(tagnames_str(i),tagnames_id)
    if ididx ne -1 then begin
        name=widget_info(id.(ididx),/name)
        if name eq 'DROPLIST' then begin
            widget_control, id.(ididx), set_droplist_select=str.(i)
        endif else begin
            widget_control, id.(ididx), set_value=str.(i)
        endelse
;        print, 'loaded', tagnames_str(i)
    endif
endfor


end

