pro wset2, win
err=0
catch,err
if err  ne 0 then begin
   window,win
   return
endif

wset,win
end
