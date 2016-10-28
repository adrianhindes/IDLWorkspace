function sinc,x
return,sin(!pi*x)/(!pi*x)
end
n=600
x=findgen(n)/n

freq=100;.5

f=(findgen(10*n)-5*n)/10.
s=complexarr(10*n)

expr1 = sinc(f) * exp(complex(0,1)*2*!pi*f*0.5)
expr2 = sinc(f) * exp(complex(0,1)*2*!pi*f*1.5)
expr=(expr1+expr2)/2
exprb=sinc(2*f) * exp(complex(0,1)*2*!pi*f)
xr=[-30,30]/2./10.
plotm,f,c2v(expr1),xr=xr,pos=posarr(2,1,0)
plotm,f,c2v(expr2),/oplot,linesty=2
plotm,f,c2v(expr),xr=xr,pos=posarr(/next),/noer
plotm,f,c2v(exprb),/oplot,linesty=2
end

