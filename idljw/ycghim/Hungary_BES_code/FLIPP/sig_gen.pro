pro sig_gen, npoints=npoints,modfrequency=modfrequency,rel_modampl=rel_modampl,rel_noise=rel_noise,$
                      offset_microsec=offset_microsec,sampletime=sampletime,timerange=timerange,$
                      mod_event_density=mod_event_density,turb_event_density=turb_event_density,one_point=one_point,$
                      linear_vel=linear_vel,gamlike_velfield=gamlike_velfield,excit_ch_ampl=excit_ch_ampl,$
                      vel_gen_name=vel_gen_name,sig_gen_1_name=sig_gen_1_name,sig_gen_2_name=sig_gen_2_name,ch=ch,$
                      BES_noise=BES_noise, growing_gams=growing_gams,smpl0=smpl0,kernel_type=kernel_type,kernel_asymmetric=kernel_asymmetric,$
                      kernel_vel_symmetric=kernel_vel_symmetric,silent=silent,amplifier_inttime=amplifier_inttime,corr_period=corr_period,$
                      corr_decay=corr_decay,amp_mod_mode=amp_mod_mode,amp_mod_amp=amp_mod_amp,signal_rel_flucamp=signal_rel_flucamp,ptg=ptg,$
                      gam_excitation_int_time=gam_excitation_int_time


;-------------------------------------------------------------------------------------------------------------------
; Authors: Laszlo Bardoczi and Sandor Zoletnik
;          (MTA KFKI RMKI PFFO)
;          date:  2010.07.08.

; Description:
;
;   PART I.: GENERATION OF THE FUNDAMENTAL SIGNAL
;   This program simulates measurement signals corresponding to infinite lifetime turbulence structures moving across
;   one ore two measurement points with a temporally varying velocity. The velocity consists of a constant plus a GAM-like random
;   modulation. First a kernel function is generated which modells one turbulent structure. This can be a quasi-coherent
;   structure (exponentially decaying sinusoidal) or a monotonic decaying function, symmetric or asymmetric. The decay time and
;   the number of periodicity can be set by the user. The default is a symmetric quasi-coherent structure, from which the signal yields an
;   autocorrelaiton function, power spectra and amplitude probability density function similar to those computed
;   from the TEXTOR edge BES data. The excitation signal of this kernel is generated the following way, A series of normally
;   distributed random numbers and a series of uniformly distributed
;   numbers are generated. Where the value of an element in the uniformly distributed series does not reach a certain value
;   (defined by 'turb_event_density'), the element of the corresponding place in the normally distributed
;   series is set to zero. This way the density of the excitation is handled whithout changing the symmetry of the
;   amplitude probability density function. Then the kernel is convolved with this modified normally distributed series.
;   By this a series of turbulent structures is generated along a spatial coordinate with normally distributed amplitude with
;   a high spatial resolution (defined by smpl0*sampletime), called "fundamental signal".
;   In the nex step the velocity is generated as follows.
;
;   PART II.: GENERATION OF THE VELOCITY (POLOIDAL) AND THE SIMULATED TURBULENCE SIGNALS
;   The velocity is generated similarly to the series of the quasi-coherent structures. A sine with exponential amplitude
;   (this can be decaying or growing) is convolved with a manipulated normally distributed series. The frequency can be set by
;   modfrequency, the amplitude by rel_modampl. The velocity signal itself does not contain a noise component.
;   Since s(t)=integral(v(t)dt)), the velocity is integrated, yielding the spatial coordinates, where the fundamental signals
;   has to be sampled. First the fundamental signal is sampled with this s(t), yielding sig_gen_1. Then with a spatial shift of dx
;   (the mean time delay is handled by "offset_microsec") the fundamental signal is sampled again, yielding sig_gen_2.
;
;   The fluctuation amplitude can be modulated as well. If amp_mod_mode='GAM' then scaled velocity signal is used for modulation:
;   the velocity signal is divided by its mean and multiplied by the amp_mod_amp value. The turbulence signal is modulated by the
;   resulting modulation signal.
;
;   Finally the mean value and the variance of the signals are set, and independent white noise is added to the signals.
;
;   The generated singals are saved in the signal cache.
;
;   OPTIONAL: GENERATING A VELOCITY FIELD ALONG THE RADIAL COORDINATE
;   If the keyword "gamlike_velfield" is set, then the program generates velocity signals as follows.
;   The invoking program should set the parameter channel number and call this sig_gen program multiple times.
;   Than this program generates velocity signals for n channels, where
;   the radial correlation of the GAM excitation can be handled through "excit_ch_ampl". The frequency of the GAM oscillations can be
;   set independently. The atomic effect of the beam can also be modelled, by creating the signals with 0 noise level, than making the
;   integration along the radial coordinate, and finally setting the correct mean values and variances.
;
;   OPTIONAL: GENERATING LINEARLY CHANGING VELOCITY (USED ONLY FOR TESTS)
;   If the keyword "linear_vel" is set, then the program generates linearly (and slowly) changing velocity with zero mean value. The
;   maximum and minimum can be set by rel_modampl.
;
; INPUT and OUTPUT parameters:
;
; Paramaters of turbulence signals
;   timerange: timerange of the simulated signal [s]
;   smpl0: Oversampling of the fundamental signal relative to sampletime
;   sampletime: sampletime of the simulated signal [s]
;   kernel_type: type of kernel functions (modelling turublence structures); can be 'qc'(quasi-coherent) or 'monotonic'
;   corr_period: period time of waves of the kernel if it is 'qc' [s]
;   corr_decay: time constant of the exponentials in the kernel functions [s]
;   turb_event_density: density of turbulence events in the simulated signals, range: [0,1]
;   signal_rel_flucamp: relative fluctuation amplitude of signal
;   sig_gen_1_name: name of the first simulated signal when saved in the cache
;   sig_gen_2_name: name of the second simulated signal when saved in the cache
;
;  Parameters of the noise
;   rel_noise: relative noise level (NSR, noise amplitude/light fluctuation amplitude)
;   amplifier_inttime: integration time of the noise, that is the signal amplifier in the simulated measurement [s]
;   corrdecay_noise: decay time constant of the noise
;
;  Parameters of the velocity
;   modfrequency: frequency of velocity modulations [kHz]
;   rel_modampl: relative modulation amplitude of the velocity (compared to the mean value)
;   corrdecay_vel: decay time constant of the velocity kernel [s]
;   mod_event_density: density of velocity modulation events in time, D=[0,1]
;   offset_microsec: mean time delay between the to generated signals
;   vel_gen_name: name of the generated velocity, when saved in the cache
;   ch: serial number of the channel where the signals are beeing generated (needed only when the keyword "gamlike_velfield" is set)
;   gam_excitation_int_time: integration time of GAM excitation in microsec, used only if the whole velocity field is generated (at "gamlike_velfield")
;
;  Keywords:
;   /silent: do not write anything on the screen
;   /kernel_asymmetric: makes asymmetric kernel of turbulence (the default is symmetric)
;   /kernel_vel_symmetric: makes symmetric kernel of velocity modulations (the default is asymmetric, decaying)
;   /linear_vel: generates linearly changing velocity (defined as: mean=0, max=abs(min)=rel_modampl)
;   /gamlike_velfield: generating velocity signals over more than one channel along the radial coordinate
;   /growing_gams: modelling growing gams instead of decaying ones
;   /BES-noise: simulating the noise of the detectors more accurately than simply adding white noise to the signals
;   /one_point: if only one signal should be generated (to spare time if only one signal is needed and the sampling frquency is hight)
;
;-------------------------------------------------------------------------------------------------------------------------------------

; Parameters of the turbulencesignals
default,timerange,[0,0.1]
trange=timerange
trange[1]=trange[1]+0.002
default,timelength,trange[1]-trange[0]
default,sampletime,24e-7		;[s]
default,npoints,long(timelength/sampletime)		;[points]
default,starttime,timerange[0]     ;[s]
default,smpl0,1
default,kernel_sigma,10e-6*2
default,kernel_type,'qc'
default,corr_period,11*1e-6*2
default,corr_decay,5*1e-6
default,turb_event_density,1
default,signal_rel_flucamp,0.05  ; Relative fluctuation amplitude of signal
default,sig_gen_1_name,'sig_gen_1'
default,sig_gen_2_name,'sig_gen_2'
; Parameters of noise
default,rel_noise,0.0     ;[fraction]
default,amplifier_inttime,0.3*1e-6
default,corrdecay_noise,1*1e-4
; Parameters of velocity modulations
default,modfrequency,15.	;[kHz]
modfr=modfrequency*(4e-6*2*3.1415*1000)
default,rel_modampl,0.20
default,corrdecay_vel,2e-4;2e-4 ;24e-4[s]
default,mod_event_density,1 ; between [0,1]
default,offset_microsec,5
default,vel_gen_name,'vel_gen'
default,ch,0
default,amp_mod_mode,'GAM'
default,amp_mod_amp,0
default,gam_excitation_int_time,sampletime
; end of parameters list

if not keyword_set(silent) then print,'Started (sig_gen.pro).'

; Generating the kernel function of the turbulence signals
if not keyword_set(silent) then print,'Generating kernel of turbulence structures ...'
; Generating quasi-coherent turbulent structure
if kernel_type eq 'qc' then begin
   exp_time=findgen(corr_decay*1e7/sampletime*1e-6*smpl0)*sampletime/smpl0
   wave_time=findgen(corr_decay*1e7/sampletime*1e-6*smpl0)*sampletime/smpl0*2*!pi
   if not keyword_set(kernel_asymmetric) then begin
      kernel=exp(-exp_time/corr_decay)*cos(wave_time/corr_period)
      kernel_2=dblarr(n_elements(kernel)*2-1)
      kernel_2[0:n_elements(kernel)-2]=reverse(kernel[1:n_elements(kernel)-1])
      kernel_2[n_elements(kernel)-1:n_elements(kernel)*2-2]=(kernel)
      kernel=kernel_2
   endif
   if keyword_set(kernel_asymmetric) then begin
      kernel=exp(-exp_time/corr_decay)*sin(wave_time/corr_period)
   endif
endif
;  Generating monotonic structure
if kernel_type eq 'monotonic' then begin
   exp_time=findgen(corr_decay*1e8/sampletime*1e-6*smpl0)*sampletime/smpl0
   if not keyword_set(kernel_asymmetric) then begin
      kernel=exp(-(exp_time/(4*corr_decay)))+0.1*exp(-(exp_time/(40*corr_decay)))
      kernel_2=dblarr(n_elements(kernel)*2-1)
      kernel_2[0:n_elements(kernel)-2]=reverse(kernel[1:n_elements(kernel)-1])
      kernel_2[n_elements(kernel)-1:n_elements(kernel)*2-2]=(kernel)
      kernel=kernel_2-min(kernel_2)
   endif
   if keyword_set(kernel_asymmetric) then begin
      kernel=exp(-(exp_time/(kernel_sigma)))+0.1*exp(-(exp_time/(10*kernel_sigma)))
   endif
endif
if not keyword_set(silent) then print,'Generating the fundamental signal ...'
; generating the series of normally distributed random numbers:
signal0=randomn(seed,npoints*smpl0)
; manipulating the previous series as to handle the density of turbulence events in time
if turb_event_density lt 1 then begin
   noise_uniform=randomu(seed,npoints*smpl0)
   signal0(where(noise_uniform gt turb_event_density))=0
endif

; doing the convolution, generating the fundamental signal (series of structures along the spatial coordinate)
; this "reverse" is needed since the "convol" of the IDL reverses the kernels, and so they should be "re-reversed" before the convolution
if keyword_set(kernel_asymmetric) then begin
   kernel=reverse(kernel)
endif
signal0 = convol(signal0,kernel)

; generating linearly changing velocity
if keyword_set(linear_vel) then begin
   if not keyword_set(silent) then print,'Generating linearly changing velocity ...'
   genvelmod=findgen(npoints)
   genvelmod=genvelmod-mean(genvelmod)
   genvelmod=1+genvelmod/max(genvelmod)*rel_modampl
endif

; generating a GAM-like velocity modulation:
if not keyword_set(linear_vel) and not keyword_set(gamlike_velfield) then begin
   if not keyword_set(silent) then print,'Generating GAM-like velocity ...'
   genvelmod=1
   vel_time=findgen(corrdecay_vel*5./sampletime)*sampletime
   if not keyword_set(kernel_vel_symmetric) then begin
      kernel_vel=exp(-vel_time/corrdecay_vel)*cos(2*!pi*modfrequency*1e3*vel_time)
      kernel_vel=reverse(kernel_vel)
      if keyword_set(growing_gams) then begin
         kernel_vel=reverse(kernel_vel)
      endif
   endif
   if keyword_set(kernel_vel_symmetric) then begin
      kernel_vel = exp(-abs(vel_time-mean(vel_time))/corrdecay_vel)*cos(2*!pi*modfrequency*1e3*vel_time)
   endif
   noise_vel=randomn(seed,npoints)
   if mod_event_density lt 1 then begin
      noise_vel_uniform=randomu(seed,npoints)
      noise_vel(where(noise_vel_uniform gt mod_event_density))=0
   endif
   fluct_vel=convol(noise_vel,kernel_vel)
   fluct_vel=fluct_vel/sqrt(variance(fluct_vel))
   genvelmod=genvelmod*(1+rel_modampl*fluct_vel)
endif

if keyword_set(gamlike_velfield) then begin
   if not keyword_set(silent) then print,'Generating the GAM-like velocity field ...'
   signal_cache_get,data=noise_vel,starttime=starttime,sampletime=sampletime,name='noise_vel', errormess=errormess
   if (errormess ne '') then begin
      noise_vel=randomn(seed,npoints)
      if mod_event_density lt 1 then begin
         noise_vel_uniform=randomu(seed,npoints)
         noise_vel(where(noise_vel_uniform gt mod_event_density))=0
         noise_vel=integ(noise_vel,gam_excitation_int_time/sampletime)
      endif
      signal_cache_add,starttime=starttime,sampletime=sampletime,data=noise_vel,name='noise_vel',errormess=errormess
      if (errormess ne '') then begin
         print, errormess
         return
      endif
   endif
   noise_vel_loc=randomn(seed,n_elements(noise_vel))
   if mod_event_density lt 1 then begin
      noise_vel_uniform=randomu(seed,npoints)
      noise_vel_loc(where(noise_vel_uniform gt mod_event_density))=0
      noise_vel_loc=integ(noise_vel_loc,gam_excitation_int_time/sampletime)
   endif
   ; eltolás (ideiglenesen most beleirom):
      nelem=n_elements(noise_vel)
      noise_vel_temp=dblarr(nelem)
      noise_vel_temp(0:nelem-1-ptg/sampletime)=noise_vel(ptg/sampletime:nelem-1)
      noise_vel=noise_vel_temp
   ; eddig van beleirva
   noise_vel=noise_vel*(1-excit_ch_ampl)+noise_vel_loc/sqrt(variance(noise_vel_loc))*sqrt(variance(noise_vel))*excit_ch_ampl
   noise_vel=noise_vel/max(noise_vel)
   signal_cache_add,starttime=starttime,sampletime=sampletime,data=noise_vel,name='noise_vel',errormess=errormess
   if (errormess ne '') then begin
      print, errormess
      return
   endif
   signal_cache_add,starttime=starttime,sampletime=sampletime,data=noise_vel,name='noise_vel_ch_'+i2str(ch),errormess=errormess
   if (errormess ne '') then begin
      print, errormess
      return
   endif
   genvelmod=1
   vel_time=findgen(corrdecay_vel*5./sampletime)*sampletime
   if not keyword_set(kernel_vel_symmetric) then begin
     kernel_vel=exp(-vel_time/corrdecay_vel)*cos(2*!pi*modfrequency*1e3*vel_time)
     kernel_vel=reverse(kernel_vel)
     if keyword_set(growing_gams) then begin
        kernel_vel=reverse(kernel_vel)
     endif
   endif
   if keyword_set(kernel_vel_symmetric) then begin
      kernel_vel = exp(-abs(vel_time-mean(vel_time))/corrdecay_vel)*cos(2*!pi*modfrequency*1e3*vel_time)
   endif
   fluct_vel=convol(noise_vel,kernel_vel)
   fluct_vel=fluct_vel/sqrt(variance(fluct_vel))
   genvelmod=genvelmod*(1+rel_modampl*fluct_vel)
endif

;ind2=ind1+genvelmod+0.5  ; half sample period delay to simulate deflected beam measurement

; generating the integrated genvelmod
if not keyword_set(silent) then print,'Generating the spatial coordinates of sampling (integrating velocity) ...'
genvelmod_integ=dblarr(n_elements(genvelmod))
genvelmod_integ[0]=genvelmod[0]
for t=1l,n_elements(genvelmod)-1 do begin
	genvelmod_integ[t]=genvelmod_integ[t-1]+genvelmod[t]
end

; sampling the first signal
if not keyword_set(silent) then print,'Sampling the first signal ...'
sig_gen_1=interpolate(signal0,smpl0*(genvelmod_integ+offset_microsec*1e-6/sampletime))
if (keyword_set(amp_mod_amp)) then begin
   if (amp_mod_mode eq 'GAM') then begin
      modsig = (genvelmod/mean(genvelmod)-1)*amp_mod_amp+1
      sig_gen_1 = sig_gen_1*modsig
   endif
endif
; adding random noise to the first signal:
noise_signal = randomn(seed,timelength/sampletime)
if (keyword_set(amplifier_inttime)) then begin
  noise_signal = integ(noise_signal,amplifier_inttime/sampletime)
endif

sig_gen_1=sig_gen_1+sqrt(variance(sig_gen_1))/sqrt(variance(noise_signal))*rel_noise*noise_signal
; Adding mea level to the first signal
sig_gen_1 = sig_gen_1+sqrt(variance(sig_gen_1))*(1./signal_rel_flucamp)

; generation of the second signal (needed only at simulations of two point measurements)
if not keyword_set(one_point) then begin
   ; sampling the second signal:
   if not keyword_set(silent) then print,'Sampling the second signal ...'
   sig_gen_2=interpolate(signal0,smpl0*(genvelmod_integ))
   if (keyword_set(amp_mod_amp)) then begin
      if (amp_mod_mode eq 'GAM') then begin
         sig_gen_2 = sig_gen_2*(genvelmod/mean(genvelmod))
      endif
   endif
   ; adding random noise to sig_gen_2:
   noise_signal = randomn(seed,1/sampletime)
   if (keyword_set(amplifier_inttime)) then begin
      noise_signal = integ(noise_signal,amplifier_inttime/sampletime)
   endif
   sig_gen_2=sig_gen_2+sqrt(variance(sig_gen_2))/sqrt(variance(noise_signal))*rel_noise*noise_signal
   ; adding DC level to the second signal
   sig_gen_2 = sig_gen_2+sqrt(variance(sig_gen_2))*(1./signal_rel_flucamp)
endif


if not keyword_set(silent) then print,'Adding signals to the cache ...'

sig_gen_1=sig_gen_1(0.001/sampletime:(timelength-0.001)/sampletime)
signal_cache_add,starttime=starttime, sampletime=sampletime, data=double(sig_gen_1), name=sig_gen_1_name,errormess=e
if (e ne '') then begin
   print,e
	 return
endif

if not keyword_set(one_point) then begin
   sig_gen_2=sig_gen_2(0.001/sampletime:(timelength-0.001)/sampletime)
	 signal_cache_add,starttime=starttime, sampletime=sampletime, data=double(sig_gen_2), name=sig_gen_2_name,errormess=e
	 if (e ne '') then begin
		  print,e
	    return
	 endif
endif

genvelmod=genvelmod(0.001/sampletime:(timelength-0.001)/sampletime)
signal_cache_add,starttime=starttime, sampletime=sampletime, data=double(genvelmod), name=vel_gen_name,errormess=e
if (e ne '') then begin
   print,e
   return
endif

if not keyword_set(silent) then print,'Finished (sig_gen.pro).'

end