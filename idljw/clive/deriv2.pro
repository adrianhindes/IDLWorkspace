function deriv2, x, y, x2
n=n_elements(x)
x2=fltarr(n-1)
yd=fltarr(n-1)
for i=0,n-2 do begin
yd(i)=(y(i+1) - y(i) ) / (x(i+1) - x(i) )
x2(i) = 0.5 * (x(i+1) + x(i) )
endfor

return,yd
end
