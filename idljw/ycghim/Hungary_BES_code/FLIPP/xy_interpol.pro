function xy_interpol,x,y,x1
; interpolates y(x) at x1 coordinates
; x should be a monotonous function
nx=(size(x))(1)
nx1=(size(x1))(1)
y1=fltarr(nx1)
for i=0,nx1-1 do begin
  i1=where(x ge x1(i))
  if ((size(i1))(0) eq 0) then begin
    i1 = (where(x eq max(x)))(0)
    if (i1 eq 0) then begin
      i2 = 1
    endif else begin
      i2 = nx-2
    endelse
    goto,cont
  endif
  i2=where(x lt x1(i))
  if ((size(i2))(0) eq 0) then begin
    i2 = (where(x eq min(x)))(0)
    if (i2 eq 0) then begin
      i1 = 1
    endif else begin
      i1 = nx-2
    endelse
    goto,cont
  endif
  xi1=x(i1)
  xi2=x(i2)  
  i1 = i1((where(xi1 eq min(xi1)))(0))
  i2 = i2((where(xi2 eq max(xi2)))(0))
cont:
  y1(i)=float(y(i2)-y(i1))*((x1(i)-x(i1))/(x(i2)-x(i1)))+y(i1)
endfor
return,y1
end
