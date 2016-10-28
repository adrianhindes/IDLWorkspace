pro ploterr3,xp,yp,dyp,xr=xr,over=over,color=color,width=width,_extra=_extra
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
    oplot,x,y,color=color,_extra=_extra
endif else begin
    plot,x,y,xr=xr,color=color,_extra=_extra
endelse
default,color,!p.color
psav=!p.color
!p.color=color
;errplot,x,y-dy,y+dy,width=width

 idx=where(finite(y))
if keyword_set(xr) then  idx=where(finite(y) and x ge xr(0) and x le xr(1))



x1=x(idx)
y1=y(idx)
dy1=dy(idx)
yt=y1+dy1
yb=y1-dy1
n=n_elements(x1)
x2=[x1,reverse(x1),x1(0)]
y2=[yb,reverse(yt),yb(0)]

polyfill,x2,y2
!p.color=psav
;stop
end



    
