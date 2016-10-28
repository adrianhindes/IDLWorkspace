pro getxy, iter,x,y,fil=fil
path='/raijin/esc/LINUX/test/'
default,fil,'mesh.mtv'
openr,lun,path+fil,/get_lun
istart=-1
nmax=1e4
cnt=0L
x=fltarr(nmax)
y=fltarr(nmax)
while not eof(lun) do begin
   lin=''
   readf,lun,lin
   if lin eq ' x y' then begin
      istart=istart+1
      continue
   endif
   if istart eq iter then begin
      if lin eq ' $DATA=COLUMN' or lin eq '  ' then goto, nowreturn
      pts=float(strsplit(lin,/extract))
      x(cnt)=pts(0)
      y(cnt)=pts(1)
      cnt=cnt+1
   endif

endwhile

nowreturn:
close,lun
free_lun,lun
x=x(0:cnt-1)
y=y(0:cnt-1)


end

;pro getpsigrid, iter, psi, r, z
;getxy,iter,r1,z1;
;
;trigrid,r1,z1
;;
;
;getxy,0,x,y
;getxy,1,x2,y2
;
;end


pro getpsigrid, r1,z1,rho1,rout,zout,rhogrid
triangulate,r1,z1,tri

goto,nn
plot,r1,z1,psym=3,/iso
;stop
;stop
n=n_elements(tri(0,*))
for i=0,n-1 do begin
   tsel=tri([0,1,2,0],i)
   oplot,r1(tsel),z1(tsel)
endfor
stop
nn:
gs=[.01,.01]
default,limits,[0.,-1.5,1.4,1.5]
  rhogrid=trigrid(r1,z1,rho1,tri,gs,limits,xgrid=rout,ygrid=zout,missing=!values.f_nan)
end

pro getb, r,z,psi,br,bz,bp


;if n_elements(g.time) eq 0 then return
;if a.ishot le 0 or g.time le 0 then return
;if g.time le 0 then return
mw=n_elements(r) & mh=n_elements(z)
bp=fltarr(mw,mh) & bt=fltarr(mw,mh) & br=fltarr(mw,mh) & bz=fltarr(mw,mh)
dpsidx = fltarr(mw,mh)
dpsidy = fltarr(mw,mh)

; calculate vertical derivative of psi
for i = 0,mw-1 do begin
 dpsidy[i,*] = Deriv(z[0:mh-1],psi[i,0:mh-1])
endfor

; calculate horizontal derivative of psi
for j = 0,mh-1 do begin
  dpsidx[*,j] = Deriv(r[0:mw-1],psi[0:mw-1,j])
endfor

; calculate array of Br, Bz, and Bp
for j = 0,mh-1 do begin
   br[*,j] = -dpsidy[0:mw-1,j]/r[0:mw-1]
   bz[*,j] = dpsidx[0:mw-1,j]/r[0:mw-1]
endfor
bp = sqrt(br*br+bz*bz)


end

pro getbz, iter,bz1,r=rout,z=zout,psi=psigrid,axr=rax

sz=[129,51]
getxy,iter,r1,z1 & r2=reform(r1,sz(0),sz(1)) & z2=reform(z1,sz(0),sz(1))
getxy,3+iter*5,s,psibar,fil='prof.mtv'
psi2= replicate(1,sz(0)) # psibar 
getpsigrid,r2,z2,psi2,rout,zout,psigrid
getb, rout,zout,psigrid,br,bz,bp
nz=n_elements(zout)
bz1=bz(*,nz/2)
rax=mean(r2(*,0))

end

getbz,0,bz0,r=r,z=z,psi=psi0,axr=rax
getbz,3,bz1,psi=psi1
plot,r,bz0,ysty=8
oplot,r,bz1,col=2
oplot,rax*[1,1],!y.crange,linesty=2,col=3
oplot,!x.crange,[0,0],linesty=2,col=3

plot,r,bz1-bz0,/noer,ysty=4
axis,!x.crange(1),!y.crange(1),yaxis=0
oplot,!x.crange,[0,0],linesty=2
;oplot,rax*[1,1],!y.crange,linesty=2,col=3
stop

contour,psi0,r,z,nl=20
contour,psi1,r,z,nl=20,c_col=replicate(2,20),/noer

end

