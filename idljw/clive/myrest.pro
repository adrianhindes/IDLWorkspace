function myrest,fil
help,name='*',output=var0
print,var0
restore,file=fil;,/verb
help,name='*',output=var1
;print,var1
nvar=n_elements(var1)
nvar0=n_elements(var0)
strng='str={'
for i=0,nvar-1 do begin
    nm=(strsplit(var1(i),' ',/extract))(0)
    if nm eq 'VAR0' or nm eq 'FIL' then continue
    found=0
    for j=0,nvar0-1 do begin
        nm0=(strsplit(var0(j),' ',/extract))(0)
        if nm eq nm0 then found=1
    endfor
    if found eq 1 then continue
    strng=strng+''+nm+':'+nm+','
endfor
strng=strmid(strng,0,strlen(strng)-1)+'}'
;print,strng
dum=execute(strng)
for i=0,nvar-1 do begin
    nm=(strsplit(var1(i),' ',/extract))(0)
    if nm eq 'VAR0' or nm eq 'FIL' then continue
    found=0
    for j=0,nvar0-1 do begin
        nm0=(strsplit(var0(j),' ',/extract))(0)
        if nm eq nm0 then found=1
    endfor
    if found eq 1 then begin
        dum=execute('dum2=temporary('+nm+')')
    endif
endfor

return,str
end

;s=myrest('~/pol_new1_.sav')

;end

