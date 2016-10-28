function islong, sh
;err=0
;catch,err
;if err ne 0 then begin
;    print,'is error'
;    goto,af
;endif
on_ioerror,af

lsh=long(sh)
goto, enn
af:
print,'hey error'
enn:

return,lsh
end
