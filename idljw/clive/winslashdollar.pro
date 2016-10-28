function winslashdollar, str
char='$'
;doit=0

doit=1
char='^'


;if !version.os eq 'Win32'  then doit=1 else begin
;spawn,'hostname',host
;if host eq 'prl75' then begin
;   doit=1
;   char='^'
;endif
;endelse



if doit eq 1 then  begin
   bstr=byte(str)
   idx=where(bstr eq (byte('\'))(0))
   if idx(0) ne -1 then bstr(idx)=byte(char)
   idx=where(bstr eq (byte(':'))(0))
   if idx(0) ne -1 then bstr(idx)=byte('#')

   str2=string(bstr)

endif else str2=str
return,str2
end

   
