pro window2,ix,_extra=_extra
err=0L
catch,err
if err ne 0 then goto, after
wset,ix
return

after:
catch,/cancel
window,ix,_extra=_extra
end
