restore,file='~/cntr.sav'
restore,file='~/co.sav'
istore1=1000L
i=value_locate(r,0.1)
i2=value_locate(r,0.2)
t=t(0:istore1-1)
mkfig,'~/cocntsim.eps',xsize=8,ysize=8,font_size=10
plot,t,-difstore(i,0:istore1-1),yr=[0,2.5],xtitle='time (s)',title='current density @R=0.1m'
;oplot,t,-difstore(i2,0:istore1-1),linesty=2
restore,file='~/cntr.sav'
t=t(0:istore1-1)
oplot,t,-difstore(i,0:istore1-1),col=2
legend,['co','counter'],textcol=[1,2],box=0,/right,charsize=2
endfig,/gs,/jp
end

