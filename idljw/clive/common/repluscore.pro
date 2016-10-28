function repluscore, s,backward=backward
n=n_elements(s)
s2=s
if keyword_set(backward) then begin
   a='$'
   b='_'
endif else begin
   a='_'
   b='$'
endelse

for i=0,n-1 do begin
   p=strpos(s(i),a)
   if p ne -1 then begin
      dum=strmid(s(i),0,p) + b + strmid(s(i),p+1,99999)
      s2(i)=dum
   endif
endfor

return,s2
end

