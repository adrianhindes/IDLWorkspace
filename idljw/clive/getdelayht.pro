
d1=opd(0,0,par={crystal:'linbo3',facetilt:0*!dtor,thickness:20e-3,lambda:658e-9},delta=0,kappa=kappa)/2/!pi & d1*=kappa
d2=opd(0,0,par={crystal:'bbo',facetilt:0*!dtor,thickness:1e-3,lambda:658e-9},delta=0,kappa=kappa)/2/!pi & d2*=kappa
d3=opd(0,0,par={crystal:'bbo',facetilt:45*!dtor,thickness:5e-3,lambda:658e-9},delta=0,kappa=kappa)/2/!pi & d3*=kappa


d1b=opd(0,0,par={crystal:'linbo3',facetilt:0*!dtor,thickness:7.5e-3,lambda:658e-9},delta=0,kappa=kappa)/2/!pi & d1b*=kappa

d3b=opd(0,0,par={crystal:'bbo',facetilt:45*!dtor,thickness:5e-3,lambda:658e-9},delta=0,kappa=kappa)/2/!pi & d3b*=kappa

delay1ht=d1+d2+d3
delay2ht=d1b+d3b
print,d1,d2,d3,d1+d2+d3
print,d1b,d3b,d1b+d3b

