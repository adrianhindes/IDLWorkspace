
function maxrmp, sh

mdsopen,'kstar',sh
y=mdsvalue('\KSTAR::TOP.KSTAR:RMP_M_I')
if n_elements(y) gt 5 then mx=max(y) else mx=0.

return,mx

end

pro loopit
openw,lun,'~/rmp.txt',/get_lun
for sh=9862,11724 do begin
printf,lun,sh,maxrmp(sh)
endfor
close,lun & free_lun,lun

end

