function posarr2, ny,im,cnx=cnx,cny=cny,ratio=ratior,msrat=msrat
msratx=1000.
default,msrat,1
i=(ny-1)-im

default,ratior,replicate(5,ny)
ratio=reverse(ratior)
rat2=fltarr(ny*2+1)
rat2(0)=msrat
for j=0,ny-1 do rat2(2*j+1)=ratio(j)
for j=0,ny-1 do rat2(2*j+2)=msrat
ratc=total(rat2,/cum)
ratcn=ratc/total(rat2)

ix=0
nx=1
default,cnx,0.05
default,cny,0.05
ox = cnx+ float(ix*msratx)/float(nx*msratx-1) * (1-2*cnx)
wx = 1./nx * (msratx-1)/msratx * (1-2*cnx)


ratcn=ratcn * (1-2*cny) + cny
yp=[ratcn(2*i),ratcn(2*i+1)]
;stop
return, [ox,yp(0),ox+wx,yp(1)]
end

;dum=posarr2(5,0)
;print,dum
;end
