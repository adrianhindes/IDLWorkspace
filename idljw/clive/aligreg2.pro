function cart2pol, p
return,[sqrt(p(0)^2+p(1)^2),atan(p(1),p(0)),p(2)]
end
function pol2cart,p
return,[p(0) * cos(p(1)),p(0)*sin(p(1)),p(2)]
end


goto,ee
;read_spe,'~/share/greg/Specific 2014 July 15 12_45_10.spe',l,t,d
im1=d(*,*,17)+d(*,*,67)
imgplot,im1,/cb,zr=[0,3000]
;cursor,dx1,dy,/down
;cursor,dx2,dy,/down
;xc=(dx1+dx2)/2.
;ns=512-xc
im2=shift(im1,ns)
imgplot,im2

stop
write_tiff,'~/idl/clive/nleonw/gregview/surv1.tif',im2,/long


ee:

;long time!
;at 352.8 deg.8

;; which is -7.2 deg  which is -7.2 * 3 angle~18 deg down.

;; pfc is ~ 1m, 24cm swing radius
;; goes though 1.08, -0.22
;; windows is up 502.
;; up along 80cm to [1.37,0.52]
;; then out to the about 2mish so another 0.63m
;; so net is about 1.43
;; so origin point is about [1.6,1.1] at 352 deg
;; Specific 2014 July 15 12_45_10.spe
;; sensor is 13.1x13.1

; but, is about 1.51,0.52 with 34 deg as it should be.


;; oint#=       0
;;       0.42283951      0.85485537col=green
;;      0.422723     0.855015col=red
;;       1628.96     -208.469      724.656
;; point#=       1
;;       0.55902778      0.38378099col=green
;;      0.559946     0.383520col=red
;;       1384.84     -125.908      402.802
;; point#=       2
;;       0.60416667      0.85278926col=green
;;      0.604683     0.853689col=red
;;       1637.05     -109.500      712.832
p1=[      1628.96  ,   -208.469  ,    724.656]
p2=[      1384.84 ,    -125.908  ,    402.802]
p3=[      1637.05,     -109.500 ,     712.832]

pc=(p1+p2)/2.
vec1=p2-p1
vec2=p3-p1

kay=crossp(vec1,vec2) & kay/=norm(kay)
;kay=-kay
print,pc,kay
print,cart2pol(pc)*[1,!radeg,1]
print,atan(-kay(2)/sqrt(kay(0)^2+kay(1)^2))*!radeg - 90.


path2='~/idl/clive/nleonw/gregali/'
restore,file=path2+'irsetn2.sav',/verb & view=str

og_p=[view.rad,view.tor,view.hei]*[1000,1,1000]
og=pol2cart(og_p)
print,og
v=og-pc
;print,total(v*kay)
v2 = v - 2*total(v*kay) * kay
ogr=pc+v2
print,ogr
ogr_p=cart2pol(ogr)*[1e-3,!radeg,1e-3]
print,ogr_p
end
