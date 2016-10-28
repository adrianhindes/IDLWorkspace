function dee,var,fun
sz=size(fun,/dim)
nx=sz(0)
ny=sz(1)
rv=fun*0
if var eq 'x' then begin
for i=0,ny-1 do begin
   rv(*,i)=deriv(fun(*,i))
endfor
endif

if var eq 'y' then begin
for i=0,nx-1 do begin
   rv(i,*)=deriv(fun(i,*))
endfor
endif
return,rv
end
