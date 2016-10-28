
f=linspace(10e3,30e3,1000)
w=2*!pi*f
ii=complex(0,1)



rs=50.*2
l=10e-3;4.78e-5 / fact
c=4.7e-9;1e-6 * fact



fwant=25e3
want=fwant*2*!pi
cwant=1/want^2/l
ctrim = 1/ (1/cwant-1/c )
print,'ctrim=',ctrim/1e-9,'nf'

c=1/(1/c+1/ctrim)

print,'cnet=',c/1e-9,'nf'
;c=c+ctrim
za1= ii*w * l 
za2= 1/(ii * w * c) 
za=za1+za2 + rs
zb = 10.

;1/(1/zb1 + 1/zb2)


vout=abs(zb/(za+zb))
plot,f,vout

dum=max(vout,imax)
ia=value_locate(vout(0:imax),dum/2)
ib=value_locate(vout(imax:*),dum/2)&ib+=imax
fwhm=f(ib)-f(ia)
print,'fwhm=',fwhm
end
