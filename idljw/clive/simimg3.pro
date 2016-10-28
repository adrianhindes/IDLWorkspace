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




pro opd,xc,yc,d,thickness=thickness,f2=f2,lambda=lambda,theta=theta,n_e=n_e,n_o=n_o,delta0=delta0,crystal=crystal

default,lambda,656.e-9
default,crystal,'bbo'
if crystal eq 'bbo' then cbbo,n_e=n_e,n_o=n_o,lambda=lambda
if crystal eq 'quartz' then cquartz,n_e=n_e,n_o=n_o,lambda=lambda

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
; common cba,da
; print,'call da',g*!radeg
; if n_elements(da) ne 0 then return,da
; common cbb,x2,y2,f2
; thickness=0.6e-3 * (8*360+10.)/(8*360) & theta=0.*!dtor 
; opd,x2,y2,da,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e,delta0=g,crystal='quartz'
; ;stop
; sz=size(da,/dim)
; ma=da[sz(0)/2,sz(1)/2]
; sgn=ma/abs(ma)
; da=da-!pi/2*sgn ; subtract quarter wave
; print,da[sz(0)/2,sz(1)/2]/2/!pi

da=0;-!pi/2
;stop
return,da
end

function d1, g
print,'call d1',g*!radeg
common cb1,d1
if n_elements(d1) ne 0 then return,d1
common cbb,x2,y2,f2
thickness=7.5e-3 & theta=55.*!dtor 
opd,x2,y2,d1,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e,delta0=g
return,d1
end

function d2a, g
print,'call d2a',g*!radeg
common cb2a,d2a
if n_elements(d2a) ne 0 then return,d2a
common cbb,x2,y2,f2
thickness=5.e-3 & theta=45.*!dtor  
opd,x2,y2,d2a,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e,delta0=g
return,d2a
end

function d2b, g
print,'call d2b',g*!radeg
common cb2b,d2b
if n_elements(d2b) ne 0 then return,d2b
common cbb,x2,y2,f2
thickness=5.e-3 & theta=45.*!dtor  
opd,x2,y2,d2b,f2=f2,thickness=thickness,lambda=lambda,theta=theta,n_o=n_o,n_e=n_e,delta0=g
return,d2b
end



pro simimg, s0=s0,s1=s1,s2=s2,s3=s3,$
           db=db,dc=dc,dd=dd,de=de,$
            res=res

default,db,0
default,dc,0
default,dd,0
default,de,0
default,s3,0.
default,s0,1.
default,s1,1.
default,s2,0.
Pi=!pi
g=0. ; dummy init azimuth
res=           s0/2. + (s1*(Cos(2*(-dd + de - Pi/4.))*(Cos(2*(-dc + dd + Pi/2.))*$,
           (Cos(2*(-db + dc - Pi/4.))*Cos(2*(db + Pi/4.)) - Cos(d1(-db + g - Pi/4.))*Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))) + $,
          Sin(2*(-dc + dd + Pi/2.))*(Cos(d2a(-dc + g))*$,
              (-(Cos(2*(db + Pi/4.))*Sin(2*(-db + dc - Pi/4.))) - Cos(2*(-db + dc - Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(2*(db + Pi/4.)))$,
              + Sin(2*(db + Pi/4.))*Sin(d1(-db + g - Pi/4.))*Sin(d2a(-dc + g)))) + $,
       Sin(2*(-dd + de - Pi/4.))*(Cos(d2b(-dd + g - Pi/2.))*$,
           (-((Cos(2*(-db + dc - Pi/4.))*Cos(2*(db + Pi/4.)) - Cos(d1(-db + g - Pi/4.))*Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.)))*$,
                Sin(2*(-dc + dd + Pi/2.))) + Cos(2*(-dc + dd + Pi/2.))*$,
              (Cos(d2a(-dc + g))*(-(Cos(2*(db + Pi/4.))*Sin(2*(-db + dc - Pi/4.))) - $,
                   Cos(2*(-db + dc - Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(2*(db + Pi/4.))) + $,
                Sin(2*(db + Pi/4.))*Sin(d1(-db + g - Pi/4.))*Sin(d2a(-dc + g)))) + $,
          (Cos(d2a(-dc + g))*Sin(2*(db + Pi/4.))*Sin(d1(-db + g - Pi/4.)) - $,
             (-(Cos(2*(db + Pi/4.))*Sin(2*(-db + dc - Pi/4.))) - Cos(2*(-db + dc - Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(2*(db + Pi/4.)))*$,
              Sin(d2a(-dc + g)))*Sin(d2b(-dd + g - Pi/2.)))))/2. + $,
  (s2*(Cos(2*(-dd + de - Pi/4.))*(Cos(2*(-dc + dd + Pi/2.))*$,
           (-(Cos(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))*Sin(da(g))) + $,
             Sin(2*(-db + dc - Pi/4.))*(-(Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(da(g))))$,
            + Sin(2*(-dc + dd + Pi/2.))*(Sin(d2a(-dc + g))*$,
              (-(Cos(d1(-db + g - Pi/4.))*Cos(da(g))) + Cos(2*(db + Pi/4.))*Sin(d1(-db + g - Pi/4.))*Sin(da(g))) + $,
             Cos(d2a(-dc + g))*(Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))*Sin(da(g)) + $,
                Cos(2*(-db + dc - Pi/4.))*(-(Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - $,
                   Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(da(g)))))) + $,
       Sin(2*(-dd + de - Pi/4.))*(Sin(d2b(-dd + g - Pi/2.))*$,
           (Cos(d2a(-dc + g))*(-(Cos(d1(-db + g - Pi/4.))*Cos(da(g))) + Cos(2*(db + Pi/4.))*Sin(d1(-db + g - Pi/4.))*Sin(da(g))) - $,
             Sin(d2a(-dc + g))*(Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))*Sin(da(g)) + $,
                Cos(2*(-db + dc - Pi/4.))*(-(Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - $,
                   Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(da(g))))) + $,
          Cos(d2b(-dd + g - Pi/2.))*(-(Sin(2*(-dc + dd + Pi/2.))*$,
                (-(Cos(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))*Sin(da(g))) + $,
                  Sin(2*(-db + dc - Pi/4.))*(-(Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - $,
                     Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(da(g))))) + $,
             Cos(2*(-dc + dd + Pi/2.))*(Sin(d2a(-dc + g))*$,
                 (-(Cos(d1(-db + g - Pi/4.))*Cos(da(g))) + Cos(2*(db + Pi/4.))*Sin(d1(-db + g - Pi/4.))*Sin(da(g))) + $,
                Cos(d2a(-dc + g))*(Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))*Sin(da(g)) + $,
                   Cos(2*(-db + dc - Pi/4.))*(-(Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - $,
                      Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Sin(da(g)))))))))/2. + $,
  (s3*(Cos(2*(-dd + de - Pi/4.))*(Cos(2*(-dc + dd + Pi/2.))*$,
           (Cos(2*(-db + dc - Pi/4.))*Cos(da(g))*Sin(2*(db + Pi/4.)) + $,
             Sin(2*(-db + dc - Pi/4.))*(Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Cos(da(g)) - Sin(d1(-db + g - Pi/4.))*Sin(da(g)))) + $,
          Sin(2*(-dc + dd + Pi/2.))*(Sin(d2a(-dc + g))*$,
              (-(Cos(2*(db + Pi/4.))*Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - Cos(d1(-db + g - Pi/4.))*Sin(da(g))) + $,
             Cos(d2a(-dc + g))*(-(Cos(da(g))*Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))) + $,
                Cos(2*(-db + dc - Pi/4.))*(Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Cos(da(g)) - Sin(d1(-db + g - Pi/4.))*Sin(da(g))))$,
             )) + Sin(2*(-dd + de - Pi/4.))*(Sin(d2b(-dd + g - Pi/2.))*$,
           (Cos(d2a(-dc + g))*(-(Cos(2*(db + Pi/4.))*Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - Cos(d1(-db + g - Pi/4.))*Sin(da(g))) - $,
             Sin(d2a(-dc + g))*(-(Cos(da(g))*Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))) + $,
                Cos(2*(-db + dc - Pi/4.))*(Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Cos(da(g)) - Sin(d1(-db + g - Pi/4.))*Sin(da(g))))$,
             ) + Cos(d2b(-dd + g - Pi/2.))*(-(Sin(2*(-dc + dd + Pi/2.))*$,
                (Cos(2*(-db + dc - Pi/4.))*Cos(da(g))*Sin(2*(db + Pi/4.)) + $,
                  Sin(2*(-db + dc - Pi/4.))*(Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Cos(da(g)) - $,
                     Sin(d1(-db + g - Pi/4.))*Sin(da(g))))) + $,
             Cos(2*(-dc + dd + Pi/2.))*(Sin(d2a(-dc + g))*$,
                 (-(Cos(2*(db + Pi/4.))*Cos(da(g))*Sin(d1(-db + g - Pi/4.))) - Cos(d1(-db + g - Pi/4.))*Sin(da(g))) + $,
                Cos(d2a(-dc + g))*(-(Cos(da(g))*Sin(2*(-db + dc - Pi/4.))*Sin(2*(db + Pi/4.))) + $,
                   Cos(2*(-db + dc - Pi/4.))*(Cos(2*(db + Pi/4.))*Cos(d1(-db + g - Pi/4.))*Cos(da(g)) - $,
                      Sin(d1(-db + g - Pi/4.))*Sin(da(g)))))))))/2.




;     s0/2. + (s1*(Cos(d2b(g - Pi/2.))*Sin(d1(g - Pi/4.))*Sin(d2a(g)) - Cos(d2a(g))*Sin(d1(g - Pi/4.))*Sin(d2b(g - Pi/2.))))/2. + $,
;   (s2*(-(Cos(d2b(g - Pi/2.))*(Cos(d1(g - Pi/4.))*Cos(da(g))*Sin(d2a(g)) + Cos(d2a(g))*Sin(da(g)))) - $,
;        Sin(d2b(g - Pi/2.))*(-(Cos(d1(g - Pi/4.))*Cos(d2a(g))*Cos(da(g))) + Sin(d2a(g))*Sin(da(g)))))/2. + $,
;   (s3*(-(Sin(d2b(g - Pi/2.))*(-(Cos(da(g))*Sin(d2a(g))) - Cos(d1(g - Pi/4.))*Cos(d2a(g))*Sin(da(g)))) - $,
;        Cos(d2b(g - Pi/2.))*(-(Cos(d2a(g))*Cos(da(g))) + Cos(d1(g - Pi/4.))*Sin(d2a(g))*Sin(da(g)))))/2. 

end


function simimg3, ang,sm=sm
common cbb,x2,y2,f2

awx=16.6e-3
nx=2560/sm
ny=2160/sm
x1=linspace(-awx/2,awx/2,nx)
awy=awx * ny/nx
y1=linspace(-awy/2,awy/2,ny)
x2=x1 # replicate(1,ny)
y2=replicate(1,nx) # y1
f2=105e-3 
lambda=656e-9

common cba,da
common cb1,d1
common cb2a,d2a
common cb2b,d2b
if n_elements(da) ne 0 then dum=temporary(da)
if n_elements(d1) ne 0 then dum=temporary(d1)
if n_elements(d2a) ne 0 then dum=temporary(d2a)
if n_elements(d2b) ne 0 then dum=temporary(d2b)

sd=100
s1=cos(2*ang);-!pi/4)
s2=sin(2*ang);-!pi/4)
mag=3.
simimg,            res=res,s3=0.,s2=s2,s1=s1,dd=mag*!dtor*randomn(sd),de=mag*!dtor*randomn(sd),dc=mag*!dtor*randomn(sd),db=0*!dtor ;*randomn(sd)
;imgplot,res,/iso
;stop
;fr=fft(res)
;fr=shift(fr,n/2,n/2)
;imgplot,alog10(abs(fr)),/iso,/cb;,xr=[0,40],yr=[0,40]

;stop
return,res
;stop
end


