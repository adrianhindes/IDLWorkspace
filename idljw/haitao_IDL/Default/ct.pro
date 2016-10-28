function ct,l,wl
l=double(l)
wl=double(wl)
c=3.0*1e8 
m=1.67*1e-27 
k=1.38*1e-23

;carbon658 chariactraisatic temperature
delta_n=linbo3(wl, kapa=kapa)
ct=2*12*m*(wl*1e-9)^2*c^2/(l*1e-3)^2/k/kapa^2/delta_n^2/!pi^2/4/11600.0

return, ct
end