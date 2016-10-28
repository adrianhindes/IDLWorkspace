pro analyse_precursor, shot, type=type, frange=frange, overplot=op, twin1=twin1, twin2=twin2,$
                       one=one, hist=hist, noplot=noplot, correlation=correlation, spect=spect, $
                       vchannel=vchannel, coherency=coherency, int=int, winsize=ws,  stft=stft,$
                       channel=channel, velocity=velocity, modenumber=modenumber, ps=ps, $
                       onlyplot=onlyplot, raddist=raddist, line=line

;**************************************************************
;*                 analyse_precursor                          *
;**************************************************************
;* The routine restores elmdatabase.sav from the KSTAR        *
;* directory and analyses the precursors with the             *
;* set input parameters.                                      *
;**************************************************************
;*INPUTs:                                                     *
;*        shot: shotnumber                                    *
;*        type: type of the precursor                         *
;*        frange: frequency range of the calculation          *
;*        overplot: overplot all spectrum onto each           *
;*                  other for all ELMs                        *
;*        twin1,twin2: timewindow for the plotting, it        *
;*                     should be used like this:              *
;*                     [elmtime-twin1[0],elmtime+twin1[1]]    *
;*                     the two are for the spectrum           *
;*                     analysis                               *
;*        one: plot only one spectrum for twin1               *
;*        noplot: do not create plot with floc_correlation    *
;*        correlation: calculate the correlation for          *
;*                     vchannel and the lowest channel in     *
;*                     the vchannel array                     *
;*        spect: calculate the spectrum for channel           *
;*        coherency: calculate the coherency between vchan    *
;*                   and the first channel in the vertical    *
;*                   array                                    *
;*        stft: calculate the short time Fourier transform    *
;*              for channel                                   *
;*        modenumber: calculate the mode number for vchannel  *
;*        int: integration time for stft                      *
;*        ws: windowsize for stft                             *
;*        vchannel: vertical channel for correlation          *
;*                  calculation default: 8                    *
;*        channel: channel number for spectrum calculation    *
;*                 default: BES-4-8                           *
;*        postscript: create postscript file for the plots    *
;*OUTPUTs: None    (plots or .ps file)                        *
;**************************************************************

cd, 'd:\KFKI\Measurements\KSTAR\Measurement'
restore, 'elmdatabase.sav'
default, type, -1
default, frange, [1e3, 1e5]
default, one, 1
default, noplot, 0
set_plot_style, 'foile_kg'
if not defined(shot) then begin
  ind=where(database.prec_type eq type and database.bes_time ne -2)
endif else begin
  if type eq -1 then begin
    ind=where(database.prec_time ne -2 and database.shot eq shot and database.bes_time ne -2)
  endif else begin
    ind=where(database.shot eq shot and database.prec_type eq type and database.bes_time ne -2)
  endelse
endelse
n=n_elements(ind)

bl=defined(correlation) + defined(spect) + defined(coherency) + defined(stft) + $
   defined(modenumber) + defined(velocity) + defined(onlyplot) + defined(raddist)
if (bl eq 0) then begin
  print, 'Please specify one of the following: /spect, /coherency, /correlation. Now returning...'
  return
endif
if (bl gt 1) then begin
  print, 'Please define only one thing (correlation,spect, coherency, stft)! Now returning...'
  return
endif

if defined(spect)       then def=0
if defined(correlation) then def=1
if defined(coherency)   then def=2
if defined(stft)        then def=3
if defined(velocity)    then def=4
if defined(modenumber)  then def=5
if defined(onlyplot)    then def=6
if defined(raddist)     then def=7

case def of
  0: filename=dir_f_name('plots/','analyse_precursor_spect_type'+strtrim(type,2))
  1: filename=dir_f_name('plots/','analyse_precursor_correlation_type'+strtrim(type,2))
  2: filename=dir_f_name('plots/','analyse_precursor_coherency_type'+strtrim(type,2))
  3: filename=dir_f_name('plots/','analyse_precursor_stft_type'+strtrim(type,2))
  4: filename=dir_f_name('plots/','analyse_precursor_velocity_type'+strtrim(type,2))
  5: filename=dir_f_name('plots/','analyse_precursor_modenumber_type'+strtrim(type,2))
  6: filename=dir_f_name('plots/','analyse_precursor_onlyplot_type'+strtrim(type,2))
  7: filename=dir_f_name('plots/','analyse_precursor_raddist_type'+strtrim(type,2))
endcase

;*****************************************************
;*  Calculate the spectrum with the input variables  *
;*****************************************************

if def eq 0 then begin
  maxf=dblarr(n)
  default, twin1, [0.001,-0.0005]
  default, twin2, [0.0005,0]
  
  loadct, 39
  default, channel, 'BES-4-8'
  if keyword_set(ps) then hardon, /color
  fres=500.
  nhist=round(frange[1]-frange[0])/fres+1
  hist=dblarr(nhist,2)
  hist[*,0]=frange[0]+indgen(nhist)*fres
  intn=2
  for i=0,n-1 do begin
    if not (keyword_set(op)) then begin
      shot2=database[ind[i]].shot
      elmtime=database[ind[i]].bes_time
      if (keyword_set(one)) then begin
        pos1=[0.05,0.05,0.95,0.95]
        pos2=[0.05,0.95,0.95,0.95]
        xc=1.5
        cs=0.01
      endif else begin
        pos1=[0.05,0.50,0.95,0.95]
        pos2=[0.05,0.05,0.95,0.50]
        
        xc=0.01
        cs=1.5
      endelse
      
      time_range=[elmtime-twin1[0],elmtime+twin1[1]]
      fluc_correlation, shot2, timerange=time_range, refchan=channel, /auto, frange=frange, /plot_power, outpower=outpower1, $
                        outfscale=fscale1, interval_n=2, /noplot
      time_range=[elmtime-twin2[0],elmtime+twin2[1]]
      fluc_correlation, shot2, timerange=time_range, refchan=channel, /auto, frange=frange, /plot_power, outpower=outpower2, $
                        outfscale=fscale2, interval_n=2, /noplot
      if not keyword_set(noplot) then begin
        plot, fscale1, outpower1, position=pos1, /noerase, xcharsize=xc, ycharsize=1.5, thick=3, title='Power'
        plot, fscale2, outpower2, position=pos2, /noerase, xcharsize=xc, ycharsize=1.5, title='Power', thick=3
      endif
      erase
    endif else begin
      shot2=database[ind[i]].shot
      elmtime=database[ind[i]].bes_time
      time_range1=[elmtime-twin1[0],elmtime+twin1[1]]
      time_range2=[elmtime-twin2[0],elmtime+twin2[1]]
      if (keyword_set(one)) then begin
        pos1=[0.05,0.05,0.95,0.95]
        pos2=[0.05,0.95,0.95,0.95]
        xc=1.5
        xch=0.01
      endif else begin
        ;pos1=[0.05,0.50,0.95,0.95]
        ;pos2=[0.05,0.05,0.95,0.50]
        pos1=[0.05,0.50,0.95,0.80]
        pos2=[0.05,0.20,0.95,0.50]
        xc=0.01
        xch=1.5
      endelse
      
      if i eq 0 then begin
        fluc_correlation, shot2, timerange=time_range1, refchan=channel, /auto, frange=frange, /plot_power, position=pos1,$
                          /nolegend, /noerror, /nopara, /khz, xcharsize=xc, ycharsize=0.01, linethick=3, thick=3,$
                          /noerase, noplot=noplot, outpower=outpower1, outfscale=fscale1, interval_n=intn
        fluc_correlation, shot2, timerange=time_range2, refchan=channel, /auto, frange=frange, /plot_power, position=pos2,$
                          /nolegend, /noerror, /nopara, /khz, title=' ', ycharsize=0.01, linethick=3, thick=3, $
                          /noerase, xcharsize=xch, noplot=noplot, outpower=outpower2, outfscale=fscale2, interval_n=intn
      endif else begin
        fluc_correlation, shot2, timerange=time_range1, refchan=channel, /auto, frange=frange, /plot_power, position=pos1,$
                          /nolegend, /noerror, /nopara, /khz, charsize=0.01, linethick=3, thick=3, /noerase,$
                          title=' ', outpower=outpower1, outfscale=fscale1, noplot=noplot, interval_n=intn
        fluc_correlation, shot2, timerange=time_range2, refchan=channel, /auto, frange=frange, /plot_power, position=pos2,$
                          /nolegend, /noerror, /nopara, /khz, title=' ', charsize=0.01, linethick=3, thick=3,$
                          /noerase, outpower=outpower2, outfscale=fscale2, noplot=noplot, interval_n=intn
      endelse
      
      if (keyword_set(hist) and keyword_set(noplot)) then begin
        a=max(outpower1,maxind)
        fmax=fscale1[maxind]
        for j=0,nhist-1 do begin
          if ((fmax gt hist[j,0]-fres/2) and (fmax lt hist[j,0]+fres/2)) then hist[j,1]+=1 
        endfor
      endif
    endelse
  endfor
  if (keyword_set(hist) and keyword_set(noplot)) then begin
    erase
    plot, hist[*,0], hist[*,1], xtitle='Frequency [Hz]', ytitle='Number of events', xstyle=1, ystyle=1, charsize=1.5, thick=3
  endif
  str=''
  if not defined(noplot) then begin 
    if defined(op) then str+='_oplot'
    if not defined(shot) then str+='_all'
    if defined(one) then str+='_one'
  endif
  if defined(hist) then str+='_hist'
  if keyword_set(ps) then hardfile, filename+str+'.ps'
endif

;****************************************************************
;* calculate the correlation for a given vertical channel array *
;****************************************************************
if def eq 1 then begin

  default, vchannel, 8
  position=[[0.05,0.65,0.95,0.91],$
            [0.05,0.35,0.95,0.61],$
            [0.05,0.05,0.95,0.31]]
  erase
  if keyword_set(ps) then hardon, /color
  for i=0,n-1 do begin
    default, twin1, [0.005,0.001]
    time_range=[database[ind[i]].time-twin1[0], database[ind[i]].time+twin1[1]]
    shot2=database[ind[i]].shot
    for j=0,2 do begin
      plotchan='BES-1-'+strtrim(vchannel,2)
      refchan='BES-'+strtrim(4-j,2)+'-'+strtrim(vchannel,2)
      if j lt 2 then begin
        xc=0.01
        yc=2
      endif else begin
        xc=2
        yc=2
      endelse
      fluc_correlation, shot2, timerange=time_range, refchan=refchan, plotchan=plotchan, frange=frange, /plot_correlation, $
                        xcharsize=xc, ycharsize=yc, linethick=3, thick=3, title=refchan+' and '+plotchan+' correlation',$
                        /noerase, outcorr=outcorr, outfscale=fscale, noplot=noplot, $
                        position=position[*,j], /noerror ;,/nolegend, /noerror, /nopara, /khz
      
    endfor
    if not keyword_set(ps) then cursor, x, y, /down
    erase
  endfor
  if keyword_set(ps) then hardfile, filename+'.ps'
endif

;**************************************************************
;* calculate the coherency for a given vertical channel array *
;**************************************************************
if def eq 2 then begin
  default, vchannel, 8
  default, twin1, [0.001,-0.0005]
  position=[[0.05,0.65,0.95,0.91],$
            [0.05,0.35,0.95,0.61],$
            [0.05,0.05,0.95,0.31]]
  erase
  if keyword_set(ps) then hardon, /color   
  for i=0,n-1 do begin
    time_range=[database[ind[i]].time-twin1[0], database[ind[i]].time+twin1[1]]
    shot2=database[ind[i]].shot
    for j=0,2 do begin
      plotchan='BES-1-'+strtrim(vchannel,2)
      refchan='BES-'+strtrim(4-j,2)+'-'+strtrim(vchannel,2)
      if j lt 2 then begin
        xc=0.01
        yc=1
      endif else begin
        xc=1
        yc=1
      endelse
        
      fluc_correlation, shot2, timerange=time_range, refchan=refchan, frange=frange, $
                       /plot_spectra, outpower=outpower, outfscale=fscale, /noplot,/silent
      a=max(outpower,maxind)
      fmax=fscale[maxind]
      fluc_correlation, shot2, timerange=time_range, refchan=refchan, plotchan=plotchan, frange=frange, /plot_spectra, $
                        xcharsize=xc, ycharsize=yc, linethick=1, thick=1, $ ;title=refchan+' and '+plotchan+' coherency',$
                        /noerase, outcorr=outcorr, outfscale=fscale, noplot=noplot, /norm, $
                        position=position[*,j], /noerror ;,/nolegend, /noerror, /nopara, /khz
      loadct, 5
      oplot, [fmax,fmax], [-1e15,1e15], linestyle=3, color=100
                        
      
    endfor
      
    if not keyword_set(ps) then cursor, x, y, /down
    erase
  endfor
  if keyword_set(ps) then hardfile, filename+'.ps' 
endif

;******************************************
;* calculate the stft for channel BES-4-8 *
;******************************************

if def eq 3 then begin
  n=n_elements(ind)
  maxf=dblarr(n)
  loadct, 39
  default, channel, 'BES-4-8'
  if keyword_set(ps) then hardon, /color
  for i=0,n-1 do begin
    shot2=database[ind[i]].shot
    elmtime=database[ind[i]].bes_time
    time_range=[elmtime-twin[0],elmtime+twin[1]]
    get_rawsignal, shot2, channel, time, data, trange=timerange
    print, time_range
    ;twin=0.001
    range=[elmtime-twin[0],elmtime+twin[1]]
    indt=where(time ge range[0] and time le range[1])   
    if indt[0] eq -1 then begin
       indt= indgen(n_elements(time))
    endif
    time=time[indt]
    data=data[indt]
    stft_kg1f=pg_spectrogram_sim(data,time,plot=-1,freqax=freqax, windowsize=ws)
    nx=n_elements(time)
    ny=n_elements(freqax)
    
    for fmin=0,ny-1 do begin
       if (freqax[fmin] ge frange[0]) then break
    endfor
    for fmax=fmin,ny-1 do begin
       if (freqax[fmax] ge frange[1]) then break
    endfor
    freqax=freqax[fmin:fmax]
    stft_rescale=fltarr(nx,fmax-fmin)
    stft_rescale=stft_kg1f[0:nx-1,fmin:fmax]
    nc=round(50*(2e33-2e23)/(max(abs(stft_rescale)^2)-min(abs(stft_rescale)^2)))
    levels1=(max(abs(stft_rescale)^2)-min(abs(stft_rescale)^2))/50.*findgen(51)+min(abs(stft_rescale)^2)
    nx=n_elements(time)
    ny=n_elements(freqax)
    sig=abs(stft_rescale)^2
    if keyword_set(ps) then hardon, /color
  ;set_plot_style, 'foile_kg_eps'
    DEVICE,DECOMPOSED=0
    print, strtrim(round(double(i+1)/double(n)*100),2)+'%'
    show_rawsignal, shot2, channel, trange=time_range, position=[0.1,0.33,0.85,0.66], int=int, charsize=1, /noerase
    show_rawsignal, shot2, '\TOR_HA09', trange=time_range, position=[0.1,0.66,0.85,0.95], /noerase, ystyle=1
  ;    plot, time,data, position=[0.1,0.50,0.85,0.9], xcharsize=0.01, ycharsize=cs, xrange=range,$
  ;          xstyle=1, xticks=10, ytitle='Amplitude', yticks=4
      contour,sig,time,freqax,xstyle=1,ystyle=1,nlevels=32,$
              /fill,xcharsize=0.01,ycharsize=cs,ytitle='Frequency [kHz]',$
              xtitle='Time [s]',levels=levels1, position=[0.1,0.05,0.85,0.33],$
              xrange=range, xticks=10, /noerase
      erase
  endfor
  if keyword_set(ps) then begin
    if not defined(shot) then begin
      hardfile, filename+'_all'+strtrim(type,2)+'.ps'
    endif else begin
      hardfile, 'precursor_analysis_'+strtrim(shot,2)+'_'+strtrim(type,2)+'.ps'
    endelse
  endif
endif

;*************************************
;*      calculate the velocity       *
;*************************************
;
; For the velocity calculation, one needs the time shift of each pixel for the vertical pixel array
; this could be gathered from the correlation by calculating the maximum of the correlation function
; and knowing the place of each detector pixel, it iw easy to calculate the velocity with linear regression. That's it falks!

if (def eq 4) then begin
default, twin1, [0.002,-0.0005]
  if keyword_set(ps) then hardon, /color
  if keyword_set(one) then begin
  
    timeshift=dblarr(n,2,4) ; [eventnum,[timeshift,distance]]
    v=dblarr(n)
    for i=0,n-1 do begin
        default,vchannel, 8
        time_range=[database[ind[i]].time-twin1[0], database[ind[i]].time+twin1[1]]
        shot2=database[ind[i]].shot
        detpos=getcal_kstar_spat(shot2, /xyz)
        for j=0,2 do begin
          plotchan='BES-1-'+strtrim(vchannel,2)
          refchan='BES-'+strtrim(j+2,2)+'-'+strtrim(vchannel,2)
  
          fluc_correlation, shot2, timerange=time_range, refchan=refchan, plotchan=plotchan, frange=frange, /plot_correlation, $
                          outcorr=outcorr, outtime=outtime, /noplot, /silent
          
          outcorr2=outcorr[where(outtime lt 0 and outtime gt -ws)]
          outtime2=outtime[where(outtime lt 0 and outtime gt -ws)]
          
          a=max(outcorr2,k)
          timeshift[i,0,j+1]=outtime2[k]*1e-6
          timeshift[i,1,j+1]=distance(detpos[j+1,vchannel-1,*],detpos[0,vchannel-1,*])*1e-3
          if not keyword_set(noplot) then begin
            plot, outtime, outcorr
            oplot, [outtime2[k],outtime2[k]], [-1e15,1e15]
            if not keyword_set(ps) then cursor, x,y, /down
            print, outtime[k]
            print, distance(detpos[j+1,vchannel-1,*],detpos[0,vchannel-1,*])
          endif
        endfor
        ;calculate the velocity with linear regression
        v[i]=(total(timeshift[i,0,*]*timeshift[i,1,*])-4*mean(timeshift[i,0,*])*mean(timeshift[i,1,*]))/$
             (total((timeshift[i,0,*])^2)-4*mean(timeshift[i,0,*])^2)
        
    endfor
    v=v[where(v gt -8*1e3)]
    
    if keyword_set(ps) then begin
      thick=3
      xc=0.01
      cs=2
    endif else begin
      xc=0.01
      cs=1
    endelse
    
    plot, findgen(n),v/1.e3, ytitle='Velocity [km/s]', xtitle='ELM event index', thick=thick, $
          xcharsize=cs, ycharsize=cs, /noerase, psym=4
          
    if keyword_set(ps) then hardfile, filename+'.ps'
          
  endif else begin
    default, twin1, [0.001,-0.0005]
    default, twin2, [0.0005,0]
    default, vchannel, 8
    
    timeshift=dblarr(n,2,4,2) ; [eventnum,[timeshift,distance]]
    v=dblarr(n,2)
    time_range=dblarr(2,2)
    
    for i=0,n-1 do begin
      default,vchannel, 8
      time_range[*,0]=[database[ind[i]].time-twin1[0], database[ind[i]].time+twin1[1]]
      time_range[*,1]=[database[ind[i]].time-twin2[0], database[ind[i]].time+twin2[1]]
      
      shot2=database[ind[i]].shot
      detpos=getcal_kstar_spat(shot2, /xyz)
      for j=0,2 do begin
        for k=0,1 do begin
          plotchan='BES-1-'+strtrim(vchannel,2)
          refchan='BES-'+strtrim(j+2,2)+'-'+strtrim(vchannel,2)
  
          fluc_correlation, shot2, timerange=time_range[*,k], refchan=refchan, plotchan=plotchan, frange=frange, /plot_correlation, $
                          outcorr=outcorr, outtime=outtime, /noplot, /silent
          outcorr2=outcorr[where(outtime lt 0 and outtime gt -ws)]
          outtime2=outtime[where(outtime lt 0 and outtime gt -ws)]
          
          a=max(outcorr2,maxind)
          timeshift[i,0,j+1,k]=outtime2[maxind]*1e-6
          timeshift[i,1,j+1,k]=distance(detpos[j+1,vchannel-1,*],detpos[0,vchannel-1,*])*1e-3
        endfor

;      if not keyword_set(noplot) then begin
;        plot, outtime, outcorr
;        oplot, [outtime2[maxind],outtime2[maxind]], [-1e15,1e15]
;        if not keyword_set(ps) then cursor, x,y, /down
;        print, outtime[k]
;        print, distance(detpos[j+1,vchannel-1,*],detpos[0,vchannel-1,*])
;      endif

    endfor
      ;calculate the velocity with linear regression
    for k=0,1 do begin
      v[i,k]=(total(timeshift[i,0,*,k]*timeshift[i,1,*,k])-4*mean(timeshift[i,0,*,k])*mean(timeshift[i,1,*,k]))/$
           (total((timeshift[i,0,*,k])^2)-4*mean(timeshift[i,0,*,k])^2)
    endfor
    
    endfor
    yrange=[-0.5,0.5]
    pos1=[0.05,0.50,0.95,0.95]
    pos2=[0.05,0.05,0.95,0.50]

    if keyword_set(ps) then begin
      thick=3
      xc=0.01
      cs=1.5
    endif else begin
      xc=0.01
      cs=1
    endelse
    
    plot, findgen(n),v[*,0]/1.e3, ytitle='Velocity [km/s]', xtitle='ELM event index', thick=thick, $
          position=pos1, xcharsize=xc, ycharsize=cs, psym=4
    plot, findgen(n),v[*,1]/1.e3, ytitle='Velocity [km/s]', xtitle='ELM event index', thick=thick, $
          position=pos2, xcharsize=cs, ycharsize=cs, /noerase, psym=4
          
    if keyword_set(ps) then hardfile, filename+'.ps'

  endelse
endif

;*******************************************
;*         calculate wavelength            *
;*******************************************

if (def eq 5) then begin
  default, vchannel, 8
  default, fwin, 2.5e3
  phaseshift=dblarr(n,2,4) ; [eventnum,[phaseshift,distance]]
  phaseshift_perm=dblarr(n,2,4,27)
  wavel=dblarr(n)
  wavel2=dblarr(n,27)
  
  polmodenum=dblarr(n)
  if keyword_set(one) then begin
    default, twin1, [0.002,-0.0005]
    for i=0,n-1 do begin
      time_range=[database[ind[i]].time-twin1[0], database[ind[i]].time+twin1[1]]
      shot2=database[ind[i]].shot
      detpos=getcal_kstar_spat(shot2, /xyz)
      for j=0,2 do begin
        plotchan='BES-1-'+strtrim(vchannel,2)
        refchan='BES-'+strtrim(4-j,2)+'-'+strtrim(vchannel,2)
        fluc_correlation, shot2, timerange=time_range, refchan=refchan, frange=frange, $
                          /plot_spectra, outpower=outpower, outfscale=fscale, /noplot,/silent
        a=max(outpower,maxind)
        fmax=fscale[maxind]
        fluc_correlation, shot2, timerange=time_range, refchan=refchan, plotchan=plotchan, frange=frange, $
                          /plot_spectra, outphase=outphase, outfscale=fscale, /noplot, /norm, /silent
        ;a=min(abs(fscale-fmax),minind)
        ;phaseshift[i,0,j+1]=outphase[minind]/(2.*!pi)
        
        ind3=where(fscale gt fmax-fwin and fscale lt fmax+fwin)
        phaseshift[i,0,j+1]=mean(outphase[ind3])/(2.*!pi)
       
        phaseshift[i,1,j+1]=distance(detpos[j+1,vchannel-1,*],detpos[0,vchannel-1,*])*1e-3
      endfor
      
;      for j=1,2 do begin
;        if ((phaseshift[i,0,j]-phaseshift[i,0,j-1]) gt 0.5) then phaseshift[i,0,j-1]+=1
;        if ((phaseshift[i,0,j]-phaseshift[i,0,j-1]) lt -0.5) then phaseshift[i,0,j-1]-=1
;      endfor


      for k=0,2 do begin
        for m=0,2 do begin
          for j=0,2 do begin
            phaseshift_perm[i,0,1,9*j+3*k+m]=phaseshift[i,0,1]+j-1
            phaseshift_perm[i,0,2,9*j+3*k+m]=phaseshift[i,0,2]+k-1
            phaseshift_perm[i,0,3,9*j+3*k+m]=phaseshift[i,0,3]+m-1
            phaseshift_perm[i,1,j,9*j+3*k+m]=phaseshift[i,1,j]
          endfor
        endfor
      endfor
      disp=dblarr(27)
    for k=0,26 do begin
        wavel2[i,k]=(total(phaseshift_perm[i,0,*,k]*phaseshift_perm[i,1,*,k])-4*mean(phaseshift_perm[i,0,*,k])*mean(phaseshift_perm[i,1,*,k]))/$
           (total((phaseshift_perm[i,0,*,k])^2)-4*mean(phaseshift_perm[i,0,*,k])^2)
      for j=0,2 do begin   
        disp[k]+=disp[k]+1/4.*(wavel2[i,k]-phaseshift_perm[i,1,j,k]/phaseshift_perm[i,0,j,k])   
      endfor
    endfor
    a=min(sqrt(disp),j)
    phaseshift[i,0,*]=phaseshift_perm[i,0,*,j]
    phaseshift[i,0,0]=-1
      wavel[i]=(total(phaseshift[i,0,*]*phaseshift[i,1,*])-4*mean(phaseshift[i,0,*])*mean(phaseshift[i,1,*]))/$
           (total((phaseshift[i,0,*])^2)-4*mean(phaseshift[i,0,*])^2)
      detpos=getcal_kstar_spat(shot2)
      R=mean(detpos[*,vchannel-1,0])*1e-3
      polmodenum[i]=2*(R-1.8)*!pi/wavel[i]  
    endfor
    mv=mean(abs(wavel))
    ind=where(abs(wavel) le mv*3)
    n=n_elements(ind)
    wavel=wavel[ind]
    polmodenum=polmodenum[ind]
    phaseshift2=dblarr(n_elements(ind),4)
    for i=0,3 do begin
      phaseshift2[*,i]=phaseshift[ind,0,i]
    endfor
    phaseshift=phaseshift2
    device, decomposed=0
    loadct, 5
    yrange=[-0.5,0.5]
    color=100
    if keyword_set(ps) then begin
      hardon, /color
      thick=3
      charsize=1.5
    endif
    phaseshift=phaseshift+1
    plot, findgen(n), wavel, color=color, ycharsize=0.1, yrange=yrange, xstyle=1
    axis, yaxis=1, ycharsize=1, yrange=yrange, color=color, ytitle='Wavelength [m]'
    plot, findgen(n), phaseshift[*,0,0], yrange=[-1,1], psym=4, /noerase, ytitle='Phase [2*pi*rad]',$
          xstyle=1, xtitle='ELM event index'
    for j=0,3 do oplot, findgen(n), phaseshift[*,j], psym=4
    if not keyword_set(ps) then cursor, x, y, /down
    plot, polmodenum, ytitle='Modenumber', xtitle='ELM event index', xstyle=1
    if keyword_set(ps) then hardfile, filename+'_'+strtrim(fwin,2)+'_one.ps'
    
  endif else begin
  
    ;This period is for the plotting of frequency changing precursors
    default, twin1, [0.001,-0.0005]
    default, twin2, [0.0005,0]
    default, vchannel, 8

    phaseshift=dblarr(n,2,4,2)
    phaseshift_perm=dblarr(n,2,4,2,27) ; [eventnum,[phaseshift,distance],hchannel,[twin1,twin2]]
    wavel=dblarr(n,2)
    wavel2=dblarr(n,2,27)
    polmodenum=dblarr(n,2)
    time_range=dblarr(2,2)
    
    for i=0,n-1 do begin
      print, double(i+1)/n
      time_range[*,0]=[database[ind[i]].time-twin1[0], database[ind[i]].time+twin1[1]]
      time_range[*,1]=[database[ind[i]].time-twin2[0], database[ind[i]].time+twin2[1]]
      shot2=database[ind[i]].shot
      detpos=getcal_kstar_spat(shot2, /xyz)
      for j=0,2 do begin
        plotchan='BES-1-'+strtrim(vchannel,2)
        refchan='BES-'+strtrim(4-j,2)+'-'+strtrim(vchannel,2)
        for k=0,1 do begin
          fluc_correlation, shot2, timerange=time_range[*,k], refchan=refchan, frange=frange, $
                            /plot_spectra, outpower=outpower, outfscale=fscale, /noplot, /silent
          a=max(outpower,maxind)
          
          fmax=fscale[maxind]
          fluc_correlation, shot2, timerange=time_range[*,k], refchan=refchan, plotchan=plotchan, frange=frange, $
                            /plot_spectra, outphase=outphase, outfscale=fscale, /noplot, /norm, /silent
          ind3=where(fscale gt fmax-fwin and fscale lt fmax+fwin)
          ;a=min(abs(fscale-fmax),minind)
          ;phaseshift[i,0,j+1,k]=outphase[minind]/(2.*!pi)
          phaseshift[i,0,j+1,k]=mean(outphase[ind3])/(2.*!pi)
          phaseshift[i,1,j+1,k]=distance(detpos[j+1,vchannel-1,*],detpos[0,vchannel-1,*])*1e-3
        endfor
      endfor
      ; The following part does the 2pi correction by doing all +2pi,0,-pi variations and fitting a line on that. The one with the lowest dispersion will be THE ONE.
      for k=0,2 do begin
        for m=0,2 do begin
          for j=0,2 do begin
            for o=0,1 do begin
              phaseshift_perm[i,0,1,o,9*j+3*k+m]=phaseshift[i,0,1,o]+j-1
              phaseshift_perm[i,0,2,o,9*j+3*k+m]=phaseshift[i,0,2,o]+k-1
              phaseshift_perm[i,0,3,o,9*j+3*k+m]=phaseshift[i,0,3,o]+m-1
              phaseshift_perm[i,1,j,o,9*j+3*k+m]=phaseshift[i,1,j,o]
            endfor
          endfor
        endfor
      endfor
    disp=dblarr(27,2)
    for k=0,26 do begin
      for l=0,1 do begin
          wavel2[i,l,k]=(total(phaseshift_perm[i,0,*,l,k]*phaseshift_perm[i,1,*,l,k])-4*mean(phaseshift_perm[i,0,*,l,k])*mean(phaseshift_perm[i,1,*,l,k]))/$
             (total((phaseshift_perm[i,0,*,l,k])^2)-4*mean(phaseshift_perm[i,0,*,l,k])^2)
        for j=0,2 do begin   
          disp[k,l]+=disp[k,l]+1/4.*(wavel2[i,l,k]-phaseshift_perm[i,1,j,l,k]/phaseshift_perm[i,0,j,l,k])   
        endfor
      endfor
    endfor
    bv=dblarr(27)
    for l=0,1 do begin
      bv[*]=disp[*,l]
      a=min(sqrt(bv),j)
      phaseshift[i,0,*,l]=phaseshift_perm[i,0,*,l,j]
      phaseshift[i,0,0,l]=-1
      wavel[i,l]=(total(phaseshift[i,0,*,l]*phaseshift[i,1,l,*])-4*mean(phaseshift[i,0,*,l])*mean(phaseshift[i,1,*,l]))/$
               (total((phaseshift[i,0,*,l])^2)-4*mean(phaseshift[i,0,*,l])^2)
      detpos=getcal_kstar_spat(shot2)
      R=mean(detpos[*,vchannel-1,0])*1e-3
      polmodenum[i]=2*(R-1.8)*!pi/wavel[i]  
    endfor


      
;      for j=1,3 do begin
;        for k=0,1 do begin
;          if ((phaseshift[i,0,j,k]-phaseshift[i,0,j-1,k]) gt 0.5)  then phaseshift[i,0,j-1,k]+=1
;          if ((phaseshift[i,0,j,k]-phaseshift[i,0,j-1,k]) lt -0.5) then phaseshift[i,0,j-1,k]-=1
;        endfor
;      endfor
      
;      ind2=where(phaseshift[i,0,*,0] lt 0)
;      if ind2[0] ne -1 then begin
;        phaseshift[i,0,ind2,0]+=1
;      endif
;      ind2=where(phaseshift[i,0,*,1] lt 0)
;      if ind2[0] ne -1 then begin
;        phaseshift[i,0,ind2,1]+=1
;      endif

      ;if n_elements(ind) eq 2 then begin
      ;  phaseshift[i,0,ind,0]1=1
      ;endelse
       
      for k=0,1 do begin
        wavel[i,k]=(total(phaseshift[i,0,*,k]*phaseshift[i,1,*,k])-4*mean(phaseshift[i,0,*,k])*mean(phaseshift[i,1,*,k]))/$
                   (total((phaseshift[i,0,*,k])^2)-4*mean(phaseshift[i,0,*,k])^2)
      endfor
      detpos=getcal_kstar_spat(shot2)
      R=mean(detpos[*,vchannel-1,0])*1e-3
      polmodenum[i,*]=2*(R-1.8)*!pi/wavel[i,*]
    endfor
    phaseshift=phaseshift+1
    device, decomposed=0

    xrange=[-1,n]
    yrange=[-0.2,0.2]
    color=100
    pos1=[0.05,0.50,0.95,0.95]
    pos2=[0.05,0.05,0.95,0.50]
    xc=0.01
    cs=1.5
       
    if keyword_set(ps) then begin
      hardon, /color
      thick=3
      charsize=1.5
    endif
        loadct, 5
    plot, findgen(n), wavel[*,0], color=color, ycharsize=0.1, yrange=yrange, position=pos1,$
          thick=thick, xrange=xrange, xstyle=1
    axis, yaxis=1, ycharsize=1, yrange=yrange, color=color, ytitle='Wavelength [m]'
    loadct, 1
    plot, findgen(n), phaseshift[*,0,0,0], yrange=[-1,1], psym=4, /noerase, ytitle='Phase [2*pi*rad]',$
          position=pos1, thick=thick, xrange=xrange, xtitle='ELM event index', xstyle=1
    for j=0,3 do oplot, findgen(n), phaseshift[*,0,j,0], psym=4, color=j*50, thick=thick 
    loadct, 5
    plot, findgen(n), wavel[*,1], color=color, ycharsize=0.1, yrange=yrange, position=pos2,$
          /noerase, thick=thick, xrange=xrange, xstyle=1
    axis, yaxis=1, ycharsize=1, yrange=yrange, color=color, ytitle='Wavelength [m]'
    loadct, 1
    plot, findgen(n), phaseshift[*,0,0,1], yrange=[-1,1], psym=4, /noerase, ytitle='Phase [2*pi*rad]',$
          position=pos2, thick=thick, xrange=xrange, xtitle='ELM event index', xstyle=1
    for j=0,3 do oplot, findgen(n), phaseshift[*,0,j,1], psym=4, color=j*50, thick=thick
    
    if not keyword_set(ps) then cursor, x, y, /down
    
    plot, polmodenum[*,0], ytitle='Modenumber', position=pos1, xstyle=1
    plot, polmodenum[*,1], ytitle='Modenumber', position=pos2, /noerase, xstyle=1
    
    if keyword_set(ps) then hardfile, filename+'_'+strtrim(fwin,2)+'.ps'
      
  endelse
  stop
endif



if def eq 6 then begin
  default, twin1, [0.001,-0.0005]
  default, channel, 'BES-4-8'
  if keyword_set(ps) then begin
    hardon, /color
    set_plot_style, 'foile_kg'
  endif
  for i=0, n-1 do begin
    shot2=database[ind[i]].shot
    time_range=[database[ind[i]].time-twin1[0], database[ind[i]].time+twin1[1]]
    show_rawsignal, shot2, channel, timerange=time_range, thick=3, charsize=2, $
                    position=[0,0,1,0.3], /noerase, ystyle=1
    
    erase 
  endfor
  if keyword_set(ps) then hardfile, filename+'.ps'
endif
if (def eq 7) then begin
  hardon, /color
  set_plot_style,'foile_eps_kg'
  twin1=0.002
  twin2=0.0005
  for i=0,n-1 do begin
    shot=database[ind[i]].shot
    case shot of
      6122: begin
              trange_bg=[0.90476182,0.97278902]
              bgsub=1
            end
      6123: begin
              trange_bg=[0.94557814,0.98639446]
              bgsub=1
            end
      6124: begin
              trange_bg=[0.89795909,0.95918358]
              bgsub=1
            end
      else: begin
              bgsub=0
              trange_bg=[0,0]
            end
    endcase
    trange=[database[ind[i]].time-twin1,database[ind[i]].time+twin1]
    plot_2d_radial_dist,shot,line,timerange=trange, trange_bg=trange_bg, int=5
    erase
  endfor
  hardfile, filename+'_line'+strtrim(line,2)+'.ps'
endif

end