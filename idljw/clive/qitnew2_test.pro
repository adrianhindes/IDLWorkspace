dorot=0
;sh=8044 
;lam=656e-9
;sh='cxrstestb4';74;8;l74;94;88;74
;sh='cxrstesta100mmp5ap2';74;8;l74;94;88;74
sh='cxrstestc42';85  
;sh='cxrstestc42';2';74;8;l74;94;88;74
;sh='cxrstestd42';74;8;l74;94;88;74
;sh='cxrstestbb4new3' &dorot=1
;sh='edge_cal'
;sh='cxrstesta100mmp5ap2'
;sh='cxrstestp5ap'
sh='tst3'

;sh='cxrstesttt4'
sh='cxrstest4z'
imw=0

;imw=100

;shb=sh+'_black'
shb='cxrstestc4_black'
;dum=file_search('~/rsphy/kstartestimages'+shb+'.tif',count=cnt)
;if cnt eq 0 then shb='cxrstestp5ap_black'
;lam=529e-9
lam=529e-9
doplot=1


;svec=[1,1/sqrt(2),1/sqrt(2),0]
;tt=-11.5*!dtor*0+
if sh eq 'cxrstesttt4' then tt=-45 ; last pol at 22.5
if sh eq 'cxrstest4z' then tt=-22.5 ; last pol at 45
if sh eq 'cxrstest4y' then tt=-22.5 ; last pol at 45



tt*=!dtor

svec=[1,cos(2*tt),sin(2*tt),0]
;svec=[1,1,0,0]
;svec=[1,0,-1,0]

simimgnew,simg,sh=sh,lam=lam,svec=svec
;myroi=[651,2080,341,1820]
;myroi=[2560/2 + [ -127,128],2160/2 + [-127,128]]
;delvar,myroi
;simga=getimgnew(sh,imw,info=info,/getinfo,str=p,roi=myroi)*1.0
;simgb=getimgnew(shb,0,roi=myroi)*1.0
;simg=simga;-simgb
;if dorot eq 1 then simg=rotate(simg,7)
demodtype='basicd43'
;demodtype='basicd32'

readdemodp,demodtype,sd
readpatch,sh,p
readcell,p.cellno,str
newdemod,simg,cars,sh=sh,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=p,doplot=doplot,thx=thx,thy=thy,/noload,sd=sd,str=str
;lam=529e-9
;stop
gencarriers2,th=[0,0],sh=sh,mat=mat,dmat=dmat,kz=kz,lam=lam,kx=kx,ky=ky,dkx=dkx,dky=dky,p=p

iz=(where(kz eq 0))(0)
;nn=n_elements(kz)
;carsb = cars/replarr(abs(cars(*,*,iz)),nn)

;contrast=abs(carsb)

amp = reform(abs(dmat ## svec) )
amp=amp/abs(amp(iz))

print,abs(amp)
print,kz

end
