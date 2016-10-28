;+
;
;NAME: pg_modenumber_full
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.08.23.
;
; PURPOSE: Calculate and plot scalograms (or spectrograms), coherences and mode numbers on the time-frequency plane.
;	     This program can calculate mode numbers from magnetics and SXR data.
;      For magnetics and SXR (poloidal mode numbers):
;          the variables channels and chpos should be vectors.
;      For SXR (toroidal mode numbers): 
;          the variables channels and chpos should be matrices.
;          For an example how to use pg_modenumber_full calculating toroidal mode numbers for AUG SXR 
;          see EXAMPLE below. 
;
; CALLING SEQUENCE:
;	modenum=pg_modenumber_full(shot [,channels] [,chpos] [,trange] [,filters] [,fmax] [,windowname] [,windowsize] [,masksize] [,step] $
;		[,freqres] [,fmax] [,/cwt] [,family] [,order] [,dscale] [,start_scale] [,nscale] [,modescale] [,fmax]$
;		[,plot] [,paircoh] [,avr] [,/print] [,opt] [,filterparam1] [,filterparam2] [,filterparam3] [,cohlim] [,powlim]$
;		[,timeax=timeax] [,freqax=freqax] [,cphases=cphases] [,transforms=transforms]$
;		[,cpows=cpows] [,cohs=cohs] [,qmin=qmin] [,qavr=qavr] )
;
; INPUTS:
;		shot: shot numbers
;		channels (optional): channel numbers; default: W7-AS Mirnov/MIR-1 coils
;		chpos (optional): channel positions in degrees; default: W7-AS Mirnov/MIR-1 coils
;		trange (optional): timerange to view in s, 2 element vector; default: whole range
;		fmax (optional): maximum frequency in kHz (by downsampling); default: whole frequency range of 1st signal
;		filters (optional): vector of filter numbers to use; default: 0 available filters:
;			-1: No filter
;			0: Select most fitting linear to the relative phases as a function of their relative position
;				with a weighting of COH/median(COH)
;					filterparam1 (optional): mode number steps to be considered; default:1
;					filterparam2 (optional): minimum distance accepted Q values from Q_mean measured in Q_stddev units
;					filterparam3 (optional): maximum mode number to be considered; default: number of channels
;     1: Select most fitting linear to the relative phases as a function of their relative position
;       with a weighting of COH/median(COH)
;         filterparam1 (optional): mode number steps to be considered; default:1
;         filterparam2 (optional): steps of Q values to be plotted in percentage of Q_avr-Q_min for all
;           default: [1,5,10,20,50]
;         filterparam3 (optional): maximum mode number to be considered; default: number of channels
;     2: Select most fitting linear to the relative phases as a function of their relative position
;       with a weighting of 1
;         filterparam1 (optional): mode number steps to be considered; default:1
;         filterparam2 (optional): steps of Q values to be plotted in percentage of Q_avr-Q_min for all
;           default: [1,5,10,20,50]
;         filterparam3 (optional): maximum mode number to be considered; default: number of channels
;  STFT parameters:
;		windowname (optional); window type; default: 'Gauss'
;		windowsize (optional): length of window (standard deviation *2 for Gauss window); default: 50
;		masksize (optional): length of mask vector; default: 500
;		step (optional): time steps of FFT; default: 1
;		freqres (optional): frequency resolution; default: 1 (giving masksize/2)
;	CWT parameters:
;		/cwt (optional): Use CWT instead of STFT
;		family (optional): wavelet family to use (available: 'Morlet'); default: 'Morlet'
;		order (optional): order of the wavelet; default: 6
;		dscale (optional): fraction of diadic scaling; default:0.25
;		start_scale (optional): starting scale (has no effect on CWT using Morlet wavelets; default:2
;		nscale (optional): total number of scale values; default:log2(N/start_scale)/dscale+1
;	Visualization parameters:
;		plot (optional): display mode (available:
;										 0:Mode numbers of the time-frequency plane,
;										 1:0+time-frequency energy-density distributions,
;                    2:1+Freq. scale (for Morlet wavelets only),
;                    3:1+Freq. scale with forced 0 in frequency axis (for Morlet wavelets only),
;                    4:1+Plot pair coherences
;                    other:None; default: 0
;   paircoh (optional): if paircoh = 1 it calculates paircoherences between all signal pairs
;		opt (optional): exponent for opimized scale visualization
;		avr (optional): number of independent averages (0 switches averaging off); default: 0
;		modescale (optional): scale of plotted modes; default: all modes
;		cohlim (optional): lower limit of minimal coherence for plotting; default: none
;		powlim (optional): limit of CPSD for plotting (fraction of maximum); default: none
;		/print (optional): Print to file instead of plotting
;   /poster (optional): Print in poster form
;
; OUTPUT:
;		modenum: mode numbers of the time-frequency plane
;		timeax (optional): Time axis
;		freqax (optional): Frequency axis
;		cphases (optional): Cross-phases
;		cpows (optional): Cross-powers
;		cohs (optional): Coherences
;		transforms (optional): Unsmoothed time-frequency transforms of the channels
;		smoothed_apsds (optional): Smoothed APSDs of the channels
;		qmin (optional for filters 1): matrix of Q values for the most fitting modes
;		qavr (optional for filters 1): average of Q values for all modes at all times
;
;EXAMPE:
; Calculating toroidal mode numbers from SXR signals
;  shot=25845
;  chpos=[[1.,136.45],[1.,136.45],[1.,136.45],[1.,136.45]]
;  trange=[1.93,2.03]
;  channels=[['AUG_SXR/F_016','AUG_SXR/G_016'],$
;  ['AUG_SXR/F_017','AUG_SXR/G_017'],$
;  ['AUG_SXR/F_018','AUG_SXR/G_018'],$
;  ['AUG_SXR/F_019','AUG_SXR/G_019']]
;  modenum=pg_modenumber_full(shot, channels=channels, chpos=chpos,trange=trange,$
;    fmax=100.,filters=[2],/cwt,$
;    order=12,dscale=0.02,plot=1,/print,cohlim=0.5,powlim=0.2,$
;    opt=0.1,avr=5,filterparam2=[1,5,10,20],filterparam3=6,$
;    timeax=timeax, freqax=freqax,$
;    cphases=cphases, transforms=transforms,smoothed_apsds=smoothed_apsds,$
;    cpows=cpows, cohs=cohs, qmin=qmin, qavr=qavr $
;    )
;  save,/all,filename='data/AUG_modenumbers_tor_SXR_25845_1930_order_12_avr_5.sav'
;  return
;
;
;-

function pg_modenumber_full, shot, channels=channels, chpos=chpos, trange=trange, filters=filters,$
	fmax=fmax, windowname=windowname, windowsize=windowsize, masksize=masksize, step=step, freqres=freqres, $
	cwt=cwt, family=family, order=order, dscale=dscale, start_scale=start_scale, nscale=nscale, cohlim=cohlim, powlim=powlim,$
	plot=plot, paircoh=paircoh, print=print, poster=poster, opt=opt, modescale=modescale, avr=avr, filterparam1=filterparam1, $
	filterparam2=filterparam2,filterparam3=filterparam3,$
	timeax=timeax, freqax=freqax, cphases=cphases, transforms=transforms,smoothed_apsds=smoothed_apsds, $
	cpows=cpows, cohs=cohs, qmin=qmin, qavr=qavr

compile_opt defint32 ; 32 bit integers

; Set defaults
print=keyword_set(print)
log=keyword_set(log)
cwt=keyword_set(cwt)
if not(keyword_set(channels)) then channels=['W7-AS Mirnov/MIR-1-1',$
															'W7-AS Mirnov/MIR-1-2',$
															'W7-AS Mirnov/MIR-1-3',$
															'W7-AS Mirnov/MIR-1-4',$
															'W7-AS Mirnov/MIR-1-5',$
															'W7-AS Mirnov/MIR-1-6',$
															'W7-AS Mirnov/MIR-1-7',$
															'W7-AS Mirnov/MIR-1-8',$
															'W7-AS Mirnov/MIR-1-9',$
															'W7-AS Mirnov/MIR-1-10',$
															'W7-AS Mirnov/MIR-1-11',$
															'W7-AS Mirnov/MIR-1-12',$
															'W7-AS Mirnov/MIR-1-13',$
															'W7-AS Mirnov/MIR-1-14',$
															'W7-AS Mirnov/MIR-1-15',$
															'W7-AS Mirnov/MIR-1-16']
if not(keyword_set(chpos)) then chpos=[10,30,50,85,100,120,145,165,185,200,220,255,275,305,340,355]
if not(keyword_set(fmax)) then fmax=1.0e32
if not(keyword_set(filters)) then filters=[0,1]
if not(keyword_set(windowname)) then windowname='Gauss'
if not(keyword_set(windowsize)) then windowsize=50
if not(keyword_set(masksize)) then masksize=500
if not(keyword_set(step)) then step=1
if not(keyword_set(freqres)) then freqres=1
if not(keyword_set(order)) then order=6
if not(keyword_set(dscale)) then dscale=0.25
if not(keyword_set(family)) then family='Morlet'
if not(keyword_set(plot)) then plot=0
if (plot GE 0) AND (where(filters EQ -1) EQ -1) then modenumberplot=1 else modenumberplot=0 ; Plot mode numbers
if plot GE 1 then transplot=1 else transplot=-1 ; Plot time-frequency energy-density distributions
if plot GE 2 then if cwt then transplot=3 ; Plot cwt results with linear frequency axis
if plot GE 3 then if cwt then transplot=4 ; Plot cwt results with linear frequency axis with 0 freq.
if not (keyword_set(paircoh)) then paircoh=0 else paircoh=1
if not(keyword_set(opt)) then opt=1
if not(keyword_set(avr)) then avr=0
if not(keyword_set(modescale)) then begin
	setmodescale=0
	modescale=[-1.,1.]
endif else begin
	setmodescale=1
endelse
channessize=n_elements(channels)
if size(channels, /n_dimensions) GT 1 then sxr=1 else sxr=0

; Read data, and resize to the size of the first channel, if necessary
get_rawsignal,shot,channels(0),timeax,data,trange=trange
timesize=n_elements(timeax)
fmax=double(fmax)
if timeax(timesize-1)-timeax(0) LT timesize/(fmax*1000*2) then begin
	timesize=floor((timeax(timesize-1)-timeax(0))*fmax*1000*2)
	data=pg_resample(data,timesize)
	timeax=timeax(0)+findgen(timesize)/(fmax*1000*2)
endif
datas=fltarr(n_elements(channels),n_elements(data))
datas(0,*)=data
for i=1,channessize-1 do begin
	get_rawsignal,shot,channels(i),timeax2,data,trange=trange
	if NOT (norm(timeax-timeax2) EQ 0) then begin
		stime=timeax2(1)-timeax2(0)
		shift=(timeax2(0)-timeax(0))/stime
		data=pg_retrigger(data,shift)
		data=pg_resample(data,timesize)
	endif
	datas(i,*)=data
endfor

; Initialize graphics
pg_initgraph,print=print
printdatas0='shot: '+i2str(shot)+$
	'!C'+channels[0]+$
	'!C'+channels[1]+$
	'!C...'+$
	'!Ctrange:!C '+pg_num2str(timeax[0],length=4)+' s - '+$
		pg_num2str(timeax[n_elements(timeax)-1],length=4)+' s'+$
	'!Caverages: '+i2str(avr)
if cwt then printdata0s=printdatas0+$
		'!Cfamily: '+family+$
		'!Corder: '+i2str(order)+$
		'!Cdscale: '+pg_num2str(dscale,length=5) $
	else printdatas0=printdatas0+$
		'!Cwin.: '+windowname+$
		'!Cwinsize: '+i2str(windowsize)+'!C '+pg_num2str((timeax[1]-timeax[0])*windowsize/step)+'s'+$
		'!Cmasksize: '+i2str(masksize)+$
		'!Cfreqres: '+i2str(freqres)+$
		'!Cstep: '+i2str(step)

; Calculate energy-density distributions
if cwt then begin
	print,'CWT for '+i2str(shot)+channels(0)
	time=timeax
	transform=pg_scalogram_sim2(datas(0,*),time,shot=shot,channel=channels(0),trange=trange,family=family,order=order,dscale=dscale,$
		start_scale=start_scale, nscale=nscale, plot=transplot, print=print, poster=poster, /pad, opt=opt, $
		freqax=freqax, scaleax=scaleax)
	transformsize=size(transform)
	transforms=complexarr(channessize,transformsize(1),transformsize(2))
	transforms(0,*,*)=transform
	for i=1,channessize-1 do begin
		print,'CWT for '+i2str(shot)+channels(i)
		time=timeax
		transforms(i,*,*)=pg_scalogram_sim2(datas(i,*),time,shot=shot,channel=channels(i),trange=trange,family=family,order=order,dscale=dscale,$
			start_scale=start_scale, nscale=nscale, plot=transplot, print=print, poster=poster, /pad, opt=opt, $
			freqax=freqax, scaleax=scaleax)
	endfor
endif else begin
	print,'STFT for '+i2str(shot)+channels(0)
	time=timeax
	transform=pg_spectrogram_sim(datas(0,*),time,shot=shot,channel=channels(0),trange=trange,windowname=windowname, $
		windowsize=windowsize,masksize=masksize,step=step, $
		freqres=freqres, plot=transplot, print=print, poster=poster, log=log, opt=opt, freqax=freqax)
	transformsize=size(transform)
	transformsize(2)=transformsize(2)/2+1 ;Store for positive frequencies only
	transforms=complexarr(channessize,transformsize(1),transformsize(2))
	transforms(0,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
	for i=1,channessize-1 do begin
		print,'STFT for '+i2str(shot)+channels(i)
		time=timeax
		transform=pg_spectrogram_sim(datas(i,*),time,shot=shot,channel=channels(i),trange=trange,windowname=windowname, $
			windowsize=windowsize,masksize=masksize,step=step, $
			freqres=freqres, plot=transplot, print=print, poster=poster, log=log, opt=opt, freqax=freqax)
		transforms(i,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
	endfor
endelse
timeax=time ;Set new time axis

; Calculate smoothed (averaged) APDSs
smoothed_transsize=transformsize
if (avr GT 0) then begin
	print,'Smoothing transforms'
	wait,0.1
	if cwt then begin
		scaleind=where(scaleax LT smoothed_transsize(1)/(avr*2*!PI))
		scaleax=scaleax(scaleind)
		smoothed_transsize(2)=n_elements(scaleax)
		freqax=order/scaleax/(timeax(1)-timeax(0))/1000/2/!PI
	endif
	smoothed_apsds=complexarr(channessize,smoothed_transsize(1),smoothed_transsize(2))
	for i=0,channessize-1 do begin
		if cwt then begin
			; Chop off the frequencies too low for averaging
			transform=reform(transforms(i,*,scaleind))
			; Time intergration
			for k=0,smoothed_transsize(2)-1 do $
				smoothed_apsds(i,*,k)=smooth(abs(transform(*,k))^2,ceil(scaleax(k)*avr*2*!PI), /EDGE_TRUNCATE)
			; Plot smoothed scalogram
			if transplot GE 0 then begin
				title='Smoothed scalogram '+i2str(shot)+' '+channels(i)
				if print then device,filename=pg_filename(title) else window,/free
				pg_plot4,reverse(reform(smoothed_apsds(i,*,*)),2),ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
					,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
					,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
					,title=title,zlog=log,opt=opt,data=printdatas,poster=poster
      endif
      if transplot EQ 3 then begin
        title='Linear axis smoothed scalogram '+i2str(shot)+' '+channels(i)
        if print then device,filename=pg_filename(title) else window,/free
        loadct,5
        colors_scale_exponent=1/opt
        levels=findgen(60)^colors_scale_exponent
        plotted=reform(smoothed_apsds(i,*,*))
        levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
        CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title
      endif
      if transplot GE 4 then begin
        title='Linear 0 axis smoothed scalogram '+i2str(shot)+' '+channels(i)
        if print then device,filename=pg_filename(title) else window,/free
        loadct,5
        colors_scale_exponent=1/opt
        levels=findgen(60)^colors_scale_exponent
        plotted=reform(smoothed_apsds(i,*,*))
        plottedsize=size(plotted)
        plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)
        plottedplus(*,0:plottedsize(2)-1)=plotted
        freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
        levels=levels/max(levels)*(max(plottedplus)-min(plottedplus))+min(plottedplus)
        CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title
      endif
		endif else begin
			inttime=avr*windowsize/step
			; Time intergration
			for k=0,smoothed_transsize(2)-1 do $
				smoothed_apsds(i,*,k)=smooth(abs(reform(transforms(i,*,k)))^2,inttime, /EDGE_TRUNCATE)
			; Plot smoothed spectrogram
      if transplot GE 0 then begin
        title='Smoothed spectrogram '+i2str(shot)+' '+channels(i)
        if print then device,filename=pg_filename(title) else window,/free
        pg_plot4,reform(smoothed_apsds(i,*,*)),ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,zlog=log,opt=opt,data=printdatas,poster=poster
      endif
		endelse
	endfor
endif

; Create arrays for coherences and averaged CPSD
if (avr GT 0) then begin
	mincoh=fltarr(smoothed_transsize(1),smoothed_transsize(2))+1 ;fill array with ones
	avrcoh=fltarr(smoothed_transsize(1),smoothed_transsize(2))
endif
smoothed_avrcpsd=fltarr(smoothed_transsize(1),smoothed_transsize(2))

; Calculate cross-phases for SXR data
if sxr EQ 1 then begin
losnum=n_elements(channels(0,*))  ;number of los.
crosssize=losnum
cphases=fltarr(crosssize,smoothed_transsize(1),smoothed_transsize(2))
cpows=fltarr(crosssize,smoothed_transsize(1),smoothed_transsize(2))
cohs=fltarr(crosssize,smoothed_transsize(1),smoothed_transsize(2))
for i=0,channessize-1,2 do begin
	print,'Crosstransforms for '+i2str(shot)+channels(i)+' '+channels(i+1)
	wait,0.1
	ctrans=conj(reform(transforms(i,*,*)))*reform(transforms(i+1,*,*)) ; Calculate cross-transform
	; Smoothing cross-transforms in time for averaging
	if avr GT 0 then begin
		if cwt then begin
			; Chop off the frequencies too low for averaging
			ctrans=ctrans(*,scaleind)
			; Time intergration
			for k=0,smoothed_transsize(2)-1 do ctrans(*,k)=smooth(ctrans(*,k),ceil(scaleax(k)*avr*2.*!PI), /EDGE_TRUNCATE)
			; Calculate coherence
			coh=float(abs(ctrans)/sqrt(reform(smoothed_apsds(i,*,*))*reform(smoothed_apsds(i+1,*,*))))
		endif else begin
			inttime=avr*windowsize/step
			; Time intergration
			ctranssize=size(ctrans)
			for k=0,smoothed_transsize(2)-1 do ctrans(*,k)=smooth(ctrans(*,k),inttime, /EDGE_TRUNCATE)
			; Calculate coherence
			coh=float(abs(ctrans)/sqrt(reform(smoothed_apsds(i,*,*))*reform(smoothed_apsds(i+1,*,*))))
		endelse
		mincoh=mincoh<coh ; Calculate minimum coherence
		avrcoh=avrcoh+coh/float(crosssize) ; Calculate average coherence
		cohs(i/2.,*,*)=coh
	endif
	cphases(i/2.,*,*)=atan(imaginary(ctrans),float(ctrans)) ; Calculate cross-phase
	cpows(i/2.,*,*)=abs(ctrans) ; Calculate cross-power
	smoothed_avrcpsd=smoothed_avrcpsd+abs(ctrans)/float(crosssize) ; Calculate cross-power
endfor

endif else begin

; Calculate cross-phases for Mirnov data
crosssize=channessize*(channessize-1)/2
cphases=fltarr(crosssize,smoothed_transsize(1),smoothed_transsize(2))
cpows=fltarr(crosssize,smoothed_transsize(1),smoothed_transsize(2))
cohs=fltarr(crosssize,smoothed_transsize(1),smoothed_transsize(2))
for i=0,channessize-1 do begin
  for j=i+1,channessize-1 do begin
    print,'Crosstransforms for '+i2str(shot)+channels(i)+' '+channels(j)
    wait,0.1
    ctrans=conj(reform(transforms(i,*,*)))*reform(transforms(j,*,*)) ; Calculate cross-transform
    ; Smoothing cross-transforms in time for averaging
    if avr GT 0 then begin
      if cwt then begin
        ; Chop off the frequencies too low for averaging
        ctrans=ctrans(*,scaleind)
        ; Time intergration
        for k=0,smoothed_transsize(2)-1 do ctrans(*,k)=smooth(ctrans(*,k),ceil(scaleax(k)*avr*2.*!PI), /EDGE_TRUNCATE)
        ; Calculate coherence
        coh=float(abs(ctrans)/sqrt(reform(smoothed_apsds(i,*,*))*reform(smoothed_apsds(j,*,*))))
      endif else begin
        inttime=avr*windowsize/step
        ; Time intergration
        ctranssize=size(ctrans)
        for k=0,smoothed_transsize(2)-1 do ctrans(*,k)=smooth(ctrans(*,k),inttime, /EDGE_TRUNCATE)
        ; Calculate coherence
        coh=float(abs(ctrans)/sqrt(reform(smoothed_apsds(i,*,*))*reform(smoothed_apsds(j,*,*))))
      endelse
      mincoh=mincoh<coh ; Calculate minimum coherence
      avrcoh=avrcoh+coh/float(crosssize) ; Calculate average coherence
      cohs(i*(channessize-(i+1)/2.)-(i+1)+j,*,*)=coh
    endif
    cphases(i*(channessize-(i+1)/2.)-(i+1)+j,*,*)=atan(imaginary(ctrans),float(ctrans)) ; Calculate cross-phase
    cpows(i*(channessize-(i+1)/2.)-(i+1)+j,*,*)=abs(ctrans) ; Calculate cross-power
    smoothed_avrcpsd=smoothed_avrcpsd+abs(ctrans)/float(crosssize) ; Calculate cross-power
  endfor
endfor


endelse

; Plot coherences
if avr GT 0 then begin
	if cwt then begin
		title='Minimum coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
		if print then device,filename=pg_filename(title) else window,/free
		pg_plot4,reverse(mincoh,2),ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
			,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))],zrange=[0,1]$
			,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
			,title=title,data=printdatas, poster=poster
    if transplot EQ 3 then begin
      title='Linear axis minimum coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,5
      levels=findgen(60)
      plotted=mincoh
      levels=levels/max(levels)
      CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
    if transplot GE 4 then begin
      title='Linear 0 axis minimum coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,5
      levels=findgen(60)
      plotted=mincoh
      plottedsize=size(plotted)
      plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)
      plottedplus(*,0:plottedsize(2)-1)=plotted
      freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
      levels=levels/max(levels)
      CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
		title='Average coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
		if print then device,filename=pg_filename(title) else window,/free
		pg_plot4,reverse(avrcoh,2),ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
			,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))],zrange=[0,1]$
			,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
			,title=title,data=printdatas, poster=poster
    if transplot EQ 3 then begin
      title='Linear axis average coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,5
      levels=findgen(60)
      plotted=avrcoh
      levels=levels/max(levels)
      CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
    if transplot GE 4 then begin
      title='Linear 0 axis average coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,5
      levels=findgen(60)
      plotted=avrcoh
      plottedsize=size(plotted)
      plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)
      plottedplus(*,0:plottedsize(2)-1)=plotted
      freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
      levels=levels/max(levels)
      CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
	endif else begin
		title='Minimum coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
		if print then device,filename=pg_filename(title) else window,/free
		pg_plot4,mincoh,ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)],zrange=[0,1]$
			,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
		title='Average coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
		if print then device,filename=pg_filename(title) else window,/free
		pg_plot4,avrcoh,ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)],zrange=[0,1]$
			,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
	endelse
endif

;Plot coherences between all pairs of probes
if paircoh EQ 1 then begin
  for i=0,channessize-1 do begin
    for j=i+1,channessize-1 do begin
      title='Paircoherence of shots: '+i2str(shot)+' '+channels(i)+' '+channels(j)
      if print then device,filename=pg_filename(title) else window,/free
      plotted=reform(cohs(i*(channessize-(i+1)/2.)-(i+1)+j,*,*))
      pg_plot4,reverse(plotted,2),ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
        ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))],zrange=[0,1]$
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
        ,title=title,data=printdatas, poster=poster
      if transplot EQ 3 then begin
        title='Linear axis minimum coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        loadct,5
        levels=findgen(60)
        plotted=mincoh
        levels=levels/max(levels)
        CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title
      endif
      if transplot GE 4 then begin
        title='Linear 0 axis minimum coherence of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        loadct,5
        levels=findgen(60)
        plotted=mincoh
        plottedsize=size(plotted)
        plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)
        plottedplus(*,0:plottedsize(2)-1)=plotted
        freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
        levels=levels/max(levels)
        CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title
      endif
     endfor
  endfor
endif

; Calculate mode numbers on the time-frequency plane
print,'Mode numbers for '+i2str(shot)
wait,0.1
T=systime(1) ; Initialize progress indicator
modenum=fltarr(smoothed_transsize(1),smoothed_transsize(2))
modenum=modenum+1000 ; set mode number values definetly not reached
mediancoh=median(median(cohs,dimension=[3]),dimension=[2])
if where(filters GE 1) GT -1 then begin
	qmin=fltarr(smoothed_transsize(1),smoothed_transsize(2))
	qavr=0
endif
for i=0,smoothed_transsize(1)-1 do begin
	for j=0,smoothed_transsize(2)-1 do begin

		; Filter 0: positive-negative mode numbers from relative positions
		; (linear fit with weighting COH/median(COH))
		if where(filters EQ 0) GT -1 then begin
			if setmodescale then moderange=modescale
			if not(keyword_set(filterparam3)) then filterparam3=channelssize
			m0=pg_modefilter_fitrel(cphases(*,i,j),chpos, weights=cohs(*,i,j)/mediancoh,$
				modestep=filterparam1, qlim=filterparam2, moderange=[-filterparam3,filterparam3])
			if NOT(m0 EQ 1000) then modenum(i,j)=m0
		endif

    ; Filter 1: positive-negative mode numbers from relative positions
    ; (linear fit with weighting COH/median(COH))
    if where(filters EQ 1) GT -1 then begin
      if setmodescale then moderange=modescale
      if not(keyword_set(filterparam3)) then filterparam3=channelssize
      if not(keyword_set(filterparam2)) then filterparam2=[1,5,10,20,50]
      m0=pg_modefilter_fitrel(cphases(*,i,j),chpos, weights=cohs(*,i,j)/mediancoh,$
        modestep=filterparam1, moderange=[-filterparam3,filterparam3],qs=qs,ms=ms)
      if NOT(m0 EQ 1000) then begin
        modenum(i,j)=m0
        qmin(i,j)=min([qs(where(qs EQ min(qs)))])
        qavr=qavr+mean(qs)/float(smoothed_transsize(1)*smoothed_transsize(2))
      endif
    endif
      
    ; Filter 2: positive-negative mode numbers from relative positions
    ; (linear fit with weighting 1)
    if where(filters EQ 2) GT -1 then begin
      if setmodescale then moderange=modescale
      if not(keyword_set(filterparam3)) then filterparam3=channelssize
      if not(keyword_set(filterparam2)) then filterparam2=[1,5,10,20,50]
      m0=pg_modefilter_fitrel(cphases(*,i,j),chpos,$
        modestep=filterparam1, moderange=[-filterparam3,filterparam3],qs=qs,ms=ms)
      if NOT(m0 EQ 1000) then begin
        modenum(i,j)=m0
        qmin(i,j)=min([qs(where(qs EQ min(qs)))])
        qavr=qavr+mean(qs)/float(smoothed_transsize(1)*smoothed_transsize(2))
      endif
		endif

		; Progress indicator
		if floor(systime(1)-T) GE 10 then begin
			print, pg_num2str(double(i)/double(smoothed_transsize(1))*100.)+' % done'
			T=systime(1)
			wait,0.1
		endif
	endfor
endfor

; Set scale for plotting mode numbers
isdefined=where(modenum NE 1000)
if max(isdefined) GT -1 then maxmodenum=max(abs(modenum(isdefined))) else maxmodenum=0
if (modescale(1) LT maxmodenum) AND (NOT setmodescale) then modescale=[-maxmodenum,maxmodenum]
; Set not defined mode numbers for plotting
notdefined=where((modenum LT modescale(0)) OR (modenum GT modescale(1)))
if max(notdefined) NE -1 then modenum(notdefined)=modescale(1)+(modescale(1)-modescale(0))/200.

; Plot mode numbers
if modenumberplot then begin
	; Set filter parameters to be plotted
	if where(filters EQ 0) GT -1 then begin
		printdatas1=printdatas0+'!CFilter 0'+$
			'!Cmodestep: '+pg_num2str(filterparam1)+$
			'!CQ limit: '+pg_num2str(filterparam2)+$
			'!Cmax mode number: '+i2str(filterparam3)
	endif
	if where(filters EQ 1) GT -1 then begin
		printdatas1=printdatas0+'!CFilter 1'+$
			'!Cmodestep: '+pg_num2str(filterparam1)+$
			'!Cmax mode number: '+i2str(filterparam3)+$
			'!Caverage Q: '+pg_num2str(qavr)
	endif
	if where(filters EQ 2) GT -1 then begin
		printdatas1=printdatas0+'!CFilter 2'
	endif
	if where(filters EQ 3) GT -1 then begin
		printdatas1=printdatas0+'!CFilter 3'
	endif
	if where(filters EQ 4) GT -1 then begin
		printdatas1=printdatas0+'!CFilter 4'
	endif
	; Plot
	printdatas=printdatas1
	if cwt then begin
	  title='Mode numbers of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
		if print then device,filename=pg_filename(title) else window,/free
		pg_plot4,reverse(modenum,2),ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
			,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))] $
			,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
			,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
			;,/original
    if transplot EQ 3 then begin
      title='Linear axis mode numbers of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,42
      levels=findgen(fix(modescale(1)-modescale(0)+1))
      plotted=modenum
      levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
      levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
      CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
    if transplot GE 4 then begin
      title='Linear 0 axis mode numbers of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,42
      levels=findgen(fix(modescale(1)-modescale(0)+1))
      plotted=modenum
      plotted=modenum
      plottedsize=size(plotted)
      plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)+1000
      plottedplus(*,0:plottedsize(2)-1)=plotted
      freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
      levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
      levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
      CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
	endif else begin
    title='Mode numbers of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
		if print then device,filename=pg_filename(title) else window,/free
		pg_plot4,modenum,ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
			,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
			,poster=poster,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
			;,/original
	endelse
	modenumfull=modenum
	
	; Plot coherence limited mode numbers
	if (avr GT 0) and keyword_set(cohlim) then begin
		modenum=modenumfull
		notplotted=where(mincoh LT cohlim)
		if max(notplotted) GT -1 then modenum(notplotted)=1000
		; Set scale for plotting mode numbers
		isdefined=where(modenum LT modescale(1)+(modescale(1)-modescale(0))/200.)
		if max(isdefined) GT -1 then maxmodenum=max(abs(modenum(isdefined))) else maxmodenum=0
		if (modescale(1) LT maxmodenum) AND (NOT setmodescale) then modescale=[-maxmodenum,maxmodenum]
		; Set not defined mode numbers for plotting
		notdefined=where((modenum LT modescale(0)) OR (modenum GT modescale(1)))
		if max(notdefined) NE -1 then modenum(notdefined)=modescale(1)+(modescale(1)-modescale(0))/200.

		printdatas=printdatas1+'!Ccohlim:'+pg_num2str(cohlim)
		; Plot
		if cwt then begin
      title='Mode numbers (cohlim) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
			if print then device,filename=pg_filename(title) else window,/free
			pg_plot4,reverse(modenum,2),ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
				,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))] $
				,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
				,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
				;,/original
      if transplot EQ 3 then begin
        title='Linear axis mode numbers (cohlim) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        loadct,42
        levels=findgen(fix(modescale(1)-modescale(0)+1))
        plotted=modenum
        levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
        levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
        CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title,max_value=999
      endif
      if transplot GE 4 then begin
        title='Linear 0 axis mode numbers (cohlim) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        loadct,42
        levels=findgen(fix(modescale(1)-modescale(0)+1))
        plotted=modenum
        plottedsize=size(plotted)
        plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)+1000
        plottedplus(*,0:plottedsize(2)-1)=plotted
        freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
        levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
        levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
        CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title,max_value=999
      endif
		endif else begin
      title='Mode numbers (cohlim) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
			if print then device,filename=pg_filename(title) else window,/free
			pg_plot4,modenum,ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
				,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
				,poster=poster,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
				;,/original
		endelse
	endif
	
	; Plot power limited mode numbers
	if keyword_set(powlim) then begin
		modenum=modenumfull
		powlim=powlim*max(smoothed_avrcpsd)
		; Plot mode numbers for large CPSD areas
		notplotted=where(smoothed_avrcpsd LT powlim)
		if max(notplotted) GT -1 then modenum(notplotted)=1000
		; Set scale for plotting mode numbers
		isdefined=where(modenum LT modescale(1)+(modescale(1)-modescale(0))/200.)
		if max(isdefined) GT -1 then maxmodenum=max(abs(modenum(isdefined))) else maxmodenum=0
		if (modescale(1) LT maxmodenum) AND (NOT setmodescale) then modescale=[-maxmodenum,maxmodenum]
		; Set not defined mode numbers for plotting
		notdefined=where((modenum LT modescale(0)) OR (modenum GT modescale(1)))
		if max(notdefined) NE -1 then modenum(notdefined)=modescale(1)+(modescale(1)-modescale(0))/200.

		printdatas=printdatas1+'!Cpowlim+:'+pg_num2str(powlim)
		; Plot
		if cwt then begin
      title='Mode numbers (powlim+) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
			if print then device,filename=pg_filename(title) else window,/free
			pg_plot4,reverse(modenum,2),ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
				,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))] $
				,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
				,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
				;,/original
      if transplot EQ 3 then begin
        title='Linear axis mode numbers (powlim+) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        loadct,42
        levels=findgen(fix(modescale(1)-modescale(0)+1))
        plotted=modenum
        levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
        levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
        CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title
      endif
      if transplot GE 4 then begin
        title='Linear 0 axis mode numbers (powlim+) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        loadct,42
        levels=findgen(fix(modescale(1)-modescale(0)+1))
        plotted=modenum
        plottedsize=size(plotted)
        plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)+1000
        plottedplus(*,0:plottedsize(2)-1)=plotted
        freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
        levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
        levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
        CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
          YTITLE='Frequency (kHz)',levels=levels,title=title
      endif
		endif else begin
      title='Mode numbers (powlim+) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
			if print then device,filename=pg_filename(title) else window,/free
			pg_plot4,modenum,ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
				,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
				,poster=poster,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
				;,/original
		endelse

		; Plot mode numbers for small CPSD areas
		modenum=modenumfull
		notplotted=where(smoothed_avrcpsd GT powlim)
		if max(notplotted) GT -1 then modenum(notplotted)=1000
		; Set scale for plotting mode numbers
		isdefined=where(modenum LT modescale(1)+(modescale(1)-modescale(0))/200.)
		if max(isdefined) GT -1 then maxmodenum=max(abs(modenum(isdefined))) else maxmodenum=0
		if (modescale(1) LT maxmodenum) AND (NOT setmodescale) then modescale=[-maxmodenum,maxmodenum]
		; Set not defined mode numbers for plotting
		notdefined=where((modenum LT modescale(0)) OR (modenum GT modescale(1)))
		if max(notdefined) NE -1 then modenum(notdefined)=modescale(1)+(modescale(1)-modescale(0))/200.

		printdatas=printdatas1+'!Cpowlim-:'+pg_num2str(powlim)

		; Plot
		if cwt then begin
      title='Mode numbers (powlim-) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
    	if print then device,filename=pg_filename(title) else window,/free
			pg_plot4,reverse(modenum,2),ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
				,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))] $
				,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
				,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
				;,/original
    if transplot EQ 3 then begin
      title='Linear axis mode numbers (powlim-) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,42
      levels=findgen(fix(modescale(1)-modescale(0)+1))
      plotted=modenum
      levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
      levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
      CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
    if transplot GE 4 then begin
      title='Linear 0 axis mode numbers (powlim-) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
      if print then device,filename=pg_filename(title) else window,/free
      loadct,42
      levels=findgen(fix(modescale(1)-modescale(0)+1))
      plotted=modenum
      plottedsize=size(plotted)
      plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)+1000
      plottedplus(*,0:plottedsize(2)-1)=plotted
      freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
      levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
      levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
      CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif
		endif else begin
      title='Mode numbers (powlim-) of shot: '+i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
			if print then device,filename=pg_filename(title) else window,/free
			pg_plot4,modenum,ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
				,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
				,poster=poster,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
				;,/original
		endelse
	endif
	
	; Plot Q limited mode numbers
  if (where(filters EQ 1) GT -1) OR (where(filters EQ 2) GT -1) then begin
    qminmin=min(qmin)
    for i=0,n_elements(filterparam2)-1 do begin
      qlim=qminmin+(qavr-qminmin)/100.*filterparam2(i)
      modenum=modenumfull
      notplotted=where(qmin GT qlim)
      if max(notplotted) GT -1 then modenum(notplotted)=1000
      ; Set scale for plotting mode numbers
      isdefined=where(modenum LT modescale(1)+(modescale(1)-modescale(0))/200.)
      if max(isdefined) GT -1 then maxmodenum=max(abs(modenum(isdefined))) else maxmodenum=0
      if (modescale(1) LT maxmodenum) AND (NOT setmodescale) then modescale=[-maxmodenum,maxmodenum]
      ; Set not defined mode numbers for plotting
      notdefined=where((modenum LT modescale(0)) OR (modenum GT modescale(1)))
      if max(notdefined) NE -1 then modenum(notdefined)=modescale(1)+(modescale(1)-modescale(0))/200.

      printdatas=printdatas1+'!Climit Q: '+pg_num2str(qlim)+' ('+i2str(filterparam2(i))+'%)'
      ; Plot
      if cwt then begin
        title='Mode numbers (global Q: '+i2str(filterparam2(i))+') of shot: '$
          +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        pg_plot4,reverse(modenum,2),ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
          ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))] $
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
          ,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
          ;,/original
        if transplot EQ 3 then begin
          title='Linear axis mode numbers (global Q: '+i2str(filterparam2(i))+') of shot: '$
            +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
          if print then device,filename=pg_filename(title) else window,/free
          loadct,42
          levels=findgen(fix(modescale(1)-modescale(0)+1))
          plotted=modenum
          levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
          levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
          CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
            YTITLE='Frequency (kHz)',levels=levels,title=title
        endif
        if transplot GE 4 then begin
          title='Linear 0 axis mode numbers (global Q: '+i2str(filterparam2(i))+') of shot: '$
            +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
          if print then device,filename=pg_filename(title) else window,/free
          loadct,42
          levels=findgen(fix(modescale(1)-modescale(0)+1))
          plotted=modenum
          plottedsize=size(plotted)
          plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)+1000
          plottedplus(*,0:plottedsize(2)-1)=plotted
          freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
          levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
          levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
          CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
            YTITLE='Frequency (kHz)',levels=levels,title=title
        endif
      endif else begin
        title='Mode numbers (global Q: '+i2str(filterparam2(i))+') of shot: '$
          +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        pg_plot4,modenum,ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
          ,poster=poster,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
          ;,/original
      endelse
    endfor
  endif
  
  ; Plot coherence and Q limited mode numbers
  if (where(filters EQ 1) GT -1) OR (where(filters EQ 2) GT -1)then begin
    qminmin=min(qmin)
    for i=0,n_elements(filterparam2)-1 do begin
      qlim=qminmin+(qavr-qminmin)/100.*filterparam2(i)
      modenum=modenumfull
      notplotted=where((qmin GT qlim) OR (mincoh LT cohlim))
      if max(notplotted) GT -1 then modenum(notplotted)=1000
      ; Set scale for plotting mode numbers
      isdefined=where(modenum LT modescale(1)+(modescale(1)-modescale(0))/200.)
      if max(isdefined) GT -1 then maxmodenum=max(abs(modenum(isdefined))) else maxmodenum=0
      if (modescale(1) LT maxmodenum) AND (NOT setmodescale) then modescale=[-maxmodenum,maxmodenum]
      ; Set not defined mode numbers for plotting
      notdefined=where((modenum LT modescale(0)) OR (modenum GT modescale(1)))
      if max(notdefined) NE -1 then modenum(notdefined)=modescale(1)+(modescale(1)-modescale(0))/200.

      printdatas=printdatas1+'!Ccohlim:'+pg_num2str(cohlim)
      printdatas=printdatas1+'!Climit Q: '+pg_num2str(qlim)+' ('+i2str(filterparam2(i))+'%)'
      ; Plot
      if cwt then begin
        title='Mode numbers (cohlim + global Q: '+i2str(filterparam2(i))+') of shot: '$
          +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        pg_plot4,reverse(modenum,2),ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
          ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))] $
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
          ,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
          ;,/original
        if transplot EQ 3 then begin
          title='Linear axis mode numbers (cohlim + global Q: '+i2str(filterparam2(i))+') of shot: '$
            +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
          if print then device,filename=pg_filename(title) else window,/free
          loadct,42
          levels=findgen(fix(modescale(1)-modescale(0)+1))
          plotted=modenum
          levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
          levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
          CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
            YTITLE='Frequency (kHz)',levels=levels,title=title
        endif
        if transplot GE 4 then begin
          title='Linear 0 axis mode numbers (cohlim + global Q: '+i2str(filterparam2(i))+') of shot: '$
            +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
          if print then device,filename=pg_filename(title) else window,/free
          loadct,42
          levels=findgen(fix(modescale(1)-modescale(0)+1))
          plotted=modenum
          plottedsize=size(plotted)
          plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)+1000
          plottedplus(*,0:plottedsize(2)-1)=plotted
          freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
          levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
          levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
          CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
            YTITLE='Frequency (kHz)',levels=levels,title=title
        endif
     endif else begin
        title='Mode numbers (cohlim + global Q: '+i2str(filterparam2(i))+') of shot: '$
          +i2str(shot)+' '+channels(0)+' '+channels(1)+'...'
        if print then device,filename=pg_filename(title) else window,/free
        pg_plot4,modenum,ct=42,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
          ,poster=poster,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz; $
          ;,/original
      endelse
    endfor
  endif

endif

if print then device,/close

timeax=timeax
freqax=freqax
cphases=cphases
cpows=cpows
cohs=cohs
transforms=transforms
smoothed_apsds=smoothed_apsds
qmin=qmin
qavr=qavr
modenum=modenumfull

return, modenum 
end
