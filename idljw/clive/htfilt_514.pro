wid=16e-6 * 512 / 50e-3
ff=4;8*2
nx=30*ff
ny=30*ff

thx=linspace(-wid/2,wid/2,nx)*1d0
thy=thx*1d0
thx2=thx # replicate(1,ny)
thy2=replicate(1,nx) # thy

filtstr={nref:2.05,cwl:514}

d2=[$
[      513.294, 0.1417],$
      [513.328 ,0.1417],$
      [513.726 ,0.0493],$
      [513.917 ,0.0495],$
      [514.349 ,0.1359],$
      [514.516 ,0.3275],$
      [515.109 ,0.1544]]
lam=reform(d2(0,*))
yval=reform(d2(1,*))

nlines=n_elements(lam)

lamv=lam
path='~/spectrum/'
;fil='2013 August 08 13_25_58.spe'
;fil='2013 August 08 13_28_41.spe'
fil='514 filter.spe'
read_spe,path+fil,l,t,d
cwl=total(l*d)/total(d)
i0=value_locate(l,cwl)
p1=value_locate(d(0:i0-1),max(d) * 0.5) 
p2=value_locate(d(i0:*),max(d) * 0.5)
fwhm = -l(p1) + l(p2+i0)


;stop
;'stop

;scalld,l,d,l0=cwl,fwhm=fwhm,opt='a3';,remember=remember
;stop


;d=d/max(d)



dshift=fltarr(nx,ny)
;f=fltarr(nx,ny,3)
f=dblarr(nx,ny,nlines)
;cwl=fltarr(nx,ny)
cwl=dblarr(nx,ny)
;goto,ee
for i=0,nx-1 do for j=0,ny-1 do begin
    thetax = thx(i)
    thetay = thy(j)
    thetao=sqrt(thetax^2+thetay^2)
    dlol=1-sqrt(filtstr.nref^2-sin(thetao)^2)/filtstr.nref
    tshifted=filtstr.cwl*dlol ;lam0c=lam0*(1-dlol)
;    tshifted = 0.
    dshift(i,j)=tshifted
    for k=0,nlines-1 do $
    f(i,j,*)=interpolo(d,l-tshifted,lam)*yval
    cwl(i,j)=total(f(i,j,*)*lam)/total(f(i,j,*))
;    if thetao gt max(thx) then cwl(i,j)=!values.f_nan
endfor

plotm,cwl
ee:
;stop
;lam=cwl

for kk=0,nlines do begin
if kk eq nlines then lam=cwl(nx/2,ny/2)
if kk le nlines-1 then lam=lamv(kk)

;10mm linbo3 + 2.2mm bbo + 1mm bbo + 2mm savart plate (bbo).
;par2={crystal:'linbo3',thickness:10e-3,lambda:lam*1e-9,facetilt:0*!dtor}
;par3={crystal:'bbo',thickness:3.2e-3,lambda:lam*1e-9,facetilt:0*!dtor}
par2={crystal:'linbo3',thickness:23e-3,lambda:lam*1e-9,facetilt:0*!dtor}
par3={crystal:'bbo',thickness:0e-3,lambda:lam*1e-9,facetilt:0*!dtor}
par4={crystal:'bbo',thickness:1e-3,lambda:lam*1e-9,facetilt:45*!dtor}
par5={crystal:'bbo',thickness:1e-3,lambda:lam*1e-9,facetilt:45*!dtor}

nwav1a=opd(thx2,thy2,par=par2,delta=!pi*1/4)/2/!pi
nwav1b=opd(thx2,thy2,par=par3,delta=!pi*1/4)/2/!pi
nwav1=nwav1a+nwav1b
nwav2=opd(thx2,thy2,par=par4,delta=!pi*3/4)/2/!pi
nwav3=opd(thx2,thy2,par=par5,delta=!pi/4)/2/!pi
nwav=nwav1+nwav2-nwav3
;if kk eq 0 then nwavr=nwav
;if kk eq 1 then nwavs=nwav

if kk eq 0 then nwavstore=dblarr(nx,ny,nlines+1)
nwavstore(*,*,kk)=nwav
endfor




pat=dcomplexarr(nx,ny)
pint=pat
for kk=0,nlines-1 do begin
pat = pat + exp(dcomplex(0,1)*2*!dpi*nwavstore(*,*,kk))*f(*,*,kk)
pint=pint + f(*,*,kk)
endfor
pref=exp(dcomplex(0,1)*2*!dpi*nwavstore(*,*,nlines))

dif=atan2(pat/pref)*!radeg
zeta=abs(pat)/abs(pint)
contourn2,zeta,nl=30
stop
imgplot,dif,/iso,/cb
stop
;gencarriers2,sh=sh,th=[0,0]

;,mat=mat,kx=kx,ky=ky,kz=kza,dkx=dkx,dky=dky,p=p,str=str,/noload,frac=frac,indexlist=indexlist,lam=lam,stat=stat,slist=slist,dmat=dmat,quiet=quiet,nstates=nstates
dif=nwavs-nwavr
plotm,dif
pos=posarr(2,2,0)
wset,1
imgplot,dif,/cb,pos=pos
wset,0


imgplot,cos(2*!pi*nwavr),/iso,pos=pos
imgplot,cos(2*!pi*nwavs),/iso,pos=posarr(/next),/noer

meas=getimgnew('calibration 9 29-10-2013',0,db='h')*1.0 - $
     getimgnew('calibration 10 29-10-2013',0,db='h')*1.0 

imgplot,meas,indgen(512),indgen(128)*4,/cb,pos=posarr(/next),/iso,/noer
plas=getimgnew(81138,20,db='h')*1.0 
imgplot,plas,indgen(512),indgen(128)*4,/cb,pos=posarr(/next),/iso,/noer
end
