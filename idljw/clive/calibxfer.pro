

;sh=88496 & which='old'

sh=88495 & which='new'
;82 - no amp
;83/84 - with amp & divider but loaded with cable
;95 - new divider
;96 - with amp and divider, not loaded, 300kHz bandwdith
;97 - with 300k bandwidth
;98 1MHz lpf 
mdsopen,'h1data',sh
filt=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_2')
ref=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_1')

win=hanning(n_elements(ref.t))
;win=win*0+1
filt.v = filt.v / max(abs(filt.v))
sref=fft(ref.v*win)
sfilt=fft(filt.v*win)

spectdata2c, ref.v,filt.v,ps,t,f,fdig=1e6,dt=0.5e-3,df=2e3;,/nohan
kern=fltarr(1,5) + 1./5.
ps=convol(ps,kern)
n=n_elements(t)
f1=fltarr(n)
p1=fltarr(n)
a1=fltarr(n)
for i=0,n-1 do begin
dum=max(abs(ps(i,*)),imax)
f1(i)=f(imax)
a1(i)=abs(ps(i,imax))
p1(i)=atan2(ps(i,imax))
endfor


plot,f1,a1/max(a1),pos=posarr(2,1,0),xr=[0,500e3]
oplot,f1,abs(ffilter(f1,which=which))/max(abs(ffilter(f1,which=which))),col=2


;; squot = sfilt / sref
plot,f1,p1,pos=posarr(/next),/noer,xr=[0,500e3]
oplot,f1,-atan2(ffilter(f1,which=which)),col=2

stop
s=fft(filt.v)
ftrue=fft_t_to_f(filt.t,/neg)
xferfunc = ffilter(ftrue,which=which)
xferfunc(0)=1.
xferfunc = xferfunc/abs(xferfunc(1))
s = s / xferfunc
filt2 = fft(s,/inverse)

xr=[0,1e-5]+40e-3
plot,ref.t,ref.v/2.2,xr=xr
oplot,filt.t,filt.v*5,col=2
oplot,filt.t,filt2,col=3
;a1/max(a1)
;; f=fft_t_to_f(filt.t)
;; idx=where(f ge 1e3 and f le 100e3)
;; squot2=squot*0
;; squot2(idx)=squot(idx)
;; squot2=smooth(squot2,100)
;; sreal=fft(squot2,/inverse)
;; plot,abs(sreal),yr=[0,1]
end
