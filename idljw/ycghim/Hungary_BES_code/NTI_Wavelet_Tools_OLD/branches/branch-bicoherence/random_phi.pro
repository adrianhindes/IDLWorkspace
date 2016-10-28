function random_phi,c

t=dindgen(32768)*0.001
dt=dindgen(512)*0.001

dphi=c*randomn(seed,64,/NORMAL)

phi=dindgen(32768)
phi[0]=0

phi[0:511]=dphi[0]*dt

for i=1L,63L do begin
    phi[i*512:(i+1)*512-1]=phi[i*512-1]+dphi[i]*dt
end

;plot,phi
return,phi

end