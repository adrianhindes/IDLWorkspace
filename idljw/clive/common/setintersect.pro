function setintersect, s1,s2,rvi=rvi
n1=n_elements(s1)
n2=n_elements(s2)
rv=fltarr(n1)
cnt=0L
rvi=rv
for i=0,n1-1 do begin
    idx=where(s2 eq s1(i))
    if idx(0) ne -1 then begin
        rv(cnt)=s1(i)
        rvi(cnt)=i
        cnt=cnt+1
    endif
endfor
rv=rv(0:cnt-1)
rvi=rvi(0:cnt-1)
return,rv
end
