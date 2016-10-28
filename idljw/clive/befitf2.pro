@newmakeefitnl
@newcmpmseefit
pro befitf2,sh,tref,twant,norun=norun,inperr=inperr,dogas=dogas,dobeam2=dobeam2,kpp=kpp,kff=kff,runtwice=runtwice,drcm=drcm,invang=invang,rrng=rrng,gfile=gfile,mfile=mfile,lut=lut,field=field,wt=wt,dzcm=dzcm,nz=nz,distback=distback,noplot=noplot,mixfactor=mixfactor,cmpang=cmpang,outgname=outgname,errmixfactor=errmixfactor,profexp=profexp,profsim=profsim,rval1=r1,profinten=profinten,profdop=profdop,proflin=proflin,methavg=methavg
default, lut, sh gt 8000

tarr=tref
ifr=frameoftime(sh,tarr,db='k')&only2=1&demodtype=sh gt 8000 ? 'sm32013mse' : 'basicd'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,lut=lut,lin=lin,inten=inten;,/cacheread,/cachewrite
;ang1b=ang1



tarra=twant
na=n_elements(tarra)
;goto,ee
;for i=0,na-1 do begin
tarr=tarra
;tarr=2.7
ifr=frameoftime(sh,tarr,db='k')&only1=1&only2=0
;
if tarr eq -1 then ang1b=ang1 else    newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2,lut=lut,lin=lin,inten=inten;,/cacheread,/cachewrite
if tarr eq -1 then tarr=tref

if sh lt 8000 then ang1b-=16 else if not keyword_set(lut) then ang1b-=12.8 else ang1b-=1.5

default,field,2
ang1b-= 2 * (field - 3) ; for new cmapign ref is at 3T

if sh lt 8000 then ang1b*=-1



if keyword_set(invang) then ang1b*=-1
default,inperr,0


;if keyword_set(cmpang) then begin
idx=where(finite(ang1b) eq 0)
default,methavg,''

newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=dobeam2,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim,/just,mixfactor=mixfactor,rval=r,zval=z

if methavg eq 'proper' then begin
newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=0,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim1,/just
newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=1,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim2,/just
angsim=angsim1 * (1-mixfactor) + angsim2 * mixfactor
endif

;angsim(idx)=!values.f_nan

sz=size(r,/dim)
iz0=value_locate(z(sz(0)/2,*),0)
r1=r(*,iz0)
z1=z(sz(0)/2,*)
profexp=ang1b(*,iz0)
profsim=angsim(*,iz0)
proflin=lin(*,iz0)
profinten=inten(*,iz0)
profdop=dopc1(*,iz0)


end

