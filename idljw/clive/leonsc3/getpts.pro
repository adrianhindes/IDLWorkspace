pro apparr, x,x1
if n_elements(x1) ne 0 then begin
    if n_elements(x) ne 0 then x=[[[x]],[[x1]]] else x=x1
endif
end

pro getpts1, fn, fcb,lns,dir=dir
restore,file=dir+'/'+fn+'show.sav',/verb
end

pro getpts, fn, fcb,lns,dir=dir
nfn=n_elements(fn)
for i=0,nfn-1 do begin
    getpts1,fn(i),x1,y1,dir=dir
    apparr,x,x1
    apparr,y,y1
 endfor
if n_elements(x) ne 0 then fcb=x
lns=y
end
