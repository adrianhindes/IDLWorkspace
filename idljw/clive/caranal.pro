restore,file='~/car.sav',/verb
iix=indgen(n_elements(x))
;is=where((x le 800) and (iix ne 3))
is=(where(x gt 800))

y=round(y/5.)*5.
x=round(x)
x=x(is)
y=y(is)
plot,x,y,psym=-4

n=n_elements(x)



dx=x(1:n-1)-x(0:n-2)
x1=x(1:n-1)
y1=y(1:n-1)
dy=y(1:n-1)-y(0:n-2)
acc=dy/dx
;dat=transpose([[x],[y]])
dat=transpose([[x1],[dx],[y1],[acc]])
print,dat

yms=y * 1000 / 3600
;plot,x,yms,psym=-4

nmax=5000
xn=linspace(x(0),x(n-1),nmax)
yn=interpol(yms,x,xn)
;plot,xn,yn
dx=xn(1)-xn(0)
dn=total(yn,/cumulative) * dx
;plot,xn,dn
;plot,dn,yn
dst=int_tabulated(x,yms)
print,dst
dxn2=5.
n2=round( (x(n-1)-x(0))/dxn2)
xn2=findgen(n2)*dxn2+x(0)
yn2=interpol(yn,xn,xn2)*3.6
xn2-=x(0)
dtab=transpose([[xn2],[yn2]])
print,dtab
end
