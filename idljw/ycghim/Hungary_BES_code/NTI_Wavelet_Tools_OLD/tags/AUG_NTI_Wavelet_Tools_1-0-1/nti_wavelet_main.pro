;+
;
;NAME: nti_wavelet_main
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2011.07.25.
;
; PURPOSE: Calculate scalograms (or spectrograms), cross/transforms, coherences and mode numbers
;       on the time-frequency plane.
;
;-

pro nti_wavelet_main,$
  ; Input
    data=data, dtimeax=dtimeax, chpos=chpos, expname=expname, shotnumber=shotnumber, timerange=timerange,$
    channels=channels, channelpairs_used=channelpairs_used, transf_selection=transf_selection,$
    cwt_selection=cwt_selection, cwt_family=cwt_family, cwt_order=cwt_order, cwt_dscale=cwt_dscale,$
    stft_selection=stft_selection, stft_window=stft_window, stft_length=stft_length, stft_fres=stft_fres,$
    stft_step=stft_step, freq_min=freq_min, freq_max=freq_max,$
    crosstr_selection=crosstr_selection, coh_selection=coh_selection, coh_avr=coh_avr,$
    mode_selection=mode_selection, mode_type=mode_type, mode_filter=mode_filter,$
    mode_steps=mode_steps, mode_min=mode_min, mode_max=mode_max,startpath=startpath,$
  ; Output
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, modenumbers=modenumbers, qs=qs

compile_opt defint32 ; 32 bit integers

; Set defaults and constants
datasize=size(data) ; First index is time, second is channel
if not(keyword_set(expname)) then expname='General'
if not(keyword_set(shotnumber)) then shotnumber=0
if not(keyword_set(timerange)) then timerange=[min(timeax),max(timeax)]
if not(keyword_set(channels)) then channels=string(indgen(datasize(2)))
if not(keyword_set(channelpairs_used)) then begin
  channelpairs_used=strarr(2, (datasize(2)*(datasize(2)-1)/2))
  for i=0L,datasize(2)-1 do begin
    for j=i+1,datasize(2)-1 do begin
      channelpairs_used(0,k)=channels(i)
      channelpairs_used(1,k)=channels(j)
      k=k+1
    endfor
  endfor
endif
if not(keyword_set(cwt_family)) then cwt_family='Morlet'
if not(keyword_set(cwt_order)) then cwt_order=6
if not(keyword_set(cwt_dscale)) then cwt_dscale=0.1
if not(keyword_set(stft_window)) then stft_window='Gauss'
if not(keyword_set(stft_length)) then stft_length=50
if not(keyword_set(stft_fres)) then stft_fres=1000
if not(keyword_set(stft_step)) then stft_step=1
if not(keyword_set(freq_min)) then freq_min=0 else freq_min=double(freq_min)
if not(keyword_set(freq_max)) then freq_max=1.0e32 else freq_max=double(freq_max)
if not(keyword_set(coh_avr)) then coh_avr=5
if not(keyword_set(mode_type)) then mode_type='Toroidal'
if not(keyword_set(mode_filter)) then mode_filter='Rel. pos.'
if not(keyword_set(mode_steps)) then mode_steps=1
if not(keyword_set(mode_min)) then mode_min=-6
if not(keyword_set(mode_max)) then mode_max=6
if not(keyword_set(startpath)) then startpath='./'

channelsize=n_elements(channels)
crosssize=(size(channelpairs_used))(2)
timeax=dtimeax
timesize=n_elements(timeax)

; Downsampling to freq_max
if timeax(timesize-1)-timeax(0) LT timesize/(freq_max*1000*2) then begin
  print,'Downsampling data'
  timesize=floor((timeax(timesize-1)-timeax(0))*freq_max*1000*2)
  data_resampled=fltarr(timesize,channelsize)
  for i=0,channelsize-1 do begin
    data_resampled(*,i)=pg_resample(reform(data(*,i)),timesize)
  endfor
  data=data_resampled
  datasize=size(data)
  timeax=timeax(0)+dindgen(timesize)/(freq_max*1000*2) ; New time axis
  timesize=n_elements(timeax)
endif


; Calculate energy-density distributions
if transf_selection then begin
  if cwt_selection then begin
    ; Calculate minimum frequency for CWT
    dt=double(timeax(n_elements(timeax)-1)-timeax(0))/double(n_elements(timeax)-1)
    freq_min=max([freq_min*1000,max([1,coh_avr])*cwt_order*2/(timeax(n_elements(timeax)-1)-timeax(0))]) ; in Hz
    start_scale=cwt_order/!PI
    max_scale=cwt_order/freq_min/2/!PI/dt
    nscale=ceil(pg_log2(max_scale/start_scale)/cwt_dscale)+1 ; Calculate nscale from minimum frequency
    freq_min=freq_min/1000. ; Conver to kHz and return
    
  	print,'CWT for '+i2str(shotnumber)+channels(0)
  	time=timeax ; Load original time axis for new data
  	transform=pg_scalogram_sim2(data(*,0),time,shot=shotnumber,channel=channels(0),trange=timerange,family=cwt_family,order=cwt_order,dscale=cwt_dscale,$
  		start_scale=start_scale, nscale=nscale, plot=-1, /pad,	freqax=freqax, scaleax=scaleax)
  	transformsize=size(transform)
  	transforms=complexarr(channelsize,transformsize(1),transformsize(2))
  	transforms(0,*,*)=transform
  	for i=1,channelsize-1 do begin
  		print,'CWT for '+i2str(shotnumber)+channels(i)
  		time=timeax ; Load original time axis for new data
  		transforms(i,*,*)=pg_scalogram_sim2(data(*,i),time,shot=shotnumber,channel=channels(i),trange=timerange,family=cwt_family,order=cwt_order,dscale=cwt_dscale,$
  			start_scale=start_scale, nscale=nscale, plot=-1, /pad,	freqax=freqax, scaleax=scaleax)
  	endfor
  endif else begin
  	print,'STFT for '+i2str(shotnumber)+channels(0)
  	freqres=1
    masksize=stft_fres*2-1
  	time=timeax ; Load original time axis for new data
  	transform=pg_spectrogram_sim(data(*,0),time,shot=shotnumber,channel=channels(0),trange=timerange,windowname=stft_window, $
  		windowsize=stft_length,masksize=masksize,step=stft_step, freqres=freqres, plot=-1, freqax=freqax)
  	transformsize=size(transform)
  	transformsize(2)=transformsize(2)/2+1 ;Store for positive frequencies only
  	transforms=complexarr(channelsize,transformsize(1),transformsize(2))
  	transforms(0,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
  	for i=1,channelsize-1 do begin
  		print,'STFT for '+i2str(shotnumber)+channels(i)
  		time=timeax ; Load original time axis for new data
  		transform=pg_spectrogram_sim(data(*,i),time,shot=shotnumber,channel=channels(i),trange=timerange,windowname=stft_window, $
  			windowsize=stft_length,masksize=masksize,step=stft_step,	freqres=freqres, plot=-1, freqax=freqax)
  		transforms(i,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
  	endfor
  endelse
  timeax=time ;Set new time axis
  timesize=n_elements(timeax)
endif

if crosstr_selection then begin
  ; Create arrays for crosstransforms
  crosstransforms=complexarr(crosssize,transformsize(1),transformsize(2))
  
  for i=0,crosssize-1 do begin
  	print,'Crosstransforms for '+i2str(shotnumber)+channelpairs_used(*,i)
  	wait,0.1
  	transform1=reform(transforms(where(channels EQ channelpairs_used(0,i)),*,*))
  	transform2=reform(transforms(where(channels EQ channelpairs_used(1,i)),*,*))
  	crosstransforms(i,*,*)=conj(transform1)*transform2 ; Calculate cross-transform
  endfor
endif

if coh_selection then begin
  ; Create array for coherences
  coherences=fltarr(crosssize,transformsize(1),transformsize(2))
  
  ; Calculate smoothed energy density distributions
   if (coh_avr GT 0) then begin
    print,'Smoothing energy density distributions'
    wait,0.1
    smoothed_apsds=fltarr(channelsize,transformsize(1),transformsize(2))
    for i=0,channelsize-1 do begin
      if cwt_selection then begin
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_apsds(i,*,k)=smooth(abs(reform(transforms(i,*,k)))^2,ceil(scaleax(k)*coh_avr*2.*!PI), /EDGE_TRUNCATE)
      endif else begin
        inttime=coh_avr*stft_length/stft_step
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_apsds(i,*,k)=smooth(abs(reform(transforms(i,*,k)))^2,inttime, /EDGE_TRUNCATE)
      endelse
    endfor
    
    ; Calculate smoothed cross-transforms
    print,'Smoothing cross-transforms'
    wait,0.1
    smoothed_crosstransforms=complexarr(crosssize,transformsize(1),transformsize(2))
    for i=0,crosssize-1 do begin
      if cwt_selection then begin
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_crosstransforms(i,*,k)=smooth(crosstransforms(i,*,k),ceil(scaleax(k)*coh_avr*2.*!PI), /EDGE_TRUNCATE)
      endif else begin
        inttime=coh_avr*stft_length/stft_step
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_crosstransforms(i,*,k)=smooth(crosstransforms(i,*,k),inttime, /EDGE_TRUNCATE)
      endelse
    endfor
  endif
  
  ;Calculate coherence
  for i=0,crosssize-1 do begin
    smoothed_apsd1=reform(smoothed_apsds(where(channels EQ channelpairs_used(0,i)),*,*))
    smoothed_apsd2=reform(smoothed_apsds(where(channels EQ channelpairs_used(1,i)),*,*))
    coherences(i,*,*)=float(abs(reform(smoothed_crosstransforms(i,*,*)))/sqrt(smoothed_apsd1*smoothed_apsd1))
  endfor
endif

if mode_selection then begin
  ; Calculate mode numbers on the time-frequency plane
  print,'Mode numbers for '+i2str(shotnumber)
  wait,0.1
  ; Create array for mode numbers
  modenumbers=fltarr(transformsize(1),transformsize(2))+1000 ; Initialize mode number arraz with 1000 standing for undefined
  qs=fltarr(transformsize(1),transformsize(2))
  if (size(smoothed_crosstransforms))(0) LT 2 then $ ; Calculate cross-phase
    cphases=atan(imaginary(crosstransforms),float(crosstransforms))$
    else $
    cphases=atan(imaginary(smoothed_crosstransforms),float(smoothed_crosstransforms))
    
  
  T=systime(1) ; Initialize progress indicator
  ; Fill 2D chpos array
  chpos2D=fltarr(2,crosssize)
  for i=0,1 do begin
    for j=0,crosssize-1 do begin
      chpos2D(i,j)=chpos(where(channels EQ channelpairs_used(i,j)))
    endfor
  endfor
;  channels=transpose(channels)
;  chpos2D=transpose(chpos2D)
  for i=0,transformsize(1)-1 do begin
  	for j=0,transformsize(2)-1 do begin
  	  case mode_filter of 
  	    'Rel. pos.': begin
          ; Filter Rel. Pos.: positive-negative mode numbers from relative positions
          ; (linear fit with weighting 1)
          m0=pg_modefilter_fitrel(reform(cphases(*,i,j)),chpos2D,$
            modestep=mode_steps, moderange=[mode_min,mode_max],qs=qs_all,ms=ms_all)
          if NOT(m0 EQ 1000) then begin
            modenumbers(i,j)=m0
            qs(i,j)=min(qs_all)
          endif
        end
      endcase

  		; Progress indicator
  		if floor(systime(1)-T) GE 10 then begin
  			print, pg_num2str(double(i)/double(transformsize(1))*100.)+' % done'
  			T=systime(1)
  			wait,0.1
  		endif
  	endfor
  endfor
endif

end
