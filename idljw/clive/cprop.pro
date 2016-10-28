pro cprop, thick, facetilt,crystal=crystal

nth=100
th=linspace(-4*!dtor,4*!dtor,nth)
ang=0
thx=th*cos(ang)
thy=th*sin(ang)
default,crystal,'bbo'
par={crystal:crystal,thickness:thick*1e-3,lambda:656e-9,facetilt:facetilt*!dtor}

opd1=opd(thx,thy,par=par,delta=0)/2/!pi
print,'delay=',opd1(nth/2)
sl=deriv(th*!radeg,opd1)
kay=sl(nth/2)
print,'kay=',kay,'fringes/deg'
end

