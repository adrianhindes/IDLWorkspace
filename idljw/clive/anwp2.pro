;qwp#1
order=5
lam=691.e-9 + 0.5e-9 * randomu(sd)
cquartz,n_e=n_e,n_o=n_o,lambda=lam
nwav = 0. + order
thick = nwav * lam / (n_e-n_o)
print,'thick=',thick/1e-3


lam=586.e-9+ 0.5e-9 * randomu(sd)
cquartz,n_e=n_e,n_o=n_o,lambda=lam
nwav = 1. + order
thick2 = nwav * lam / (n_e-n_o)
print,'thick=',thick2/1e-3
print,(thick2-thick)/(thick2+thick)

thick=(thick2+thick)/2.

;retall

lam=660.2e-9
cquartz,n_e=n_e,n_o=n_o,lambda=lam
nwav = thick2 /( lam / (n_e-n_o))

print, 'nwav=',nwav

cor=5.25 - nwav
print,cor*360.


end
