function istag, strct, tag,loc=loc
on_error,2
tags=tag_names(strct)

ntags=n_elements(tags)
for i=0,ntags-1 do if tags(i) eq strupcase(tag) then begin
    loc=i
    return, 1
    endif


return, 0

end
