;goto,ee
;sh=87793 & dt=0.01/5;tw=[.03,.04]; 250

sh=87845 & dt=0.01;tw=[.03,.04];;;bpp=250ork=4deg max cor, R=237
;sh=87846 & dt=0.01;tw=[.03,.04];;;bpp=250ork=4deg max cor, R=231
;sh=87847 & dt=0.01;tw=[.03,.04];;;bpp=250ork=4deg max cor, R=243
which='old' & dofilt=1
;sh=88533 
;IDL> print,sh(idx)           
;       87843       87844       87845       87846       87847       87848
;       87861
;IDL> print,rad(idx)
;      211.000      225.000      237.000      231.000      243.000      250.000
;      219.000
;IDL> 



;sh=88533 & dt=0.01 & which='new' & dofilt=1


t=linspace(.005,.095,18*2+1) & dt=0.01/4
nt=n_elements(t)
vel=fltarr(nt)
cc=fltarr(nt)
frng=[1e3,100e3] & lmax=50
;frng=[-1,-1] & lmax=150
;frng=[3e3,9e3]
;frng=[50e3,100e3] & lmax=100
;frng=[100e3,200e3]
for i=0,nt-1 do begin
print,i
;doit, sh, tr=t(i)+[-1,1]*dt/2
;stop
tdcorr, sh, t(i)+[-1,1]*dt/2, frng, tlag,maxcc,velocity=velocity,doplot=1,lmax=lmax
dum=0.
vel(i)=tlag
cc(i)=maxcc
print,i,t(i),dum,tlag,maxcc
;stop
endfor
ee:
plot,t,vel,psym=-4,pos=posarr(1,3,0)
oplot,!x.crange,[0,0],linesty=2
plot,t,cc,psym=-4,/noer,col=3,pos=posarr(/next)

dum= getpar( sh, 'isat', tw=[0,.1],y=y)

plot,y.t,y.v>0,/noer,xr=!x.crange,col=2,pos=posarr(/next)


end



