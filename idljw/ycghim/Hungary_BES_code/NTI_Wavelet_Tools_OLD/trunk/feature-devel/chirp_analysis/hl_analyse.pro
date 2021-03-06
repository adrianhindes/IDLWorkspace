;**************************************************************************************************
;  Name: hl_analyse
;
;  Written by: Gergely PAPP and Laszlo HORVATH
;
;
; SHORT MANUAL
; ============
;
;  pro hl_analyse,shotnumber,channel1,channel2,$
;                   ID=ID,trange=trange,blocksize=blocksize,hann=hann,$
;                   charsize=charsize, thick=thick, charthick=charthick,$
;                   treshold=treshold,apsd_y_max=apsd_y_max,apsd_y_min=apsd_y_min,adaptive=adaptive,$
;                   data1=data1, data2=data2, timeax1=timeax1, timeax2=timeax2
;
;  The hl_analyse calculates the cross correlation function, the cross power spectral density function,
;  the coherence&phase function, the impulse-response function and the transfer function between two
;  data vectors, and also calculates the auto correlation function and the auto power spectral density
;  function for both data vectors. The results will be saved as .eps.
;     
;
; USAGE
; =====
;
;  The program needs a shotnumber and the names of the requested two channels. The data vectors will
;  be read by the program get_rawsignal. The results will be saved as .eps,
;  to ./data/HL_ANALYSE/'shotnumer'/'ID' with the following names:
;      ACF       -    auto correlation function
;      APSD      -    auto power spectral density
;      CCF       -    cross correlation function
;      COH       -    coherence&phase function
;      CPSD      -    cross power spectral density function
;      IMP       -    impulse-response function
;      RAW       -    raw signal
;      TRANSFER  -    transfer function
;
;
;   Arguements:
;   -----------
;  ID:          default value is systime
;  data1,2:     the two input vectors, if you give it manually
;  timeax1,2:   time axis
;  trange:      range of the time axis
;  blocksize:   the blockseize of windowing. Default value is: 256
;  
;
;
;   Switches:
;   ---------
;  hann  :   the default windowing type is the Hanning windowing. Boxcar can be enabled by typing hann=0
;  adaptive:
;  treshold:
;  sampling: you can use this, when timeax1 not equal with timeax2. The default setting is downsampling.
;            Upsampling can be enable by typing sampling=0
;
;   Print settings:
;   ---------
;  charsize: size of the characters, default value is 2
;  thick:    thickness of the plotting lines, default value is 3
;  charthick:thickness of the characters, default value is 3
;
;
; NEEDED PROGRAMS:
; ================
;
;  nti_wavelet_default.pro
;  defined.pro
;  gp_cohphasef.pro
;  nti_wavelet_i2str.pro
;  norm.pro
;  pg_initgraph.pro
;  pg_num2str.pro
;  pg_removestr.pro
;  pg_resample.pro
;  pg_retrigger.pro
;
;
; HISTORY:
; ========
; 
;  v 1.13: removed fmax=floor(max(f))
;  v 1.14: re-setting spcetral axes
;  v 1.15: re-setting retriggering and shifting, completed with "check time axes"
;  v 1.16: re-setting retriggering and shifting, re-setting print and file names

pro hl_analyse,shotnumber,channel1,channel2,$
                   ID=ID,trange=trange,blocksize=blocksize,hann=hann,sampling=sampling,$
                   charsize=charsize, thick=thick, charthick=charthick,$
                   treshold=treshold,apsd_y_max=apsd_y_max,apsd_y_min=apsd_y_min,adaptive=adaptive,$
                   data1=data1, data2=data2, timeax1=timeax1, timeax2=timeax2, $
		   imp = imp, timp = timp, ccf = ccf

version=2.0
prog='hl_analyse.pro'
if not keyword_set(ID) then ID=nti_wavelet_i2str(systime(1))

;SETTING DEFAULTS
;======================================================================================================

nti_wavelet_default,adaptive,1
nti_wavelet_default,hann,1
nti_wavelet_default,blocksize,256
nti_wavelet_default,treshold,0
nti_wavelet_default,apsd_y_max,10000
nti_wavelet_default,apsd_y_min,0.0001
nti_wavelet_default, channel1, 'channel1'
nti_wavelet_default, channel2, 'channel2'
nti_wavelet_default, sampling, 1


;setting default printing parameters
!P.MULTI=0
nti_wavelet_default, charsize, 2
nti_wavelet_default, thick, 3
nti_wavelet_default, charthick, 3

;DATA READING
;======================================================================================================


if not keyword_set(data1) then begin
get_rawsignal, shotnumber, channel1, timeax1, data1, trange=trange
get_rawsignal, shotnumber, channel2, timeax2, data2, trange=trange
endif else begin
   if not keyword_set(data2) then return
   if not keyword_set(timeax1) then return
   if not keyword_set(timeax2) then return
endelse

;CHECK TIME AXES
;======================================================================================================
;checking the length of the data vectors and timeax vectors
if NOT (n_elements(timeax1) EQ n_elements(data1)) then begin
print, 'Elements of timeax1 not equal with elements of data1!'
return
endif

if NOT (n_elements(timeax2) EQ n_elements(data2)) then begin
print, 'Elements of timeax2 not equal with elements of data2!'
return
endif

;checking the existence of common section of timeaxes
if  (timeax1(0) GT timeax2(n_elements(timeax2)-1)) OR $
    (timeax2(0) GT timeax1(n_elements(timeax1)-1)) then begin
    print, 'There is no common section of the timeaxes!'
    return
endif

;CREATIING DATA_TIME MATRIXES
;======================================================================================================

;stime1 and stime2 are the sampling time of the timeaxes
stime1=(timeax1((n_elements(timeax1)-1))-timeax1(0))/float((n_elements(timeax1)-1))
stime2=(timeax2((n_elements(timeax2)-1))-timeax2(0))/float((n_elements(timeax2)-1))


;create data_time matrixes
data_time_1=dblarr(n_elements(data1),2)
data_time_2=dblarr(n_elements(data2),2)

data_time_1[*,0]=data1
data_time_1[*,1]=timeax1
data_time_2[*,0]=data2
data_time_2[*,1]=timeax2


;CUT START OF DATA_TIME
;======================================================================================================

if (data_time_1[0,1] GT data_time_2[0,1]) then begin
  if (stime1 GT stime2) then begin
    ;____________________________________________________________________________
    ;this runs: when timeax1 is start after timeax2, and
    ;           sampletime of timeax1 is greather than sampletime of timeax2
    ;____________________________________________________________________________

    ;check where is the start of common sections of timeaxes:
    where=where(data_time_2[*,1] GT data_time_1[0,1])
    ;keep the last data_point before start of timeax1
    index=dindgen(n_elements(where)+1)
    index[0]=where[0]-1
    index[1:*]=where
    ;cut start of datatime
    data_time_2=data_time_2[index,*]
  
  endif else begin
    ;____________________________________________________________________________    
    ;    this runs: when timeax1 is start before timeax2, and
    ;               sampletime of timeax1 is lower or equal than sampletime of timeax2
    ;____________________________________________________________________________

    ;check where is the start of common sections of timeaxes:
    ;keep the first datapoint after start of timeax1
    ;cut start of data_time
    data_time_2=data_time_2[where(data_time_2[*,1] GT data_time_1[0,1]),*]
    
    ;timeax2(0)-timeax1(0) must be lower than stime1
    ;check where is the start of common sections of timeaxes:
    where=where(data_time_1[*,1] GT data_time_2[0,1])
    ;keep the last data_point before start of timeax2
    index=dindgen(n_elements(where)+1)
    index[0]=where[0]-1
    index[1:*]=where
    ;cut start of datatime
    data_time_1=data_time_1[index,*]

  endelse
endif else begin
if (data_time_1[0,1] LT data_time_2[0,1]) then begin
  if (stime1 GT stime2) then begin
    ;____________________________________________________________________________
    ;this runs: when timeax1 is start after timeax2, and
    ;           sampletime of timeax1 is greather than sampletime of timeax2
    ;____________________________________________________________________________

    data_time_1=data_time_1[where(data_time_1[*,1] GT data_time_2[0,1]),*]

    ;timeax1(0)-timeax2(0) must be lower than stime2
    ;check where is the start of common sections of timeaxes:
    where=where(data_time_2[*,1] GT data_time_1[0,1])
    ;keep the last data_point before start of timeax1
    index=dindgen(n_elements(where)+1)
    index[0]=where[0]-1
    index[1:*]=where
    ;cut start of datatime
    data_time_2=data_time_2[index,*]

  endif else begin
    ;____________________________________________________________________________
    ;this runs: when timeax1 is start after timeax2, and
    ;           sampletime of timeax1 is lower or equal than sampletime of timeax2
    ;____________________________________________________________________________

    ;check where is the start of common sections of timeaxes:
    where=where(data_time_1[*,1] GT data_time_2[0,1])
    ;keep the last data_point before start of timeax2
    index=dindgen(n_elements(where)+1)
    index[0]=where[0]-1
    index[1:*]=where
    ;cut start of datatime
    data_time_1=data_time_1[index,*]

  endelse
endif
endelse

;cut end of data_time
if (data_time_1[n_elements(data_time_1[*,1])-1,1] GE (data_time_2[n_elements(data_time_2[*,1])-1,1]+10)) then begin
    where2=where(data_time_1[*,1] LT data_time_2[n_elements(data_time_2[*,1])-1,1])
    index2=dindgen(n_elements(where2)+5)
    index2[0:(n_elements(where2)-1)]=where2
    index2[(n_elements(where2)):*]=dindgen(5)+(n_elements(where2)-1)
    data_time_1=data_time_1[index,*]

endif else begin
  if (data_time_2[n_elements(data_time_2[*,1])-1,1] GE (data_time_1[n_elements(data_time_1[*,1])-1,1]+10)) then begin
    where2=where(data_time_2[*,1] LT data_time_1[n_elements(data_time_1[*,1])-1,1])
    index2=dindgen(n_elements(where2)+5)
    index2[0:(n_elements(where2)-1)]=where2
    index2[(n_elements(where2)):*]=dindgen(5)+(n_elements(where2)-1)
    data_time_2=data_time_2[index,*]
  endif
endelse

;;retriggering and resampling
;if (stime1 LE stime2) then begin
;  shift=data_time_2[0,1]-data_time_1[0,1]
;  data_time_1[*,0]=pg_retrigger(data_time_1[*,0],shift)
;  data_time_1[*,1]=data_time_1[*,1]+shift
;endif else begin
;  shift=data_time_1[0,1]-data_time_2[0,1]
; data_time_2[*,0]=pg_retrigger(data_time_2[*,0],shift)
;  data_time_2[*,1]=data_time_2[*,1]+shift
;endelse

;RETRIGGERING AND SHIFTING IF TIMEAXES ARE NOT THE SAME
;======================================================================================================

;if NOT (norm(timeax1-timeax2) EQ 0) then begin
;  print,'Time axes are not equivalent, difference is '+pg_num2str(norm(timeax1-timeax2))
;
;  stime1=(timeax1((n_elements(timeax1)-1))-timeax1(0))/float((n_elements(timeax1)-1))
;  stime2=(timeax2((n_elements(timeax2)-1))-timeax2(0))/float((n_elements(timeax2)-1))
;  ;stime1 and stime2 are the sampling time of the timeaxes
;  ;float??? jó így???
;
;  sampl=sampling EQ (stime1 GE stime2)
;  ;if sampl equal to 1 channel2 will be retriggered and resampled
;  ;if sampl equal to 0 channel1 will be retriggered and resampled
;    
;    if (sampl) then begin
;        print,'Retriggering and resampling channel2...'
;        timesize=n_elements(timeax1)
;        stime=timeax2(1)-timeax2(0) ;stime1,2 -hez hasonlóan???
;        shift=(timeax2(0)-timeax1(0))/stime
;        data2=pg_retrigger(data2,shift)
;        data2=pg_resample(data2,timesize)
;        timeax=timeax1
        n_points=n_elements(timeax1)
;    endif else begin
;        print,'Retriggering and resampling channel1...'
;        timesize=n_elements(timeax2)
;        stime=timeax1(1)-timeax1(0) ;stime1,2 -hez hasonlóan???
;        shift=(timeax1(0)-timeax2(0))/stime
;        data1=pg_retrigger(data1,shift)
;        data1=pg_resample(data1,timesize)
;        timeax=timeax2
;        n_points=n_elements(timeax2)
;    endelse
;endif else begin
  timeax=timeax1
;  n_points=n_elements(timeax1)
;endelse

;setting frequency axis
;------------------------------------------------------------------------------------------------------
f=findgen(floor(blocksize/2.)+1)
f=f/max(f)
fn=(1/(timeax[2]-timeax[1])/2.)
faxis=f*fn/1000
maxf=max(faxis)

;creating coherence matrix for coherence multiplots
coh_matrix=dblarr(blocksize,2,2)
meancoh=dblarr(blocksize)

;DATA CALCULATION AND PRINTING
;======================================================================================================
print,'Calculating functions:'

    ;calculating spectra with external function gp_cohphasef
    c=gp_cohphasef(data1,data2,blocksize,meanapsd1=meanapsd1,meanapsd2=meanapsd2,meancpsd=meancpsd,hann=hann)
    
    if adaptive then begin
       apsd_y_max=max([max(meanapsd1),max(meanapsd2),max(abs(meancpsd[0:blocksize/2-1]))])
       apsd_y_min=min([min(meanapsd1[round(2.*blocksize/3):blocksize-1]),min(meanapsd2[round(2.*blocksize/3):blocksize-1]),$
                       min(abs(meancpsd[round(2*(blocksize/2-1)/3):blocksize/2-1]))])
    endif
    
    ;initializing
    transfer=complexarr(n_elements(meancpsd))
    transfer_b=transfer
    phase=dblarr(n_elements(meancpsd))
    
    ;calculating functions from the spectra
    ;------------------------------------------------------------
    for k=0., n_elements(meancpsd)-1 do begin
      transfer(k)=meancpsd(k)/meanapsd1(k)
      transfer_b(k)=meancpsd(k)/meanapsd2(k)
      if (meanapsd1(k) LT treshold or (meancpsd(k) LT treshold)) then transfer(k)=0
      phase(k)=atan(imaginary(transfer(k)),float(transfer(k)))
    endfor
    
    ;setting ccf the same parameters as meancpsd
    ccf=meancpsd
    
    ;calculating coherence and phase
    coh=c[*,0]
    for index=0.,n_elements(coh)-1 do begin
      if ((meanapsd1(index) LT treshold) or (meanapsd2(index) LT treshold) or (meancpsd(index) LT treshold)) then coh(index)=0
    endfor
    phase2=c[*,1]
    
    impulse_response2=FFT(transfer)
    impulse_response=shift(impulse_response2,floor(n_elements(transfer)/2)-1)
    
    impulse_response2_b=FFT(transfer_b)
    impulse_response_b=shift(impulse_response2_b,floor(n_elements(transfer_b)/2)-1)

    
    timp=lindgen(blocksize)-ceil(blocksize/2.)+1
    timp=timp*(timeax[2]-timeax[1])*1000

;calculating correlation functions with Fourier-technique

    ccf2=float(FFT(meancpsd))
    ccf=shift(ccf2,floor(n_elements(meancpsd)/2)-1)
    acf12=float(FFT(meanapsd1))
    acf1=shift(acf12,floor(n_elements(meanapsd1)/2)-1)
    acf22=float(FFT(meanapsd2))
    acf2=shift(acf22,floor(n_elements(meanapsd2)/2)-1)
   
    factor=sqrt(max(acf1)*max(acf2))
    
    for c=0.,n_elements(ccf)-1 do begin
        ccf(c)=ccf(c)/float(factor(0))
    endfor
   
    acf1=acf1/max(acf1)
    acf2=acf2/max(acf2)
    
    ;initializing print
    pg_initgraph, /print
    !P.FONT = 0
    
    ;setting print and paths
    ;------------------------------------------------------------
    types=['TRANSFER','COH','CCF','IMP','APSD','ACF','CPSD','RAW']
    print,types
    types=types+'_'
    fname=strarr(n_elements(types))
    titles=fname
    name_common=fname
    name_common=types+ID+'_'+pg_num2str(shotnumber)+'_'
    name1=channel1+'_'
    name2=channel2+'_'
    if keyword_set(trange) then begin
       tstart=trange[0]
       tend=trange[1]
    endif else begin
       tstart=min(timeax)
       tend=max(timeax)
    endelse
    name_time='time_'+pg_num2str(tstart,length=6)+'-'+pg_num2str(tend,length=6)
    name=name_common+name1+name2+name_time
    
    if hann EQ 0 then name=name+'_boxcar_'
    
    path='./data/HL_ANALYSE/'
    file_mkdir,path
    path=path+pg_num2str(shotnumber)+'/'
    file_mkdir,path
    path=path+ID+'/'
    file_mkdir,path
      
    for i=0,n_elements(types)-1 do fname(i)=path+pg_removestr(name(i))+'.eps'
    titles=name_common+name_time
         
    datas='shot:   '+pg_num2str(shotnumber,length=5)+'  N: '+nti_wavelet_i2str(n_points)+'  Blocksize: '+nti_wavelet_i2str(blocksize)+$
          '!CCh1:    '+channel1+$
          '!CCh2:    '+channel2+$
          '!Ctrange: '+pg_num2str(tstart,length=6)+' s - '+$
          pg_num2str(tend,length=6)+' s'
          
    datas1='shot:   '+pg_num2str(shotnumber,length=5)+'  N: '+nti_wavelet_i2str(n_points)+'  Blocksize: '+nti_wavelet_i2str(blocksize)+$
          '!CCh:    '+channel1+$
          '!Ctrange: '+pg_num2str(tstart,length=6)+' s - '+$
          pg_num2str(tend,length=6)+' s'     
          
    datas2='shot:   '+pg_num2str(shotnumber,length=5)+'  N: '+nti_wavelet_i2str(n_points)+'  Blocksize: '+nti_wavelet_i2str(blocksize)+$
          '!CCh:    '+channel2+$
          '!Ctrange: '+pg_num2str(tstart,length=6)+' s - '+$
          pg_num2str(tend,length=6)+' s' 
              
    datas_prog='ID:    '+ID+$
           '!CProg: '+prog+$
           '!CVer.:  '+pg_num2str(version,length=4)+$
           '!CDate: '+systime()

    

    ;PLOTTING CROSS FUNCTIONS
    ;-------------------------------------------------------------------------------
    ;transfer function
    device, filename=fname(0);+'transfer.eps'
    !P.MULTI=[0, 1, 2]
    plot, faxis, abs(transfer[0:blocksize/2-1]), charsize=charsize, thick=thick, charthick=charthick, title=titles(0), xtitle='Frequency [kHz]',xrange=[min(faxis),maxf], xstyle=1
    plot, faxis, phase, charsize=charsize, thick=thick, charthick=charthick,title='H_phase', xtitle='Frequency [kHz]',xrange=[min(faxis),maxf], xstyle=1
    xyouts,0.99,0.12,datas,/normal,orientation=90,charsize=1.3,charthick=2
    xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
    device, /close
    !P.MULTI=0
    
    ;Cross power spectral density function
    device, filename=fname(6);+'cpsd.eps'
    !P.MULTI=[0, 1, 2]
    plot, /YLOG, faxis, abs(meancpsd[0:blocksize/2-1]), charsize=charsize, thick=thick, charthick=charthick, $
          title=titles(6), xtitle='Frequency [kHz]', yrange=[apsd_y_min,apsd_y_max],xrange=[min(faxis),maxf], xstyle=1
    plot, faxis, phase, charsize=charsize, thick=thick, charthick=charthick,title='meancpsd_phase', xtitle='Frequency [kHz]',xrange=[min(faxis),maxf], xstyle=1, ystyle=1
    xyouts,0.99,0.12,datas,/normal,orientation=90,charsize=1.3,charthick=2
    xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
    device, /close
    !P.MULTI=0
    
    ;coherence&phase functions
    device, filename=fname(1);+'coh-phase.eps'
    !P.MULTI=[0, 1, 2]
    plot, faxis, coh[0:blocksize/2-1], charsize=charsize, thick=thick, charthick=charthick, title=titles(1), xtitle='Frequency [kHz]', yrange=[0,1],xrange=[min(faxis),maxf], xstyle=1
    plot, faxis, phase2, charsize=charsize, thick=thick, charthick=charthick, title='PHASE', xtitle='Frequency [kHz]',xrange=[min(faxis),maxf], xstyle=1
    xyouts,0.99,0.12,datas,/normal,orientation=90,charsize=1.3,charthick=2
    xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
    !P.MULTI=0
    device, /close
    
    
    if n_elements(ccf) EQ n_elements(acf1) then begin
    ;cross correlation function
    device,filename=fname(2);+'ccf.eps'
    plot,  timp, ccf, charsize=charsize, thick=thick, charthick=charthick,title=titles(2), xtitle='Time delay (ms)', xstyle=1
    xyouts,0.99,0.12,datas,/normal,orientation=90,charsize=1.3,charthick=2
    xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
    device, /close
    endif
    
    ;impulse-response function
    device, filename=fname(3);+'impulse-response.eps'
    plot,  timp, impulse_response, charsize=charsize, thick=thick, charthick=charthick,title=titles(3), xtitle='Time delay (ms)', xstyle=1
    xyouts,0.99,0.12,datas,/normal,orientation=90,charsize=1.3,charthick=2
    xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
    device,/close
    
    ;PLOTTING AUTO FUNCTIONS
    ;===================================================================================
    ;auto power spectral density function
       device, filename=path+name_common(4)+pg_removestr(name1)+name_time+'.eps' ;+'apsd.eps'
       plot, /YLOG, faxis, meanapsd1, charsize=charsize, thick=thick, charthick=charthick, title=titles(4), $
             xtitle='Frequency [kHz]', ytitle='[W^2*s/m^4]', yrange=[apsd_y_min,apsd_y_max],xrange=[min(faxis),maxf], xstyle=1, ystyle=1
       xyouts,0.99,0.12,datas1,/normal,orientation=90,charsize=1.3,charthick=2
       xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
       device,/close

       device, filename=path+name_common(4)+pg_removestr(name2)+name_time+'.eps' ;+'apsd.eps'
       plot, /YLOG, faxis, meanapsd2, charsize=charsize, thick=thick, charthick=charthick, title=titles(4), $
             xtitle='Frequency [kHz]', ytitle='[W^2*s/m^4]', yrange=[apsd_y_min,apsd_y_max],xrange=[min(faxis),maxf], xstyle=1, ystyle=1
       xyouts,0.99,0.12,datas2,/normal,orientation=90,charsize=1.3,charthick=2
       xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
       device,/close
    
    ;auto correlation function
       device,filename=path+name_common(5)+pg_removestr(name1)+name_time+'.eps' ;+'acf.eps'
       plot,  timp, acf1, charsize=charsize, thick=thick, charthick=charthick,title=titles(5), xtitle='Time delay (ms)', xstyle=1
       xyouts,0.99,0.12,datas1,/normal,orientation=90,charsize=1.3,charthick=2
       xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2      
       device, /close

       device,filename=path+name_common(5)+pg_removestr(name2)+name_time+'.eps' ;+'acf.eps'
       plot,  timp, acf2, charsize=charsize, thick=thick, charthick=charthick,title=titles(5), xtitle='Time delay (ms)', xstyle=1
       xyouts,0.99,0.12,datas2,/normal,orientation=90,charsize=1.3,charthick=2
       xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2       
       device, /close
    
    ;raw signal
       device,filename=path+name_common(7)+pg_removestr(name1)+name_time+'.eps' ;+'raw.eps'
       plot,  timeax, data1, charsize=charsize, thick=thick, charthick=charthick,title=titles(7), xtitle='Time (s)', $
              ytitle='Intensity (W/m^2)', yrange=[min(data1),max(data1)], xrange=[min(timeax),max(timeax)], xstyle=1
       xyouts,0.99,0.12,datas1,/normal,orientation=90,charsize=1.3,charthick=2
       xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2       
       device, /close
    
       device,filename=path+name_common(7)+pg_removestr(name2)+name_time+'.eps' ;+'raw.eps'
       plot,  timeax, data2, charsize=charsize, thick=thick, charthick=charthick,title=titles(7), xtitle='Time (s)', $
              ytitle='Intensity (W/m^2)', yrange=[min(data2),max(data2)], xrange=[min(timeax),max(timeax)], xstyle=1
       xyouts,0.99,0.12,datas2,/normal,orientation=90,charsize=1.3,charthick=2
       xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2       
       device, /close


;restoring printing parameters
pg_initgraph
!P.FONT = -1

print, 'Data saved to folder '+path

timp = timp
imp = impulse_response
ccf = ccf

end