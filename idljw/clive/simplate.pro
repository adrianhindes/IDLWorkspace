pro cbbo, n_e=n_e,n_o=n_o,lambda=lambda
default,lambda,656e-9
; these are bBBO
ao = double([2.7359,.01878,.01822,-.01354])
ae = double([2.3753,.01224,.01667,-.01516])

;Scott Silburn's numbers - aBBO - incorrect
;ao = double([2.7471, 0.01878, 0.01822, - 0.01354])
;ae = double([2.3174, 0.01224, 0.01667, - 0.01516])

l=lambda*1d6    ;wavelength in microns
n_e = sqrt(ae(0)+ae(1)/(l^2-ae(2))+ae(3)*l^2)
n_o = sqrt(ao(0)+ao(1)/(l^2-ao(2))+ao(3)*l^2)
dnedl = l/n_e*(-ae(1)/(l^2-ae(2))^2+ae(3))
dnodl = l/n_o*(-ao(1)/(l^2-ao(2))^2+ao(3))
dmudl = dnodl-dnedl
end


pro opd,xc,yc,d,thickness=thickness,f2=f2,lambda=lambda,theta=theta,n_e=n_e,n_o=n_o

cbbo,n_e=n_e,n_o=n_o,lambda=lambda
;,i=i,doff=doff
x=sqrt(xc^2+yc^2)

delta=atan(yc,xc)
alpha = x /f2

n_i=1.

; theta is the angle of the crystal axis wrt the waveplate surface (zero is a standard waveplate)
; alpha and delta are the incident angle and the azimuth

; allow to override the refractive indices - e.g. in case of temperature dependence

Denom = (n_e^2*sin(theta)^2+n_o^2*cos(theta)^2)
a1 = sqrt(n_o^2-n_i^2*sin(alpha)^2)
a2 = n_i*(n_o^2-n_e^2)*sin(theta)*cos(theta)*cos(delta)*sin(alpha)/Denom
a3 = -n_o*sqrt(n_e^2*(n_e^2*sin(theta)^2+n_o^2*cos(theta)^2)-(n_e^2-(n_e^2-n_o^2)*cos(theta)^2*sin(delta)^2)*n_i^2*sin(alpha)^2)/Denom
d = thickness/lambda*(a1+a2+a3)
end

pro tst
aw=20e-3
n=30
x1=linspace(-aw/2,aw/2,n)
y1=x1
x2=x1 # replicate(1,n)
y2=replicate(1,n) # y1
f2=105e-3 
thickness=5.e-3
lambda=656e-9
theta=0.*!dtor
opd,x2,y2,d,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e
;stop
end

