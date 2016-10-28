shref=9249
tarr=0.6


ifr=frameoftime(shref,tarr,db='k')&only2=1&demodtype=shref gt 8000 ? 'sm32013mse' : 'basicd'
newdemodflclt,shref, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,lut=lut,/doplot


newdemodflclt,9243,frameoftime(9243,0.34,db='k') ,dopc=dopc2,angt=ang2,eps=eps2,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,lut=lut,/doplot

ph1=exp(complex(0,1)*dopc1*!dtor)
ph2=exp(complex(0,1)*dopc2*!dtor)
ph21=ph2/ph1
dopc21=atan2(ph21)*!radeg




;,/cacheread,/cachewrite
;ang1b=ang1



;befit1,sh,0.34, 1.1,field=2.8
;befit1,sh,0.6, 1.1,field=2.8,shref=9245


end
