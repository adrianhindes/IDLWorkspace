
lut=1
db='k'
;sh=9323 & twant=0.925 & multiplier=1
;sh=9955 & twant=2.38 & multiplier=4 ; beam3 new campgin

;sh=10536 & twant=0.9 & multiplier=1

;sh=10536 & twant=10.64 +0.04*0& multiplier=1&db='kl' ; one recomended by ntm eccdguy (young)

;sh=10536 & twant=0.92& multiplier=1&db='kl' ; one recomended by ntm eccdguy (young)

;sh=10502 & twant=14.0 & multiplier=1&db='kl' ; biam ingo gas
;sh=10502 & twant=8.6 & multiplier=1 ; biam ingo gas

;sh=33 & twant = 2. & multiplier=1 & db='kcal2014'

;sh=9328 & twant=0.82 & multiplier=1 ; beam 2 into gas last campaign
;sh=9332 & twant=0.82 & multiplier=1 ; beam 2 into gas last campaign vf -6ka
;sh=9328 & twant=0.54 & multiplier=1 ; beam 1 into gas last campaign

;sh=9958 & twant=1.04 & multiplier=3 ; beam2

;sh=9998 & twant=3.10 & multiplier=3 ; beam 2 new campaign

;sh=10560 & twant=0.92 & multiplier=1 & db='kl'

;sh=9892 & twant=0.95 & multiplier=1 ; pol in


;sh=9880 & twant=3.36 & multiplier=1 ; first shot

;sh=9943 & twant=0.8 & multiplier=1  ; ok b3 early one

;sh=9414 & twant=6.425 & multiplier=1 ; b2 old campaign

;sh=11080 & twant=0.7 & multiplier=1

;sh=10536 & twant = 10.64 & multiplier=1 ; early efit test



sh=11004 & twant=1.95 & multiplier=1 ; eccdconter
;sh=11082 & twant = .4 & multiplier=1 ; matthew#5
;sh=11082 & twant = 1.525 & multiplier=1 ; matthew#5


;sh=11006 & twant = 0.3 & multiplier=1 ; beam into gas

 newdemodflclt,sh,twant=twant,multiplier=multiplier,/only2,demodtype='sm32013mse',lut=lut,/noid2,angt=ang,dostop=0,db=db,doplot=0,inten=inten,lin=lin,dopc=dopc,/cachewrite

sz=size(ang,/dim)
offset=ang(sz(0)/2,sz(1)/2) 
offset=7.69

;offset=-12.43
imgplot,ang-offset,/cb,pal=-2,zr=[-10,10],pos=posarr(2,1,0)

plot,ang(*,sz(1)/2)-offset,pos=posarr(/next),/noer
;plotm,ang
print,offset
end
