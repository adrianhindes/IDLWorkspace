pro freq_fluct, fixdata, fixtimeax, fixblocksize, height=height,$
    plot_apsd=plot_apsd, hun=hun, sigma=sigma, width=width, plot_peak=plot_peak

data=double(fixdata)
timeax=double(fixtimeax)
blocksize=long(fixblocksize)

;SETTING DEFAULTS
;================

default,hun,0
default,height,0.5
default,plot_apsd,0
<<<<<<< .mine
default,plot_peak,0
=======
default,sigma,0
>>>>>>> .r317

;SET LANGUAGE OF PLOTS
;=====================

  ;HUN
  ;----------
  if hun then begin

  title='Auto-spektrum'
  xtitle='Frekvencia [kHz]'
  ytitle='['+string(byte("366B))+'.e]'
  xyouts_date='D'+string(byte("341B))+'tum'
  peak_title='Auto-spektrum csúcsa'
  peak_xtitle='Frekvencia [kHz]'
  peak_ytitle='['+string(byte("366B))+'.e]'

endif else begin

  ;EN
  ;----------
  title='APSD'
  xtitle='Frequency [kHz]'
  ytitle='[a.u]'
  xyouts_date='Date'
  peak_title='Peak of APSD'
  peak_xtitle='Frequency [kHz]'
  peak_ytitle='[a.u]'

endelse

;CREATE FREQUENCY AXIS
;=====================

    ;sampletime of data vector:
    stime=(timeax[n_elements(timeax)-1]-timeax[0])/double(n_elements(timeax)-1)
    ;Nyquits-frequency:
    nfreq=1/(2*stime)

    ;create frequency axis:
    freqax=dindgen(floor(blocksize/2.)+1)
    freqax=freqax/max(freqax)
    freqax=freqax*nfreq/1000;kHz

;CALCULATE APSD
;==============

    ;calculate number of blocks:
    blockn=long(2*floor((n_elements(data)/blocksize))-1)
    ;initializing vector of APSD:
    APSD=dblarr(blockn,blocksize)

  ;calculate APSD of blocks
  ;------------------------
    for i=0L, blockn-1 do begin
      F=FFT(HANNING(blocksize)*(data[i*blocksize/2:(i+2)*blocksize/2-1]-mean(data[i*blocksize/2:(i+2)*blocksize/2-1])),-1)
      APSD[i,*]=conj(F)*F
    endfor

  ;Calculate mean of APSD functions of the blocks
  ;----------------------------------------------
    ;initializing vector of the mean of APSDs:
    meanapsd=dblarr(blocksize)
    ;calculate mean of APSDs:
    for i=0L,blocksize-1 do begin
      meanapsd(i)=mean(APSD(*,i))
    endfor


;CALCULATE FREQUENCY FLUCTUATION
;===============================

    ;Copy APSD vector:
    fapsd=meanapsd[0:floor(blocksize/2)]
    ;Calculate the point of the maxima:
    fapsd_maxp=where(fapsd EQ max(fapsd))
      if n_elements(fapsd_maxp) NE 1 then begin
	print,'ERROR: The function have two or more maxima!'
	return
      endif 
    fapsd_maxp=long(fapsd_maxp[0])
    ;Calculate the maxima of APSD:
    fapsd_max=fapsd[fapsd_maxp]

  ;Interpolating to the APSD near to the maxima
  ;--------------------------------------------
    ;Find the range of interpolating:
    x=fapsd-height*fapsd_max ;height: where we calculate the width of the peak.
    range=5*abs(where(abs(x) EQ min(abs(x)))-fapsd_maxp)
    range=long(range[0])

    ;Interpolating - fitting a cubic spline (http://en.wikipedia.org/wiki/Interpolate#Spline_interpolation):
    ;Cut the observed section of the APSD:
    itpdata=fapsd[fapsd_maxp-range:fapsd_maxp+range]
    ;Initialize the ax of the interpolated section:
    itpax=freqax[fapsd_maxp-range:fapsd_maxp+range]
    ax=(dindgen(1000*range+1)/(1000*range))*(itpax[2*range]-itpax[0])+itpax[0]
    ;Interpolating:
    itp=interpol(itpdata,1000*range+1,/spline)

    ;The point of the APSD's maxima at the interpolated function:
    itp_maxp=500*range

  ;Find the width of the peak
  ;--------------------------------------------
    ;Find the start of the peak:
    itp1=itp[0:500*range]
    start=where(min(abs(itp1-0.5*fapsd_max)) EQ abs (itp1-0.5*fapsd_max))
      if n_elements(start) NE 1 then begin
	print,'ERROR: Find two point for start of the peak!'
	return
      endif
    start=long(start[0])

    ;Find the end of the peak:
    itp2=itp[500*range+1:1000*range]
    finish=where(min(abs(itp2-0.5*fapsd_max)) EQ abs (itp2-0.5*fapsd_max))
      if n_elements(finish) NE 1 then begin
	print,'ERROR: Find two point for end of the peak!'
	return
      endif
    finish=long(finish[0])+500*range

    ;The width of the peaks in kHz
    width=ax[finish]-ax[start]
    width_str=pg_num2str(width,length=5)+'kHz'

;PLOT RESULTS
;============

  ;Setting output names:
  ;---------------------
    ;setting path of output:
      ;read date:
      date=bin_date(systime())
      date=i2str(date[0])+'-'+i2str(date[1])+'-'+i2str(date[2])
    path='./bicoherence_data/apsd/'+date+'/'
    ;create path:
    file_mkdir,path
  
    ;setting name of output:
    name_apsd='apsd-'+i2str(systime(1))+'-bs:-'+pg_num2str(blocksize)+'.eps'
    name_peak='peak-'+i2str(systime(1))+'-bs:-'+pg_num2str(blocksize)+'-sigma:-'+pg_num2str(sigma)+'-fluct:-'+width_str+'.eps'

  ;Setting printing parameters:
  ;----------------------------
    pg_initgraph,/print
    device,bits_per_pixel=8,font_size=8,/portrait,/color,/encapsulated,/bold,/cmyk,/preview,/times

    tvlct, 255,0,0,100 
    tvlct, 0,0,255,101

  ;Plot APSD
  ;---------
  if plot_apsd then begin
    device, filename=path+name_apsd
    plot, /YLOG, freqax, meanapsd,$
      title=title, xtitle=xtitle, ytitle=ytitle,$	;titles
      xmargin=[10,16], ymargin=[5,3],$	;placement of graph
      charsize=2, xthick=3, ythick=3, charthick=3, xstyle=1, ystyle=1,xticklen=-0.01, yticklen=-0.01	;style

    ;initialize xyouts:
    info=xyouts_date+': '+systime()+$
	'!Cxyouts!'
    ;print xyouts:
    xyouts,0.83,0.10,info,/normal,orientation=90,charsize=1.4,charthick=1.8

  ;Restoring printing parameters:
  ;------------------------------
    device,/close
  endif

  ;Plot peak
  ;---------

  if plot_peak then begin
    device, filename=path+name_peak

    plot,freqax,fapsd,xrange=[freqax[fapsd_maxp-2*range],freqax[fapsd_maxp+2*range]],$
      title=peak_title, xtitle=peak_xtitle, ytitle=peak_ytitle,$	;titles
      xmargin=[10,16], ymargin=[5,3],$	;placement of graph
      charsize=2, xthick=3, ythick=3, charthick=3, xstyle=1, ystyle=1,xticklen=-0.01, yticklen=-0.01,psym=7	;style

    ;plot interpolation:
      oplot,ax,itp,psym=3,color=100
    ;plot width:
      oplot,[ax[start],ax[start]],[0,fapsd_max],color=101
      oplot,[ax[finish],ax[finish]],[0,fapsd_max],color=101
    ;plot half of peak:
      oplot,[freqax[fapsd_maxp-2*range],freqax[fapsd_maxp+2*range]],[0.5*fapsd_max,0.5*fapsd_max],color=101
    ;plot width of peak:
      xyouts,0.52,0.83,width_str,/normal,charsize=2.7,charthick=5.5


    device,/close
  endif

  ;Restoring printing parameters:
  ;------------------------------
    pg_initgraph

end
