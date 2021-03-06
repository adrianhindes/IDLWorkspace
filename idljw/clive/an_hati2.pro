sh=84544
sh+=0
;sh=84588

read_spe,'~/share/greg/ha_cal  1.spe',lc,tc,dc,str=strc&lc=reverse(lc)
read_spe,'~/share/greg/ha_cal  4.spe',lcd,tcd,dc0,str=strc0
read_spe,'~/share/greg/shaun_'+string(sh,format='(I0)')+'.spe',l,t,d,str=str,xml=xml&l=reverse(l)
print,str.avgain
dc*=1.
dc0*=1.
d*=1.
;ich=2  &frac=0.75&ti=2. & vel2=[-10e3,-10e3]
;ich=5  &frac=0.75&ti=2. & vel2=[-10e3,-10e3]
;ich=5  &frac=0.75&ti=2. & vel2=[-10e3,-5e3]

addto=0.
;ich=14 & frac=0.5&ti=10. & vel2=[-15e3,-10e3] & addto=100.
;ich=13 & frac=0.5&ti=10. & vel2=[-15e3,-10e3] & addto=100.

ich=12 & frac=0.5&ti=10. & vel2=[-15e3,-10e3] & addto=100.
;ich=11 & frac=0.5&ti=7. & vel2=[-15e3,-10e3] & addto=100.
;ich=12 & frac=0.5&ti=5. & vel2=[-30e3,-5e3] & addto=100.
;ich=11 & frac=0.5&ti=5. & vel2=[-30e3,-5e3] & addto=100.
;ich=10 & frac=0.5&ti=4. & vel2=[-15e3,-10e3] & addto=100.
;ich=1
active=(d(*,ich,3)-d(*,ich,0));/str.avgain;*6
cal=dc(*,ich,3)-dc0(*,ich,0)
;cal = cal / max(cal) * max(active)

l=reverse(l)
lc=reverse(lc)
active=reverse(active)
cal=reverse(cal)
plot,l,active,xr=656+[-1,1.]/2.,psym=-4,/ylog,yr=[1,1e5]
oplot,lc-0.04,cal*max(active)/max(cal),col=2,psym=-4


dl=abs(l(1)-l(0))
ncut=fix(2. / dl) / 2 * 2 + 1
ltrial=intspace(-ncut/2,ncut/2)*dl
;frac=0.5&ti=5
;frac=0.75&ti=2.
;frac=1&ti=2.
;frac=0.95&ti=1.

;frac=0.75&ti=10. & vel2=[-10e3,-10e3]
;frac=0.9&ti=3. & vel2=[-15e3,0e3]


lv=[656.27, 656.27,656.53] 
clight=3e8
lv2=lv + [1/clight * lv(0)*vel2,0]
ltrialt=ltrial + lv(0) + 0.02
f=fltarr(ncut)

a=[frac,1-frac,0.03]
echarge=1.6e-19
mi=1.67e-27
vth=sqrt(2*echarge*ti/mi)
clight=3e8
lwid = lv(0) * vth/clight
for i=0,2 do begin
if i eq 0 then begin
   f=f+a(i)*exp(-(ltrialt-lv2(i))^2/lwid^2) / lwid / sqrt(!pi) * dl
endif else begin
   i0=value_locate(ltrialt,lv2(i))
   f(i0)+=a(i)
endelse
endfor

oplot,ltrialt-0.32,f/max(f)*max(active),col=3,psym=-4
;f/=total(f)
fcon=convol(cal,reverse(f))
oplot,lc,fcon*max(active)/max(fcon) + addto,col=4,psym=-4


;line=exp(

;print,xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.intensifier.gating.dif.startinggate.pulse.width
print,float(xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.intensifier.gating.dif.endinggate.pulse.width)/1e9

end
