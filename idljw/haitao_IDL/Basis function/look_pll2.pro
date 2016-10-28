pro look_pll2,twin,win=win
; data analysis of gate time delay using camera.
pmtfile='C:\haitao\papers\PMT camera\coherence data\data\data 02-06-2014\pll22.sav'
restore, pmtfile
deltat=1*1e-6
time=reform(data(0,*))
dc=reform(data(1,*))
sq=reform(data(2,*))
gate=reform(data(3,*))
osc=reform(data(4,*))
ind=where(gate ge max(gate)/2.0)
indd=abs(ind(1:*)-ind(0:n_elements(ind)-2))
pind=where(indd ge max(indd)*0.8)
tcycle=(ind(pind(2))-ind(pind(1)))*deltat
toff=(ind(pind(1)+1)-ind(pind(1)))*deltat
ton=tcycle-toff
st=ind(pind(0))*deltat-ton

phat=make_array(8,/float)
lockac=make_array(8,/float)
for i=0,7 do begin
  ti=st+tcycle*i
  ind1=where(time ge ti and time lt ti+ton)
  gate1=-gate(ind1)
  oscs=osc(ind1)
  
  hoscs=hilbert(oscs)
  phas=atan(real_part(hoscs),oscs)
  ind2=peaks(gate1,20)
  lockac(i)=total(osc(ind1(ind2)))
  phat(i)=mean(phas(ind1(ind2)))
  endfor

tn=n_elements(time)/50
tfd=make_array(50,tn/2.0+1)
for j=0,49 do begin
  sig=osc(tn*j:tn*(j+1)-1)
  pow=abs(fft(sig))
  tfd(j,*)=pow(0:tn/2.0)
  endfor
freq=findgen(tn/2.0+1)/tn/deltat
;the whole data set analysis
if win eq 1 then begin
  !p.multi=[0,1,2]
  plot, lockac,title='Locked signal intensity for frames'
  imgplot, tfd, findgen(50)*1.0/49.0, freq/1000.0, title='Time frequency distribution of the signal',xtitle='Time/s',ytitle='Freq/kHz',yr=[0,50]
  endif
 stop
 ;specific time interval analysis 
indx=where(time ge twin(0) and time lt (twin(1)))
dc=dc(indx)
sq=sq(indx)
gate=gate(indx)
osc=osc(indx)

gatep=-gate
indx1=where(gatep lt 0.0)
gatep(indx1)=0.0
gatep=gatep/max(gatep)
osc1=osc/max(abs(osc))

hosc=hilbert(osc1)
pha=atan(real_part(hosc),osc1)
if win eq 2 then begin
  !p.multi=[0,2,4]
  plot, gate, title='Raw pulse signal from camera'
  plot, osc, title='Raw pmt signal'
  plot, sq, title='Raw ectified pmt signal'
  plot, osc1, title='Normalized pmt signal and pulse'
  oplot, gatep,color=3
 plot, osc1, title='Normalized pmt signal and Hilbert transform'
 oplot, real_part(hosc),color=3
 plot, pha, title='Phase of the signal'
 oplot, gatep*3, color=3
 indx2=where(gatep gt max(gatep)*0.68)
 plot, pha(indx2),title='Locked phase of pulse',yrange=[-!pi,!pi]
 endif 
  
  

  
camfile='C:\haitao\papers\PMT camera\coherence data\data\data 02-06-2014\test22.spe'
read_spe, camfile, lam, t1,d,texp=texp,str=str,fac=fac & d=float(d)


stop
end