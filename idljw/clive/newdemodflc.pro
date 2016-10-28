pro newdemodflc,sh, off, only2=only2p, eps=eps,angt=ang,dop1=dop1,dop2=dop2,doplot=doplot,cacheread=cacheread,cachewrite=cachewrite,dop3=dop3,dopc=dopc,dostop=dostop,ang0=ang0,pp=p,str=str,sd=sd,noload=noload,vkz=vkz,lin=lin,inten=inten,ix=ix,iy=iy,plotcar=plotcar,cix=cix,ciy=ciy,only1=only1,cars=cars,istata=istata,demodtype=demodtype,noid2=noid2,db=db,multiplier=multiplier
default,only2p,0
default,only1,0


only2=abs(only2p)
if keyword_set(cacheread) or keyword_set(cachewrite) then begin
    pth=gettstorepath()
    fn=string(pth,'newdemodflc',only2,only1,sh,off,format='(A,A,"_only2_",I0,"_only1_",I0,"_",I0,"_",I0,".hdf")')
endif

default,demodtype,'basicd'

if keyword_set(cacheread) then begin
    dum=file_search(fn,count=cnt)
    if cnt ne 0 then begin
;        restore,file=fn,/verb
        hdfrestoreext,fn,outs
        cars=outs.cars
        svec2=outs.svec2
        sz=outs.sz
        readdemodp,demodtype,sd
        istata=outs.istata
;        p=outs.p
goto,eex
        readpatch,sh,p,/getinfo,/getflc,db=db
        str=outs.str
        ix=outs.ix
        iy=outs.iy
        thx=outs.thx
        thy=outs.thy
        
        nx=n_elements(thx)
        ny=n_elements(thy)
        thv=fltarr(nx,ny,2)
        for i=0,nx-1 do thv(i,*,0)=thx(i)
        for j=0,ny-1 do thv(*,j,1)=thy(j)

        gencarriers2,sh=sh,th=[0,0],/quiet,vth=thv,vkz=vkz,lam=661.e-9,p=p,str=str,/noload ;659.89e-9
eex:
        if not keyword_set(quiet) then print,'restored'
        goto,ee
        return
    endif
endif


;sh=7479 & off=72;69;62

;sh=7480 & off=72;69;62

;sh=7426 & off=84
;sh=7358 & off=40;polariser 45 degish
;sh=7484 & off=92&xxt=10&only2=1.;polariser 40 degish

;sh=1207 & off=4


lam=659.89e-9
;

istata=fltarr(4)-1

up=only1 eq 1 ? 1 : (only2 eq 1 ? 1 : 3)
if only2p lt 0 then up=3

for j=0,up do begin

;for j=0,3 do begin
;    ang=(45)*!dtor
;    simimgnew,simg,sh=sh,lam=lam,svec=[1,cos(2*ang),sin(2*ang),0],ifr=j+off

;    simg=getimgnew(sh,j+off,info=info,/getinfo)*1.0
;ss=size(simg,/dim)
 ;   plot,simg(ss(0)/2,ss(1)/2-10:ss(1)/2+10),psym=-4,noer=j gt 0,yr=j eq 0 ? [0,0] :!y.crange,col=j+1


;imgplot,simg,/cb,zr=[0,4000]

;stop
;simg=simimg_cxrs()
;print,kx,ky,kz
default,multiplier,1
    newdemod,simg,cars,sh=sh,lam=lam,doplot=0,demodtype=demodtype,ix=ix,iy=iy,ifr=j*multiplier+off,noinit=j gt 0,mat=mattmp,kx=kx,ky=ky,kz=kz,slist=slist,dmat=mat,istat=istat1,thx=thx,thy=thy,/doload,p=p,str=str,sd=sd,noload=noload,noid2=noid2,db=db;,/cacheread,/cachewrite;,/cachewrite
istata(j)=istat1


endfor

;print,'w,r,g,b'
;print,istata


nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
for i=0,nx-1 do thv(i,*,0)=thx(i)
for j=0,ny-1 do thv(*,j,1)=thy(j)
;stop
if not keyword_set(noload) then gencarriers2,sh=sh,th=[0,0],/quiet,vth=thv,vkz=vkz,lam=661.e-9,p=p,str=str,/noload;659.89e-9

cref=exp(complex(0,1)*2*!pi*(vkz))
;stop
cars=cars / cref

;stop
;cref=cars(*,*,1)+cars(*,*,3) & cref/=abs(cref)
;for j=0,3 do cars(*,*,1+j*2) /= cref

;cref0=abs(cars(*,*,0))


;;; big thunk for to make compatible with newdemodflclt!!!
;slisttmp=slist
;if keyword_set(only2) then begin
;   istatatmp=istata
;   istata(0)=istatatmp(1)
;   istata(1)=istatatmp(0)
;endif

;slist=1-slist
iref=(where(istata(0) eq slist))(0)
irefm=(where(istata(0) eq slist))
;stop
jmax=n_elements(cars(0,0,*))/2-1
for j=0,jmax do begin
    rat=abs(cars(*,*,j*2))/abs(cars(*,*,iref))
;    stop
    cars(*,*,j*2+1)= cars(*,*,j*2+1)/ rat ;harm1 normalised for variation in harm0
    cars(*,*,j*2)= cars(*,*,j*2)/ rat ;harm1 normalised for variation in harm0
endfor

;for j=0,3 do cars(*,*,j*2)*= cref/abs(cars(*,*,j*2))

;stop
;cars(*,*,
;getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts
;contourn2,r
;imgplot,abs(cars(*,*,1)),xsty=1,ysty=1
;contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)

;stop

mato=mat
carso=cars
if only2 eq 1 then begin
    idx=[0,1,2,3]               ;indgen(4);+4
    mat=mat(*,idx)
    mat=[[mat],[0,0,0,20]]
    cars=cars(*,*,[idx,0])
    cars(*,*,4)=0.
;stop
endif


if only1 eq 1 then begin
    idx=irefm                   ;indgen(4);+4
    mat=mat(*,idx)

    cars(*,*,irefm(1)) = cars(*,*,irefm(1)) * exp(-complex(0,1)*dopc*!dtor)
    cars=cars(*,*,idx)
    
    matr=matc2r(mat)
    matr=removecol(matr,7)
    matr=removecol(matr,6)
    matr=removecol(matr,5)
    matr=removecol(matr,3)

    sz=size(cars,/dim)
    carsr=fltarr(sz(0),sz(1),sz(2)*2)
    for i=0,sz(2)-1 do begin
        carsr(*,*,2*i)=float(cars(*,*,i))
        carsr(*,*,2*i+1)=imaginary(cars(*,*,i))
    endfor

endif else begin
    matr=matc2r(mat)
    sz=size(cars,/dim)
    carsr=fltarr(sz(0),sz(1),sz(2)*2)
    for i=0,sz(2)-1 do begin
        carsr(*,*,2*i)=float(cars(*,*,i))
        carsr(*,*,2*i+1)=imaginary(cars(*,*,i))
    endfor
endelse



sz=size(cars,/dim)
szr=size(carsr,/dim)


la_svd,(mat),w,u,v
wi=1/w   ;                       &  wi(3)=0.
imat=v ## diag_matrix(wi) ## conj(transpose(u))

svdc,matr,wr,ur,vr,/double
wir=1/wr
print,'singular values are',wr
imatr = vr ## diag_matrix(wir) ## conj(transpose(ur))

svec2r=complexarr(sz(0),sz(1),szr(2))


svec2=complexarr(sz(0),sz(1),4)
;szm=size(mat,/dim)
;for i=0,szm(0)-1 do for j=0,szm(1)-1 do svec2(*,*,i)+=imat(j,i) * cars(*,*,j)
szm=size(matr,/dim)
for i=0,szm(0)-1 do for j=0,szm(1)-1 do svec2r(*,*,i)+=imatr(j,i) * carsr(*,*,j)


if only1 eq 0 then begin
    for j=0,3 do svec2(*,*,j)=complex(svec2r(*,*,2*j),svec2r(*,*,2*j+1))
endif else begin
    svec2(*,*,0)=complex(svec2r(*,*,0),svec2r(*,*,1))
    svec2(*,*,1)=complex(svec2r(*,*,2))
    svec2(*,*,2)=complex(svec2r(*,*,3))
endelse

;;;
if keyword_set(plotcar) then begin
    xxt=0
    car1=transpose(reform(cars(cix,ciy,*)))
    car1o=transpose(reform(carso(cix,ciy,*)))
    svec2=imat ## car1
    scor = abs(svec2(1)) gt abs(svec2(2)) ? svec2(1)/abs(svec2(1)) : svec2(2)/abs(svec2(2))

;scor=scor * exp(complex(0,1)*180*!dtor)
    svec2t=svec2
    svec2 = svec2 / scor
    
    print,'scor is',scor
    circpol=abs2(svec2(3))/abs(svec2(0))
    linpol=sqrt(abs(svec2(1))^2+abs(svec2(2))^2)/abs(svec2(0))
    print,'circ pol frac=',circpol
    eps=atan(circpol/linpol)*!radeg/2
    print,'eps=',eps
    print,'pol frac=',linpol
    
    print,'true ang=',xxt
    
    tmp=atan(abs2(svec2(2)),abs2(svec2(1)))*!radeg/2 + p.camangle
;tmp=atan(abs(svec2(2)),abs(svec2(1)))*!radeg/2 + p.camangle
    print,'angmsea(t)=',tmp
    print,'diff = ',tmp-xxt
    angout=tmp
    tmp=(atan2(car1(3)) - atan2(car1(1)))/4.*!radeg;+45 + p.camangle
    print,'ang simp=',tmp
    print,'diff = ',tmp-xxt
    mm= ((atan2(svec2[1])*!radeg - atan2(svec2[2])*!radeg)) 
    
    print,'mismatch of angle from 2 s vector is',mm,'deg'
    
    mmb= ((atan2(svec2[1])*!radeg - atan2(svec2[3])*!radeg)) 
    print,'doppler phase is',atan2(svec2[1])*!radeg , atan2(svec2[2])*!radeg
    
    print,'mismatch of angle from 3 and 1 s vector is',mmb,'deg'
    
;tmp=(atan2(car1(7)) - atan2(car1(5)))/2.*!radeg
;print,'delta simp=',tmp

    car2o = mato ## svec2t

    plot,abs(car2o),pos=posarr(2,1,0)
    oplot,abs(car1o),col=2
    plot,atan2(car2o)*!radeg,pos=posarr(/next),/noer
    oplot,atan2(car1o)*!radeg,col=2
    return
endif

;;



if keyword_set(cachewrite) then begin
;        restore,file=fn,/verb
        outs={svec2:svec2,cars:cars,sz:sz,thx:thx,thy:thy,ix:ix,iy:iy,istata:istata,str:str,p:p}
;stop
        dum=file_search(fn,count=cnt)
;        if cnt ne 0 then file_delete,fn
        hdfsaveext,fn,outs

        if not keyword_set(quiet) then         print,'saved'
endif

ee:
s12=svec2(*,*,1:2)
dum=max(abs(s12),imax,dimension=3)
imax=reform(imax,sz(0),sz(1))
scor=s12(imax) / abs(s12(imax))

if not keyword_set(only1) then dopc=atan2(scor)*!radeg
dop1=atan2(svec2(*,*,1))*!radeg
dop2=atan2(svec2(*,*,2))*!radeg
;if not keyword_set(only1) then dopc=dop1


svec2t=svec2
svec2t(*,*,3) = svec2(*,*,3)  / scor;(svec2(*,*,2) / abs(svec2(*,*,2))) ; ph corr
svec2t(*,*,1) = svec2(*,*,1)  / scor;(svec2(*,*,2) / abs(svec2(*,*,2))) ; ph corr
svec2t(*,*,2) = svec2(*,*,2)  / scor;(svec2(*,*,2) / abs(svec2(*,*,2))) ; ph corr

;circ=abs2(svec2t(*,*,3))/abs(svec2(*,*,0))
circ=float(svec2t(*,*,3))/abs(svec2(*,*,0))

;ang=atan(abs(svec2(*,*,2)),abs(svec2(*,*,1)))/2*!radeg+p.camangle

;ang=atan(abs2(svec2t(*,*,2)),abs2(svec2t(*,*,1)))/2*!radeg+p.camangle
ang=atan(float(svec2t(*,*,2)),float(svec2t(*,*,1)))/2*!radeg  ;;;+p.camangle


;!thunk!!!!!!!!1
ang = -ang
;plot,float(svec2t(*,35,1:2))
;oplot,imaginary(svec2t(*,35,1:2)),col=2
;stop

lin=sqrt(abs(svec2(*,*,1))^2 + abs(svec2(*,*,2))^2)/abs(svec2(*,*,0))
circr=circ/lin

inten=abs(svec2(*,*,0))
;idx=where(istata eq 0)
if only2 eq 1 then begin
   if istata(0) eq 0 then inten=cars(*,*,0)/19.7392
   if istata(0) eq 1 then inten=cars(*,*,2)/19.7392
endif

eps=atan(circr)*!radeg/2
dop3=atan2(svec2(*,*,3))*!radeg
;delsimp=(atan2(cars(*,*,7))*!radeg - atan2(cars(*,*,5))*!radeg)/2.
;4
;resstr={ang:ang,lin:lin,eps:eps,dop1:dop1,dop2:dop2,dop3:dop3,dopc:dopc}

;doplot=1

if keyword_set(doplot) then begin
print,'should be ang0=',ang(sz(0)/2,sz(1)/2)
default,ang0,28
imgplot,(ang-ang0),/cb,pal=-2,zr=[-10,10],pos=posarr(2,2,0)
;imgplot,eps,/cb,zr=[-10,10],pal=-2,pos=posarr(/next),/noer
imgplot,abs(svec2(*,*,0)),/cb,pos=posarr(/next),/noer
imgplot,dopc,/cb,pos=posarr(/next),/noer
;imgplot,dop2,/cb,pos=posarr(/next),/noer
imgplot,lin,/cb,pos=posarr(/next),/noer,zr=[0,.7]
;stop
endif
;stop

;if keyword_set(only1) then stop
if keyword_set(dostop) then stop


end



;newdemodflcshot,7426,[1.,2.],res=res;
;end

; common cbshot, shotc,dbc,isconnected
; shotc=sh
; dbc='kstar'
; nbi1=cgetdata('\NB11_VG1');\NB11_I0')
; ;nbi2=cgetdata('\NB12_I0')
; plot,t,dop2,/yno,pos=posarr(1,2,0),yr=[-180,180]
; oplot,t,dop2-180,col=3
; oplot,t,dop3,col=4
; vs=smooth(nbi1.v,200)
; plot,nbi1.t,vs,xr=!x.crange,xsty=1,/noer,/yno,col=2,pos=posarr(/next)

; end

;newdemodflc,7358, 40,/doplot,/dostop,/only2,ang0=-5;-5 john
;newdemodflc,7483, 82,/doplot,/dostop,/only2,ang0=0+10;0 john
;newdemodflc,7484, 92,/doplot,/dostop,/only2,ang0=-10+14;-10john
;newdemodflc,7690, 60,/doplot,/dostop,/only2,ang0=-10+12;-10
;newdemodflc,7688, 80,/doplot,/dostop,/only2,ang0=+10+12;+10
;newdemodflc,7695, 94,/doplot,/dostop,/only2,ang0=-20+12;-20
;newdemodflc,7696, 160,/doplot,/dostop,/only2,ang0=-30+90+12;-20

;bch

;end


;    -23.1555
;      102.722
;      85.3442

