function delstruct, struct, field

nt=n_tags(struct)
tn=tag_names(struct)
idel=where(tn eq field)
if idel(0) eq -1 then return,-1
for i=0,nt-1 do begin
   if i eq idel(0) then goto, noadd
   if i eq 0 then structret=create_struct(tn(i),struct.(i)) else $
            structret=create_struct(structret,tn(i),struct.(i))
noadd:
endfor
return, structret
end
