function range,from,to,step,npts=npts, num=num, exact = exact, close=close, endpoints=endpoints
if keyword_set(num) then npts=num
; e.g. y=range(1,10,/proto=1D) returns a list of 50 doubles between 1,10
; allow it to return integers only if we explicitly want it
if n_params() eq 0 then $
	stop,'RANGE - error: incorrect number of parameters'
if n_params() gt 3 then $
	stop,'RANGE - error: too many parameters'
if n_params() eq 1 then to=from 
if keyword_set(npts) then begin
  inc=(to-from)/(npts)
  if keyword_set(exact) or keyword_Set(close) or keyword_set(endpoints) then inc=( (to-from)/((npts-1) > 1))
end else begin
  if n_params() eq 2 then begin
	inc=to-from 
  end else begin
    if step eq 0 then npts=1 else npts=long( (to-from)/step +1)
    inc=step
  end
end
if (from ne 0) then Prot=from/from else $
if (to ne 0) then Prot=to/to else prot=from
if npts lt 1 then begin
;  print,'RANGE - warning: step size too big'
  if (to ne from) then range=[from,to] else range=[from]
end else if npts eq 1 then begin
  range=[from]
end else begin
  range=from + lindgen(npts)*inc
end
return,range
end
