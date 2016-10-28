function rotd,th,ix
if ix eq 2 then begin&i1=0&i2=1&end
if ix eq 1 then begin&i1=0&i2=2&end
if ix eq 0 then begin&i1=1&i2=2&end
mat=identity(3)
mat(i1,i1)=cos(th)
mat(i1,i2)=sin(th)
mat(i2,i1)=-sin(th)
mat(i2,i2)=cos(th)
return,mat
end

;pro kstargeom1

;b0=[3445,-1378,0.]
;b1=[1487,-1440,0.]
b0=[1440,-1487.,0] ; middle of field
b1=[1013,-1487.,0] ; beam inner point near mag axis

p0=[2753,-82,285.] ; window point

zhat=b0-p0 & zhat/=norm(zhat)
xhattmp=b1-b0 & xhattmp/=norm(xhattmp)
yhat=crossp(zhat,xhattmp) & yhat/=norm(yhat)

xhat=crossp(zhat,yhat)

b12 = rotd(1*!dtor,2) # zhat


xhattmp2=b12 & xhattmp2/=norm(xhattmp2)
yhat2=crossp(zhat,xhattmp2) & yhat2/=norm(yhat2)

xhat2=crossp(zhat,yhat2)

print,'the roll is',acos(total(xhat2 * xhat))*!radeg

; reflect mirror

p1 = p0+[1000,0,0]

zhatr=p1-p0  & zhatr/=norm(zhatr)

mvec = (zhatr + (-zhat))/2
mvec/=norm(mvec)


ahat=b1-p0 & ahat/=norm(ahat)

bhat=b12 & bhat/=norm(bhat)

zhatr2 = zhat - 2 * (total(zhat*mvec)) * mvec

ahatr2 = ahat - 2 * (total(ahat*mvec)) * mvec

bhatr2 = bhat - 2 * (total(bhat*mvec)) * mvec


print,zhatr2
print,ahatr2
print,bhatr2
print,'det plane angle=',atan(ahatr2(2),ahatr2(1))*!radeg

print,'rel angle=',acos(total(zhat * zhatr))*!radeg

end



