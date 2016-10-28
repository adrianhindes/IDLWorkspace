@newdemodflclt
@newcmpmseefit
;@getptsnew
;goto,af

;goto,ee

;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype
sh=7485
ifr=frameoftime(sh,2.5)&only2=1&demodtype='basicd'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2

ang1-=18.
;stop

newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1,str=p,gfile='/home/cam112/idl/g007485.002500'

end
