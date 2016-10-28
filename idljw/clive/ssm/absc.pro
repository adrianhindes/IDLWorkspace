function absc, z
r=float(z)
i=imaginary(z)
idx=where(r lt 0)
if idx(0) ne -1 then begin
    r(idx)=-r(idx)
    i(idx)=-i(idx)
endif

r2=float(z)
i2=imaginary(z)
idx=where(i2 lt 0)
if idx(0) ne -1 then begin
    r2(idx)=-r2(idx)
    i2(idx)=-i2(idx)
endif
t1=total(i)/total(r)
t2=total(i2)/total(r2)
w1=total(r)^2 + total(i)^2
w2=total(r2)^2 + total(i2)^2
tt=(t1*w1+t2*w2)/(w1+w2)
if tt gt 1 then zr=complex(r2,i2) else zr=complex(r,i)
return,zr
end
