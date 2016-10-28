;sh=8044 
;lam=656e-9
;sh='cxrstestb4';74;8;l74;94;88;74
sh='cxrstestp6';74;8;l74;94;88;74
lam=529e-9

svec=[1,1/sqrt(2),1/sqrt(2),0]
svec=[1,1,0,0]
;svec=[1,0,-1,0]

;simimgnew,simg,sh=sh,lam=lam,svec=svec
simga=getimgnew(sh,0,info=info,/getinfo)*1.0
simgb=getimgnew('cxrstestb4_black',0,info=info,/getinfo)*1.0
simg=simga-simgb

newdemod,simg,cars,sh=sh,lam=lam,/doplot,demodtype='basicd4',ix=ix,iy=iy,p=str
lam=529e-9
stop
gencarriers2,th=[0,0],sh=sh,mat=mat,dmat=dmat,kz=kz,lam=lam,kx=kx,ky=ky,dkx=dkx,dky=dky,p=p

iz=(where(kz eq 0))(0)
nn=n_elements(kz)
carsb = cars/replarr(abs(cars(*,*,iz)),nn)

contrast=abs(carsb)

amp = reform(abs(dmat ## svec) )
amp=amp/amp(iz)

for i=0,nn-1 do contrast(*,*,i)/=amp(i)
plot,contrast(140,120,*)
pos=posarr(2,2,0)
erase
for i=0,nn-1 do begin
imgplot,contrast(*,*,i),title=kz(i),pos=pos,/noer
pos=posarr(/next)
endfor
sz=size(contrast,/dim)
plot,kz,contrast(sz(0)/2,sz(1)/2,*),pos=posarr(/next),/noer

         kmult= $; fringes/deg
            1/!dtor* $; /rad
            1/p.flencam* $; per mm on detector
            6.5e-3*p.bin ; per binned pixel

print,kz
print,kx*kmult
print,ky*kmult

;calcmet,[kz(1:*)],met
stop

print,'dky/dkx=',dky/dkx,'dkx=',dkx*kmult,'dky=',dky*kmult



;-1 =  savart
;1=bbo
;2=ln
cdb=[$
[1,6.,45],$
[1,5.,30],$
[1,7.5,35],$
[1,5,45],$
[1,4,45],$
[1,3,45],$
[-1,2,45],$
[-1,2.5,45],$
[2,1.,45],$
[-2,2,45],$
[1,2.2,0],$
[1,1.0,0],$
[1,2.0,0],$
[2,0.6,0],$
[2,2.0,0]]


end
