echarge=1.6e-19

c=3e8
;delay=opd(0,0,par={crystal:'linbo3',thickness:40e-3,facetilt:0,lambda:468e-9},kappa=kappa,delta0=0)/2/!pi&amass=1
;delay=opd(0,0,par={crystal:'linbo3',thickness:15e-3,facetilt:0,lambda:468e-9},kappa=kappa,delta0=0)/2/!pi&amass=1
;delay=opd(0,0,par={crystal:'linbo3',thickness:25e-3,facetilt:0,lambda:514e-9},kappa=kappa,delta0=0)/2/!pi&amass=12
;delay=opd(0,0,par={crystal:'linbo3',thickness:35e-3,facetilt:0,lambda:658e-9},kappa=kappa,delta0=0)/2/!pi&amass=12

delay=opd(0,0,par={crystal:'bbo',thickness:4e-3,facetilt:45*!dtor,lambda:529e-9},kappa=kappa,delta0=0,k0=k0)/2/!pi&amass=12
k0/=!radeg ;convert k from fringes per radian to fringes per degree
flencam=135e-3
psizmm=12.8e-3

         kmult= $; fringes/deg
            1/!dtor* $; /rad
            1/(flencam*1e3)* $; per mm on detector
            psizmm; per binned pixel


gdelay=delay*kappa
mi=amass * 1.67e-27


vchar = c  /( !pi * (gdelay))
chart = mi * vchar^2 / 2 / echarge
print,'chart =',chart
print,'delay=',delay
print,'fingex/pix=',k0*kmult
print,'pix/fringe=',1/(k0*kmult)

end

