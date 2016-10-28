pro cprop2,db,delay,kay,lambda=lambda,kappa=kappa
default,lambda,529e-9

nth=100
th=linspace(-4*!dtor,4*!dtor,nth)
ang=0
thx=th*cos(ang)
thy=th*sin(ang)

par={crystal:abs(db(0)) eq 1 ? 'bbo' : 'linbo3',thickness:db(0) gt 0 ? db(1)*1e-3 : db(1)*1e-3 / 2,lambda:lambda,facetilt:db(2)*!dtor}

ccrystal,par,dum1,dum2,kappa=kappa
opd1=opd(thx,thy,par=par,delta=0)/2/!pi
delay=opd1(nth/2)
sl=deriv(th*!radeg,opd1)
kay=sl(nth/2)
if db(0) lt 0 then begin
    kay=kay * sqrt(2)
    delay=0
endif

end

