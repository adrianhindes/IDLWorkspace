fn1='~/magwell_kh0.72_large';Filter_type_4'
fn2='~/iotabar_kh0.72_large'
restore,file=fn2+'.sav',/verb
mkfig,'~/magconfh1.eps',xsize=9,ysize=15,font_size=9 & !p.thick=3
plot,x,y,/yno,pos=posarr(1,2,0,cnx=0.1,cny=0.1),title=textoidl('\iota'),xtitle='<r> (m)',/nodata


xx=[.17,.2,.2,.17,.17]

xx2=[.2,.25,.25,.2,.2]

yy=[!y.crange(1),!y.crange(1),!y.crange(0),!y.crange(0),!y.crange(1)];2,2,-6,-6,2]
polyfill,xx,yy,col=5
polyfill,xx2,yy,col=3


oplot,x,y

oplot,!x.crange,4./3. *[1,1],linesty=2

oplot,!x.crange,7./5. *[1,1],linesty=2

;oplot,0.2*[1,1],!y.crange,linesty=2

restore,file=fn1+'.sav',/verb
plot,x,-y,/yno,/noer,col=1,pos=posarr(/next),title=textoidl('Magnetic well (%)'),xtitle='<r> (m)',/nodata

yy=[!y.crange(1),!y.crange(1),!y.crange(0),!y.crange(0),!y.crange(1)];

polyfill,xx,yy,col=5
polyfill,xx2,yy,col=3

oplot,x,-y
;oplot,!x.crange,0. *[1,1],col=1

;oplot,0.2*[1,1],!y.crange,linesty=2
endfig,/gs,/jp & !p.thick=0

end
