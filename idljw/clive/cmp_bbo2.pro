
nl=100
lam=linspace(459e-9,514e-9,nl)
;lam=linspace(200e-9,1200e-9,nl)
cbbo2,lambda=lam,bi=bi,temp=20
plot,lam*1e-9,bi

cbbo2,lambda=lam,bi=bi2,temp=45
oplot,lam*1e-9,bi2,col=2

end
