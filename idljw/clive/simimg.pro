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


pro opd,xc,yc,d,thickness=thickness,f2=f2,lambda=lambda,theta=theta,n_e=n_e,n_o=n_o,delta0=delta0

cbbo,n_e=n_e,n_o=n_o,lambda=lambda
default,delta0,0.
;,i=i,doff=doff
x=sqrt(xc^2+yc^2)

delta=atan(yc,xc)+ delta0
alpha = x /f2 

n_i=1.

; theta is the angle of the crystal axis wrt the waveplate surface (zero is a standard waveplate)
; alpha and delta are the incident angle and the azimuth

; allow to override the refractive indices - e.g. in case of temperature dependence

Denom = (n_e^2*sin(theta)^2+n_o^2*cos(theta)^2)
a1 = sqrt(n_o^2-n_i^2*sin(alpha)^2)
a2 = n_i*(n_o^2-n_e^2)*sin(theta)*cos(theta)*cos(delta)*sin(alpha)/Denom
a3 = -n_o*sqrt(n_e^2*(n_e^2*sin(theta)^2+n_o^2*cos(theta)^2)-(n_e^2-(n_e^2-n_o^2)*cos(theta)^2*sin(delta)^2)*n_i^2*sin(alpha)^2)/Denom
d = thickness/lambda*(a1+a2+a3)*2*!pi
end

function da, g
;common cbb,x2,y2
return,0.
end

function d1, g
common cbb,x2,y2,f2


pro simimg, s0=s0,s1=s1,s2=s2,s3=s3,$
            d1=d1,d2a=d2a,d2b=d2b,da=da,db=db,dc=dc,dd=dd,de=de,x1=x1,x2=x2,$
            res=res
default,da,0
default,db,0
default,dc,0
default,dd,0
default,de,0
default,x1,0
default,x2,0
default,s3,0.
default,s0,1.
default,s1,1.
default,s2,0.
Pi=!pi
res=        s0/2. + (s1*(-(Cos(d2b(g - Pi/2.))*(-(Cos(d1(da + g - Pi/4.))*Sin(2*(da + Pi/2.))) + $,
            Cos(2*(da + Pi/2.))*Sin(d1(da + g - Pi/4.))*Sin(d2a(da + g)))) - Cos(d2a(da + g))*Sin(d1(da + g - Pi/4.))*Sin(d2b(g - Pi/2.)))$,
     )/2. + (s2*(-(Sin(d2b(g - Pi/2.))*(-(Cos(d1(da + g - Pi/4.))*Cos(d2a(da + g))*Cos(da(da + g))) + $,
            Sin(d2a(da + g))*Sin(da(da + g)))) - Cos(d2b(g - Pi/2.))*$,
        (-(Cos(da(da + g))*Sin(2*(da + Pi/2.))*Sin(d1(da + g - Pi/4.))) + $,
          Cos(2*(da + Pi/2.))*(-(Cos(d1(da + g - Pi/4.))*Cos(da(da + g))*Sin(d2a(da + g))) - Cos(d2a(da + g))*Sin(da(da + g))))))/2. + $,
  (s3*(-(Sin(d2b(g - Pi/2.))*(-(Cos(da(da + g))*Sin(d2a(da + g))) - Cos(d1(da + g - Pi/4.))*Cos(d2a(da + g))*Sin(da(da + g)))) - $,
       Cos(d2b(g - Pi/2.))*(-(Sin(2*(da + Pi/2.))*Sin(d1(da + g - Pi/4.))*Sin(da(da + g))) + $,
          Cos(2*(da + Pi/2.))*(Cos(d2a(da + g))*Cos(da(da + g)) - Cos(d1(da + g - Pi/4.))*Sin(d2a(da + g))*Sin(da(da + g))))))/2.

end

pro tst
aw=16.6e-3;*0.1
n=2000/2
x1=linspace(-aw/2,aw/2,n)
y1=x1
x2=x1 # replicate(1,n)
y2=replicate(1,n) # y1
f2=105e-3 
lambda=656e-9
thickness=7.5e-3 & theta=55.*!dtor & delta0=0.*!dtor
opd,x2,y2,d1,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e,delta0=delta0
thickness=5.e-3 & theta=45.*!dtor  & delta0=-45.*!dtor
opd,x2,y2,d2a,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e,delta0=delta0
thickness=5.e-3 & theta=45.*!dtor  & delta0=45*!dtor
opd,x2,y2,d2b,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e,delta0=delta0


simimg,             d1=d1,d2a=d2a,d2b=d2b,$
            res=res,s1=0.9,s3=0.,dd=2.*!dtor,de=-2.*!dtor
imgplot,res,/iso
fr=fft(res)
fr=shift(fr,n/2,n/2)
imgplot,alog10(abs(fr)),/iso;,xr=[0,40],yr=[0,40]

stop
end
tst
end

