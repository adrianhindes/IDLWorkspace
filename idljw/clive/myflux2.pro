@pr_prof2
pro myflux2, sh, t0, dt, result,which=which,dofilt=dofilt,noplot=noplot,ff=f,fkrns=krns

;sh=82823 & tw=[.03,.04] ;vfloat,martijns shot->inwards, is positive


;sh=87717 & tw=[.06,.07];; was this one ; 260


;sh=88530 & tw=.065+[0,.01]

;dofilt=1
;which='new'
;sh=88533 & tw=[.088,.098] ; uncollapsed state
;sh=88533 & tw=[.025,.035] ; collapsed state

;sh=88528 & tw=[.02,.04]

;sh=88606 & tw=[.06,.07]

;sh=87062 & tw=[.03,.04] ; kh=0.4-.48, w 15kw, has drop [but bw bad]

;sh=87773 & tw=[.03,.04];230
;sh=87781 & tw=[.03,.04]; 240
;sh=87793 & tw=[.03,.04]; 250 ; in .015to.025 is cleraly out, what is rotation?
;sh=87801 & tw=[.01,.02]; 260

;tw=[.015,.025];[.08,.09]
tw=t0+[-dt/2,dt/2]
default,which,'old'
default,dofilt,1
;sh=86427 & tw=[.06,.07]
; doit,86427,tr=[.06,.07]

dum=getpar(sh,'isat',y=isat,tw=[0,.01])
dum=getpar(sh,'vplasma',y=vpl,tw=[0,.01])
idx=where(isat.t ge tw(0) and isat.t lt tw(1))
dens=isat & dens.v = dens.v * 1e18 / 0.02

sd=fft(dens.v(idx))
sv=fft(vpl.v(idx))

f=fft_t_to_f(isat.t(idx))

ftrue=fft_t_to_f(isat.t(idx),/neg)


xferfunc = ffilter(ftrue,which=which)
xferfunc = xferfunc/abs(xferfunc(1))
xferfunc(0)=1.


if dofilt eq 1 then sv = sv / xferfunc
nsm=10
cc=smooth(sd * conj(sv),nsm )
ac1=smooth(abs(sd)^2,nsm)
ac2=smooth(abs(sv)^2,nsm)
coh=cc/sqrt(ac1*ac2)

;stop
f2=fft_t_to_f(isat.t(idx),/neg)
kayf = 1. / 1e3 * f2

krn=sd*conj(sv)*kayf*complex(0,1)
idx2=where(abs(f2) le 1e3)
krn(idx2)=0.
krns=smooth(krn,nsm)
result = total(krn)

if not keyword_set(noplot) then begin
plot,f,abs(coh),xr=[0,150e3],yr=[0,1]
plot,f,atan2(coh),col=2,xr=[0,150e3],/noer
plot,f,krns,col=3,/noer,xr=[0,150e3]
plot,f,total(krns,/cum),xr=[0,150e3],/noer,col=4
;stop
print,'flux is',result
endif






end

pro testmyflux22

sh=88533 & dt=0.01 & which='new' & dofilt=1

t0=0.035
t1=0.085
myflux2,sh,t0,dt,dum,which=which,dofilt=dofilt,noplot=1,ff=f,fkrns=krns
myflux2,sh,t1,dt,dum,which=which,dofilt=dofilt,noplot=1,ff=f,fkrns=krns2

df=f(1)-f(0)
mkfig,'~/tex/ishw/tsd.eps',xsize=8,ysize=3.5,font_size=7
plot,f/1e3,-krns/1e14/df,xr=[0,50],xtitle='Freq / kHz',title='Transport spectral density function',ytitle=textoidl('\Gamma (10^{14} 1/m^2/s/Hz)')
oplot,f/1e3 ,-krns2/1e14/df,col=2,linesty=2
legend,['30-40ms','80-90ms'],textcol=[1,2],col=[1,2],/right,linesty=[0,2]
endfig,/gs,/jp
stop
end



pro testmyflux2
; goto,ee
sh=87793 & dt=0.01/5;tw=[.03,.04]; 250

sh=88533 & dt=0.01/5 & which='new' & dofilt=1


t=linspace(.005,.095,10*5)
nt=n_elements(t)
flux=fltarr(nt)
for i=0,nt-1 do begin
myflux2,sh,t(i),dt,dum,which=which,dofilt=dofilt,noplot=0 & flux(i)=dum
print,i,t(i),dum
endfor
ee:
plot,t,flux,psym=-4
oplot,!x.crange,[0,0],linesty=2
dum= getpar( sh, 'isat', tw=[0,.1],y=y)

plot,y.t,y.v>0,/noer,xr=!x.crange
plot,t,flux,psym=-4,col=2,/noer

end



testmyflux22
end
