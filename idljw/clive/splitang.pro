p0=[306,168.]
p1=[1376,872.]
p2=[2496,870.]
p3=[1354,1622.]
sx=p2(0)-p1(0)
sy=abs(p3(1)-p1(1))
dx=p1(0)-p0(0)
dy=abs(p1(1)-p0(1))

print,dy/dx / (4./6.)
seposize=[sx,sy]/[dx,dy]
f1=55.
siz=[6.,4.]

deltheta = seposize * siz / f1
print,deltheta * !radeg

end
