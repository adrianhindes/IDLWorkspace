diag='\LV23'
y=cgetdata(diag,shot=11003,db='kstar')
y2=cgetdata(diag,shot=11004,db='kstar')

plot,y.t,total(y.v,/cum)-total(y.v(0:value_locate(y.t,2))),xr=[2,6]
oplot,y2.t,total(y2.v,/cum)-total(y2.v(0:value_locate(y2.t,2))),col=2

end
