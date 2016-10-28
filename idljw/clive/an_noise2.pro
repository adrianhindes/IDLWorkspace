sh=40
;read_spe,'~/pll2/test'+string(sh,format='(I0)')+'.SPE',l,t,d&imgplot,d(*,*,0),/cb,title=sh

;read_spe,'~/pll2/background 03-06-2014.SPE',l,t,db&imgplot,db(*,*,0),/cb,title=sh

read_spe,'~/pll2/calibration1 03-06-2014.SPE',l,t,d&imgplot,d(*,*,0),/cb,title=sh
read_spe,'~/pll2/calibration2 03-06-2014.SPE',l,t,db&imgplot,db(*,*,0),/cb,title=sh

read_spe,'~/pll2/white 04-06-2014.SPE',l,t,dw&imgplot,dw(*,*,0),/cb,title=sh
read_spe,'~/pll2/whitebg 04-06-2014.SPE',l,t,dwb&imgplot,dwb(*,*,0),/cb,title=sh


read_spe,'~/pll2/white_camera 04-06-2014.SPE',l,t,dwc&imgplot,dw(*,*,0),/cb,title=sh
read_spe,'~/pll2/white_camerabg 04-06-2014.SPE',l,t,dwcb&imgplot,dwb(*,*,0),/cb,title=sh
dw=dw*1.0
dwb=dwb*1.0
dw2=dw-dwb
dw2=dw2/max(dw2)

dwc=dwc*1.0
dwcb=dwcb*1.0
dwc2=dwc-dwcb
dwc2=dwc2/max(dwc2)

ix=[240,280]
;ix=[260,280]
iy=[300,310]
;iy=[0,511]


d=d*1.0
db=db*1.0
d=d-db
;d=d/dw2
n=iy(1)-iy(0)
wset2,0
plotm,d(ix(0):ix(1),iy(0):iy(1))

wset2,1

plotm,dw2(ix(0):ix(1),iy(0):iy(1)),offy=0.05,yr=[.65,1.3]
ddiv=d/dw2
wset2,2

plotm,dwc2(ix(0):ix(1),iy(0):iy(1)),offy=0.05,yr=[.65,1.3]

ddiv2=dw2/dwc2

wset,3
plotm,ddiv2(ix(0):ix(1),iy(0):iy(1)),offy=0.05,yr=[0.8,1.5]



stop
wset2,4
plotm,ddiv(ix(0):ix(1),iy(0):iy(1))

stop
wset2,5
st2=fltarr(n,2)
mn=fltarr(n,2)
for i=0,n-1 do begin
st2(i,0)=stdev(d(ix(0):ix(1),iy(0)+i))^2
mn(i,0)=mean(d(ix(0):ix(1),iy(0)+i))
st2(i,1)=stdev(ddiv(ix(0):ix(1),iy(0)+i))^2
mn(i,1)=mean(ddiv(ix(0):ix(1),iy(0)+i))

endfor

plot,mn(*,0),(st2(*,0)),psym=4,yr=[0,max(st2)];,yr=[0,5e4]
oplot,mn(*,0),st2(*,1),psym=4,col=4
;plot,mn,st2,yr=[0,1e3],psym=4,xr=[0,500]


oplot,mn, mn*350/220,col=2
end
