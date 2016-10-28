
f=linspace(1e3,100e3,1000)
w=2*!pi*f
ii=complex(0,1)



za= 50./3.
c=0.1*3e-6;4.7e-9 * fact
zb= 1/(ii * w * c) 


vout=abs(zb/(za+zb))^2

plot,f,vout,/ylog,/xlog
end
