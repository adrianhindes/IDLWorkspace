pro calccorr,par=par,corr=corr,sz=sz

awx=par.w2
nx=sz(0)
ny=sz(1)
x1=linspace(-awx/2,awx/2,nx)
awy=awx * ny/nx
y1=linspace(-awy/2,awy/2,ny)
x2=x1 # replicate(1,ny)
y2=replicate(1,nx) # y1
f2=50e-3 
lambda=656e-9

thx=x2/par.f2
thy=y2/par.f2

ppar={crystal:'bbo',thickness:5e-3,lambda:656e-9,facetilt:45*!dtor}

ccrystal,ppar,n_e,n_o

corr=2*thy / sqrt(n_e*n_o)
end



