
nl=100
lam=linspace(459e-9,514e-9,nl)
;lam=linspace(200e-9,1200e-9,nl)
cbbo,n_e=n_e1,n_o=n_o1,lambda=lam
b1=n_e1-n_o1
cbbo2,n_e=n_e2,n_o=n_o2,lambda=lam,dn_edt=dn_edt,dn_odt=dn_odt,bi=bi
b2=n_e2-n_o2

plot,lam*1e-9,n_e1,yr=[1.55,1.7],ysty=1
oplot,lam*1e-9,n_e2,col=2
oplot,lam*1e-9,n_o1,col=1,linesty=2
oplot,lam*1e-9,n_o2,col=2,linesty=2

;plot,2*n_e2*dn_edt,yr=[-100,0]
;oplot,2*n_o2*dn_odt
end
