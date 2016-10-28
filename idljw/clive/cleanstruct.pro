function cleanstruct,str
tn=tag_names(str)
nt=n_tags(str)
for i=0,nt-1 do begin
    val=str.(i)
    if size(str.(i),/n_dim) eq 1 then if size(str.(i),/dim) eq 1 then val=(str.(i))(0)
    if i eq 0 then rv=create_struct(tn(i),val) else rv=create_struct(rv,tn(i),val)
endfor

return,rv
end

