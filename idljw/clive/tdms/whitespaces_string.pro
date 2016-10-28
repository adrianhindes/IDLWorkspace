function whitespaces_string,length1

;Todo: documentation!
;- Creates a whitespaces string with an user defined length
length=length1

if length gt 1000 then begin
   length=1000
;   print,'warning whitespages-string'
endif
if length eq 0 then length=1

  empty_str=strjoin(Replicate(' ',length))

return,empty_str
end
