;; outside of centrl ring condu170 +/-

;midle would be 170-58=112
;; furthest inbound side of puffer 563

;; (inside of tube)

;; bellows sitting on top of mirnov poloidal (aka closes to plasma side of helical) 220m ~ 5mm accuracy

;; 973 inside edge of flange

;; #2

;; #5 ruler in, but not well focussed?

;; before adjusting focus "m" is on blue mark

;; front lens was on f/4 now on f/22

;; lens on spectometer was on f/2.8 

;; surv 10
;; mark is outside 500

;; back to f/4


;; 131 pfc


;; surv (before 23)-- and the raw one
;; 2 paper bent over
;; ring 152
;; surv 23

;; 1: 190 to 225
;; 2: 350 width 20
;; 3: 440 to 460
;; 4: 513 to 546 in centre

fil='/prl96lf/surv  21.spe'   
read_spe,fil,l,t,d ;& imgplot,d

xx=500
xx=391
profile=d(xx,*)
plot,profile,pos=posarr(2,1,0)

dd=[$
  [0,    0],$
  [190,  0],$
  [190,  1],$
  [225,  1],$
  [225,  0],$
  [350-10,  0],$
  [350-10,  1],$
  [350+10,  1],$
  [350+10,  0],$
  [440,     0],$
  [440,     1],$
  [460,     1],$
  [460,     0],$
  [513,     0],$
  [513,     1],$
  [546,     1],$
  [546,     0]]

x=dd(0,*)
y=dd(1,*)

;x0=152-58. ; outside of pfc
x0=131-58. ; outside of pfc

x2=(x-x0) * 1e-3 + 1

;plot,x2,y,psym=-4


readpatch,99996,db='greg',str,nfr=1;9998
str.biny=1
;str.mapstr[9]+=0.8 ; 2 deg yaw down
;str.mapstr[4]*=1.07 ; mm efl
;str.mapstr[4]*=0.95 ; mm efl



;str.mapstr[9]+=4. ; 2 deg yaw down
str.mapstr[4]*=1.05 ; mm efl
;str.mapstr[5]+=0.08 ; R pos of head
getptsnew,pts=pts,str=str,bin=1,/pptsonly,lene=[0,200.],nl=201,nx=nx,ny=ny,ix=ix1,iy=iy1,detx=detx,dety=dety
pts*=0.01 ; cm to m
dl = 0.01 ; 1cm dl
;stop
;plot,xax3,yax3,xr=[-2,2],yr=[-2,2],/iso
;oplot,pts(*,*,0),pts(*,*,1),col=2
;oplot,xax3,yax3

;for i=0,nphi-1 do oplot,rout*cos(phiarr(i)),rout*sin(phiarr(i)),col=3

ptsc=pts*0
ptsc(*,*,0)=sqrt(pts(*,*,0)^2+pts(*,*,1)^2)
ptsc(*,*,1)=atan(pts(*,*,1),pts(*,*,0))
ptsc(*,*,2)=pts(*,*,2) ;r,phi,z

triangulate,ptsc(*,*,0),ptsc(*,*,2),tri
zed=(findgen(1024)) # replicate(1,201)
res0=trigrid(ptsc(*,*,0),ptsc(*,*,2),zed/cos(6.*!dtor),tri,xout=reform(x2),yout=.05+[0,.01])
res=res0(*,0)

oplot,res,y*!y.crange(1),col=2



fil='/prl96lf/surv  1.spe'   
read_spe,fil,l,t,d ;& imgplot,d

xx=420
profile=reform(d(xx,*,0))
;profile=reverse(profile)
plot,profile,pos=posarr(/next),/noer

dd=[$
  [0,    0],$
  [520,     0],$
  [520,     1],$
  [525,     1],$
  [525,  0]]

x=dd(0,*)
y=dd(1,*)

x0=78.

x2=(x-x0) * 1e-3 + 1

res0=trigrid(ptsc(*,*,0),ptsc(*,*,2),zed,tri,xout=reform(x2),yout=-0.05+[0,.01])
res=res0(*,0)

oplot,res,y*!y.crange(1),col=2

end


