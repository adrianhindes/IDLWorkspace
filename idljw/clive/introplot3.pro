sh=9323
nb=cgetdata('\NB11_I0',sh=sh,db='kstar')
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
ip=cgetdata('\RC01')
lv=cgetdata('\LV23',sh=sh,db='kstar')
;sh=11004
;ec2=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
;ip2=cgetdata('\RC01')
;lv2=cgetdata('\LV23',sh=sh,db='kstar')

nsm=1000
lv.v=smooth(lv.v,nsm)
lv2.v=smooth(lv2.v,nsm)

;if (ex eq 'a' and sh eq 11433) or (sh eq 11434) then ec=cgetdata('\ECH_VFWD1',sh=sh,db='kstar')

mkfig,'~/introplot3.eps',xsize=8,ysize=10,font_size=8
xr=[0,8]
pos=posarr(1,3,0,cny=0.1,cnx=0.1,fx=0.5)
plot,ip.t,-ip.v/100e3,pos=posarr(/curr),xr=xr,xsty=1,title='IP & ECCD',ytitle='kA'
;oplot,ip.t,-ip.v/100e3,col=2
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4,xsty=4+1
;oplot,ec2.t,ec2.v,col=2
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,title='loop voltage',yr=[-.8,-.3],xsty=1,ytitle='V'
;oplot,lv2.t,lv2.v,col=2

common ab,res,t,v
;getece,9323,res,t,v
i=value_locate3(res.r2,1.8)
plot,res.t,res.v(*,i)>0,pos=posarr(/next),/noer,title='ECE Te, R=1.86m, 2.2m',xr=!x.crange,xsty=1,ytitle='eV',xtitle='time (s)'

i=value_locate3(res.r2,2.2)
oplot,res.t,res.v(*,i)>0

;,pos=posarr(/next),/noer,title='ECE, R=2.2m',xr=!x.crange,xsty=1,ytitle='eV',xtitle='time (s)'




;; dt=lv.t(1)-lv.t(0)
;; plot,lv.t,(total(lv.v,/cum) - total(lv.v(0:value_locate(lv.t,2))))*dt,pos=posarr(/next),title='flux consumption',ytitle='(Vs)',/noer,xr=xr,xsty=1,yr=[-2,0],xtitle='time (s)'
;; oplot,lv2.t,(total(lv2.v,/cum)  - total(lv2.v(0:value_locate(lv2.t,2))))*dt,col=2



endfig,/gs,/jp
end

