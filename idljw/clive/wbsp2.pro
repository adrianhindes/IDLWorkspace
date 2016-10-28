function myhilb, arr
sarr=fft(arr)
nx=n_elements(arr(*,0))
ny=n_elements(arr(0,*))
ix=findgen(nx) & ix(where(ix gt nx/2))-=nx
iy=findgen(ny) & iy(where(iy gt ny/2))-=ny
ix2=ix # replicate(1,ny)
iy2=replicate(1,nx) # iy
slope=-2.
in = iy2 gt ix2*slope
sarr=sarr*in
;imgplot,alog(abs(sarr)),/cb
arr2=fft(sarr,/inverse)
return,arr2
;stop
end


pro calcim, img,only=only,lam=lam,sh=sh
default,sh,'test1'
db='wb'
default,lam,660e-9

if sh eq 'testb1' then svec=[1,0.5,0.5,0]
if sh eq 'test1' then svec=[1,0.5,0.5,0]
if sh eq 'testc1' then svec=[1,0.5,0.5,0]
if sh eq 'test2' then svec= [1,0,1,0]
if strmid(sh,0,5) eq 'test3' then svec=[1,0.5,0.5,0]
if sh eq 'test4' then svec=[1,0.5,0.5,0]

simimgnew,img,sh=sh,lam=lam,svec=svec,db=db;,/angdeptilt
; imgplot,alog10(abs(fft(img*hanning(2560,2160),/center))),/cb


;stop
if keyword_set(only) then return
readpatch,sh,p,db=db
readdemodp,'basicd44',sd

p=create_struct(p,'infoflc',{stat1:[[0,0,0,0],[0,0,0,0]]})
readcell,p.cellno,str


newdemod, img,cars,/noload,str=str,p=p,sd=sd,lam=lam,thx=thx,thy=thy,/doplot
stop

thx2=thx # replicate(1,n_elements(thy))
thy2=replicate(1,n_elements(thx)) # thy
vth=fltarr(n_elements(thx),n_elements(thy),2)
vth(*,*,0)=thx2
vth(*,*,1)=thy2

gencarriers2,sh=sh,db=db,mat=mat,dmat=dmat,kz=kz,kx=kx,ky=ky,th=[0,0],vth=vth,vkz=kzv

print,'weights are'
print,dmat ## svec/50.

;nbin=nb,gap=id2,sh=sh,mat=mat,thx=thx,thy=thy,$
;iz=iz,p=p,str=str,sd=sd,doplot=doplot,demodtype=demodtype,frac=frac,$
;indexlist=indexlist,lam=lam,ixo=ixo,iyo=iyo,ifr=ifr,noinit=noinit,slist=slist,$
;stat=stat,quiet=quiet,dmat=dmat,kx=kx,ky=ky,kz=kza,istat=istat,doload=doload,$
;cacheread=cacheread,cachewrite=cachewrite,noload=noload,noid2=noid2,db=db
nx=n_elements(thx)
ny=n_elements(thy)
ind=findgen(nx)
;kzv=abs(kzv)
mkfig,'~/cars.eps',xsize=12,ysize=9,font_size=10
for c=1,4 do begin
dir=[kx(c),ky(c)]
dir/=sqrt(total(dir^2))
dist=linspace(-nx/2,nx/2,nx/2*2+1)
xi=nx/2 + dir(0) * dist * (kz(c) ne 0 ? abs(kz(c))/kz(c) : 1)
yi=ny/2 + dir(1) * dist * (kz(c) ne 0 ? abs(kz(c))/kz(c) : 1)
topl=interpolate(kzv(*,*,c),xi,yi)*(kz(c) ne 0 ? abs(kz(c))/kz(c) : 1)
if c eq 1 then plot, dist, topl,yr=[-1,1]*max(abs(kzv)) else oplot,dist,topl,col=c

endfor
endfig,/gs,/jp
;stop
end

pro psf,sh=sh,larr,prod
default,sh,'testb1'
calcim,im,lam=660e-9,sh=sh & im=myhilb(im)
stop
larr=linspace(-10,10,21)
nl=n_elements(larr)
prod=fltarr(nl)
for i=0,nl-1 do begin
   calcim,im1,/only,sh=sh,lam=(660.+larr(i))*1e-9 & im1=myhilb(im1)
   prod(i)=abs(total((im*conj(im1))))
endfor

;plot,larr,prod

end
;goto,ee
psf,sh='testd3',larr,prod
;psf,sh='test2',larr2,prod2
ee:
mkfig,'~/pdf1.eps,',xsize=13,ysize=10,font_size=10
plot,larr,prod/max(prod),thick=4,xtitle='Delta lambda (nm)',ytitle='psf'
oplot,larr2,prod2/max(prod2),col=2,thick=4
endfig,/gs,/jp
end

