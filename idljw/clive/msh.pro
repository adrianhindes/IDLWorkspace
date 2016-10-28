pro msh,t0=t0,dt=dt,df=df,t1=t1,sh=sh,zr=zr,my=my,yr=yr,m2y=m2y,bes=bes
nicenumberinit
default,sh,7523
common cbshot, shotc,dbc, isconnected
shotc=sh & dbc='kstar'
;mdsopen,'kstar',long(sh)
if keyword_set(my) then d=cgetdata('.WAVEFORMS:CAMERA_MON',sh=sh,db='pll') else if keyword_set(m2y) then d={v:getmyprobe(sh),t:findgen(5e6)*2e-6} else if keyword_set(bes) then d={v:getbes(sh),t:-2+dindgen(40000000)*0.5e-6} else d=cgetdata('\MC1T03');,/norest)


default,t0,0.
default,t1,5.

idx=where(d.t lt t1 and d.t ge t0)
fdig=1/(d.t(1)-d.t(0))
fdig = round(fdig / 1e3) * 1e3 ; rount it
t0b=d.t(idx(0))

default,dt,10e-3
default,df,1e3
help,idx,fdig

spectdata2,d.v(idx),ps,t,f,t0=t0b,fdig=fdig,dt=dt,df=df
imgplot,alog10(ps),t,f,/cb,zr=zr,yr=yr


end

