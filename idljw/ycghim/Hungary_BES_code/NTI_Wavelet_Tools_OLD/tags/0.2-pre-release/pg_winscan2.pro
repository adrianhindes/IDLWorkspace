;+
; Name: pg_winscan2
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2004.02.18.
;
; Purpose: Plot time integrated Spectrogram as a function of windowsize for a measurement in the Nicolet system
;		Fast algoritm (no calculation of STFT)
;
; Calling sequence:
;	winscan=pg_winscan2(shot, channel [,trange] [,windowname] [,windowsize] [,masksize] [,step] $
;		[,freqres] [,plot] [,/print] [,/dc] [,/log] [,opt] [,/double] [,timeax=timeax] [,freqax=freqax])
;
; Inputs:
;	shot: shot number
;	channel: channel number
;	trange (optional): timerange to view, 2 element vector; default: whole range
;	windowsize (optional): length of window (standard deviation *2 for Gauss window); default: [1,500]
;	masksize (optional): length of mask vector (must be GT max(windowsize)); default: 4*max(windowsize)
;	windowname (optional): shape of the window (available: see in pg_gen_win.pro)
;	step (optional): time steps of FFT; default: 1
;	freqres (optional): frequency resolution (must be GT masksize); default: length of data
;	plot (optional): Display mode (available: 0: Plot time integrated spectrogram as a function of windowsize
;						  1: 0+time integrated spectra
;						   ; default: 0)
;	opt (optional): exponent for opimized scale visualization
;	/print (optional): Print to file instead of plotting
;	/log (optional): visualize on log scale (except for Phase)
;	/double (optional): double precision
;
; Output:
;	winscan: Time integrated spectrogram as a function of windowsize
;	timeax (optional): Time axis
;	freqax (optional): Frequency axis
;
;-

function pg_winscan2, shot, channel, trange=trange, windowname=windowname, $
	windowsize=windowsize, masksize=masksize, step=step, freqres=freqres, $
	plot=plot, print=print, dc=dc, log=log, opt=opt, double=double, $
	timeax=timeax, freqax=freqax

compile_opt defint32 ; 32 bit integers

; Set defaults
double=keyword_set(double)
print=keyword_set(print)
if not(keyword_set(windowsize)) then windowsize=[1,500]
if not(keyword_set(masksize)) then masksize=4*max(windowsize)
if not(keyword_set(plot)) then plot=0
if plot GE 0 then wsplot=1 else wsplot=0 		; Plot time integrated spectrogram as a function of windowsize
if plot GE 1 then splot=1 else splot=0 			; Plot time integrated spectra

; Read data
get_rawsignal,shot,channel,timeax,data,trange=trange

; Initialize graphics
pg_initgraph,print=print

; Initialize arrays
winscan=fltarr(windowsize[1]-windowsize[0]+1,floor(freqres/2d)+1)

; Calculate spectrum
sp=fft(data,-1)
sp=abs(sp[0,ceil(n_elements(data)/2.)])^2+abs([0,sp[1,ceil(n_elements(data)/2.)]])^2

if not(keyword_set(freqres)) then freqres=n_elements(data)
freqres=(freqres > masksize) < n_elements(data)

; Calculate frequency axis
freqax=findgen(freqres/2+1)/(freqres/2)/(timeax[1]-timeax[0])/2/1000

for i=windowsize[0],windowsize[1] do begin

	; Progress indicator
	print,'Window size: '+i2str(i)
	wait,0.5

	; Get the window
	win=pg_gen_win(windowsize[i],masksize=masksize,windowname=windowname,double=double)

	matrix=pg_spectrogram_sim( data, timeax, shot=shot,channel=channel,trange=trange, windowname=windowname, $
		windowsize=i, masksize=masksize, step=step, freqres=freqres, plot=matrixplot, $
		print=print, opt=0.4, double=double, freqax=freqax)

	; Calculate spectrum for the whole time intervall
	winscan[i-windowsize[0],*]=total(abs(matrix[*,0:floor(freqres/2d)])^2,1)

	; Norm spectrum
	winscan[i-windowsize[0],*]=winscan[i-windowsize[0],*]/total(winscan[i-windowsize[0],*])

endfor

; Plot spectra for the whole time intervall
if splot then begin

	; Set multiplot for band power plotting
	!P.MULTI=[0,2,8,0,1]
	!P.CHARSIZE=1.4

	for i=windowsize[0],windowsize[1] do begin

		; Progress indicator
		print,'Plotting spectra for window size: '+i2str(i)

		; Open new plot
		if ((i-windowsize[0]) mod 16) EQ 0 then begin
			title='Spectra '+i2str(shot)+' '+channel+' window size: '+i2str(i)+'-'+i2str(i+15 < windowsize[1])
			if print then device,filename=pg_filename(title) else window,/free
		endif

		title='Spectrum '+i2str(shot)+' '+channel+' window size: '+i2str(i)
		plot, freqax, winscan[i-windowsize[0],*], title=title, xstyle=1, xtitle='Frequency (kHz)'
	endfor

	; Reset original multiplot after band power plotting
	!P.MULTI=0
	!P.CHARSIZE=1.

endif

; Plot time integrated spectrogram as a function of windowsize
if wsplot then begin

	; Progress indicator
	print,'Plotting time integrated spectrogram as a function of windowsize'

	;Plot as bitmap
	title='Windowsize scan '+i2str(shot)+' '+channel+' window size: '+i2str(windowsize[0])+'-'+i2str(windowsize[1])
	if print then device,filename=pg_filename(title) else window,/free
	title=title+' ('+pg_num2str((timeax[1]-timeax[0])*windowsize[0])+'-'+pg_num2str((timeax[1]-timeax[0])*windowsize[1])+')'
	pg_plot,winscan,xrange=[windowsize[0],windowsize[1]],yrange=[min(freqax),max(freqax)]$
		,xtitle='Window size (s)',ytitle='Frequency (kHz)',title=title,log=log,opt=opt,/norm

endif

timeax=timeax
freqax=freqax

if print then device,/close

return, winscan

end
