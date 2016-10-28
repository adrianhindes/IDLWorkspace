;sh=intspace(85752,85756)
sh=intspace(85757,85766)
;sh=intspace(85773,85777)
nsh=n_elements(sh)
tr=[.06,.08]
tr=[.085,.095]
bp=fltarr(nsh)
sw=bp

for i=0,nsh-1 do begin
mdsopen,'anal',sh(i)
y=mdsvalue2('te_sw',/nozero)
idx=where(y.t ge tr(0) and y.t le tr(1))
sw(i)=mean(y.v(idx))

y=mdsvalue2('tebp',/nozero)
idx=where(y.t ge tr(0) and y.t le tr(1))
bp(i)=mean(y.v(idx))

endfor

plot,sw
oplot,bp,col=2

end
;(\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_2*33 - \H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3*33)/3.76
