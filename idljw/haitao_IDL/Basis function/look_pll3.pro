pro look_pll3,sh,twin,win=win,ana=ana
;romana's pmt data taken 28/02/2014
;filerpm='C:\haitao\papers\PMT camera\romana pmt data\28_02_2014\2\6.sav'
;restore, filerpm
;dr=reform(p_data(*,4))
;ind=where(time gt 0.13 and time lt 0.3)

;PLL data taken 28/05/2014
;mdsopen,'pll',sh
;time=mdsvalue('dim_of(\pll::top.waveforms:camera_mon)')
;dr=mdsvalue('\pll::top.waveforms:lock_signal')
;ind=where(time gt 0.1 and time lt 1.0)
;
;Pmt data taken 04/06/2014
;filepll='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\data398.save'
;restore, filepll
;dr=reform(data(*,2))
;time=findgen(n_elements(dr))*1.0/(5*1e5)
;ind=where(time gt 0.1 and time lt 1.0)

;data taken 14/07/2013
;dr=read_pmt_channel(1590,12,time=time) ;last year data review
;ind=where(time gt 0.1 and time lt 0.5)

;data taken on 31/07/2014 for different current
;lfshot=179
;sh=strtrim(string(lfshot),1)
;fil='C:\haitao\papers\PMT camera\coherence data\data\data 31-07-2014\linearfield_'+sh+'.lvm'
;data=myread_ascii(fil,data_start=23,delim=string(byte(9)))
;deltat=1.0/500000.0
;time=findgen(250000)*deltat
;dr=data(*,1)
;ind=where(time gt 0.1 and time lt 0.4)

;data taken on 27/06/2014 for mirror current 800A and source current 50A
;mdsopen,'pll',364
;time=mdsvalue('dim_of(\pll::top.waveforms:camera_mon)')
;dr=mdsvalue('\pll::top.waveforms:lock_signal')
;ind=where(time gt 0.1 and time lt 0.5)
;mdsclose

dr1=dr(ind)
t=time(ind)
drf=fft(dr1)
drf1=drf
freq=findgen(n_elements(drf)/2.0+1)/n_elements(drf)/(t(1)-t(0))
powdr=abs(drf(0:n_elements(drf)/2.0))
ind2=where(freq gt 27000 and freq lt 31000)
drf1(0:ind2(0))=0.0
drf1(ind2(n_elements(ind2)-1):*)=0.0
rps=real_part(fft(drf1,/inverse))
rpso=real_part(fft(drf,/inverse))
!p.multi=[0,2,2]
!p.charsize=1
plot, time, dr, title='Raw signal of 364 Dc ',xtitle='Time/s',ytitle='Amplitude/v'
plot, freq/1000,alog10(powdr), title='Power spectrum of shot364',xrange=[0,50],xtitle='Freq/kHz',ytitle='Alog10(Power)'
plot, t,rpso,title='Signal without filter',xtitle='Time/s',ytitle='Amplitude/v',xrange=[0.150,0.20]
plot, t, rps, title='Filtered signal', xtitle='Time/s', ytitle='Amplitude/v',xrange=[0.150,0.20]
!p.multi=0
stop
phasestage=7
ps=phasestage+1
 ;order=['32','33','34','35','36','37','38','39','40','50','60']
order=['0','2','4','6','1','3','5','7','8']
;order=['0','2','4','6','8','10','12','14','1','3','5','7','9','11','13','15','16']
;order=['0','2','4','6','8','10','12','14','1','3','5','7','9','11','13'];,'15','16']
;shotno=strtrim(string(order+397),1) ;210
shotno=strtrim(string(order+568),1) 
dataarr=make_array(700000,4,ps,/float)

if ana eq  1 then begin
; data analysis of gate time delay using camera.
lockac=make_array(ps,/float)
c_signal=make_array(50,ps,/float)

;the whole data set analysis
if win eq 1 then begin
for i=0,ps-1 do begin
pmtfile='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\data'+shotno(i)+'.save'
restore, pmtfile
dataarr(*,*,i)=data
endfor

for j=0,ps-1 do begin
time=reform(dataarr(*,0,j))
time=time-min(time)
dc=reform(dataarr(*,1,j))
;sq=reform(dataarr(2,*,i))
gate=reform(dataarr(*,3,j))
osc=reform(dataarr(*,2,j))
ind=where(gate ge max(gate)*0.8)
gatet=gate(ind(0):ind(n_elements(ind)-1))

gateos=osc(ind(0):ind(n_elements(ind)-1))
indd=where(gatet ge max(gatet)*0.8)
if j eq 5 then begin
hilos=hilbert(gateos)
phaos=atan(real_part(hilos),gateos)
gatepha=phaos(indd)
hisphase=histogram(gatepha, max=!pi,min=-!pi,binsize=0.1,locations=locations)
endif
c_signal(*,j)=c_correlate(gatet, gateos, findgen(50)-25)
lockac(j)=total(osc(ind))
endfor


deltat=time(1)-time(0)
deltat=2*1e-6
tn=n_elements(time)/50
tfd=make_array(50,tn/2.0+1)
for j=0,49 do begin
  sig=osc(tn*j:tn*(j+1)-1)
  pow=abs(fft(sig))
  tfd(j,*)=pow(0:tn/2.0)
  endfor
freq=findgen(tn/2.0+1)/tn/deltat

  ;!p.multi=[0,1,2]
  imgplot,tfd, findgen(50)*max(time)/49.0, freq/1000.0, title='Time frequency distribution of the signal at 400A',xtitle='Time/s',ytitle='Freq/kHz',yr=[0,50],/cb
  plot, lockac, title='Lock pmt signal',xrange=[0,ps-1]
  plot, locations,hisphase,title='Histogram of phase',xtitle='Phase/radians',ytitle='Phase intensity'
  for j=1,ps-1 do begin
    oplot,locations,hisphase(*,j)
    endfor
  plot, c_signal(*,0),title='Correlation of gate and pmt signal'
  for j=1, ps-1 do begin
    oplot,c_signal(*,j),color=3*j
    wait, 2.0
    endfor
    endif


;one specific data shot analysis
sh=string(sh,format='(I3.3)')
file='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\data'+sh+'.save'
restore, file
data1=data
gate1=reform(data1(*,3))
osc1=reform(data1(*,2))
;sq1=reform(data1(2,*))
dc1=reform(data1(*,1))
t=reform(data1(*,0))
t=t-min(t)

ind1=where(t ge twin(0) and t lt twin(1))
osc1=osc1(ind1)
gate1=gate1(ind1)
;sq1=sq1(ind1)
dc1=dc1(ind1)


if win eq 2 then begin
 !p.multi=[0,2,3]
 plot, osc1, title='The pmt and gate signal',charsize=2
 oplot, gate1,color=3
 ;plot, dc1,title='pmt dc signal',charsize=2
 ;plot, sq1, title='Rectified square signal',charsize=2
 ;plot, gate1,title='Gate signal from camera',charsize=2
 hosc=hilbert(osc1)
 pha=atan(real_part(hosc), osc1)
 
 plot, osc1, title='Phase of the pmt signal and hilbert transform',charsize=2
 oplot, real_part(hosc),color=3
 plot, pha, title='Phase of the signal',charsize=2
 oplot, gate1,color=3
 plot, c_correlate(gate1,osc1,findgen(200)-100),title='Coorelation between pmt signal and gates',charsize=2
 ind2=where(gate1 ge max(gate1)*0.85)
 plot, pha(ind2),title='Gated phase',yrange=[-!pi,!pi],charsize=2
 oplot, pha(ind2),psym=6,color=3
 hpha=histogram(pha(ind2), max=!pi,min=-!pi,binsize=0.5,locations=locations)
 plot, locations, hpha,title='Histogram of phase distribution',xtitle='Phase/radians',ytitle='Density',charsize=2
 endif
 endif
 !p.multi=0
 
 if ana eq 2 then begin
 mdsopen,'pll',sh
 img=mdsvalue('\pll::top.pimax:images') 
  mdsclose
;camera imgaes analysis
;shotno= STRTRIM(string(['0','2','4','6','1','3','5','7','8']+154),1)
imgdata=make_array(512,512,ps,/float)
fil='C:\haitao\papers\PMT camera\coherence data\data\data 03-06-2014\background 03-06-2014.SPE'
read_spe, fil, lam, t1,d,texp=texp,str=str,fac=fac & d=float(d)
background=d
;for i=0,ps-1 do begin
;file='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\test'+shotno(i)+'.spe'
;read_spe, file, lam, t1,d,texp=texp,str=str,fac=fac & d=float(d)
;indd=where(d lt 0.1*max(d))
;d1=d(indd)
;imgdata(*,*,i)=d-mean(d1)
;endfor
;shotno= STRTRIM(string(['0','2','4','6','1','3','5','7']))
imgdata=img

calfil1='C:\haitao\papers\PMT camera\coherence data\data\data 03-06-2014\calibration2 03-06-2014.SPE'
read_spe, calfil1, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
calback=d
calfil2='C:\haitao\papers\PMT camera\coherence data\data\data 03-06-2014\calibration1 03-06-2014.SPE'
read_spe,calfil2, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
cal=d-calback
calfil3='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\white 04-06-2014.SPE'
read_spe, calfil3, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
calwh=d
calfil4='C:\haitao\papers\PMT camera\coherence data\data\data 04-06-2014\whitebg 04-06-2014.SPE'
read_spe, calfil4, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
calwhb=d
calintensityw=calwh-calwhb

han=hanning(512,512)
calf=fft(cal*han,/center)
calf1=calf
calf(*,0:190)=0
calf(*,210:*)=0
calf1(*,0:240)=0
calf1(*,280:*)=0

calintensity=abs(fft(calf1, /inverse, /center))
calcontrast=2*abs(fft(calf,/inverse,/center))/calintensity
calphase=atan(fft(calf,/inverse,/center),/phase)

intensity=make_array(512,512,ps,/float)
contrast=make_array(512,512,ps,/float)
phase=make_array(512,512,ps,/dcomplex)

for j=0,ps-1 do begin
  imgd=imgdata(*,*,j)
  imgdf=fft(imgd*han, /center)
  imgdf1=imgdf
  imgdf(*,0:200)=0
 imgdf(*,220:*)=0
imgdf1(*,0:240)=0
 imgdf1(*,280:*)=0
 intensity(*,*,j)=abs(fft(imgdf1, /inverse, /center))
 contrast(*,*,j)=2*abs(fft(imgdf,/inverse,/center)/abs(fft(imgdf1, /inverse, /center)))
 phase(*,*,j)=fft(imgdf,/inverse,/center)
 scal=calintensityw/max(calintensityw)
 intensity(80:430,150:400,j)=intensity(80:430,150:400,j)/scal(80:430,150:400)
 intensity(*,*,j)=intensity(*,*,j)/max(intensity(*,*,j))
 endfor
 
stop

;calculation of perturbation
intensityp=make_array(512,512,ps,/float)
phasep=make_array(512,512,ps,/float)
contrastp=make_array(512,512,ps,/float)
for i=0,(ps-2)/2.0 do begin
  incre=ps/2.0
  ;if i eq (ps-3)/2.0 then begin
    ;incre=(ps-1)/2.0-1
     ;intensityp(*,*,i)=intensity(*,*,i)-(intensity(*,*,i)+intensity(*,*,i+incre))/2.0
   ;intensityp(*,*,i+incre)=intensity(*,*,i+incre)-(intensity(*,*,i)+intensity(*,*,i+incre))/2.0
  ;contrastp(*,*,i)=contrast(*,*,i)-(contrast(*,*,i)+contrast(*,*,i+incre))/2.0
; contrastp(*,*,i+incre)=contrast(*,*,i+incre)-(contrast(*,*,i)+contrast(*,*,i+incre))/2.0
   ;phasep(*,*,i)=atan(phase(*,*,i)/((phase(*,*,i)+phase(*,*,i+incre))/2.0),/phase)
   ;phasep(*,*,i+incre)=atan(phase(*,*,i+incre)/((phase(*,*,i)+phase(*,*,i+incre))/2.0),/phase)
   ;endif
  intensityp(*,*,i)=intensity(*,*,i)-(intensity(*,*,i)+intensity(*,*,i+incre))/2.0
   intensityp(*,*,i+incre)=intensity(*,*,i+incre)-(intensity(*,*,i)+intensity(*,*,i+incre))/2.0
  contrastp(*,*,i)=contrast(*,*,i)-(contrast(*,*,i)+contrast(*,*,i+incre))/2.0
 contrastp(*,*,i+incre)=contrast(*,*,i+incre)-(contrast(*,*,i)+contrast(*,*,i+incre))/2.0
   phasep(*,*,i)=atan(phase(*,*,i)/((phase(*,*,i)+phase(*,*,i+incre))/2.0),/phase)
   phasep(*,*,i+incre)=atan(phase(*,*,i+incre)/((phase(*,*,i)+phase(*,*,i+incre))/2.0),/phase)
   endfor
stop
;intensityp(*,*,ps-1)=intensity(*,*,ps-1)-(intensity(*,*,ps-1)+intensity(*,*,(ps-1)/2.0))/2.0
;contrastp(*,*,ps-1)=contrast(*,*,ps-1)-(contrast(*,*,ps-1)+contrast(*,*,(ps-1)/2.0))/2.0
;phasep(*,*,ps-1)=atan(phase(*,*,ps-1)/((phase(*,*,ps-1)+phase(*,*,(ps-1)/2.0))/2.0),/phase)

;picking up valid area
sec=reform(intensity(*,250,4))
ind3=where(sec lt max(sec)*0.2)
ind4=[findgen(100),findgen(512-450)+450]
intensityp(ind3, *,*)=0.0
intensityp(*,ind4,*)=0.0
phasep(ind3,*,*)=0.0
phasep(*,ind4,*)=0.0
contrastp(ind3,*,*)=0.0
contrastp(*,ind4,*)=0.0   

;binning of perturbation to reduce nosie
xs=16
ys=80
intensityp=smooth(intensityp,[xs,ys,1])
contrastp=smooth(contrastp,[xs,ys,1])
phasep=smooth(phasep,[xs,ys,1])
;!p.multi=[0,3,1]
;!p.charsize=1
;imgplot,reform(intensityp(*,250,0:ps-2)),title='Intensity perturbation',/cb,pal=-2
;imgplot,reform(contrastp(*,250,0:ps-2)),title='Contrast perturbation',/cb,pal=-2
;imgplot,reform(phasep(*,250,0:ps-2)),title='Phase perturbation',/cb,pal=-2
;!p.multi=0
;stop
;window,0
!p.multi=[0,3,1]
!p.charsize=1
;imgplot,reform(phasep(*,250,0:ps-1))/114996.0*3*1e8,findgen(512),findgen(ps)*!pi*2.0/(ps-1),title='Flow perturbation/(m/s)',/cb,pal=-2,xtitle='X pixel',ytitle='Phase/radians'
;imgplot,reform(intensityp(*,250,0:ps-1)),findgen(512),findgen(ps)*!pi*2.0/(ps-1),xtitle='X pixel',title='Intensity perturbation',/cb,pal=-2,ytitle='Phase/radians'
;imgplot,reform(contrastp(*,250,0:ps-1)),findgen(512),findgen(ps)*!pi*2.0/(ps-1),xtitle='X pixel',title='Contrast perturbation',/cb,pal=-2,ytitle='Phase/radians'
 !p.multi=0
 !p.background=254
 !p.color=4
 ;imgplot, reform(intensityp(*,250,*))*100.0,findgen(512)*10.0/511.0,findgen(8)*!pi*2/8.0,xtitle='Position(cm)',ytitle='Phase(radians)',/cb,pal=-2
d=reform(intensityp(*,250,*))*100.0
d1=reform(phasep(*,250,*))/114996.0*3*1e8
g=image(rebin(d,5120,8000),findgen(5120)*0.1,findgen(8000)*!pi*2.0/8000.0,rgb_table=4,axis_style=1,xtitle='Camera Pixel',ytitle='Phase(radians)',xrange=[100,400],aspect_ratio=50,font_size=17)
l=colorbar(target=g,orientation=1,position=[0.94,0.25,0.97,0.80],title='Intensity perturbation(%)',font_size=17)
 ;g=image(rebin(reform(intensityp(*,250,*))*100.0,5120,800),rgb_table=39,findgen(5120)*10.0/5199.0,findgen(800)*!pi*2/799.0,xtitle='Position(cm)',ytitle='Phase(radians)')
 ;intdata=reform(intensityp(*,250,0:ps-2))
;g=image(rebin(intdata,5120,(ps-1)*100.0),axis_style=1,findgen(512*10)*10.0/(512*10-1)-5.0,findgen((ps-1)*100)*!pi*2/((ps-1)*100-1),rgb_table=4,xtitle='Coordinate across plasma tube/cm',ytitle='Phase/radians')
stop
sintensityp=reform(intensityp(*,250,4))
ind5=where(sintensityp ne 0.0)
intensityps=reform(intensityp(*,250,*))
flowps=reform(phasep(*,250,*))/114996.0*3*1e8
fs=size(intensityps,/dimensions)
intensitypa=make_array(fs(0),fs(1),value=0.0)
intensitypp=make_array(fs(0),fs(1),value=0.0)
flowpa=make_array(fs(0),fs(1),value=0.0)
flowpp=make_array(fs(0),fs(1),value=0.0)
 
for i=ind5(0),ind5(n_elements(ind5)-1) do begin  
     fip=fft(reform(intensityps(i,*)))
     fip1=fft(reform(flowps(i,*)))
     fip(0)=0.0
     fip(2:*)=0.0
     fip1(0)=0.0
     fip1(2:*)=0.0
     intensitypa(i,*)=real_part(fft(fip,/inverse))
     intensitypp(i,*)=atan(fft(fip,/inverse),/phase)
     flowpa(i,*)=real_part(fft(fip1,/inverse))
     flowpp(i,*)=atan(fft(fip1,/inverse),/phase)
    intensitypp(i,*)=intensitypp(i,*)-intensitypp(i,0)
    ;flowpp(i,*)=flowpp(i,*)-flowpp(i,0)
     endfor
     
jumpimg, intensitypp
jumpimg, flowpp
intensitypp(ind3, *)=0.0
flowpp(ind3,*)=0.0
intensitypa(ind3, *)=0.0
flowpa(ind3,*)=0.0


flowpps=reform(flowpp(*,4))
ind6=where(flowpps ne 0.0)
phadf=make_array(fs(0),value=0.0)
for j=ind6(0),ind6(n_elements(ind6)-1) do begin
  fm=min(abs(reform(flowpa(j,*))),fidx)
  im=min(abs(reform(intensitypa(j,*))),iidx)
  phadf(j)=intensitypp(j,iidx)-flowpp(j,fidx)
  endfor
  


!p.multi=[0,2,2]
!p.charsize=1
imgplot, intensitypa, findgen(512)*10.0/511-5.0,findgen(ps)*!pi*2/(ps-1), title='Intensity amplitude',xtitle='Radius/cm',ytitle='Phase/radians',/cb,xr=[-5,5],yr=[0,!pi*2]
imgplot, intensitypp, findgen(512)*10.0/511-5.0,findgen(ps)*!pi*2/(ps-1),pal=-2, title='Intensity phase/radians',xtitle='Radius/cm',ytitle='Phase/radians',/cb,xr=[-5,5],yr=[0,!pi*2],zr=[-2*!pi,2*!pi]
imgplot, smooth(flowpa,[4,8]), findgen(512)*10.0/511-5.0,findgen(ps)*!pi*2/(ps-1), title='Flow amplitude/(m/s)',xtitle='Radius/cm',ytitle='Phase/radians',/cb,xr=[-5,5],yr=[0,!pi*2]
imgplot, flowpp, findgen(512)*10.0/511-5.0,findgen(ps)*!pi*2/(ps-1),pal=-2, title='Flow phase/radians',xtitle='Radius/cm',ytitle='Phase/radians',/cb,xr=[-5,5],yr=[0,!pi*2],zr=[-2*!pi,2*!pi]
endif
stop
;phase noise analysis
wavelength=486.133
xs=512
ys=512
sz=24*1e-6
f=135.0
bdeltan=bbo(wavelength, kapa=kapa)
kapab=kapa
ldeltan=linbo3(wavelength, kapa=kapa)
kapal=kapa
op1=waveplateb_gel(wavelength,20.0,!pi/2,f,sz,xs,ys)*kapab-waveplatel_gel(wavelength,5.0,0.0,f,sz,xs,ys)*kapal
op2=waveplateb_gel(wavelength,20.0,0.0,f,sz,xs,ys)*kapab-waveplatel_gel(wavelength,5.0,!pi/2,f,sz,xs,ys)*kapal
mimg=op1+op2+displacer_gel(wavelength,3.0,!pi/2,f,sz,xs,ys)*kapab
stop
mdata=500*cos(mimg)+2000
noise=make_array(512,512,value=50.0*350/200)
;mdata=mdata;+POIDEV(noise)
m1data=mdata+POIDEV(noise)
fmdata=fft(mdata*han,/center)
fm1data=fft(m1data*han,/center)
fm1data1=fm1data
fmdata1=fmdata
fmdata(*,0:210)=0.0
fmdata(*,230:*)=0.0
fmdata1(*,0:250)=0.0
fmdata1(*,270:*)=0.0

fm1data(*,0:210)=0.0
fm1data(*,230:*)=0.0
fm1data1(*,0:250)=0.0
fm1data1(*,270:*)=0.0

mintensity=abs(fft(fmdata1,/center,/inverse))
m1intensity=abs(fft(fm1data1,/center,/inverse))
mcontrast=2.0*abs(fft(fmdata,/center,/inverse))/mintensity
m1contrast=2.0*abs(fft(fm1data,/center,/inverse))/m1intensity
mphase=atan(fft(fmdata,/center,/inverse),/phase)
m1phase=atan(fft(fm1data,/center,/inverse),/phase)
mphasep=mphase-(mphase+m1phase)/2.0
mcontrastp=mcontrast-(mcontrast+m1contrast)/2.0



stop
end