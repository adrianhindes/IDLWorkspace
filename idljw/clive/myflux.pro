@pr_prof2


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
sh=87793 & tw=[.03,.04]; 250 ; in .015to.025 is cleraly out, what is rotation?
;sh=87801 & tw=[.01,.02]; 260

tw=[.015,.025];[.08,.09]
which='old'
dofilt=1
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

plot,f,abs(coh),xr=[0,150e3],yr=[0,1]
plot,f,atan2(coh),col=2,xr=[0,150e3],/noer
;stop
f2=fft_t_to_f(isat.t(idx),/neg)
kayf = 1. / 1e3 * f2

krn=sd*conj(sv)*kayf*complex(0,1)
idx2=where(abs(f2) le 1e3)
krn(idx2)=0.
krns=smooth(krn,nsm)

plot,f,krns,col=3,/noer,xr=[0,150e3]
result = total(krn)

print,'flux is',result

plot,f,total(krns,/cum),xr=[0,150e3],/noer,col=4



end

