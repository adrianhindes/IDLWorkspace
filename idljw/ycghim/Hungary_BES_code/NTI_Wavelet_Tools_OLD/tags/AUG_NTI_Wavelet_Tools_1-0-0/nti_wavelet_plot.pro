;+
;
;NAME: nti_wavelet_plot
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2011.07.25.
;
; PURPOSE: Plot scalograms (or spectrograms), cross/transforms, coherences and mode numbers
;       on the time-frequency plane, as calculated by nti_wavelet_main.pro.
;
;-

pro nti_wavelet_plot, $
  ; Inputs - calculation results
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, modenumbers=modenumbers, qs=qs,$
  ; Inputs - processing parameters
    expname=expname, shotnumber=shotnumber, channels=channels, channelpairs_used=channelpairs_used,$
    cwt_selection=cwt_selection, cwt_family=cwt_family, cwt_order=cwt_order, cwt_dscale=cwt_dscale,$
    stft_selection=stft_selection, stft_window=stft_window, stft_length=stft_length, stft_fres=stft_fres,$
    stft_step=stft_step, freq_min=freq_min, freq_max=freq_max, coh_avr=coh_avr,$
    mode_type=mode_type, mode_filter=mode_filter,$
    mode_steps=mode_steps, mode_min=mode_min, mode_max=mode_max, $
  ; Inputs - visualization parameters
    transf_selection=transf_selection, transf_smooth=transf_smooth, transf_energy=transf_energy,$
    transf_phase=transf_phase, transf_cscale=transf_cscale,$
    crosstr_selection=crosstr_selection, crosstr_smooth=crosstr_smooth, crosstr_energy=crosstr_energy,$
    crosstr_phase=crosstr_phase, crosstr_cscale=crosstr_cscale,$
    coh_selection=coh_selection, coh_all=coh_all, coh_avg=coh_avg, coh_min=coh_min,$
    mode_selection=mode_selection, mode_cohlimit=mode_cohlimit, mode_powlimit=mode_powlimit,$
    mode_qlimit=mode_qlimit, linear_freqax=linear_freqax,$
  ; Paths
    startpath=startpath, savepath=savepath, version=version

compile_opt defint32 ; 32 bit integers

; Set defaults
if not(keyword_set(transf_selection)) then transf_selection=0
if not(keyword_set(transf_smooth)) then transf_smooth=0
if not(keyword_set(transf_energy)) then transf_energy=0
if not(keyword_set(transf_phase)) then transf_phase=0
if not(keyword_set(transf_cscale)) then transf_cscale=0.4
if not(keyword_set(crosstr_selection)) then crosstr_selection=0
if not(keyword_set(crosstr_smooth)) then crosstr_smooth=0
if not(keyword_set(crosstr_energy)) then crosstr_energy=0
if not(keyword_set(crosstr_phase)) then crosstr_phase=0
if not(keyword_set(crosstr_cscale)) then crosstr_cscale=0.4
if not(keyword_set(coh_selection)) then coh_selection=0
if not(keyword_set(coh_all)) then coh_all=0
if not(keyword_set(coh_avg)) then coh_avg=0
if not(keyword_set(coh_min)) then coh_min=0
if not(keyword_set(mode_selection)) then mode_selection=0
if not(keyword_set(mode_cohlimit)) then mode_cohlimit=0
if not(keyword_set(mode_powlimit)) then mode_powlimit=0
if not(keyword_set(linear_freqax)) then linear_freqax=0
if not(keyword_set(savepath)) then cd, current=savepath
if not(keyword_set(startpath)) then startpath='./'
if not(keyword_set(version)) then version='Unidentified version'
channelsize=n_elements(channels)
crosssize=(size(channelpairs_used))(2)
transformsize=size(transforms)
dt=double(timeax(n_elements(timeax)-1)-timeax(0))/double(n_elements(timeax)-1)

; Initialize graphics
pg_initgraph,/print
shot_printdatas=$
  'version: '+version+$
  '!Cshot: '+expname+' '+i2str(shotnumber)
if cwt_selection then begin
  transf_printdatas=$
		'!Cfamily: '+cwt_family+$
		'!Corder: '+i2str(cwt_order)+$
		'!Cdscale: '+pg_num2str(cwt_dscale,length=5)
endif else begin
  transf_printdatas=$
		'!Cwindow: '+stft_window+$
		'!Cwinsize: '+i2str(stft_length)+'!C '+pg_num2str(dt*stft_length/stft_step)+'s'+$
		'!Cfres: '+i2str(stft_fres)+$
		'!Cstep: '+i2str(stft_step)
endelse

; Plot transforms
if transf_selection then begin
  print,'Plotting transforms'
  if transf_energy then begin
    loadct,5,file=startpath+'nti_wavelet_colors.tbl'
    if transf_smooth then begin
      for i=0,channelsize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannel: '+channels(i)+$
          transf_printdatas+$
          '!Caverages: '+i2str(coh_avr)
        plotted=reform(smoothed_apsds(i,*,*))
        if cwt_selection then begin
          title='Smoothed scalogram of '+expname+' '+i2str(shotnumber)+'-'+channels(i)
          device,filename=pg_filename(title,dir=savepath)
          if linear_freqax then begin
            colors_scale_exponent=1/transf_cscale
            levels=findgen(60)^colors_scale_exponent
            levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
            CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
               levels=levels,title=title
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
              ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=transf_cscale,data=printdatas
          endelse
        endif else begin
          title='Smoothed spectrogram of '+expname+' '+i2str(shotnumber)+'-'+channels(i)
          device,filename=pg_filename(title,dir=savepath)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas        
        endelse
      endfor
    endif else begin
      for i=0,channelsize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannel: '+channels(i)+$
          transf_printdatas
        plotted=reform(abs(transforms(i,*,*))^2)
        if cwt_selection then begin
          title='Scalogram of '+expname+' '+i2str(shotnumber)+'-'+channels(i)
          device,filename=pg_filename(title,dir=savepath)
          if linear_freqax then begin
            colors_scale_exponent=1/transf_cscale
            levels=findgen(60)^colors_scale_exponent
            levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
            CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
               levels=levels,title=title
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
              ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=transf_cscale,data=printdatas
          endelse
        endif else begin
          title='Spectrogram of '+expname+' '+i2str(shotnumber)+'-'+channels(i)
          device,filename=pg_filename(title,dir=savepath)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas        
        endelse
      endfor      
    endelse
  endif
  if transf_phase then begin
    loadct,0,file=startpath+'nti_wavelet_colors.tbl'
    for i=0,channelsize-1 do begin
      printdatas=shot_printdatas+$
        '!Cchannel: '+channels(i)+$
        transf_printdatas
      plotted=reform(atan(imaginary(transforms(i,*,*)),float(transforms(i,*,*))))
      if cwt_selection then begin
        title='CWT phase of '+expname+' '+i2str(shotnumber)+'-'+channels(i)
        device,filename=pg_filename(title,dir=savepath)
        if linear_freqax then begin
          levels=findgen(60)
          levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
          CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
             levels=levels,title=title
        endif else begin
          pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
            ,title=title,data=printdatas
        endelse
      endif else begin
        title='STFT phase of '+expname+' '+i2str(shotnumber)+'-'+channels(i)
        device,filename=pg_filename(title,dir=savepath)
        pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas        
      endelse
    endfor      
  endif
endif

; Plot cross-transforms
if crosstr_selection then begin
  print,'Plotting cross-transforms'
  if transf_energy then begin
    loadct,5,file=startpath+'nti_wavelet_colors.tbl'
    if crosstr_smooth then begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas+$
          '!Caverages: '+i2str(coh_avr)
        plotted=reform(abs(smoothed_crosstransforms(i,*,*))^2)
        if cwt_selection then begin
          title='Smoothed cross-scalogram of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          if linear_freqax then begin
            colors_scale_exponent=1/transf_cscale
            levels=findgen(60)^colors_scale_exponent
            levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
            CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
               levels=levels,title=title
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
              ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=transf_cscale,data=printdatas
          endelse
        endif else begin
          title='Smoothed cross-spectrogram of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas        
        endelse
      endfor
    endif else begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas
        plotted=reform(abs(crosstransforms(i,*,*))^2)
        if cwt_selection then begin
          title='Cross-scalogram of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          if linear_freqax then begin
            colors_scale_exponent=1/transf_cscale
            levels=findgen(60)^colors_scale_exponent
            levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
            CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
               levels=levels,title=title
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
              ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=transf_cscale,data=printdatas
          endelse
        endif else begin
          title='Cross-spectrogram of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas        
        endelse
      endfor      
    endelse
  endif
  if transf_phase then begin
    loadct,0,file=startpath+'nti_wavelet_colors.tbl'
    if transf_smooth then begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas+$
          '!Caverages: '+i2str(coh_avr)
        plotted=reform(atan(imaginary(smoothed_crosstransforms(i,*,*)),float(smoothed_crosstransforms(i,*,*))))
        if cwt_selection then begin
          title='Smoothed cross-CWT phases of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          if linear_freqax then begin
            levels=findgen(60)
            levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
            CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
               levels=levels,title=title
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
              ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,data=printdatas
          endelse
        endif else begin
          title='Smoothed cross-STFT phases of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas        
        endelse
      endfor
    endif else begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas
        plotted=reform(atan(imaginary(crosstransforms(i,*,*)),float(crosstransforms(i,*,*))))
        if cwt_selection then begin
          title='Cross-CWT phases of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          if linear_freqax then begin
            levels=findgen(60)
            levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
            CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
               levels=levels,title=title
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
              ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,data=printdatas
          endelse
        endif else begin
          title='Cross-STFT phases of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          device,filename=pg_filename(title,dir=savepath)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas        
        endelse
      endfor      
    endelse
  endif
endif

; Plot coherences
if coh_selection then begin
  print,'Plotting coherences'
  loadct,5,file=startpath+'nti_wavelet_colors.tbl'
  if coh_all then begin
    for i=0,crosssize-1 do begin
      printdatas=shot_printdatas+$
        '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
        transf_printdatas+$
        '!Caverages: '+i2str(coh_avr)
      plotted=reform(coherences(i,*,*))
      if cwt_selection then begin
        title='Coherence of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
        device,filename=pg_filename(title,dir=savepath)
        if linear_freqax then begin
          levels=findgen(60)
          levels=levels/max(levels)
          CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
             levels=levels,title=title
        endif else begin
          pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
            ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))],zrange=[0,1]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
            ,title=title,data=printdatas
        endelse
      endif else begin
        title='Coherence of '+expname+' '+i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
        device,filename=pg_filename(title,dir=savepath)
        pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)],zrange=[0,1]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas        
      endelse
    endfor
  endif 
  if coh_avg then begin
    printdatas=shot_printdatas+$
      transf_printdatas+$
      '!Caverages: '+i2str(coh_avr)+$
      '!Cchannel pairs: '+i2str(crosssize)
    for i=0,crosssize-1 do printdatas=printdatas+'!C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
    
    plotted=total(coherences,1)/crosssize ;Calculating average coherence
    
    if cwt_selection then begin
      title='Average coherence of '+expname+' '+i2str(shotnumber)
      device,filename=pg_filename(title,dir=savepath)
      if linear_freqax then begin
        levels=findgen(60)
        levels=levels/max(levels)
        CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
           levels=levels,title=title
      endif else begin
        pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
          ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))],zrange=[0,1]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
          ,title=title,data=printdatas
      endelse
    endif else begin
      title='Average coherence of '+expname+' '+i2str(shotnumber)
      device,filename=pg_filename(title,dir=savepath)
      pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)],zrange=[0,1]$
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas        
    endelse
  endif 
  if coh_min then begin
    printdatas=shot_printdatas+$
      transf_printdatas+$
      '!Caverages: '+i2str(coh_avr)+$
      '!Cchannel pairs: '+i2str(crosssize)
    for i=0,crosssize-1 do printdatas=printdatas+'!C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)

    plotted=min(coherences,dimension=1)
    if cwt_selection then begin
      title='Minimum coherence of '+expname+' '+i2str(shotnumber)
      device,filename=pg_filename(title,dir=savepath)
      if linear_freqax then begin
        levels=findgen(60)
        levels=levels/max(levels)
        CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
           levels=levels,title=title
      endif else begin
        pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
          ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))],zrange=[0,1]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
          ,title=title,data=printdatas
      endelse
    endif else begin
      title='Minimum coherence of '+expname+' '+i2str(shotnumber)
      device,filename=pg_filename(title,dir=savepath)
      pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)],zrange=[0,1]$
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas        
    endelse
  endif 
endif

; Plot mode numbers
if mode_selection then begin
  print,'Plotting mode numbers'
  loadct,42,file=startpath+'nti_wavelet_colors.tbl'
  modescale=[mode_min,mode_max]
  printdatas=shot_printdatas+$
    transf_printdatas+$
    '!Caverages: '+i2str(coh_avr)+$
    '!Cfilter: '+i2str(mode_filter)+$
    '!Cmode steps: '+pg_num2str(mode_steps,length=5)+$
    '!CCoherence limit: '+i2str(mode_cohlimit)+' %'+$
    '!CPower limit: '+i2str(mode_powlimit)+' %'+$    
    '!CQ limit: '+i2str(mode_qlimit)+' %'+$    
    '!Cchannel pairs: '+i2str(crosssize)
  for i=0,crosssize-1 do printdatas=printdatas+'!C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
  
  plotted=modenumbers
    
  ; Filter mode numbers
  ; Filter out modes out of plotted range
  notplotted=where((plotted LT modescale(0)) OR (plotted GT modescale(1)))
  if max(notplotted) GT -1 then plotted(notplotted)=1000
  ; Filter out modes with low coherence
  if mode_cohlimit NE 0. then begin
    mode_cohlimit=float(mode_cohlimit)/100.
    ; Calculate minimum coherence for coherence limit filtering
    limcoh=min(coherences,dimension=1)
    ; Do filtering
    notplotted=where(limcoh LT mode_cohlimit)
    if max(notplotted) GT -1 then plotted(notplotted)=1000
  endif
  ; Filter out modes with low power
  if mode_powlimit NE 0. then begin
    mode_powlimit=float(mode_powlimit)/100.
    ; Calculate average cross energy density for power limit filtering
    limpow=fltarr(transformsize(2),transformsize(3))
    if (size(smoothed_crosstransforms))(0) LT 2 then begin
      for i=0,transformsize(2)-1 do begin
        for j=0,transformsize(3)-1 do begin
          limpow(i,j)=mean(abs(crosstransforms(*,i,j))^2)
        endfor
      endfor
    endif else begin
      for i=0,transformsize(2)-1 do begin
        for j=0,transformsize(3)-1 do begin
          limpow(i,j)=mean(abs(smoothed_crosstransforms(*,i,j))^2)
        endfor
      endfor
    endelse
    limpow=limpow/max(limpow)
    ; Do filtering
    notplotted=where(limpow LT mode_powlimit)
    if max(notplotted) GT -1 then plotted(notplotted)=1000    
  endif
  ; Filter out modes with high fitting remainder
  if mode_qlimit NE 100. then begin
    mode_qlimit=float(mode_qlimit)/100.
    ; Calculate normalized Q matrix for Q limit filtering
    limq=qs/max(qs)
    ; Do filtering
    notplotted=where(limq GT mode_qlimit)
    if max(notplotted) GT -1 then plotted(notplotted)=1000        
  endif
  
  ; Set not defined mode numbers for plotting
  notplotted=where((plotted LT modescale(0)) OR (plotted GT modescale(1)))
  if max(notplotted) NE -1 then plotted(notplotted)=modescale(1)+(modescale(1)-modescale(0))/200.
  
  if cwt_selection then begin
    title=mode_type+' mode numbers of '+expname+' '+i2str(shotnumber)
    device,filename=pg_filename(title,dir=savepath)
    if linear_freqax then begin
      levels=findgen(fix(modescale(1)-modescale(0)+1))
      levels=levels/(max(levels))*(modescale(1)-modescale(0))+modescale(0)
      levels=[levels,modescale(1)+(modescale(1)-modescale(0))/200.]
      CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time',$
        YTITLE='Frequency (kHz)',levels=levels,title=title
    endif else begin
      pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
        ,/ylog,y2range=[min(-pg_log2(scaleax)),max(-pg_log2(scaleax))] $
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
        ,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz
    endelse
  endif else begin
    title=mode_type+' mode numbers of '+expname+' '+i2str(shotnumber)
    device,filename=pg_filename(title,dir=savepath)
      pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)] $
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
        ,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],/intz
  endelse
endif

device,/close
pg_initgraph

end
