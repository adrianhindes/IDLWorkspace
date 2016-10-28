pro look_pll,sh,twin,nlags,fr=fr,ylog=ylog,img=img,win=win,ana=ana

c=3.0*1e8  ;light velocity
am=1.67*1e-27 ; proton mass
k=1.38*1e-23  ;planck constant
phadelay=125960.18  ; group delay for 80mm BBO -10mmLinbo3
ct=2*18.0*am*c^2/phadelay^2/k/11600.0 ;chariastic temperature

;power spectrum for different current (magnetic configuration)------------------------------------------
;lfshot=179
;sh=strtrim(string(lfshot),1)
;fil='C:\haitao\papers\PMT camera\coherence data\data\data 31-07-2014\linearfield_'+sh+'.lvm'
;data=myread_ascii(fil,data_start=23,delim=string(byte(9)))
;time=data(*,0)-data(0,0)
;deltat=1.0/500000.0
;signal=data(*,1)
;power=fft(signal)
;ft=[1000.0,3000.0]
;power1=power
;power1(0:ft(0))=0.0
;power1(ft(1):*)=0.0
;signal1=fft(power1,/inverse)
;n=n_elements(signal)
;freq=findgen(n/2)/n/deltat
;power=abs(power(0:n/2.0-1))
;n1=n_elements(signal)/50.0
;power_t=make_array(50,n1)
;for j=0,49 do begin
  ;s=j*n1
  ;e=(j+1)*n1-1
  ;power_t(j,*)=abs(fft(signal(s:e)))
  ;endfor
;lockt=findgen(50)*n1*deltat
;freqt=findgen(n1/2)/n1/deltat
;indt=where(freqt/1000.0 ge fr(0) and freqt/1000.0 lt fr(1))
;power_t=power_t(*,indt)
;freqt=freqt(indt) 
;imgplot,alog10(power_t),lockt,freqt/1000.0,/cb,yr=[0,10],xr=[0,0.4],zr=[-5,-1]
;stop
;----------------------------------------------------------------------------------------------


ps=8.0;phasestages
if ana eq 1 then begin
default,fr,[0,50]
mdsopen,'pll',sh
camera_mon=mdsvalue('\pll::top.waveforms:camera_mon')
cam_read=mdsvalue('\pll::top.waveforms:cam_read')
t=mdsvalue('dim_of(\pll::top.waveforms:camera_mon)')
pll=mdsvalue('\pll::top.waveforms:pll')
locksignal=mdsvalue('\pll::top.waveforms:lock_signal')
img=mdsvalue('\pll::top.pimax:images')
img=float(img)
deltat=t(2)-t(1)
mdsclose

;!p.multi=[0,2,2]
;plot, t, xrange=[0,50]+10000, title='TIme sample of shot110',xtitle='Point No.',ytitle='Time'
;oplot, t,color=100,psym=6
;plot, locksignal, xrange=[0,50]+10000, title='Signal sample of shot110',xtitle='Point No.',ytitle='Locksignal'
;oplot, locksignal,color=100,psym=6


; analysis data for whole time series
lockpoints=where(camera_mon ge 0.8*max(camera_mon))
lockac=make_array(ps,/float)
pll_lock=make_array(n_elements(nlags),ps)
n_lock=n_elements(lockpoints)
lockpoints1=lockpoints(0:n_lock-2)
lockpoints2=lockpoints(1:n_lock-1)
lockpoints3=abs(lockpoints1-lockpoints2)
indx=where(lockpoints3 gt 0.5*max(lockpoints3))
ton=deltat*lockpoints1(indx(0))
tcycle=deltat*lockpoints2(indx(0))
st=[0.0,deltat*lockpoints2(indx)]
index=make_array(ps,/float)
hisphase=make_array(63,8,/float)
phase_detect=make_array(8,/float)
meanphase=make_array(8,/float)
if win eq 1 then begin
for i=0,ps-1 do begin
  t2=st(i)
  ind1=where((t ge t2) and (t lt t2+ton))
  locksignal1=locksignal(ind1)
  index(i)=n_elements(ind1)
 ; pll1=pll(ind1)       ; for data taken before 27/06/2014
 pll1=camera_mon(ind1)  ;for data taken at 27/06/2014
  pll_lock(*,i)=c_correlate(locksignal1,pll1,nlags)
  ind2=where(pll1 gt 0.9*max(pll1))
  pll2=pll1(ind2)
  locksignal2=locksignal1(ind2)
  lockac(i)=total(locksignal2)
  ;if i eq 0 then begin
 hillock=hilbert(locksignal1(100000:200000))
 pll3=pll1(100000:200000)
 ind3=where(pll3 gt 0.9*max(pll3))
phase=atan(real_part(hillock),locksignal1(100000:200000))
lockphase=phase(ind3)
meanphase(i)=mean(lockphase(200:300))
hisphase(*,i)=histogram(lockphase, max=!pi,min=-!pi,binsize=0.1,locations=locations) 
dpha=reform(hisphase(*,i))
maxdpha=max(dpha,inde)
phase_detect(i)=locations(inde)
;if i eq 1.0 then begin ;thesis plot for locking performance.
;signal_sam=locksignal1(161050:161200)
;t_sam=t2+(findgen(151)+161050)*deltat
;pll_sam=pll1(161050:161200)
;phase_sam=phase(61050:61200)
;indx_sam=where(pll_sam gt 0.8*max(pll_sam))
;lockphase_sam=phase_sam(indx_sam)
;lockphase_sam=smooth(lockphase_sam,2)
;stop
;endif
  endfor
;check time frequency distribution
n1=n_elements(t)/50.0
power_t=make_array(50,n1)
for j=0,49 do begin
  s=j*n1
  e=(j+1)*n1-1
  power_t(j,*)=abs(fft(locksignal(s:e)))
  endfor
lockt=findgen(50)*n1*deltat
freqt=findgen(n1/2)/n1/deltat
indt=where(freqt/1000.0 ge fr(0) and freqt/1000.0 lt fr(1))
power_t=power_t(*,indt)
freqt=freqt(indt)
;imgplot, alog10(power_t),lockt, freqt/1000.0,xtitle='Time/s',ytitle='Freq/kHz',title='Frequency time distribution of PMT signal at 800A',/cb

;oplot, locations, hisphase;, title='Histogram of phase',xtitle='Phase',ytitle='Phase intensity'
!p.multi=[0,1,3]
imgplot, alog(power_t),lockt, freqt/1000.0,xtitle='Time/s',ytitle='Freq/kHz',title='Frequency time distribution of PMT signal(alog)',/cb,zr=[0,6]
plot, locations, hisphase(*,0), title='Histogram of first phase',xtitle='Phase',ytitle='Phase intensity'
plot, lockac/max(lockac), title='Normalized Locked total intensity of PMT signal',xtitle='Frame No.',ytitle='Relative intensity'
plot,nlags, pll_lock(*,0),title='Cross correlation between lock signal and pll signal'
for j=1,ps-1 do begin
  oplot, nlags,pll_lock(*,j),color=j+1
  wait,2.0
  endfor 
endif
; thesis plot for pll performance, shot364
!p.multi=0
imgpos=[0.15,0.15,0.81,0.81]
colorpos=[0.82,0.25,0.85,0.65]
;phase_detect(5:*)=phase_detect(5:*)-!pi*2.0
;theophase=range(phase_detect(0),phase_detect(0)-!pi*2.0,npts=8)
;p=plot(findgen(8),phase_detect,xtitle='Frame number',ytitle='Phase(radians)',font_size=16)
;p1=plot(findgen(8),theophase,xtitle='Frame number',ytitle='Phase(radians)',linestyle=2,/overplot)
;
;p2=plot(t_sam,phase_sam,xtitle='Time(s)',ytitle='Phase(radians)',xrange=[min(t_sam),max(t_sam)],font_size=16)
;p3=plot(t_sam(indx_sam),lockphase_sam,overplot=1,sym_size=9,sym_filled=1,color='red',symbol='Period',linestyle=6,font_size=16)
;
;p4=plot(t_sam,2.0*signal_sam/max(signal_sam),xtitle='Time(s)',ytitle='Intensity(arb)',xrange=[min(t_sam),max(t_sam)],font_size=16,yrange=[-2,2])
;p5=plot(t_sam,pll_sam/max(pll_sam),color='red',overplot=1)
g=image(alog(power_t),lockt, freqt/1000.0,rgb_table=4,axis_style=1,position=imgpos,xtitle='Time/s',ytitle='Freq(kHz)',aspect_ratio=0.1,font_size=16)
c=colorbar(target=g,title='ln(Power)',orientation=1,position=[0.82,0.38,0.85,0.58],textpos=1,font_size=16)
stop
;;p6=plot(t(10100:10200),camera_mon(10100:10200),axis_style=0,font_size=16);logic zoom in
;p7=plot(t,camera_mon/max(camera_mon),xtitle='Time(s)',ytitle='Intensity(arb)',font_size=16,yrange=[0,1.5],axis_style=1)
;stop
;indx2=where(hisphase eq max(hisphase))
;print, locations(indx2)
; analysis data of one specific time period
if win eq 2 then begin
idx=where(t ge twin(0) and t lt twin(1))
camera_mon=camera_mon(idx)
t=t(idx)

;pll-===
pll=pll(idx)
pll=pll-mean(pll)
acpll=a_correlate(pll, nlags)

;PMT signal analysis
locksignal=locksignal(idx)
locksignal=locksignal-mean(locksignal)
aclocksignal=a_correlate(locksignal, nlags)
powerlock=abs(fft(locksignal))^2
powerpll=abs(fft(pll))^2
pn=n_elements(locksignal)
freq=findgen(pn/2.0)/(pn*deltat)

fp=fft(locksignal)
freq1=freq/1000.0
index3=where(freq1 lt 21.5 or freq1 gt 22.5)
fp(index3)=0.0
fp(n_elements(freq)-1:*)=0.0
fp1=fft(fp,/inverse)
;plot, real_part(fp1),xrange=[0,1000]
;locksignal=real_part(fp1)

;cross correlation
ccs=c_correlate(locksignal,camera_mon,nlags)
 sp=0
 ep=99999;9000
  hlocksignal=hilbert(locksignal(sp:ep))
  hpha=atan(real_part(hlocksignal),locksignal)
  ind3=where(pll(sp:ep) gt 0.5*max(pll(sp:ep)))
  lockpha=hpha(ind3)
  window, 0,title='lock signal of frame1'
  !p.multi=[0,2,3]
  ;plot ,camera_mon,title='Camera monitor signal of this time interval',charsize=2
  plot,locksignal(sp:ep),title='lock signal and the gate signal',charsize=2
  oplot,camera_mon(sp:ep),color=100
  plot,locksignal(sp:ep),title='lock signal and the hilber transform',charsize=2
  oplot,real_part(hlocksignal),color=100
  plot,hpha,title='Phase of the lock signal and gate signal',charsize=2,ytitle='Phase/radians'
  oplot, camera_mon(sp:ep)/max(pll(sp:ep))*3.0,color=100
  plot, nlags, ccs,title='Correlation of PMT and gate signals',charsize=2
  plot,lockpha, title='Lock phase during this time interval',charsize=2,ytitle='Locked phase/radian',xrange=[0,n_elements(lockpha)-1],yrange=[-!pi,!pi]
   oplot,lockpha,psym=2,color=100
  hispha=histogram(lockpha, max=!pi,min=-!pi,binsize=0.5,locations=locations)
  plot, locations, hispha, title='Histogram of phase distritution',xtitle='Phase/radians',ytitle='Intensity',charsize=2
endif

if win eq 3 then begin
!p.multi=[0,2,4]
plot, t,locksignal, title='Lock signal',charsize=2
plot, nlags,aclocksignal, title='Auto correlation of lock signal',charsize=2
plot, t,pll, title='PLL signal',charsize=2
plot, nlags,acpll, title='Auto correlation of PLL signal',charsize=200
plot, t,camera_mon,title='camera monitor signal',charsize=2
plot, nlags,ccs, title='Cross correlation of pll and lock signals',charsize=200
pn=n_elements(freq)-1
plot, freq/1000.0, powerlock(0:n_elements(freq)-1), title='Power spectrum of lock signal',xtitle='Freq/kHz',ytitle='Power',xrange=fr,ylog=ylog,charsize=2
oplot, freq/1000.0, powerpll(0:n_elements(freq)-1),thick=2,color=3
endif
!p.multi=0
;plot, freq/1000.0, powerlock(0:n_elements(freq)-1), title='Power spectrum of lock signal',xtitle='Freq/kHz',ytitle='Power',xrange=[15,30],ylog=ylog,charsize=2
endif

;---------------------------------------------------------------------------------------------------------------------


if ana eq 2 then begin
  
;coherence imaging data
;calibration
calshot1=387
calbg1=388
calshot2=405
calbg2=406
mdsopen, 'pll',calshot1
cal1=float(mdsvalue('\pll::top.pimax:images'))
mdsopen, 'pll',calbg1
bg1=float(mdsvalue('\pll::top.pimax:images'))
mdsopen, 'pll',calshot2
cal2=float(mdsvalue('\pll::top.pimax:images'))
mdsopen, 'pll',calbg2
bg2=float(mdsvalue('\pll::top.pimax:images'))
mdsclose
;g=image(mean(cal1,dimension=3),rgb_table=0,axis_style=1,xtitle='X pixel',ytitle='Y pixel')

;continousd calibration  analysis,data taken on 30/07/2014------------------------------------------------------
;calnu1=1
;calnu2=31
;cn1=strtrim(string(calnu1),1)
;cn2=strtrim(string(calnu2),1)
;fil='C:\haitao\papers\PMT camera\coherence data\data\data 30-07-2014\background 30-07-2014.SPE'
;fil1='C:\haitao\papers\PMT camera\coherence data\data\data 30-07-2014\'+'cal'+cn1+' 30-07-2014.SPE'
;fil2='C:\haitao\papers\PMT camera\coherence data\data\data 30-07-2014\'+'cal'+cn2+' 30-07-2014.SPE'
;read_spe, fil, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
;bg1=d
;bg2=d
;read_spe, fil1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
;cal1=d
;read_spe, fil2, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
;cal2=d
;-----------------------------------------------------------------------------------
;white soure calibration of the imaging system
;file='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\white_camera 04-06-2014.SPE'
;read_spe, file, lam, t1,d,texp=texp,str=str,fac=fac & d=float(d)
;file='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\white_camerabg 04-06-2014.SPE'
;read_spe, file, lam, t1,d1,texp=texp,str=str,fac=fac & d1=float(d1)
;whitecd=d-d1
;-----------------------------------------------------------------------------------------------
cf=[200,220,240,280]
caldim=size(cal2,/dimensions)
calint1=make_array(caldim(0),caldim(1),caldim(2),/float)
calint2=make_array(caldim(0),caldim(1),caldim(2),/float)
calcon1=make_array(caldim(0),caldim(1),caldim(2),/float)
calcon2=make_array(caldim(0),caldim(1),caldim(2),/float)
calpha1=make_array(caldim(0),caldim(1),caldim(2),/dcomplex)
calpha2=make_array(caldim(0),caldim(1),caldim(2),/dcomplex)
han=hanning(caldim(0),caldim(1))
;han=make_array(512,512,value=1.0)
han2=han
idx2=where(han2 le 0.01)
idxdim=n_elements(idx2)
handim=size(han2,/dimensions)
for i=0, idxdim-1 do begin
  ind=array_indices(handim,idx2(i),/dimensions)
  han2(ind(0),ind(1))=1.0
  endfor

for i=0, caldim(2)-1 do begin
  cal1_fft=fft((cal1(*,*,i)-bg1(*,*,i))*han,/center)
  cal2_fft=fft((cal2(*,*,i)-bg2(*,*,i))*han,/center)
  cal1_fft1=cal1_fft
  cal2_fft1=cal2_fft
  
  cal1_fft(*,0:cf(0))=0.0
  cal1_fft(*,cf(1):*)=0.0
  cal1_fft1(*,0:cf(2))=0.0
  cal1_fft1(*,cf(3):*)=0.0
  
  cal2_fft(*,0:cf(0))=0.0
  cal2_fft(*,cf(1):*)=0.0
  cal2_fft1(*,0:cf(2))=0.0
  cal2_fft1(*,cf(3):*)=0.0
  
  calint1(*,*,i)=abs(fft(cal1_fft1,/inverse,/center))/han2
  calint2(*,*,i)=abs(fft(cal2_fft1,/inverse,/center))/han2
  
  calcon1(*,*,i)=2.0*abs(fft(cal1_fft,/inverse,/center)/fft(cal1_fft1,/inverse,/center))
  calcon2(*,*,i)=2.0*abs(fft(cal2_fft,/inverse,/center)/fft(cal2_fft1,/inverse,/center))
  
  calpha1(*,*,i)=fft(cal1_fft,/inverse,/center)
  calpha2(*,*,i)=fft(cal2_fft,/inverse,/center)
  endfor
  
;calirantion comparison
 caldif_pha=atan(calpha1(*,*,1)/calpha2(*,*,1),/phase)
 caldif_pha1=atan(calpha1(*,*,5)/calpha2(*,*,5),/phase)
 caldif_phase=atan(calpha1(*,*,1)/calpha1(*,*,5),/phase)
 caldif_phase1=atan(calpha2(*,*,1)/calpha2(*,*,5),/phase)
 caldif_con=reform(calcon1(*,*,1) -calcon2(*,*,1))
 caldif_contrast=reform(calcon1(*,*,1) -calcon1(*,*,5))
 ;!p.multi=[0,2,3]
 ;imgplot, 180.0/!pi*caldif_pha(100:400,100:400), xtitle='X pixel',ytitle='Y pixel', title='Phase shift of frame 1 between two shots(degree) ',/cb,zr=[-10.,10.]
 ;imgplot, 180.0/!pi*caldif_pha1(100:400,100:400), xtitle='X pixel',ytitle='Y pixel', title='Phase shift of frame 5 between two shots(degree) ',/cb,zr=[-10.,10.]
 ;plot,  180.0/!pi*caldif_pha(*,250),yrange=[-10,10]
 ;plot,  180.0/!pi*caldif_pha(*,250),yrange=[-10,10]
 ;imgplot, 180.0/!pi*caldif_phase(100:400,100:400), xtitle='X pixel',ytitle='Y pixel', title='Phase shift of shot411 between frame 1 and 5(degree)',/cb,zr=[-10.,10.]
 ;imgplot, 180.0/!pi*caldif_phase1(100:400,100:400), xtitle='X pixel',ytitle='Y pixel', title='Phase shift of shot405 between frame 1 and 5(degree) ',/cb,zr=[-10.,10.]
 ;!p.multi=0
 ;imgplot, caldif_con(100:400,100:400), xtitle='X pixel',ytitle='Y pixel', title='Contrast shift of frame 1 between two shots',/cb,zr=[-0.1,0.1]
 ;imgplot, caldif_contrast(100:400,100:400), xtitle='X pixel',ytitle='Y pixel', title='Contrast shift of shot 411 between frame 1 and 5',/cb,zr=[-0.1,0.1]
  

caln=1; calibration image number
calint=calint1(*,*,caln)
calcon=calcon2(*,*,caln)  ;we choose different calibration data here
calpha=calpha2(*,*,caln)
calint=calint/max(calint)

;intensity calibration
indx3=where(calint lt 0.5*max(calint) )
indim3=n_elements(indx3)
for i=0, indim3-1 do begin
  ind1=array_indices([512,512],indx3(i),/dimensions)
  calint(ind1(0),ind1(1))=1.0
  endfor
 shotarr=[361,362,363,364,365,367,368,372,373,374,375,376]
scanp=n_elements(shotarr) 
 imgdim=[512,512,ps]
contrast=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)
intensity=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)
phase=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)

contrast0=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)
intensity0=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)
phase0=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)

phase1=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/dcomplex) 
contrastp=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)
intensityp=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)
phasep=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)
tempp=make_array(imgdim(0),imgdim(1),imgdim(2),scanp,/float)


for k=0,scanp-1 do begin
mdsopen,'pll',416
plasmabg=float(mdsvalue('\pll::top.pimax:images'));plasma background
mdsopen,'pll',shotarr(k)
img=float(mdsvalue('\pll::top.pimax:images'))
mdsclose


;g=image(mean(img,dimension=3),rgb_table=0,axis_style=1,xtitle='X pixel',ytitle='Y pixel')

hidx=[findgen(80),findgen(512-450)+450]
for i=0, imgdim(2)-1 do begin
  imgd=img(*,*,i)-plasmabg
  img_fft=fft(imgd*han,/center)
  img_fft1=img_fft
  
  img_fft(*,0:cf(0))=0.0
  img_fft(*,cf(1):*)=0.0
  img_fft1(*,0:cf(2))=0.0
  img_fft1(*,cf(3):*)=0.0

intensity(*,*,i,k)=abs(fft(img_fft1,/center,/inverse))/han2/calint
contrast(*,*,i,k)=2*abs(fft(img_fft,/center,/inverse)/fft(img_fft1,/center,/inverse))/calcon
phase(*,*,i,k)=atan(fft(img_fft,/center,/inverse)/calpha,/phase)
phase1(*,*,i,k)=fft(img_fft,/inverse,/center)
intensity(*,*,i,k)=intensity(*,*,i,k)/max(intensity(*,*,i,k))
endfor
; perturbation analysis

for i=0,(ps-2)/2.0 do begin
  incre=ps/2.0
 intensityp(*,*,i,k)=intensity(*,*,i,k)-(intensity(*,*,i,k)+intensity(*,*,i+incre,k))/2.0
   intensityp(*,*,i+incre,k)=intensity(*,*,i+incre,k)-(intensity(*,*,i,k)+intensity(*,*,i+incre,k))/2.0
  contrastp(*,*,i,k)=contrast(*,*,i,k)-(contrast(*,*,i,k)+contrast(*,*,i+incre,k))/2.0
 contrastp(*,*,i+incre,k)=contrast(*,*,i+incre,k)-(contrast(*,*,i,k)+contrast(*,*,i+incre,k))/2.0
   phasep(*,*,i,k)=atan(phase1(*,*,i,k)/((phase1(*,*,i,k)+phase1(*,*,i+incre,k))/2.0),/phase)
   phasep(*,*,i+incre,k)=atan(phase1(*,*,i+incre,k)/((phase1(*,*,i,k)+phase1(*,*,i+incre,k))/2.0),/phase)
   tempp(*,*,i,k)=-contrastp(*,*,i,k)/contrast(*,*,i,k)*ct
   tempp(*,*,i+incre,k)=-contrastp(*,*,i+incre,k)/contrast(*,*,i+incre,k)*ct
 ;background
   phase0(*,*,i,k)=atan((phase1(*,*,i,k)+phase1(*,*,i+incre,k))/2.0/calpha,/phase)
   phase0(*,*,i+incre,k)=atan((phase1(*,*,i,k)+phase1(*,*,i+incre,k))/2.0/calpha,/phase)
   contrast0(*,*,i,k)=(contrast(*,*,i,k)+contrast(*,*,i+incre,k))/2.0
   contrast0(*,*,i+incre,k)=(contrast(*,*,i,k)+contrast(*,*,i+incre,k))/2.0
   intensity0(*,*,i,k)=(intensity(*,*,i,k)+intensity(*,*,i+incre,k))/2.0
   intensity0(*,*,i+incre,k)=(intensity(*,*,i,k)+intensity(*,*,i+incre,k))/2.0  
 endfor
 endfor

temp=-alog(contrast0)*ct
flow=phase0/phadelay*c
flowp=phasep/phadelay*c

; average and modification
sr=imgdim(1)/2-100
er=imgdim(1)/2+100

int_dc=mean(intensity0(*,sr:er,*,*),dimension=2)
int_ac=mean(intensityp(*,sr:er,*,*),dimension=2)

flow_dc=mean(flow(*,sr:er,*,*),dimension=2)
flow_ac=mean(flowp(*,sr:er,*,*),dimension=2)

temp_dc=mean(temp(*,sr:er,*,*),dimension=2)
temp_ac=mean(tempp(*,sr:er,*,*),dimension=2)


mask=make_array(512,8,/float,value=0.0)
xsmooth=16
int_dc=smooth(int_dc,[16,1,1],/edge_mirror)
int_ac=smooth(int_ac,[16,1,1],/edge_mirror)
flow_dc=smooth(flow_dc,[16,1,1],/edge_mirror)
flow_ac=smooth(flow_ac,[16,1,1],/edge_mirror)
temp_dc=smooth(temp_dc,[16,1,1],/edge_mirror)
temp_ac=smooth(temp_ac,[16,1,1],/edge_mirror)
;scandata={ip:int_ac,fp:flow_ac,tp:temp_ac, i:int_dc,f:flow_dc,t:temp_dc}
;save, scandata, filename='Scan data for 50A_800A on 27-06-2014.save'  ;save original data for tomography


dim=size(int_dc,/dimensions)
int_ac_ft=make_array(dim(0),dim(1),dim(2),/float)
int_ac_phase=make_array(dim(0),dim(1),dim(2),/float)
flow_ac_ft=make_array(dim(0),dim(1),dim(2),/float)
flow_ac_phase=make_array(dim(0),dim(1),dim(2),/float)
temp_ac_ft=make_array(dim(0),dim(1),dim(2),/float)
temp_ac_phase=make_array(dim(0),dim(1),dim(2),/float)
for j=0,scanp-1 do begin
  ref=reform(int_dc(*,2,j))
  ind_pick=where(ref ge 0.15*max(ref))
;  ind_pickn=n_elements(ind_pick)-1
;  ind_pickm=ind_pick(1:ind_pickn)-ind_pick(0:ind_pickn-1)
;  maxpickm=max(ind_pickm,index)
;  begp=min(ind_pick)
;  endp=ind_pick(index)
  mask(ind_pick,*)=1.0
  mask(460:*,*)=0.0
  ;int_dc(*,*,j)=reform(int_dc(*,*,j))*mask
  int_ac(*,*,j)=reform(int_ac(*,*,j))*mask
  int_dc(*,*,j)=reform(int_dc(*,*,j))*mask
  ;flow_dc(*,*,j)=reform(flow_dc(*,*,j))*mask
  flow_ac(*,*,j)=reform(flow_ac(*,*,j))*mask
  flow_mod=mean(reform(flow_dc(*,*,j)),dimension=2)
  flow_sh=mean(flow_mod(250:260))
  flow_dc(*,*,j)=flow_dc(*,*,j)-flow_sh
  flow_dc(*,*,j)=reform(flow_dc(*,*,j))*mask
 temp_dc(*,*,j)=reform(temp_dc(*,*,j))*mask
  temp_ac(*,*,j)=reform(temp_ac(*,*,j))*mask
  temp_dc(*,*,j)=reform(temp_dc(*,*,j))*mask
  
;fourier analysis
for i=0,511 do begin
  intf=fft(reform(int_ac(i,*,j)))
  intf(0)=0.0
  intf(2:*)=0.0
  intf_iv=fft(intf,/inverse)
  int_ac_phase(i,*,j)=atan(intf_iv,/phase)
 
  int_ac_ft(i,*,j)=2.0*real_part(intf_iv)
  
  
  
  flowf=fft(reform(flow_ac(i,*,j)))
  flowf(0)=0.0
  flowf(2:*)=0.0
  flowf_iv=fft(flowf,/inverse)
  flow_ac_phase(i,*,j)=atan(flowf_iv,/phase)
  flow_ac_ft(i,*,j)=2.0*real_part(flowf_iv)
  
 
  tempf=fft(reform(temp_ac(i,*,j)))
  tempf(0)=0.0
  tempf(2:*)=0.0
  tempf_iv=fft(tempf,/inverse)
  temp_ac_phase(i,*,j)=atan(tempf_iv,/phase)
  temp_ac_ft(i,*,j)=2.0*real_part(tempf_iv)
 endfor
  int_ac_phase(*,*,j)=reform(int_ac_phase(*,*,j))*mask
  flow_ac_phase(*,*,j)=reform(flow_ac_phase(*,*,j))*mask
  temp_ac_phase(*,*,j)=reform(temp_ac_phase(*,*,j))*mask
 
 endfor
 stop
;;plot for thesis shot364
;sh_ind=where(shotarr eq sh)
int_ac_phap=transpose(reform(int_ac_phase(*,3,*)))
int_dc_p=transpose(reform(mean(int_dc,dimension=2)))
int_ac_p=transpose(reform(int_ac(*,2,*)))
imgpos=[0.15,0.15,0.80,0.80]
cbpos=[0.82,0.3,0.85,0.65]
samimg=reform(img(*,*,2))
gg=image(samimg/max(samimg),position=imgpos,rgb_table=4,axis_style=1,xtitle='X pixel',ytitle='Y pixel',aspect_ratio=1.0,font_size=16)
cc=colorbar(target=gg,orientation=1,title='Intensity(arb)',textpos=1,$
  position=cbpos,font_size=16)

;g=image(rebin(int_ac_phap,1200,512),findgen(1200)*4.0*0.01+13.0,position=imgpos,$
;findgen(512),rgb_table=4,axis_style=1,xtitle='Axis(cm)',ytitle='Pixel',aspect_ratio=0.05,font_size=16)
;c=colorbar(target=g,orientation=1,title='Phase(radians)',textpos=1,$
;  position=cbpos,font_size=16)
g1=image(rebin(int_dc_p,1200,512),findgen(1200)*4.0*0.01+13.0,position=imgpos,$
findgen(512),rgb_table=4,axis_style=1,xtitle='Axis(cm)',ytitle='Pixel',aspect_ratio=0.05,font_size=16)
c1=colorbar(target=g1,orientation=1,title='Intensity(arb)',textpos=1,$
 position=cbpos,font_size=16)

g2=image(rebin(int_ac_p,1200,512),findgen(1200)*4.0*0.01+13.0,findgen(512),position=imgpos,max_value=0.04,min_value=-0.04,$
  rgb_table=4,axis_style=1,xtitle='Axis(cm)',ytitle='Pixel',aspect_ratio=0.05,font_size=16)
c2=colorbar(target=g2,orientation=1,title='Intensity(arb)',textpos=1,$
 position=cbpos,font_size=16) 
;  
;  
;  
;
flow_ac_phap=transpose(reform(flow_ac_phase(*,3,*)))
flow_dcp=transpose(reform(mean(flow_dc,dimension=2)))
flow_acp=transpose(reform(flow_ac(*,2,*)))
;g3=image(rebin(flow_ac_phap,1200,512),findgen(1200)*4.0*0.01+13.0,position=imgpos,$
;findgen(512),rgb_table=4,axis_style=1,xtitle='Axis(cm)',ytitle='Pixel',aspect_ratio=0.05,font_size=16)
;c3=colorbar(target=g3,orientation=1,title='Phase(radians))',textpos=1,$
;  position=cbpos,font_size=16)
g3=image(rebin(flow_dcp,1200,512)/1000.0,findgen(1200)*4.0*0.01+13.0,findgen(512),rgb_table=4,$
  axis_style=1,xtitle='Axis(cm)',ytitle='Pixel',aspect_ratio=0.05,font_size=16,position=imgpos,max_value=1.0,min_value=-1.0)
c3=colorbar(target=g3,orientation=1,title='Flow(km/s)',textpos=1,position=cbpos,font_size=16)  
;
g4=image(rebin(flow_acp,1200,512),findgen(1200)*4.0*0.01+13.0,findgen(512),rgb_table=4,$
  axis_style=1,xtitle='Axis(cm)',ytitle='Pixel',aspect_ratio=0.05,font_size=16,position=imgpos,max_value=50.0,min_value=-50.0)
c4=colorbar(target=g4,orientation=1,title='Flow perturbation(m/s)',textpos=1,position=cbpos,font_size=16)  
;  
;  
stop 
;  
;  
;if win eq 1 then begin
;;data visulizaiton
;window,0,title='Intensity profile'
;imgplot, mean(reform(int_dc(*,*,sh_ind)),dimension=2),/cb
;window, 1, title='Temperature profile'
;imgplot, temp_dc(*,*,),/cb,zr=[0,1.5]
;window, 2, title='Flow profile'
;imgplot, flow(*,*,3),/cb,zr=[-1000,1000]
;endif
;
;
;if win eq 2 then begin
;  window,0,title='Intensity perturbation profile'
; imgplot, reform(intensityp(*,250,*)),/cb,pal=-2
; window,1, title='Flow perturbation'
; imgplot, reform(flowp(*,250,*)),/cb,pal=-2
; window, 2, title='Temperatur perturbation'
; imgplot, reform(tempp(*,250,*)),/cb,pal=-2
; endif


if win eq 3 then begin
  !p.multi=[0,3,2]
  !p.charsize=2
  imgplot, reform(int_ac(*,*,sh_ind))*100, xtitle='Camera pixel',ytitle='Frame No.', title='Intensity perturbation(%)',/cb,pal=-2
  imgplot, reform(flow_ac(*,*,sh_ind)), xtitle='Camera pixel',ytitle='Frame No.', title='Flow perturbation(m/s)',/cb,pal=-2
  imgplot, reform(temp_ac(*,*,sh_ind)), xtitle='Camera pixel',ytitle='Frame No.', title='Temperature perturbation (eV)',/cb,pal=-2
 int_dcp=mean(reform(int_dc(*,*,sh_ind)),dimension=2)
  plot, int_dcp/max(int_dcp), xtitle='X pixel',ytitle='Y pixel', title='Normalized intensity profile',yrange=[0,1]
 flow_dcp=mean(reform(flow_dc(*,*,sh_ind)),dimension=2)
  plot, flow_dcp+400.0, xtitle='X pixel',ytitle='Y pixel', title='Flow profile(m/s)',yrange=[-1000,1000]
 temp_dcp=mean(reform(temp_dc(*,*,sh_ind)),dimension=2)
  plot, temp_dcp, xtitle='X pixel',ytitle='Y pixel', title='Temperature profile(eV)',yrange=[0,1.5]
  !p.multi=0
  endif
stop
;theoretical analysis
;phase noise analysis
wavelength=487.986
xs=512
ys=512
sz=24*1e-6
f=135.0
bdeltan=bbo(wavelength, kapa=kapa)
kapab=kapa
ldeltan=linbo3(wavelength, kapa=kapa)
kapal=kapa
op1=waveplateb_gel(wavelength,40.0,!pi/2,f,sz,xs,ys)*kapab-waveplatel_gel(wavelength,5.0,0.0,f,sz,xs,ys)*kapal
op2=waveplateb_gel(wavelength,40.0,0.0,f,sz,xs,ys)*kapab-waveplatel_gel(wavelength,5.0,!pi/2,f,sz,xs,ys)*kapal
mimg=op1+op2+displacer_gel(wavelength,3.0,!pi/2,f,sz,xs,ys)*kapab
op1=waveplateb_gel(wavelength,40.0,!pi/2,f,sz,xs,ys)*kapab-waveplatel_gel(wavelength,5.0,0.0,f,sz,xs,ys)*kapal
;hydrogen and deutrium test
hline=486.13330
dline=486.00398
bbol=20.0
hdelay1=waveplateb_gel(hline,bbol,!pi/2,f,sz,xs,ys)*kapab
ddelay1=waveplateb_gel(dline,bbol,!pi/2,f,sz,xs,ys)*kapab
h1sig=dcomplex(cos(hdelay1),sin(hdelay1))
d1sig=dcomplex(cos(ddelay1),sin(ddelay1))
pdf1=atan(h1sig/d1sig,/phase)

hdelay2=waveplateb_gel(hline,bbol,!pi/2,f,sz,xs,ys)*kapab+waveplatel_gel(hline,5.0,0.0,f,sz,xs,ys)*kapal
ddelay2=waveplateb_gel(dline,bbol,!pi/2,f,sz,xs,ys)*kapab+waveplatel_gel(dline,5.0,0.0,f,sz,xs,ys)*kapal
h2sig=dcomplex(cos(hdelay2),sin(hdelay2))
d2sig=dcomplex(cos(ddelay2),sin(ddelay2))
pdf2=atan(h2sig/d2sig,/phase)

pdf=atan((h1sig/d1sig)/(h2sig/d2sig),/phase)

stop



;oscilloscope data
file10='C:\haitao\papers\PMT camera\coherence data\data\data 23-05-2014\tek0010CH1.csv' ;shot 73
os10=read_csv(file10,n_table_header=21)
os10t=os10.field1 
os10dc=os10.field2
file12='C:\haitao\papers\PMT camera\coherence data\data\data 23-05-2014\tek0012CH1.csv' ;shot 75
os12=read_csv(file12,n_table_header=21)
os12t=os12.field1
os12dc=os12.field2

file13='C:\haitao\papers\PMT camera\coherence data\data\data 23-05-2014\tek0013CH1.csv' ;shot 76
os13=read_csv(file13,n_table_header=21)
os13t=os13.field1
os13dc=os13.field2


file14='C:\haitao\papers\PMT camera\coherence data\data\data 23-05-2014\tek0014CH1.csv' ;shot 78
os14=read_csv(file14,n_table_header=21)
os14t=os14.field1
os14dc=os14.field2

fil15='C:\haitao\papers\PMT camera\coherence data\data\data 27-05-2013\tek0015ALL.csv'


index=where(t lt 0.15)
camera_mon1=camera_mon(index)
camera_mon2=abs(camera_mon1(0:n_elements(index)-2)-camera_mon1(1:*))
index1=where(camera_mon2 ge 5.0*1e3)
ton=deltat*index1(0)
tcycle=deltat*index1(1)

dcflu=make_array(8,/float)
np=make_array(8,/float)
for i=0,7 do begin
  tint=-0.5+i*tcycle
  ind1=where((os12t gt tint) and (os12t le tint+ton))
  np(i)=n_elements(ind1)
  dcflu(i)=total(os12dc(ind1))
  endfor
  stop
!p.multi=[0,1,3]
;save, dcflu, filename='DC fluctuation of shot 78 with 400 A.save'
restore,'DC fluctuation of shot 78 with 400 A.save'
plot, dcflu, title='Dc fluctuaiton of shot78 with 400A',xtitle='Frame NO.',ytitle='DC' ,yrange=[1500,2500],Charsize=2.0
;save, dcflu, filename='DC fluctuation of shot 75 with 500 A.save'
restore,'DC fluctuation of shot 75 with 500 A.save'
plot, dcflu, title='Dc fluctuaiton of shot75 with 500A',xtitle='Frame NO.' ,ytitle='DC' ,yrange=[1500,2500],Charsize=2.0
;save, dcflu, filename='DC fluctuation of shot 76 with 600 A.save'
restore,'DC fluctuation of shot 76 with 600 A.save'
plot, dcflu, title='Dc fluctuaiton of shot76 with 600A',xtitle='Frame NO.' ,ytitle='DC',yrange=[1500,2500],Charsize=2.0
endif

;phase relation of the coherence imaging data
if ana eq 3 then begin
cslice=4
shotarr=['361','362','363','364','365','367','368','372','373','374','375','376']
;check intensity for Romona
;shotarr1=[361,362,363,364,365,367,368,372,373,374,375,376]
;inty=make_array(12,/float)
;for i=0,11 do begin
  ;mdsopen,'pll',shotarr1(i)
  ;img=mdsvalue('\pll::top.pimax:images')
  ;d=mean(img(100:400,100:400,*),dimension=3)
  ;d1=mean(d,dimension=2)
  ;inty(i)=mean(d1)
;endfor
;stop
shotsize=n_elements(shotarr)
intphase=make_array(shotsize, 512,/float)
flowphase=make_array(shotsize, 512,/float)
tempphase=make_array(shotsize, 512,/float)
phase_dif=make_array(shotsize, 512,/float)

int_axis=make_array(shotsize, 512,/float)
flow_axis=make_array(shotsize, 512,/float)
temp_axis=make_array(shotsize, 512,/float)
for i=0,shotsize-1 do begin
  restore, 'result'+shotarr(i)+'.save'
  ip=result.ip
  fp=result.fp
  tp=result.tp
  ipphase=result.ippha
  fpphase=result.fppha
  tpphase=result.tppha
  int_axis(i,*)=reform(ip(*,250,cslice))
  flow_axis(i,*)=reform(fp(*,250,cslice))
  temp_axis(i,*)=reform(tp(*,250,cslice))
  intphase(i,*)=atan(reform(ipphase(*,cslice)),/phase)
  flowphase(i,*)=atan(reform(fpphase(*,cslice)),/phase)
  tempphase(i,*)=atan(reform(tpphase(*,cslice)),/phase)
  phase_dif(i,*)=atan(reform(fpphase(*,cslice)/ipphase(*,cslice)),/phase)
  endfor
!p.multi=[0,2,2]
!p.charsize=2
imgplot, rebin(int_axis,1200,512)*100.0,findgen(1200)*4.0*0.01+13.0,findgen(512),xtitle='Axis coordinate(cm)',ytitle='X pixel',title='Intensity perturbation along the axis(%)',/cb
imgplot, rebin(flow_axis,1200,512),findgen(1200)*4.0*0.01+13.0,findgen(512),xtitle='Axis coordinate(cm)',ytitle='X pixel',title='Flow perturbation along the axis(m/s)',/cb
imgplot, rebin(intphase,1200,512),findgen(1200)*4.0*0.01+13.0,findgen(512),xtitle='Axis coordinate(cm)',ytitle='X pixel',title='Intensity perturbation phase along the axis(radians)',/cb
imgplot, rebin(flowphase,1200,512),findgen(1200)*4.0*0.01+13.0,findgen(512),xtitle='Axis coordinate',ytitle='X pixel',title='Flow perturbation phase along the axis(radians)',/cb
stop
g=image(rebin(int_axis,1200,512),rgb_table=4,axis_style=1,title='Intensity perturbation ') 
c=colorbar(target=g,orientation=1,position=[0.95,0.25,0.98,0.75])


g1=image(rebin(flow_axis,1200,512),rgb_table=4,axis_style=1,title='Flow perturbation') 
c=colorbar(target=g1,orientation=1,position=[0.95,0.25,0.98,0.75])

g2=image(rebin(intphase,1200,512),rgb_table=4,axis_style=1,title='Intensity phase') 
c=colorbar(target=g2,orientation=1,position=[0.95,0.25,0.98,0.75])

;jumpimg,phase_dif
g3=image(rebin(flowphase,1200,512),rgb_table=4,axis_style=1,title='flow phase') 
c=colorbar(target=g3,orientation=1,position=[0.95,0.25,0.98,0.75])
endif


;john's method to do demodulation
if ana eq 4 then begin
cf=[200,220,245,265]
;calibration
;calibration
calshot1=387
calbg1=388
calshot2=405
calbg2=406
mdsopen, 'pll',calshot1
cal1=float(mdsvalue('\pll::top.pimax:images'))
mdsopen, 'pll',calbg1
bg1=float(mdsvalue('\pll::top.pimax:images'))
mdsopen, 'pll',calshot2
cal2=float(mdsvalue('\pll::top.pimax:images'))
mdsopen, 'pll',calbg2
bg2=float(mdsvalue('\pll::top.pimax:images'))
mdsclose
caldim=size(cal2,/dimensions)
hw=80+findgen(450-80)
calint1=make_array(caldim(0),caldim(2),/float)
calint2=make_array(caldim(0),caldim(2),/float)
calcon1=make_array(caldim(0),caldim(2),/float)
calcon2=make_array(caldim(0),caldim(2),/float)
calpha1=make_array(caldim(0),caldim(2),/dcomplex)
calpha2=make_array(caldim(0),caldim(2),/dcomplex)
for i=0, caldim(2)-1 do begin
  calimg1=reform(cal1(*,*,i)-bg1(*,*,i))
  calimg2=reform(cal2(*,*,i)-bg2(*,*,i))
  ind=where(reform(calimg1(*,256)) gt 0.4*max(reform(calimg1(*,256))))
  wd=make_array(caldim(0),caldim(1),/float,value=1.0)
  wd(*,0:min(hw))=0.0
  wd(*,max(hw):*)=0.0
  wd(0:min(ind),*)=0.0
  wd(max(ind):*,*)=0.0
  calimg1=calimg1*wd
  calimg2=calimg2*wd
  calimg1=mean(calimg1,dimension=1)
  calimg2=mean(calimg2,dimension=1)
  
  cal1_fft=fft(calimg1,/center)
  cal2_fft=fft(calimg2,/center)
  cal1_fft1=cal1_fft
  cal2_fft1=cal2_fft
  
  cal1_fft(0:cf(0))=0.0
  cal1_fft(cf(1):*)=0.0
  cal1_fft1(0:cf(2))=0.0
  cal1_fft1(cf(3):*)=0.0
  
  cal2_fft(0:cf(0))=0.0
  cal2_fft(cf(1):*)=0.0
  cal2_fft1(0:cf(2))=0.0
  cal2_fft1(cf(3):*)=0.0
  
 calint1(*,i)=abs(fft(cal1_fft1,/inverse,/center))
 calcon1(*,i)=2.0*abs(fft(cal1_fft,/inverse,/center)/fft(cal1_fft1,/inverse,/center))
 calpha1(*,i)=fft(cal1_fft,/inverse,/center)
 
 calint2(*,i)=abs(fft(cal2_fft1,/inverse,/center))
 calcon2(*,i)=2.0*abs(fft(cal2_fft,/inverse,/center)/fft(cal1_fft1,/inverse,/center))
 calpha2(*,i)=fft(cal2_fft,/inverse,/center)
  endfor
caln=1; calibration image number
calint=calint1(*,caln)
calcon=calcon2(*,caln)  ;we choose different calibration data here
calpha=calpha2(*,caln)
calint=calint/max(calint)


shotarr=[361,362,363,364,365,367,368,372,373,374,375,376]
mdsopen,'pll',416
plasmabg=float(mdsvalue('\pll::top.pimax:images'));plasma background
mdsclose
intensity=make_array(caldim(0),ps,n_elements(shotarr),/float)
contrast=make_array(caldim(0),ps,n_elements(shotarr),/float)
phase=make_array(caldim(0),ps,n_elements(shotarr),/float)
 phase1=make_array(caldim(0),ps,n_elements(shotarr),/dcomplex)
imgdata=make_array(caldim(0),ps,n_elements(shotarr))
  for i=0,n_elements(shotarr)-1 do begin
  mdsopen,'pll',shotarr(i)
  img=mdsvalue('\pll::top.pimax:images')
  mdsclose
  ind1=where(reform(img(*,256,1)) gt 0.4*max(reform(img(*,256,1))))
  wd=make_array(caldim(0),caldim(1),/float,value=1.0)
  wd(*,0:min(hw))=0.0
  wd(*,max(hw):*)=0.0
  wd(0:min(ind1),*)=0.0
  wd(max(ind1):*,*)=0.0
  for j=0,ps-1 do begin
    img(*,*,j)=img(*,*,j)-plasmabg
    img(*,*,j)=reform(img(*,*,j))*wd
    imgdata(*,j,i)=mean(img(*,*,j),dimension=1)
  endfor
   endfor
 for i=0,n_elements(shotarr)-1 do begin
  for j=0,ps-1 do begin
    data=reform(imgdata(*,j,i))
    data_fft=fft(data,/center)
    data_fft1=data_fft
    data_fft(0:cf(0))=0.0
   data_fft(cf(1):*)=0.0
   data_fft1(0:cf(2))=0.0
   data_fft1(cf(3):*)=0.0
   intensity(*,j,i)=abs(fft(data_fft1,/center,/inverse))/calint
   contrast(*,j,i)=2*abs(fft(data_fft,/center,/inverse)/fft(data_fft1,/center,/inverse))/calcon
   phase1(*,j,i)=fft(data_fft,/center,/inverse)
    phase(*,j,i)=atan(fft(data_fft,/center,/inverse),/phase)
    intensity(*,j,i)=intensity(*,j,i)/max(intensity(*,j,i))
   endfor
   endfor
  endif
;perturbation analysis
contrastp=make_array(caldim(0),ps,n_elements(shotarr),/float)
intensityp=make_array(caldim(0),ps,n_elements(shotarr),/float)
phasep=make_array(caldim(0),ps,n_elements(shotarr),/float)
tempp=make_array(caldim(0),ps,n_elements(shotarr),/float)
for i=0,(ps-2)/2.0 do begin
  incre=ps/2.0
 intensityp(*,i,*)=intensity(*,i,*)-(intensity(*,i,*)+intensity(*,i+incre,*))/2.0
   intensityp(*,i+incre,*)=intensity(*,i+incre,*)-(intensity(*,i,*)+intensity(*,i+incre,*))/2.0
  contrastp(*,i,*)=contrast(*,i,*)-(contrast(*,i,*)+contrast(*,i+incre,*))/2.0
 contrastp(*,i+incre,*)=contrast(*,i+incre,*)-(contrast(*,i,*)+contrast(*,i+incre,*))/2.0
   phasep(*,i,*)=atan(phase1(*,i,*)/((phase1(*,i,*)+phase1(*,i+incre,*))/2.0),/phase)
   phasep(*,i+incre,*)=atan(phase1(*,i+incre,*)/((phase1(*,i,*)+phase1(*,i+incre,*))/2.0),/phase)
   tempp(*,i,*)=-contrastp(*,i,*)/contrast(*,i,*)*ct
   tempp(*,i+incre,*)=-contrastp(*,i+incre,*)/contrast(*,i+incre,*)*ct
  endfor
  flowp=phasep/phadelay*c
;fourier analysis
int_pha=make_array(n_elements(hw),ps,n_elements(shotarr),/float)
flow_pha=make_array(n_elements(hw),ps,n_elements(shotarr),/float)
temp_pha=make_array(n_elements(hw),ps,n_elements(shotarr),/float)
pdif=make_array(n_elements(hw),ps,n_elements(shotarr),/float)
for i=0,n_elements(shotarr)-1 do begin
  for j=0,n_elements(hw)-1 do begin
  int_fft=fft(intensityp(hw(j),*,i))
  flow_fft=fft(flowp(hw(j),*,i))
  temp_fft=fft(tempp(hw(j),*,i))
  int_fft(0)=0.0
  int_fft(2:*)=0.0
  flow_fft(0)=0.0
  flow_fft(2:*)=0.0
  temp_fft(0)=0.0
  temp_fft(2:*)=0.0
  int_pha(j,*,i)=atan(fft(int_fft,/inverse),/phase)
  flow_pha(j,*,i)=atan(fft(flow_fft,/inverse),/phase)
  temp_pha(j,*,i)=atan(fft(temp_fft,/inverse),/phase)
  pdif(j,*,i)=atan(fft(flow_fft,/inverse)/fft(int_fft,/inverse),/phase)
  endfor
  endfor
  
  



stop
end
