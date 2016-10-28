pro locateeps2, epc, iharm1,iharm2,epsfinal,epns=epns,rng=rngp,epfund=epfund
nh=n_elements(iharm1)
eps=atan2(epc)
epsc=atan2(epc*complex(0,-1))
epa=abs(epc)

default,epns,min(epa)

i1=(where(iharm1 eq 1 and iharm2 eq 0))(0)
;ins=(where(iharm eq nsharm))(0)
mf=10

print,'epa(i1), epsns*m',epa(i1),epns*mf
if epa(i1) lt epns*mf then begin
    if n_elements(rngp) ne 0 then begin
        rng=rngp
        print, 'fundamental signal too small',epa(i1),epns,'; using rng from keyword rng; rng=',rng*!radeg
    endif else begin
        rng=[-10,80]*!dtor 
        print, 'fundamental signal too small',epa(i1),epns,'; using hard coded rng; rng=',rng*!radeg
    endelse
endif else begin
    modm = epsc(i1) + !pi * intspace(-5,5)
    idx=where(modm ge 0 and modm lt !pi)
    tmp=modm(idx(0))
    epfund=tmp
    rng=tmp+[-!pi/4,!pi/4]
;    idx=where((modm ge -!pi/2) and (modm lt !pi/2))
;    if modm(idx) gt 0 then rng=[0,!pi/2] else rng =[-!pi/2,0]
    print, 'obtaining phase from fundamental signal; phase=',tmp*!radeg,'rng=',rng*!radeg
    rngp=rng
endelse
;rng=[-10,80]*!dtor ; hard coded
;stop
i2=(where(iharm1 eq 2 and iharm2 eq 0))(0)
eps2t=eps(i2)/2. + !pi/2 * intspace(-5,5)
idx=where((eps2t ge rng(0)) and (eps2t le rng(1)))
epsfinal=(eps2t(idx))(0)

;return
if epa(i1) gt epa(i2) then begin
    modm = epsc(i1) + !pi * intspace(-5,5)
    idx=where(modm ge 0 and modm lt !pi)
    tmp=modm(idx(0))
    epsfinal=tmp
    print,'using epsfinal from fundamental'
endif

;stop
end
