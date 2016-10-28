sh=11433
nb=cgetdata('\NB11_I0',sh=sh,db='kstar')
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
ec110=cgetdata('\ECH_VFWD1',sh=sh,db='kstar')
ip=cgetdata('\RC01')
lv=cgetdata('\LV23',sh=sh,db='kstar')
;sh=11004
;ec2=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
;ip2=cgetdata('\RC01')
;lv2=cgetdata('\LV23',sh=sh,db='kstar')

nsm=1000
lv.v=smooth(lv.v,nsm)
;lv2.v=smooth(lv2.v,nsm)

;if (ex eq 'a' and sh eq 11433) or (sh eq 11434) then ec=cgetdata('\ECH_VFWD1',sh=sh,db='kstar')

mkfig,'~/introplot2.eps',xsize=10,ysize=18,font_size=8
xr=[0,9]
pos=posarr(1,4,0,cny=0.1,cnx=0.1,fx=0.5)
plot,ip.t,-ip.v/100e3,pos=posarr(/curr),xr=xr,xsty=1,title='IP & ECCD & ECH',ytitle='kA'
;oplot,ip.t,-ip.v/100e3,col=2
plot,ec.t,ec.v,xr=!x.crange,pos=posarr(/curr),/noer,ysty=4,xsty=4+1
oplot,ec110.t,ec110.v,linesty=3,col=2
;oplot,ec2.t,ec2.v,col=2
plot,lv.t,lv.v,xr=!x.crange,pos=posarr(/next),/noer,title='loop voltage',yr=[-1,0],xsty=1,ytitle='V'
;oplot,lv2.t,lv2.v,col=2

common ab,res,t,v
;getece,sh,res,t,v
i=value_locate3(res.r2,1.8)
plot,res.t,res.v(*,i)>0,pos=posarr(/next),/noer,title='ECE, R=1.8m',xr=!x.crange,xsty=1,ytitle='eV'

;i=value_locate3(res.r2,2.2)
;plot,res.t,res.v(*,i)>0,pos=posarr(/next),/noer,title='ECE, R=2.2m',xr=!x.crange,xsty=1,ytitle='eV',xtitle='time (s)'

;common ab2,res2,t2,v2
;;getece,11004,res2,t2,v2
;i=value_locate3(res2.r2,2.2)
;oplot,res2.t,res2.v(*,i)>0,col=2

;legend,['co (B=2.85T)','cntr (B=3.15T)'],textcol=[1,2],charsize=1.5,box=0



;; dt=lv.t(1)-lv.t(0)
;; plot,lv.t,(total(lv.v,/cum) - total(lv.v(0:value_locate(lv.t,2))))*dt,pos=posarr(/next),title='flux consumption',ytitle='(Vs)',/noer,xr=xr,xsty=1,yr=[-2,0],xtitle='time (s)'
;; oplot,lv2.t,(total(lv2.v,/cum)  - total(lv2.v(0:value_locate(lv2.t,2))))*dt,col=2



endfig,/gs,/jp
end

