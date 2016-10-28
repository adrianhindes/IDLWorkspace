pro look_pll2,sh,twin,fr=fr,ylog=ylog,img=img,win=win,f0=f0,bw=bw,iframe=iframe,ccs=ccs
;nlags=intspace(-200,200)
nlags=findgen(400)-200


default,fr,[1,100]
mdsopen,'pll',sh
camera_mon=mdsvalue('\pll::top.waveforms:camera_mon')
t=mdsvalue('dim_of(\pll::top.waveforms:camera_mon)')
if n_elements(twin) eq 0 then twin=[0,1.]

dc=camera_mon(1:*)-camera_mon(0:n_elements(camera_mon)-2)
iswitchon=[0,where(dc gt 1e4)]
iswitchoff=[where(dc lt -1e4)]
if keyword_set(iframe) then begin
   twin=[t(iswitchon(iframe)),t(iswitchoff(iframe))]
   twin=twin(0)+[0,0.05]
   print,twin
endif


deltat=t(2)-t(1)
idx=where(t ge twin(0) and t lt twin(1))
camera_mon=camera_mon(idx)
t=t(idx)

;pll-===
pll=mdsvalue('\pll::top.waveforms:pll')
pll=pll(idx)
pll=pll-mean(pll)
acpll=a_correlate(pll, nlags)


;lock_singal=...
locksignal=mdsvalue('\pll::top.waveforms:lock_signal')
img=mdsvalue('\pll::top.pimax:images')
mdsclose
locksignal=locksignal(idx)
locksignal2=locksignal

; plot,fft_t_to_f(t),abs(fft(locksignal)),/ylog,xr=[1e3,100e3]
if keyword_set(bw) then filtsig,locksignal2,bw=bw,f0=f0,t=t,nmax=1,/nodc


;oplot,fft_t_to_f(t),abs(fft(locksignal2)),col=2
locksignal=float(locksignal2)
;stop



locksignal=locksignal-mean(locksignal)
hlocksignal=float(hilbert(locksignal))

lphs=atan(hlocksignal,locksignal)
aclocksignal=a_correlate(locksignal, nlags)

;cross correlation
ccs=c_correlate(locksignal,pll,nlags)

nt=n_elements(t)
dpll=pll(1:*)-pll(0:nt-2)
ipulse = where(dpll gt 2000)

lphs2=lphs(ipulse)*!radeg

default,win,1
if win eq 1 then begin
wset2,0
!p.multi=[0,1,5]
plot, t,locksignal, title='Lock signal'
oplot,t,hlocksignal,col=2
plot,t,lphs*!radeg,title='lock phase'
plot, t,pll, title='PLL signal'
plot,t(ipulse),lphs2,psym=10
oplot,t(ipulse),lphs2,psym=4
;plot,lphs2(sort(lphs2)),psym=4
hg=histogram(lphs,omax=omax,omin=omin,nbins=32)
hgx=linspace(omin,omax,32) 
plot,hgx,hg

!p.multi=0
endif
if win eq 2 then begin
wset2,1
!p.multi=[0,2,3]
plot, nlags,aclocksignal, title='Auto correlation of lock signal'
plot, nlags,acpll, title='Auto correlation of PLL signal'
plot, t,camera_mon,title='camera monitor signal'
plot, nlags,ccs, title='Cross correlation of pll and lock signals'

power=abs(fft(locksignal))^2
powerpll=abs(fft(pll))^2
pn=n_elements(locksignal)
freq=findgen(pn/2.0)/(pn*deltat)

plot, freq/1000.0, power(0:n_elements(freq)-1), title='Power spectrum of lock s;ignal',xtitle='Freq/kHz',ytitle='Power',xrange=fr,/ylog
oplot, freq/1000.0, powerpll(0:n_elements(freq)-1),thick=2
plot,totaldim(img(*,*,1:*),[1,1,0]),/yno
!p.multi=0
stop
endif

stop
end

pro loop
;75 500,76 600, 78 400
for i=1,7 do begin
look_pll2,90,win=3,iframe=i,ccs=ccs
x=intspace(-200,200)
if i eq 1 then plot,x,ccs,yr=[-.1,.1] else oplot,x,ccs,col=i
endfor
end
