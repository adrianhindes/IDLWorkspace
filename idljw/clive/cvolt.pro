;volt1=80e3
;volt2=95e3

volt1=80.627e3
volt2=80.637e3

volt1=95.655e3
volt2=95.697e3

volt1=86.631e3
volt2=86.679e3

e=1.6e-19
mi=1.67e-27

c=3e8

l0=656.

dl=[l0 * sqrt(2*e*volt1/(2*mi)) / c,l0 * sqrt(2*e*volt2/(2*mi)) / c]


print,dl

gencarriers2,th=[0,0],sh=7425,kz=kz,kappa=kappa

nwav=kz(1) * dl/l0 * kappa
print,'delta nwav = ',nwav
print,'diff=',nwav(1)-nwav(0)
print, ' in deg is ',(nwav(1)-nwav(0))*360
end
