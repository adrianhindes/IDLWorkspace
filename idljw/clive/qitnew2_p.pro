pro getp,ii,pscal,cscal,kz
;sh=8044 
;lam=656e-9
;sh='cxrstestb4';74;8;l74;94;88;74
;sh='cxrstesta100mmp5ap2';74;8;l74;94;88;74
;sh='cxrstestc4';2';74;8;l74;94;88;74
;sh='cxrstestc42';2';74;8;l74;94;88;74
;sh='cxrstestd42';74;8;l74;94;88;74
;sh='cxrstestbb4new';2'
;sh='edge_cal'
;sh='cxrstesta100mmp5ap2'
;sh='cxrstestp5ap'
;imw=0

imw=ii mod 193
ima=ii/193
sarr=['','@0001','@0002','@0003','@0004']
;sh=;'tst2@0001'
suff=sarr(ima)
sh='tst2'+suff



;shb=sh+'_black'
shb='cxrstestd4_black'
dum=file_search('~/rsphy/kstartestimages'+shb+'.tif',count=cnt)
if cnt eq 0 then shb='cxrstestp5ap_black'
lam=529e-9
doplot=0


;svec=[1,1/sqrt(2),1/sqrt(2),0]
;tt=-11.5*!dtor*0+
if sh eq 'edge_cal' then tt=11.5*2 - 22.5 else tt=22.5
if strmid(sh,0,9) eq 'cxrstestp' then tt=90.+22.5
if strmid(sh,0,15) eq 'cxrstesta100mmp' then tt=90.+22.5

tt*=!dtor

svec=[1,cos(2*tt),sin(2*tt),0]
;svec=[1,1,0,0]
;svec=[1,0,-1,0]

;simimgnew,simg,sh=sh,lam=lam,svec=svec
;myroi=[651,2080,341,1820]
myroi=[2560/2 + [ -127,128],2160/2 + [-127,128]]
simga=getimgnew(sh,imw,info=info,/getinfo,str=p,roi=myroi)*1.0
simgb=getimgnew(shb,0,roi=myroi)*1.0
simg=simga-simgb
demodtype='basicd42'
;demodtype='basicd3'

readdemodp,demodtype,sd
readcell,p.cellno,str

newdemod,simg,cars,sh=sh,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=p,doplot=doplot,thx=thx,thy=thy,/noload,sd=sd,str=str
lam=529e-9
;stop
gencarriers2,th=[0,0],sh=sh,mat=mat,dmat=dmat,kz=kz,lam=lam,kx=kx,ky=ky,dkx=dkx,dky=dky,p=p

iz=(where(kz eq 0))(0)
nn=n_elements(kz)
carsb = cars/replarr(abs(cars(*,*,iz)),nn)

contrast=abs(carsb)

amp = reform(abs(dmat ## svec) )
amp=amp/amp(iz)

print,abs(amp)

for i=0,nn-1 do contrast(*,*,i)/=amp(i)

pos=posarr(2,3,0)
erase
for i=0,nn-1 do begin
if kz(i) ne 0 then imgplot,contrast(*,*,i),thx*!radeg,thy*!radeg,title=kz(i),pos=pos,/noer,/cb
oplot,[-4,4,4,-4,-4],[-4,-4,4,4,-4],col=2


pos=posarr(/next)
endfor
sz=size(contrast,/dim)
plot,kz,contrast(sz(0)/2,sz(1)/2,*),pos=pos,/noer

pscal=atan2(carsb(sz(0)/2,sz(1)/2,*))
cscal=contrast(sz(0)/2,sz(1)/2,*)


end
goto,ee
;iarr=fix(linspace(200,900,71))
iarr=fix(linspace(200,900,70*4+1))

n=n_elements(iarr)

nd=4
parr=fltarr(nd,n)
carr=parr

for i=0,n-1 do begin
getp,iarr(i),p,c
parr(*,i)=p
carr(*,i)=c
endfor
ee:
mkfig,'~/rsphy/stability.eps',xsize=27,ysize=18,font_size=12
pp=parr
for i=0,n-1 do for j=0,3 do pp(j,i)-=parr(j,0)
pp=phs_jump(transpose(pp))
plotm,iarr/60.,pp*!radeg,pos=posarr(1,2,0,cny=0.1),psym=-4,title='phase',xtitle='time (hours)'
plotm,iarr/60.,transpose(carr),pos=posarr(/next),/noer,title='contrast',xtitle='time (hours)'
legend,string(kz),textcol=[1,2,3,4],/right
endfig,/gs,/jp
end
