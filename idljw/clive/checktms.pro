
function maxtms, sh

mdsopen,'kstar',sh
y=mdsvalue('\KSTAR::TOP.ELECTRON.TS_CORE:TS_CORE1:CORE1:F00')
if n_elements(y) gt 5 then mx=1 else mx=0.

return,mx

end

pro loopit
openw,lun,'~/tms.txt',/get_lun
for sh=9862,11724 do begin
printf,lun,sh,maxtms(sh)
endfor
close,lun & free_lun,lun

end

