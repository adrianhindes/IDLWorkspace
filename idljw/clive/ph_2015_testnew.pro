;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100

sh='testa'
ifr=0
doplot=1
img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0

newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz


end

