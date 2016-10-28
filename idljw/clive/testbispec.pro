@pr_prof2
fsamp=1e6

npts=1e4

t=findgen(npts)*1/fsamp

freq=20e3
y=sin(2*!pi*freq*t)
y2=y^10
noise=randomn(sd,npts)*0.01

y2=y2+noise

tr=[0.02,0.03]
;sh=[82823,intspace(82811,82819)]
;82811		1.36
;82812		1.300
;82813		1.270
;82814		1.240
;82815		1.210
;82816		1.255
;82817		1.285
;82818		1.315
;82819		1.345

;dum=getpar(82676,'isat',y=ys,tw=tr)
;dum=getpar(82837,'isat',y=ys,tw=tr)

;goto,af
;dum=getpar(82136,'isat',y=ys,tw=tr)
dum=getpar(82141,'isat',y=ys,tw=tr)
idx=where(ys.t ge tr(0) and ys.t lt tr(1))
y2=ys.v(idx)
t=ys.t(idx)
npts=n_elements(t)
af:

plot,t,y2,xr=[0,200e3]
f=fft_t_to_f(t)
s=fft(y2)
plot,f,abs(s),/ylog
;stop
fr=[0,100e3]*2
;dum=temporary(fr)
mkfig,'~/bcoh1.eps',xsize=20,ysize=20,font_size=12
bi=bi_spectrum(y2,n_seg=npts/20,dt=1/fsamp,f=f2,/img,Pj=s2)
imgplot,abs(bi),f2/1e3,f2/1e3,/cb,xr=fr/1e3,yr=fr/1e3,title=textoidl('B(f_1,f_2)'),xtitle=textoidl('f_1 (kHz)'),ytitle=textoidl('f_2 (kHz)'),offx=1,/rev,pal=5,/iso

endfig,/gs,/jp
stop

;mkfig,'~/bcoh2.eps',xsize=
;dum=posarr(/next)
plot,f2,alog10(s2),pos=posarr(/next),/noer,xr=fr,yr=[-9,-4],xtitle='f',title='Power spectrum'
sbi=bi_spectrum(y2,n_seg=npts/20,dt=1/fsamp)
plot,f2,sbi,pos=posarr(/next),/noer,xr=fr,xtitle='f',title='Sum bicoherence'
endfig,/gs,/jp

end
