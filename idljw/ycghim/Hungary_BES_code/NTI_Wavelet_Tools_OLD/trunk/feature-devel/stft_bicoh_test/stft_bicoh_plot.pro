;********************************************************************************************************
;
;    Name: STFT_BICOH_PLOT
;
;    Written by: Laszlo Horvath 2010 - Gergo Pokol 2013
;
;
;  SHORT MANUAL
;  ------------
;
;
; PURPOSE
; =======
;
;  This program plots the loaded STFT bicoherence data: 
;  2D frequency1-frequency2 plots for given time points
;  and time-frequency2 plots for given frequency1 values.
;
; USAGE
; =====
;
; SWITCHES
; ========
;
; NEEDED PROGRAMS:
; ================
;
;  pg_initgraph.pro
;  default.pro
;  nti_wavelet_i2str.pro
;  pg_num2str.pro
;
;********************************************************************************************************

pro stft_bicoh_plot, bicoherences=bicoherences, timeax=timeax, freqax=freqax, $
    times=times, freqs=freqs, trange=trange, $
    expname=expname, shotnumber=shotnumber, channels=channels, $
    stft_window=stft_window, stft_length=stft_length, $
    stft_fres=stft_fres, stft_step=stft_step, $
    bicoh_avr=bicoh_avr, opt=opt

;SETTING DEFAULTS
;================

nti_wavelet_default,times,[0]
nti_wavelet_default,freqs,[0]
nti_wavelet_default,trange,[timeax[0],timeax[n_elements(timeax)-1]]
nti_wavelet_default,expname,'-'
nti_wavelet_default,shotnumber,'-'
nti_wavelet_default,channels,'-'
nti_wavelet_default,revision,0
nti_wavelet_default,opt,1

;Bicoh
bicoh_title='Bicoherence'
bicoh_xtitle='Frequency 1 [kHz]'
bicoh_ytitle='Frequency 2 [kHz]'

;Color scale
cs_xtitle='Bicoherence'

;READ_REVISION
;=============

svn_data=strarr(5)
svn_path='./.svn/entries'
; .svn directory found, but can we open it?
openr,unit,svn_path,/get_lun,error=error
if error ne 0 then begin 
  print, 'Subversion file could not be opened at '+svn_path
endif else begin
  readf,unit,svn_data
endelse

;print, svn_data
revision=fix(svn_data[3])

if NOT (times EQ [0]) then begin

  ntimes = n_elements(times)
  for k = 0,ntimes-1 do begin
    ;Find timepoint
    time = times(k)
    i = where(min(timeax - time, /abs) eq (timeax - time))
    time = timeax(i)
    
    ;Channels
    nchannels = n_elements(channels)
    for m = 0, nchannels-1 do begin
    
      ;Find bicoherence matrix
      bicoh = reform(bicoherences(m,i,*,*))

      ;create frequency axes
      ;---------------------
	;frequency axes of x direction
	xfreqax=freqax
	;frequency axes of y direction
	yfreqax=freqax(0:n_elements(freqax)/2-1)
	;points out of domain set to 1
	plot_bicoh=bicoh
	endloop = n_elements(yfreqax)-1; end of for loop
	length = n_elements(xfreqax)
	for j = 1L, endloop do begin
	  plot_bicoh(0:j-1,j) = 1
	  plot_bicoh(length-j:length-1,j) = 1
	endfor
  
      ;plot bispectrum
      ;---------------
	;setting path and name
	date=bin_date(systime())
	date=nti_wavelet_i2str(date[0])+'-'+nti_wavelet_i2str(date[1])+'-'+nti_wavelet_i2str(date[2])
	path='./bicoherence_data/'
	file_mkdir,path
	name='Bicoherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+' '+channels(m)+' '+pg_num2str(timeax(i))+'s'
	filename=pg_filename(name,dir=path, ext='.eps')

	;initializing printing parameters
	pg_initgraph,/print
	!P.FONT=0
	device,bits_per_pixel=8,font_size=8,/portrait,/color,/encapsulated,/cmyk,/preview
	device, filename=filename
    
	;transform bicoherence matrix for plot
	  ;Color scale optimisation:
	  plot_bicoh = plot_bicoh^opt
	plot_bicoh=plot_bicoh*255
	
	;load color table
	loadct,5
    
	;plot axes
	plot,[min(xfreqax),max(xfreqax)],[min(yfreqax),max(yfreqax)],xmargin=[10.5,4.5],ymargin=[10,3]$
	,title=bicoh_title,xtitle=bicoh_xtitle,ytitle=bicoh_ytitle,/nodata,$
	xstyle=1,ystyle=1,xticklen=-0.01,yticklen=-0.01,charsize=2,charthick=3,xthick=3,ythick=3

	;plot bicoherence matrix
	px=!x.window
	py=!y.window
	tv,plot_bicoh,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal

	;initialize color scale
	cscale=fltarr(256,2)
	cscale[*,0]=findgen(256)/255.
	cscale[*,1]=findgen(256)/255.
	axis=cscale[*,0]
	;Color scale optimisation:
	cscale = cscale^opt
	cscale = cscale*255.

	;plot axes of color scale
	plot,[0,1],axis,/nodata,xstyle=1,ystyle=1,yrange=[0,1],yticklen=0,ytitle='',xmargin=[14,51],ymargin=[5,34]$
	,ytickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']$
	,xrange=[min(axis),max(axis)]$
	,xtitle=cs_xtitle,NOERASE=1,xthick=3,ythick=3,charsize=1.3,charthick=2

	;plot color scale
	px=!x.window
	py=!y.window
	tv,cscale,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal

	;initialize xyouts
	dt=double(timeax(n_elements(timeax)-1)-timeax(0))/double(n_elements(timeax)-1)
	info='Date: '+systime()+$
	  '!C'+'version: r'+pg_num2str(revision)+$
	  '!C'+'window: '+pg_num2str(stft_window)+$
	  '!C'+'winsize: '+pg_num2str(stft_length)+$
	  '!C '+pg_num2str(dt*stft_length/stft_step)+' s'+$
	  '!C'+'fres: '+pg_num2str(stft_fres)+$
	  '!C'+'step: '+pg_num2str(stft_step)+$
	  '!C'+'averages: '+pg_num2str(bicoh_avr)
        
	;plot xyouts
	xyouts,0.62,0.19,info,/normal,charsize=1.2,charthick=1.8
	xyouts, 0.2, 0.83, pg_num2str(timeax(i))+' s',charsize=2,charthick=2, /normal
	xyouts, 0.7, 0.83, expname+' #'+nti_wavelet_i2str(shotnumber)+'!C !C'+channels(m),charsize=2,charthick=2, /normal

	device, /close
	
	;restoring printing parameters
	pg_initgraph
	!P.FONT=-1

    endfor  ;channels
  endfor  ;times
  
endif

if NOT (freqs EQ [0]) then begin

  ;points out of domain set to 1
  plot_bicoh=bicoherences
  endloop = n_elements(yfreqax)-1; end of for loop
  length = n_elements(xfreqax)
  for j = 1L, endloop do begin
    plot_bicoh(*,*,0:j-1,j) = 1
    plot_bicoh(*,*,length-j:length-1,j) = 1
  endfor

  nfreqs = n_elements(freqs)
  for k = 0,nfreqs-1 do begin
  
    ;Find timepoint
    freq = freqs(k)
    i = where(min(freqax - freq, /abs) eq (freqax - freq))
    freq = freqax(i)
    
    ;Channels
    nchannels = n_elements(channels)
    for m = 0, nchannels-1 do begin
    
      ;Create matrix to be plotted
      matrix = [[reform(plot_bicoh(m,*,i,0:i))],[reform(plot_bicoh(m,*,i+1:n_elements(freqax)-i-1,i))]]
      
      ;Plot matrix
      path='./bicoherence_data/'
      file_mkdir,path
      name = 'Bicoherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+' '+channels(i)+' '+pg_num2str(freq)+' kHz'
      filename=pg_filename(name,dir=path, ext='.eps')

      pg_initgraph, /print, /portrait
      device,bits_per_pixel=8,font_size=8,/portrait,/color,/encapsulated,/cmyk,/preview
      device, filename=filename

      ;initialize xyouts
      dt=double(timeax(n_elements(timeax)-1)-timeax(0))/double(n_elements(timeax)-1)
      transf_printdatas=$
        'version: r'+pg_num2str(revision)+$
	'!Cshot: '+expname+' '+pg_num2str(shotnumber)+$
	'!Cwindow: '+pg_num2str(stft_window)+$
	'!Cwinsize: '+pg_num2str(stft_length)+'!C '+pg_num2str(dt*stft_length/stft_step)+'s'+$
	'!Cfres: '+pg_num2str(stft_fres)+$
	'!Cstep: '+pg_num2str(stft_step)
      
      title = 'Bicoherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+' '+channels(i)+'!C'+pg_num2str(freq)+' kHz'
      pg_plot4,matrix,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),freqax(n_elements(freqax)-i-1)],$
	xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=opt, zrange = [0,1], poster=1, data=transf_printdatas
            
      device, /close
      pg_initgraph

    endfor  ;channels
  endfor  ;freqs

endif 


end