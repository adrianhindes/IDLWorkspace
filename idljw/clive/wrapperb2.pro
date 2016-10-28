sh=87055
ee:
dum= getpar( sh, 'isat', tw=[0,.1],y=y)

dum= getpar( sh, 'lint', tw=[0,.1],y=interf)


mdsopen,'h1data',sh
ihel=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_sec',/nozero)
imain=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_main',/nozero)
kappa={t:interf.t,v: interpol(ihel.v,ihel.t,interf.t) /  interpol(imain.v,imain.t,interf.t)}


mkfig,'~/fluxkvdiff2.eps',xsize=9,ysize=9,font_size=8

plot,interf.t,interf.v>0,xr=[0,.1],pos=posarr(1,3,0,cnx=0.1,cny=0.1,msraty=7),ysty=8,xtitle='time (s)',title=textoidl('Line av. density & \kappa_h'),ytitle=textoidl('n_e (10^{18} m^{-3})')


plot,kappa.t,kappa.v,xr=[0,.1],pos=posarr(/curr),/ynozero,yr=[.48,.6],xsty=4,ysty=4,col=2,/noer
axis,!x.crange(1),!y.crange(0),yaxis=1,ytitle=textoidl('\kappa_h'),col=2,yticklen=1,ygridstyle=2


 plot,y.t,y.v>0,/noer,xr=!x.crange,pos=posarr(/curr),xtickname=replicate(' ',10),xsty=4,ysty=4,col=4,thick=2,yr=[0,.05];,title=textoidl('I_{sat} @ R=132cm (\rho=0.7)'),ytitle='A'

;; plot,t,-flux/1e18,psym=-4,pos=posarr(/next),/noer,yr=[-1,10],ysty=1,title='Fluctuation-driven and total flux',ytitle=textoidl('\Gamma (10^{18} m^{-2}s^{-1})'),thick=2,xtitle='time (s)'
;; oplot,!x.crange,[0,0],linesty=2

;; ;plot,t,flux,psym=-4,col=2,/noer,pos=posarr(/next)


;; tspec=(gettiming(sh,nameunit='greg')  -1400.) / 1000.
;; read_spedb,sh,lam,t,d,str=str
;; lam=reverse(lam)
;; idx=where(lam ge 655.8 and lam le 656.8)

;; halpha=totaldim(d(idx,3:13,*),[1,1,0]) 

;; halpha=halpha-halpha(0)
;; halpha = halpha / halpha(3) * 6e17 * 3
;; ;plot,tspec,halpha,psym=-4,pos=posarr(/next),/noer,xr=!x.crange

;; oplot,tspec,halpha/1e18,psym=-4,col=2,thick=2


endfig,/gs,/jp

end



