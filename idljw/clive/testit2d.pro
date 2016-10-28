@~/idl/clive/calcfit3
@gencarriers
@newdemod

pro testit2d,skip=skip
common cb2, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd,thv,ilist0,isubx,isuby,iz2,lam

shf=1615;05;25

;sh=1625 & lam=659.89e-9
;sh=1624 & lam=653.28824e-9
shr=1626;dark


;meth='dark'
meth='norm'
ifr=0
;sh=1604 & lam=659.89e-9 ; vert cal in kstar
;sh=1605 & lam=659.89e-9 ; horiz cal in kstar
;sh=1610 & lam=659.89e-9 ; vert cal later but with ciruclar because film wrong way round nb this fits v well to 1615

;sh=8054 & lam=661e-9 & ifr=300


sh=1615 & lam=659.89e-9 ; full sphere/line cal

if not keyword_set(skip) then begin
   if meth eq 'dark' then begin
       img=getimgnew(sh,0)*1.0
       for fr=1,15 do img+=getimgnew(sh,fr)*1.0
       img/=16.
       
       imgr=getimgnew(shr,0)*1.0
       for fr=1,15 do imgr+=getimgnew(shr,fr)*1.0
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
       img=getimgnew(sh,ifr)*1.0
   endif
;   stop
;    simimgnew, img, sh=sh & img=img*1.0
   newdemod, img,cars, nbin=nb,gap=id2,sh=sh,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,demodtype='real3',indexlist=ilist0,lam=lam ;,/doplot

   print,'done demod'
   docomp=1
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
;xpar=[0,0,0,0,0,0]
readancal, shf, xpar

xi=identity(6)*0.1

common cbc, ncalls
ncalls=0


dum=calcfit3(xpar,/plot,res1=res1,res2=res2)


stop
ftol=1e-4
powell,xpar, xi, ftol, fmin, 'calcfit3',iter=iter,itmax=100
dum=calcfit3(xpar,/plot,res1=res1,res2=res2)
writeancal, sh, xpar

res1=interpolate(res1,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)
res2=interpolate(res2,interpol(findgen(nx2),isubx,findgen(nx)),interpol(findgen(ny2),isuby,findgen(ny)),/grid)
str={res1:res1,res2:res2,sh:sh}
hdfsaveext,getenv('HOME')+'/idl/clive/settings/res'+string(sh,format='(I0)')+'.hdf',str

stop
end

testit2d;,/skip
end
