sh=85629
;[-400,400];

doplot=1
db='h1tor'
if not keyword_set(sim) then d=getimgnew(sh,0,db=db) else simimgnew,d,sh=sh,db=db,svec=[1,0,1,0]


read_spe,'/alex/background.spe',l,t,d0 & d0=d0*1.

d=d*1.
d=d-d0

;stop
demodtype='basicrf2'
newdemod,d,cars,doplot=doplot,db=db,sh=sh,demodtype=demodtype
if doplot eq 1 then stop
zeta=abs(cars(*,*,1))/abs(cars(*,*,0))*2
light=abs(cars(*,*,0))
dx=0
dy=0
again:
;xr=560+[-100,100]
;yr=614+[-100,100]
imgplot,d,/cb,pos=posarr(2,1,0),title=string(sh),/iso,xr=xr,yr=yr,xsty=1,ysty=1
plots,dx,dy,psym=4
imgplot,alog10(zeta),/cb,pos=posarr(/next),/noer,zr=[-2,0],/iso,xr=xr,yr=yr,xsty=1,ysty=1,offx=1.


end
