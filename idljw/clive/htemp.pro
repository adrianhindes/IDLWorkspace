temp = 1000.;k
temp2 = 2.;ev
hplanck=6.6e-34
echarge=1.6d-19
kb=1.38d-23

mi=1.67d-27
clight=1d8
nlam=1001
lam=linspace(0.001,1,nlam)

v = lam/656. * clight

absc = -0.5 * mi * v^2 / (kb * temp)

gaus=exp(absc)
gaus/=total(gaus)

absc2 = -0.5 * mi * v^2 / (echarge * temp2)
gaus2=exp(absc2)
gaus2/=total(gaus2)

gaust=gaus+gaus2*0.1

disp = 0.3*1d-10/1d-3 ;ang/mm

pos=lam*1e-9 / disp

plot,pos,gaust,/xlog,psym=-4
plot,pos,gaust,/ylog,psym=-4,yr=[1e-4,1]

end

