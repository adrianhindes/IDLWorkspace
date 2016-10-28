function pathfind, str
sep=strsplit(!path,':',/extr)
ns=n_elements(sep)
res=strarr(ns)
cnt=0
for i=0,ns-1 do if strpos(sep(i),str) ne -1 or strpos(sep(i),tildrep(str)) ne -1 then begin
    res(cnt)=sep(i)
    cnt=cnt+1
endif
if cnt gt 0 then res=res(0:cnt-1)
return,res
end
