function noarr,g
nt=n_tags(g)
tn=tag_names(g)
for i=0,nt-1 do begin
   v=g.(i)

   if size(v,/n_dim) eq 1 then if (size(v,/dim))(0) eq 1 then v=v(0)

   if i eq 0 then g2=create_struct(tn(i),v) else $
      g2=create_struct(g2,tn(i),v)
endfor
return,g2
end


