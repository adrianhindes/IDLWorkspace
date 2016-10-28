;@applycal
;@calcfit
;@gencarriers
;@newdemod

;pro testit2c,skip=skip

;shf=1615;05;25
pro testit2c_wb1, shf, lamp,shbase=shbase

common cb2, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd,thv,ilist0,isubx,isuby,iz2,lam,wta,test1

;shf=9181 & db='cal' ;9181
;shf=9229 & db='cal' ;9181
;shnum=shf

;shf='cxrstest4_tuni_lasertr' & db='k2'
;shnum=88888
wta=[1,1,1,1.]
;shf = 29 & db='wb'  & lam=659.8e-9+0e-9 & demodtype='real4'
;shf = 27 & db='wb' & lam=532.0e-9  & demodtype='real5'
;shf = 31 & db='wb' & lam=532.0e-9  & demodtype='real6' & wta=[1.,0,1,0]

;shf = 51 & db='wb' & lam=487.98e-9  & demodtype='real6' 
;shf = 85 & db='wb' & lam=514.178e-9  & demodtype='real6' 


;shf = 95 & db='wb' & lam=487.98e-9  & demodtype='real6' 
db='wb' & demodtype='real6';4';6' 
test1 = shf ge 83 
lam=lamp

shnum=shf
;sh=1625 & lam=659.89e-9
;sh=1624 & lam=653.28824e-9
;shr=1626;dark


;meth='dark'
meth='norm'
ifr=0
;sh=1604 & lam=659.89e-9 ; vert cal in kstar
;sh=1605 & lam=659.89e-9 ; horiz cal in kstar
;sh=1610 & lam=659.89e-9 ; vert cal later but with ciruclar because film wrong way round nb this fits v well to 1615

;sh=8054 & lam=661e-9 & ifr=300
sh=shf


if not keyword_set(skip) then begin
   if meth eq 'dark' then begin
       img=getimgnew(sh,0)*1.0
       for fr=1,15 do img+=getimgnew(sh,fr,db=db)*1.0
       img/=16.
       
       imgr=getimgnew(shr,0)*1.0
       for fr=1,15 do imgr+=getimgnew(shr,fr,db=db)*1.0
       imgr/=16.
       img0=img
       img=img-imgr
       imgm=median(img,5)
       mn=mean(img)
       std=stdev(img)
       fac=2
       
       idx=where(imgm ge mn + std*fac or imgm le mn-std*fac)
       if idx(0) ne -1 then imgm(idx)=mn
       
       imgdif=(img-imgm)/imgm

;   idx=where(img ge mn + std*fac or img le mn-std*fac)
       idx=where(imgdif ge 2 or imgdif le -2)
       img(idx)=imgm(idx)
   endif
   if meth eq 'norm' then begin
       img=getimgnew(sh,ifr,db=db)*1.0

   endif
;   stop
;    simimgnew, img, sh=sh & img=img*1.0
   newdemod, img,cars, nbin=nb,gap=id2,sh=sh,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,demodtype=demodtype,indexlist=ilist0,lam=lam ,db=db,kx=kx,ky=ky,kz=kz,/doplot

gencarriers2,th=[0,0],sh=sh,db=db,mat=mat,dmat=dmat,kz=kz,lam=lam,kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,/noload,str=str

tt=22.5*!dtor
svec=[1,cos(2*tt),sin(2*tt),0]

amp = reform(abs(dmat ## svec) )
izz=(where(kz eq 0))(0)
amp=amp/amp(izz)

zeta=abs(cars) & for i=1,4 do zeta(*,*,i)/=zeta(*,*,0)/2
wset2,0
pos=posarr(2,2,0)
for i=1,4 do begin
   imgplot,zeta(*,*,i)/amp(i),pos=pos,noer=i gt 1,/cb,zr=[0,1.5],title=string(i,amp(i))
   pos=posarr(/next)
endfor
wset2,1
;   stop

   print,'done demod'
   docomp=0
   if docomp eq 1 then begin
       
       hdfrestoreext,getenv('HOME')+'/idl/clive/settings/res'+string(1615,format='(I0)')+'.hdf',res
       
       jj=[16,22]               ;[28,21]
       for k=0,1 do begin
           j=jj(k)
           r=res.(k)
           ii=(where(ilist0 eq j))(0)
           cars(*,*,ii) = cars(*,*,ii) * exp(complex(0,1)* 2 * !pi * r)
       endfor
   endif

;stop
endif


readpatch,sh,p,db=db
readcell,p.cellno,str

nx=n_elements(thx)
ny=n_elements(thy)

mul=5
nx2=nx/mul
ny2=ny/mul
isubx=indgen(nx2)*mul
isuby=indgen(ny2)*mul
iz2=[value_locate(isubx,iz(0)),value_locate(isuby,iz(1))]
thx2=thx(isubx)
thy2=thy(isuby)

thv=fltarr(nx2,ny2,2)
for i=0,nx2-1 do thv(i,*,0)=thx2(i)
for j=0,ny2-1 do thv(*,j,1)=thy2(j)
forward_function calcfit
xpar=[0,0,0,0.];,0,0];,0,0]

if keyword_set(shbase) then begin
   readancal, shbase, xpar
endif

xi=identity(n_elements(xpar))*0.1

common cbc, ncalls
ncalls=0


dum=calcfit_wb1(xpar,/plot,res1=res1,res2=res2)



;stop
ftol=1e-4
if n_elements(shbase) eq 0 then $
   powell,xpar, xi, ftol, fmin, 'calcfit_wb1',iter=iter,itmax=100
dum=calcfit_wb1(xpar,/plot,res1=res1,res2=res2,res3=res3,res4=res4);,/dostop)


;stop
if n_elements(shbase) eq 0 then writeancal, shnum, xpar

res1=interpolate(res1,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)
res2=interpolate(res2,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)
res3=interpolate(res3,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)
res4=interpolate(res4,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)


str={res1:res1,res2:res2,res3:res3,res4:res4,sh:sh,thx:thx2,thy:thy2,zeta:zeta(*,*,1:4),amp:amp(1:4),inten:zeta(*,*,0)}
hdfsaveext,getenv('HOME')+'/idl/clive/settings/res'+string(shnum,format='(G0)')+'.hdf',str


end

;testit2c;,/skip
;end
