pro newscan, rho, qty,par=par
rad=[280,260,240,300,290]
idx=sort(rad)
rad=rad(idx)
sh=89300+[86,88,89,90,91]
sh=sh(idx)


th=replicate(2.6,n_elements(rad))
r=rad*0
z=r
n=n_elements(rad)
for i=0,n-1 do begin
   fppos3,rad(i)-10,th(i),rdum,zdum
   r(i)=rdum & z(i)=zdum
endfor
loaddata
mb_cart2flux, r*1e-3,z*1e-3,rho,eta,phi=7.2*!dtor & rho=sqrt(rho)


qty=fltarr(n)
for i=0,n-1 do begin
   qty(i)=getpar(sh(i),par+'fork',tw=[0.01,0.02])
endfor

;plot,rho,qty,psym=-1



end


pro newscan2, rho, qty,par=par
zed=[0, 30, 60, 90, 105.]
ang=60. & 


rval=804.*replicate(1,n_elements(zed))

r = rval

z = (1000 + 710 + 500 + 45 + zed - 20.) - 2180
loaddata
mb_cart2flux, r*1e-3,z*1e-3,rho,eta,phi=60*!dtor & rho=sqrt(rho)
print,rho

stop

sh=[81,83,84,85,86]+89300L
n=n_elements(sh)
qty=fltarr(n)
for i=0,n-1 do begin
   qty(i)=getpar(sh(i),par,tw=[0.01,0.02])
endfor

;plot,rho,qty,psym=-1





;; 

end


newscan,rr1,zz1,par='vfloat'
newscan2,rr2,zz2,par='vfloat'
plot,rr1,zz1,pos=posarr(2,1,0),psym=-4
oplot,rr2,zz2,col=2,psym=-4


newscan,rr1,zz1,par='isat'
newscan2,rr2,zz2,par='isat'
plot,rr1,zz1,pos=posarr(/next),psym=-4,/noer
oplot,rr2,zz2/3,col=2,psym=-4

stop


end

