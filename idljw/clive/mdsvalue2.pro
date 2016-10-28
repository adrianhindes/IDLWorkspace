function mdsvalue2, nd,nozero=nozero,_extra=_extra
y={t:mdsvalue('DIM_OF('+nd+')',_extra=_extra),v:mdsvalue(nd,_extra=_extra)}
if not keyword_set(nozero) then if size(y.t,/type) ne 7 then y.t=y.t-y.t(0)
;y.t/=1000.
return,y
end
