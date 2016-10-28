
n=1001
v=linspace(-10,10,n)

i=exp(v)-1

nkern=201
x=(linspace(-1,1,nkern+2))(1:nkern)
y=1/sqrt(1-x^2);abs(asin(x))
y/=total(y)
i2=convol(i,y)

plot,v,i+1,/ylog
oplot,v,i2+1,col=2

end
