sh=86418
sh=87837
loadinterf,sh,d,dt=dt,t0=t0,/pmt
d=d>0
;t=mdsvalue('DIM_OF(\H1DATA::TOP.ELECTR_DENS.CAMAC:A14_22:INPUT_2)')
t=findgen(n_elements(d(*,0)))*dt+t0

p1=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_4')
p2=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_6')
tt=mdsvalue('DIM_OF(\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_5)')

dum= getpar(sh, 'isat', tw=[0,.01],y=p1p)
dum= getpar(sh, 'isatfork', tw=[0,.01],y=p2p)


xr=.0684+[0,0.0003];,.0720]
xr=.0273+[0,.001]
;xr=.0503+[0,.001]
xr=[15e-3,25e-3]
xr=[18e-3,29e-3]
xr=[22e-3,24e-3]+1e-3
xr=[22e-3,23e-3]+1e-3

mkfig,'~/tex/ishw/pmtsigs_sm.eps',xsize=8,ysize=6,font_size=6.5
plot,tt,p1p.v,xr=xr,pos=posarr(1,2,0,msraty=1000,cny=0.1,cnx=0.1,fx=0.7),title=textoidl('Probe signals (I_{sat})'),xsty=4,thick=2,ytitle=textoidl('I_{sat} (A)')
;axis,!x.crange(0),!y.crange(1),xaxis=1
oplot,tt,p2p.v,col=4,thick=2
;stop
d2=convol(d,fltarr(10,1)+1./10.)
d2=d
;plot,t,d2(*,15),xr=xr,/noer,col=2,pos=po
;plot,t,d2(*,3),xr=xr,/noer,col=4

ii=value_locate(t,xr)
nch=n_elements(d2(0,*))
contourn2,d2(ii(0):ii(1),*),t(ii(0):ii(1)),findgen(nch),pos=posarr(/next),/noer,xsty=1,nl=10,title='C II (514nm), PMT signals',xtitle='time (s)',ytitle='Channel #'

endfig,/gs,/jp


end
