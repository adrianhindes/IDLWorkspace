function sell2, co, l,doder=doder, der=der
A=co(0)
B=co(1)
C=co(2)
D=co(3)
E=co(4)

n = (A + B / (1-C/l^2)  +  D /  (1  -  E/l^2) )^ 0.5

if keyword_set(doder) then begin
numerator=(-2*B*C)/((1 - C/l^2)^2*l^3) - (2*D*E)/((1 - E/l^2)^2*l^3)
der = numerator/2/n
endif
return,n
end

function dsell2,co,l,n
G=co(0)*1e-6
H=co(1)*1e-6
lig=co(2)/1e3 ; nm to micron
R=l^2/(l^2-lig^2)
dndt=(G*R + H*R^2 )/2/n

return,dndt
end


pro cbbo2, n_e=n_e,n_o=n_o,lambda=lambda,kappa=kappa,dnedl=dnedl,dnodl=dnodl,dn_edt=dn_edt,dn_odt=dn_odt,temp=temp,bi=bi
default,temp,20
default,lambda,656e-9
; these are bBBO

amat=[[1.7018379, 1.5920433],$
[ 1.0357554, 0.7816893],$
[ 0.018003440, 0.016067891],$
[ 1.2479989, 0.8403893],$
[91, 91]]


;Scott Silburn's numbers - aBBO - incorrect
;ao = double([2.7471, 0.01878, 0.01822, - 0.01354])
;ae = double([2.3174, 0.01224, 0.01667, - 0.01516])

l=lambda*1d6    ;wavelength in microns




n_o = sell2(amat(0,*),l,/doder,der=dnodl)
n_e = sell2(amat(1,*),l,/doder,der=dnedl)


bmat=transpose([[-19.300, -34.968, 65.2],$ ; o
[-141.421,110.863 , 73.0]]) ; e

dn_odt=dsell2(bmat(0,*),l,n_o)
dn_edt=dsell2(bmat(1,*),l,n_e)

n_e=n_e + (temp-20) * dn_edt
n_o=n_o + (temp-20) * dn_odt

dmudl = dnodl-dnedl

dnodl*=1e6
dnedl*=1e6

bi=n_e-n_o
kappa=1 - dmudl / (n_o-n_e) * l

end
