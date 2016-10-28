
function maxrmp, sh

mdsopen,'kstar',sh
y=mdsvalue('\KSTAR::TOP.KSTAR:RMP_M_I')
if n_elements(y) gt 5 then mx=max(y) else mx=0.

return,mx

end
