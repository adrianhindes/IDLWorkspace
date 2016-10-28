;************************************************************
function amod,a
; this returns the given angle a as an angle on [-!pi,!pi]
return,( (((a+!pi) mod (2*!pi)) +(2*!pi)) mod (2*!pi))-!pi
end
;************************************************************
function bmod,a
; this returns the given angle a as an angle on [0,2*!pi]
return,( ((a mod (2*!pi)) +(2*!pi)) mod (2*!pi))
end
;+
; x=edge_detector(y, thresh=thresh, direction=direction)
; returns the positions in the array y at which leading or trailing
; edges exceeding a threshold THRESH occur.
; DIRECTION gives the corresponding sign of the transistion
;-
function edge_detector, phase, thresh=thresh, direction=d
default, thresh, 2*!pi
pplusnext=phase(1:*)+thresh
pminusnext=phase(1:*)-thresh
pnext=phase(1:*)	; leave first point alone
pthis=phase(0:n_elements(phase)-2)
;inc=lonarr(n_elements(pnext))
wplus=where(abs(pplusnext-pthis) lt abs(pnext-pthis))
;if w(0) ne -1 then inc(w)=1
wminus=where(abs(pminusnext-pthis) lt abs(pnext-pthis))
;if w(0) ne -1 then inc(w)=-1
w=[-1]  &  d=[0]
if wplus(0) ne -1 then begin
	w = [w, wplus] & d=[d, replicate(-1,n_elements(wplus))]
end
if wminus(0) ne -1 then begin
	w = [w,wminus] & d=[d, replicate(1,n_elements(wminus))]
end
nw = n_elements(w)
if nw gt 1 then begin
	w=w(1:nw-1)  &  d=d(1:nw-1)
end
srt = sort(w)  &  w=w(srt)  &  d=d(srt)  
return, w
end


;+
; Create amod and bmod of the supplied phase.
; use an edge detector to
; swap between these complementary signals to eliminate noise spikes
;-
function phs_jump, phase,  thresh = thresh
forward_function edge_detector

default, thresh, 2*!pi
twopi=2*!pi
pb = bmod(phase)	;map to [0, 2pi]
pa = amod(phase)	;map to [-pi,pi]
pb = phase(0)-pb(0)+pb
pa = phase(0)-pa(0)+pa

; use transition points to switch between pa and pb

xa = edge_detector(pa, thresh=thresh)
xb = edge_detector(pb, thresh=thresh)

if xa(0) eq -1 then return, pa
if xb(0) eq -1 then return, pb
nxa = n_elements(xa)  &  nxb=n_elements(xb)

; swap the traces at the transition points
;  if xa(0) ge xb(0) then phs = pa else phs = pb 
  xx=[xa,xb]  &  ab = [replicate(1,nxa),replicate(-1,nxb)]
  sx = uniq(xx, sort(xx))  &  xx=xx(sx)  &  ab=ab(sx)

; create array phs.  Make it equal to whichever of pa or pb finishes
; this is not the correct thing to do!
;  if xa(nxa-1) ge xb(nxb-1) then phs = pb else phs=pa
  
; create the new phase array 
  phs = pa  
; add a final point to close the interval
  xx = [xx, n_elements(phs)-1]

  for n=0L, n_elements(xx)-2 do begin & $
    k = xx(n)  &  k1=xx(n+1) & $
;    if n eq n_elements(xx)-2 then k1 = n_elements(phs)-1
    if ab(n) eq -1 then begin & $
	phs(k+1:k1)=phs(k)+pa(k+1:k1)-pa(k) & $
    end else begin & $
	phs(k+1:k1)=phs(k)+pb(k+1:k1)-pb(k) & $
    end & $
  end
  return, phs

end

pro test_phs_jump
a=findgen(200)*.1
a=[a,reverse(a)]
!p.multi=[0,1,3]
plot,bmod(a),titl='BMOD'
plot,amod(a),titl='AMOD'
plot,phs_jump(a),titl='PHS_JUMP'
stop
end
