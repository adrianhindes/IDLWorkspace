pro newdemod, img,cars, nbin=nb,gap=id2,sh=sh,mat=mat,thx=thx,thy=thy,$
iz=iz,p=p,str=str,sd=sd,doplot=doplot,demodtype=demodtype,frac=frac,$
indexlist=indexlist,lam=lam,ixo=ixo,iyo=iyo,ifr=ifr,noinit=noinit,slist=slist,$
stat=stat,quiet=quiet,dmat=dmat,kx=kx,ky=ky,kz=kza,istat=istat,doload=doload,$
cacheread=cacheread,cachewrite=cachewrite,noload=noload,noid2=noid2,db=db,onlyplot=onlyplot,svec=svec,ordermag=ordermag,no2load=no2load



default,ifr,0


if keyword_set(cacheread) or keyword_set(cachewrite) then begin
    pth=gettstorepath()
    fn=string(pth,'newdemod',sh,ifr,format='(A,A,"_",I0,"_",I0,".hdf")')
endif


if not keyword_set(noload) and not keyword_set(no2load) then begin
    readpatch,sh,p,db=db,/getflc
 endif

if not keyword_set(noload) then begin

    default,demodtype,'basicd'
    readdemodp,demodtype,sd
    readcell,p.cellno,str
endif
ifr=fix(ifr)

gencarriers2,sh=sh,th=[0,0],mat=mat,kx=kx,ky=ky,kz=kza,dkx=dkx,dky=dky,p=p,str=str,/noload,frac=frac,indexlist=indexlist,lam=lam,stat=stat,slist=slist,dmat=dmat,quiet=quiet,nstates=nstates,tkz=tkz
ifr2=ifr+p.nskip

if p.flc0per eq 999 then begin
   print,'error 999 peiod'
   stop
endif
;stat1=[((ifr2 - p.flc0t0) mod p.flc0per) / (p.flc0mark eq 0 ? p.flc0per/2 : p.flc0mark), ((ifr2-p.flc1t0) mod p.flc1per) / (p.flc1mark eq 0 ? p.flc1per/2 : p.flc1mark)]
stat1=p.pinfoflc.stat1[ifr,*]
if n_elements(stat)/2 eq 2 then stat1(1)=0. ;; fudge 



if nstates gt 1 then istat=where( (stat1(0) eq stat(0,*)) and (stat1(1) eq stat(1,*))) else istat=0

if not keyword_set(quiet) then print,'stat1=',stat1,istat
;print,'___'
;wait,1


imsz=[(p.roir-p.roil+1),(p.roit-p.roib+1)]/[p.binx,p.biny]
;         if not keyword_set(quiet) then print,'imsz=',imsz
         kmult= $; fringes/deg
            1/!dtor* $; /rad
            1/p.flencam* $; per mm on detector
            p.pixsizemm*[p.binx,p.biny] ; per binned pixel

kx*=kmult(0)
ky*=kmult(1)
dkx*=kmult(0)
dky*=kmult(1)


if keyword_set(cacheread) then begin
    dum=file_search(fn,count=cnt)
    if cnt ne 0 then begin
;        restore,file=fn,/verb
        hdfrestoreext,fn,outs
        cars1=outs.cars
        mat=outs.mat
        ixo=outs.ixo
        iyo=outs.iyo
        thx=outs.thx
        thy=outs.thy
        iz=outs.iz

        if not keyword_set(noinit) then cars=cars1*0
        ncar=n_elements(kx)

        for i=0,ncar-1 do begin
            if slist(i) ne istat then continue
            cars(*,*,i)=cars1(*,*,i)
        endfor

        if not keyword_set(quiet) then print,'restored'
        return
    endif
endif


if keyword_set(doload) then begin
    img=getimgnew(sh,ifr,db=db,info=info,/getinfo,/noloadstr,str=p)*1.0
;    img=median(img,3,dimension=0) ;; filter hard coded!!!
    img0=img&imgs=img&sz=size(img,/dim)
    for i=0,sz(1)-1 do imgs(*,i)=median(img0(*,i),9)
    idx=where(abs(imgs-img0) gt abs(imgs)*0.5)
    if idx(0) ne -1 then img(idx)=imgs(idx)

;    stop
endif

szs=size(img,/dim)
ix=findgen(szs(0))/szs(0)-0.5
iy=findgen(szs(1))/szs(1)-0.5

wx=hats(0,.5,ix,set=sd.win);,dopl=doplh)
wy=hats(0,.5,iy,set=sd.win)

win=transpose(wy) ## (wx)

if keyword_set(doplot) then begin
;    imgplot,win,pos=posarr(2,1,0),title='window'
endif

img2=img*win
;stop
getfftix, szs,ix,iy,ix2,iy2


rot=(str.mountangle - p.camangle)*!dtor
ix2r=   ix2 * cos(rot) + iy2 * sin(rot)
iy2r= - ix2 * sin(rot) + iy2 * cos(rot)




fimg=fft(img2)




arot=abs(rot)

dkx=dkx < 1.0
dky=dky < 1.0

dkxr=   dkx * cos(arot) + dky * sin(arot)
dkyr=   dkx * sin(arot) + dky * cos(arot)

nbx=floor(1/dkxr/ sd.dsmultx)>1
nby=floor(1/dkyr/ sd.dsmulty)>1
nb=[nbx,nby]


i0=(getcamdims(p) / [p.binx,p.biny] )/2.
id2=[(i0(0) - (p.roil-1)) mod nb(0), (i0(1)-(p.roib-1)) mod nb(1)]
if keyword_set(noid2) then id2=id2*0
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
if not keyword_set(onlyplot) then begin
   mx=max(alog10(abs(fimgs>1e-16)))
   default,ordermag,6
   imgplot,alog10(abs(fimgs)),ixs,iys,/iso,pos=posarr(1,1,0),/cb,zr=[-ordermag,0]+mx ;,/noer
   defcirc,/fill
   oplot,kx,ky,psym=8,col=5,symsize=1
endif

if keyword_set(onlyplot) then begin
   ps=abs(fimgs)^2
   kern=fltarr(31,31)+1.
;   ps2=convol(ps,kern/total(kern))
   ps2=ps
   fimgs2=sqrt(ps2)
   fimgs2/=max(fimgs2)
   imgplot,alog10(abs(fimgs2)),ixs,iys,/iso,pos=posarr(1,1,0),/cb,zr=[-5,0] ;,/noer
   defcirc
   pw=transpose(abs(dmat ## transpose(svec)))
   idx=where(pw gt max(pw) * 0.01)
   oplot,kx(idx),ky(idx),psym=8,col=5,symsize=3
   print,kx(idx),ky(idx),kza(idx),pw(idx)

   stop
endif




endif
ncar=n_elements(kx)


;ixn=findgen(imsz(0)) # replicate(1,imsz(1))
;iyn=replicate(1,imsz(0)) # findgen(imsz(1))


winb=rebin(win(id2(0):id2(0)+imsz2(0)-1,id2(1):id2(1)+imsz2(1)-1),imszo(0),imszo(1),/sample)

if not keyword_set(noinit) then cars=complexarr(imszo(0),imszo(1),ncar)

for i=0,ncar-1 do begin
    if slist(i) ne istat then continue
;    if not keyword_set(quiet) then print,'start'
    rot=(str.mountangle - p.camangle)*!dtor
    kxr = kx * cos(rot) + ky * sin(rot)
    kyr = -kx * sin(rot) + ky * cos(rot)

    if sd.demodtype eq 'basicfullt' then filtx = hats2(kxr(i), dkx*sd.fracbwx, ix2r,set=sd.filt.type eq 'sghat' ? {type:'sg',sgexp:sd.filt.sgexp,sgmul:sd.filt.sgmul} : sd.filt) $
       else $
          filtx = hats(kxr(i), dkx*sd.fracbwx, ix2r,set=sd.filt.type eq 'sghat' ? {type:'sg',sgexp:sd.filt.sgexp,sgmul:sd.filt.sgmul} : sd.filt)

    filty = hats(kyr(i), dky*sd.fracbwy, iy2r,set=sd.filt)
    filt = filtx * filty

    if keyword_set(doplot) then contour, shift(filt,(szs(0)-1)/2,(szs(1)-1)/2),ixs,iys,/noer,pos=posarr(/curr),/iso
;    print,'hey'
    tmp=fft(fimg*filt,/inverse)
    car=rebinc(tmp(id2(0):id2(0)+imsz2(0)-1,id2(1):id2(1)+imsz2(1)-1),imszo(0),imszo(1),/sample)
 ; make sure its cntred for the downsample
    cars(*,*,i)=car

endfor

if sd.typthres eq 'data' then begin
    izz=where(kza eq 0 and fix(slist) eq istat(0))
    inan=where(abs(cars(*,*,izz)) lt  max(abs(cars(*,*,izz))) * sd.thres)
 endif

if sd.typthres eq 'data1' then begin
    izz=where(kza ne 0 and fix(slist) eq istat(0))
    inan=where(abs(cars(*,*,izz)) lt  max(abs(cars(*,*,izz))) * sd.thres)
 endif

;stop
if sd.typthres eq 'win' then inan=where(winb lt max(winb) * sd.thres)

for i=0,    ncar-1 do begin
    if inan(0) ne -1 then begin
        car=cars(*,*,i)
        car(inan)=!values.f_nan
        cars(*,*,i)=car
    endif
endfor

ixo=findgen(imszo(0))*nb(0) + id2(0) + p.roil-1
iyo=findgen(imszo(1))*nb(1) + id2(1) + p.roib-1


x1=(ixo - i0(0))*p.binx * p.pixsizemm
y1=(iyo - i0(1))*p.biny * p.pixsizemm

;x2 = x1 # replicate(1,imsz(1))
;y2 = replicate(1,imsz(0)) # y1

thx=x1/p.flencam
thy=y1/p.flencam

iz=[value_locate(ixo,i0(0)),value_locate(iyo,i0(1))]



if keyword_set(cachewrite) then begin
;        restore,file=fn,/verb
        outs={cars:cars,mat:mat,ixo:ixo,iyo:iyo,thx:thx,thy:thy,iz:iz}
        hdfsaveext,fn,outs
        if not keyword_set(quiet) then         print,'saved'


endif

end








