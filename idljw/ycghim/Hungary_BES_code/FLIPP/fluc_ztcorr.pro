pro fluc_ztcorr,shot,timefile,refchan=refchan_in,taures=tres,norm=norm,inttime=inttime,$
  delay=delay,zrange=zrange,taurange=trange,comment=user_comment,$
  fres=fres,frange=frange,ftype=ftype,$
  noplot=noplot,outtime=outtime,levels=levels,$
  fill=fill,nocalc=nocalc,nlev=nlev,lowcut=lowcut,fitorder=fitorder,baseline_function=baseline_function,$
  cut_length=cut_length,extrapol_length=extrapol_length,$
  extrapol_order=extrapol_order,show=show,printer=printer,$
  interval_n=interval_n,density=dens,$
  fft=fft,nofft=nofft,channels=channels,chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
  errormess=errormess,silent=silent,$
  data_source=data_source,afs=afs,$
  checkstop=checkstop,messageproc=message_proc,$
  outz=outz,outcorr=outcorr2,outscat=outscat2,$
  outfscale=outfscale,outpower=outpower2,outpwscat=outpwscat2,outphase=outphase2,$
  proct1=proct1,proct2=proct2,procn=procn,calfac=calfac,nocalibrate=nocalibrate,$
  dens_tvec=dens_tvec,dens_sampletime=dens_sampletime,$
  experiment=experiment,subchannel=subchannel,timerange=timerange,$
  colorscheme=colorscheme,plotrange=plotrange,pluslevels=pluslevels,noscale=noscale,$
  ytitle=ytitle,nolegend=nolegend,nopara=nopara,nowarning=nowarning,$
  datapath=datapath,filename=filename,$
  plot_correlation=plot_correlation, plot_power=plot_power, plot_phase=plot_phase,$
  z_vect=z_vect,ztitle=ztitle,charsize=charsize,linethick=linethick,axisthick=axisthick,$
  filter_low=filter_low,filter_high=filter_high,filter_order=filter_order


default,message_proc,'print_message'
refchan=refchan_in


; ********************* ztcorr.pro ************************** S. Zoletnik *********
; Calculates and plots the z-t correlation function of the reference channel
; with channels in the channels list

; timefile: a two-column list of time intervals
; experiment: name of experiment file (see load_experiment.pro). This argument overrides
;             shot and timefile
; refchan: the reference signal (channel number or signal name)
; channels: Use these channels (numbers, or channel names)
; chan_prefix: Prefix for constructing the channel names  (see get_rawsignal.pro)
; chan_postfix: Postfix for constructing a full channel name (see get_rawsignal.pro)
; z_vect: The spatial coordinate of the channels
; taures: tau resolution of crosscorrelation function (should be odd number)
; taurange: tau range for calculation
; /norm: normalise crosscorrelation (divide by signal power)
; lowcut: integration time of subtracted integrated signal (low-cut filter)
; inttime: integration time in microsec (high-cut filter)
; filter_low: The low frequency limit of the digital filter [Hz]  (def:0)
; filter_high: The high frequency limit of the digital filter [Hz]  (def: fsample/2)
; filter_order: filter_order  (def: 5)
; fitorder: order of fitted polynomial for background subtraction
; baseline_function: name of baseline correction function. Default is 'baseline_poly'
; delay: shift plotchan signal in test by some time steps
; cut_length: microsecond delay range (-cut_length,+cut_length) in which
;             the autocorrelation functions are cut and extrapolated from
;             the edges of the interval (0 ==> no cut)
; extrapol_length: the length of the delay time interval from which the
;                  extrapolation around zero delay of the autocorrelation
;                  function is done
; extrapol_order: order of polynomial for extrapolation
; channels: a list of channels which are to be calculated
;           default: list returned by defchannels()
; data_source: see get_rawsignal.pro
; /afs: get data from afs
;  calfac: calibration factors (optional), returned on exit
; /dens: use simulated density signals (only for W7-AS Li-beam)
; dens_tvec: time vector for simulated density signals (optional)
;  filename: Name of the datafile (only for 6 and 13 and for MAST test shots)
;  datapath: Path for the datafile
; /hanning: Use Hanning windowing for FFT  | If none of these is set no windowing function will be used
; /hamming: Use Hamming windowing for FFT  |
; /silent: Do not print processing messages
;
; PLOT CONTROL:
; plotrange: The z (color) plot range
; /noplot: do not make plot
; /plot_correlation: plot correlation vs z-t
; /plot_power:   plot power vs z-f
; /plot_phase:   plot phase vs z-f
; /nocalc: do not calcultate only plot using out... variables
; /show: plot crosscorrelation functions during calculation
; nlev: number of contour levels
; levels: array of levels
; user_comment: Write this text on the parameter list of the plot.
; ztitle: The title of the z axis
;
; OUTPUT:
; outcorr: Correlation array
; outtime: Time lag array for correlation
; outscat: Scatter of correlation
; outpower: Crosspower spectrum
; outfscale: output frequency scale for power and phase [Hz]
; outphase: Crossphase spectrum
; outspectrum: Complex crosspower spectrum
; outpwscat: Scatter of power spectrum
; outz: Spatial scale
; ********************************************************************************

default,message_proc,'print_message'
default,refchan_in,1
refchan=refchan_in
; Getting string channel name
if (not keyword_set(dens) and not keyword_set(experiment)) then begin
  if (defined(data_source)) then ds = data_source
  get_rawsignal,shot,refchan,data_source=ds,errormess=errormess,/nodata,chan_prefix=chan_prefix,chan_postfix=chan_postfix
  if (errormess ne '') then return
endif

if (not keyword_set(plot_correlation) and not keyword_set(plot_spectra) and not keyword_set(plot_power) and not keyword_set(plot_phase)) then begin
  plot_correlation = 1
endif

default,comment,' '
if (keyword_set(inttime)) then begin
  comment='!Cinttime='+string(inttime,format='(I3)')+' '+comment
endif
if (keyword_set(lowcut)) then begin
  comment='!Clowcut='+string(lowcut,format='(I3)')+' '+comment
endif
if (keyword_set(plot_correlation)) then begin
  if (keyword_set(tres)) then begin
    comment='!Ctaures='+string(tres,format='(F4.1)')+' '+comment
  endif
endif
if (keyword_set(plot_power)) then begin
  if (keyword_set(fres)) then begin
    comment='!Cfres='+string(fres,format='(E10.1)')+' '+comment
  endif
endif
if (keyword_set(fitorder)) then begin
  comment='!Cfitord='+string(fitorder,format='(I1)')+' '+comment
endif
if (keyword_set(norm)) then begin
  comment='!C/norm '+comment
endif
if (keyword_set(cut_length)) then begin
  comment='!Ccut_length='+i2str(cut_length)+' ' + comment
endif
if (keyword_set(extrapol_length)) then begin
  comment='!Cext_length='+i2str(extrapol_length)+' '+ comment
endif
if (keyword_set(extrapol_order)) then begin
  comment='!cextrapol_order='+i2str(extrapol_order)+' '+ comment
endif


default,data_source,fix(local_default('data_source',/silent))
if (not defined(refchan)) then begin
  errormess = 'Reference channel should be set.'
  outcorr2 = 0
  return
endif

taurange_start_str = local_default('taurange_start',/silent)
if (taurange_start_str ne '') then taurange_start = float(taurange_start_str)
taurange_end_str = local_default('taurange_end',/silent)
if (taurange_end_str ne '') then taurange_end = float(taurange_end_str)
if (defined(taurange_start) and defined(taurange_end)) then begin
  default,trange,[taurange_start,taurange_end]
endif else begin
  default,trange,[-100,100]
endelse
default,norm,0
default,inttime,0
default,lowcut,float(local_default('lowcut',/silent))
default,fitorder,2
b = local_default('baseline_function',/silent)
if (b eq '') then begin
  default,baseline_function,'baseline_poly'
endif else begin
  baseline_function = b
endelse

chname=refchan
if (keyword_set(dens)) then begin
  simparafile='data/'+i2str(shot,digits=5)+'.simpara'
  openr,unit,simparafile,error=error,/get_lun
  if (error ne 0) then begin
    print,'Cannot find simulation parameter file '+simparafile
    outcorr2=0
    return
  endif
  close,unit
  free_lun,unit
  trange_sav=trange
  inttime_sav=inttime
  if (keyword_set(channels)) then channels_save=channels
  shot_sim=0 & mode=0 & matrix=0 & z_vect=0 & p0r=0 & n0=0 & channels=0 & max_photon=0 & inttime=0 & trange=0
  sampletime=0 & multi=0 & decay=0 & ampmax=0 & period=0 & width=0 & output_sampletime=0
  flucprof=0 & dens_avr=0 & dens_flucprof=0 & nophoton=0 & background=0 & background_time=0 & startz=0
  endz=0
	restore,simparafile
  if (keyword_set(channels_save)) then channels=channels_save else channels=findgen(n_elements(z_vect))+1
  trange=trange_sav
  inttime=inttime_sav
endif else begin
	if (not defined(channels)) then channels=defchannels(shot,data_source=data_source)
endelse
chn=n_elements(channels)

if (not keyword_set(nocalc)) then begin
  for chi=0,chn-1  do begin
    if (keyword_set(checkstop)) then begin
      if (call_function(checkstop) ne 0) then begin
        outcorr2=0
        return
      endif
    endif
    ch=channels(chi)
    ; Create string channel name
    if is_string(ch) then begin
      ch_str = ch
    endif else begin
      ch_str = i2str(ch)
    endelse
    if (not keyword_set(silent)) then begin
      if (message_proc eq 'print_message') then begin
        print,' '+ch_str,format='($,A)'
      endif else begin
        call_procedure,message_proc,' '+ch_str,/no_newline
      endelse
    endif
    if (defined(data_source)) then ds = data_source
    ref = refchan

    fluc_correlation,shot,timefile,interval_n=interval_n,$
      plotchan=ch,refchan=ref,taures=tres,taurange=trange,norm=norm,inttime=inttime,$
      lowcut=lowcut,delay=delay,/noverbose,$
      outtime=outtime,outcorr=outcorr,outscat=outscat,/noplot,$
      outfscale=outfscale,outpower=outpow,outpwscat=outpwscat,outphase=outphase,$
      fitorder=fitorder,baseline_function=baseline_function,$
      cut_length=cut_length,extrapol_length=extrapol_length,$
      extrapol_order=extrapol_order,density=dens,fft=fft,nofft=nofft,$
      errormess=errormess,silent=silent,$
      fres=fres,frange=frange,ftype=ftype,hanning=hanning,hamming=hamming,$
      proct1=proct1,proct2=proct2,procn=procn,$
      data_source=ds,afs=afs,calfac=calfac,nocalibrate=nocalibrate,$
      dens_tvec=dens_tvec,dens_sampletime,experiment=experiment,$
      subchannel_ref=subchannel,subchannel_plot=subchannel,timerange=timerange,/no_errorcatch,$
      nowarning=nowarning,datapath=datapath,filename=filename,$
      chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
      filter_low=filter_low,filter_high=filter_high,filter_order=filter_order
    if (errormess ne '') then begin
      outcorr2=0
      return
    endif
    if (keyword_set(show)) then begin
      if (keyword_set(dens)) then chname='Dens-'+i2str(refchan) else chname=refchan
        plot,outtime,outcorr,psym=3,xrange=trange,xstyle=1,$
          xtitle='Time delay [microsec]',$
	      tit=i2str(shot)+'  ref:'+chname+' ch:'+i2str(ch),$
          yrange=[min(outcorr-outscat),max(outcorr+outscat)]
	    errplot,outtime,outcorr-outscat,outcorr+outscat
        save_time=outtime
	    save_corr=outcorr
        save_scat=outscat
      endif
      if (keyword_set(show)) then begin
        plotsymbol,0
	    oplot,outtime,outcorr,psym=8,symsize=1.5
	    thk=!p.thick
	!p.thick=3
	errplot,outtime,outcorr-outscat,outcorr+outscat
	!p.thick=thk
	if (ask('Hardcopy?')) then begin
	  hardon
	  erase
	  time_legend,'ztcorr.pro'
          if (keyword_set(dens)) then chname='Dens-'+i2str(refchan) else chname=refchan
          plot,save_time,save_corr,psym=3,xrange=trange,xstyle=1,$
              xtitle='Time delay [microsec]',tit=i2str(shot)+'  ref:'+chname+$
              ' ch:'+i2str(ch),/noerase,$
               yrange=[min(save_corr-save_scat),max(save_corr+save_scat)]
	  errplot,save_time,save_corr-save_scat,save_corr+save_scat
          plotsymbol,0
          oplot,outtime,outcorr,psym=8,symsize=1.5
          thk=!p.thick
          !p.thick=3
        errplot,outtime,outcorr-outscat,outcorr+outscat
          !p.thick=thk
          hardoff,printer
        endif
      endif
		if (chi eq 0) then begin
		  nt = n_elements(outtime)
		  nf = n_elements(outfscale)
		  outcorr2 = fltarr(nt,chn)
		  outscat2 = fltarr(nt,chn)
		  outpower2 = fltarr(nf,chn)
		  outphase2 = fltarr(nf,chn)
		  outpwscat2 = fltarr(nf,chn)
		endif
		outcorr2[*,chi] = outcorr
		outscat2[*,chi] = outscat
		outpower2[*,chi] = outpow
		outphase2[*,chi] = outphase
		outpwscat2[*,chi] = outpwscat
	endfor  ; cycle for channels
	if (keyword_set(dens)) then begin
	  outz=z_vect
	endif else begin
	  if (not defined(z_vect)) then begin
        if (keyword_set(experiment)) then begin
		  exp=load_experiment(experiment,errormess=errormess,/silent)
			shot = exp[0].shot
		endif
        corr_zscale,shot,channels,data_source=data_source,chan_prefix=chan_prefix,chan_postfix=chan_postfix,zscale=xrr,ztitle=ztitle
        outz=xrr
      endif else begin
        outz = z_vect
        default,ztitle,'???'
      endelse
	endelse
  call_procedure,message_proc,' '
  save,shot,outcorr2,outz,outscat2,outpower2,outphase2,outfscale,data_source,chname,outtime,refchan,chan_prefix,chan_postfix,$
              trange,tres,fres,frange,timerange,timefile,file='tmp/ztcorr.sav'
endif else begin
  restore,'tmp/ztcorr.sav'
endelse

if (not keyword_set(noplot)) then begin
  default,trange,[min(outtime),max(outtime)]
  default,frange,[min(outfscale),max(outfscale)]
  default,zrange,[min(outz),max(outz)]
  default,nlev,10
  ;default,levels,findgen(nlev)/nlev*(max(outcorr2)-min(outcorr2))+min(outcorr2)
  default,fill,1
  default,pos,[0.07,0.15,0.7,0.7]
  default,colorscheme,'blue-white-red'
  default,linethick,1
  default,axisthick,1
  default,charsize,1


  if (keyword_set(experiment)) then begin
    title='exp:'+experiment
  endif else begin
    if (keyword_set(shot)) then begin
    title='#'+i2str(shot)
    endif else begin
      title = ''
    endelse
    if (defined(timefile)) then begin
      title=title+'!Ctimes:'+timefile
    endif else begin
      if (keyword_set(timerange)) then begin
        title=title+'!Ctimerange:!C ['+string(timerange[0],format='(F6.3)')+','+string(timerange[1],format='(F6.3)')+']'
      endif
    endelse
  endelse
  if (keyword_set(chan_prefix)) then begin
    title=title+'!Cchan_prefix:'+chan_prefix
  endif
  if (keyword_set(chan_postfix)) then begin
    title=title+'!Cchan_postfix:'+chan_postfix
  endif
  title = title+'!Cref. ch:!C '+string(chname)
  get_rawsignal,data_names=data_names,/nodata
  title = title+'!Cdata_source: '+data_names[data_source]
  title = title+'!C'+comment
  if (keyword_set(user_comment)) then title = title+'!C!C'+user_comment

  if (keyword_set(plot_correlation)) then begin
    default,plotrange,[min(outcorr2),max(outcorr2)]
    if (keyword_set(pluslevels)) then begin
      default,levels,(findgen(nlev))/(nlev)*abs(plotrange(1))
    endif else begin
      default,levels,(findgen(nlev))/(nlev)*(plotrange(1)-plotrange(0))+plotrange(0)
    endelse
    setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
    if (not keyword_set(noerase)) then erase
    if (not keyword_set(nolegend)) then time_legend,'ztcorr.pro'
    if (not keyword_set(nopara)) then begin
      plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
      xyouts,pos(2)+0.04,0.85,title,/normal
    endif
    if (keyword_set(fill) and not keyword_set(noscale)) then begin
       sc=fltarr(2,50)
       scale=findgen(50)/49*(max(outcorr2)-min(outcorr2))+min(outcorr2)
       sc(0,*)=scale
       sc(1,*)=scale
       contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
       position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
       xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
       xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
       ythick=axisthick,thick=linethick,charthick=axisthick
    endif
    contour,outcorr2,outtime,outz,xrange=trange,xstyle=1,xtitle='Time delay [!4l!Xs]',$
	  yrange=zrange,ystyle=1,ytitle=ztitle,charsize=charsize,xthick=axisthick,ythick=axisthick,$
      nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
	  position=pos-[0,0,0.1,0],c_colors=c_colors,$
      fill=fill,/noerase,title='Correlation'
  endif
  if (keyword_set(plot_power)) then begin
    default,plotrange,[min(outpower2),max(outpower2)]
    if (keyword_set(pluslevels)) then begin
      default,levels,(findgen(nlev))/(nlev)*abs(plotrange(1))
    endif else begin
      default,levels,(findgen(nlev))/(nlev)*(plotrange(1)-plotrange(0))+plotrange(0)
    endelse
    setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
    if (not keyword_set(noerase)) then erase
    if (not keyword_set(nolegend)) then time_legend,'fluc_ztcorr.pro'
    if (not keyword_set(nopara)) then begin
      plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
      xyouts,pos(2)+0.04,0.85,title,/normal
    endif
    if (keyword_set(fill) and not keyword_set(noscale)) then begin
       sc=fltarr(2,50)
       scale=findgen(50)/49*(max(outpower2)-min(outpower2))+min(outpower2)
       sc(0,*)=scale
       sc(1,*)=scale
       contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
       position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
       xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
       xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
       ythick=axisthick,thick=linethick,charthick=axisthick
    endif
    contour,outpower2,outfscale,outz,xrange=frange,xstyle=1,xtitle='Frequency [hz]',$
	  yrange=zrange,ystyle=1,ytitle=ztitle,$
      nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
	  position=pos-[0,0,0.1,0],c_colors=c_colors,xthick=axisthick,ythick=axisthick,$
      fill=fill,/noerase,title='Crosspower'

  endif
  if (keyword_set(plot_phase)) then begin
    default,plotrange,[min(outphase2),max(outphase2)]
    if (keyword_set(pluslevels)) then begin
      default,levels,(findgen(nlev))/(nlev)*abs(plotrange(1))
    endif else begin
      default,levels,(findgen(nlev))/(nlev)*(plotrange(1)-plotrange(0))+plotrange(0)
    endelse
    setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
    if (not keyword_set(noerase)) then erase
    if (not keyword_set(nolegend)) then time_legend,'fluc_ztcorr.pro'
    if (not keyword_set(nopara)) then begin
      plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
      xyouts,pos(2)+0.04,0.85,title,/normal
    endif
    if (keyword_set(fill) and not keyword_set(noscale)) then begin
       sc=fltarr(2,50)
       scale=findgen(50)/49*(max(outphase2)-min(outphase2))+min(outphase2)
       sc(0,*)=scale
       sc(1,*)=scale
       contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
       position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
       xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
       xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
       ythick=axisthick,thick=linethick,charthick=axisthick
    endif
    contour,outphase2,outfscale,outz,xrange=frange,xstyle=1,xtitle='Frequency [hz]',$
	  yrange=zrange,ystyle=1,ytitle=ztitle,$
      nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
	  position=pos-[0,0,0.1,0],c_colors=c_colors,xthick=axisthick,ythick=axisthick,$
      fill=fill,/noerase,title='Crosspower'
  endif

  endif
  end


