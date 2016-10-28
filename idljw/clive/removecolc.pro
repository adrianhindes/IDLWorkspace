function removecolc, mat, k
sz=size(mat,/dim)
mat2=complexarr(sz(0)-1,sz(1))
cnt=0
for i=0,sz(0)-1 do begin
    if i eq k then continue
    mat2(cnt,*)=mat(i,*)
    cnt=cnt+1
endfor
return,mat2
end

