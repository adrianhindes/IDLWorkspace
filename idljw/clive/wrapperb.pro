goto,ee

which='old' & dofilt=1.
;sh=87801 & dt=0.01/5 ; 260

;sh=87793 & dt=0.01/5;tw=[.03,.04]; 250 ; outward flux during dithering, inwar dspike at crash
;sh=87792 & dt=0.01/5;tw=[.03,.04]; 240 inward flux few 1019 in dithering state
;which='new'

sh=87780 & dt=0.01/5;tw=[.03,.04]; 230 loutward flux in downward
;dithering state ~ 1e18 in dithering. out.

;sh=87846 & dt=0.01/5 & which='old' & dofilt=1;tw=[.03,.04]; 250 with poloidal scan

sh=88533 & dt=0.01/5 & which='new' & dofilt=1


t=linspace(.005,.095,10*5)
nt=n_elements(t)
flux=fltarr(nt)
for i=0,nt-1 do begin
myflux2,sh,t(i),dt,dum,which=which,dofilt=dofilt,noplot=0 & flux(i)=dum
print,i,t(i),dum
endfor
ee:
dum= getpar( sh, 'isat', tw=[0,.1],y=y)

dum= getpar( sh, 'lint', tw=[0,.1],y=interf)


mdsopen,'h1data',sh
ihel=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_sec',/nozero)
imain=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_main',/nozero)
kappa={t:interf.t,v: interpol(ihel.v,ihel.t,interf.t) /  interpol(imain.v,imain.t,interf.t)}


mkfig,'~/fluxkvdiff.eps',xsize=15,ysize=18,font_size=10

plot,interf.t,interf.v>0,xr=[0,.1],pos=posarr(1,3,0,cnx=0.1,cny=0.1,msraty=7),ysty=8,xtickname=replicate(' ',10),title=textoidl('Line av. density & \kappa_h'),ytitle=textoidl('n_e (10^{18} m^{-3})')


plot,kappa.t,kappa.v,xr=[0,.1],pos=posarr(/curr),/ynozero,yr=[.67,.76],xsty=4,ysty=4,col=2,/noer
axis,!x.crange(1),!y.crange(0),yaxis=1,ytitle=textoidl('\kappa_h'),col=2


plot,y.t,y.v>0,/noer,xr=!x.crange,pos=posarr(/next),xtickname=replicate(' ',10),title=textoidl('I_{sat} @ R=132cm (\rho=0.7)'),ytitle='A'

plot,t,-flux/1e18,psym=-4,pos=posarr(/next),/noer,yr=[-1,10],ysty=1,title='Fluctuation-driven and total flux',ytitle=textoidl('\Gamma (10^{18} m^{-2}s^{-1})'),thick=2,xtitle='time (s)'
oplot,!x.crange,[0,0],linesty=2

;plot,t,flux,psym=-4,col=2,/noer,pos=posarr(/next)


tspec=(gettiming(sh,nameunit='greg')  -1400.) / 1000.
read_spedb,sh,lam,t,d,str=str
lam=reverse(lam)
idx=where(lam ge 655.8 and lam le 656.8)

halpha=totaldim(d(idx,3:13,*),[1,1,0]) 

halpha=halpha-halpha(0)
halpha = halpha / halpha(3) * 6e17 * 3
;plot,tspec,halpha,psym=-4,pos=posarr(/next),/noer,xr=!x.crange

oplot,tspec,halpha/1e18,psym=-4,col=2,thick=2


endfig,/gs,/jp

end



