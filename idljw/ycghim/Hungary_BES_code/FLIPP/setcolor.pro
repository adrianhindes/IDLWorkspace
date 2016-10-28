pro setcolor,levels=levels,c_colors=c_colors,scheme=scheme,noset=noset

;*************************************************************************
; Sets the color table. If <levels> is set then sets as many colors as
; the number of elements in <levels>, otherwise sets the full color table.
; returns the color indices assigned to the levels in <c_colors>.
; Use this procedure before erasing the screen.
; INPUT
;   scheme: color scheme ('red-white-blue','blue-white-red','white-black',
;                         'black-white')
;   levels: list of levels (e.g. levels for a contour plot)
;   /noset: do not set colors only background
; OUTPUT
;   c_colors: color indices for levels
;************************************************************************

if (defined(levels)) then n=n_elements(levels) else n=!d.n_colors-2<256
if (defined(levels)) then ll=float(levels) else ll=findgen(n)
default,scheme,'black-white'

if (n gt !d.n_colors-1) then begin
  print,'Too many colors needed, device has only '+i2str(!d.n_colors)+' colors.'
  print,'Cannot set color table.'
  stop
endif

if ((!d.name eq 'X') and $
    ((scheme eq 'blue-white-red') or (scheme eq 'white-black'))) then begin
  !p.background=!d.n_colors-1
  !p.color=0
endif
if ((!d.name eq 'X') and $
    ((scheme eq 'blue-black-red') or (scheme eq 'black-white'))) then begin
  !p.background=0
  !p.color=!d.n_colors-1
endif

maxint=255
case (scheme) of
  'blue-black-red': begin
       a=max(abs(ll))
       r=ll
       g=ll
       b=ll
       ind=where(ll ge 0)
       if ((size(ind))(0) ne 0) then begin
         v=ll(ind)/a
         r(ind)=v
         g(ind)=0
         b(ind)=0
       endif
       ind=where(ll lt 0)
       if ((size(ind))(0) ne 0) then begin
         v=-ll(ind)/a
         r(ind)=0
         g(ind)=0
         b(ind)=v
       endif
     end
  'blue-white-red': begin
       a=max(abs(ll))
       r=ll
       g=ll
       b=ll
       ind=where(ll ge 0)
       if ((size(ind))(0) ne 0) then begin
         v=ll(ind)/a
         r(ind)=1
         g(ind)=1-v
         b(ind)=1-v
       endif
       ind=where(ll lt 0)
       if ((size(ind))(0) ne 0) then begin
         v=-ll(ind)/a
         r(ind)=1-v
         g(ind)=1-v
         b(ind)=1
       endif
     end
  'white-black': begin
       r=(max(ll)-ll)/(max(ll)-min(ll))
       g=r
       b=r
     end
  'black-white': begin
       r=(ll-min(ll))/(max(ll)-min(ll))
       g=r
       b=r
     end
  else:  begin
      print,'SETCOLOR.PRO: Unknown color scheme:'+scheme
      print,'Exiting.'
      retall
    end
endcase

r=r*maxint
g=g*maxint
b=b*maxint
if (!d.n_colors le 256) then begin
  ; This is probably a pseudo-color device
    if (not keyword_set(noset)) then tvlct,r,g,b,1
  c_colors=findgen(n_elements(r))+1
endif else begin
  ; This is probably a true-color device
  c_colors=r+long(g)*256+long(b)*256*256
endelse

end


