
pro getdxdy, kxt, kyt,dx,dy,rot=rot,frac=frac

default,frac,0.1
default,rot,0.
trot=rot
kx = kxt * cos(trot) + kyt * sin(trot)
ky = -kxt * sin(trot) + kyt * cos(trot)

;plot,kxt,kyt,psym=4,/iso,xr=[-10,10]*1.5,yr=[-10,10]*1.5
;oplot,kx,ky,psym=5,col=2
;stop

n=n_elements(kx)
dxa=fltarr(n,n)
dya=dxa
maxx=10000.
thres = frac * max([kx,ky])

for i=0,n-1 do for j=0,n-1 do begin
    dxa(i,j)=abs(kx(i)-kx(j))
    dya(i,j)=abs(ky(i)-ky(j))
    if dxa(i,j) lt 1e-5 then dxa(i,j)=maxx
    if dya(i,j) lt 1e-5 then dya(i,j)=maxx
endfor
idx=where(dxa lt thres) & if idx(0) ne -1 then dxa(idx)=9e9
idx=where(dya lt thres) & if idx(0) ne -1 then dya(idx)=9e9
dx=min(dxa)
dy=min(dya)

;;; override for 2015!
;diff=abs(kx(0))
;dx=diff
;dy=diff


end
