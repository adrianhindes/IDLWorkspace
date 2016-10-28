;sh=11066
sh=11433
demodtype='smp2013mse';sm32013mse
;demodtype='sm32013mse';sm32013mse
;tr=[2,10]
tr=[2,6]
;newdemodflcshot, sh, tr,/only2,res=res,nskip=1,demodtype=demodtype,cacheread=1,cachewrite=1&res.ang=-(res.ang - 27.) 
;!x.margin=15
pos=posarr(1,2,0,cnx=0.1)
imgplot,transpose(reform(res.ang(*,36,*))),res.t,findgen(n_elements(res.ang(*,0,0))),/cb,zr=[-5,5]-30,offx=1.,pos=pos,yr=[0,500]

mdsopen,'kstar',sh
d=mdsvalue2('.KSTAR:HALPHA')
mdsclose
plot,d.t,d.v,xr=!x.crange,pos=posarr(/next),/noer
end
