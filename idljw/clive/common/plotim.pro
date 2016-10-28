pro plotim,f,_extra=_extra
x=float(f)
y=imaginary(f)
rng=max([x,y])*[-1,1]
plot,x,y,xr=rng,yr=rng,/iso,psym=3,_extra=_extra
end
