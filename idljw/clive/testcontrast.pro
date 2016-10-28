 shref=13438 & ifrref=500 & dbref='k'
 shref=14367 & ifrref=0 & dbref='kcal'


 shref=90060 & ifrref=30 & dbref='k'

for ifrref=0,99  do begin

;shref=82 & ifrref=1+2*0  & dbref='kcal2015'

;shref=70 & ifrref=1+2*0 & dbref='kcal2015'

;shref=90020 & ifrref=1+2*0  & dbref='kcal2015'

demodtyper='basicnofull2r'

imgref=getimgnew(shref,ifrref,db=dbref)

doplot=0
cacheread=0
cachewrite=0

newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=dbref,lam=lam,doplot=doplot,demodtype=demodtyper,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,doload=0,cachewrite=cachewrite,cacheread=cacheread ;,/onlyplot


  ia=1
  ib=3
  ic=2

zetaa=abs(carsr(*,*,ia)/carsr(*,*,0))
zetab=abs(carsr(*,*,ib)/carsr(*,*,0))

imgplot,zetaa,pos=posarr(2,1,0),zr=[0,.2],/cb,title=ifrref
imgplot,zetab,pos=posarr(/next),/noer,/cb,zr=[0,.2]
endfor


end
