pro mkfig, fname,_extra=_extra,pr=pr,col=col,tt=tt,hersh=hersh

common cb,fnameb

fnameb=fname
; dummy=findfile(fname,count=count)
; if count ne 0 then begin
;     print, 'warning: file '+fname+' exists. Overwrite?'
;     ans=''
;     read,ans
;     if strupcase(ans) ne 'Y' then return
; endif

set_plot,'ps'
default,col,1
if col eq 1 then begin
    tek_color
    ctfix
    !p.color=1
    !p.background=0
    print, 'done colour settings'
endif

if keyword_set(pr) then $
  device,enc=0,/col,file=fname,_extra=_extra $
  else $
  device,/enc,/col,file=fname,_extra=_extra
if keyword_set(tt) then !p.font=1 else $
  if keyword_set(hersh) then !p.font=-1 else !p.font=0


end

