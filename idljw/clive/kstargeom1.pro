;pro kstargeom1

b0=[3445,-1378,0.]
b1=[1487,-1440,0.]
;angle is -178.186
bv=b1-b0 & bv/=norm(bv)

p0=[2753,-82,285.]
p1=b1

pm=[3.7143, 0.0448, 0.0000]
print, acos(total(pm*b0)/sqrt(total(pm*pm)*total(b0*b0)))*!radeg
;print,norm(b1)
end



