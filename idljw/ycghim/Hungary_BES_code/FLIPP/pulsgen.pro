pro pulsgen,n,photon_rate=photon_rate,inttime=inttime,timeinterval=timeint,dclevel=dclevel

; Generates a test signal from overlaid Gaussian pulses.
; HWFM=50 microsec
; Will generate 1 sec signal with 1 microsec time resolution
; 
; INPUT:
;  n: number of pulses (amplitude=1)
;  photon_rat: average number of detected photons/sec (default: no photon noise)
;  inttime: integration time of detector in sec
;  timeinterval: length of time interval in sec.
;  dclevel: DC signal level
;
; OUTPUT:
;  writes simulated signal to shot 10000, channel 9, data_source=0

default,photon_rate,0
default,inttime,1e-6
default,timeint,1
default,dclevel,0

np =1000000l*timeint
s = fltarr(np)

if (n ne 0) then begin
  t0v=fltarr(n)
  for i=0l,n-1 do begin
    t0 = long(randomu(seed)*(np-220)+110)
    t0v[i] = t0
    ss = exp(-(findgen(201)/50-3)^2)
    s[t0-100:t0+100] = s[t0-100:t0+100]+ss
  endfor
endif
s = s+dclevel


if (photon_rate ne 0) then begin
  photon_noise,s/mean(s)*photon_rate,tres=1e-6,inttime=inttime,outsig=outsig
  s = outsig/photon_rate
endif


wftwrite,'data/10000008.wft',s*0.5,tstart=0,sampletime=1e-6,/over
;r=histogram(t0v,bin=float(np)/1000)
;plot,r
end  
