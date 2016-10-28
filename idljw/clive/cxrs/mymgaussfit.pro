

function mymgaussfit, xp, a
;here doubel guass

;x - delays [ replicate twice]
;y - real then imaginary part
common cbmgf2, xtrue2,cohwhite
;n=n_elements(x)
;n2=n/2
x=xtrue2(xp)
cohwhitesub=cohwhite(xp)
tmp=fgaussof(x,a[1],a[2],pder1=pder2,pder2=pder3)
a4=a[3]
a5=a[4]
a6=a[5]

tmp2=fgaussof(x,a5,a6,pder1=pder6,pder2=pder7)


a3=0
pder1=tmp * exp(complex(0,1)*a3) - cohwhitesub

;pder4=tmp * a[0] * exp(complex(0,1)*a3) * complex(0,1)

f=a[0]*exp(complex(0,1)*a3)*tmp + (1-a[0]-a4) * cohwhitesub + $
  a4 * tmp2

pder2 *= a[0] * exp(complex(0,1)*a3)
pder3 *= a[0] * exp(complex(0,1)*a3)

pder5=tmp2 - cohwhitesub
pder6 *= a4
pder7 *= a4

pder=transpose([[ri(f,xp)],[ri(pder1,xp)],[ri(pder2,xp)],$
                [ri(pder3,xp)],$
;                [ri(pder4,xp)],$
                [ri(pder5,xp)],[ri(pder6,xp)],$
                [ri(pder7,xp)]])


return,pder
end
