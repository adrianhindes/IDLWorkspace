pro exp_fit,v,fit_params,i
i = fit_params(0) * (1-exp( (v-fit_params(1))/fit_params(2)))
end


n=201
v=linspace(-30,30,n)

par=[-0.02,0,10.]
exp_fit,v,par,i 

plot,v,i


t=findgen(256)/256. 
vt = 20. * cos(2*!pi*t)

dt=t(1)-t(0)
exp_fit,vt,par,it
iav=total(it) * dt
;plot,vt
;plot,it,/noer,col=2
oplot,vt,it,thick=3,col=2
oplot,!x.crange,iav*[1,1],col=3
oplot,!x.crange,[0,0]


end
