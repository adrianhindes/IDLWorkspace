function floattrap, sh,err=err
;err=0
;catch,err
;if err ne 0 then begin
;    print,'is error'
;    goto,af
;endif
on_ioerror,af

nsh=n_elements(sh) 
lsh=fltarr(nsh)
err=intarr(nsh)
for i=0,nsh-1 do begin
    tmp=float(sh(i))
    lsh(i)=tmp
    if strlen(string(tmp,format='(G0)')) ne strlen(sh(i)) then err(i)=1
    continue
    af:
    err(i)=1
endfor

return,lsh
end
