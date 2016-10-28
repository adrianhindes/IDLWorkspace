function dynrangem, f,n,mn=mn,ignorezero=ignorezero,el=el,eu=eu
default,el,3
default,eu,3

idx=where(finite(f) eq 1)
if keyword_set(ignorezero) then begin
	idx2=where(f(idx) ne ignorezero)
	idx3=idx(idx2)
	idx=idx3
endif

mn=mean(f(idx))
st=stdev(f(idx))
if n_elements(n) eq 0 then return, [mn-el*st,mn+eu*st] else return, [mn-st,mn+st,n]
end
