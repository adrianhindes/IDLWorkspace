function perpdir, dir
if dir(0) ne 0 then perp = [-dir(1) /dir(0),1] else $
  perp = [1,-dir(0)/dir(1)]
perp=perp/sqrt(perp(0)^2+perp(1)^2)
cp=crossp( [dir,0], [perp,0] )
if cp(2) gt 0. then perp=-perp

return,perp
end

pro makebiggerby, x, y, xout, yout, by



n=n_elements(x)
xout = fltarr(n) & yout = xout
dir = [x(1)-x(0),y(1)-y(0)]
for i=0,n-1 do begin
    dirperp = perpdir(dir)

    xout(i) = x(i) + dirperp(0) * by
    yout(i) = y(i) + dirperp(1) * by
    if i ne n-1 then dir = [x(i+1)-x(i),y(i+1)-y(i)]
endfor

end
