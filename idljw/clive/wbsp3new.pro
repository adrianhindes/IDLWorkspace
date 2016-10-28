
;9=660nm ar line
;10=black
;11=ar lamp
;12=black
;for the above, 2 5mm plates with 50mm lens

;then shots13-14,15-16 are with fw savart [ahwp in it]


;1718 white light no filt
;1920 spectral lamp filt ;[nb adjusted then...]
;2122 white light filt
;2324 spectral lamp no filt
;2526 white lamp no filt...



pro getit, lam=lam,eikonal=eikonal

pix=6.5e-6*2
flen=50e-3
nx=2560/2
ny=2160/2

thx=linspace(-nx/2*pix/flen,nx/2*pix/flen,nx)
thy=linspace(-ny/2*pix/flen,ny/2*pix/flen,ny)
thx2=thx # replicate(1,ny)
thy2=replicate(1,nx) # thy

par1={crystal:'bbo',thickness:5e-3,lambda:lam,facetilt:45*!dtor}
par2={crystal:'bbo',thickness:2.2e-3,lambda:lam,facetilt:0*!dtor}

nwav1=float(opd(thx2,thy2,par=par1,delta=!pi-1.4*!dtor,k0=k0))/2/!pi
nwav2=float(opd(thx2,thy2,par=par2,delta=!pi/2))/2/!pi
nwav=nwav1-nwav2

;nwavtmp = -thx2 * k0 + nwav(nx/2,ny/2) & nwav=nwavtmp
eikonal=exp(complex(0,1)*nwav*2*!pi)
end


d=getimgnew(9+2*3,0,db='wb');&s=fft(d,/center)  
;plot,abs(s(*,2160/2+4)),xr=2560/2+[100,300]
d0=getimgnew(10+2*3,0,db='wb')
d*=1.
d0*=1.
d-=d0
d=d>0
print,'0'
dd=d
win=hanning(1280,1080)
win=win*0+1
s=fft(d*win,/center)
sz=size(d,/dim)
n=10
;s(sz(0)/2-n:sz(0)/2+n,sz(1)/2-n:sz(1)/2+n)=0
s(0:sz(0)/2+n,*)=0
d=fft(s,/inverse,/center)
print,'b'
plot,abs(s(*,1080/2+2)),xr=[950,1100],xsty=1

dat=(read_ascii('/data/kstar/misc/wbtest1/Ar_lamp_spec.txt',data_start=12)).(0)
dlam=reform(dat(0,*))
ddat=reform(dat(2,*))


ddat=smooth(ddat,3)
ddat2 = ddat * (dlam/600.)^2 ; per dl to dk

cbbo, n_e=n_e,n_o=n_o,lambda=dlam*1e-9,kappa=kappa

ddat3 = ddat2 / kappa

bi=-(n_e-n_o)
a=600*406.*1.023
;a=600*390.
b=1280/2
bp=660.
c=25/4e4*0.15*8
d=1524.

oplot, a*bi/0.12/(dlam) + b, c*(ddat3-d),col=2
oplot, a*bi/0.12/(dlam) + b, c*(ddat-d),col=3


stop


nl=21
larr=linspace(-50,30,nl)
prod=fltarr(nl)
win=hanning(sz(0),sz(1))
for i=0,nl-1 do begin
getit,lam=532e-9+larr(i)*1e-9,eikonal=sim
prod(i)=abs(total(sim*(d)*win))/1e7
;print,larr(i),
;imgplot,float(d*(sim))/1e4,zr=[-1,1],pal=-2
;stop

endfor
plot,larr,prod,psym=-4

;simimgnew,sim2,sh=1,lam=532.e-9,svec=[1,0,1,0],db='wb'

;d=sim


;newdemod,d,cars,lam=532.e-9,/doplot,sh=1,db='wb',demodtype='basic'
;zeta=abs(cars(*,*,1))/abs(cars(*,*,0))*2

;imgplot,zeta
end
