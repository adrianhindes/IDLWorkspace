pro addstr, str, tagname, val

if n_elements(str) eq 0 then str=create_struct(tagname,val) else $
  str=create_struct(str,tagname,val)
end

pro savewidget, id, fname,struct=struct
err=0
ntags=n_tags(id)
tagnames=tag_names(id)
for i=0,ntags-1 do begin
    type=widget_info(id.(i),/name)
    if (type eq 'BASE') then begin
        catch, err
        if err ne 0 then begin
            err=0
            goto, after
        endif
        widget_control, id.(i), get_value=val
        if (err ne 0) or (n_elements(val) ne 0) then begin
;            print, tagnames(i), n_elements(val)
          addstr, str, tagnames(i),val
      endif

    endif
    if (type eq 'DROPLIST') then begin
        val=widget_info(id.(i),/droplist_select)
        if n_elements(val) ne 0 then $
          addstr, str, tagnames(i),val
    endif
    after:
endfor
catch,/cancel

if not keyword_set(struct) then $
  save, str, file=(fname) else $
  fname=str
catch,/cancel
end




            
