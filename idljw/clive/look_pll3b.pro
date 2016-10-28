pro look_pll2,sh,twin,fr=fr,ylog=ylog,img=img,win=win,f0=f0,bw=bw,iframe=iframe,ccs=ccs,lmax=lmax,doiframe=doiframe,lockavg=lockavg
default,lmax,200
nlags=intspace(-lmax,lmax)


default,fr,[1,100]
mdsopen,'pll',sh
camera_mon=mdsvalue('\pll::top.waveforms:cam_read')
t=mdsvalue('dim_of(\pll::top.waveforms:cam_read)')
if n_elements(twin) eq 0 then twin=[0,1.]

dc=camera_mon(1:*)-camera_mon(0:n_elements(camera_mon)-2)
iswitchon=[0,where(dc gt 1e4)]
iswitchoff=[where(dc lt -1e4)]
if keyword_set(doiframe) then begin
   twin=[t(iswitchon(iframe)),t(iswitchoff(iframe))]
;   twin=twin(0)+[0,0.05]
   print,twin
   print,iframe
endif


deltat=t(2)-t(1)
idx=where(t ge twin(0) and t lt twin(1))
camera_mon=camera_mon(idx)
t=t(idx)

;pll-===
;pll=mdsvalue('\pll::top.waveforms:pll')
pll=mdsvalue('\pll::top.waveforms:camera_mon')
pll=pll(idx)
pll0=pll
pll=pll-mean(pll)
acpll=a_correlate(pll, nlags)


;lock_singal=...
locksignal=-mdsvalue('\pll::top.waveforms:lock_signal')
img=mdsvalue('\pll::top.pimax:images')
mdsclose
locksignal=locksignal(idx)
locksignal2=locksignal

; plot,fft_t_to_f(t),abs(fft(locksignal)),/ylog,xr=[1e3,100e3]
if keyword_set(bw) then filtsig,locksignal2,bw=bw,f0=f0,t=t,nmax=1,/nodc


;oplot,fft_t_to_f(t),abs(fft(locksignal2)),col=2
locksignal=float(locksignal2)
;stop


locksignal0=locksignal
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

lockavg=total(pll0*locksignal0)



if win eq 1 then begin
wset2,0
;!p.multi=[0,1,5]
plot, t,locksignal, title='Lock signal',pos=posarr(1,5,0)
oplot,t,hlocksignal,col=2
;plot,t,lphs*!radeg,title='lock phase'
nsmm=10
freq=-deriv(t,smooth(phs_jump(lphs),nsmm))/2/!pi

plot,t,freq/1e3,title='freq',yr=[10,35],ysty=1,pos=posarr(/next),/noer
plot, t,pll, title='PLL signal',pos=posarr(/next),/noer
plot,t(ipulse),lphs2,psym=10,pos=posarr(/next),/noer
oplot,t(ipulse),lphs2,psym=4
;plot,lphs2(sort(lphs2)),psym=4
;hg=histogram(lphs,omax=omax,omin=omin,nbins=32)
;hgx=linspace(omin,omax,32) 
nbin=32
hg=histogram(lphs2,min=-180,max=180,nbins=nbin)
hgxe=linspace(-180,180,nbin+1) 
hgx=(hgxe(1:nbin)+hgxe(0:nbin-2))/2.
plot,hgx,hg,pos=posarr(/next),/noer
stop
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

plot, freq/1000.0, power(0:n_elements(freq)-1), title='Power spectrum of lock signal',xtitle='Freq/kHz',ytitle='Power',xrange=fr,/ylog
;oplot, freq/1000.0, powerpll(0:n_elements(freq)-1),thick=2,col=2
plot,totaldim(img(*,*,1:*),[1,1,0]),/yno
!p.multi=0
stop
endif

;stop
end

pro loop,sh
;75 500,76 600, 78 400
larr=fltarr(8)
for i=0,7 do begin
lmax=50
look_pll2,sh,win=3,iframe=i,ccs=ccs,lmax=lmax,doiframe=1,lockavg=l1,f0=23e3,bw=3e3
larr(i)=l1
x=intspace(-lmax,lmax)
if i eq 1 then plot,x,ccs,yr=[-.1,.1]*3,pos=posarr(2,1,0) else oplot,x,ccs,col=i
endfor
plot,larr,pos=posarr(/next),/noer
end


;98;rng4
;101 rng2
;106 rng4, no filtre
;107 rng2, no filter
;108 rng2, no filter, 800
;109 rng4 no filter 800
;110 test

;114 800A filter

;;;

;120 start 1
;121 start 5

;123 optimized match, 8 phases, 800A, w/filter


;124 as 123 but with filter to 27kHz (3.3nf)
;125 filter to 29kHz (3nF)


;211-114 field on, no scanning
