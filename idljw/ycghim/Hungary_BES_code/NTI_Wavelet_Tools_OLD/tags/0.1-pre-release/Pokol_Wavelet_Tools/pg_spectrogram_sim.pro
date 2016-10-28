; Name: pg_spectrogram_sim
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.06.12.
;
; Purpose: Plot the Spectrogram or the Phase of the Short Time Fourier Transform of a signal
;
; Calling sequence:
;	stft=pg_spectrogram_sim( data, timeax [,shot] [,channel] [,trange] [,fmax] [,windowname] [,windowsize] [,masksize] [,step] $
;		[,freqres] [,plot] [,/print] [,/poster] [,/dc] [,/log] [,opt] [,/double] [,freqax=freqax])
;
; Inputs:
;	data: signal
;	timeax: time axis
;	shot (optional): shot number
;	channel (optional): channel number
;	trange (optional): timerange to view, 2 element vector; default: whole range
;	fmax (optional): frequency maximum of spectrogram (in kHz), resampled with pg_resample, Downsamples time axis!
;	windowsize (optional): length of window (standard deviation *2 for Gauss window); default: length of data / 10
;	masksize (optional): length of mask vector; default: all nonzero values
;	windowname (optional): shape of the window (available: see in pg_gen_win.pro)
;	step (optional): time steps of FFT; default: 1
;	freqres (optional): frequency resolution; default: length of data
;	plot (optional): display mode (available: 0:All, 1:Spectrogram, 2:Phase, other:None); default: 1
;	opt (optional): exponent for opimized scale visualization
;	/print (optional): Print to file instead of plotting
;	/poster (optional): Print in poster form
;	/dc (optional): without mean subtraction
;	/log (optional): visualize on log scale (except for Phase)
;	/double (optional): double precision
;
; Output:
;	stft: STFT of signal
;	freqax (optional): Frequency scale

function pg_spectrogram_sim, data, timeax, shot=shot, channel=channel, trange=trange, windowname=windowname, $
	windowsize=windowsize, masksize=masksize, step=step, $
	freqres=freqres, plot=plot, print=print, poster=poster, dc=dc, log=log, opt=opt, double=double, $
	freqax=freqax, fmax=fmax, ID=ID

compile_opt defint32 ; 32 bit integers

; Set defaults
size=n_elements(data)
double=keyword_set(double)
print=keyword_set(print)
poster=keyword_set(poster)
if not(keyword_set(plot)) then plot=1
if not(keyword_set(shot)) then shot=0
if not(keyword_set(channel)) then channel='SIMULATED'

; Read data
if not(keyword_set(trange)) then trange=[min(timeax),max(timeax)]
ind=where((timeax ge trange(0)) and (timeax le trange(1)))
timeax=timeax(ind)
data=data(ind)

;papp@reak.bme.hu, 2008.nov.
;resampling data if set
if keyword_set(fmax) then begin
   print,'Resampling data to get f_max: '+pg_num2str(fmax)+' kHz (original f_s was: '+pg_num2str(0.001/(timeax(1)-timeax(0)))+' kHz)'
   print,'Original time axis is: '+pg_num2str(timeax(0))+' - '+pg_num2str(timeax(n_elements(timeax)-1))
   newsize=(timeax(n_elements(timeax)-1)-timeax(0))*2*fmax*1000
   data=pg_resample(data,newsize)
   timeax=float(dindgen(n_elements(data))*(double(timeax(n_elements(timeax)-1))-double(timeax(0)))/n_elements(data))+timeax(0)
   print,'Resampled data, new timeax is: '+pg_num2str(timeax(0))+' - '+pg_num2str(timeax(n_elements(timeax)-1))+', f_max is: '+pg_num2str(0.0005/(timeax(1)-timeax(0)))+' kHz'
endif

; Zeropad data where abscent
repeat begin
	timesize=n_elements(timeax)
	dts=timeax(1+findgen(timesize-1))-timeax(findgen(timesize-1))
	ind=where(abs(dts-dts(1)) GT dts(1))
	if max(ind) NE -1 then begin
		place=ind(0)
		timeax=[timeax(findgen(place)),(findgen(fix(dts(place)/dts(1)-1))+1)*dts(1)+timeax(place),$
			timeax(place+1+findgen(timesize-place-1))]
		data=[data(findgen(place)),findgen(fix(dts(place)/dts(1)-1))*0,$
			data(place+1+findgen(timesize-place-1))]
	endif
endrep until max(ind) EQ -1

; Compute STFT
stft=pg_stft(data,windowsize=windowsize,masksize=masksize,windowname=windowname,$
	step=step,freqres=freqres,dc=dc,double=double)

; Compute axis
freqax=findgen(freqres/2+1)/(freqres/2)/(timeax[n_elements(timeax)-1]-timeax[0])*n_elements(timeax)/2/1000
timeax=pg_downsample(timeax,step=step)
;timeax=findgen(n_elements(timeax)/step)*(timeax[1]-timeax[0])*step+timeax[0]
sizestft=size(stft)

; Initialize graphics
pg_initgraph,print=print
title0=' of shot: '+pg_num2str(shot)+' '+channel
;title0=' of shot: '+pg_num2str(shot)+' '+channel+' using window type: '+windowname+$
;		' size: '+pg_num2str((timeax[1]-timeax[0])*windowsize)+'s ('+pg_num2str(windowsize*step)+')'
datas='shot: '+i2str(shot)+$
	'!C'+channel+$
	'!Ctrange:!C '+pg_num2str(timeax[0],length=5)+' s - '+$
		pg_num2str(timeax[n_elements(timeax)-1],length=5)+' s'+$
	'!Cwin.: '+windowname+$
	'!Cwinsize: '+i2str(windowsize)+'!C '+pg_num2str((timeax[1]-timeax[0])*windowsize/step)+'s'+$
	'!Cmasksize: '+i2str(masksize)+$
	'!Cfreqres: '+i2str(freqres)+$
	'!Cstep: '+i2str(step)

;papp@reak.bme.hu, 2008.11.24. Adding 'ID' string to datas for easier identification
if keyword_set(ID) then datas='ID='+ID+'!C'+datas


;if step NE 1 then title0=title0+' step: '+pg_num2str(step)
;if freqres NE size then title0=title0+' frequency resolution: '+pg_num2str(freqres)

; Plot the results
if (plot EQ 0) OR (plot EQ 1) then begin

	;Compute Power Density Distribution
	ploted=abs(stft[*,0:sizestft(2)/2])^2*2

	;Plot as bitmap
	title='Spectrogram'+title0
	if print then device,filename=pg_filename(title) else window,/free
	pg_plot4,ploted,ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
		,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,zlog=log,opt=opt,data=datas, poster=poster

endif
if (plot EQ 0) OR (plot EQ 2) then begin

	;Compute Phase
	ploted=atan(float(stft[*,0:sizestft(2)/2]),imaginary(stft[*,0:sizestft(2)/2]))

	;Plot as bitmap
	title='STFT phase'+title0
	if print then device,filename=pg_filename(title) else window,/free
	pg_plot4,ploted,ct=0,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
		,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=datas, poster=poster

endif

if print then device,/close

freqax=freqax

return, stft

end
