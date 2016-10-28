nx=201
x=linspace(-1,1,nx)
c0=0.3
c1=0

h0=2
h1=0.

y0=fltarr(nx) & y1=y0

y0(0:value_locate(x,c0))=1./(1+c0) * (x(0:value_locate(x,c0))+1)
y0(value_locate(x,c0)+1:*)=1./(-1+c0) * (x(value_locate(x,c0)+1:*)-1)
y0=y0*h0+1
y1(0:value_locate(x,c1))=1./(1+c1) * (x(0:value_locate(x,c1))+1)
y1(value_locate(x,c1)+1:*)=1./(-1+c1) * (x(value_locate(x,c1)+1:*)-1)
y1=y1*h1+1

plot,x,y0
oplot,x,y1,col=2
stop
plot,y0/y1
end
