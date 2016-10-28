pro cquartz, n_e=n_e,n_o=n_o,lambda=lambda
default,lambda,656e-9

;, lambda, n_e=n_e, n_o=n_o, dnedl=dnedl, dnodl=dnodl, dmudl=dmudl, sell2=sell2

; see document Quartz_mgf2_thorlabs_sellmeier.pdf
a1=1.28851804D
a2=1.09509924D
a3=1.02101864D-2
a4=1.15662475D
a5=100.D

b1=1.28604141D
b2=1.07044083D
b3=1.00585997d-2
b4=1.10202242D
b5=100.D

l = lambda*1d6
l2 = l^2
n_e=sqrt(a1+(a2*l2)/(l2-a3)+(a4*l2)/(l2-a5))
n_o=sqrt(b1+(b2*l2)/(l2-b3)+(b4*l2)/(l2-b5))

dnodl = -l*( a3*a2/(l2-a3)^2 + a4*a5/(l2-a5)^2 )/n_o
dnedl = -l*( b3*b2/(l2-b3)^2 + b4*b5/(l2-b5)^2 )/n_e
dmudl = dnedl - dnodl

end


d=(read_ascii('~/kstartestimages/b')).(0)
d2=(read_ascii('~/kstartestimages/wp2')).(0)

lcal=[580.44496,581.14066,582.01558,585.24878,587.28275,588.1895,591.3633,591.89068,594.4834,596.5471,597.46273,597.55343,598.79074,600.09275,602.99968,607.43376,609.6163,612.84498,614.2508,614.30627,615.02985,616.35937,618.2146,620.57775,621.38758,621.72812,624.67294,625.87884,626.64952,629.37447,630.47893,631.36855,632.81646,633.08894,633.44276,635.18532,636.49963,638.29914,640.1076,640.2248,640.97469,642.17044,644.47118,650.65277,653.28824,659.89528,660.29007,665.20925,666.6892,667.82766,692.94672,702.405,703.24128,705.12922,705.91079,717.3938,724.51665,743.88981,747.24383,748.88712,753.57739]
y=[5000,3000,5000,20000,5000,10000,2500,2500,5000,5000,5000,6000,1500,1000,10000,10000,3000,1000,1000,10000,1000,10000,1500,1000,1500,10000,1000,1000,10000,1000,1000,1500,3000,1500,10000,1000,1000,10000,1000,20000,1500,1000,1500,15000,1000,10000,1000,1500,1000,5000,100000,34000,85000,2200,10000,77000,77000,60000,3100,32000,28000]


del=-0.1
disp = 0.0345



lb=[[lcal-del],[lcal],[lcal+del]]
n=n_elements(y)
yb=[[replicate(0,n)],[y],[replicate(0,n)]]
lb2=reform(transpose(lb),n*3)
yb2=reform(transpose(yb),n*3)
cwl=642+del
span=20.
plot,lb2,yb2,xr=cwl+[-1,1]*span/2
nd=n_elements(d)
ix=findgen(nd)-nd/2
ld = cwl + ix * disp
d=d-min(d)
d2=d2-min(d2)
plot,ld,d,/noer,col=2,xr=!x.crange
qty=smooth(d2,30)
plot,ld,qty,/noer,col=4,xr=!x.crange,thick=3
plot,ld,deriv(ld,qty),/noer,col=5,xr=!x.crange,thick=4,yr=[-10,10]*5
oplot,!x.crange,[0,0]
aa=642.2
oplot,aa*[1,1],!y.crange

lam=642.2e-9
cquartz,n_e=n_e,n_o=n_o,lambda=lam
nwav = 8.5
thick = nwav * lam / (n_e-n_o)
print,'thick=',thick/1e-3

lam2=660.2e-9
cquartz,n_e=n_e,n_o=n_o,lambda=lam2
nwav2 = thick * (n_e-n_o)/lam2
print,'nwav2=',nwav2
print,(nwav2-8)*360


e=(read_ascii('~/kstartestimages/c')).(0)
e2=(read_ascii('~/kstartestimages/d')).(0)

del2=0.1
disp2 = 0.0345
cwl2=656.+del2
ld2 = cwl2 + ix * disp2
stop
plot,lb2,yb2,xr=cwl2+[-1,1]*span/2

plot,ld2,e-min(e),xr=!x.crange,col=2,/noer
plot,ld2,e2-min(e2),xr=!x.crange,col=4,/noer

lam3=660.29e-9
cquartz,n_e=n_e,n_o=n_o,lambda=lam3
nwav3 = thick * (n_e-n_o)/lam3
print,'nwav3=',nwav3
print,(nwav3-8)*360

lam3=580e-9
cquartz,n_e=n_e,n_o=n_o,lambda=lam3
nwav3 = thick * (n_e-n_o)/lam3
print,'nwav3=',nwav3



end
