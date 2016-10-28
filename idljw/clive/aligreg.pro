function cart2pol, p
return,[sqrt(p(0)^2+p(1)^2),atan(p(1),p(0)),p(2)]
end
function pol2cart,p
return,[p(0) * cos(p(1)),p(0)*sin(p(1)),p(2)]
end


goto,ee
f='~/share/alex/2014_06_17_Puffer/ebeam 2014 June 17 17_47_07.spe'
read_spe,f,l,t,d
lread_spe,'~/share/greg/Specific 2014 July 15 12_45_10.spe',l,t,d
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

;; from "my" model the mirror endpoints define as:
;;    1686.17     -278.716      631.557
;; point#=      13
;;       0.57407407      0.33608815col=green
;;      0.575063     0.336851col=red
;;       1377.65     -138.945      396.443
;; point#=      14
;;       0.41769547      0.32644628col=green
;;      0.419342     0.326537col=red
;;       1365.11     -238.157      396.443
;; midp of 1st and 2nd is cenre of mirror

p1=[  1686.17,     -278.716,      631.557]
p2=[      1377.65  ,   -138.945,      396.443]
p3=[      1365.11  ,   -238.157 ,     396.443]
pc=(p1+p2)/2.
vec1=p2-p1
vec2=p3-p1

kay=crossp(vec1,vec2) & kay/=norm(kay)

print,pc,kay
print,cart2pol(pc)*[1,!radeg,1]
print,atan(kay(2)/sqrt(kay(0)^2+kay(1)^2))*!radeg - 90.


end
