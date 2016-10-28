;sh=8052;3;46
;ifr=155
;seq='8'

pro doit, seq,sim,pdif,psum,noplot=noplot,ovr=ovr,laovr=laovr


demodtype='basicnofull2'

if seq eq '1' then begin
sh=5;9;6;5
ifr=0

shr=4;10;5;4
ifrr=0
db='t5b'
ia=2
ib=3
pbfact=1.
endif

if seq eq '2' then begin


sh=112 & ifr=4
shr=113 & ifrr=4
db='t5sc' & pbfact=-1 & ia=1
endif

if seq eq '3' then begin
sh=44 & ifr= 0 & db='kcal2015'; psh h/ne
shr = 49 & ifr=0 & ia=1 & ib=3 & pbfact=1
endif

if seq eq '4' then begin
sh=46 & ifr= 0 & db='kcal2015'; ash h/ne
shr = 50 & ifrr=0 & ia=1 & ib=3 & pbfact=1
la = 656.11e-9
lb=659.89e-9
endif

if seq eq '5' then begin
sh=43 & ifr= 0 & db='kcal2015' ; ash d/ne
shr = 50 & ifrr=0 & ia=1 & ib=3 & pbfact=1;-1
la = 656.28e-9
lb=659.89e-9
endif

if seq eq '6' then begin
sh=43 & ifr= 0 & db='kcal2015' ; ash h/d
shr = 46 & ifrr=0 & ia=1 & ib=3 & pbfact=1

la = 656.28e-9
lb = 656.11e-9

endif

if seq eq '6a' then begin
sh=42 & ifr= 0 & db='kcal2015' ; psh h/d
shr = 44 & ifrr=0 & ia=1 & ib=3 & pbfact=1
la=656.11e-9
lb=656.280e-9
endif

if seq eq '7' then begin
sh=55 & ifr=0 & db='kcal2015' ; laser extremes
shr = 59 & ifrr=0 & ia=1 & ib=3 & pbfact=1
la = 656.530e-9
lb=  656.329e-9
endif

if seq eq '8' then begin
sh=38 & ifr= 0 & db='kcal2015' ; ne lines
shr = 40 & ifrr=0 & ia=1 & ib=3 & pbfact=1
la=667.82766e-9
lb=659.89e-9
demodtype='basicfull2'
endif

if keyword_set(ovr) then sh=ovr
if keyword_set(laovr) then la=laovr*1e-9
dbtrue='kcal2015t'

doplot=0
if sim eq 0 then img=getimgnew(sh,db=db,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0

if sim eq 1 then simimgnew,img,sh=sh,db=dbtrue,lam=la,svec=[2.2,1,1,.2];,/angdeptilt


newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz;,/doload;,/cachewrite,/cacheread

;stop
if sim eq 0 then imgr=getimgnew(shr,db=db,ifrr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
if sim eq 1 then simimgnew,imgr,sh=shr,db=dbtrue,lam=lb,svec=[2.2,1,1,.2];

newdemod,imgr,carsr,sh=shr,ifr=ifrr,db=db,lam=la,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz;,/doload;,/cachewrite,/cacheread


; carsr = carsr + cars ; 50/50 h/d
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)*(pbfact)

paj=pa
pbj=pb
;stop
jumpimg,paj
jumpimg,pbj

pdif=paj-pbj
psum=(paj+pbj)


polang=pdif/4*!radeg


;pdif = pdif+!pi/2 
ny=n_elements(pdif(0,*))
;plot,pdif(*,ny/2)*!radeg

sz=size(pdif,/dim)
cx=sz(0)/2
cy=sz(1)/2

polangc=polang(cx,cy)
dpolang=polang-polangc

if  keyword_set(noplot) then return
imgplot,pdif,/cb,pal=-2
stop
imgplot,dpolang,/cb,pal=-2,zr=[-10,10]

print,'polang c is',polangc
print,'actual ang is',ang-angr,ang,angr

end

pro docmp, seq
doit,seq,0,exp,/noplot
doit,seq,1,sim,/noplot
mkfig,'~/cmp.eps',xsize=25,ysize=12
contourn2,exp,lev=lev,pal=-2,pos=posarr(2,1,0),/iso
contour,sim,lev=lev,/overplot,c_lab=replicate(1,100)
ang=(10-45)*!dtor
sz=size(exp,/dim)

iy=findgen(sz(1))
ix=sz(0)/2 + (iy-sz(1)/2) * tan(ang)
oplot,ix, iy

plot,exp[ix,iy],pos=posarr(/next),yr=minmax2([exp[ix,iy],sim[ix,iy]]),/noer
oplot,sim(ix,iy),col=2
endfig,/gs,/jp
stop
end

;goto,ee
pro docmp2, seq
seq='7'
doit,seq,0,dum,exp,/noplot,ovr=55
doit,seq,0,dum,exp2,/noplot,ovr=57
doit,seq,0,dum,exp3,/noplot,ovr=61
doit,seq,0,dum,exp4,/noplot,ovr=42
eea:
doit,seq,0,dum,exp5,/noplot,ovr=44

sz=size(exp,/dim)

sz2=sz/2
y=[exp[sz2(0),sz2(1)],exp2[sz2(0),sz2(1)],0,exp3[sz2(0),sz2(1)], exp4[sz2(0),sz2(1)],exp5[sz2(0),sz2(1)] ]
x=[656.530, 656.449, 656.329, 656.513, 656.11,656.281]
ee:
ysim=y*0
for i=0,5 do begin
quickdelof,'del2',lam=x(i)*1e-9,del=del,/doprint & ysim(i)=del*2* 2 * 2*!pi
endfor
ysim=- (ysim - ysim(2))


mkfig,'~/disp_cal.eps',xsize=12,ysize=10,font_size=9
plot,x,y,psym=4,yr=[-3,3],xtitle='wavelength/nm',ytitle='sum phase/rad'

;dum=linfit(x,y,yfit=yfit)
;oplot,x,yfit
oplot,x,ysim,col=2,psym=5
endfig,/gs,/jp
stop
end

