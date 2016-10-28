which='old' & dofilt=1.
;sh=87801 & dt=0.01/5 ; 260

;sh=87793 & dt=0.01/5;tw=[.03,.04]; 250 ; outward flux during dithering, inwar dspike at crash
;sh=87792 & dt=0.01/5;tw=[.03,.04]; 240 inward flux few 1019 in dithering state
;which='new'

sh=87780 & dt=0.01/5;tw=[.03,.04]; 230 loutward flux in downward
;dithering state ~ 1e18 in dithering. out.

;sh=87846 & dt=0.01/5 & which='old' & dofilt=1;tw=[.03,.04]; 250 with poloidal scan

;sh=88533 & dt=0.01/5 & which='new' & dofilt=1


sharr=[87729,87730,87731]
sh=sharr(0)

dum= getpar( sh, 'isat', tw=[0,.1],y=y)

dum= getpar( sh, 'lint', tw=[0,.1],y=interf)


mdsopen,'h1data',sh
ihel=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_sec',/nozero)
imain=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_main',/nozero)
kappa={t:interf.t,v: interpol(ihel.v,ihel.t,interf.t) /  interpol(imain.v,imain.t,interf.t)}


mkfig,'~/tex/ishw/density_power.eps',xsize=9.5,ysize=15,font_size=8
;
plot,interf.t,interf.v>0,xr=[0,.12],pos=posarr(1,4,0,cnx=0.1,cny=0.1,msraty=7,fx=0.5),xtickname=replicate(' ',10),title=textoidl('Line av. density, power scan'),ytitle=textoidl('n_e (10^{18} m^{-3})'),xsty=1,yr=[0,2]

legend,['20kW','31kW','40kW'],col=[1,2,3],textcol=[1,2,3],/right,/bottom,box=0

for i=1,2 do begin
   dum= getpar( sharr(i), 'lint', tw=[0,.1],y=interf)
   oplot,interf.t,interf.v>0,col=i+1
endfor


;plot,kappa.t,kappa.v,xr=[0,.12],pos=posarr(/next),/ynozero,yr=[.67,.83],xsty=1,ysty=1,col=1,/noer,thick=4
;axis,!x.crange(1),!y.crange(0),yaxis=1,ytitle=textoidl('\kappa_h'),col=2,yticklen=1,ygridstyle=2,ysty=1


n=n_elements(sharr)
for i=0,n-1 do begin
   dum= getpar( sharr(i), 'isat', tw=[0,.1],y=y)
if i eq 0 then $
   plot,y.t,y.v>0,/noer,xr=!x.crange,pos=posarr(/next),title=textoidl('I_{sat}, R=1.32m, power scan '),ytitle='A',xsty=1,ysty=1,yr=[0,.11],xtickname=replicate(' ',10) $
else $
   oplot,y.t,y.v,col=i+1

endfor
legend,['20kW','31kW','40kW'],col=[1,2,3],textcol=[1,2,3],/right,/bottom,box=0

plot,kappa.t,kappa.v,xr=[0,.12],pos=posarr(/next),/ynozero,yr=[.7,.83],xsty=1,ysty=1,col=1,/noer,title=textoidl('\kappa_h'),yticklen=1,ygridstyle=1,xtickname=replicate(' ',10)
;axis,!x.crange(1),!y.crange(0),yaxis=1,ytitle=textoidl('\kappa_h'),col=2,yticklen=1,ygridstyle=2,ysty=1

;endfig,/gs,/png

end



