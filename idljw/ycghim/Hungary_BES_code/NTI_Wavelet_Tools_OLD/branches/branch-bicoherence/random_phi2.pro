function random_phi2,c

dt=dindgen(2048)*5D-7

dphi=c*randomn(seed,30,/NORMAL)

phi=dindgen(61440)
phi[0]=0

phi[0:2047]=dphi[0]*dt

for i=1L,29L do begin
    phi[i*2048:(i+1)*2048-1]=phi[i*2048-1]+dphi[i]*dt
end

phi=phi[0:59999]

;plot,phi
return,phi

end