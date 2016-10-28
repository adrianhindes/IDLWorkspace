function mygaussbgfit, xp, a
;x - delays [ replicate twice]
;y - real then imaginary part
common cbmgf2, xtrue2,cohwhite
;n=n_elements(x)
;n2=n/2
x=xtrue2(xp)
cohwhitesub=cohwhite(xp)
tmp=fgaussof(x,a[1],a[2],pder1=pder2,pder2=pder3)

pder1=tmp * exp(complex(0,1)*a[3]) - cohwhitesub
pder4=tmp * a[0] * exp(complex(0,1)*a[3]) * complex(0,1)

f=a[0]*exp(complex(0,1)*a[3])*tmp + (1-a[0]) * cohwhitesub

pder2 *= a[0] * exp(complex(0,1)*a[3])
pder3 *= a[0] * exp(complex(0,1)*a[3])
pder=transpose([[ri(f,xp)],[ri(pder1,xp)],[ri(pder2,xp)],$
                [ri(pder3,xp)],[ri(pder4,xp)]])
;stop
return,pder
end
