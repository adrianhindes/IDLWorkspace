function removeij, mat, k,l
sz=size(mat,/dim)
mat2=complexarr(sz(0)-1,sz(1)-1)
cnt=0
for i=0,sz(0)-1 do begin
    if i eq k then continue
    cnt2=0
    for j=0,sz(1)-1 do begin
        if j eq l then continue
        mat2(cnt,cnt2)=mat(i,j)
        cnt2=cnt2+1
    endfor
    cnt=cnt+1
endfor
return,mat2
end

