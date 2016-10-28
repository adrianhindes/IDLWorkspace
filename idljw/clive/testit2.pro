@calcfit
@gencarriers
@newdemod

pro testit2,skip=skip


sh=1625;15
lam=659.89e-9*0.98

common cb2, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd,thv,ilist0
if not keyword_set(skip) then begin
    img=getimgnew(sh)*1.0
;    simimgnew, img, sh=sh & img=img*1.0
    newdemod, img,cars, nbin=nb,gap=id2,sh=sh,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,demodtype='real',indexlist=ilist0
print,'done demod'
endif


readpatch,sh,p
readcell,p.cellno,str

nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
for i=0,nx-1 do thv(i,*,0)=thx(i)
for j=0,ny-1 do thv(*,j,1)=thy(j)
forward_function calcfit
xpar=[0,0,0,0,0,0]
xi=identity(6)*0.1
dum=calcfit(xpar)
ftol=1e-4
powell,xpar, xi, ftol, fmin, 'calcfit',iter=iter,itmax=1000


stop
end

testit2;,/skip
end
