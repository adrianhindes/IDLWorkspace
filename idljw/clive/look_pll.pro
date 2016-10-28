pro look_pll,sh,twin,nlags,fr=fr,ylog=ylog,img=img




default,fr,[0,100]
mdsopen,'pll',sh
camera_mon=mdsvalue('\pll::top.waveforms:camera_mon')
t=mdsvalue('dim_of(\pll::top.waveforms:camera_mon)')
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

 plot,fft_t_to_f(t),abs(fft(locksignal)),/ylog,xr=[1e3,100e3]
filtsig,locksignal2,bw=8e3,f0=23e3,t=t,nmax=1,/nodc

oplot,fft_t_to_f(t),abs(fft(locksignal2)),col=2
locksignal=float(locksignal2)
stop



locksignal=locksignal-mean(locksignal)
hlocksignal=float(hilbert(locksignal))

lphs=atan(hlocksignal,locksignal)
aclocksignal=a_correlate(locksignal, nlags)
power=abs(fft(locksignal))^2
powerpll=abs(fft(pll))^2
pn=n_elements(locksignal)
freq=findgen(pn/2.0)/(pn*deltat)



;cross correlation
ccs=c_correlate(locksignal,pll,nlags)

nt=n_elements(t)
dpll=pll(1:*)-pll(0:nt-2)
ipulse = where(dpll gt 2000)

lphs2=lphs(ipulse)*!radeg

;dada display
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
;plot, nlags,aclocksignal, title='Auto correlation of lock signal'
;plot, nlags,acpll, title='Auto correlation of PLL signal'
;plot, t,camera_mon,title='camera monitor signal'
;plot, nlags,ccs, title='Cross correlation of pll and lock signals'
;plot, freq/1000.0, power(0:n_elements(freq)-1), title='Power spectrum of lock s;ignal',xtitle='Freq/kHz',ytitle='Power',xrange=fr,ylog=ylog
;oplot, freq/1000.0, powerpll(0:n_elements(freq)-1),thick=2
;plot,totaldim(img(*,*,1:*),[1,1,0]),/yno


;; ;coherence imaging data
;; ;calibration data
;; bfile='Z:\haitao\background 22-05-2014.spe' ;bfile is the background file taken in the same conditoin as shot 72-78
;; cfile1='Z:\haitao\cal0 22-05-2014.spe'     ; cfile1 is a picture taken as the same condition as shot 72-78, cfile2 and cfile3 are the same condition while taking two pictures to fill the sensor
;; cfile2='Z:\haitao\cal1 22-05-2014.spe'
;; cfile3='Z:\haitao\cal2 22-05-2014.spe'
;; read_spe, bfile, lam, t,d,texp=texp,str=str,fac=fac
;; background=d(*,*,3)
;; read_spe, cfile1, lam, t,d,texp=texp,str=str,fac=fac
;; calib1=d(*,*,3)
;; read_spe, cfile2, lam, t,d,texp=texp,str=str,fac=fac
;; calib2=d
;; read_spe, cfile3, lam, t,d,texp=texp,str=str,fac=fac
;; calib3=d(*,*,3)

;; cal=calib1-background
;; han=hanning(128,256)
;; cal=cal*han
;; calf=fft(cal*han)




stop
end
