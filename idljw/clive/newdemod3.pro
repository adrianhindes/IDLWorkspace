
function Power, a, p
return, a^p
end

function fourwp, r,d,k,kvecxyz=kvecxyz
Pi=!pi


mat0=$
[[$
Sqrt(2*Pi),$
0,$
0,$
0],$
[$
0,$
Sqrt(2*Pi)*Power(Cos(2*r),2),$
Sqrt(Pi/2.)*Sin(4*r),$
0],$
[$
0,$
Sqrt(Pi/2.)*Sin(4*r),$
Sqrt(2*Pi)*Power(Sin(2*r),2),$
0],$
[$
0,$
0,$
0,$
0]]
matp=[$
[$
0,$
0,$
0,$
0],$
[$
0,$
Sqrt(Pi/2.)*Power(Sin(2*r),2),$
-(Sqrt(Pi/2.)*Sin(4*r))/2.,$
Complex(0,1)*Sqrt(2*Pi)*Cos(r)*Sin(r)],$
[$
0,$
-(Sqrt(Pi/2.)*Sin(4*r))/2.,$
Sqrt(Pi/2.)*Power(Cos(2*r),2),$
Complex(0,-1)*Sqrt(Pi/2.)*Cos(2*r)],$
[$
0,$
Complex(0,-1)*Sqrt(2*Pi)*Cos(r)*Sin(r),$
Complex(0,1)*Sqrt(Pi/2.)*Cos(2*r),$
Sqrt(Pi/2.)]]

matn=conj(matp)


kvec=[0,1,-1]*k
kvecx=kvec * cos(r)
kvecy=kvec * sin(r)
kvecz=[0,1,-1]*d
kvecxyz=transpose([[kvecx],[kvecy],[kvecz]])
tens=complexarr(4,4,3)
tens(*,*,0)=mat0
tens(*,*,1)=matp
tens(*,*,2)=matn
return,tens
end


function tcontract,tens1,tens2
sz1=size(tens1,/dim) ; 4x4;n
sz2=size(tens2,/dim) ; 4x4;m .e.g. 3
n1=sz1(2)
n2=sz2(2)
n=n1*n2
szout=sz1 & szout(2)=n
tout=complexarr(szout)
for i=0,3 do for j=0,3 do for k1=0,n1-1 do for k2=0,n2-1 do begin
    tout(i,j,k1*n2 + k2)=total(tens1(i,*,k1)*tens2(*,j,k2))
endfor
return,tout
end

function kouter,kay1,kay2
sz1=size(kay1,/dim)
sz2=size(kay2,/dim)
n1=sz1(1)
n2=sz2(1)
n=n1*n2
szout=sz1 & szout(1)=n
kout=fltarr(szout)
for i=0,2 do for k1=0,n1-1 do for k2=0,n2-1 do begin
    kout(i,k1*n2+k2)=kay1(i,k1)+kay2(i,k2)
endfor

return,kout
end


function leftmult,tensmat,regmat
sz1=size(tensmat,/dim) 
sz2=size(regmat,/dim) 
nd2=n_elements(sz1)
n1=sz1(2)
szout=sz1
tensmult=tensmat*0

for i=0,3 do for j=0,3 do for k1=0,n1-1 do $
    tensmult(i,j,k1)=total(regmat(*,i) * tensmat(j,*,k1))

return,tensmult
end
function rightmultmatrix,tensmat,regmat
sz1=size(tensmat,/dim) 
sz2=size(regmat,/dim) 
nd2=n_elements(sz1)
n1=sz1(2)
szout=sz1
tensmult=tensmat*0

for i=0,3 do for j=0,3 do for k1=0,n1-1 do $
    tensmult(i,j,k1)=total(regmat(i,*) * tensmat(*,j,k1))

return,tensmult
end


function rightmult,tensmat,vec
sz1=size(tensmat,/dim) 
sz2=size(vec,/dim) 
n1=sz1(2)
szout=sz1
tensmult=complexarr([4,sz1(2)])

for i=0,3 do for k1=0,n1-1 do $
    tensmult(i,k1)=total(tensmat(i,*,k1) * vec)
return,tensmult
end

function matrot, r
mat=[$
[1.,0,0,0],$
[0,cos(2*r),sin(2*r),0],$
[0,-sin(2*r),cos(2*r),0],$
[0,0,0,1.]]
return,mat
end


function matpol, r
matpol=$
[[$
0.5,$
Cos(2*r)/2.,$
Sin(2*r)/2.,$
0],$
[$
Cos(2*r)/2.,$
Power(Cos(2*r),2)/2.,$
(Cos(2*r)*Sin(2*r))/2.,$
0],$
[$
Sin(2*r)/2.,$
(Cos(2*r)*Sin(2*r))/2.,$
Power(Sin(2*r),2)/2.,$
0],$
[$
0,$
0,$
0,$
0]]
return,matpol
end


pro getdxdy, kxt, kyt,dx,dy,rot=rot
default,rot,0.

kx = kxt * cos(rot) + kyt * sin(rot)
ky =-kyt * sin(rot) + kyt * cos(rot)

n=n_elements(kx)
dxa=fltarr(n,n)
dya=dxa
maxx=10000.
for i=0,n-1 do for j=0,n-1 do begin
    dxa(i,j)=abs(kx(i)-kx(j))
    dya(i,j)=abs(ky(i)-ky(j))
    if dxa(i,j) lt 1e-5 then dxa(i,j)=maxx
    if dya(i,j) lt 1e-5 then dya(i,j)=maxx
endfor
dx=min(dxa)
dy=min(dya)
end





pro gencarriers,th=th,sh=sh,mat=mat,kx=kxlist,ky=kylist,kz=kzavlist,tkz=kzlist,nkz=nkz,dkx=dkx,dky=dky,quiet=quiet,p=p,str=str,noload=noload,toutlist=toutlist,vth=thv,indexlist=indexlist,kzv

lam=656.2e-9 
if not keyword_set(noload) then readpatch,sh,p
if not keyword_set(noload) then readcell,p.cellno,str

if not keyword_set(quiet) then print,p.cellno

tn=tag_names(str)
i0=value_locate(tn,'WP1')
nstates=1
for i=0,4 do begin
    if str.(i0+i).type eq 'flc' then nstates=nstates*2
endfor

stat=transpose([[0,0,1,1],[0,1,0,1]])

;th=[3,3.]*!dtor
;th=[3.,0.]*!dtor
;th=[0.,0.]
for state=0,nstates-1 do begin

    szv=size(thv,/dim)
    if n_elements(thv) ne 0 then opdv=fltarr(szv(0),szv(1),5)
    cnt=0
    for i=0,4 do begin
        tmp=str.(i0+i)
        tmp.angle+=str.mountangle - p.camangle
        if tmp.type eq 'wp' then begin
            par={crystal:tmp.material,thickness:tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:tmp.angle*!dtor}
            opd=opd(th(0),th(1),par=par,delta0=par.delta0,k0=k,kappa=kappat)/2/!pi & k/=!radeg ;& if not keyword_set(dbef) then opd = opd * (1-del*kappat)

                if n_elements(thv) ne 0 then opdv(*,*,cnt)=opd(thv(*,*,0),thv(*,*,1),par=par,delta0=par.delta0)/2/!pi


            cnt=cnt+1
;            part=par & part.lambda=part.lambda*(1+del)
;            opdt=opd(th(0),th(1),par=part,delta0=par.delta0)/2/!pi
            if i eq 0 then opd=0.25

            if not keyword_set(quiet) then print,'thicknessmm=',tmp.thicknessmm,'facetilt:',tmp.facetilt,'opd=',opd,'k=',k,'angle=',par.delta0*!radeg

            if opd gt 100 then kappa=kappat

;            if not keyword_set(quiet) then print,opd/opdt, 1+kappat*del


        endif
        if tmp.type eq 'flc' then begin
            opd=tmp.delaydeg/360
            s=stat(tmp.sourceid,state)*2. - 1.
            par={delta0:(tmp.angle + s * tmp.switchangle/2)*!dtor}
            k=0.
            if not keyword_set(quiet) then print,'flc ','angle',par.delta0*!radeg,'retardance',tmp.delaydeg
        endif
        if tmp.type eq 'flc' or tmp.type eq 'wp' then begin
            tens=fourwp(par.delta0,opd,k,kvecxy=kvec)
            if n_elements(touts) eq 0 then begin
                touts=tens
                kouts=kvec
            endif else begin
                touts=tcontract(touts,tens)
                kouts=kouter(kouts,kvec)
            endelse
        endif
        if tmp.type eq 'pol' then begin
            mp=matpol(tmp.angle*!dtor)
            if not keyword_set(quiet) then print,'polariser at ',tmp.angle
            touts=leftmult(touts,mp)
            goto,out1
        endif
    endfor

    out1:

    souts=fltarr(n_elements(kouts(0,*))) + state
    if state eq 0 then begin
        tout=touts
        kout=kouts
        sout=souts
    endif else begin
        tout=[[[tout]],[[touts]]]
        kout=[[kout],[kouts]]
        sout=[sout,souts]
    endelse
    dum=temporary(touts)
endfor

tout0=tout(0,0,*)
tout1=tout(0,1,*)
tout2=tout(0,2,*)
tout3=tout(0,3,*)
toutc=abs(tout1)+abs(tout2)+abs(tout3)+abs(tout0)
kx=kout(0,*)
ky=kout(1,*)
kz=kout(2,*)

;tout=exp(complex(0,1) * 2*!pi*kz) * tout


idx=where(abs(toutc) gt 1d-5)
idxog=idx
;dum=where(kz(idx) ge 0) & idx=idx(dum)
ttmp=(str.mountangle - p.camangle)*!dtor + 1*!dtor
vec=[cos(ttmp),sin(ttmp)]
sgn=kx*vec(0)+ky*vec(1)
dum=where(sgn(idx) ge 0) & idx=idx(dum)
kmax=100
dmax=10000
scal=kx/kmax * 100. + ky/kmax * 10. + sout*1000;+ kz/dmax
uq=uniq(scal(idx),sort(scal(idx)))
idxo=idx
idx=idx(uq)
nidx=n_elements(idx)
tmax=8
kzlist=fltarr(nidx,tmax)
toutlist=complexarr(4,4,nidx,tmax)
toutlistw=toutlist
toutsum=complexarr(4,4,nidx)
nkz=fltarr(nidx)
kxlist=fltarr(nidx)
kylist=kxlist
kzavlist=kxlist
kzrnglist=kxlist
slist=kxlist
indexlist=intarr(nidx)
if n_elements(thv) ne 0 then begin
    kzv=fltarr(szv(0),szv(1),nidx)
    for i=0,nidx-1 do begin
;    rr=[2,0,1];
        rr=[0,1,-1]
        for cnt=0,3 do begin
            mult=rr[idx(i)/3^cnt mod 3]
            kzv(*,*,i)+=mult * opdv(*,*,cnt)
        endfor
    endfor
endif

for i=0,nidx-1 do begin
    tmp=where(scal(idxo) eq scal(idx(i)))
    nf=n_elements(tmp)
    kzlist(i,0:nf-1) = kz(idxo(tmp))
    indexlist(i)=idxo(tmp(0))
    kzavlist(i)=mean(kz(idxo(tmp)))
    kzrnglist(i)=max(kz(idxo(tmp))) - min(kz(idxo(tmp)))
    kxlist(i)=kx(idx(i))
    kylist(i)=ky(idx(i))
    slist(i)=sout(idx(i))
;    if not keyword_set(dbef) then fc = (1-del*kappa) else  
   fc=1.
    for j=0,nf-1 do toutlist(*,*,i,j)=tout(*,*,idxo(tmp(j)))
    for j=0,nf-1 do toutlistw(*,*,i,j)=exp(2*!pi*complex(0,1)*abs(fc*kz(idxo(tmp(j)))))
    nkz(i)=nf
    if n_elements(thv) ne 0 then stop
endfor
toutlistm=toutlist*toutlistw
for i=0,nidx-1 do begin
    for j=0,nkz(i)-1 do toutsum(*,*,i)+=toutlistm(*,*,i,j)
endfor
;delta lambda correction
;

;pcor=abs(kzavlist)*del*kappa*(-1)
;if not keyword_set(dbef) then for i=0,nidx-1 do toutsum(*,*,i)*=exp(pcor)


mat=reform(toutsum(0,*,*))

getdxdy,kxlist,kylist,dkx,dky,rot=(str.mountangle - p.camangle)*!dtor
;stop
end

pro newdemod, img,cars, nbin=nb,gap=id2,sh=sh,mat=mat,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,doplot=doplot,demodtype=demodtype
readpatch,sh,p
default,demodtype,'basic'
readdemodp,demodtype,sd
readcell,p.cellno,str

gencarriers,sh=sh,th=[0,0],mat=mat,kx=kx,ky=ky,kz=kza,dkx=dkx,dky=dky,p=p,str=str,/noload;,/quiet


szs=size(img,/dim)
ix=findgen(szs(0))/szs(0)-0.5
iy=findgen(szs(1))/szs(1)-0.5

wx=hats(0,.5,ix,set=sd.win);,dopl=doplh)
wy=hats(0,.5,iy,set=sd.win)

win=transpose(wy) ## (wx)

if keyword_set(doplot) then begin
    imgplot,win,pos=posarr(2,1,0),title='window'
endif

img2=img*win

getfftix, szs,ix,iy,ix2,iy2


rot=(str.mountangle - p.camangle)*!dtor
ix2r=   ix2 * cos(rot) + iy2 * sin(rot)
iy2r= - ix2 * sin(rot) + iy2 * cos(rot)




fimg=fft(img2)


imsz=[(p.roir-p.roil+1),(p.roit-p.roib+1)]/p.bin
;         if not keyword_set(quiet) then print,'imsz=',imsz
         kmult= $; fringes/deg
            1/!dtor* $; /rad
            1/p.flencam* $; per mm on detector
            6.5e-3*p.bin ; per binned pixel

kx*=kmult
ky*=kmult
dkx*=kmult
dky*=kmult



arot=abs(rot)
dkxr=   dkx * cos(arot) + dky * sin(arot)
dkyr=   dkx * sin(arot) + dky * cos(arot)
nbx=floor(1/dkxr/ sd.dsmult)
nby=floor(1/dkyr/ sd.dsmult)
nb=[nbx,nby]


i0=(getcamdims(p) / p.bin )/2.
id2=[(i0(0) - (p.roil-1)) mod nb(0), (i0(1)-(p.roib-1)) mod nb(1)]

imszo=floor((imsz-id2)*1./[nbx,nby])
imsz2=imszo * nb
id=imsz-imsz2
;id2=id/2





;ixo1=findgen(imszo(0))*nbx
;iyo1=findgen(imszo(1))*nby
;ixo2=ixo1 # replicate(1,imszo(1))
;iyo2=replicate(1,imszo(0)) # iyo1


if keyword_set(doplot) then begin
ixs=shift(ix,((szs(0)-1)/2))
iys=shift(iy,((szs(1)-1)/2))
fimgs=shift(fimg,(szs(0)-1)/2,(szs(1)-1)/2)
imgplot,alog10(fimgs),ixs,iys,pos=posarr(/next),/noer
defcirc,/fill
oplot,kx,ky,psym=8,col=5,symsize=1
endif

ncar=n_elements(kx)


;ixn=findgen(imsz(0)) # replicate(1,imsz(1))
;iyn=replicate(1,imsz(0)) # findgen(imsz(1))


winb=rebin(win(id2(0):id2(0)+imsz2(0)-1,id2(1):id2(1)+imsz2(1)-1),imszo(0),imszo(1),/sample)

cars=complexarr(imszo(0),imszo(1),ncar)
for i=0,ncar-1 do begin
;    if not keyword_set(quiet) then print,'start'
    filtx = hats(kx(i), dkx*sd.fracbw, ix2r,set=sd.filt)
    filty = hats(ky(i), dky*sd.fracbw, iy2r,set=sd.filt)
    filt = filtx * filty

    if keyword_set(doplot) then contour, shift(filt,(szs(0)-1)/2,(szs(1)-1)/2),ixs,iys,/noer,pos=posarr(/curr)

;    print,'hey'
    tmp=fft(fimg*filt,/inverse)
    car=rebinc(tmp(id2(0):id2(0)+imsz2(0)-1,id2(1):id2(1)+imsz2(1)-1),imszo(0),imszo(1),/sample)
 ; make sure its cntred for the downsample
;    stop
    
    if sd.typthres eq 'win' then inan=where(winb lt max(winb) * sd.thres)
    if sd.typthres eq 'data' then inan=where(abs(cars(*,*,0)) lt max(abs(cars(*,*,0))) * sd.thres)
    if inan(0) ne -1 then car(inan)=!values.f_nan
    cars(*,*,i)=car

endfor

ixo=findgen(imszo(0))*nb(0) + id2(0) + p.roil-1
iyo=findgen(imszo(1))*nb(1) + id2(1) + p.roib-1


x1=(ixo - i0(0))*p.bin * 6.5e-3
y1=(iyo - i0(1))*p.bin * 6.5e-3

;x2 = x1 # replicate(1,imsz(1))
;y2 = replicate(1,imsz(0)) # y1

thx=x1/p.flencam
thy=y1/p.flencam

iz=[value_locate(ixo,i0(0)),value_locate(iyo,i0(1))]

;stop




end


pro genmat3, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav

nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
for i=0,nx-1 do thv(i,*,0)=thx(i)
for j=0,ny-1 do thv(*,j,1)=thy(j)

gencarriers,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,vth=thv


end

pro genmat2, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav

gencarriers,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat
;kz0=kz

;print,mat ## transpose([1,1,0,0])/19.7
;print,transpose(reform(car1))

nx=n_elements(thx)
ny=n_elements(thy)

;stop

nidx=n_elements(kx)

sz=size(kz,/dim)
nxn=nx/5
nyn=ny/5
kzs=fltarr(sz(0),sz(1),nxn,nyn)
kza=fltarr(sz(0),sz(1),nx,ny)
thxs=interpol(thx,linspace(0,1,nx),linspace(0,1,nxn))
thys=interpol(thy,linspace(0,1,ny),linspace(0,1,nyn))

ixtmp=linspace(0,nxn-1,nx)
iytmp=linspace(0,nyn-1,ny)

for i=0,nxn-1 do for j=0,nyn-1 do begin
    gencarriers,sh=sh,th=[thxs(i),thys(j)],p=p,str=str,/noload,/quiet,tkz=kz
    kzs(*,*,i,j)=kz
;    print,i,j,nxn,nyn
endfor

for i=0,sz(0)-1 do for j=0,sz(1)-1 do begin
    kza(i,j,*,*)=interpolate(kzs(i,j,*,*),ixtmp,iytmp,/grid,cubic=-0.5)
;    print,i,j,sz
endfor

kzaav=fltarr(nidx,nx,ny)
for i=0,nidx-1 do $
  kzaav(i,*,*)=total(kza(i,0:nkz(i)-1,*,*),2)/nkz(i)


mat2=complexarr(4,nidx,nx,ny)
for i=0,nidx-1 do begin
    nf=nkz(i)
    for j=0,nf-1 do begin
        tmp=reform(exp(2*!pi*complex(0,1)*abs(kza(i,j,*,*)))) ; a(i,j,iz(0),iz(1)))))
                                ;matrix multiply
        for k=0,3 do  mat2(k,i,*,*)+=toutlist(0,k,i,j) * tmp
    endfor
endfor

end ; genmat2



pro testit
common cb2, img,cars,gap,nbin,mat,thx,thy,iz,p,str,sd
simimgnew,img
sh=8046
newdemod,img,cars,gap=gap,nbin=nbin,sh=sh,mat=mat,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd;,/doplot


nx=n_elements(thx)
ny=n_elements(thy)

iztmp=iz
iztmp(0)+=30
car1=cars(iztmp(0),iztmp(1),*)




 genmat2, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav


svec=complexarr(nx,ny,4)
delarr=fltarr(nx,ny)
for i=0,nx-1 do for j=0,ny-1 do begin
;    la_svd,mat,w,u,v
    la_svd,mat2(*,*,i,j),w,u,v
    wi=1/w                      ;&  wi(2)=0.
    imat=v ## diag_matrix(wi) ## conj(transpose(u))*20.
    harm=transpose(reform(cars(i,j,*)))

    tmp=kza(*,*,i,j)
    inz=where(tmp ne 0)
    mkz=median(tmp(inz))

    iharm=imat ## harm
    kappa=1.0
    del1=atan2(iharm(1)) /2/!pi / mkz / kappa
    del2=atan2(iharm(2)) /2/!pi / mkz / kappa

;    delw=(del1*abs(iharm(1)) + del2 * abs(iharm(2))) / (abs(iharm(1))+abs(iharm(2)))
    delw=del1
    delarr(i,j)=delw
    
    pcor2=abs(kzaav(*,i,j))*delw*kappa*(1)
    harm=harm * exp(-2*!pi*complex(0,1)*pcor2)
;    stop

    s=imat ## harm


    svec(i,j,*)=s
endfor

;print,kza(*,*,iztmp(0),iztmp(1))-kz0


print,svec(iztmp(0),iztmp(1),*)

 imgplot,atan2(svec(*,*,1))*!radeg,/cb,pal=-2,pos=posarr(2,2,0)


; imgplot,atan(abs(svec(*,*,2)),abs(svec(*,*,1)))*!radeg,/cb,pal=-2,pos=posarr(/next),/noer

 imgplot,atan(float(svec(*,*,2)),float(svec(*,*,1)))*!radeg,/cb,pal=-2,pos=posarr(/next),/noer

 imgplot,delarr*656.1,/cb,pal=-2,pos=posarr(/next),/noer



;print,mat
;print,' '
;print,mat2(*,*,iz(0),iz(1))


;stop
end

pro testit2

sh=1615


common cb2, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd

img=getimgnew(sh)*1.0

newdemod, img,cars, nbin=nb,gap=id2,sh=sh,mat=mat,thx=thx,thy=thy,iz=iz,p=p,str=str,sd=sd,demodtype='real'

print,'hey'
;stop
genmat3, mat2=mat2,kza1=kza,sh=sh,iz=iz,thx=thx,thy=thy,p=p,str=str,kzaav=kzaav

nx=n_elements(thx)
ny=n_elements(thy)




carsim=complexarr(nx,ny,4)
svec=transpose([1,1,0,0])

for i=0,nx-1 do for j=0,ny-1 do begin
;    la_svd,mat,w,u,v

    tmpmat=mat2(*,*,i,j)
    carsim(i,j,*) = tmpmat ## svec
endfor


;svec=complexarr(nx,ny,4)
;delarr=fltarr(nx,ny)
;for i=0,nx-1 do for j=0,ny-1 do begin


;stop
end


testit2
end




