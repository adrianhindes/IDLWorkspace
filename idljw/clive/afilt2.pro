
f=linspace(1e3,100e3,1000)
w=2*!pi*f
ii=complex(0,1)



za= 50.
;fact = 500.
fact=1.
l=8e-6*3*fact;fact*15e-6;10e-3 / fact
c=1.5e-6/fact;1/fact*3.3e-6;4.7e-9 * fact
zb1= ii*w * l 
zb2= 1/(ii * w * c) 

zser=3.
zb1+=zser
zb=1/(1/zb1 + 1/zb2) 


vout=abs(zb/(za+zb))

plot,f,vout
end
