pro getzeta, sh, zeta1, light1,raw1,iwy=iwy,sim=sim,doplot=doplot,gatedelay=gatedelay

;[-400,400];

default,doplot,0
db='h1tor'
if not keyword_set(sim) then d=getimgnew(sh,0,db=db,info=info,/getinfo) else simimgnew,d,sh=sh,db=db,svec=[1,0,1,0]
gatedelay=info.gatedelay
demodtype='basicrf1n'
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
imgplot,zeta,/cb,pos=posarr(/next),/noer,zr=[0,.2],/iso,xr=xr,yr=yr,xsty=1,ysty=1,offx=1.
;stop
if  n_elements(iwy) ne 0 then begin
   zeta1=zeta;(*,iwy)
;   cursor,dx,dy,/down
   light1=light/mean(light,/nan)
   raw1=d/mean(d,/nan)
   return
endif

plots,dx,dy,psym=4
cursor,dx,dy,/down
print,'dx,dy=',dx,dy
if !mouse.button ne 1 then stop
goto,again

end
;getzeta,85519
;retall
;goto,e2

;85610

nn=8
siz=[1024,1024]
z1=fltarr(siz(0),siz(1),nn)
l1=z1
r1=fltarr(1024,1024,nn)
p1=findgen(8)*!pi/4
;p2=p1+!pi/4
;p=[p1,p2]
p=shift(p1,-2)
idx=sort(p)
p=p(idx)
gd=fltarr(nn)
for i=0,nn-1 do begin
getzeta,(85610+idx(i)),zeta1,light1,raw1,iwy=1,gatedelay=gg& z1(*,*,i)=zeta1 & l1(*,*,i)=light1&r1(*,*,i)=raw1 & gd(i)=gg
endfor
e:
;plotm,z1;,xr=[200,350]
zav=total(z1,3) / nn
z2=z1 
for i=0,nn-1 do z2(*,*,i)-=zav

lav=total(l1,3) / nn
l2=l1 
for i=0,nn-1 do l2(*,*,i)-=lav

rav=total(r1,3) / nn
r2=r1 
for i=0,nn-1 do r2(*,*,i)-=rav



;; z2s=z2
;; kern=fltarr(20,40)+1.
;; kern/=total(kern)
;; for i=0,nn-1 do z2s(*,*,i)=convol(z2(*,*,i),kern)

;; l2s=l2
;; kern=fltarr(20,40)+1.
;; kern/=total(kern)
;; for i=0,nn-1 do l2s(*,*,i)=convol(l2(*,*,i),kern)


sz=complexarr(siz(0),siz(1),nn)
sl=complexarr(siz(0),siz(1),nn)

for i=0,siz(0)-1 do for j=0,siz(1)-1 do begin
   sz(i,j,*)=fft(z1(i,j,*))
   sl(i,j,*)=fft(l1(i,j,*))
endfor

e2:
pos=posarr(2,1,0)
;imgplot,lav,pos=pos,/cb,zr=[0,1]
;contour,lav,pos=posarr(/curr),lev=linspace(0.2,0.6,5),/noer
erase
imgplot,alog10(zav),pos=posarr(/curr),/noer,/cb,zr=[-3,-0.5]
contour,lav,pos=posarr(/curr),lev=linspace(0.2,0.6,5),/noer

sz2=sz(*,*,2)
sz2s=sz2
kern=fltarr(3,3)+1.
kern/=total(kern)
sz2s=convol(sz2,kern)


imgplot,(abs(sz2s)),pos=posarr(/next),/noer,/cb,zr=[0,.01]
stop
contour,lav,pos=posarr(/curr),lev=linspace(0.2,0.6,5),/noer



end

