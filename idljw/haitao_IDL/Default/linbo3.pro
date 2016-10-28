function linbo3, lambda, n_e=n_e, n_o=n_o, dnedl=dnedl, dnodl=dnodl, dmudl=dmudl,  T = T,kapa=kapa
; calculate ne, no using the sellmeier equation
; see website http://www.newsight.com/newsight/dcasix/casixlnb.htm
;
; inout temperature in degrees kelvin
default,  T,  297.5
; temperature in degrees centigrade
Tc = T-273
T0 = 24.5
F = double((Tc-T0)*(Tc+570.5))

ae=[4.5820D, 9.921d4, 2.109d2, -2.194d-8]
ao=[4.9048D, 1.1775d5, 2.1802d2, -2.7153d-8]

be = [5.2716d-2, -4.9143d-5, 2.2971d-7]*F
bo = [2.2314d-2, -2.9671d-5, 2.1429d-8]*F
l=lambda ;wavelenth in nm
n_e = sqrt(ae(0)+(ae(1)+be(0))/(l^2-(ae(2)+be(1))^2)+be(2)+ae(3)*l^2)
n_o = sqrt(ao(0)+(ao(1)+bo(0))/(l^2-(ao(2)+bo(1))^2)+bo(2)+ao(3)*l^2)
dnedl = l/n_e*(-(ae(1)+be(0))/(l^2-(ae(2)+be(1))^2)^2+ae(3))
dnodl = l/n_o*(-(ao(1)+bo(0))/(l^2-(ao(2)+bo(1))^2)^2+ao(3))
dmudl = dnodl-dnedl
kapa=1+l*dmudl/(n_e-n_o)
return, n_e-n_o
end