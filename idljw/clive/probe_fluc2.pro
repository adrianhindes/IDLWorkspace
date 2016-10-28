pro probe_fluc2,sh,xr=xr,chan=chan,nsm=nsm,fr=fr,bw=bw,band=band,par=par

default,chan,'isat'
default,xr,[0,.05]

mdsopen,'h1data',sh
if chan eq 'isat' then num =2
if chan eq 'vfloat' then num=3
if chan eq 'vplas' then num=4
if n_elements(num) gt 0 then $
   cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(num,format='(I0)'),/nozero) $
else begin
   if chan eq 'temp' then begin
      vfl=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3',/nozero) 
      vpl=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_4',/nozero) 
      cur=vfl & cur.v = vfl.v-vpl.v
   endif
endelse

mirn=mdsvalue2('\H1DATA::TOP.MIRNOV.ACQ132_7:INPUT_01',/nozero)
curi=interpol(cur.v,cur.t,mirn.t)

idx=where(mirn.t ge xr(0) and mirn.t le xr(1))

c2=curi(idx)
m2=mirn.v(idx)
f=fft_t_to_f(mirn.t(idx))
default,bw,3e3
nsm=ceil(bw/(f(1)-f(0)))
;


n=n_elements(c2)
win=hanning(n)

fc=fft(c2*win)
fm=fft(m2*win)

sc=smooth(abs(fc)^2,nsm)
sm=smooth(abs(fm)^2,nsm)

cc=smooth(fc*conj(fm),nsm)

coh=cc/sqrt(sc*sm)
acoh=abs(coh)
pcoh=atan2(coh)

i2=where(f ge band(0) and f le band(1))
dum=max(sm(i2),imax)
imax=i2(imax)

plot,f,sm,/ylog,pos=posarr(2,2,0),title='sm',xr=fr
plots,f(imax),dum,psym=4,col=2
plot,f,sc,/ylog,pos=posarr(/next),title='sc',/noer,xr=fr
plot,f,abs(cc),/ylog,pos=posarr(/next),title='cc',/noer,xr=fr
plot,f,acoh,pos=posarr(/next),title='ccoh',yr=[0,1],/noer,xr=fr

;stop
par=[f(imax),sm(imax),sc(imax),cc(imax),coh(imax)]


end

tab=[[47,1.3],$
     [48,1.24],$
     [51,1.33],$
;     [50,1.33],$
     [52,1.25]]
sh=reform(81700+tab(0,*))
r=reform(tab(1,*))
idx=sort(r)
r=r(idx)
sh=sh(idx)
par=complexarr(4,5)
pa2r=complexarr(4,5)
for i=0,3 do begin
   band=[20e3,50e3]
;   band=[10e3,20e3]
   chan1='isat'
   chan2='vfloat'

;probe_fluc,sh(i),xr=[0,.05],minc=1e-2,chan=chan,fr=[0,50e3],zri=[-6,-2]
;stop


   probe_fluc2,sh(i),xr=[0.025,0.03]+0.005,chan=chan1,fr=[0,100e3],bw=2e3,band=band,par=par1
   probe_fluc2,sh(i),xr=[0.025,0.03]+0.005,chan=chan2,fr=[0,100e3],bw=2e3,band=band,par=par2

   par(i,*)=par1
   pa2r(i,*)=par2
   wait,.1
endfor
plot,r,par(*,0),pos=posarr(2,3,0),title='freq'
plot,r,par(*,1),pos=posarr(/next),title='size of mag fluc',/noer
plot,r,abs(par(*,2))/abs(par(*,1)),psym=-4,pos=posarr(/next),/noer,title='mag '+chan+'/mag mirn'

plot,r,abs(pa2r(*,2))/abs(pa2r(*,1)),psym=-4,pos=posarr(/curr),/noer,title='mag '+chan+'/mag mirn',col=2

plot,r,abs(par(*,4)),psym=-4,pos=posarr(/next),/noer,title='coh'
oplot,r,abs(pa2r(*,4)),psym=-4,col=2
plot,r,atan2(par(*,3))*!radeg,psym=-4,pos=posarr(/next),/noer,/yno,title='cross phase',yr=minmax(atan2([par(*,3),pa2r(*,3)])*!radeg)

oplot,r,atan2(pa2r(*,3))*!radeg,psym=-4,col=2
;plot,r,atan2(par(*,2)),




;probe_fluc2,81752,xr=[0.025,0.030]

end
