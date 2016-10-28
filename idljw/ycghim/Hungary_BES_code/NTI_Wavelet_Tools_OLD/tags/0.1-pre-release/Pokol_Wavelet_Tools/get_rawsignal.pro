pro get_rawsignal,shot,full_signal_in,time,data,errorproc=errorproc,errormess=errormess,$
         data_source=data_source,afs=afs,cdrom=cdrom,trange=trange,data_names=data_names,$
         nocalibrate=nocalibrate,calfac=calfac,sampletime=sampletime,equidist=equidist,$
         no_shift_correct=no_shift_correct,$
         correction_method=correction_method,p2_points=p2_points,$
         datapath=datapath,filename=filename,nodata=nodata,$
         subchannel=subchannel,$
         vertical_norm=vertical_norm,vertical_zero=vertical_zero,$
         savedata=savedata,movedata=movedata ;P.G. 2008.02.07

; ************* get_rawsignal.pro ********************** S. Zoletnik *** 1.4.1998
; This is the general routine for reading (calibrated) data from different data source
; If a new data source is added, this routine (and meas_config.pro) should be modified.
; To get a list of available data sources call:
; get_rawsignal,data_names=names
; After return <names> containes a string array, each string is the name of the
; associated data source.
; INPUT:
;  shot: shot number
;  signal: [<data source>/]<signal name> or channel number
;       <data_source> is any of the names returned in data_names. This overrides the
;          data_source input
;           Signal names for Li channels:   Li-xx
;           Signal names for Mirnov channels: Mir-<m>-<ch>  <m>: module  <ch>: channel
;  !!  Will return full signal name string (e.g. W7-AS Nicolet/Li-1) !!!!
;  errorproc: name of error processing routine to call on error
;  data_source:  0 --> W7-AS Nicolet system (see meas_config.pro)
;                1 --> W7-AS Aurora system
;                2 --> W7-AS standard Li-beam data acquisition
;                3 --> AUG standard Li-beam data acquisition
;                4 --> W7-AS Mirnov system /Pokol G. changed to call mag_alldat_o_papp
;                5 --> AUG Nicolet data (Data taken with W7 Nicolet)
;                6 --> W7-AS CO2 laser scattering
;                7 --> TEXTOR Li-beam with LMS loggers
;                8 --> TEXTOR Blo-off-beam with LMS loggers
;                9 --> TEXTOR Li-beam for test shots
;               10 --> W7-AS Blo-off-beam (diagn.: VUV,module: Juelich 1-4, channel: 1,2
;               11 --> JET Li-beam channels measured in CATS
;               12 --> Numerical tests, simulated light signals
;               13 --> Signals measured with NI6115 system
;               14 --> W7-AS ECE signals (saved from eaus and read through read_ece.pro
;               15 --> JET KK3 ECE system (through MDS+)
;               16 --> General interface for signals in IDL save file
;                        File name: <shot><signal name>.sav
;                        Contents:  data: data array
;                                   sampletime: sample time in sec
;                                   starttime: start time in sec
;               17 --> CASTOR data. Channel name is system-channel
;               18 --> MT-1M data: Channel name is system-channel
;               19 --> TEXTOR web umbrella access
;               20 --> TEXTOR supersonic He beam   /D. D.  2005. 06.13.
;               21 --> NI-6115 Test Measurements   / D. D. 2005. 10. 10.
;               22 --> AUG Mirnov diagnostocs      /K. G. 2005.11.14, P.G. 2008.02.07
;               23 --> MAST data through read_data.pro  /Z.S. 2006.01.10
;		24 --> AUG SXR diagnostics /M.A. 2010.07.21
;		25 --> AUG ECE diagnostics
;               26 --> AUG FILD diagnostics /M.A. 2010.08.14
; 
;  /afs: get data from afs system instead of data/ dir.
;  trange: time range in sec (default: get all data)
;  /nocalibrate: do not calibrate signal (e.g. relative calibaration of Li channels)
;  calfac: calibration factors (optional)
;  /cdrom: get Nicolet data from cdrom (dir cdrom/...)
;  /equidist: accept only equidistantly measured signals (except for subchannels)
;  /nodata: don't read data, just test signal availability and return
;  subchannel: Subchannel in deflected Li-beam measurements (0: all signal,
;      1... a subchannel
;  vertical_norm: Vertical scale in wftread
;  vertical_zero: Vertical offset in wftread
;  filename: Name of the datafile (only for 6 and 13)
;  *** Keywords only for CO_2 laser scattering signals ***
;  /no_shift_correct: Do not apply time shift correction for the shift introduced by the hardware
;  correction_method: Time shift correction method
;  p2_points: use only power of two number of points
;  datapath: Path for the datafile
;  savedata (1 or 0): Save data to file, default: 1
;  movedata (string): Move data to the specified address through scp
; OUTPUT:
;  time: time vector
;  data: data vector
;  data_names: available data sources (data_names(data_source) is the name of
;              the actual data source
;  sampletime: time resolution of signal in sec
;  signal: the full name of the signal
;
;  Procedure to include new data sources:
;   1. Select a data source number and include name of new data source
;      above in this comment block.
;   2. Include the new name in the data_names array below.
;   3. Update meas_config.pro for handling the new source
;   4. Include a block in this routine:
;      if (data_source eq xxx) then begin
;       ...
;      endif
;        where xxx is the data source number.
;******************************************************************************

errormess=''

data_names=['W7-AS Nicolet',$
            'W7-AS Aurora',$
            'W7-AS Li-standard',$
            'AUG Li-standard',$
            'W7-AS Mirnov',$
            'AUG Nicolet',$
            'W7-AS Lscat',$
            'TEXTOR Li-beam',$
            'TEXTOR Blow-off',$
            'TEXTOR Li-beam test',$
            'W7-AS Blow-off',$
            'JET Li-beam',$
            'Numtest',$
            'NI6115',$
            'W7-AS ECE',$
            'JET KK3 ECE',$
            'General',$
            'CASTOR',$
            'MT-1M',$
            'TEXTOR',$
            'TEXTOR-HE',$
            'NI-6115 TEST',$
            'AUG_mirnov',$
            'MAST',$
	    'AUG_SXR',$
	    'AUG_ECE',$
            'AUG_FILD']

forward_function default

default,shot,0
default,data_source,16      ; Nicolet at W7-AS
default,datapath,'data/'
default,savedata,1
default,movedata,''

forward_function strsplit
forward_function i2str
forward_function meas_config
forward_function getdata
forward_function flukfile

; Returning if signal name is not set
if (not keyword_set(full_signal_in)) then return

forward_function getcal

; Extracting system name from signal name if system name is present
if (strpos(full_signal_in,'/') gt 0) then begin ; if system is given in signal name
  w=str_sep(full_signal_in,'/')
  sysname=w(0)
  signal_in=w(1)
  if (n_elements(w) gt 2) then begin
    for i=2,n_elements(w)-1 do begin
      signal_in = signal_in+'/'+w[i]
    endfor
  endif
  sys=where(strupcase(sysname) eq strupcase(data_names))

  if (sys(0) lt 0) then begin
    errormess='Unknown system name ('+sysname+') found in total signal name: '+signal_in
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  data_source=sys(0)
endif else begin
  signal_in = full_signal_in
  sysname = data_names(data_source)
endelse

; If the signal name is only a number, it will be changed to a string
if ((data_source eq 8) or (data_source eq 10)) then begin
  if ((size(signal_in))(1) ne 7) then signal_in='Blo-'+i2str(signal_in) $
            else signal_in=string(signal_in)
endif else begin
  if (((data_source le 5) or (data_source eq 7) or (data_source eq 9) or (data_source eq 11)) and $
    ((size(signal_in))(1) ne 7)) then signal_in='Li-'+i2str(signal_in) $
              else signal_in=string(signal_in)
endelse
full_signal_in = sysname+'/'+signal_in

; Handling subchannels
default,subchannel,0
if ((data_source ne 0) and (subchannel ge 1)) then begin
  errormess='Subchannels are available only in deflected W7-AS Li-beam measurement'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  time=0
  data=0
  return
endif

; Reading data for W7-AS Nicolet
if (data_source eq 0) then begin
  r=meas_config(shot,data_source=0,subchannels=subchannels)

  if ((subchannel ge 1) and (subchannels le 1)) then begin
    errormess='Subchannels are not available in shot '+i2str(shot)+'. Not a deflected beam measurement.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    time=0
    data=0
    return
  endif

  if (subchannel gt subchannels) then begin
    errormess='Subchannel '+i2str(subchannel)+' is not available in shot '+i2str(shot)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    time=0
    data=0
    return
  endif

  ff=flukfile(shot,signal_in,afs=afs,cdrom=cdrom)
  if ((ff eq '???') or (ff eq '')) then begin
    errormess=signal_in+' not available.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    time=0
    data=0
    return
  endif

  full_signal_in = sysname+'/'+signal_in
  if (keyword_set(nodata)) then return

  if (subchannels le 1) then begin
    ; not a deflected shot
    wftread,ff,data,rc,time=time,trange=trange,fsample=fsample,ext_fsample=wftsamp(shot),vertical_norm=vertical_norm,vertical_zero=vertical_zero
    sampletime=1./fsample
    if ((strmid(signal_in,0,3) eq 'Li-') and (not keyword_set(nocalibrate))) then begin
      if (not keyword_set(calfac)) then calfac=getcal(shot,data_source=data_source,/silent)
      if ((size(calfac))(0) eq 0) then begin
        errormess='Cannot find calibration data for shot '+i2str(shot)
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data=0
        time=0
        return
      endif
      ch=fix(strmid(signal_in,3,strlen(signal_in)-3))
     data=data*calfac(ch-1)
    endif
  endif else begin ; deflected shot
    if (subchannels ne 2) then begin
      errormess='This version of the programs can handle only deflection to two positions'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif

    deflection_config,shot,period_time=period_time,period_n=period_n,$
     start_sample=start_sample,sampletime=sampletime,mask_down=mask_down,$
     mask_up=mask_up,starttime=starttime
    if (period_time eq 0) then begin
      errormess='Shot '+i2str(shot)+' is not deflected beam shot.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
       if (subchannel eq 0) then mask = findgen(period_n)
    if (subchannel eq 1) then mask=mask_down
    if (subchannel eq 2) then mask=mask_up
    default,trange,[starttime,starttime+10]
       trange=float(trange)
    if (trange[0] lt starttime) then trange[0] = starttime
       if (trange[0] ge trange[1]) then begin
      errormess='End of time interval is before start of measurement.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    start_period = long((trange(0)-starttime)/(period_time))
    end_period = long((trange(1)-starttime)/(period_time))
    start = long(start_period)*period_n+start_sample
    stop = (long(end_period)+1)*period_n+start_sample-1
    wftread,ff,data,rc,ext_fsample=1,pointn=stop+period_n+1,vertical_norm=vertical_norm,vertical_zero=vertical_zero
    if (n_elements(data) lt 2) then begin
      errormess='No data is available in specified time window.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif

       data=data[start:n_elements(data)-1]
    if (n_elements(data) ne stop-start+1) then $
      end_period = long(n_elements(data)/period_n)+start_period
    ind = lonarr((end_period-start_period+1)*n_elements(mask))
    ind1 = lindgen(end_period-start_period+1)*period_n
    ind2 = lindgen(end_period-start_period+1)*n_elements(mask)
    for i=0,n_elements(mask)-1 do ind(ind2+i) = ind1+mask(i)
    data = data(ind)
    time = fltarr((end_period-start_period+1)*n_elements(mask))
    ind1 = lindgen(end_period-start_period+1)
    for i=0,n_elements(mask)-1 do time(ind2+i) = double(starttime)+(start_period+ind1)*double(period_time)+mask(i)*sampletime
    if ((strmid(signal_in,0,3) eq 'Li-') and (not keyword_set(nocalibrate))) then begin
      if (not keyword_set(calfac)) then calfac=getcal(shot,data_source=data_source,/silent)
      if ((size(calfac))(0) eq 0) then begin
        errormess='Cannot find calibration data for shot '+i2str(shot)
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data=0
        time=0
        return
      endif
      ch=fix(strmid(signal_in,3,strlen(signal_in)-3))
     data=data*calfac(ch-1)
    endif

    return
  endelse ; deflected shot
endif


if (data_source eq 5) then begin
  ff=flukfile(shot,signal_in,afs=afs,cdrom=cdrom,data_source=data_source)
  if ((ff eq '???') or (ff eq '')) then begin
    errormess=signal_in+' not available.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    time=0
    data=0
    return
  endif
  if (keyword_set(nodata)) then return
  wftread,ff,data,rc,time=time,trange=trange,fsample=fsample,ext_fsample=wftsamp(shot),vertical_norm=vertical_norm,vertical_zero=vertical_zero
  sampletime=1./fsample
  data=-data
  if ((strmid(signal_in,0,3) eq 'Li-') and (not keyword_set(nocalibrate))) then begin
    if (not keyword_set(calfac)) then calfac=getcal(shot,data_source=data_source,/silent)
    if ((size(calfac))(0) eq 0) then begin
      errormess='Cannot find calibration data for AUG shot '+i2str(shot)
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    ch=fix(strmid(signal_in,3,strlen(signal_in)-3))
    data=data*calfac(ch-1)
    return
  endif
endif

if (data_source eq 1) then begin
  txt='No data_source=1 (W7-AS Aurora) is supported at present.'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,txt,/forward
  endif else begin
    print,txt
  endelse
  return
endif

if (data_source eq 2) then begin

openr, unit, 'data/'+i2str(shot)+'standard_li.sav', error=errli, /get_lun

  if  (errli EQ 0) then begin
    close, unit  & free_lun,unit
    restore, 'data/'+i2str(shot)+'standard_li.sav'

  endif else begin
    ; If no data were found in data/
    if ((strmid(signal_in,0,3) ne 'Li-') and  (strmid(signal_in,0,6)  ne 'Halpha') and $
          (strmid(signal_in,0,8) ne 'Pressure')) then begin
      txt='No signal_in '+signal_in+' in W7-AS Li-standard system.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,txt,/forward
      endif else begin
        print,txt
      endelse
      time=0
      data=0
      return
    endif

    if (strmid(getenv('HOST'),0,3) ne 'das') then begin
      txt='Libeam standard data are available only on das machines!'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,txt,/forward
      endif else begin
        print,txt
      endelse
      return
    endif
    if (keyword_set(nodata)) then return
    if (strmid(signal_in,0,3) eq 'Li-') then begin
      channel=fix(strmid(signal_in,3,strlen(signal_in)-3))
    endif else begin
      if (signal_in eq 'Pressure') then channel=29 else channel=30
    endelse
    pointn=15000
    if (not keyword_set(nosave)) then begin
      data_arr = fltarr(31,pointn)
      for i=1,30 do begin
        channel = i
        rawchannel,shot,'PELLET','LIB3',channel,pointn,data,time
        data_arr[i,*] = data
      endfor
      data_arr[0,*] = time
      save,data_arr,time,file=dir_f_name('data',i2str(shot)+'standard_li.sav')
    endif else begin
      rawchannel,shot,'PELLET','LIB3',channel,pointn,data,time
    endelse
    sampletime=round((time(1)-time(0))/1e-6)*1e-6
  endelse

r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list)
if (r ne 0) then begin
      txt='Error in meas_config.pro'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,txt,/forward
      endif else begin
        print,txt
      endelse
      time=0
      data=0
      return
endif

ind=where(signal_list eq signal_in)
get_rawsignal,data_names=syst_names
if (ind(0) lt 0) then begin
  txt='Signal '+ch_str+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,txt,/forward
      endif else begin
        print,txt
      endelse
      time=0
      data=0
      return
endif



    channel2read=fix(channel_list[ind[0]])

    time=data_arr[0,*]
    data=data_arr[channel2read,*]
    sampletime=time[1]-time[0]

    sigarr=str_sep(signal_in,'-')

; Now calibrating
  if ( (sigarr[0] eq 'Li') and (not keyword_set(nocalibrate))) then begin
    if (not keyword_set(calfac)) then calfac=getcal(shot,data_source=data_source,/silent)
    if ((size(calfac))(0) eq 0) then begin
      errormess='Cannot find calibration data for W7-AS shot '+i2str(shot)
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    ch=fix(strmid(signal_in,3,strlen(signal_in)-3))
    data=data*calfac(ch-1)
    return
  endif

endif

if (data_source eq 3) then begin
  if (strmid(signal_in,0,3) ne 'Li-') then begin
    txt='No signal_in '+signal_in+' in AUG Li-standard system.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,txt,/forward
    endif else begin
      print,txt
    endelse
    return
  endif
  chn=fix(strmid(signal_in,3,strlen(signal_in)-3))
  directory = 'data'
  file_name = directory+'/'+'AUG'+i2str(shot,digits=5) + '_time.sav'
  openr,unit,file_name,error=error,/get_lun
  if (error ne 0) then begin
    txt='Cannot open data file '+file_name
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,txt,/forward
    endif else begin
      print,txt
    endelse
    return
  endif else begin
    close,unit
    free_lun,unit
  endelse
  if (keyword_set(nodata)) then return
  restore,file_name
  time=signal_time
  file_name = directory+'/'+'AUG'+i2str(shot,digits=5) + '_' +i2str(chn,digits=2)+ '.sav'
  openr,unit,file_name,error=error,/get_lun
  if (error ne 0) then begin
    txt='Cannot open data file '+file_name
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,txt,/forward
    endif else begin
      print,txt
    endelse
    return
  endif else begin
    close,unit
    free_lun,unit
  endelse
  restore,file_name
  data=signal
  sampletime=round((time(1)-time(0))/1e-6)*1e-6
;  if (keyword_set(nocalibrate)) then begin
;    txt='Warning: Cannot get uncalibrated AUG data.'
;    if (keyword_set(errorproc)) then begin
;      call_procedure,errorproc,txt,/forward
;    endif else begin
;      print,txt
;    endelse
;  endif
endif

if (data_source eq 4) then begin    ; *** Mirnov data from W7-AS Mirnov system
  if (keyword_set(nodata)) then return
  w=str_sep(strupcase(signal_in),'-')
  modname=w(0)+'-'+w(1)
  buffname=datapath+'mir_'+i2str(shot,digits=5)+'_'+strupcase(modname)+'.sav'
  openr,unit,buffname,/get_lun,error=error
  if (error ne 0) then begin
    signames=1
    forward_function mag_alldat_o_papp
    r=mag_alldat_o_papp(data,shot,modname,/cal,signames=signames)
    save,data,shot,signames,file=buffname
  endif else begin
    close,unit
    free_lun,unit
    data=0 & shot=0 & signames=0
    restore,buffname
  endelse
  if (not keyword_set(data)) then begin
    errormess='Cannot load mirnov data.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  ind=(where(strupcase(signal_in) eq strupcase(signames)))(0)
  if (ind lt 0) then begin
    errormess='Cannot find signal '+signal_in+' in Mirnov module '+modname
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  time=data.tvec
  if (data.t_units eq 'MICROSECONDS') then time=time*1e-6
  sampletime=data.dt(0)*1e-6
  data=data.signals(*,ind)
endif

if (data_source eq 6) then begin    ; *** W7-AS CO2 laser scattering ***************
  if (keyword_set(nodata)) then return
  ch=fix(signal_in)
  read_qdm,shot,data,trange=trange,cdrom=cdrom,afs=afs,errormess=errormess,channel=ch,$
           time=time,hw=hw,$
           no_shift_correct=no_shift_correct,$
;           correction_method=correction_method,p2_points=p2_points,$
; For CO_2 scattering
           datapath=datapath,filename=filename
;
  if (errormess ne '') then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  data=float(data)
  sampletime=1./hw.f_sample*1e-6
endif

if (data_source eq 7) then begin  ; *************** TEXTOR Li-beam signal ***************
  r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list,$
    errortext=errormess,ext_fsample=ext_fsample,starttime=starttime,/silent)
  if (r ne 0) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  ind=where(signal_list eq signal_in)
  get_rawsignal,data_names=syst_names
  if (ind(0) lt 0) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+  $
           ' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(nodata)) then return
  ch = channel_list(ind(0))
  case ch of
    1: signal_name = 'LMSA1'
    2: signal_name = 'LMSA2'
    3: signal_name = 'LMSB1'
    4: signal_name = 'LMSB2'
    5: signal_name = 'LMSD1'
    6: signal_name = 'LMSD2'
  endcase
  retrievedata,shot,signal_name,1000000L,time,data,ok
  if (ok eq 0) then begin
    errormess = 'Cannot read signal '+signal_in+' in shot '+i2str(shot)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
; The time vector is not scaled correctly sometimes. Assuming that
; the start time is OK, we use ext_fsample for sample frequency
  time=(time-time(0))/(time(1)-time(0))/ext_fsample+starttime
  sampletime = time(1)-time(0)
  if (not keyword_set(nocalibrate)) then begin
    cal=getcal(shot,data_source=data_source)
    ind=where(cal(0,*) eq ch)
    if (ind(0) lt 0) then begin
      print,'No calibration data is available for channel '+i2str(ch)
      stop
    endif
    data=(data-cal(1,ind(0)))*cal(2,ind(0))
  endif
endif          ; *************** TEXTOR Li-beam signal ***************

if (data_source eq 8) then begin  ; TEXTOR Blow-off signal
  r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list,$
                errortext=errormess,ext_fsample=ext_fsample,/silent)
  if (r ne 0) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  ind=where(signal_list eq signal_in)
  get_rawsignal,data_names=syst_names
  if (ind(0) lt 0) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(nodata)) then return
  ch = channel_list(ind(0))
  case ch of
    1: signal_name = 'LMSA1'
    2: signal_name = 'LMSA2'
    3: signal_name = 'LMSB1'
    4: signal_name = 'LMSB2'
    5: signal_name = 'LMSD1'
    6: signal_name = 'LMSD2'
  endcase
  retrievedata,shot,signal_name,1000000L,time,data,ok
; The time vector is not scaled correctly sometimes. Assuming that
;  the start time is OK, we use ext_fsample for sample frequency
  if (ok eq 0) then begin
    errormess = 'Cannot read signal '+signal_in+' in shot '+i2str(shot)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  time = float(time)/(time(1)-time(0))/ext_fsample
  sampletime = time(1)-time(0)
endif

if (data_source eq 9) then begin  ; ************* TEXTOR Li-beam test signal *************
  r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list,$
                errortext=errormess,ext_fsample=ext_fsample,/silent)
  if (r ne 0) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  ind=where(signal_list eq signal_in)
  get_rawsignal,data_names=syst_names
  if (ind(0) lt 0) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(nodata)) then return
  ch = channel_list(ind(0))
  case ch of
    1: signal_name = 'LMSA1'
    2: signal_name = 'LMSA2'
    3: signal_name = 'LMSB1'
    4: signal_name = 'LMSB2'
    5: signal_name = 'LMSD1'
    6: signal_name = 'LMSD2'
  endcase
  retrievedata_t,shot,signal_name,1000000L,time,data,ok
; The time vector is not scaled correctly sometimes. Assuming that
;  the start time is OK, we use ext_fsample for sample frequency
  if (ok eq 0) then begin
    errormess = 'Cannot read signal '+signal_in+' in shot '+i2str(shot)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  time = float(time)/(time(1)-time(0))/ext_fsample
  sampletime = time(1)-time(0)
  if (not keyword_set(nocalibrate)) then begin
    cal=getcal(shot,data_source=data_source)
    ind=where(cal(0,*) eq ch)
    if (ind(0) lt 0) then begin
      print,'No calibration data is available for channel '+i2str(ch)
      stop
    endif
    data=(data-cal(1,ind(0)))*cal(2,ind(0))
  endif
endif

;**** Blow-off channels from W7-AS
;**** added by M. Bruchhausen on 14.05.01
if (data_source eq 10) then begin  ; W7-AS Blow-off signal
  r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list,$
                errortext=errormess,ext_fsample=ext_fsample,/silent)

  if (r ne 0) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  ind=where(signal_list eq signal_in)

  get_rawsignal,data_names=syst_names

  if (ind(0) lt 0) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(nodata)) then return
  ch = channel_list(ind(0))
  diag='VUV'
  amount=500000L
  case ch of
    1: BEGIN
         module='Juelich-1' & channel=1
       END
    2: BEGIN
         module='Juelich-1' & channel=2
       END
    3: BEGIN
         module='Juelich-2' & channel=1
       END
    4: BEGIN
         module='Juelich-2' & channel=2
       END
    5: BEGIN
         module='Juelich-3' & channel=1
       END
    6: BEGIN
         module='Juelich-3' & channel=2
       END
    7: BEGIN
         module='Juelich-4' & channel=1
       END
    8: BEGIN
         module='Juelich-4' & channel=2
       END
  endcase

rawchannel,shot,diag,module,channel,amount,data,time
time=findgen(n_elements(data))/ext_fsample
para=readshotpara(shot)
t0=float(para[0])*1e-3
dt=float(para[1])*1e-3
nn=float(para[2])
samples=float(para[3])

time=time+t0
FOR i=1,(nn-1) DO BEGIN
  time[i*samples:(i+1)*samples-1]=$
    time[i*samples:(i+1)*samples-1]+i*(dt-samples/ext_fsample)
ENDFOR
time[(nn)*samples:n_elements(data)-1]=time[(nn)*samples:$
  n_elements(data)-1]+(nn-1)*dt

  if (r ne 0) then begin
    errormess = 'Cannot read signal '+signal_in+' in shot '+i2str(shot)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  time = float(time)/(time(1)-time(0))/ext_fsample
  sampletime = time(1)-time(0)

endif
; **** End of W7-AS blow-off section


;**** JET Li-beam channels measured in CATS
if (data_source eq 11) then begin
  vertical_norm=1
  vertical_zero=0
  r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list,$
                errortext=errormess,ext_fsample=ext_fsample,/silent)

  if (r ne 0) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  ind=where(signal_list eq signal_in)

  get_rawsignal,data_names=syst_names

  if (ind(0) lt 0) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(nodata)) then return
  ch = channel_list(ind(0))
  sampletime = 1e-6
  window_counter = 1
  time = 0
  data = 0
  while (window_counter ge 0) do begin
    node = 'DI/C1-CATS<KG1:'+i2str(ch,digits=3)+'/'+i2str(window_counter)
    jpfget, node=node, pulno=shot, data=data_win, tvec=time_win, unit=unit,$
                      pulsefile='LPF', diag='CATS1', ier=ier
    if (ier ne 0) then begin
      window_counter = -1
    endif else begin
    print,i2str(window_counter)+'   ['+string(time_win(0),format='(F6.3)')+' , '+string(time_win(n_elements(time_win)-1),format='(F6.3)')+']'
      if (window_counter eq 1) then begin
        time = dindgen(n_elements(time_win))*sampletime+time_win(0)
        data = data_win
      endif else begin
        time = [time,dindgen(n_elements(time_win))*sampletime+time_win(0)]
        data = [data,data_win]
      endelse
      window_counter = window_counter+1
    endelse
  endwhile

  if (n_elements(time) le 1) then begin
    errormess='Error reading signal '+signal_in+' in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)+' (jpfget error:'+i2str(ier)+')'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif

  find_cats_timewindows,time
  data = data+6

endif
; **** End of JET Li-beam section


; Test signals
if (data_source eq 12) then begin
;  r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list,$
;                errortext=errormess,/silent)
;  if (r ne 0) then begin
;    if (keyword_set(errorproc)) then begin
;      call_procedure,errorproc,errormess,/forward
;    endif else begin
;      print,errormess
;    endelse
;    data=0
;    time=0
;    return
;  endif
;  ind=where(signal_list eq signal_in)
;  get_rawsignal,data_names=syst_names
;  if (ind(0) lt 0) then begin
;    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
;    if (keyword_set(errorproc)) then begin
;      call_procedure,errorproc,errormess,/forward
;    endif else begin
;      print,errormess
;    endelse
;    data=0
;    time=0
;    return
;  endif
  sampletime = 1e-6;
  if (strmid(signal_in,0,7) eq 'Line-1-') then begin
    ch_txt = i2str(fix(strmid(signal_in,7))-1);
    fname = dir_f_name('data','ch'+ch_txt+'l1'+i2str(shot)+'.dat')
  endif
  if (strmid(signal_in,0,7) eq 'Line-2-') then begin
    ch_txt = i2str(fix(strmid(signal_in,7))-1);
    fname = dir_f_name('data','ch'+ch_txt+'l2'+i2str(shot)+'.dat')
  endif
  if (strmid(signal_in,0,5) eq 'Dens-') then begin
    ch_txt = i2str(fix(strmid(signal_in,5))-1);
    fname = dir_f_name('data','ch'+ch_txt+'dens'+i2str(shot)+'.dat')
  endif
  if (strmid(signal_in,0,5) eq 'Temp-') then begin
    ch_txt = i2str(fix(strmid(signal_in,5))-1);
    fname = dir_f_name('data','ch'+ch_txt+'temp'+i2str(shot)+'.dat')
  endif
  if (not keyword_set(fname)) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif

  if (keyword_set(nodata)) then return

  restore,fname
  data = savvector
  time=findgen(n_elements(savvector))*1e-6
endif
; ****************** End of test signals


;**** NI6115 system
if (data_source eq 13) then begin
  vertical_norm=1
  vertical_zero=0
  r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list,$
                errortext=errormess,ext_fsample=ext_fsample,/silent,starttime=starttime)

  if (r ne 0) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  ind=where(signal_list eq signal_in)

  get_rawsignal,data_names=syst_names

  if (ind(0) lt 0) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(nodata)) then return
  ch = channel_list(ind(0))
  card = fix((ch-1)/4)
  ch = ((ch-1) mod 4)+1
  if (not keyword_set(filename)) then begin
    filename = 'ni'+i2str(card)+'_'+i2str(shot,digits=5)+'.dat'
  endif

  if (keyword_set(trange)) then trange_rel = trange-starttime
  read_ni6115,datapath+filename,ch,config=config,errormess=errormess,data=data,time=time,trange=trange_rel
  if (keyword_set(errormess)) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  time = time+starttime

  sampletime = 1./config.sample_rate

endif
; **** End of JET Li-beam section

;**** W7-AS ECE system
if (data_source eq 14) then begin

  file = 'data/ecetemp'+i2str(shot,digits=5)+'.dat'
  read_ece,file,frequencies,time,te_array,channels=channels,errormess=errormess,/silent
  if (errormess ne '') then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif

  ind=where(fix(channels) eq fix(signal_in))
  get_rawsignal,data_names=syst_names

  if (ind(0) lt 0) then begin
    errormess='Signal '+signal_in+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(nodata)) then return
  data = te_array(ind[0],*)
  sampletime = time[1]-time[0]
endif
; **** End of W7-AS ECE section

;**** JET KK3 ECE system
if (data_source eq 15) then begin
  if (keyword_set(nodata)) then return
  mdsconnect,'mdsplus.jet.efda.org'
  str = '_sig=jet("ppf/kk3/te'+i2str(fix(signal_in))+'",'+i2str(shot,digits=5)+')'
  data = mdsvalue(str)
  time = mdsvalue('dim_of(_sig)')
  mdsdisconnect
  if (not keyword_set(data) or (not keyword_set(time))) then begin
    get_rawsignal,data_names=syst_names
    errormess='Cannot read '+signal_in+' in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  if (keyword_set(trange)) then begin
    ind=where((time ge trange(0)) and (time le trange(1)))
    if (ind(0) lt 0) then begin
      errormess='Cannot find signal '+signal_in+' in time interval.
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    time=time(ind)
    data=data(ind)
  endif
  sampletime = double(time[n_elements(time)-1]-time[0])/(n_elements(time)-1)
endif
; ********* end of JET KK3 ECE system

; General interface to IDL save files
;     File name: <shot><signal name>.sav
;     Contents:      data: data array
;              sampletime: sample time in sec
;               starttime: start time in sec
;               endtime: end time in sec by Pokol 2008.03.04
;
if (data_source eq 16) then begin
  if (keyword_set(nodata)) then return
  fname = datapath+i2str(shot,digits=5)+signal_in+'.sav'
  restore,fname
  if (not defined(data) or not defined(sampletime) or not defined(starttime)) then begin
    errormess='Invalid data file: '+fname
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
;  time = dindgen(n_elements(data))*sampletime+starttime ; Old method
  time = dindgen(n_elements(data))*(double(endtime)-double(starttime))/(n_elements(data)-1)+double(starttime) ; Pokol 2008.03.04, Papp 2008.11.18.
endif
; ****************** End of general IDL data source


; ******************* CASTOR data ************************
if (data_source eq 17) then begin
  if (keyword_set(nodata)) then return
  r = strsplit(signal_in,'-',/extract)
  if (n_elements(r) ne 2) then begin
    errormess='Invalid signal name for CASTOR data: '+signal_in
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  castor_path = datapath
  data = getdata(shot,r[0],fix(r[1]),path=castor_path,time=time)
  sampletime = round((time[1]-time[0])*1e3)
  starttime = time[0]/1000.
  time = findgen(n_elements(data))*sampletime*1e-6+starttime
  sampletime = sampletime*1e-6
endif
; ****************** End of CASTOR data source

; ******************* MT-1M data ************************
if (data_source eq 18) then begin
  if (keyword_set(nodata)) then return
  r = strsplit(signal_in,'-',/extract)
  if (n_elements(r) ne 2) then begin
    errormess='Invalid signal name for MT-1M data: '+signal_in
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  d = collmod(shot,r[0],r[1])
  if (n_elements(d) le 1) then begin
    errormess = 'Cannot find data.'
    return
  endif
  time = d[*,0]
  sampletime = (time[1]-time[0])*1E-9
  time = time*1e-9
  data = d[*,1]
  starttime = time[0]
endif
; ****************** End of MT-1M data source

; ******************* TEXTOR web umbrella ************************
if (data_source eq 19) then begin
  if (keyword_set(nodata)) then return
  r = strsplit(signal_in,'@',/extract)
  sss = r[0]
  if (n_elements(r) gt 1) then begin
    for i=1,n_elements(r)-1 do begin
      sss = sss+'/'+r[i]
    endfor
  endif
  base_url= 'http://ipptwu.ipp.kfa-juelich.de'
  sig_type=''
  dfp= 0
  post_url='/textor/all/'+i2str(shot,digits=5)+'/'+sss
  url= base_url + post_url
  time = 0
  for i=0,10 do begin
    result= twu_read_signal(dfp, url, data, time, sig_type)
    print,i,result,' ',n_elements(time)
    if (result eq 'OK') and (n_elements(time) gt 1) then break
  endfor
  if (result ne 'OK') then begin
    errormess = 'Error reading data.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data = 0
    time = 0
  endif
  sampletime = (time[n_elements(time)-1]-time[0])/(n_elements(time)-1)
  starttime = time[0]
endif
; ****************** End of TEXTOR web umrella ******************

; ****************** TEXTOR HE-BEAM ****************************

; Added on 2005. 06. 13.                                by Daniel Dunai
;                                                     to be verified
if (data_source eq 20) then begin


sigarr=str_sep(signal_in, 'ch')
; line - pre/post chnum

sigarr2=str_sep(sigarr[1], '-')


IF n_elements(sigarr2 eq 1) THEN BEGIN
; normal channels
   get_lun, unit1
   ;openr, unit1, i2str(shot)+'/'+i2str(shot)+'hebeam.sav', error=errhe
   openr, unit1, shot+'/'+shot+'hebeam.sav', error=errhe
   close, unit1
   free_lun, unit1

  if  (errhe EQ 0) then begin
    restore, shot+'/'+shot+'hebeam.sav'

       ch2read_st=sigarr[1]
       ch2read=fix(ch2read_st)

       if ((ch2read GT 8 ) or (ch2read LT 1)) then begin

         errormess='Wrong channel number!'
           if  (keyword_set(errorproc)) then begin
              call_procedure,errorproc,errormess,/forward
           endif else begin
              print,errormess
                endelse
            time=-1
            data=-1
            return
        endif


    if (sigarr[0] EQ '668') then begin

         time=time
         data=fbeam668[ch2read-1,*]
         sampletime=time[1]-time[0]

    endif else begin

         if (sigarr[0] EQ '706') then begin

           time=time
           data=fbeam706[ch2read-1,*]
           sampletime=time[1]-time[0]

         endif else begin

             if (sigarr[0] EQ '728') then begin

                 time=time
              data=fbeam728[ch2read-1,*]
              sampletime=time[1]-time[0]

              endif else begin

              errormess='Wrong line number'
              if (keyword_set(errorproc)) then begin
              call_procedure,errorproc,errormess,/forward
              endif else begin
                 print,errormess
                endelse
              time=-1
              data=-1
              return

              endelse



         endelse


   endelse
     endif else begin
       errormess='Error opening file'
       if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess,/forward
           endif else begin
           print,errormess
                endelse
       time=-1
       data=-1
       return
    endelse

ENDIF ELSE BEGIN

   get_lun, unit1
   ;openr, unit1, i2str(shot)+'/'+i2str(shot)+'tails.sav', error=errhe
   openr, unit1, shot+'/'+shot+'tails.sav', error=errhe
   close, unit1
   free_lun, unit1

   if  (errhe EQ 0) then begin
    restore, shot+'/'+shot+'tails.sav'

       ch2read_st=sigarr2[1]
       ch2read=fix(ch2read_st)

       if ((ch2read GT 8 ) or (ch2read LT 1)) then begin

         errormess='Wrong channel number!'
           if  (keyword_set(errorproc)) then begin
              call_procedure,errorproc,errormess,/forward
           endif else begin
              print,errormess
                endelse
            time=-1
            data=-1
            return
         endif


   IF sigarr2[0] eq 'pre' THEN BEGIN

    ; channels before he pulse

           if (sigarr[0] EQ '668') then begin

         time=timepre
         data=fpre668[ch2read-1,*]
         sampletime=time[1]-time[0]

       endif else begin

          if (sigarr[0] EQ '706') then begin

             time=timepre
             data=fpre706[ch2read-1,*]
             sampletime=time[1]-time[0]

           endif else begin

             if (sigarr[0] EQ '728') then begin

                 time=timepre
              data=fpre728[ch2read-1,*]
              sampletime=time[1]-time[0]

              endif else begin

              errormess='Wrong line number'
              if (keyword_set(errorproc)) then begin
              call_procedure,errorproc,errormess,/forward
              endif else begin
                 print,errormess
                endelse
              time=-1
              data=-1
              return

            endelse

          endelse


        endelse



     ENDIF  ELSE BEGIN

        IF sigarr2[0] eq 'post' THEN BEGIN
          ; channels after pulse

         if (sigarr[0] EQ '668') then begin

         time=timepost
         data=fpost668[ch2read-1,*]
         sampletime=time[1]-time[0]

       endif else begin

          if (sigarr[0] EQ '706') then begin

             time=timepost
             data=fpost706[ch2read-1,*]
             sampletime=time[1]-time[0]

           endif else begin

             if (sigarr[0] EQ '728') then begin

                 time=timepost
              data=fpost728[ch2read-1,*]
              sampletime=time[1]-time[0]

              endif else begin

              errormess='Wrong line number'
              if (keyword_set(errorproc)) then begin
              call_procedure,errorproc,errormess,/forward
              endif else begin
                 print,errormess
                endelse
              time=-1
              data=-1
              return

            endelse

          endelse


        endelse

        ENDIF ELSE BEGIN

          errormess='Error opening file'
          if (keyword_set(errorproc)) then begin
           call_procedure,errorproc,errormess,/forward
           endif else begin
           print,errormess
                endelse
       time=-1
       data=-1
       return

        ENDELSE


   ENDELSE

   ENDIF ELSE BEGIN
   ; errhe ne 0

    errormess='Error opening file'
       if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess,/forward
           endif else begin
           print,errormess
                endelse
       time=-1
       data=-1
       return

   ENDELSE


;pre post channels

ENDELSE





endif


;******************* End of TEXTOR HE-BEAM *********************

;******************* NI-6115 TEST measurements ********************

; Added on 2005. 10. 10.                                by Daniel Dunai
;                                                     to be verified
if (data_source eq 21) then begin
  ; not to add new keyword

  default, datapath, ''

  sigarr=str_sep(signal_in, 'ch')

  ch=fix(sigarr[1])

  ; config fileban
  ;start_time
  ;meas_time
  ;sample_rate (long)
  ;number of samples
  ;number of channels
  ;gain

  read_ni6115,datapath+i2str(shot)+signal_in,ch,config=$
                        config,errormess=errormess,data=data,time=time
  if (keyword_set(errormess)) then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  time = time+config.start_time
  sampletime = 1./config.sample_rate

endif

;********************End of NI-6115 TEST measurements ****************

;*********************************************************************
;--------------------- AUG MIRNOV -----------------------------------
; by K.G. 14.11.2005
; mod. by Gergo Pokol 21.12.2007 (use endtime and double precision for time-vector)
; mod. by Gergo Pokol 04.01.2008 (use pg_get_aug_mirnov.pro)
if (data_source eq 22) then begin


   ;sigarr=str_sep(signal_in, 'ch')
   ;ch=fix(sigarr[1])

   filename = dir_f_name('data','AUG_'+i2str(shot)+'_'+signal_in+'.sav')
   openr,u,filename,/get_lun,error=error
   if (error eq 0) then begin
     close,u & free_lun,u
     restore,filename
     ;time = findgen(n_elements(data))*sampletime+starttime ; Old method
     time = double(lindgen(n_elements(data)))*(double(endtime)-double(starttime))/double(n_elements(data)-1)+double(starttime)
   endif else begin
     ;forward_function read_mirnov_channels
     ;a=read_mirnov_channels(shot=shot,channel=ch,ch_name=ch_name,$
     ;            /equidistant,no_data=nodata)
     forward_function pg_get_aug_mirnov
     a=pg_get_aug_mirnov(shot,signal_in,nodata=nodata)

;   signal_in=ch_name
     if not keyword_set(nodata) then begin
          data=float(a.s)
          time=float(a.t)
          sampletime=time[1]-time[0]
     endif else begin
          data=0.
          time=0.
          sampletime=0.
    endelse
    starttime = time[0]
    endtime = time[n_elements(data)-1]
    signal='AUG_'+signal_in
    if savedata then save,data,starttime,sampletime,endtime,shot,signal,file=filename

		;automatically copy data to a remote machine if set
		if not strcmp(movedata,'') then begin
			;move to default (movedata=1) location
			if movedata eq 1 then begin
				remote='data@deep.reak.bme.hu:asdex/raw_data/'
			;move to custom location
			endif else begin
				remote=movedata
			endelse
			print, 'MOVEing data to ' + remote + ' via ssh.'
				spawn, 'scp '+filename+' '+remote, copy
				print, 'Succesfully MOVED to remote machine!'
				spawn, 'rm ' + filename
		endif
  endelse

endif
;--------------------END AUG MIRNOV ---------------------------------
;********************************************************************


; ******************* MAST data ************************
if (data_source eq 23) then begin
  if (keyword_set(nodata)) then return
  r = strsplit(signal_in,'-',/extract)
  a = read_data(shot,signal_in)
  if (a[0].error ne 0) then begin
    errormess='Could not read mast data: '+signal_in
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  data = reform(a.data)
  sampletime = a.taxis.VECTOR[1] - a.taxis.VECTOR[0]
  starttime = a.taxis.VECTOR[0]
  time = a.taxis.VECTOR
  sampletime = sampletime
endif
; ****************** End of MAST data source


;======================= AUG SXR =========================
;by Magyarkuti Andras 2010.07.21.

if data_source eq 24 then begin

	filename = i2str(shot)+'_AUG_SXR_'+signal_in+'.sav'
	dir='./data/'
	if keyword_set(datapath) then dir=datapath

	fileexists=file_test(dir + filename)
        if (fileexists eq 1) then begin
		restore, dir + filename
		print, 'Data loaded from file: '+dir+filename
	        time = double(dindgen(n_elements(data)))*(double(endtime)-double(starttime))/double(n_elements(data)-1)+double(starttime)
	endif else begin
		print, 'File not found: '+dir+filename

		if not strcmp(movedata,'') then begin
			if movedata eq 1 then begin	;copying to default location
				ma_sxr_savedata, shot, signal_in, /scp, data=data, time=time
			endif else begin
				ma_sxr_savedata, shot, signal_in, /scp, remote=movedata, data=data, time=time
			endelse
		endif else begin
			ma_sxr_savedata, shot, signal_in, data=data, time=time
		endelse
	endelse

endif

;=========================================================

;======================= AUG ECE =========================
;by Magyarkuti Andras 2010.07.21.

if data_source eq 25 then begin

	;set channel range to 1-60
	if fix(signal_in) gt 60 then begin
		print, 'Wrong channel number: >60'
		return
	endif

	filename = i2str(shot)+'_AUG_ECE.sav'
	dir='./data/'
	if keyword_set(datapath) then dir=datapath
	save_file=dir+filename

	;reading from file
        if (file_test(save_file)) then begin
		print, 'Loading data from file '+save_file+' ...'	
		restore, save_file
		data = ECE.trad[*,fix(signal_in)-1]
	        time = ECE.time

	;if file does not exists then download it
	endif else begin

		;getting data with Wolfgang Suttrop's routine (origin: /afs/ipp/u/wls/idl/read_cec.pro)
		;have /afs/ipp/u/augidl/idl/user_contrib in your path!
		;we must set start and endtime. It will be owerwritten by the function later.
		ece_start=0
		ece_end=10
		;actual data reading
		read_cec,shot,ece_start,ece_end,R,z,time,trad,f=f,df=df,Btot=Btot,$
  		rztime=rztime,Rt=Rt,zt=zt,experiment=experiment, $
 		edition=edition, Rzs=Rzs, calibsrc=calibsrc, error=error

		print, ' '
		if error EQ 0 then begin 
		    print,'Succesfully downloaded data from shot '+i2str(shot)
		endif else begin
		    print,'Error in read_cec.pro, error code: '+i2str(error)
		endelse

		;due to the number of variables the data is stored in the struct ECE
		;to prevent accidental overwriting.
		ECE=create_struct('shot',shot,'ece_start',ece_start,'ece_end',ece_end,'R',R,'z',z,'time',time,$
			'trad',trad,'rztime',rztime,'Rt',Rt,'zt',zt, name='AUG_ECE')
		
		data = ECE.trad[*,fix(signal_in)-1]
		print, 'Saving to file '+save_file+' ...'
		save, ECE, filename=save_file

		;automatically copy data to a remote machine if set
		if strcmp(size(movedata, /tn), 'STRING') then begin
			if strcmp(movedata, '') then begin
				scp=0
			endif else begin
			;move to custom location
			remote=movedata
			scp=1
			endelse
		endif else begin
			;move to default (movedata=1) location
			remote='data@deep.reak.bme.hu:asdex/raw_data/'			
			scp=1
		endelse

		if scp eq 1 then begin
				print, 'MOVEing data to ' + remote + ' via ssh.'
				spawn, 'scp '+save_file+' '+remote, copy
				print, 'Succesfully MOVED to remote machine!'
				spawn, 'rm ' + save_file
		endif

	endelse	

endif
;=========================================================

;======================= AUG FILD =========================
;by Magyarkuti Andras 2010.08.14.

if data_source eq 26 then begin

	;set channel range to 1-20
	if fix(signal_in) gt 20 then begin
		print, 'Wrong channel number: >20'
		return
	endif

	filename = i2str(shot)+'_AUG_FILD_'+signal_in+'.sav'
	dir='./data/'
	if keyword_set(datapath) then dir=datapath
	save_file=dir+filename

	;reading from file
        if (file_test(save_file)) then begin
		print, 'Loading data from file '+save_file+' ...'	
		restore, save_file
                time = double(dindgen(n_elements(data)))*(double(endtime)-double(starttime))/double(n_elements(data)-1)+double(starttime)
	;if file does not exists then download it
	endif else begin

		read_signal, ier, shot, 'FHA', 'FIPM_'+signal_in, time, data, dim
		
		print, ' '
		if ier EQ 0 then begin 
		    print,'Succesfully downloaded data from shot '+i2str(shot)
		endif else begin
		    print,'Error in read_signal.pro, error code: '+i2str(ier)
		endelse
                
                starttime=time[0]
                endtime=time[n_elements(time)-1]
		save, starttime, endtime, data, dim, signal_in, filename=save_file

		;automatically copy data to a remote machine if set
		if strcmp(size(movedata, /tn), 'STRING') then begin
			if strcmp(movedata, '') then begin
				scp=0
			endif else begin
			;move to custom location
			remote=movedata
			scp=1
			endelse
		endif else begin
			;move to default (movedata=1) location
			remote='data@deep.reak.bme.hu:asdex/raw_data/'			
			scp=1
		endelse

		if scp eq 1 then begin
				print, 'MOVEing data to ' + remote + ' via ssh.'
				spawn, 'scp '+save_file+' '+remote, copy
				print, 'Succesfully MOVED to remote machine!'
				spawn, 'rm ' + save_file
		endif

	endelse	

endif
;=========================================================

default,trange,[min(time),max(time)]
ind=where((time ge trange(0)) and (time le trange(1)))
if (ind(0) lt 0) then begin
  errormess='Cannot find signal '+signal_in+' in time interval.
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,errormess,/forward
  endif else begin
    print,errormess
  endelse
  data=0
  time=0
  return
endif
time=time(ind)
data=data(ind)
data=float(data)
if (data_source eq 4) and (keyword_set(equidist)) then begin
  d=time(1:n_elements(time)-1)-time(0:n_elements(time)-2)
  if ((where(d gt sampletime*2))(0) ge 0) then begin
    errormess='Signal '+signal_in+' is not equidistantly sampled in time interval ['$
        +string(trange(0),format='(F5.3)')+','+string(trange(1),format='(F5.3)')+']'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
endif


end
