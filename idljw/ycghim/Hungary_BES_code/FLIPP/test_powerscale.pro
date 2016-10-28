pro test_powerscale,relamp=relamp,random=random,sine=sine,absamp=absamp,sampletime=sampletime
;***************************************************************************************
; TEST_POWERSCALE.PRO
; This program tests the amplitude scaling of the fluc_correlation.pro procedure.
; Generates a sine wave or random noise and plots the relative fluctuation amplitude
; as a function of frequecy resolution and integration time.
; INPUT:
;   relamp: The relative fluctuatuon amplitude
;   absamp: The abslute fluctution amolitude
;   sampletime: Time between two samples
;   /sine: generate sine wave
;   /ramdom: generate random noise (default)
;***************************************************************************************

default,relamp,0.1
default,absamp,1.
if (not defined(random) and not defined(sine)) then random = 1
default,sampletime,1e-6

if (keyword_set(random)) then begin
  s=randomn(seed,100000)
endif
if (keyword_set(sine)) then begin
  s=sin(findgen(100000)/1e5*1000)*sqrt(2)
endif
d = s+1./relamp
d=d*absamp
signal_cache_add,data=d,sampletime=sampletime,start=0,name='s',errormess=e
  if (e ne '') then begin
    print,e
    return
  endif

fres_list=[10,20,50,100,200,500,1000]
fres_res = fltarr(n_elements(fres_list))
amp_res = fltarr(n_elements(fres_list))
for i=0,n_elements(fres_list)-1 do begin
  fluc_correlation,0,ref='cache/s',timerange=[0,0.1],interv=1,fres=fres_list[i],outfscale=f,outpower=p,mean_ref=mean_ref,/plot_power,errormess=e,/noplot
  if (e ne '') then begin
   ; print,e
    return
  endif
  fres_out=f[1]-f[0]
  fres_res[i]=fres_out
  amp_res[i] = sqrt(total(p)*2*fres_out)/mean_ref
endfor

window,0
plotsymbol,0
plot,fres_res,amp_res,xstyle=1,psym=8,xtitle='Frequency resolution [Hz]',ytitle='Relative fluctuation amplitude'

tlen_list=[0.001,0.002,0.005,0.01,0.02,0.05,0.1]
amp_res = fltarr(n_elements(fres_list))
for i=0,n_elements(fres_list)-1 do begin
  fluc_correlation,0,ref='cache/s',timerange=[0,tlen_list[i]],interv=1,fres=fres_list[i],outfscale=f,outpower=p,mean_ref=mean_ref,/plot_power,errormess=e,/noplot
  if (e ne '') then begin
   ; print,e
    return
  endif
  fres_out=f[1]-f[0]
  fres_res[i]=fres_out
  amp_res[i] = sqrt(total(p)*2*fres_out)/mean_ref
endfor

window,1
plotsymbol,0
plot,tlen_list,amp_res,xstyle=1,psym=8,xtitle='Integration time [s]',ytitle='Relative fluctuation amplitude'


end

