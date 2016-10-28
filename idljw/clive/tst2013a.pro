;@getptsnew
;goto,af



;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype


sh=9098&ifr=frameoftime(sh,3.28)&only2=1&demodtype='basic2013mse'
newdemodflc,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2

;sh=9098&ifr=frameoftime(sh,3.28)&only1=1&only2=0&demodtype='basic2013mse'
;newdemodflc,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2

;sh=9098&ifr=frameoftime(sh,3.32)&only1=1&only2=0&demodtype='basic2013mse'
;newdemodflc,sh, ifr,dopc=dopc1,angt=ang1c,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2

sz=size(ang1,/dim)
imgplot,dopc1,/cb

;plot,ang1(*,sz(1)/2)
;oplot,ang1b(*,sz(1)/2),col=2
;oplot,ang1c(*,sz(1)/2),col=3


;plotm,ang1



end
