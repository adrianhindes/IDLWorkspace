pro getit, larr=larr,prod=prod,meth=meth
;wid=16e-6 * 512 / 50e-3
wid=6.5e-6 * 2560 / 50e-3

nx=512
ny=512

thx=linspace(-wid/2,wid/2,nx)
thy=thx
thx2=thx # replicate(1,ny)
thy2=replicate(1,nx) # thy

nl=41
larr=linspace(640,680,nl)
nwavs=complexarr(nx,ny,nl)
for i=0,nl-1 do begin
lam=larr(i)
par1={crystal:'bbo',thickness:5e-3,lambda:lam*1e-9,facetilt:45*!dtor}
par2={crystal:'bbo',thickness:2.2e-3,lambda:lam*1e-9,facetilt:0*!dtor}

;par2={crystal:'bbo',thickness:1e-3,lambda:lam*1e-9,facetilt:0*!dtor}


nwav1=opd(thx2,thy2,par=par1,delta=0,k0=k0)/2/!pi
nwav2=opd(thx2,thy2,par=par2,delta=!pi/2)/2/!pi
nwav=nwav1-nwav2

print,nwav1(nx/2,ny/2),nwav2(nx/2,ny/2),nwav(nx/2,ny/2)
plot,nwav(*,nx/2)
stop


nwavtmp = thx2 * k0 + nwav(nx/2,ny/2)

isel=nl/2
;imgplot,nwav,/cb
if meth eq 0 then begin
   nwavs(*,*,i)=(exp(complex(0,1)*2*!pi*nwavtmp))
   if i eq isel then ref=(exp(complex(0,1)*2*!pi*nwav))
endif

if meth eq 1 then begin
   nwavs(*,*,i)=(exp(complex(0,1)*2*!pi*nwav))
   if i eq isel then ref=(exp(complex(0,1)*2*!pi*nwav))
endif

if meth eq 2 then begin
   nwavs(*,*,i)=(exp(complex(0,1)*2*!pi*nwavtmp))
   if i eq isel then ref=(exp(complex(0,1)*2*!pi*nwavtmp))
endif


endfor
win=hanning(nx,ny)*0+1
prod=fltarr(nl)
for i=0,nl-1 do prod(i)=abs(total(nwavs(*,*,i) * conj(ref)*win))
;stop


end

getit,larr=larr,prod=p0,meth=0
getit,larr=larr,prod=p1,meth=1
getit,larr=larr,prod=p2,meth=2
plot,larr,p0/max(p0),xtitle='lam (nm)',ytitle='psf'
oplot,larr,p1/max(p1),col=2
oplot,larr,p2/max(p2),col=3
end
