diag='\LV23'
y=cgetdata(diag,shot=11433,db='kstar')
y2=cgetdata(diag,shot=11434,db='kstar')
t1=2.25
t2=3.25
plot,y.t-t1,total(y.v,/cum)-total(y.v(0:value_locate(y.t,t1))),xr=[0,2]
oplot,y2.t-t2,total(y2.v,/cum)-total(y2.v(0:value_locate(y2.t,t2))),col=2

end
