pro futtat, coherence=coherence, coh_matrix=coh_matrix

;2011.07.03. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=0, frequency=30, ID='hanning-nincs-atlapolas-2'

return

;2011.07.03. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=1, frequency=30, ID='hanning'

return

;2011.07.03. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=0, frequency=30, ID='boxcar'

return

;2011.07.03. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=0, frequency=30, ID='hanning-nincs-atlapolas'

return

;2011.06.30. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=0, frequency=100, ID='hanning-nincs-atlapolas-y-apsd-100'

return


;2011.06.30. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=0, frequency=30, ID='hanning-nincs-atlapolas-y-apsd-ok'

return

;2011.06.30. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=0, frequency=30, ID='boxcar'

return

;2011.06.30. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=1, frequency=30, ID='hanning'

return

;2011.05.12. - SXR_BICOHERENCE
sxr_bicoherence, 24006, 'AUG_SXR/J_053', [1.6100,1.6400], 2048, hann=0, frequency=30, ID='hanning-atlapolas-nelkul-164'

return

;2011.04.01:

coherence=0
coh_matrix=0

nmax=99
imax=499
coh_matrix=dblarr(nmax+1,512)

for n=long(0),long(nmax) do begin

print,n
coherence=0

for i=0,imax do begin

;timeax=dindgen((n+1)*512)
data1=randomn(seed,(n+1)*512,/NORMAL,/DOUBLE)
data2=randomn(seed,(n+1)*512,/NORMAL,/DOUBLE)

cohphase=gp_cohphasef(data1,data2,512,error=1,hann=1)
coh=cohphase[*,0]
phase=cohphase[*,1]

coherence=coherence+coh
end
coherence=coherence/double(imax+1)
coh_matrix[n,*]=coherence
end

return



;2011.02.24: koherencia függvény mit ad az ingadozó jelre
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(1000)
phi_2=random_phi2(1000)
data1=sin(2*!DPI*100d3*timeax+phi_1);+1d-7*randomn(seed,60000,/NORMAL,/DOUBLE)
data2=sin(2*!DPI*100d3*timeax+phi_2);+1d-7*randomn(seed,60000,/NORMAL,/DOUBLE)


cohphase=gp_cohphasef(data1,data2,2048)
coh=cohphase[*,0]
phase=cohphase[*,1]

;print,coh

!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, coh, Title = 'COH'
PLOT, phase, Title = 'PHASE'
PLOT, phi_1, Title = 'PHI-1'
PLOT, phi_2, Title = 'PHI-2'

return

;2011.02.24:
timeax=5d-7*dindgen(60000)
data1=sin(2*!DPI*100d3*timeax)+1d-7*randomn(seed,60000,/NORMAL,/DOUBLE)
data2=sin(2*!DPI*100d3*timeax)+1d-7*randomn(seed,60000,/NORMAL,/DOUBLE)

cohphase=gp_cohphasef(data1,data2,2048)
coh=cohphase[*,0]
phase=cohphase[*,1]

!P.Multi = [0, 1, 2] 
!P.Font = 0 
PLOT, coh, Title = 'COH'
PLOT, phase, Title = 'PHASE'

return

;2011.01.25: koherencia függvény mit ad az ingadozó jelre
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(1000)
phi_2=random_phi2(1000)
data1=sin(2*!DPI*100d3*timeax+phi_1)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
data2=sin(2*!DPI*100d3*timeax+phi_2)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)

cohphase=gp_cohphasef(data1,data2,2048)
coh=cohphase[*,0]
phase=cohphase[*,1]

!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, coh, Title = 'COH'
PLOT, phase, Title = 'PHASE'
PLOT, phi_1, Title = 'PHI-1'
PLOT, phi_2, Title = 'PHI-2'

return

;megpróbálok hasonlót generálni mint az előző
timeax=5d-7*dindgen(60000)
data=2d3*sin(2*!DPI*12500*timeax)
freq_fluct,data,timeax,2048,/plot_apsd,/plot_peak,sigma=0

return


;2011.01.03: SXR
get_rawsignal, 24006, 'AUG_SXR/J_053', timeax, data,trange=[1.6100,1.6400]
freq_fluct,data,timeax,2048,/plot_apsd,sigma=0,/plot_peak

return


r=0*dindgen(200)
average=0*dindgen(50)
dev=0*dindgen(50)

for i=0,49 do begin
  
  for j=0,199 do begin
  sigma=i*20d0
  timeax=5d-7*dindgen(60000)
  phi_1=random_phi2(sigma)
  data=sin(2*!DPI*12500*timeax+phi_1);+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
  freq_fluct,data,timeax,2048,sigma=sigma, width=width
  r[j]=width
  endfor

  average[i]=mean(r)
  dev[i]=stdev(r)
endfor

return


;2011.01.03.:


r=0d0*dindgen(200)
average=0*dindgen(10)
dev=0*dindgen(10)

for i=0,9 do begin

  for j=0,199 do begin
  sigma=0d0
  timeax=5d-7*dindgen(60000)
  phi_1=random_phi2(sigma)
  data=sin(2*!DPI*12500*timeax+phi_1)+(0.5d0*i)*randomn(seed,60000,/NORMAL,/DOUBLE)
  freq_fluct,data,timeax,2048,sigma=sigma, width=width
  r[j]=width
  endfor

  average[i]=mean(r)
  dev[i]=stdev(r)

endfor

return



r=0d0*dindgen(200)

  for j=0,199 do begin
  sigma=0d0
  timeax=5d-7*dindgen(60000)
  phi_1=random_phi2(sigma)
  data=sin(2*!DPI*12500*timeax+phi_1);+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
  freq_fluct,data,timeax,2048,sigma=sigma, width=width
  r[j]=width
  endfor
  average=mean(r)
  dev=stdev(r)

return


r=0*dindgen(200)
average=0*dindgen(50)
dev=0*dindgen(50)

for i=0,49 do begin
  
  for j=0,199 do begin
  sigma=i*20d0
  timeax=5d-7*dindgen(60000)
  phi_1=random_phi2(sigma)
  data=sin(2*!DPI*200000*timeax+phi_1);+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
  freq_fluct,data,timeax,2048,sigma=sigma, width=width
  r[j]=width
  endfor

  average[i]=mean(r)
  dev[i]=stdev(r)
endfor

return


r=0*dindgen(100)
average=0*dindgen(20)
dev=0*dindgen(20)

for i=1,20 do begin
  
  for j=1,100 do begin
  sigma=i*20d0
  timeax=5d-7*dindgen(60000)
  phi_1=random_phi2(sigma)
  data=sin(2*!DPI*200000*timeax+phi_1);+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
  freq_fluct,data,timeax,2048,sigma=sigma, width=width
  r[j-1]=width
  endfor

  average[i-1]=mean(r)
  dev[i-1]=stdev(r)
endfor

return

;-------------

for i=1,10 do begin


sigma=75d0
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(sigma)
data=sin(2*!DPI*12500*timeax+phi_1)
freq_fluct,data,timeax,2048,sigma=sigma

endfor

return

sigma=75d0
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(sigma)
data=sin(2*!DPI*12500*timeax+phi_1)
freq_fluct,data,timeax,2048,sigma=sigma,/plot_peak

return

for i=1,10 do begin

wait,1

sigma=75d0
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(sigma)
data=sin(2*!DPI*12500*timeax+phi_1)
freq_fluct,data,timeax,2048,sigma=sigma,/plot_peak

endfor

return


;2010.12.29.:

r=0*dindgen(1000)
average=0*dindgen(100)

for i=1,100 do begin
  
  for j=1,1000 do begin
  sigma=i*10
  timeax=5d-7*dindgen(60000)
  phi_1=random_phi2(sigma)
  data=sin(2*!DPI*200000*timeax+phi_1)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
  freq_fluct,data,timeax,2048,sigma=sigma, width=width
  r[j-1]=width
  endfor

  average[i-1]=mean(r)
endfor

return

;2010.12.29.:

r=dindgen(2000)

for i=1,2000 do begin
sigma=500
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(sigma)
data=sin(2*!DPI*200000*timeax+phi_1)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
freq_fluct,data,timeax,2048,sigma=sigma, width=width
r[i-1]=width
endfor

return

;2010.12.29.:

r=dindgen(2000)

for i=1,2000 do begin
sigma=i
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(sigma)
data=sin(2*!DPI*200000*timeax+phi_1)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
freq_fluct,data,timeax,2048,sigma=sigma, width=width
r[i-1]=width
endfor

return


;2010.12.29.:

for i=1,100 do begin
sigma=i
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(sigma)
data=sin(2*!DPI*200000*timeax+phi_1)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
freq_fluct,data,timeax,2048,sigma=sigma
endfor

return

;2010.12.29.
get_rawsignal, 24006, 'AUG_SXR/J_053', timeax, data,trange=[1.6100,1.6400]
freq_fluct,data,timeax,2048,/plot_apsd,sigma=0

return

;2010.12.29.-hajnal: a képek elnevezése változott (sigma=sigma)
sigma=2
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(5000)
data=sin(2*!DPI*12500*timeax+phi_1)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
freq_fluct,data,timeax,2048,/plot_apsd,sigma=sigma

return

;2010.12.29.-hajnal: megpróbálok hasonlót generálni mint az előző
timeax=5d-7*dindgen(60000)
phi_1=random_phi2(300)
data=sin(2*!DPI*12500*timeax+phi_1)+0.1*randomn(seed,60000,/NORMAL,/DOUBLE)
freq_fluct,data,timeax,2048,/plot_apsd

return

;2010.12.29.-hajnal: vajon mit kezd az sxr-jelekkel? egész jó lett :)
get_rawsignal, 24006, 'AUG_SXR/J_053', timeax, data,trange=[1.6100,1.6400]
freq_fluct,data,timeax,2048,/plot_apsd

return

t=dindgen(65536)*0.00001
phi_1=random_phi2(1)
data=sin(2*!DPI*10000*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
freq_fluct,data,t,2048

t=dindgen(65536)*0.00001
phi_1=random_phi2(5)
data=sin(2*!DPI*10000*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
freq_fluct,data,t,2048

t=dindgen(65536)*0.00001
phi_1=random_phi2(10)
data=sin(2*!DPI*10000*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
freq_fluct,data,t,2048

return

t=dindgen(65536)*0.00001
phi_1=random_phi2(8)
data=sin(2*!DPI*10000*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
freq_fluct,data,t,2048

return

t=dindgen(65536)*0.001
phi_1=random_phi2(8)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
freq_fluct,data,t,2048

return

t=dindgen(65536)*0.001
phi_1=random_phi2(5)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
freq_fluct,data,t,2048

return

t=dindgen(65536)*0.001
phi_1=random_phi2(5)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
freq_fluct,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi2(5)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi2(5)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi2(10)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi2(1)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi2(0.1)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi(0.5)
data=sin(2*!DPI*100*t)+sin(2*!DPI*200*t)
plot_bicoherence,data,t,512,ID='test',shotnumber='003'

return

t=dindgen(65536)*0.001
phi_1=random_phi(0.5)
data=sin(2*!DPI*100*t)+sin(2*!DPI*200*t)
plot_bicoherence,data,t,512,ID=test,shotnumber='002'

return

t=dindgen(65536)*0.001
phi_1=random_phi(0.5)
data=sin(2*!DPI*100*t+phi_1)+sin(2*!DPI*200*t+phi_1)
plot_bicoherence,data,t,512,ID=test,shotnumber='001'

return

t=dindgen(65536)*0.001
phi_1=random_phi(0.5)
data=sin(2*!DPI*100*t+phi_1)+sin(2*!DPI*200*t+phi_1)
apsd,data,t,512

return

t = DINDGEN(65536)*0.01
; Set up the values of the independent variable. 
y = [0,1,0,1] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

data=y(0,*)
plot_bicoherence,data,t,512,ID='van_der_pol_e(1,1)_c(0.2,0.2)',/hun
return

t = DINDGEN(65536)*0.001
; Set up the values of the independent variable. 
y = [0,1,0,1] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

data=y(0,*)
plot_bicoherence,data,t,512,ID='van_der_pol_e(1,1)_c(0.2,0.2)',/hun
return

t = DINDGEN(65536)
; Set up the values of the independent variable. 
y = [0,1,0,1] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

data=y(0,*)
plot_bicoherence,data,t,512,ID='van_der_pol_e(0.1,1)_c(0.5,0.5)',/hun


return

t = DINDGEN(65536)*0.1
; Set up the values of the independent variable. 
y = [0,1,0,1] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

return


t = DINDGEN(100)
; Set up the values of the independent variable. 
y = [1,2,3,4] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

return

t = DINDGEN(100)
; Set up the values of the independent variable. 
y = [1,0,1,0] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

return
t = DINDGEN(100)
; Set up the values of the independent variable. 
y = [0,1,0,1] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

return

t = DINDGEN(100)
; Set up the values of the independent variable. 
y = [1,0,1,0] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

return

t = DINDGEN(500)
; Set up the values of the independent variable. 
y = [1,0,1,0] 
; Set the initial values. 
y = IMSL_ODE(t, y, 'van_der_pol', /R_K_V,MAX_STEPS = 1D6, /Double) 
; Call IMSL_ODE. 
!P.Multi = [0, 2, 2] 
!P.Font = 0 
PLOT, t, y(0, *)
PLOT, t, y(1, *)
PLOT, t, y(2, *)
PLOT, t, y(3, *)
; Plot each variable on a separate axis. 

return

t=dindgen(65536)*0.001
phi_1=random_phi(10)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return


t=dindgen(65536)*0.001
phi_1=random_phi(1)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi(0.5)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
phi_1=random_phi(0.1)
data=sin(2*!DPI*100*t+phi_1)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
data=sin(2*!DPI*100*t)+0.1*randomn(seed,65536,/NORMAL,/DOUBLE)
apsd,data,t,512

return

t=dindgen(65536)*0.001
data=sin(2*!DPI*100*t)
apsd,data,t,512

return

t=dindgen(65536)*0.001
data=sin(2*!DPI*100*t)
apsd,t,data,512

return

t=dindgen(65536)
data=sin(2*!DPI*100*t)
apsd,t,data,512

end