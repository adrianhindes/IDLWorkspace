pro findcirc, pts,cen,diam

x=pts(0,*)*1.
y=pts(1,*)*1.

mat1=[$
[x(0)^2+y(0)^2, y(0), 1],$
[x(1)^2+y(1)^2, y(1), 1],$
[x(2)^2+y(2)^2, y(2), 1]]

denommat=[$
[x(0),y(0),1],$
[x(1),y(1),1],$
[x(2),y(2),1]]


mat2=[$
[x(0),x(0)^2+y(0)^2,  1],$
[x(1),x(1)^2+y(1)^2,  1],$
[x(2),x(2)^2+y(2)^2,  1]]


h = determ(mat1) / 2 / determ(denommat)

k = determ(mat2) / 2 / determ(denommat)

r=sqrt( (x(0) - h)^2 + (y(0)-k)^2 )
diam=2*r
cen=[h,k]
;stop

end
