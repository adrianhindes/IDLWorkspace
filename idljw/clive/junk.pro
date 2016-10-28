;par1={crystal:'linbo3',thickness:0.6e-3,lambda:529e-9,facetilt:0*!dtor}
par1={crystal:'linbo3',thickness:1e-3,lambda:529e-9,facetilt:45*!dtor}
;par1={crystal:'linbo3',thickness:0.6e-3,lambda:529e-9,facetilt:0*!dtor}



par2={crystal:'bbo',thickness:6e-3,lambda:529e-9,facetilt:45*!dtor}


t=3
d1=opd(0,0,par=create_struct(par1,'temperature',0))
d1t=opd(0,0,par=create_struct(par1,'temperature',t))

d2=opd(0,0,par=create_struct(par2,'temperature',0))
d2t=opd(0,0,par=create_struct(par2,'temperature',t))

c1=d1t-d1
c2=d2t-d2

print,c1
print,c2
print,c1+c2


end
