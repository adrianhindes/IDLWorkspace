par={thickness:2e-3, facetilt:0.05*45.*!dtor, crystal:'linbo3',lambda:656e-9}

nx=31
ny=31

thx1=linspace(-5*!dtor,5*!dtor,nx)/2
thy1=linspace(-5*!dtor,5*!dtor,ny)/2
thx2=thx1 # replicate(1,ny)
thy2=replicate(1,nx) # thy1

d=opd(thx2,thy2,par=par,delta0=0)/2/!pi

imgplot,d,thx1,thy1,/iso,/cb
;oplot,thx1,thy1,col=2
;cursor,dx1,dy1,/down
;print,dy1/dx1
;;cursor,dx2,dy2,/down
;;print,dy2/dx2

plot,thx1*!radeg,d(*,ny/2)-d(nx/2,ny/2)
ccrystal,par,n_e,n_o

print,n_e-n_o,n_e,n_o

par.crystal='bbo'
ccrystal,par,n_e,n_o
print,n_e-n_o,n_e,n_o


end

