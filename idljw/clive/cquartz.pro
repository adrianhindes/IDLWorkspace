pro cquartz, n_e=n_e,n_o=n_o,lambda=lambda,dnedl=dnedl,dnodl=dnodl
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

dnodl*=1e6
dnedl*=1e6


dmudl = dnedl - dnodl

end
