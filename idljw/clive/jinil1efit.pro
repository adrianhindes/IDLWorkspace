@newcmpmmseefit
;@getptsnew
;goto,af

;goto,ee

;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype
sh=9243
ifr=frameoftime(sh,0.34)&only2=1&demodtype='sm32013mse'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,/cacheread

tarr=0.5 + 0.4 * 4
ifr=frameoftime(sh,tarr)&only1=1&only2=0
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2,/cacheread
   
ang1b-=12.
ang1b*=-1
;newmakeefitnl,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,wt=1,drcm=6
;runefit1,sh=sh,tw=tarr

newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr



end
