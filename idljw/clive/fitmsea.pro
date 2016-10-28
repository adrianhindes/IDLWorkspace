@~/idl/clive/calcfit3_msea
@gencarriers
@newdemod

pro fitmsea,skip=skip
common cb3, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd,thv,ilist0,isubx,isuby,iz2,lam,slist,istat

;sh=1200&lam=659.89e-9*ifr=3

sh=7426 & ifr=84+3&lam=661e-9



;meth='dark'
meth='norm'

img=getimgnew(sh,ifr)*1.022


newdemod, img,cars, nbin=nb,gap=id2,sh=sh,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,demodtype='real3',indexlist=ilist0,lam=lam,ifr=ifr,istat=istat,slist=slist ;,/doplot
print,'done demod'

readpatch,sh,p
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
forward_function calcfit,calcfit2,calcfit3
xpar=[0,0]
;readancal, shf, xpar

xi=identity(2)*0.1

common cbc, ncalls
ncalls=0


dum=calcfit3_msea(xpar,/plot,res1=res1,res2=res2)
stop
ftol=1e-4
powell,xpar, xi, ftol, fmin, 'calcfit3_msea',iter=iter,itmax=100
dum=calcfit3_msea(xpar,/plot,res1=res1,res2=res2)
stop
;writeancal, sh, xpar

res1=interpolate(res1,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)
res2=interpolate(res2,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)
str={res1:res1,res2:res2,sh:sh}
hdfsaveext,getenv('HOME')+'/idl/clive/settings/res'+string(sh,format='(I0)')+'.hdf',str

stop
end

fitmsea;,/skip
end
