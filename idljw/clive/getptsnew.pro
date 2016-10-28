pro getptsnew,pts=pts,doback=doback,str=str,ix=ix1,iy=iy1,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang,plane=plane,calca=calca,rxs=rxs,rys=rys,distback=distback,dobeam2=dobeam2,detx=detx,dety=dety,pptsonly=ptsonly,lene=lene,nl=nl,nx=nx,ny=ny,leno=leno,d3d30l=d3d30l,d3d30r=d3d30r

;bin=8;0


;sz=[688,520] / bin

;sz=[688,512] / bin

sz=[str.roir - str.roil+1,str.roit-str.roib+1]/[str.binx,str.biny]

if n_elements(ix1) eq 0 or n_elements(iy1) eq 0 then begin
    default,bin,1
    szo=floor((sz/bin))
    nx=szo(0)
    ny=szo(1)

    ix1=indgen(nx)*bin
    iy1=indgen(ny)*bin
endif else begin
    nx=n_elements(ix1);/bin
    ny=n_elements(iy1);/bin

endelse


;    stop
psizx=str.pixsizemm*str.binx
psizy=str.pixsizemm*str.biny



ix=reform(ix1 # replicate(1,ny),nx*ny)
iy=reform(replicate(1,nx) # iy1,nx*ny)
np=nx*ny


getaxnew,xhat,yhat,zhat,p0,doback=doback,str=str.mapstr,flen=flen,distcx=distcx,distcy=distcy,kdist=dist

cdir=fltarr(3,np)
p0p=cdir

rarr=fltarr(np)
zarr=fltarr(np)
parr=fltarr(np)
detx=((ix1-sz(0)*distcx) * psizx)
dety=((iy1-sz(1)*distcy) * psizy)
if keyword_set(d3d30l) or keyword_set(d3d30r) then begin

   if keyword_set(d3d30l) then isource=0
   if keyword_set(d3d30r) then isource=1


   d3dbpars2,isource=isource,us=us,vs=vs,alpha=alpha
endif else begin
   if keyword_set(dobeam2) then isource=1 else isource=0
   kbpars2,isource=isource,us=us,vs=vs,alpha=alpha
endelse
b0=[us,vs,0]
bv=[cos(alpha),sin(alpha),0]

;kbpars2,isource=0,us=us,vs=vs,alpha=alpha
;bv=[cos(alpha),sin(alpha),0]
default,distback,2500.;1000.;cm
bsource=[us,vs,0] - distback * [cos(alpha),sin(alpha),0]


for i=0L,np-1 do begin

    thx=((ix(i)-sz(0)*distcx) * psizx/flen)
    thy=((iy(i)-sz(1)*distcy) * psizy/flen)

;    print,"thx,thy",thx,thy
    thxc=0;((sz(0)*distcx-sz(0)/2) * psiz/flen)
    thyc=0;((sz(1)*distcy-sz(1)/2) * psiz/flen)

    thx=atan(thx-thxc)
    thy=atan(thy-thyc)

;    print,thx*!radeg,thy*!radeg
    thr = sqrt((thx)^2+(thy)^2)
    fac=(1 - dist * thr^2 + 3 * dist^2 * thr^4)
;    print,'fac=',1-fac,i,np
;    stop
    thx = (thx )* fac
    thy = (thy )* fac

    thx=thx+atan(thxc)
    thy=thy+atan(thyc)


    cdir1=zhat + xhat * tan(thx) + yhat * tan(thy)
    cdir1=cdir1/norm(cdir1)
    cdir(*,i)=cdir1
    p0p(*,i)=p0

    if not keyword_set(plane) then begin
       solint,b0,bv,p0,cdir1,coord,dum,dum1,dum2
    endif else begin
       p0_tmp=p0 & p0_tmp[2]=b0[2]
       cdir1_tmp=cdir1 & cdir1_tmp[2]=0. ;& cdir1_tmp /=sqrt(total(cdir1_tmp^2))
       solint,b0,bv,p0_tmp,cdir1_tmp,coord_tmp,dum,dum1,dum2;dum coord on beam,dum1 dist on beam, dum2 dist on los
       coord=coord_tmp
       coord = p0 + cdir1 * dum2
;       stop
    endelse

    rarr(i)=sqrt(coord(0)^2+coord(1)^2)
;    if rarr(i) gt 1.5e4 then stop
    parr(i)=atan(coord(1),coord(0))
    zarr(i)=coord(2)

;    pv=[ -1196.07   ,   918.184   ,  -364.050]/10.

;    tmp=(pv-p0)/cdir1
;    print,tmp/tmp(0)
;    stop

endfor
default,nl,100*3
default,lene,[50,400]
len=linspace(lene(0),lene(1),nl)
dl=(len(1)-len(0) ) * 0.01 ; cm to m
leno=fltarr(np,nl)
pts=fltarr(np,nl,3)
for i=0,np-1 do begin
   leno(i,*)=len
    for j=0,2 do pts(i,*,j)=p0p(j,i) + cdir(j,i) * len
endfor
;stop
;
if keyword_set(ptsonly) then return


ang=fltarr(nx*ny)
for i=0,nx*ny-1 do ang(i)=acos(total(cdir(*,i) * bv))*!radeg
ang=reform(ang,nx,ny)

if not keyword_set(calca) then goto, aftercalca
rxs=fltarr(3,nx*ny)
rys=rxs
for i=0,nx*ny-1 do begin
    C_vec1 = cdir(*,i)
    zhats=C_vec1
    yhats=[0,0,1.]
    xhats=crossp(yhats,zhats)  & xhats/=norm(xhats)
    xhats*=-1
    yhats=crossp(xhats,zhats)


    pint=parr(i)

    rhat=[cos(pint),sin(pint),0]
    zhat=[0,0,1.]
    phat=[-sin(pint) , cos(pint), 0]

    trmat=transpose([[rhat],[phat],[zhat]]);transpose

    cl=[rarr(i)*[cos(parr(i)),sin(parr(i))],zarr(i)]

    vvec=cl - bsource
    vvec=vvec/norm(vvec)
    vx=bv(0) & vy=bv(1) & vz=0
;    vx=vvec(0) & vy=vvec(1) & vz=vvec(2)
    vmat=[$
         [0, -vz, vy],$
         [vz,  0,-vx],$
         [-vy,vx,  0]]

    eresp=vmat ## trmat
;    eresp=transpose(eresp)
    rx=xhats ## eresp
    ry=yhats ## eresp
    rxs(*,i)=rx ; [rad, tor, z]
    rys(*,i)=ry



endfor
rxs=reform(rxs,3,nx,ny)
rys=reform(rys,3,nx,ny)
rxs=transpose(rxs,[1,2,0])
rys=transpose(rys,[1,2,0])



aftercalca:
pts=reform(pts,nx,ny,nl,3)
rarr=reform(rarr,nx,ny)
zarr=reform(zarr,nx,ny)

cdir=reform(cdir,3,nx,ny)
cdir=transpose(cdir,[1,2,0])
;stop
end

;readpatch,7345,str
;getptsnew,rarr=r,zarr=z,str=str,bin=4,ix=ix,iy=iy,pts=pts
;contourn2,r
;end
