pro fluc_correlation,shot,timefile,$
   timerange=timerange,data_source=data_source,$
   plotchannel=plotchan_in,subchannel_plot=subchannel_plot,$
   refchannel=refchan_in,subchannel_ref=subchannel_ref,auto = autocorr_flag,$
   taures=tres_orig,taurange=trange_in,yrange=yrange,fres=fres,ftype=ftype,frange=frange,$
   comment=comment,normalize=norm,inttime=inttime_in,baseline_function=baseline_function,$
   test=test,delay=delay,outtime=outtime,outcorr=outcorr,outscat=outscat,$
   noplot=noplot,plot_spectra=plot_spectra,plot_correlation=plot_correlation,$
   plot_power=plot_power,plot_phase=plot_phase,plot_noiselevel=plot_noiselevel,$
   noverbose=noverbose,lowcut=lowcut,fitorder=fitorder,$
   interval_n=interval_n,verbose=verbose,calfac=calfac,nocalibrate=nocalibrate,$
   cut_length=cut_length,extrapol_length=extrapol_length,$
   extrapol_order=extrapol_order,nocalc=nocalc,density=dens,$
   psym=psym,title=title,nolegend=nolegend,noerase=noerase,$
   fft=fft,nofft=nofft,errormess=errormess,silent=silent,$
   afs=afs,cdrom=cdrom,outfscale=outfreq,outpower=outpower,outpwscat=outpwscat,outphase=outphase,$
   outspectrum=outspectrum,$
   proct1=proct1,proct2=proct2,procn=int_n,no_errorcatch=noerrorcatch,noerror=noerror,$
   dens_tvec=dens_tvec,dens_sampletime,nopara=nopara,$
   no_shift_correct=no_shift_correct,$
   correction_method=correction_method,p2_points=p2_points,$  ; For CO_2 scattering
   datapath=datapath,filename=filename,$
   experiment=experiment,totalpoints=totalpoints,savefile=savefile,$
   percent=percent,testsignal=testsignal,background_level=background_level,$
   stop_on_error=stop_on_error,nowarning=nowarning,$
   chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
   thick=thick,charsize=charsize,color=color,xcharsize=xcharsize,ycharsize=ycharsize,$
   mean_ref=mean_ref,mean_plot=mean_plot,overplot=overplot,$
   xtype=xtype,ytype=ytype,$
   hanning=hanning_window,hamming=hamming_window,$
   filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,filter_symmetric=filter_symmetric,$
   coherency_noiselevel=crosspower_noiselevel,position=pos,kHz=khz, MHz=mhz, linestyle=linestyle,linethick=linethick,$
   offset_timerange=offset_timerange,offset_type=offset_type

; ****************************************************************************
; FLUC_CORRELATION.PRO
; Original version (crosscor_new.pro)                  S. Zoletnik 08.11.1996
; ****************************************************************************
; Calculates the crosscorrelation function and crosspower spectrum of two signals.
; Makes correct error estimates.
; If an error is encountered, errormess shows an error message.
; Errormess is set to '' if no error occured.
;
; INPUT:
; shot: shot number
; timefile: a two-column list of time intervals in seconds. For Aurora system
;           these times are relative to the Aurora system t0 time, for nicolet
;           theses are relative to the discharge t0. Time files should be in
;           subdir time/ .   Default is <shot>on.time
; timerange: a time range in the discharge, alternative to timefile
; experiment: name of experiment file (see load_experiment.pro). This argument overrides
;             shot and timefile
; data_source: see get_rawsignal.pro
; refchan: The reference channel(s). If an array of channel names is given all signals
;           will be added before calculating correlation
; subchannel_ref: The subchannel in the reference signal, if the measurement is a deflected
;                 Li-beam experiment. This is a scalar argument even if refchan is an array.
; plotchan: The channel(s) analised. If an array of channel names is given all signals
;           will be added before calculating correlation
; subchannel_plot: The subchannel in the plot signal, if the measurement is a deflected
;                 Li-beam experiment. This is a scalar argument even if plotchan is an array.
; /auto: take plot channel equal to refchannel. (plotchannel and subchannel_plot is neglected)
; chan_prefix: Prefix for constructing the channel names  (see get_rawsignal.pro)
; chan_postfix: Postfix for constructing a full channel name (see get_rawsignal.pro)
; taures: time resolution of crosscorrelation function
;        (microsec, will be set to odd multiplet of sampletime)
; taurange: Time lag range of correlation function
; fres: frequency resolution of power and phase spectra
; ftype: 0: normal frequency resolution with fres (default)
;        1: logarithmic frequency resolution. fres will be the resolution at
;           the begginning of frange and the resolution changes proportionally to the frequency.
;           As default xtype is set to 1 if ftype is is 1.
; frange: Frequency range of power and phase spectra
; /norm: normalise crosscorrelation (Normalises with photon corrected power.)
; inttime: integration time in microsec (apply high-cut filter for signal)
; lowcut: integration time of subtracted integrated signal (apply low-cut filter for signal) [in microsec], calculation: 1/(2*pi*f)
; filter_low: The low frequency limit of the digital filter [Hz]  (def:0)                    |
; filter_high: The high frequency limit of the digital filter [Hz]  (def: fsample/2)         | See
; filter_order: filter_order                                                                 | bandpass_filter_data.pro
; filter_symmetric: 1: Use symmetric time response filter, 0: use asymmetric (deterministic) |
; fitorder: order of fitted polynomial for background subtraction (this is again some kind
;           of high pass filter)
; baseline_function: name of baseline correction function. Default is 'baseline_poly'. '' means no baseline subtraction
; test: use random signals instead of measured ones
; delay: shift plotchan signal in test by some time steps
; /density: use density data from simulation (for W7-AS)
; interval_n: number of time sub-intervals in calculation. This is needed for the error estimates.
; cut_length: microsecond delay range (-cut_length,+cut_length) in which
;             the autocorrelation functions are cut and extrapolated from
;             the edges of the interval (0 ==> no cut)
; extrapol_length: the length of the delay time interval from which the
;                  extrapolation around zero delay of the autocorrelation
;                  function is done
; extrapol_order: order of polynomial for extrapolation
; /nocalc: do not calculate, plot only result using data in savefile (see /save)
; /fft: use FFT for calculation
; /nofft: use no FFT for calculation
; /hanning: Use Hanning windowing for FFT  | If none of these is set no windowing function will be used
; /hamming: Use Hamming windowing for FFT  |
; /silent: do not print error messages
; /no_errorcatch : stop on error
; dens_tvec: time vector for simulated density signals (optional)
; dens_sampletime: sampletime for simulated density signals
; /savefile: save data in tmp directory in this file (for use with /nocalc later)
;            /save or /savefile will store into fluc_correlation.sav
; /percent: Plot square root of autocorrelation function scaled to percentage of average signal
; background_level: Background level used in percent calculation (Default:0)
; testsignal: Add this signal to the real signal
; /stop_on_error: stop when error occurs
; /nowarning: Do not stop on warning errors
;
; *** PLOT arguments ***********
; /noplot: do not make plot
; /plot_correlation: Plot correlation function
; /plot_spectra: Plot spectra (power and phase)
; /plot_power: Plot power spectrum
; /plot_phase: Plot phase spectrum
; /plot_noiselevel: Plots coherency noiselevel on coherency plot. plot_coherencey=x plots x times the noiselevel
;                   (See coherency_noiselevel)
; yrange: vertical plot range
; /noerase: Do not erase screen
; /nolegend: Do not print name and time of plot.
; /nopara: Do not print parameters on plot
; thick: Line and character thickness (default:1)
; charsize: Character size (default:1)
; psym: plotsymbol code (like in plot)
; title: title to print on top
; /noerror: Do not plot error bars
; /overplot: Overplot existing figure (only for correlation plot)
; xtype,ytype: Same as for plot (xtype=1 --> log scale)
; /noverbose: do not print comments on screen
; position: same as position keyword in IDL, plot corners in normal coordinates
; /kHz: Plot frequency scale is kHz
; /MHz: Plot frequency scale in MHz
; offset_timerange: 
;
; OUTPUT:
; mean_ref and mean_plot: return the mean of the two signals
; outcorr: Correlation array
; outtime: Time lag array for correlation
; outscat: Scatter of correlation
; outpower: Crosspower (autopower) spectrum.
;           Scaling of power: The amplitude of the band integrated power can be calculated by
;           summing the power over the required frequency range, multiplying by the actual
;           frequency resolution (outfscale[1]-outfscale[0]) and teking square root.
;           Both negative and positive
;           frequencies must be integrated, this means that for autopower the sum should be
;           multipled by 2. To calculate the relative amplitude divide by mean_ref for autopower.
;           See TEST_POWERSCALE.PRO for example.
; outfscale: output frequency scale for power and phase [Hz]
; outphase: Crossphase spectrum in radians
; outspectrum: Complex crosspower spectrum
; outpwscat: Scatter of power spectrum
; proct1,proct2: start and stop times of the processed intervals
; errormess: return error message in this variable
; procn: number of processed intervals
; calfac: calibration factors (optional), returned on exit
; coherency_noiselvel: The effective reduction of the crosspower due to both frequency smoothing and number of intervals
;                       For coherency this is the expected noiselevel. For crosspower this should be multiplied by the
;                       square root is the product of the autopowers.
;                       For ftype=0 this is a scalar, for ftype=1 this is an array showing the coherency as a function of frequency
; **************************************************************************************************

errormess=''

if (defined(savefile)) then begin
  save = 1
  if (size(savefile,/type) ne 7) then begin
    savefile = 'fluc_correlation.sav'
  endif
endif

if (keyword_set(nocalc)) then default,savefile,'fluc_correlation.sav'

if (keyword_set(nocalc)) then begin
  restore,dir_f_name('tmp',savefile)
  goto,plot
endif

; ********************* check some input parameters **********************
if (keyword_set(timefile) and keyword_set(timerange)) then begin
    errormess='Set only one of <timefile> or <timerange> !'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
endif

if (not keyword_set(experiment) and not keyword_set(timefile) and not keyword_set(timerange)) then begin
    errormess='One of <timefile> or <timerange> must be set!'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
endif

if (not keyword_set(plot_correlation) and not keyword_set(plot_spectra) and not keyword_set(plot_power) and not keyword_set(plot_phase)) then begin
  plot_correlation = 1
endif

if ((keyword_set(plot_power) or keyword_set(plot_spectra) or keyword_set(plot_phase)) and keyword_set(nofft)) then begin
    errormess='Keyword /nofft cannot be used if spetrum is to be calculated.'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
endif

if (not defined(refchan_in)) then begin
    errormess='refchannel should be set. (FLUC_CORRELATION.PRO)'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
endif

; ***** Put here default values for input parameters *****************
if (not keyword_set(timerange) and defined(shot)) then begin
  default,timefile,i2str(shot)+'on.time'
endif
default,data_source,fix(local_default('data_source',/silent))
b = local_default('baseline_function',/silent)
if (b eq '') then begin
  default,baseline_function,'baseline_poly'
endif else begin
  baseline_function = b
endelse
default,lowcut,0
default,fitorder,2
default,comment,' '
if (not defined(plotchan_in)) then default,autocorr_flag,1
default,subchannel_ref,0
default,inttime_in,0
default,delay,0
default,interval_n,8
default,background_level,0
default,cut_length,0
default,psym,0
default,thick,1
default,charsize,1
default,ftype,0
default,xtype,ftype

if ((defined(xcharsize)) and (not defined(ycharsize))) then ycharsize=1
if ((defined(ycharsize)) and (not defined(xcharsize))) then xcharsize=1

if (keyword_set(norm) and keyword_set(plot_correlation)) then begin
  default,yrange,[-1.1,1.1]
endif

if (keyword_set(autocorr_flag)) then begin
  plotchan_in = refchan_in
  if (defined(subchannel_ref)) then subchannel_plot = subchannel_ref
endif

if (keyword_set(percent) and keyword_set(norm)) then begin
  errormess ='/PERCENT and /NORM are conflicting switches.'
  if (not keyword_set(silent)) then print,errormess
  outcorr=0
  return
endif


if (keyword_set(fft) and keyword_set(nofft)) then begin
  errormess = 'Only one of /FFT or /NOFFT should be set!'
  if (not keyword_set(silent)) then print,errormess
  outcorr=0
  return
endif

if (not keyword_set(fft) and not keyword_set(nofft)) then fft=1

; If experiment is set this same program will be called recursively
if (keyword_set(experiment)) then begin
  if (keyword_set(timerange)) then begin
    errormess = 'timerange cannot be used if experiment is set.'
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
  endif

  exp = load_experiment(experiment,/silent,errormess=errormess)
  if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
  endif

  nexp = n_elements(exp)
  for i=0,nexp-1 do begin

    if (not keyword_set(noverbose)) then begin
      print,'Processing shot '+i2str(exp[i].shot)+' timefile '+exp[i].timefile
    endif

    plot_in = plotchan_in
    ref_in = refchan_in
    if defined(offset_timerange) then offset_timerange_to_get_3=offset_timerange
    fluc_correlation,exp[i].shot,exp[i].timefile,$
      data_source=data_source,$
      plotchannel=plot_in,subchannel_plot=subchannel_plot,refchannel=ref_in,subchannel_ref=subchannel_ref,$
      tres=tres_orig,trange=trange_in,$
      normalize=norm,inttime=inttime_in,baseline_function=baseline_function,$
      filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,filter_symmetric=filter_symmetric,$
      delay=delay,outtime=outtime_1,outcorr=outcorr_1,outscat=outscat_1,$
      /noplot,noverbose=noverbose,lowcut=lowcut,fitorder=fitorder,$
      interval_n=interval_n,verbose=verbose,calfac=calfac,nocalibrate=nocalibrate,$
      cut_length=cut_length,extrapol_length=extrapol_length,$
      extrapol_order=extrapol_order,density=dens,$
      fft=fft,nofft=nofft,errormess=errormess,/silent,$
      afs=afs,cdrom=cdrom,no_errorcatch=noerrorcatch,$
      dens_tvec=dens_tvec,dens_sampletime,totalpoints=totalpoints,testsignal=testsignal,nowarning=nowarning,$
      chan_prefix =chan_prefix,chan_postfix=chan_postfix,offset_timerange=offset_timerange_to_get_3,offset_type=offset_type


    if (errormess(0) ne '') then begin
        if (not keyword_set(silent)) then print,errormess
        outcorr=0
        return
    endif

    if (i eq 0) then begin
      outcorr = outcorr_1*totalpoints
      outscat = outscat_1^2*totalpoints
      outtime = outtime_1
      sum_totalpoints = totalpoints
    endif else begin
      if (n_elements(outtime) ne n_elements(outtime_1)) then begin
        errormess = 'Different tau list in different shots.'
      endif else begin
        if ((where(outtime ne outtime_1))(0) ge 0) then begin
          errormess = 'Different tau list in different shots.'
        endif
      endelse
      if (errormess ne '') then begin
          if (not keyword_set(silent)) then print,errormess
          outcorr=0
          return
      endif

      outcorr = outcorr + outcorr_1*totalpoints
      outscat = outscat + outscat_1^2*totalpoints^2
      sum_totalpoints = sum_totalpoints+totalpoints
    endelse
  endfor

  ind = where(sum_totalpoints ne 0)
  outcorr(ind) = outcorr(ind)/sum_totalpoints(ind)
  outscat(ind) = sqrt(outscat(ind)/sum_totalpoints(ind)^2)
  totalpoints = sum_totalpoints

  tres = outtime(1)-outtime(0)
  trange = [min(outtime),max(outtime)]
  inttime = inttime_in
  if (keyword_set(noplot)) then return
  goto,plot
endif



if (not keyword_set(noerrorcatch)) then begin
  on_error,3
  catch,errstat
  if (errstat ne 0) then goto,err
endif

n_plotchan = n_elements(plotchan_in)
n_refchan = n_elements(refchan_in)
plotchan = strarr(n_plotchan)
refchan = strarr(n_refchan)

; *** Converting channel names to full names with get_rawsignal
if (not keyword_set(dens)) then begin
 for i=0, n_plotchan-1 do begin
   chname = plotchan_in(i)
   if (defined(data_source)) then ds_1 = data_source
     get_rawsignal,shot,chname,subchannel=subchannel_plot,data_source=ds_1,/nodata,errormess=errormess,$
                 chan_prefix=chan_prefix,chan_postfix=chan_postfix
     plotchan(i)=chname
    endfor
 for i=0, n_refchan-1 do begin
   chname = refchan_in(i)
   if (defined(data_source)) then ds_2 = data_source
   get_rawsignal,shot,chname,subchannel=subchannel_ref,data_source=ds_2,/nodata,errormess=errormess,$
                 chan_prefix=chan_prefix,chan_postfix=chan_postfix
       refchan(i)=chname
    endfor
endif else begin
  dens_plotchan=plotchan_in
  dens_refchan=refchan_in
  if ((size(plotchan_in))(1) ne 7) then plotchan='Dens-'+i2str(plotchan_in) else plotchan=plotchan_in
  if ((size(refchan_in))(1) ne 7) then refchan='Dens-'+i2str(refchan_in) else refchan=refchan_in
endelse

; ************** Loading the timefile **************
if (keyword_set(timefile)) then begin
 tfile=dir_f_name('time',timefile)
    times=loadncol(tfile,2,/silent,errormess=errormess)
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    ind=where((times(*,0) ne 0) or (times(*,1) ne 0))
    times=times(ind,*)
endif
if (keyword_set(timerange)) then begin
  times=fltarr(1,2)
    times(0,*)=timerange
endif
nt=(size(times))(1)

tstart=double(min(times))
tend=double(max(times))
; ****************** getting data for plot channel ***************
if (not keyword_set(dens)) then begin
  if (not keyword_set(test)) then begin
    for i=0,n_plotchan-1 do begin
      if (defined(data_source)) then ds_plot = data_source
      if defined(offset_timerange) then offset_timerange_to_get_1=offset_timerange
      get_rawsignal,shot,plotchan(i),t_w,d_w,data_source=ds_plot,afs=afs,cdrom=cdrom,/equidist,$
                    trange=[tstart,tend],calfac=calfac,nocalibrate=nocalibrate,sampletime=samp_w,$
                    subchannel=subchannel_plot,errormess=errormess,$
                    no_shift_correct=no_shift_correct,$                              ;
                    correction_method=correction_method,p2_points=p2_points,$ ; For CO_2 scattering
                    datapath=datapath,filename=filename,offset_timerange=offset_timerange_to_get_1,offset_type=offset_type
      if (not keyword_set(t_w) or (errormess ne '')) then begin
        if (errormess eq '') then begin
          default,errormess,'Could not read data of channel '+plotchan(i)+'. Time interval: '+$
                          string(tstart)+'-'+string(tend)
          if (not keyword_set(silent)) then print,errormess
        endif
        outcorr=0
        return
      endif
      default,samp_w,(t_w[n_elements(t_w)-1]-t_w[0])/(n_elements(t_w)-1)
      if (i eq 0) then begin
        time_plot=t_w
        data_plot=d_w
        tres_plot = samp_w
      endif else begin
        if ((time_plot(0) ne t_w(0)) or (tres_plot ne samp_w)) then begin
          errormess='Timebase of channels to be added is different:'+plotchan(0)+'-'+plotchan(i)
          if (not keyword_set(silent)) then print,errormess
          outcorr=0
          return
        endif
        data_plot=data_plot+d_w
      endelse
    endfor
  endif else begin
    if (not keyword_set(sampletime)) then begin
      errormess='Sampletime should be set if simulated data are desired!.'
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    pointn=long((tend-tstart)/sampletime)+1
    data_plot=abs(randomn(seed,pointn))
    datas=data_plot
    tres_plot=sampletime
  endelse
endif else begin
  fn='data/'+i2str(shot,digits=5)+i2str(dens_plotchan,digits=3)+'_dens.dat'
  z_vect=0
  dd=0
  restore,fn
  ind=where((dens_tvec ge tstart) and (dens_tvec le tend))
  if (n_elements(ind) lt 0) then begin
    errormess='Could not read data of simulated density signal '+dens_plotchan+'. Time interval: '+$
        string(tstart)+'-'+string(tend)
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
  endif
  data_plot=dd(ind)
  time_plot=dens_tvec(ind)
  sampletime=round((time_plot(1)-time_plot(0))/1e-6)*1e-6
end

if ((size(data_plot,/type) eq 6) or (size(data_plot,/type) eq 9)) then begin
  complex_data = 1
endif

if (delay ne 0) then begin
  ind=findgen(n_elements(data_plot))-delay
  data_plot=data_plot(ind)
endif

if (keyword_set(testsignal)) then begin
  ntest = min([n_elements(testsignal),n_elements(data_plot)])
  data_plot[0:ntest-1] = data_plot[0:ntest-1]+testsignal[0:ntest-1]
endif


; ****************** getting data for reference channel ***************
; *** If refchannel is the same as plotchannel (autocorrelation) then not reading
;     again
if ((n_plotchan eq n_refchan) and (total(strlowcase(plotchan) ne strlowcase(refchan)) eq 0) $
    and (subchannel_plot eq subchannel_ref)) then begin
  data_ref=data_plot
  time_ref=time_plot
  tres_ref=tres_plot
  autocorr_flag=1
endif else begin
  if (not keyword_set(dens)) then begin
    if (not keyword_set(test)) then begin
      for i=0,n_refchan-1 do begin
        if (defined(data_source)) then ds_ref = data_source
      if defined(offset_timerange) then offset_timerange_to_get_2=offset_timerange

        get_rawsignal,shot,refchan(i),t_w,d_w,data_source=ds_ref,afs=afs,cdrom=cdrom,/equidist,$
                trange=[tstart,tend],nocalibrate=nocalibrate,sampletime=samp_w,$
                subchannel=subchannel_ref,errormess=errormess,$
                no_shift_correct=no_shift_correct,$                              ;
                correction_method=correction_method,p2_points=p2_points,$ ; For CO_2 scattering
                datapath=datapath,filename=filename,offset_timerange=offset_timerange_to_get_2,offset_type=offset_type                           ;
        if (not keyword_set(t_w) or (errormess ne '')) then begin
          if (errormess eq '') then begin
            default,errormess,'Could not read data of channel '+refchan(i)+'. Time interval: '+$
               string(tstart)+'-'+string(tend)
            if (not keyword_set(silent)) then print,errormess
          endif
          outcorr=0
          return
        endif
          default,samp_w,(t_w[n_elements(t_w)-1]-t_w[0])/(n_elements(t_w)-1)
          if (i eq 0) then begin
            time_ref=t_w
              data_ref=d_w
              tres_ref=samp_w
          endif else begin
            if ((time_ref(0) ne t_w(0)) or (tres_ref ne samp_w)) then begin
               errormess='Timebase of channels to be added is different: '+refchan(0)+'-'+refchan(i)
               if (not keyword_set(silent)) then print,errormess
               outcorr=0
               return
              endif
              data_ref=data_ref+d_w
           endelse
         endfor
    endif else begin
      data_ref=abs(randomn(seed,pointn))
      tres_ref=sampletime
    endelse
  endif else begin
    fn='data/'+i2str(shot,digits=5)+i2str(dens_refchan,digits=3)+'_dens.dat'
    z_vect=0
    dd=0
    restore,fn
    ind=where((dens_tvec ge tstart) and (dens_tvec le tend))
    if (n_elements(ind) lt 0) then begin
      errormess='Could not read data of simulated density signal '+dens_refchan+'. Time interval: '+$
          string(tstart)+'-'+string(tend)
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    data_ref=dd(ind)
    time_ref=dens_tvec(ind)
    sampletime=round((time_ref(1)-time_ref(0))/1e-6)*1e-6
  end
endelse

if (keyword_set(testsignal)) then begin
  ntest = min([n_elements(testsignal),n_elements(data_ref)])
  data_ref[0:ntest-1] = data_ref[0:ntest-1]+testsignal[0:ntest-1]
endif

if ((size(data_ref,/type) eq 6) or (size(data_ref,/type) eq 9)) then begin
  complex_data = 1
endif

; *** If time resolution of the two signals is different, then interpolating the slower sampletime signal
; *** to the better resolution one's timescale
tres_plot=tres_plot/1e-6
tres_ref=tres_ref/1e-6
if (tres_plot ne tres_ref) then begin
  if ((subchannel_ref ne 0) or (subchannel_plot ne 0)) then begin
    errormess = 'Cannot use subchannels with different time resolution.'
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
  endif

  tres_com=min([tres_plot,tres_ref])

  if (tres_com eq tres_plot) then begin
    time=time_plot
  endif else begin
       time = time_ref
    endelse

    if (tres_com eq tres_plot) then begin
    data_ref=interpol(data_ref,time_ref,time)
       time_ref = time
  endif else begin
    data_plot=interpol(data_plot,time_plot,time_ref)
       time_plot = time
  endelse

endif else begin
  time=time_plot
  tres_com=tres_ref
endelse

if (keyword_set(percent) and not keyword_set(autocorr_flag)) then begin
  errormess = '/percent can be used only for autocorrelation.'
  if (not keyword_set(silent)) then print,errormess
  outcorr=0
  return
endif



; *** Finding tau resolution
sampletime=tres_com*1e-6
default,tres_orig,sampletime/1e-6

; *** Determining tau range
if (tres_orig lt 100) then begin
  default,trange_in,[-300,300]
endif else begin
  default,trange_in,[-3*tres_orig,3*tres_orig]
endelse
trange=trange_in
inttime=inttime_in

if (trange(0) gt 0) then trange(0)=0
if (trange(1) lt 0) then trange(1)=0

st=sampletime/1e-6


; *** Setting tau resolution to odd number of sampletime if at least one of the
;     signals is not from deflected Li-beam measurement.
;     If both are from deflected Li-beam measurement tres will be kept
;     unchanged and checked later.
tres=(fix((tres_orig/st-0.6)/2)*2+1)*st
if ((abs(tres_orig - tres)/st gt 0.5) and not keyword_set(noverbose)) then begin
     if (not keyword_set(silent)) then print,'Setting taures to '+string(tres,format='(F5.2)')+' from '+string(tres_orig,format='(F5.2)')
     ;stop
endif
trange=long(trange/tres)*tres


; *** shift_list is a list of shifts for correlation calculation without FFT
; shift_n is thge number of sampletime shifts
shift_n=round((trange(1)-trange(0))/st+1+long(tres/st/2)*2)
; shift_list is a list of shifts
shift_list=lindgen(shift_n)+round(trange(0)/st)-long(tres/st/2)

; shift_res_n is the number of elements in the final correlation function
shift_res_n=(trange(1)-trange(0))/tres+1



; ********* Finding sub-timeintervals for error determination **************
ttot=0
for it=0,nt-1 do ttot=ttot+(times(it,1)-times(it,0))
if (keyword_set(verbose)) then begin
  print,'Total measurement time available is '+string(ttot,format='(F5.3)')+'s.'
endif
if (not keyword_set(proct1) or not keyword_set(proct2) or not keyword_set(int_n)) then begin
  if (keyword_set(verbose)) then print,'Finding time intervals...'
  shtime1=-(min(shift_list)*sampletime < 0)
  shtime2=max(shift_list)*sampletime > 0
  if (nt lt interval_n) then begin
    int_len=ttot/interval_n
  endif else begin
    int_len=ttot/nt*.99
  endelse
  int_n=0
  repeat begin
  int_n=0
    for it=0,nt-1 do begin
      act_time=double(times(it,0))
     repeat begin
         t1=act_time
         if (double(t1) lt times(it,0)) then t1=double(times(it,0))
         t2=t1+int_len

       if (t2 ge times(it,1)) then t2=t1
         if (t2-t1 ge 1e-5) then begin
            if (int_n eq 0) then begin
              proct1=dblarr(1)+t1
              proct2=dblarr(1)+t2
            endif else begin
              proct1=[proct1,t1]
              proct2=[proct2,t2]
            endelse
           act_time=t2+sampletime
            int_n=int_n+1
         endif else begin
           act_time=times(it,1)
         endelse
      endrep until (act_time ge times(it,1))
    endfor
    int_len=int_len*0.8
    if (int_len lt 10e-6) then begin
      errormess='Cannot find intervals.'
          if (not keyword_set(silent)) then print,errormess
          if (keyword_set(stop_on_error)) then stop
          return
    endif
  endrep until (int_n ge interval_n)
endif

if (not keyword_set(noverbose) and not keyword_set(silent)) then begin
  print,'Intervals ('+i2str(int_n)+'):'
    for i=0,int_n-1 do begin
      print,i2str(i+1)+'  '+string(proct1(i),format='(F9.6)')+$
      ' '+string(proct2(i),format='(F9.6)')
  endfor
endif

avr_ref = double(0)
nsample_ref= double(0)
avr_plot = double(0)
nsample_plot= double(0)

; *** Looping through the subintervals
for int_i=0,int_n-1 do begin

; *** Finding the samples of the reference signal in the processing time period
  ind = where( (time_ref ge proct1(int_i)) and (time_ref le proct2(int_i)) )
  if (n_elements(ind) lt 2) then begin
    errormess='Not enough data in processing time interval ['+string(proct1(int_i),format='(F7.5)')+$
               ','+string(proct2(int_i),format='(F7.5)')+']'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
  endif
  i1c = ind(0)
  i2c = ind(n_elements(ind)-1)

  sigref1=data_ref(i1c:i2c)
  time_ref1 = time_ref(i1c:i2c)

  ; Calculating average signal
  avr_ref = avr_ref + total(sigref1)
  nsample_ref = nsample_ref + n_elements(sigref1)

  ; *** Subtracting baseline from reference signal
  if ((baseline_function ne '') and (baseline_function ne 'none')) then begin
    b=call_function(baseline_function,time_ref1,sigref1,fitorder,data_source=data_source)
    sigref1 = sigref1-b
  endif

  ; *** Low- or high-cut filtering for reference signal
;  if ((subchannel_ref ne 0) and ((inttime ne 0) or (lowcut ne 0) or defined(filter_low) or defined(filter_high))) then begin
;    errormess='Filtering canot be used for subchannels.'
;    if (not keyword_set(silent)) then print,errormess
;    outcorr=0
;    return
;  endif
  if (inttime ne 0) then sigref1=integ(sigref1,inttime*1e-6/sampletime)
  if (lowcut ne 0) then sigref1=sigref1-integ(sigref1,lowcut*1e-6/sampletime)
  if defined(filter_order) or defined(filter_high) or defined(filter_low) then begin
    ; This will do the actual filtering only the parameters are set
    sigref1 = bandpass_filter_data(sigref1,sampletime=sampletime,$
             filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
             filter_symmetric=filter_symmetric,errormess=errormess)
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
  endif


 ; *** Making ref signal equidistantly sampled if it is a subchannel
  if (subchannel_plot ne 0) then begin
    t = time_ref1
    s= sigref1
    ns = n_elements(t)
    ; finding elements where there is a jump in timescale
    ind = where((t(1:ns-1)-t(0:ns-1)) gt sampletime*1.5)
    if (ind(0) ge 0) then begin ; if there are jumps in the time vector
      ; number of samples which will be inserted into one jump
      n_insert = round((t(ind(0)+1)-t(ind(0)))/sampletime)-1
      ; number of subchannel samples in one period
      n_period_subch = ind(1)-ind(0)
      ; Period of the deflection
      deflection_period_ref = n_period_subch+n_insert
      ; A mask for one period: 1 where we have sample
         ; This array is one period long
      subch_mask_ref = intarr(deflection_period_ref)+1
      subch_mask_ref(ind(0)+1:ind(0)+n_insert) = 0
      ; size of the new arrays
      n_newarray = n_elements(t)+n_insert*n_elements(ind)
      ; the output arrays
      tw = dblarr(n_newarray) ; new time vector
      sw = fltarr(n_newarray) ; new data vector
      ; time vector for the insertion
      t_insert = (dindgen(n_insert)+1)*double(sampletime)
      actpos = ind(0) ; this is the index where the last element before a jump will be written
      ; looping through the insertions
      for i_insert=0l,n_elements(ind)-1 do begin
        ; copying the subchannel samples
        tw((actpos-n_period_subch+1) > 0 : actpos) = t((ind(i_insert)-n_period_subch+1) > 0 : ind(i_insert))
        sw((actpos-n_period_subch+1) > 0 : actpos) = s((ind(i_insert)-n_period_subch+1) > 0 : ind(i_insert))
        ; adding the samples in the jump
        if (actpos lt n_newarray-1) then begin
          tw(actpos+1 : actpos+1+n_insert-1) = t_insert+t(ind(i_insert))
          actpos = actpos+n_insert+n_period_subch
        endif
      endfor
      ; inserting the samples which are after the last jump
      tw(actpos-n_period_subch+1 : n_elements(tw)-1) = t(ind(n_elements(ind)-1)+1:n_elements(t)-1)
      sw(actpos-n_period_subch+1 : n_elements(tw)-1) = s(ind(n_elements(ind)-1)+1:n_elements(t)-1)
    endif
    sigref1 = sw
    time_ref1 = tw
  endif

  ; Checking if sampling is equidistant with sampletime in processing time interval
  ind = where(abs(time_ref1(1:n_elements(time_ref1)-1) - time_ref1(0:n_elements(time_ref1)-2) - sampletime)/sampletime ge 0.4)
  if (ind(0) ge 0) then begin
    errormess='Sampling is not equidistant for reference signal in time interval ['+string(proct1,format='(F8.5)')+$
               ','+string(proct2,format='(F8.5)')+']'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    if (keyword_set(stop_on_error)) then stop
    return
  endif

; *** Finding the samples of the plot signal in the processing time period
  ind = where((time_plot ge proct1(int_i)) and (time_plot le proct2(int_i)) )
  if (n_elements(ind) lt 2) then begin
    errormess='Not enough data in processing time interval ['+string(proct1(int_i),format='(F7.5)')+$
               ','+string(proct2(int_i),format='(F7.5)')+']'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
  endif
  i1c = ind(0)
  i2c = ind(n_elements(ind)-1)

  sigplot1=data_plot(i1c:i2c)
  time_plot1 = time_plot(i1c:i2c)

  ; Calculating average signal
  avr_plot = avr_plot + total(sigplot1)
  nsample_plot = nsample_plot + n_elements(sigplot1)


  ; *** Subtracting baseline for plot signal
  if ((baseline_function ne '') and (baseline_function ne 'none')) then begin
    b=call_function(baseline_function,time_plot1,sigplot1,fitorder,data_source=data_source)
    sigplot1=sigplot1-b
  endif

;  if ((subchannel_plot ne 0) and ((inttime ne 0) or (lowcut ne 0) or defined(filter_high) or defined(filter_low))) then begin
;    errormess='Filtering canot be used for subchannels.'
;    if (not keyword_set(silent)) then print,errormess
;    outcorr=0
;    return
;  endif
  ; *** Low- or high-cut filtering for plot signal
  if (inttime ne 0) then sigplot1=integ(sigplot1,inttime*1e-6/sampletime)
  if (lowcut ne 0) then sigplot1=sigplot1-integ(sigplot1,lowcut*1e-6/sampletime)
  if defined(filter_order) or defined(filter_high) or defined(filter_low) then begin
    ; This will do the actual filtering only the parameters are set
    sigplot1 = bandpass_filter_data(sigplot1,sampletime=sampletime,$
             filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
             filter_symmetric=filter_symmetric,errormess=errormess)
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
  endif
  ; *** Making plot signal equidistantly sampled if it is a subchannel
  if (subchannel_plot ne 0) then begin
    t = time_plot(i1c:i2c)
    s= sigplot1
    ns = n_elements(t)
    ; finding elements where there is a jump in timescale
    ind = where((t(1:ns-1)-t(0:ns-1)) gt sampletime*1.5)
    if (ind(0) ge 0) then begin ; if there are jumps in the time vector
      ; number of samples which will be inserted into one jump
      n_insert = round((t(ind(0)+1)-t(ind(0)))/sampletime)-1
      ; number of subchannel samples in one period
      n_period_subch = ind(1)-ind(0)
      ; Period of the deflection
      deflection_period_plot = n_period_subch+n_insert
      ; A mask for one period: 1 where we have sample
         ; This array is one period long
      subch_mask_plot = intarr(deflection_period_plot)+1
      subch_mask_plot(ind(0)+1:ind(0)+n_insert) = 0
      ; size of the new arrays
      n_newarray = n_elements(t)+n_insert*n_elements(ind)
      ; the output arrays
      tw = dblarr(n_newarray)
      sw = fltarr(n_newarray)
      ; time vector for the insertion
      t_insert = (dindgen(n_insert)+1)*double(sampletime)
      actpos = ind(0) ; this is the index where the last element before a jump will be written
      ; looping through the insertions
      for i_insert=0l,n_elements(ind)-1 do begin
        ; copying the subchannel samples
        tw((actpos-n_period_subch+1) > 0 : actpos) = t((ind(i_insert)-n_period_subch+1) > 0 : ind(i_insert))
        sw((actpos-n_period_subch+1) > 0 : actpos) = s((ind(i_insert)-n_period_subch+1) > 0 : ind(i_insert))
        ; adding the samples in the jump
        if (actpos lt n_newarray-1) then begin
          tw(actpos+1 : actpos+1+n_insert-1) = t_insert+t(ind(i_insert))
          actpos = actpos+n_insert+n_period_subch
        endif
      endfor
      ; inserting the samples which are after the last jump
      tw(actpos-n_period_subch+1 : n_elements(tw)-1) = t(ind(n_elements(ind)-1)+1:n_elements(t)-1)
      sw(actpos-n_period_subch+1 : n_elements(tw)-1) = s(ind(n_elements(ind)-1)+1:n_elements(t)-1)
    endif
    sigplot1 = sw
    time_plot1 = tw
  endif

  ; Checking if sampling is equidistant with sampletime in processing time interval
  ind = where(abs(time_plot1(1:n_elements(time_plot1)-1) - time_plot1(0:n_elements(time_plot1)-2) - sampletime)/sampletime ge 0.4)
  if (ind(0) ge 0) then begin
    errormess='Sampling is not equidistant for plot signal in time interval ['+string(proct1,format='(F7.5)')+$
               ','+string(proct2,format='(F7.5)')+']'
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    if (keyword_set(stop_on_error)) then stop
    return
  endif


  ; Sampletime of the two signals is identical here. However, it can be that
  ; the signals do not start at the same time
;  if ((subchannel_ref eq 0) and (subchannel_plot eq 0)) then begin
    time_diff = time_plot1[0]-time_ref1[0]
    if (abs(time_diff) gt sampletime*0.25) then begin
      if (time_diff gt 0) then begin
        ind = where((time_ref1-time_plot1[0]) gt -sampletime*0.99)
        if (ind[0] lt 0) then begin
          errormess="No overlap between samples of two signals."
          if (not keyword_set(silent)) then print,errormess
          outcorr=0
          return
        endif
        time_ref1 = time_ref1[ind[0]:n_elements(time_ref1)-1]
        sigref1 = sigref1[ind[0]:n_elements(sigref1)-1]
        if (subchannel_ref ne 0) then begin
          ind1 = lindgen(deflection_period_ref)+ind(0)
          subch_mask_ref = subch_mask_ref(ind1 mod deflection_period_ref)
        endif
      endif else begin
        ind = where((time_plot1-time_ref1[0]) gt 0)
        if (ind[0] lt 0) then begin
          errormess="No overlap between samples of two signals."
          if (not keyword_set(silent)) then print,errormess
          outcorr=0
          return
        endif
        time_plot1 = time_plot1[ind[0]:n_elements(time_plot1)-1]
        sigplot1 = sigplot1[ind[0]:n_elements(sigplot1)-1]
        if (subchannel_plot ne 0) then begin
          ind1 = lindgen(deflection_period_plot)+ind(0)
          subch_mask_plot = subch_mask_plot(ind1 mod deflection_period_plot)
        endif
      endelse
    endif
 ; endif

  if (n_elements(time_ref1) ne n_elements(time_plot1)) then begin
    if (n_elements(time_ref1) lt n_elements(time_plot1)) then begin
      time_plot1 = time_plot1(0:n_elements(time_ref1)-1)
      sigplot1 = sigplot1(0:n_elements(time_ref1)-1)
    endif else begin
      time_ref1 = time_ref1(0:n_elements(time_plot1)-1)
      sigref1 = sigref1(0:n_elements(time_plot1)-1)
    endelse
  endif

  if (int_i eq 0) then begin
    channel_timeshift = time_plot1[0]-time_ref1[0]
  endif else begin
    if (abs(channel_timeshift-(time_plot1[0]-time_ref1[0]))/sampletime gt 0.01) then begin
      errormess="Time shift between channels is different in processing intervals.."
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
  endelse

  if (channel_timeshift ne 0) then begin
    time_plot1 = time_plot1-channel_timeshift
  endif

  ; At this point the two signals should be sampled on the same timescale
  ; Checking this and other consistencies
  if (   (n_elements(time_ref1) ne n_elements(sigref1))   $
      or (n_elements(time_plot1) ne n_elements(sigplot1)) $
      or (n_elements(time_plot1) ne n_elements(time_ref1)) ) then begin
    errormess="Internal consitency check failed. At this point the two signals should have equal length."
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
  endif

  siglen = n_elements(time_ref1)
  if ((abs(time_ref1(0)-time_plot1(0)) gt 0.4*sampletime) $
      or (abs(time_ref1(siglen-1)-time_plot1(siglen-1)) gt 0.4*sampletime)) then begin
    errormess="Internal consitency check failed. At this point the two signals should have common timescale."
    if (not keyword_set(silent)) then print,errormess
    outcorr=0
    return
  endif

  if (int_i eq 0) then begin
    calc_len=siglen
  endif

  if (abs(siglen-calc_len) gt calc_len/10) then begin
    errormess="Warning: Calculation length for intervals is significantly different."
    print,errormess
    if (not keyword_set(silent)) then print,errormess
    if (not keyword_set(nowarning)) then begin
      outcorr=0
      return
    endif else begin
      errormess = ''
    endelse
  endif

    ; The number of correlation points for the shifts
    corr_point_n = fltarr(n_elements(shift_list))
    if ((subchannel_plot eq 0) and (subchannel_ref eq 0)) then begin
      ; if none of the signals is subchannel
       corr_point_n(*) = n_elements(sigref1)-abs(shift_list) > 0
    endif else begin
      ; At least one signal is subchannel
       if (subchannel_plot eq 0) then begin
         ; plot signal is not subchannel
         deflection_period_plot = deflection_period_ref
         subch_mask_plot = intarr(deflection_period_plot)+1
       endif
       if (subchannel_ref eq 0) then begin
         ; ref signal is not subchannel
         deflection_period_ref = deflection_period_plot
         subch_mask_ref = intarr(deflection_period_ref)+1
       endif

       ; From here both signals are handled as subchannels, just the mask can be all one
       ; for the channel which is not subchannel

       ; Finding the shorter and longer deflection period times
       deflection_period_max = max([deflection_period_plot,deflection_period_ref])
       deflection_period_min = min([deflection_period_plot,deflection_period_ref])
       ; The longer period should be a multiple of the shorter
       if ((deflection_period_max mod deflection_period_min) ne 0) then begin
         errormess = 'Incompatible deflection period times.'
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif

       ; If the two deflection periods are different extendending the mask of the shorter
       ; period signal to the longer period one
       if (deflection_period_max ne deflection_period_min) then begin
         if (deflection_period_plot eq deflection_period_min) then begin
           ; plot signal has shorter period
           subch_mask_plot_save = subch_mask_plot
          subch_mask_plot = subch_mask_ref
          ind = lindgen(deflection_period_max)
          subch_mask_plot = subch_mask_plot_save(ind mod deflection_period_plot)
         endif else begin
           ; ref signal has shorter period
           subch_mask_ref_save = subch_mask_ref
          subch_mask_ref = subch_mask_plot
          ind = lindgen(deflection_period_max)
          subch_mask_ref = subch_mask_ref_save(ind mod deflection_period_ref)
         endelse
       endif

       ; looping through the shift list
       for is=0,n_elements(shift_list)-1 do begin
         ; the actual shift
         i = shift_list(is)
         ; number of full deflection periods
         nper_total = long((n_elements(sigplot1)-i)/deflection_period_max)
         ; the number of points left at the end
         n_rest = n_elements(sigplot1)-i-deflection_period_max*nper_total
         if ((nper_total le 0) and (n_rest le 0)) then begin
           corr_point_n(is) = 0
         endif else begin
           ; mod period time shift, assuring that it is positive
           imod = (i + (long(abs(i)/deflection_period_max)+1)*deflection_period_max) mod deflection_period_max
       ;   number of correlation points for 1 period
           ind = lindgen(deflection_period_max)
           np_1 = total(subch_mask_ref*subch_mask_plot((ind+imod) mod deflection_period_max))
           ; Multiplying by the number of periods
           np_1 = np_1*nper_total
           if (n_rest ne 0) then begin
             ; Adding the correlation values in the rest of the points
             ind = lindgen(n_rest)
           np_1 = np_1 + total(subch_mask_ref(ind)*subch_mask_plot((ind+imod) mod deflection_period_max))
           endif
           corr_point_n(is) = np_1
         endelse
       endfor
    endelse  ; if one of the signals is subchannel

    corr_avail = where(corr_point_n ne 0)

    if (keyword_set(nofft)) then begin
      ; Calculating correlation following the definition, without FFT
      ; In this case no power spectrum will be calculated, this is for test pourposes only
       corr=dcomplexarr(shift_n)
       for shift_i=0,shift_n-1 do begin
         i1 = -shift_list(shift_i) > 0
         i2 = n_elements(sigref1)-1-shift_list(shift_i) < n_elements(sigref1)-1
         sigref = sigref1(i1:i2)
         sigplot=sigplot1(i1+shift_list(shift_i):i2+shift_list(shift_i))
         corr[shift_i]=total(sigref*conj(sigplot))
      endfor
    endif
    if (keyword_set(fft)) then begin
      ; Caclulating everything with FFT
      ; The range of data in the array for processing
      i1=long(-min(shift_list))
      i2=long(n_elements(sigref1)-1-max(shift_list))

      ; We detemine an array with power of 2 elements which is larger than the array to process.
      ; I think it is better not to leave the interpolation to the IDL routine for non 2-power elements
      nnn=(size(sigref1))(1)+(max(shift_list)-min(shift_list))
      plist=[128L,256L,512L,1024L,1024L*2,1024L*4,1024L*8,$
          1024L*16,1024L*32,1024L*62,1024L*128,1024L*256,1024L*512,1024L*1024,1024L*2048L,1024L*4096,1024L*8192,1024L*16384]
      if (int_i eq 0) then nfft=plist((where(nnn le plist))(0))

      ; Placing the data into the arrays for FFT calculation
      s1=dcomplexarr(nfft)
      if (not keyword_set(autocorr_flag)) then s2=dcomplexarr(nfft)
      if (keyword_set(hanning_window)) then begin
        window_function = hanning(n_elements(sigref1))
      endif else begin
        if (keyword_set(hamming_window)) then begin
          window_function = hanning(n_elements(sigref1),alpha=0.54)
        endif else begin
          window_function = 1
        endelse
      endelse
      s1((nfft-nnn)/2:(nfft-nnn)/2+n_elements(sigref1)-1) = sigref1*window_function
      ; FFT of reference signal
      p=fft(s1,-1)
      ; Creating array for storing all FFT data (this seems to be unised, therefore removing)
      ; if (not defined(fft_arr)) then fft_arr=complexarr(int_n,nfft)
      ; fft_arr(int_i,*)=p
      if (not defined(fft_totalpoints)) then fft_totalpoints = 0L
      if (n_elements(window_function) eq 1) then begin
        fft_totalpoints = fft_totalpoints + n_elements(sigref1)
      endif else begin
        fft_totalpoints = fft_totalpoints + total(window_function)
      endelse
      ; Calclulating crosspower
      if (not keyword_set(autocorr_flag)) then begin
        s2((nfft-nnn)/2:(nfft-nnn)/2+n_elements(sigplot1)-1) = sigplot1*window_function
        p1=fft(s2,-1)
        csp = p*conj(p1)
      endif else begin
        csp = p*conj(p)
      endelse
      ind1=findgen(nfft/2)+nfft/2
      ind2=findgen(nfft/2)
      if (keyword_set(complex_signal) and not keyword_set(autocorr_flag)) then begin
        corr=fft(csp,1)
      endif else begin
        corr=float(fft(csp,1))
      endelse
      if (n_elements(window_function) eq 1) then begin
        corr=corr*float(nfft)
      endif else begin
        corr=corr*float(total(window_function))
      endelse
      csp=[csp[ind1],csp[ind2]]
      ; Correct scaling for the power
      csp = csp*nfft*sampletime
      nt=(size(corr))(1)
      ind=(-shift_list+nt) mod nt
      corr=corr(ind)
    endif

    if (keyword_set(autocorr_flag) and (cut_length ne 0)) then begin
      if (subchannel_plot ne 0) then begin
         corr_photon = corr(corr_avail)/corr_point_n(corr_avail)
         time_photon = shift_list(corr_avail)*st
      photon_cut,corr_photon,time_photon,cut_length=cut_length,extrapol_length=extrapol_length,$
                  extrapol_order=extrapol_order,errormess=errormess,/silent
         corr[corr_avail] = corr_photon*corr_point_n(corr_avail)
       endif else begin
      photon_cut,corr,shift_list*st,cut_length=cut_length,extrapol_length=extrapol_length,$
                  extrapol_order=extrapol_order,errormess=errormess,/silent
       endelse
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    endif

  if (keyword_set(fft)) then begin
    fres_act = 1./(nfft*sampletime)
    frange_act = [-1*(nfft/2-1)*fres_act,nfft/2*fres_act]
    fscale_act = (dindgen(nfft)-(nfft/2-1))*fres_act
    if (channel_timeshift ne 0) then begin
      ; Correction for time shift between channels
      correction_array = exp(complex(0,2*!pi*fscale_act*channel_timeshift,/double))
      csp = csp*correction_array
    endif
  endif

  ; Creating arrays for data store in first time interval
  if (int_i eq 0) then begin
    ; The output time vector
    outtime = shift_list*sampletime/1e-6+(channel_timeshift/1e-6)
    ; The correlation for all time intervals
    korr = fltarr(int_n,n_elements(outtime))
    ; This will store 1 where correlation is available
    corr_avail_list = intarr(int_n,n_elements(outtime))
    ; total number of points for each shift
    totalpoints = fltarr(n_elements(outtime))
    if (tres ne sampletime/1e-6) then begin
      ; The number of points for smoothing
        mult=round(tres/(sampletime/1e-6))
      ; The index where the smoothed array should be read
         ind_smooth = findgen(shift_n/mult)*mult+long(mult)/2
      ; Finding the closest point on the positive side of 0 time lag where
      ; the number of points is maximum
      ind0 = (where(shift_list eq 0))(0)
      ind0_orig = ind0
      while ((corr_point_n(ind0) eq 0) or (corr_point_n(ind0) lt corr_point_n(ind0+1))) do ind0 = ind0+1
      ; The smooth index will be shifted if the maximum is not at 0 time lag
      if (ind0_orig ne ind0) then begin
        ind_smooth=ind_smooth+(ind0-ind0_orig)
        ind_smooth = ind_smooth(where(ind_smooth lt n_elements(shift_list)))
      endif
      outtime = smooth(outtime,mult)
      outtime = outtime(ind_smooth)
    endif
    ; Calculating frequency spectrum parameters only if FFT is used
    if (keyword_set(fft)) then begin
      ; The default frequency resolution is the actual one
      default,fres,fres_act
      ; Default frequency range is symmetric for crosspower and only positive for autopower
      if (keyword_set(autocorr_flag)) then begin
        default,frange,[0,max(fscale_act)]
      endif else begin
        default,frange,[min(fscale_act),max(fscale_act)]
      endelse
      if (keyword_set(ftype)) then begin
        if (frange[0] lt fres) then frange[0] = fres
      endif
      ; Calculating the output frequency array
      if (not keyword_set(ftype)) then begin
        ; the standard fixed frequency resoution
        nfreq = long(frange[1]-frange[0])/fres
        outfreq = dindgen(nfreq)*fres+frange[0]
      endif else begin
        ; Going throught the frequency array and determining the frequency ranges for each bin
        f_starts = frange[0]-float(fres)/2
        f_ends = frange[0]+float(fres)/2
        ind_loop = 0L
        while 1 do begin
          new_end = f_ends[ind_loop]*f_ends[ind_loop]/f_starts[ind_loop]
          if (new_end gt frange[1]) then break
          ; The start of the next bin equals the end of the previous
          f_starts = [f_starts,f_ends[ind_loop]]
          ; The end of the next bin is set in a way that the ration of the lenghts of the two
          ; subsequent bins is proportional to the ratio of their central frequencies
          f_ends = [f_ends,new_end]
          ; Step to next bin
          ind_loop = ind_loop+1
        endwhile
        ; The frequency scale is the middle of the bins
        outfreq = (f_starts+f_ends)/2
        nfreq = n_elements(outfreq)
      endelse
      ; Creating array for storing all spectra
      spectra = dcomplexarr(int_n,nfreq)
    endif  ; if FFT
  endif  ; if first time interval

  if (tres ne sampletime/1e-6) then begin
       corrs=smooth(corr,mult)
       corr=corrs[ind_smooth]
       cpn_s = smooth(corr_point_n,mult)
       corr_point_n=cpn_s[ind_smooth]
  endif

  ; Setting the frequency resolution for the output spectra
  if (keyword_set(fft)) then begin
    if (not keyword_set(ftype)) then begin
      ; In the normal fixed frequency resolution just smoothing array and selecting appropriate point
      if (fres_act ne fres) then begin
        smlength = round(fres/fres_act)
        ; Must be odd!!!! for smooth (not in IDL documentation)
        if ((smlength mod 2) eq 0) then smlength = smlength+1
        csp = smooth(csp,smlength)
      endif else begin
        smlength = 1
      endelse
      ; Collecting the smooth lenght for detemining the confidence of the coherency
      if (not defined(avr_smlength)) then begin
        avr_smlength = smlength
      endif else begin
        avr_smlength = avr_smlength+smlength
      endelse
      spectra[int_i,*] = interpolate(csp,(outfreq-frange_act[0])/(nfft*fres_act)*nfft)
    endif else begin ; end normal fres
      ; Creating array to collect the smooth lenght for detemining the confidence of the coherency
      if (not defined(avr_smlength)) then begin
        avr_smlength = fltarr(nfreq)
      endif
      ; for the logarithmic frequency resolution we must loop throught the array
      for i_local=0L,nfreq-1 do begin
        ind = where((fscale_act ge f_starts[i_local]) and (fscale_act lt f_ends[i_local]))
        if (ind[0] ge 0) then begin
          spectra[int_i,i_local] = mean(csp[ind])
          avr_smlength[i_local] = avr_smlength[i_local]+n_elements(ind)
        endif
      endfor
    endelse

    ; correction for the energy drop caused by partial fill of the FFT array
    if (n_elements(window_function eq 1)) then begin
      spectra[int_i,*] = spectra[int_i,*] * float(nfft)/float(n_elements(sigref1))
    endif else begin
      spectra[int_i,*] = spectra[int_i,*] * float(nfft)/float(total(window_function))
    endelse
  end ; if FFT

  ; Indices where a correlation value is available
  corr_avail = where(corr_point_n ne 0)
  corr_avail_list(int_i,corr_avail) = 1
  korr(int_i,corr_avail)=corr(corr_avail)/corr_point_n(corr_avail)
  totalpoints = totalpoints + corr_point_n
endfor   ; ******* int_i

; Calculating mean and scatter of output values from subintervals
n_corr = n_elements(outtime)
outcorr=fltarr(n_corr)
outscat=fltarr(n_corr)
; *** As the intervals are of equal length, no weighting is done below *****
for i=0,int_n-1 do begin
  outcorr=outcorr+korr[i,*]
endfor
outcorr=outcorr/int_n
for i=0,int_n-1 do begin
  outscat=outscat+(korr(i,*)-outcorr)*(korr(i,*)-outcorr)
endfor
; Normalising scatter with square root of the number of intervals
if (int_n ne 1) then begin
  outscat=sqrt(outscat/(int_n-1))
  outscat=outscat/sqrt(int_n)
endif else begin
  outscat=outcorr*0
endelse
if (keyword_set(fft)) then begin
  outpower = dblarr(n_elements(outfreq))
  outpwscat = dblarr(n_elements(outfreq))
  outspectrum = dcomplexarr(n_elements(outfreq))
  outphase = dblarr(n_elements(outfreq))
  ; *** As the intervals are of equal length, no weighting is done below *****
  for i=0,int_n-1 do begin
    outpower = outpower + sqrt(real_part(spectra[i,*])^2 + imaginary(spectra[i,*])^2)
    outspectrum = outspectrum + spectra[i,*]
  endfor
  outspectrum = outspectrum/int_n;
  outpower = outpower/int_n;
  outphase = atan(outspectrum,/phase)
  for i=0,int_n-1 do begin
    outpwscat= outpwscat+(sqrt((real_part(spectra[i,*])^2 + imaginary(spectra[i,*])^2))-outpower)^2
  endfor

  ; Normalising scatter with square root of the number of intervals
  if (int_n ne 1) then begin
    outpwscat = sqrt(outpwscat/(int_n-1))
    outpwscat = outpwscat/sqrt(int_n)
  endif else begin
    outpwscat = outpower*0
  endelse

  ; This is the effective reduction of the crosspower due to both frequency smoothing and number of intervals
  ; (confidence level for coherency)
  crosspower_noiselevel = 1./sqrt(avr_smlength/int_n)/sqrt(int_n)

  ; The output power spectrum is calculated from the average spectrum for crosspower
  ; In this case error is calculated from statistical error as it is not possible to calculate from the statistics througn intervals
  if (not keyword_set(autocorr_flag)) then begin
    outpower = sqrt(real_part(outspectrum)^2 + imaginary(outspectrum)^2)
    outpwscat = outpower*crosspower_noiselevel 
  endif

  ; Cutting out points with no data for ftype = 1
  if (keyword_set(ftype)) then begin
    ind = where(avr_smlength ne 0)
    if (ind[0] ge 0) then begin
      outfreq = outfreq[ind]
      outpower = outpower[ind]
      outpwscat = outpwscat[ind]
      outphase = outphase[ind]
      outspectrum = outspectrum[ind]
      crosspower_noiselevel = crosspower_noiselevel[ind]
    endif
  endif


endif ; FFT

; Cutting out the points where correlation is available in all intervals
corr_avail = where(total(corr_avail_list,1) eq int_n)
if (corr_avail(0) lt 0) then begin
  errormess = 'No correlation points are found. Too short time intervals?'
  if (not keyword_set(silent)) then print,errormess
  outcorr=0
  return
endif
outtime = outtime(corr_avail)
outcorr = outcorr(corr_avail)
outscat = outscat(corr_avail)

if (keyword_set(norm)) then begin
  if (keyword_set(autocorr_flag)) then begin
    ind = where(abs(outtime) lt (outtime[1]-outtime[0])/10)
    if (ind(0) lt 0) then begin
      errormess = 'No correlation is available at 0 time lag, cannot normalise.'
      if (not keyword_set(silent)) then print,errormess
      if (keyword_set(stop_on_error)) then stop
      outcorr=0
      return
    endif
    if (outcorr(ind(0)) le 0) then begin
      if (total(outcorr) ne 0) then begin
        errormess = 'Autocorrelation is negative at 0 time lag, cannot normalize.'
        if (not keyword_set(silent)) then print,errormess
        if (keyword_set(stop_on_error)) then stop
        outcorr=0
        return
      endif
    endif else begin
      outscat = outscat/outcorr(ind(0))
      outcorr = outcorr/outcorr(ind(0))
      outpower[*] = 1.
    endelse
  endif else begin
    ; Calculating autopower for plot channel
      if defined(offset_timerange) then offset_timerange_to_get_4=offset_timerange
    fluc_correlation,shot,timefile,timerange=timerange,data_source=data_source,$
      plotchannel=plotchan,subchannel_plot=subchannel_plot,refchannel=plotchan,subchannel_ref=subchannel_plot,$
      taures=tres_orig,fres=fres,ftype=ftype,frange=frange,taurange=trange_in,inttime=inttime_in,baseline_function=baseline_function,$
      filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,filter_symmetric=filter_symmetric,$
      outtime=plot_auto_time,outcorr=plot_auto_corr,$
      outpower=outpower_plot,outpwscat=outpwscat_plot,outfscale=outfscale_plot,$
      /noplot,/noverbose,lowcut=lowcut,fitorder=fitorder,$
      interval_n=interval_n,calfac=calfac,nocalibrate=nocalibrate,$
      cut_length=cut_length,extrapol_length=extrapol_length,$
      extrapol_order=extrapol_order,$
      fft=fft,nofft=nofft,errormess=errormess,/silent,$
      afs=afs,cdrom=cdrom,no_errorcatch=noerrorcatch,$
      no_shift_correct=no_shift_correct,$
      correction_method=correction_method,p2_points=p2_points,$
      datapath=datapath,filename=filename,nowarning=nowarning,offset_timerange=offset_timerange_to_get_4,offset_type=offset_type

    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    ind = where(abs(plot_auto_time) lt (plot_auto_time[1]-plot_auto_time[0])/10)
    if (ind(0) lt 0) then begin
      errormess = 'No correlation is available at 0 time lag, cannot normalise.'
      if (not keyword_set(silent)) then print,errormess
      if (keyword_set(stop_on_error)) then stop
      outcorr=0
      return
    endif
    if (plot_auto_corr(ind(0)) le 0) then begin
      errormess = 'Autocorrelation is negative at 0 time lag, cannot normalize.'
      if (not keyword_set(silent)) then print,errormess
      if (keyword_set(stop_on_error)) then stop
      outcorr=0
      return
    endif
    if (keyword_set(fft)) then begin
      if (total(outfreq ne outfscale_plot) ne 0) then begin
        errormess = 'Different frequency scales for auto and crosspower.'
        if (not keyword_set(silent)) then print,errormess
        if (keyword_set(stop_on_error)) then stop
        outcorr=0
        return
      endif
    endif

    plot_auto_corr = plot_auto_corr(ind(0))

    ; calculating autopower for reference channel
    if defined(offset_timerange) then offset_timerange_to_get_5=offset_timerange
    fluc_correlation,shot,timefile,timerange=timerange,data_source=data_source,$
      plotchannel=refchan,subchannel_plot=subchannel_ref,refchannel=refchan,subchannel_ref=subchannel_ref,$
      taures=tres_orig,taurange=trange_in,fres=fres,ftype=ftype,frange=frange,inttime=inttime_in,baseline_function=baseline_function,$
      filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,filter_symmetric=filter_symmetric,$
      outtime=ref_auto_time,outcorr=ref_auto_corr,$
      outpower=outpower_ref,outpwscat=outpwscat_ref,outfscale=outfscale_ref,$
      /noplot,/noverbose,lowcut=lowcut,fitorder=fitorder,$
      interval_n=interval_n,calfac=calfac,nocalibrate=nocalibrate,$
      cut_length=cut_length,extrapol_length=extrapol_length,$
      extrapol_order=extrapol_order,$
      fft=fft,nofft=nofft,errormess=errormess,/silent,$
    afs=afs,cdrom=cdrom,no_errorcatch=noerrorcatch,$
    no_shift_correct=no_shift_correct,$
    correction_method=correction_method,p2_points=p2_points,$
    datapath=datapath,filename=filename,nowarning=nowarning,offset_timerange=offset_timerange_to_get_5,offset_type=offset_type

    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif

    if (keyword_set(fft)) then begin
      if (total(outfreq ne outfscale_ref) ne 0) then begin
        errormess = 'Different frequency scales for auto and crosspower.'
        if (not keyword_set(silent)) then print,errormess
        if (keyword_set(stop_on_error)) then stop
        outcorr=0
        return
      endif
    endif

    ind = where(abs(ref_auto_time) lt (ref_auto_time[1]-ref_auto_time[0])/10)
    if (ind(0) lt 0) then begin
      errormess = 'No correlation is available at 0 time lag, cannot normalise.'
      if (not keyword_set(silent)) then print,errormess
      if (keyword_set(stop_on_error)) then stop
      outcorr=0
      return
    endif
    if (ref_auto_corr(ind(0)) le 0) then begin
      errormess = 'Autocorrelation is negative at 0 time lag, cannot normalize.'
      if (not keyword_set(silent)) then print,errormess
      if (keyword_set(stop_on_error)) then stop
      outcorr=0
      return
    endif

    ref_auto_corr = ref_auto_corr(ind(0))

    outcorr = outcorr/sqrt(ref_auto_corr*plot_auto_corr)
    outscat = outscat/sqrt(ref_auto_corr*plot_auto_corr)

    ; Normalized crosspower is the coherency
    ind = where((outpower_plot ne 0) and (outpower_ref ne 0))
    if (ind[0] ge 0) then begin
      outpower[ind] = outpower[ind]/sqrt(outpower_plot[ind]*outpower_ref[ind])
    endif
    ind = where((outpower_plot eq 0) or (outpower_ref eq 0))
    if (ind[0] ge 0) then begin
      outpower[ind] = 0
    endif
    ; We set the error for the coherency equal to the estimated statistical error.
    ; It is not possible to give an error estimate on the basis of the power in intervals
    ; Done on 18.12.2014   SZ.
    outpwscat = crosspower_noiselevel;
  endelse
endif  ; norm


mean_ref = avr_ref/nsample_ref
mean_plot = avr_plot/nsample_plot

if (keyword_set(percent)) then begin
  scale = 100./(avr_ref/nsample_ref-background_level)

  cp = outcorr+outscat
  ind1 = where(cp ge 0)
  ind2 = where(cp lt 0)
  if (ind1[0] ge 0) then begin
    cp[ind1] = sqrt(cp[ind1])*scale
  endif
  if (ind2[0] ge 0) then begin
    cp[ind2] = -sqrt(-cp[ind2])*scale
  endif

  cm = outcorr-outscat
  ind1 = where(cm ge 0)
  ind2 = where(cm lt 0)
  if (ind1[0] ge 0) then begin
    cm[ind1] = sqrt(cm[ind1])*scale
  endif
  if (ind2[0] ge 0) then begin
    cm[ind2] = -sqrt(-cm[ind2])*scale
  endif

  ind1 = where(outcorr ge 0)
  ind2 = where(outcorr lt 0)
  if (ind1[0] ge 0) then begin
    outcorr[ind1] = sqrt(outcorr[ind1])*scale
  endif
  if (ind2[0] ge 0) then begin
    outcorr[ind2] = -sqrt(-outcorr[ind2])*scale
  endif

  cp = cp-outcorr
  cm = outcorr-cm
  outscat = cp > cm
endif

if (keyword_set(save)) then save,file=dir_f_name('tmp',savefile)


plot:
if (not keyword_set(noplot)) then begin
  if (not keyword_set(noerase) and not keyword_set(overplot)) then erase
  if (not keyword_set(nolegend) and not keyword_set(overplot)) then begin
    time_legend,'fluc_correlation.pro'
  endif
  default,pos,[0.1,0.15,0.68,0.7]
  if (not keyword_set(nopara) and not keyword_set(overplot)) then begin
    if (keyword_set(experiment)) then begin
      txt = 'experiment: '+experiment
    endif else begin
      if (data_source ne 28) then begin
        txt = 'shot: '+i2str(shot)
      endif else begin
        txt = ''
      endelse
    endelse
    txt = txt+'!Crefchannel: '

    for i=0,n_elements(refchan)-1 do begin
      txt = txt+'!C   '+refchan(i)
    endfor
    if (subchannel_ref ne 0) then txt = txt+'!Csubchannel_ref: '+i2str(subchannel_ref)
    txt = txt+'!Cplotchannel: '
    for i=0,n_elements(plotchan)-1 do begin
      txt = txt+'!C   '+plotchan(i)
    endfor
    if (subchannel_plot ne 0) then txt = txt+'!Csubchannel_plot: '+i2str(subchannel_plot)
    if (keyword_set(density)) then txt = txt+'/density'
    if (not keyword_set(experiment)) then begin
      if (keyword_set(timefile)) then begin
        txt = txt+'!Ctimefile: '+timefile
        openr,unit,'time/'+timefile,error=error,/get_lun
        if (error ne 0) then begin
          txt = txt+'!C   (??? - ???)'
        endif else begin
          close,unit
          free_lun,unit
          w=loadncol('time/'+timefile,2,/silent)
          ind=where((w(*,0) ne 0) or (w(*,1) ne 0))
          if (ind(0) ge 0) then w=w(ind,*)
          if (max(w) ge 10) then f = '(F6.3)' else f='(F5.3)'
          txt = txt+'!C   ('+string(min(w),format=f)+$
                            '-'+string(max(w),format=f)+')'
        endelse
      endif
      if (keyword_set(timerange)) then begin
        if (max(timerange) ge 10) then f = '(F6.3)' else f='(F5.3)'
        txt = txt +'!Ctimerange:('+string(timerange(0),format=f)+$
                          '-'+string(timerange(1),format=f)+')'
      endif
    endif
    if (keyword_set(plot_correlation)) then begin
      txt = txt+'!Ctres: '+string(tres,format='(F6.2)')+' microsec.'
    endif
    if (keyword_set(plot_spectra) or keyword_set(plot_power) or keyword_set(plot_spectra) or keyword_set(plot_phase)) then begin
      txt = txt+'!Cfres: '+string(fres,format='(E9.1)')+' Hz.'
      txt = txt+'!Cfrange: ['+string(frange[0],format='(E9.1)')+','+ string(frange[1],format='(E10.2)')+' Hz.'
    endif
    txt = txt+'!Cbaseline_function: '+baseline_function
    txt = txt+'!Cfitorder: '+i2str(fitorder)
    if (inttime ne 0) then txt = txt+'!Cinttime: '+string(inttime,format='(F6.2)')+' microsec.'
    if (lowcut ne 0) then txt = txt+'!Clowcut: '+string(lowcut,format='(F8.2)')+' microsec.'
    txt = txt+'!Cinterval_n: '+i2str(int_n)
    if (keyword_set(nocalibrate)) then txt = txt+'!C/nocalibrate'
    if (keyword_set(norm)) then txt = txt+'!C/normalize'
    if ((cut_length ne 0) and keyword_set(autocorr_flag)) then begin
      txt = txt+'!Ccut_length: '+string(cut_length,format='(F4.2)')+' microsec.'
      txt = txt+'!Cextrapol_length: '+string(extrapol_length,format='(F5.2)')+' microsec.'
      txt = txt+'!Cextrapol_order: '+i2str(extrapol_order)
    endif
    if (keyword_set(percent)) then begin
      txt = txt+'!C/percent'
      txt = txt+'!Cbackground_level: '+string(background_level)
    endif
    if (keyword_set(fft)) then  txt = txt+'!C/fft'
    if (keyword_set(nofft)) then  txt = txt+'!C/nofft'
    if (keyword_set(hanning_window)) then  txt = txt+'!C/hanning'
    if (keyword_set(hamming_window)) then  txt = txt+'!C/hamming'
    if (keyword_set(ftype)) then  txt = txt+'!Cftype=1' else txt = txt+'!Cftype=0'


    plots,[pos(2)+0.03,pos(2)+0.03],[0.1,0.9],thick=3,/normal
    xyouts,pos(2)+0.04,0.85,txt,/normal,charthick=thick,charsize=charsize
  endif ; nopara

  if (keyword_set(plot_correlation)) then begin
    if (not keyword_set(norm) and not keyword_set(yrange)) then begin
      yrange=[min(outcorr-outscat),max(outcorr+outscat)]
    endif

    default,title,''
    if (keyword_set(percent)) then begin
      ytitle = 'Square root of autocorrelation [%]'
    endif else begin
      if (keyword_set(autocorr_flag)) then begin
        if (keyword_set(norm)) then ytitle = 'Autocorrelation' else ytitle = 'Autocovariance'
      endif else begin
        if (keyword_set(norm)) then ytitle = 'Crosscorrelation' else ytitle = 'Crosscovariance'
      endelse
    endelse

    if (not keyword_set(overplot)) then begin
      if (not (keyword_set(complex_data) and not keyword_set(autocorrelation_flag))) then begin
        if (defined(charsize) and (not defined(xcharsize)) and (not defined(ycharsize))) then begin
          xcharsize=charsize
          ycharsize=charsize
        endif
        ; This is a real correlation function
        plot,outtime,outcorr,xtitle='Time delay(microsec)',xstyle=1,xrange=trange,$
           ystyle=1,yrange=yrange,ytitle=ytitle,psym=psym,$
           title=title,/noerase,pos=pos,thick=thick,xthick=thick,ythick=thick,$
           charthick=thick,xcharsize=xcharsize,ycharsize=ycharsize
        if ((yrange(1) gt 0) and (yrange(0) lt 0)) then begin
          plots,trange,[0,0],linestyle=0,/data,thick=thick
        endif
        if (not keyword_set(noerror)) then begin
          errplot,outtime,outcorr-outscat,outcorr+outscat,thick=thick
        endif
        plots,[0,0],yrange,linestyle=1,thick=thick
      endif else begin
        ; Complex correlation
        pos_real = [pos[0],pos[1]+(pos[3]-pos[1])*0.6,pos[2],pos[3]]
        pos_imag = [pos[0],pos[1],pos[2],pos[1]+(pos[3]-pos[1])*0.4]
        if (defined(charsize) and (not defined(xcharsize)) and (not defined(ycharsize))) then begin
          xcharsize=charsize
          ycharsize=charsize
        endif
        plot,outtime,real_part(outcorr),xtitle='Time delay(microsec)',xstyle=1,xrange=trange,$
           ystyle=1,yrange=yrange,ytitle=ytitle+' (Real)',psym=psym,$
           title=title,/noerase,pos=pos_real,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
           xcharsize=xcharsize,ycharsize=ycharsize
        if ((yrange(1) gt 0) and (yrange(0) lt 0)) then begin
          plots,trange,[0,0],linestyle=0,/data,thick=thick
        endif
        if (not keyword_set(noerror)) then begin
          errplot,outtime,real_part(outcorr)-real_part(outscat),real_part(outcorr)+real_part(outscat),thick=thick
        endif
        plots,[0,0],yrange,linestyle=1,thick=thick
        if (defined(charsize) and (not defined(xcharsize)) and (not defined(ycharsize))) then begin
          xcharsize=charsize
          ycharsize=charsize
        endif
        plot,outtime,imaginary(outcorr),xtitle='Time delay(microsec)',xstyle=1,xrange=trange,$
           ystyle=1,yrange=yrange,ytitle=ytitle+' (Imag)',psym=psym,$
           title=title,/noerase,pos=pos_imag,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
           xcharsize=xcharsize,ycharsize=ycharsize
        if ((yrange(1) gt 0) and (yrange(0) lt 0)) then begin
          plots,trange,[0,0],linestyle=0,/data,thick=thick
        endif
        if (not keyword_set(noerror)) then begin
          errplot,outtime,imaginary(outcorr)-imaginary(outscat),imaginary(outcorr)+imaginary(outscat),thick=thick
        endif
        plots,[0,0],yrange,linestyle=1,thick=thick
      endelse
    endif else begin
      if ((keyword_set(complex_data) and not keyword_set(autocorrelation_flag))) then begin
        errormess = 'Cannot overplot complex correlations.'
        if (not keyword_set(silent)) then print,errormess
        return
      endif
      oplot,outtime,outcorr,psym=psym,thick=thick
    endelse
  endif  ; plot_correlation


    outfreq_plot = outfreq
    xtitle = 'Frequency [Hz]'
    frange_plot = frange

    if (keyword_set(khz)) then begin
      outfreq_plot = outfreq/1e3
      xtitle = 'Frequency [kHz]'
      frange_plot = frange/1e3
    endif

    if (keyword_set(mhz)) then begin
      outfreq_plot = outfreq/1e6
      xtitle = 'Frequency [MHz]'
      frange_plot = frange/1e6
    endif

  if (keyword_set(plot_spectra)) then begin
    if (defined(yrange)) then begin
      if (n_elements(yrange) ge 2) then begin
        yrange_power = yrange[0:1]
      endif
      if (n_elements(yrange) ge 4) then begin
        yrange_phase = yrange[2:3]
      endif
    endif
    if (not keyword_set(title)) then begin
      if (keyword_set(norm)) then begin
        default,title,['Coherency','Crossphase']
      endif else begin
        default,title,['Power','Crossphase']
      endelse
    endif

    if (n_elements(title) lt 2) then title = [title,title]
    if (defined(charsize) and (not defined(xcharsize)) and (not defined(ycharsize))) then begin
      xcharsize=charsize
      ycharsize=charsize
    endif
    plot,outfreq_plot,outpower,/noerase,pos=[pos[0],pos[1]+(pos[3]-pos[1])*0.6,pos[2],pos[3]],xrange=frange_plot,xstyle=1,title=title[0],psym=psym,$
       thick=thick,xthick=thick,ythick=thick,xcharsize=xcharsize,ycharsize=ycharsize,charsize=charsize,charthick=thick,xtitle=xtitle,ytype=ytype,xtype=xtype,yrange=yrange_power,ystyle=1
    if (not keyword_set(noerror)) then begin
      errplot,outfreq_plot,outpower-outpwscat,outpower+outpwscat,thick=thick
    endif
    if (keyword_set(norm) and keyword_set(plot_noiselevel)) then begin
      if (n_elements(crosspower_noiselevel) eq 1) then begin
        oplot,frange_plot,[crosspower_noiselevel,crosspower_noiselevel]*plot_noiselevel,thick=thick
      endif else begin
        oplot,outfreq_plot,crosspower_noiselevel*plot_noiselevel,thick=thick
      endelse
    endif
    if (defined(charsize) and (not defined(xcharsize)) and (not defined(ycharsize))) then begin
      xcharsize=charsize
      ycharsize=charsize
    endif
    plot,outfreq_plot,outphase/!pi,/noerase,pos=[pos[0],pos[1],pos[2],pos[1]+(pos[3]-pos[1])*0.4],xrange=frange_plot,xstyle=1,title=title[1],psym=psym,$
       thick=thick,xthick=thick,ythick=thick,xcharsize=xcharsize,ycharsize=ycharsize,charsize=charsize,charthick=thick,xtitle=xtitle,ytitle='[!7p!X]',xtype=xtype,yrange=yrange_phase,ystyle=1
  endif ; plot_spectra
  if (keyword_set(plot_power)) then begin
    if (not keyword_set(title)) then begin
      if (keyword_set(norm)) then begin
        default,title,['Coherency']
      endif else begin
        default,title,['Power']
      endelse
    endif
    default,yrange,[0,max(outpower+outpwscat)*1.05]
    default, linestyle,0
    if (defined(charsize) and (not defined(xcharsize)) and (not defined(ycharsize))) then begin
      xcharsize=charsize
      ycharsize=charsize
    endif
    plot,outfreq_plot,outpower,/noerase,pos=pos,xrange=frange_plot,xstyle=1,title=title,psym=psym,linestyle=linestyle,$
       thick=linethick,xthick=thick,ythick=thick,yrange=yrange,ystyle=1,xcharsize=xcharsize,ycharsize=ycharsize,charsize=charsize,charthick=thick,xtitle=xtitle,ytype=ytype,xtype=xtype
    if (not keyword_set(noerror)) then begin
      errplot,outfreq_plot,outpower-outpwscat,outpower+outpwscat,thick=thick
    endif

    if (keyword_set(plot_noiselevel)) then begin
      if (n_elements(crosspower_noiselevel) eq 1) then begin
        oplot,frange_plot,[crosspower_noiselevel,crosspower_noiselevel]*plot_noiselevel,thick=thick
      endif else begin
        oplot,outfreq_plot,crosspower_noiselevel*plot_noiselevel,thick=thick
      endelse
    endif
  endif ; plot_spectra
  if (keyword_set(plot_phase)) then begin
    default,title,'Phase'
    if (defined(charsize) and (not defined(xcharsize)) and (not defined(ycharsize))) then begin
      xcharsize=charsize
      ycharsize=charsize
    endif
    plot,outfreq_plot,outphase/!pi,/noerase,pos=pos,xrange=frange_plot,xstyle=1,title=title,psym=psym,charsize=charsize,$
       thick=thick,xthick=thick,ythick=thick,xcharsize=xcharsize,ycharsize=ycharsize,charthick=thick,xtitle=xtitle,ytitle='[!7p!X]',yrange=yrange
  endif ; plot_spectra


endif ; not set noplot


tres_orig=tres
return

err:
   if (not keyword_set(silent)) then print,'Error in FLUC_CORRELATION.PRO: '+!err_string
   errormess='Error in FLUC_CORRELATION.PRO: '+!err_string
   outcorr=0
   on_ioerror,NULL
   return
end


