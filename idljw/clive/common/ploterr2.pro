pro ploterr2,xp,yp,dyp,over=over,color=color,width=width,thick=thick,_extra=_extra
if n_elements(dyp) eq 0 then begin
    dy=yp
    y=xp
    x=findgen(n_elements(y))
endif else begin
    y=yp
    dy=dyp
    x=xp
endelse


if keyword_set(over) then begin
    oplot,x,y,color=color,thick=thick,_extra=_extra
endif else begin
    plot,x,y,color=color,thick=thick,_extra=_extra
endelse
default,color,!p.color
psav=!p.color
!p.color=color
errplot,x,y-dy,y+dy,width=width,thick=thick
!p.color=psav
end

    
