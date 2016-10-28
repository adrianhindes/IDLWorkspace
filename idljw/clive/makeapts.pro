pro cvt_cart, p, c
c=p
c(0,*,*)=p(0,*,*) * cos(p(2,*,*)*!dtor)
c(1,*,*)=p(0,*,*) * sin(p(2,*,*)*!dtor)
c(2,*,*)=p(1,*,*)
end


dir='~/idl/clive/nleonw/ad3d'

;    The red dot is r=1010mm, z = 0, phi=3.75deg (z increases going up the image;, phi increases going left)
;    Each full tile is 7.5 deg wide
;    Each tile is 138mm tall
;    From this we have ~8x5 coordinates for registration.
;0 to 9 left
; 4 up, 2 down
dz=138
dth=7.5
p0=[1010,0,90-3.75]
nrx=intspace(-9,0)
nry=intspace(-2,4)
nx=9
ny=6
ntil=nx*ny
nseg=ntil*4


lns=fltarr(3,2,nseg)
cnt=0
for i=0,nx-1 do for j=0,ny-1 do begin
cnp=p0 + [0,nry(j)*dz, nrx(i) * dth]
for seg=0,3 do begin
if seg eq 0 then begin&x0=0&x1=1&y0=0&y1=0&end
if seg eq 1 then begin&x0=1&x1=1&y0=0&y1=1&end
if seg eq 2 then begin&x0=1&x1=0&y0=1&y1=1&end
if seg eq 3 then begin&x0=0&x1=0&y0=1&y1=0&end
lns(*,0,cnt)=cnp + [0,0,dth]*x0 + [0,dz,0]*y0
lns(*,1,cnt)=cnp + [0,0,dth]*x1 + [0,dz,0]*y1
cnt++
endfor

endfor

lnsp=lns

cvt_cart,lnsp,lns
;plot,lnsp(2,*,*),lnsp(1,*,*)
plot,lns(0,*,*),lns(2,*,*)

;lns=lns*1e-3 ; mm to m

save,lns,file=dir+'/'+'d3dtiles.sav',/verb





end

