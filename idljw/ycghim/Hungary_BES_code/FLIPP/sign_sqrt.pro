function sign_sqrt,x
    
if ((size(x))(0) eq 0) then begin
  if (x lt 0) then return,-sqrt(abs(x)) else return,sqrt(x)
endif else begin
  x1=x
  ind=where(x lt 0)
  if (ind(0) ge 0) then x1(ind)=-sqrt(abs(x(ind)))
  ind=where(x ge 0)
  if (ind(0) ge 0) then x1(ind)=sqrt(x(ind))
  return,x1
endelse  
end
