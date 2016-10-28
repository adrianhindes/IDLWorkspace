
;pro calcim, img,only=only,lam=lam,sh=sh
;default,
sh='testfw7'
db='wb'
default,lam,660e-9

if sh eq 'test1' then svec=[1,0.5,0.5,0]
if sh eq 'test2' then svec= [1,0,1,0]
if sh eq 'test3' then svec=[1,0.5,0.5,0]
if sh eq 'test4' then svec=[1,0.5,0.5,0]
if sh eq 'testht' then svec=[1,1.,0,0]
if strmid(sh,0,6) eq 'testfw' then svec=[1,1.,0,0]
if sh eq 'testfw7' then svec=[1,0.5,0.5,0]
;if sh eq 'testfw4' then svec=[1,0.5,0.5,0]

simimgnew,img,sh=sh,lam=lam,svec=svec,db=db,/angdeptilt

readpatch,sh,p,db=db
readcell,p.cellno,str
p=create_struct(p,'infoflc',{stat1:[[0,0,0,0],[0,0,0,0]]})
readdemodp,'basicd44',sd
newdemod,img,sh=sh,lam=lam,db=db,p=p,str=str,sd=sd,/noload,/onlyplot,/doplot,svec=svec

;win=hanning(512,512)
win=hanning(2560,2160)
;win = win*0 + 1



s=fft(img*win,/center) 
ps=abs(s)^2 
ns=20
kern=fltarr(ns,ns)+1.                                


ps2=convol(ps,kern/total(kern))
sps2=sqrt(ps2)



imgplot,sps2,/cb

gencarriers2,sh=sh,db=db,mat=mat,dmat=dmat,kz=kz,kx=kx,ky=ky,th=[0,0]

print,kx,ky,kz,transpose(abs(dmat ## transpose(svec)))
end

;; if keyword_set(only) then return
;; readpatch,sh,p,db=db
;; readdemodp,'basicd44',sd

;; p=create_struct(p,'infoflc',{stat1:[[0,0,0,0],[0,0,0,0]]})
;; readcell,p.cellno,str


;; newdemod, img,cars,/doplot,/noload,str=str,p=p,sd=sd,lam=lam,thx=thx,thy=thy

;; thx2=thx # replicate(1,n_elements(thy))
;; thy2=replicate(1,n_elements(thx)) # thy
;; vth=fltarr(n_elements(thx),n_elements(thy),2)
;; vth(*,*,0)=thx2
;; vth(*,*,1)=thy2

;; gencarriers2,sh=sh,db=db,mat=mat,dmat=dmat,kz=kz,kx=kx,ky=ky,th=[0,0],vth=vth,vkz=kzv

;; print,'weights are'
;; print,dmat ## svec/50.

;; ;nbin=nb,gap=id2,sh=sh,mat=mat,thx=thx,thy=thy,$
;; ;iz=iz,p=p,str=str,sd=sd,doplot=doplot,demodtype=demodtype,frac=frac,$
;; ;indexlist=indexlist,lam=lam,ixo=ixo,iyo=iyo,ifr=ifr,noinit=noinit,slist=slist,$
;; ;stat=stat,quiet=quiet,dmat=dmat,kx=kx,ky=ky,kz=kza,istat=istat,doload=doload,$
;; ;cacheread=cacheread,cachewrite=cachewrite,noload=noload,noid2=noid2,db=db
;; nx=n_elements(thx)
;; ind=findgen(nx)
;; kzv=abs(kzv)
;; mkfig,'~/cars.eps',xsize=12,ysize=9,font_size=10
;; for c=1,4 do begin
;; dir=[kx(c),ky(c)]
;; dir/=sqrt(total(dir^2))
;; dist=linspace(-nx/2,nx/2,nx/2*2+1)
;; xi=nx/2 + dir(0) * dist * abs(kz(c))/kz(c)
;; yi=nx/2 + dir(1) * dist * abs(kz(c))/kz(c)
;; topl=interpolate(kzv(*,*,c),xi,yi)
;; if c eq 1 then plot, dist, topl,yr=[0,max(kzv)] else oplot,dist,topl,col=c

;; endfor
;; endfig,/gs,/jp
;; ;stop
;; end

;; pro psf,sh=sh,larr,prod
;; default,sh,'test1'
;; calcim,im,lam=660e-9,sh=sh,/only & im=myhilb(im)
;; stop
;; larr=linspace(-10,10,21)
;; nl=n_elements(larr)
;; prod=fltarr(nl)
;; for i=0,nl-1 do begin
;;    calcim,im1,/only,sh=sh,lam=(660.+larr(i))*1e-9 & im1=myhilb(im1)
;;    prod(i)=abs(total((im*conj(im1))))
;; endfor

;; ;plot,larr,prod

;; end
;; ;goto,ee
;; psf,sh='testht',larr,prod
;; ;psf,sh='test2',larr2,prod2
;; ee:
;; mkfig,'~/pdf1.eps,',xsize=13,ysize=10,font_size=10
;; plot,larr,prod/max(prod),thick=4,xtitle='Delta lambda (nm)',ytitle='psf'
;; oplot,larr2,prod2/max(prod2),col=2,thick=4
;; endfig,/gs,/jp
;; end
