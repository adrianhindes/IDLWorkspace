pro demodsw, sh,ch,dens,t,amp=amp

fn='/tmp/dens_'+string(sh,ch,format='(I0,"_",I0)')+'.sav'
dum=file_search(fn,count=cnt)
if cnt ne 0 then begin
;   restore,file=fn,/verb
;   return
endif
;sh=82005
d=read_datam(sh,ch,dt=dt)
dr=read_datam(sh,21,dt=dt,t0=t0)
d=d(0:129999)
dr=dr(0:129999)

idx=intspace(60000,129999)
;d=d(idx) & dr=dr(idx)
n=n_elements(d)
t=findgen(n)*dt+t0
d-=mean(d)
dr-=mean(dr)
win=hanning(n)*0+1.
s=fft(d*win)
p=fft(dr*win)
f=fft_t_to_f(t)

;ix=where(f le 50e3 or f ge 150e3)
;ix=where(f le 90e3 or f ge 110e3)
ww=exp(-(f-10e3)^2/3e3^2)

s2=s
p2=p

dum=max(abs(p2),imax)
;p2(*)=0.
;p2(imax)=1.
;p2(ix)=0
;s2(ix)=0
p2=p*ww
s2=s*ww
da=fft(s2,/inverse)
db=fft(p2,/inverse)
pp=phs_jump(atan2(da))
pr=phs_jump(atan2(db))

;plot,pp-pr

dens=pr-pp
amp=abs(da)
ix=where(t lt 0)
off=mean(dens(ix))
dens-=off
;plot,t,dens

save,t,dens,amp,file=fn,/verb
plot,f,abs(s),/ylog
stop

end

;demodsw

;end

