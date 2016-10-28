pro get_rawsignal,shot,signal_name_in,time,data,errorproc=errorproc,errormess=errormess,$
         data_source=data_source,afs=afs,cdrom=cdrom,trange=trange,data_names=data_names,$
         nocalibrate=nocalibrate,calfac=calfac,sampletime=sampletime,equidist=equidist,$
         no_shift_correct=no_shift_correct,timerange=timerange,$
         correction_method=correction_method,p2_points=p2_points,$
         datapath=datapath,local_datapath=local_datapath,filename=filename,nodata=nodata,$
         subchannel=subchannel,chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
         vertical_norm=vertical_norm,vertical_zero=vertical_zero, store_data=store_data,$
         subch_mask=subch_mask,cache=cache,search_cache=search_cache,offset_timerange=offset_timerange,no_offset=no_offset,$
         filter_radiaton_pulses=radpulse_limit,no_time=no_time

; ************* get_rawsignal.pro ********************** S. Zoletnik *** 1.4.1998
; This is the general routine for reading (calibrated) data from different data source
; If a new data source is added, this routine (and meas_config.pro) should be modified.
; To get a list of available data sources call:
; get_rawsignal,data_names=names
; After return <names> containes a string array, each string is the name of the
; associated data source.
; INPUT:
;  shot: shot number
;  signal_name _in: [<data source>/]<signal name> or numeric channel number (see chan_prefiox and chan_postfix)
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
;                4 --> W7-AS Mirnov system
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
;               22 --> AUG Mirnov diagnostocs      /K. G. 2005.11.14
;               23 --> MAST data through read_data.pro  /Z.S. 2006.01.10
;               24 --> NI card measurements ( MAST, TEXTOR)  /D. D. 2007. 01. 10.
;               25 --> TEXTOR Fast libeam 2008               /D. D. 2008. 02. 29.
;               26 --> JET JPF  (Signal name: subsystem/node
;               27 --> JET PPF
;               28 --> Signal cache (see signal_cache_add.pro)
;               29 --> ITER CXRS test spectrometer using APDCAM detector
;               30 --> MAST NETCDF data through getdata  /D.D. 2011. 05. 04.
;               31 --> ASDEX Upgrade data /S. Zoletnik  11 May 2011
;               32 --> KSTAR data / S. Zoletnik   2 August 2011
;               33 --> JET KY6D raw data from controlling PC  S. Zoletnik 19 April 2012
;
;
;  /afs: get data from afs system instead of data/ dir.
;  trange: time range in sec (default: get all data)
;  timerange: as trange above
;  /nocalibrate: do not calibrate signal (e.g. relative calibaration of Li channels)
;  calfac: calibration factors (optional)
;  /cdrom: get Nicolet data from cdrom (dir cdrom/...)
;  /equidist: accept only equidistantly measured signals (except for subchannels)
;  /nodata: don't read data, just test signal availability and return
;  subchannel: Subchannel in deflected Li-beam measurements (0: all signal,
;      1... a subchannel
;  subch_mask: A list of indices for getting out subchannel samples from one deflection period.
;              0...number of samples in period. Normally this is taken from deflection config, but
;              it can be set manually through this keyword.
;  vertical_norm: Vertical scale in wftread
;  vertical_zero: Vertical offset in wftread
;  filename: Name of the datafile (only for 6 and 13 and for MAST test shots)
;  /store_data: Store data in IDL save file in dir in local_datapath (available for MAST, JET)
;  /cache:  Store signal in signal cache using the full signal name (see signal_cache_add.pro)
;    cache='name'  Store signal in signal cache using name as signal name
;  /search_cache: Search cache for signal
;  *** Keywords only for CO_2 laser scattering signals ***
;  /no_shift_correct: Do not apply time shift correction for the shift introduced by the hardware
;  correction_method: Time shift correction method
;  p2_points: use only power of two number of points
;  datapath: Path for the datafile
;  local_datapath: The path for the directory where locally cached data are stored (see /store_data)
;  chan_prefix: Prefix for constructing a channel name
;  chan_postfix: End part for constructing  a channel name
;     After call to this program the signal_name_in variable will contain a full channel name
;     in string format constructed the following way:
;       If signal_name_in is string:  <data_source name>/<signal_name_in>
;       If signal_name_in is numeric: <data_source name>/<chan_prefix><signal_name_in><chan_postfix>
;  offset_timerange: For some signals an offset is automatically subtracted. The offset is calculated as the
;                    average signal in this timerange.
;  /no_offset: Do not subtract offset from the signals.
;  filter_radiation_pulses: Filter out pulses from neutrons and gamma photons using
;                           filter_radiation_pulses.pro. This parameter is passed
;                           to the routine as the limit parameter. The default value of this parameter is read from
;                           the radiation_pulse_limit entry in the config file.
;  /no_time: Do not return time vector. (Useful for data where no time information is available.)
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
;*******************************************************************************

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
            'NIDATA',$
            'TEXTOR Fast Li-beam',$
            'JET-JPF',$
            'JET-PPF',$
            'Cache',$
            'CXRS-BES', $
            'MAST-NC',$
            'AUG',$
            'KSTAR',$
            'JET-KY6D']

default,shot,0
if (defined(timerange)) then trange=timerange
default,data_source,fix(local_default('data_source'))
default,datapath,local_default('datapath')
default,datapath,'data'
config_local_datapath = local_default('local_datapath')
if (config_local_datapath ne '') then  local_datapath = config_local_datapath
default,local_datapath,datapath
default,search_cache,fix(local_default('search_cache'))
default,cache,fix(local_default('cache'))
if (not defined(radpulse_limit)) then begin
  config_radpulse_limit = local_default('radiation_pulse_limit')
  if (config_radpulse_limit ne '') then radpulse_limit = config_radpulse_limit
endif
if (config_local_datapath ne '') then  local_datapath = config_local_datapath
if (n_elements(offset_timerange) lt 2) then begin
  offset_timerange_start = local_default('offset_timerange_start',/silent)
  offset_timerange_end = local_default('offset_timerange_end',/silent)
  if ((offset_timerange_start ne '') and (offset_timerange_end ne '')) then begin
    offset_timerange = [double(offset_timerange_start),double(offset_timerange_end)]
  endif
endif
; No default data pathn is used for MAST as path is used only for test shots there
if (data_source ne 23) then default,datapath,'data/'

; Setting default values for chan_prefix for LBO and Lithium beam data sources
if ((data_source eq 8) or (data_source eq 10)) then begin
  default,chan_prefix,'Blo-'
endif else begin
  if ((data_source le 5) or (data_source eq 7) or (data_source eq 9) or (data_source eq 11)) then begin
    default,chan_prefix,'Li-'
  endif
endelse
; Otherwise defaults are empty strings
default,chan_prefix,''
default,chan_postfix,''

forward_function strsplit

; Returning if signal name is not set
if (not defined(signal_name_in)) then return
if (string(signal_name_in) eq '') then return

forward_function getcal

; If the signal_name_in is only a number, it will be changed to a string
if ((size(signal_name_in))(1) ne 7) then begin
  signal_name_in=chan_prefix+i2str(signal_name_in)+chan_postfix
endif

; Extracting system name from signal name if system name is present
if (strpos(signal_name_in,'/') gt 0) then begin ; if system is given in signal name
  w=str_sep(signal_name_in,'/')
  sysname=w(0)
  signal_in=w(1)
  if (n_elements(w) gt 2) then begin
    for i=2,n_elements(w)-1 do begin
      signal_in = signal_in+'/'+w[i]
    endfor
  endif
  sys=where(strupcase(sysname) eq strupcase(data_names))

  if (sys(0) lt 0) then begin
    ; Removing error handling here. 23/07/2008  S.Z.
    ; If the system name is not recongnized then it is considered that the signal name does not contain
    ; a system name
    ; errormess='Unknown system name ('+sysname+') found in total signal name: '+signal_name_in
    ; if (keyword_set(errorproc)) then begin
    ;   call_procedure,errorproc,errormess,/forward
    ; endif else begin
    ;   print,errormess
    ; endelse
    ; data=0
    ; time=0
    ; return
    signal_in = signal_name_in
    sysname = data_names(data_source)
  endif else begin
    data_source=sys(0)
  endelse
endif else begin
  signal_in = signal_name_in
  sysname = data_names(data_source)
endelse

signal_name_in = sysname+'/'+signal_in
full_signal_in = signal_name_in


if (data_source eq 28) then begin   ; Signal cache
  signal_cache_get,name=signal_in,data=data,time=time,starttime=starttime,sampletime=sampletime,errormess=errormess
  if (errormess ne '') then begin
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
  if (not defined(sampletime)) then begin
    sampletime = double(time[n_elements(time)-1]-time[0])/double(n_elements(time))
  endif else begin
    ; If NaN calculate the sampletime
    if (not finite(sampletime)) then begin
      sampletime = double(time[n_elements(time)-1]-time[0])/double(n_elements(time))
    endif
  endelse
  if (not defined(starttime)) then begin
    starttime = time[1]
  endif else begin
    ; If NaN calculate it
    if (not finite(starttime)) then begin
      starttime = time[1]
    endif
  endelse
endif else begin
  ; If cache search in enabled
  if (keyword_set(search_cache) and not keyword_set(nodata)) then begin
    cache_name = i2str(shot)+'_'+full_signal_in
    if (defined(subchannel)) then begin
      if (subchannel ne 0) then cache_name = cache_name+'_'+i2str(subchannel)
    endif
    signal_cache_get,name=cache_name,data=data,time=time,starttime=starttime,sampletime=sampletime,errormess=err
    if (err eq '') then begin
      ; Check whether the required timerange is within the cached signal timerange
      if defined(trange) then begin
        if (not finite(sampletime)) then begin
          if (n_elements(time) lt 2) then begin
            tolerance_start = 0
            tolerance_end = 0
          endif else begin
            tolerance_start = time[1]-time[0]
            tolerance_end = time[n_elements(time)-1]- time[n_elements(time)-2]
          endelse
        endif else begin
            tolerance_start = sampletime
            tolerance_end = sampletime
        endelse
        if ((trange[0] ge min(time)-tolerance_start) and (trange[1] le max(time)+tolerance_end)) then begin
          from_signal_cache = 1
        endif
      endif else begin
          from_signal_cache = 1
      endelse
    endif
  endif
endelse

; Handling subchannels
default,subchannel,0


; Jumping to end if signal is taken from cache
if (keyword_set(from_signal_cache)) then  goto,get_rawsignal_end


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
    forward_function mag_alldat
    r=mag_alldat(data,shot,modname,/cal,signames=signames)
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
;
if (data_source eq 16) then begin
  if (keyword_set(nodata)) then return
  fname = local_datapath+i2str(shot,digits=5)+signal_in+'.sav'
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
  time = dindgen(n_elements(data))*sampletime+starttime
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
  forward_function getdata_cas
  data = getdata_cas(shot,r[0],fix(r[1]),path=castor_path,time=time)
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

  ; Creating a modified signal name for use as a filename to store data locally
  mod_sig = signal_in
  ; Removing / from signal name
  ind = strsplit(mod_sig,'/')
  if (n_elements(ind) gt 1) then begin
    mod_sig_save = mod_sig
    mod_sig = ''
    ind1 = [ind, strlen(mod_sig_save)+1]
    for i=0, n_elements(ind)-1 do begin
      mod_sig = mod_sig+strmid(mod_sig_save,ind1[i],(ind1[i+1]-ind1[i])-1)
    endfor
  endif
  ; Removing : from signal name
  ind = strsplit(mod_sig,':')
  if (n_elements(ind) gt 1) then begin
    mod_sig_save = mod_sig
    mod_sig = ''
    ind1 = [ind, strlen(mod_sig_save)+1]
    for i=0, n_elements(ind)-1 do begin
      mod_sig = mod_sig+strmid(mod_sig_save,ind1[i],(ind1[i+1]-ind1[i])-1)
    endfor
  endif
  ; Trying to open local datafile
  fname = dir_f_name(local_datapath,'TEXTOR_'+i2str(shot,digits=5)+'_'+strupcase(mod_sig)+'.sav')
  openr,unit,fname,/get_lun,error=error
  if (error eq 0) then begin
    close,unit & free_lun,unit
    restore,fname
    time = dindgen(n_elements(data))*sampletime+starttime
  endif else begin
  ; Some virtual signals:
    real_signal = ''
    if (strupcase(signal_in) eq 'REFL_B_SIN') then real_signal = 'sdf/refl/c21'
    if (strupcase(signal_in) eq 'REFL_B_COS') then real_signal = 'sdf/refl/c22'
    if (strupcase(signal_in) eq 'REFL_C_SIN') then real_signal = 'sdf/refl/c23'
    if (strupcase(signal_in) eq 'REFL_C_COS') then real_signal = 'sdf/refl/c24'
    if (strupcase(signal_in) eq 'REFL_D_SIN') then real_signal = 'sdf/refl/c25'
    if (strupcase(signal_in) eq 'REFL_D_COS') then real_signal = 'sdf/refl/c26'
    if (strupcase(signal_in) eq 'REFL_E_SIN') then real_signal = 'sdf/refl/c27'
    if (strupcase(signal_in) eq 'REFL_E_COS') then real_signal = 'sdf/refl/c28'
    if (real_signal ne '') then begin
      get_rawsignal,shot,real_signal,time,data,errormess=errormess,$
         data_source=data_source,trange=trange,sampletime=sampletime,$
         datapath=datapath,local_datapath=local_datapath
      if (errormess ne '') then begin
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data = 0
        time = 0
        return
      endif
      data_available = 1
    endif

    ; Some composite virtual signals
    ; Reflectometry phase and amplitude
    if (strmatch(signal_in,'REFL_[B,C,D,E]_AMP',/fold_case) $
        or strmatch(signal_in,'REFL_[B,C,D,E]_PHASE',/fold_case) $
        or strmatch(signal_in,'REFL_[B,C,D,E]_COMP',/fold_case)) then begin
      get_rawsignal,shot,strmid(signal_in,0,7)+'SIN',time_sin,data_sin,errormess=errormess,$
         data_source=data_source,trange=trange,sampletime=sampletime,$
         datapath=datapath,local_datapath=local_datapath
      if (errormess ne '') then begin
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data = 0
        time = 0
        return
      endif
      get_rawsignal,shot,strmid(signal_in,0,7)+'COS',time,data_cos,errormess=errormess,$
         data_source=data_source,trange=trange,sampletime=sampletime,$
         datapath=datapath,local_datapath=local_datapath
      if (errormess ne '') then begin
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data = 0
        time = 0
        return
      endif
      ind = where(time_sin ne time)
      if (ind[0] ne '-1') then begin
        errormess = 'Reflectometry sine and cosine signal time vectrors are different.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data = 0
        time = 0
        return
      endif
      if (strmatch(signal_in,'REFL_[B,C,D,E]_AMP',/fold_case)) then begin
        ; Calculating amplitude
        data = sqrt(data_sin^2+data_cos^2)
        data_available = 1
      endif
      if (strmatch(signal_in,'REFL_[B,C,D,E]_PHASE',/fold_case)) then begin
        ; Calculating phase
        data = atan(data_cos,data_sin)
        data_available = 1
      endif
      if (strmatch(signal_in,'REFL_[B,C,D,E]_COMP',/fold_case)) then begin
        ; Calculating phase
        data = complex(data_cos,data_sin)
        data_available = 1
      endif
    endif

    if (not keyword_set(data_available)) then begin
      ; Try to get from web umbralla if signal is not available locally
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

      ; Trying 1 times
      result = ''
      for i=0,1 do begin
        twuget_fluc, time, data, PULSENUMBER = shot, SIGNALNAME = sss
;        result= twu_read_signal(dfp, url, data, time, sig_type)
        result='OK' ; No error handling
        ;print,i,result,' ',n_elements(time)
        if (result eq 'OK') and (n_elements(time) gt 1) then break
      endfor
      if ((result ne 'OK') or (n_elements(time) lt 1)) then begin
        errormess = 'Error reading data.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data = 0
        time = 0
      endif
    endif
    sampletime = (time[n_elements(time)-1]-time[0])/(n_elements(time)-1)
    starttime = time[0]
    if (keyword_set(store_data)) then begin
      save,sampletime,starttime,data,file=fname
    endif
  endelse ; If data is read from web umbrella
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

  read_ni6115,dir_f_name(datapath,i2str(shot)+'.dat'),ch,config=$
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
if (data_source eq 22) then begin


   sigarr=str_sep(signal_in, 'ch')
   ch=fix(sigarr[1])

   filename = dir_f_name('data','AUG_'+i2str(shot)+'_'+signal_in+'.sav')
   openr,u,filename,/get_lun,error=error
   if (error eq 0) then begin
     close,u & free_lun,u
     restore,filename
     time = findgen(n_elements(data))*sampletime+starttime
   endif else begin
     forward_function read_mirnov_channels
     a=read_mirnov_channels(shot=shot,channel=ch,ch_name=ch_name,$
                 /equidistant,no_data=nodata)

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
    starttime = time[0];
    save,data,starttime,shot,signal_in,ch,sampletime,file=filename
  endelse

endif
;--------------------END AUG MIRNOV ---------------------------------
;********************************************************************


; ******************* MAST data ************************
if (data_source eq 23) then begin
  if (keyword_set(nodata)) then return

  if (keyword_set(filename)) then begin
    s=1
    forward_function read_data
    a = read_data (s, signal_in, source='IDA::'+datapath+filename)
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
    forward_function getlasthandle
    handle=getlasthandle()
    forward_function freeidam
    rc=freeidam(handle)
  endif else begin
    ; Trying to translate some virtual signal names
    ; check for xsx_combined_
    ; There are all the horizontal SX signals starting from the bottom going to the top
    if (strupcase(strmid(signal_in,0,12)) eq 'XSX_COMBINED') then begin
      chn = fix(strmid(signal_in,13))
      xsx_names=['xsx_hcamu#16','xsx_hcamu#15','xsx_hcamu#14','xsx_hcamu#13','xsx_hcamu#12','xsx_hcamu#11','xsx_hcamu#10',$
                 'xsx_hcamu#9','xsx_hcamu#8','xsx_hcamu#7','xsx_hcamu#6','xsx_hcamu#5','xsx_hcamu#4','xsx_hcamu#3',$
                 'xsx_hcaml#1','xsx_hcaml#2','xsx_hcaml#3','xsx_hcaml#4','xsx_hcaml#5','xsx_hcaml#6','xsx_hcaml#7',$
                 'xsx_hcaml#8','xsx_hcaml#9','xsx_hcaml#10','xsx_hcaml#11','xsx_hcaml#12','xsx_hcaml#13','xsx_hcaml#14',$
                 'xsx_hcaml#15','xsx_hcaml#16']
      signnal_orig_mast = signal_in
      signal_in = xsx_names[chn-1]
    endif

    ; Trying to read stored data
    mod_sig = signal_in
    ; Removing /-s from signal name
    for i=0, strlen(signal_in) do begin
      ind = stregex(mod_sig,'/')
      if (ind[0] ge 0) then begin
        mod_sig_save = mod_sig
        mod_sig = strmid(mod_sig_save,0,ind[0])+'_'+strmid(mod_sig_save,ind[0]+1,strlen(mod_sig_save)-ind[0]-1)
      endif else begin
        break
      endelse
    endfor
    buffname = dir_f_name('data','MAST_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')

    openr,unit,buffname,/get_lun,error=error
    if (error ne 0) then begin
      s=shot
      forward_function read_data
      a = read_data (s, signal_in)
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
      if (keyword_set(store_data)) then begin
        save,shot,starttime,sampletime,data,file=buffname
      endif
      time = a.taxis.VECTOR
      forward_function getlasthandle
      handle=getlasthandle()
      forward_function freeidam
      rc=freeidam(handle)
    endif else begin
      ; Restoring stored data
      close,unit
      free_lun,unit
      data=0 & shot=0 & sampletime=0 & starttime=0;
      restore,buffname
      time = dindgen(n_elements(data))*sampletime+starttime
    endelse

    ; Do some processing if BES data (e.g. multiply by -1, calibrate and subtract offset)
    if ((strmid(signal_in,0,12) eq 'xbs_channel_')) then begin
      data = -1.0*data
      ; Do offset subtraction
      if (n_elements(offset_timerange) ge 2) then begin
        ind = where((time ge offset_timerange[0]) and (time le offset_timerange[1]))
        if (ind[0] ge 0) then begin
          data = data - mean(data[ind])
        endif
      endif
      ; Do calibration
      if (not keyword_set(nocalibrate)) then begin
        ; Load calibration table
        caltable = loadncol(dir_f_name('cal','mast_bes_caltable.dat'),2,header=3,errormess=e,/silent)
        if (e ne '') then begin
           print,'WARNING: Cannot do calibration.'
           print,e
        endif else begin
          ind = where(caltable[*,0] eq shot)
          ; If shot not found in calibration table, get closest calibration shot
          if (ind[0] lt 0) then begin
            ind = closeind(caltable[*,1],shot)
          endif
          ind = ind[0]
          ch = fix(strmid(signal_in,12,1))
          ; Read calibration profile
          cal = loadncol(dir_f_name('cal','mast_bes_'+i2str(caltable[ind,1],digits=5)+'.cal'),1,/silent)
          ; Calibrate
          data = data/(cal[ch-1]/(total(cal)/n_elements(cal)))
        endelse
      endif

    endif
  endelse


endif
; ****************** End of MAST data source

;******************* NI-6133 measurements ********************

; Added on 2007. 01. 10.                                by Daniel Dunai
;
if (data_source eq 24) then begin

  sigarr=str_sep(signal_in, 'ch')

  ch=fix(sigarr[1])

  ; config fileban
  ;start_time
  ;meas_time
  ;sample_rate (long)
  ;number of samples
  ;number of channels
  ;gain

  fname = dir_f_name(dir_f_name(datapath,i2str(shot)),i2str(shot)+'.dat')
  read_nidata,fname,ch,config=config,errormess=errormess,data=data,time=time
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
;******************* END of NI-6133 measurements ********************



;******************* TEXTOR LI beam measurements ********************

; Added on 2008. 02. 29.                                by Daniel Dunai
;
if (data_source eq 25) then begin
  ; Uncalibrated data is returned as default for TECTOR Li-BES
  ; Use nocalibrate=1 to return calibrated data
  default,nocalibrate,1
  ; Checking for signal names ADC-xx
  ; If this is requested no configuration file is read, and the raw ADC channels are read.
  if (strupcase(strmid(signal_in,0,4)) eq 'ADC-') then begin
    if (subchannel ne 0) then begin
      errormess = 'Subchannels cannot be read from raw ADC data.'
      return
    endif
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = fix(strmid(signal_in,4,2))
    endif else begin
      errormess = 'Invalid channel number in name ADC-xx.'
      return
    endelse
    catch,/cancel
    chn = 16

  endif else begin
    ; Checking channels in configuraton file
    load_config_parameter,shot,'ADCSettings','ChannelNumber',data_source=data_source,errormess=errormess,output_struct=s,datapath=datapath,/silent
    if (errormess ne '') then return

    chn = s.value

    chi = -1
    for i=1,chn do begin
      load_config_parameter,shot,'ADCSettings','Signal'+i2str(i),data_source=data_source,errormess=errormess,output_struct=s,datapath=datapath,/silent
      if (errormess ne '') then return
      if  s.value eq signal_in then begin
        chi = i
        break
      endif
    endfor
    if chi lt 1 then begin
      errormess = 'Channel is not available in this shot.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
      print,errormess
      endelse
      data_b=0
      time_b=0
      return
    endif
  endelse ; if real signal name

  if (subchannel ne 0) then begin
    deflection_config,shot,signal_in,period_n=period_sample_n,period_cycle_n=period_cycle_n,mask_up=mask_up,mask_down=mask_down,$
                      start_samp=start_sample,starttime=starttime,period_time=period_time,errormess=errormess,datapath=datapath
    if (errormess ne '') then begin
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data_b=0
      time_b=0
      return
    endif
  endif

  ;read the shot file
  fname = dir_f_name(dir_f_name(datapath,i2str(shot)),i2str(shot)+'.dat')
  read_nidata,fname,chi,config=config,errormess=errormess,data=data,time=time,nodata=nodata
  if (keyword_set(errormess)) then begin
    ; Try at an alternative location <shot>/data'
    fname1 = dir_f_name(dir_f_name(datapath,dir_f_name(i2str(shot),'data')),i2str(shot)+'.dat')
    read_nidata,fname1,chi,config=config,errormess=errormess,data=data,time=time,nodata=nodata
    if (keyword_set(errormess)) then begin
      errormess = 'Could not open data file at either '+fname+' or '+fname1
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

  ;read the background signal file
  if (not keyword_set(nodata) and not keyword_set(no_offset)) then begin
    fname = dir_f_name(dir_f_name(datapath,i2str(shot)),i2str(shot)+'_back.dat')
    read_nidata,fname,chi,config=config_back,errormess=errormess,data=data_b,time=time_b
    if (keyword_set(errormess)) then begin
      ; Try at an alternative location <shot>/data'
      fname = dir_f_name(dir_f_name(datapath,dir_f_name(i2str(shot),'data')),i2str(shot)+'_back.dat')
      read_nidata,fname,chi,config=config_back,errormess=errormess,data=data_b,time=time_b
      if (keyword_set(errormess)) then begin
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data_b=0
        time_b=0
        return
      endif
    endif
    ;substract the electrical background and invert the signal (amplifier inverts)
    data=-(data-mean(data_b))
    time = time+config.start_time
  endif  ;  if nodata

  sampletime = 1./config.sample_rate
  if (keyword_set(nodata)) then return

  if (not keyword_set(nocalibrate)) then begin
    forward_function getcal_textor
    c = getcal_textor(shot,errormess=errormess,channels=chnames)
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
    cali = where(strupcase(signal_in) eq strupcase(chnames))
    if (cali[0] lt 0) then begin
      errormess = 'Cannot find channel '+channel_in+' in calibration file.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    c = c[cali[0]]
    data = data/c
  endif

  if (subchannel ne 0) then begin
    if (not defined(subch_mask)) then begin
      if (subchannel eq 1) then mask=mask_down
      if (subchannel eq 2) then mask=mask_up
    endif else begin
      mask = subch_mask
    endelse
    default,trange,[starttime,starttime+(period_cycle_n-1.)*sampletime]
    trange=float(trange)
    if (trange[0] lt starttime) then trange[0] = starttime
    if (trange[0] ge trange[1]) then begin
      errormess='Start of time interval is after end of interval.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
       data=0
       time=0
       return
    endif
    if (trange[1] gt starttime+(period_cycle_n-1.)*period_time) then begin
      trange[1] = starttime+(period_cycle_n-1.)*period_time
    endif
    start_period = long((trange(0)-starttime)/(period_time))
    end_period = long((trange(1)-starttime)/(period_time))
    interval_start_sample = long(start_period)*period_sample_n+start_sample
    interval_stop_sample = (long(end_period)+1)*period_sample_n+start_sample-1
    if (interval_start_sample lt 0) then begin
      errormess = 'Requested time interval starts before start time of measurement.'
    endif
    if (interval_stop_sample ge n_elements(data)) then begin
      errormess = 'Requested time interval ends after end of measurement.'
    endif
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
    data = data[interval_start_sample:interval_stop_sample]
    time = time[interval_start_sample:interval_stop_sample]
    ind = lonarr((end_period-start_period+1)*n_elements(mask))
    ind1 = lindgen(end_period-start_period+1)*period_sample_n
    ind2 = lindgen(end_period-start_period+1)*n_elements(mask)
    for i=0,n_elements(mask)-1 do ind(ind2+i) = ind1+mask(i)
    data = data(ind)
    time = time[ind]

  endif  ;; subchannel ne 0
endif ; data_source 25

;******************* END of TEXTOR LI beam measurements ********************

;******************* JET JPF data ******************************************
if (data_source eq 26) then begin
  mod_sig = signal_in
  ; Removing / from signal name
  ind = stregex(signal_in,'/')
  if (ind[0] ge 0) then begin
    mod_sig_save = mod_sig
    mod_sig = ''
    for i=0, n_elements(ind) do begin
      ind1 = [-1, ind, strlen(signal_in)]
      mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+1,(ind1[i+1]-ind1[i])-1)
    endfor
  endif
  ; Removing : from signal name
  ind = stregex(mod_sig,':')
  if (ind[0] ge 0) then begin
    mod_sig_save = mod_sig
    mod_sig = ''
    for i=0, n_elements(ind) do begin
      ind1 = [-1, ind, strlen(signal_in)]
      mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+1,(ind1[i+1]-ind1[i])-1)
    endfor
  endif
  fname = dir_f_name(local_datapath,'JET-JPF_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')
  openr,unit,fname,/get_lun,error=error
  if (error eq 0) then begin
    close,unit & free_lun,unit
    restore,fname
    time = dindgen(n_elements(data))*sampletime+starttime
  endif else begin
    jpfget, node=signal_in, pulno=shot, data=data, tvec=time, unit=unit,$
            pulsefile='JPF', type='ON', ier=ier
    if (ier ne 0) then begin
      errormess = 'Error reading JET JPF data. Shot: '+i2str(shot)+', signal:'+signal_in+', error code:'+i2str(ier)
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    ; The JPF data is returned as float, which means the time vector might not have the resolution required.
    ; We solve this by calculating the effective sampling time and generating a new time vector assuming equidistant sampling
    ndata = n_elements(time)
    sampletime = double(time[ndata-1]-time[0])/double(ndata-1);
    sampletime = round(sampletime/1e-8)*double(1e-8)
    time = time[0]+dindgen(ndata)*sampletime
    if (keyword_set(store_data)) then begin
      starttime = time[0]
      save,sampletime,starttime,data,file=fname
    endif
  endelse
endif ; data_source 26 (JET-JPF)
;******************* END of JET JPF data ***********************************

;******************* JET PPF data ******************************************
if (data_source eq 27) then begin
  mod_sig = signal_in
  ; Removing / from signal name
  ind = stregex(signal_in,'/')
  if (ind[0] ge 0) then begin
    mod_sig_save = mod_sig
    mod_sig = ''
    for i=0, n_elements(ind) do begin
      ind1 = [-1, ind, strlen(signal_in)]
      mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+1,(ind1[i+1]-ind1[i])-1)
    endfor
  endif
  ; Removing : from signal name
  ind = stregex(mod_sig,':')
  if (ind[0] ge 0) then begin
    mod_sig_save = mod_sig
    mod_sig = ''
    for i=0, n_elements(ind) do begin
      ind1 = [-1, ind, strlen(signal_in)]
      mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+1,(ind1[i+1]-ind1[i])-1)
    endfor
  endif
  fname = dir_f_name(local_datapath,'JET-PPF_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')
  openr,unit,fname,/get_lun,error=error
  if (error eq 0) then begin
    close,unit & free_lun,unit
    restore,fname
  endif else begin
    ; Signal name is expected to have DDA/Datatype form
    ; Finding '/' in name
    if (strpos(signal_in,'/') gt 0) then begin
      w=str_sep(signal_in,'/')
      ; The first is the DDA
      dda = w[0]
      ; All the rest is the Datatype
      datatype =w[1]
      if (n_elements(w) gt 2) then begin
        for i=2,n_elements(w)-1 do begin
          datatype = datatype+'/'+w[i]
        endfor
      endif
    endif else begin
      errormess = 'Missing DDA name in JET PPF signal name:'+signal_in
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endelse

    ppfread,shot=shot,dda=dda,dtype=datatype,data=data,t=time,ierr=ierr
    if (ierr ne 0) then begin
      errormess = 'Error reading JET PPF data. Shot: '+i2str(shot)+', dda:'+dda+', dtype:'+datatype+', error code:'+i2str(ierr)
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    sampletime = time[1]-time[0];
    if (keyword_set(store_data)) then begin
      save,sampletime,time,data,file=fname
    endif
  endelse
endif ; data_source 27 (JET-PPF)
;******************* END of JET PPF data ***********************************


;******************* ITER CXRS BES test using APDCAM ********************

; Added on 2011.03.16   S. Zoletnik
;
if (data_source eq 29) then begin

    ; Checking channels in configuraton file
    load_config_parameter,shot,'ADCSettings','ActiveChannelNumber',data_source=data_source,errormess=errormess,output_struct=s,datapath=datapath,/silent
    if (errormess ne '') then return

    chn = s.value

    chi = -1
    for i=1,chn do begin
      load_config_parameter,shot,'ADCSettings','Signal'+i2str(i),data_source=data_source,errormess=errormess,output_struct=s,datapath=datapath,/silent
      if (errormess ne '') then return
      if  s.value eq signal_in then begin
        chi = i
        break
      endif
    endfor
    if chi lt 1 then begin
      errormess = 'Channel is not available in this shot.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
      print,errormess
      endelse
      data_b=0
      time_b=0
      return
    endif


  ;read the data file
  fname = dir_f_name(dir_f_name(datapath,i2str(shot)),dir_f_name('data',i2str(shot)+'_data.sav'))
  catch,error
  if (error ne 0) then begin
    errormess = 'Cannot open data file: '+fname
    if (not keyword_set(silent)) then print,errormess
    catch,/cancel
    data_b=0
    time_b=0
    return
  endif else begin
    restore,filename=fname
    catch,/cancel
  endelse


  sampletime = double((time_out[n_elements(time_out)-1]-time_out[0]))/(n_elements(time_out)-1)
  if (keyword_set(nodata)) then return

  data = data_out[chi-1,*]
  time = time_out
endif

;******************* ITER CXRS BES test using APDCAM ********************

;******************* MAST-NC -> MAST NETCDF data tree  ********************

; Added on 2011.05. 01   D. Dunai
; using getdata function
; Added local file suppor S. Zoletnik

if (data_source eq 30) then begin

  if (keyword_set(nodata)) then return
  notdef=1

  ; Try xbs_channel name e.g.  xbs_channel01
  a = stregex(signal_in,'xbs_channel[0-3][0-9]')
  if (a[0] lt 0) then begin
    ; Not found
    ; Try BES-?-?   e.g. BES-1-3
    a = stregex(signal_in,'BES-[1-4]-[1-8]')
    if (a[0] ge 0) then begin
      ; if BES-x-x name
      notdef = 0
      name_type = 1
      apd_row = fix(strmid(signal_in,a[0]+4,1))
      apd_col = fix(strmid(signal_in,a[0]+6,1))
      if ((apd_row lt 1) or (apd_row gt 4) or (apd_col lt 0) or (apd_col gt 8)) then begin
        errormess = 'Unknown channel: '+signal_in
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess, /forward
        endif else begin
          print,errormess
        endelse
        time = 0
        data=0
        return
      endif
      apd_chan = (apd_row-1)*8+apd_col-1
    endif
  endif else begin
    notdef = 0
    name_type = 0
    a = stregex(signal_in,'xbs_channel')
    apd_chan = fix(strmid(signal_in,a[0]+11,2))
      if (apd_chan gt 31) then begin
        errormess = 'Unknown channel: '+signal_in
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess, /forward
        endif else begin
          print,errormess
        endelse
        time = 0
        data=0
        return
      endif
  endelse
  if (notdef eq 0) then begin
    ; This is xbs_channel or BES- signal
    ; Try local data
    catch,error
    if (error eq 0) then begin
      restore, datapath+'/'+i2str(shot)+'_xbt.sav'
    endif
    catch,/cancel
    if defined(xbt) then begin
;     print, 'APD_channel from local file: channel: '+i2str(apd_chan+1)
      time = xbt.time
      sampletime = time[1]-time[0]
      if keyword_set(no_offset) then begin
        data=xbt.apd_data[apd_chan, *]
      endif else begin
        ; offset
        data=xbt.apd_data[apd_chan, *]
        offset_ind=where(time lt 0.)
        if n_elements(offset_ind) gt 1 then begin
          data=data-mean(data[offset_ind])
        endif
      endelse  ;end offset

      ; We store all channels in the cache if /cache is set
      ; We do not store here if the cache name is explicitely set as it would apply for a single channel
      if (keyword_set(cache) and (size(cache,/type) ne 7)) then begin
        chn = (size(xbt.apd_data))[1]
        if (name_type eq 0) then begin
          ; xbs_channel... type name
          basename = i2str(shot)+'_'+full_signal_in
          basename = (strsplit(basename,'channel',/extract))[0]+'channel'
        endif else begin
          basename = i2str(shot)+'_'+full_signal_in
          a = stregex(basename,'BES-[1-4]-[1-8]')
          basename = strmid(basename,0,a[0]+4)
        endelse
        time = xbt.time
        sampletime = time[1]-time[0]
        for apd_chan_i=0,chn-1 do begin
          if keyword_set(no_offset) then begin
            data_cache=xbt.apd_data[apd_chan_i, *]
          endif else begin ; offset
            data_cache=xbt.apd_data[apd_chan_i, *]
            offset_ind=where(time lt 0.)
            if n_elements(offset_ind) gt 1 then begin
              data_cache=data_cache-mean(data_cache[offset_ind])
            endif
          endelse  ;end offset
          if (apd_chan eq apd_chan_i) then begin
            data = data_cache
          endif
          if (name_type eq 0) then begin
            cachename = basename+i2str(apd_chan_i+1,digits=2)
          endif else begin
            cachename = basename+i2str((apd_chan_i)/8+1)+'-'+i2str(((apd_chan_i) mod 8)+1)
          endelse
          signal_cache_add,name=cachename,data=data_cache,time=time,starttime=time[0],sampletime=sampletime,errormess=err
        endfor
        already_cached = 1
      endif
    endif else begin   ; end local data
      ;open from MAST_data tree if local file not found
      if ((strmid(signal_in,0,3) eq 'xbt')) then begin
        notdef=0
        ;check if 2d MAST DATA (some preprocessing is needed)
        dir = '$MAST_DATA/'
        ds = getdata(signal_in, 'NETCDF::'+dir+i2str(shot)+'/LATEST/xbt0'+i2str(shot)+'.nc')
        if ds.errmsg ne '' then begin
          if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess, /forward
          endif else begin
            print,ds.errmsg
          endelse
          time = 0
          data=0
          return
        endif
        if keyword_set(no_offset) then begin
          time = ds.time
          data=ds.data
          sampletime = time[1]-time[0]
        endif else begin
          time = ds.time
          data=ds.data
          sampletime = time[1]-time[0]
          offset_ind=where(time lt 0.)
          if n_elements(offset_ind) gt 1 then begin
            data=data-mean(data[offset_ind])
          endif
        endelse
      endif ;end of xbt check

      ;check if it is XBTZ file
      ;reading zshot for 2D BES data
      if ((strmid(signal_in,0,4) eq 'zxbt')) then begin
        notdef=0
        pre = 'xbtz'
        dir = '/net/fuslsa/data/MAST_zSHOT/'
        str1 = i2str(shot)
        str2 = '000000'
        strput, str2, str1, 6 - strlen(str1)
        file = pre+str2

        ds = getdata(signal_in, 'NETCDF::'+dir+'xbt0'+i2str(shot)+'.nc')
        if ds.errmsg ne '' then begin
          if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess, /forward
          endif else begin
            print,ds.errmsg
          endelse
          time = 0
          data=0
          return
        endif
        if keyword_set(no_offset) then begin
          time = ds.time
          data=ds.data
        endif else begin
          time = ds.time
          data=ds.data
          offset_ind=where(time lt 0.)
          if n_elements(offset_ind) gt 1 then begin
            data=data-mean(data[offset_ind])
          endif
        endelse ; if offset
      endif ;end of xbtz check
    endelse  ; if could not open local file
  endif else begin ; end of section: this is BES-1 or xbs_channel signal
    ;If not an xbt or xbtz file but NETCDF file
    ;works only from MAST data_tree
    dir = '$MAST_DATA/'
    ;signal_in first 3 letters plus a 0 character
    first_letters=strmid(signal_in,0, 3)
    ds = getdata(signal_in, 'NETCDF::'+dir+i2str(shot)+'/LATEST/'+first_letters+'0'+i2str(shot)+'.nc')
    if ds.errmsg ne '' then begin
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess, /forward
      endif else begin
         print,ds.errmsg
      endelse
      time = 0
      data=0
      return
    endif
    time = ds.time
    data=ds.data
    sampletime = time[1]-time[0]
    ;save if neede
  endelse ;end of other NETCDF file read

endif  ; data_source eq 30

;******************* MAST-NC -> MAST NETCDF data tree ********************



;******************* AUG data ******************************************
if (data_source eq 31) then begin
  ; Signal name is expected to have user/system/data/channel form
  names = strsplit(signal_in,'/',/extract)
  if (n_elements(names) ne 4) then begin
    errormess = 'Bad AUG signal name:'+signal_in+'. Should have user/system/unit/channel format.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif
  aug_user = names[0]
  aug_system = names[1]
  aug_unit = names[2]
  aug_channel = fix(names[3])
  fname = dir_f_name(local_datapath,'AUG_'+i2str(shot,digits=5)+'_'+aug_user+'_'+aug_system+'_'+aug_unit+'_'+i2str(aug_channel)+'.sav')
  openr,unit,fname,/get_lun,error=error
  if (error eq 0) then begin
    close,unit & free_lun,unit
    restore,fname
  endif else begin
    default,trange,[0,5]
    read_common,shot,trange[0],trange[1],time,aug_user,aug_system,0L,aug_unit,data
    if ((size(data))[0] lt 1) then begin
      errormess = 'Error reading AUG data. Shot: '+i2str(shot)+', signal: '+signal_in
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    if ((size(data))[0] eq 2) then begin
      data = reform(data[*,aug_channel-1])
    endif
    ndata = n_elements(time)
    sampletime = (time[ndata-1]-time[0])/(ndata-1)
    if (keyword_set(store_data)) then begin
      save,sampletime,time,data,file=fname
    endif
  endelse
endif ; data_source 31 (AUG)
;******************* END of AUG data ***********************************


; ***************** KSTAR data *********************************
if (data_source eq 32) then begin
  ; Checking for signal names BES-ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...32
  if (strupcase(strmid(signal_in,0,7)) eq 'BES-ADC') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = fix(strmid(signal_in,7,2))
    endif else begin
      errormess = 'Invalid channel number in name BES-ADCxx.'
      return
    endelse
    catch,/cancel
  endif
  ; Checking for BES-<row>-<column> format. If this is found it will be translated to ADC channels
  ; using apdcam_channel_map.pro
  if (strupcase(strmid(signal_in,0,4)) eq 'BES-') and (strmid(signal_in,5,1) eq '-') then begin
    ; expecting BES-<row>-<column> format
    ; (1,1) is lower-left corner of image in plasma as seen from the optics
    catch,error_catch
    if (error_catch eq 0) then begin
      row = fix(strmid(signal_in,4,1))
      column = fix(strmid(signal_in,6,1))
    endif else begin
      errormess = 'Invalid number in name BES-<row>-<column>.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
    endelse
    data=0
    time=0
    return
    endelse
    catch,/cancel
    if ((row lt 1) or (row gt 4) or (column lt 1) or (column gt 8)) then begin
      errormess = 'Invalid number in name BES-<row>-<column>.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    map=reverse(apdcam_channel_map(data_source=data_source),2)
    chi = map[row-1,column-1]
  endif

  ; If chi is set it contains the channel number for a BES signal
  if (defined(chi)) then begin
    if (not keyword_set(nodata)) then begin
      ; Loading various parameters from the config file. If these are not available (e.g. no confog file)
      ; there are defaults after this block
      adc_block = fix((chi-1)/8)
      load_config_parameter,shot,'ADCSettings','ChannelMask'+i2str(adc_block+1),data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        mask = ishft(1,(chi-1) mod 8)
        if (s.value and mask eq 0) then begin
          errormess = 'Channel is not available in this shot.'
          if (not keyword_set(silent)) then print,errormess
          return
        endif
      endif

      load_config_parameter,shot,'ADCSettings','Trigger',data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        trigger= s.value
        if (trigger lt 0) then trigger = 0
      endif

      load_config_parameter,shot,'ADCSettings','ADCMult',data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        ADC_Mult= s.value
      endif

      load_config_parameter,shot,'ADCSettings','ADCDiv',data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        ADC_Div= s.value
      endif

      load_config_parameter,shot,'ADCSettings','Samplediv',data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        samplediv= s.value
      endif

      load_config_parameter,shot,'ADCSettings','SampleNumber',data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        samplenumber= s.value
      endif

      load_config_parameter,shot,'ADCSettings','Bits',data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        bits= s.value
      endif

      ; These are the defaults in case any of these were missing. This can happen in very early shots.
      default,trigger,0
      default,ADC_Mult,20
      default,ADC_Div,40
      default,samplediv,5
      default,bits,12

; If offset_timerange not set in local_config.dat, 0.1s background correction after the beginning of the sampling.
      if (n_elements(offset_timerange) lt 2) then begin
        offset_timerange = [trigger,trigger+0.1]
      endif

      ; Calculating sampletime
      adclk = 20.0*ADC_mult/ADC_div
      sclk = adclk/samplediv
      sampletime = 1./(sclk*1e6)

      default,samplenumber,long(6./sampletime)

      ; If trange is set we will read only the necesary samples
      if (n_elements(trange) eq 2) then begin
        samplenumber_start = long((trange[0]-trigger)/sampletime)
        if (samplenumber_start lt 0) then begin
          errormess = 'Timerange is before start time of measurement.'
          if (not keyword_set(silent)) then print,errormess
          return
        endif
        samplenumber_read = long(((trange[1]-trange[0]) > 0)/sampletime)
        if (samplenumber_read+samplenumber_start gt samplenumber) then begin
          errormess = 'Timerange end is after end time of measurement.'
          if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess,/forward
          endif else begin
          print,errormess
          endelse
          data=0
          time=0
          return
        endif
      endif else begin
        ; if trange is not set we read all data
        samplenumber_start = 0
        samplenumber_read = samplenumber
      endelse

      ;read the shot file
      datafile = dir_f_name(dir_f_name(datapath,i2str(shot)),'Channel'+i2str(chi-1,digit=2)+'.dat')
      openr,unit,datafile,/get_lun,error=error
      if (error ne 0) then begin
        errormess = 'Error opening file: '+datafile
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data=0
        time=0
        return
      endif
      on_ioerror,loaderr
      a = assoc(unit,intarr(samplenumber_read),samplenumber_start*2)
      data = reform(a[0])

      if (not keyword_set(no_offset)) then begin
        ; Determining offset. The offset timerange comes from fluct_local_config
        offset_sample_start = long((offset_timerange[0]-trigger)/sampletime) > 0
        offset_sample_end = long((offset_timerange[1]-trigger)/sampletime) > 0
        if (offset_sample_end-offset_sample_start gt 0) then begin
          if (offset_sample_start ge samplenumber_start) and $
          ; if data is already read in
            (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
            offset = mean(data[offset_sample_start:offset_sample_end-1])
          endif else begin
            ; reading offset data
            on_ioerror,loaderr_offset
            a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
            offset = mean(a[0])
          endelse
        endif else begin
          loaderr_offset:
          ; As a final resort we do not subtract offset
          offset = 0
        endelse
        data = data-offset
      endif ; offset correction
      close,unit & free_lun,unit
      ; Scaling to volts
      data = data*(2. / 2.^bits)

      ; Do calibration for BES-x-x channels
      forward_function getcal_kstar
      if (not keyword_set(nocalibrate) and (strupcase(strmid(signal_in,0,4)) eq 'BES-') and (strmid(signal_in,5,1) eq '-')) then begin
        forward_function getcal_kstar
        c=getcal_kstar(shot,channels=channels,errormess=errormess)
        if (n_elements(c lt 32)) then begin
          data = 0
          time = 0
          return
        endif
        ind = where(strupcase(signal_in) eq strupcase(channels))
        if (ind[0] lt 0) then begin
          data = 0
          time = 0
          errormess = 'Cannot find calibration data for channel '+signal_in+' in calibration file.'
          return
        endif
        data = data/c[ind[0]]
      endif
      time = dindgen(n_elements(data))*sampletime+trigger+samplenumber_start*sampletime
      goto,get_rawsignal_end

  loaderr:
        free_lun,unit
        errormess = 'Error reading data file '+datafile
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data=0
        time=0
        return
      endif else begin
        time = 0
        data = 0
        return
      endelse
  endif else begin
    ; Checking for ECEI/ECEI_[H,L]<row><column> format.
    ecei_name = stregex(strupcase(signal_in),'ECEI/ECEI_[H,L][0-2][0-9]0[1-8]',/extract)
    if (ecei_name ne '') then begin
      ; Found ECEI channel name
      datafile = dir_f_name(dir_f_name(datapath,i2str(shot)),'ecei-kstar-'+$
                   strlowcase(strmid(ecei_name,10,1))+'fs.'+i2str(shot,digits=8)+'.hdf5')
      openr,unit,datafile,/get_lun,error=e
      if (e ne 0) then begin
        errormess = 'Error opening file: '+datafile
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data=0
        time=0
        return
      endif
      close,unit & free_lun,unit
      if (H5F_IS_HDF5(datafile) ne 1) then begin
        errormess = 'File '+file+' is not a HDF5 file.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data=0
        time=0
        return
      endif
      ; Opening HDF file
      file_id = H5F_OPEN(datafile)
      ; Opening ECEI datagroup
      datagroup_id = H5G_OPEN(file_id, '/ECEI')
      ; Reading timing info
      attr = H5A_OPEN_NAME(datagroup_id,'StartTime')
      starttime = H5A_READ(attr)
      starttime = starttime[0]
      H5A_CLOSE,attr
      attr = H5A_OPEN_NAME(datagroup_id,'SampleRate')
      samplerate = H5A_READ(attr)
      sampletime = 1./double(samplerate[0])
      H5A_CLOSE,attr
      attr = H5A_OPEN_NAME(datagroup_id,'SampleNum')
      samplenum= H5A_READ(attr)
      samplenum = samplenum[0]
      H5A_CLOSE,attr
      dataset_id = H5D_OPEN(file_id, ecei_name+'/Voltage')
      ds = h5d_get_space(dataset_id)
      ; Reading data
      if (keyword_set(trange)) then begin
        start_id = long((trange[0]-starttime)/sampletime) > 0
        stop_id = long((trange[1]-starttime)/sampletime) < samplenum-1
        n_read = stop_id-start_id+1
        H5S_SELECT_HYPERSLAB, ds, [start_id],[n_read],/reset
        ms = H5S_CREATE_SIMPLE([n_read])
        data = float(H5D_READ(dataset_id,memory_space=ms,file_space=ds))
        h5s_close,ds
      endif else begin
        data = float(H5D_READ(dataset_id))
        start_id = 0
        stop_id = samplenum-1
        n_read = stop_id-start_id+1
      endelse
      h5d_close,dataset_id

      time = findgen(n_read)*sampletime+starttime+start_id*sampletime
    endif else begin ; end ECEI data from file
      ; This is a KSTAR signal
      ; Virtual name translation
      case strupcase(signal_in) of
        'IP': mdsplus_name = '\PCRC03/(-1000000.)'
        'P_NBI' : mdsplus_name = '(((\nb11_vg1))/1.5+4)*(DATA(\nb11_ig1))*0.58/1000'
        'P_ECRH' : mdsplus_name = '(ECH_VFWD1:FOO-0.23)*105/1000.'
        'E_NBI' : mdsplus_name = '(\nb11_vg1)'
        else: mdsplus_name = signal_in
      endcase

      ; Trying to read from local data directory
      ; First modifying data name to be used in file name
      mod_sig = mdsplus_name
      ; List of characters which will be removed to prevent conflict with op. system
      remove_chars = ['/',':','\\','\*']
      for ii=0,n_elements(remove_chars)-1 do begin
        while (1) do begin  ; we need this cycle as stregex return only the first match
          ; Removing these characters from signal name
          ind = stregex(mod_sig,remove_chars[ii])
          if (ind[0] ge 0) then begin
            mod_sig_save = mod_sig
            mod_sig = ''
            for i=0, n_elements(ind) do begin
              ind1 = [-1, ind, strlen(mdsplus_name)]
              mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+1,(ind1[i+1]-ind1[i])-1)
            endfor
          endif else begin
            break
          endelse
        endwhile
      endfor
      fname = dir_f_name(local_datapath,'KSTAR_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')
      openr,unit,fname,/get_lun,error=error
      if (error eq 0) then begin
        close,unit & free_lun,unit
        restore,fname
      endif else begin
        ; Reading from MDSPlus
        read_kstar_mdsplus,shot,mdsplus_name,time,data,erormess=errormess,no_time=no_time
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
        if (not keyword_set(no_time)) then begin
          sampletime = double(time[n_elements(time)-1]-time[0])/(n_elements(time)-1)
        endif else begin
          sampletime = 0
        endelse
        if (keyword_set(store_data)) then begin
          save,sampletime,time,data,file=fname
        endif
      endelse ; reading MDSPlus

    endelse ;  This is KSTAR signal
  endelse ; this is not a KSTAR BES signal
endif ; data_source 32

; ***************** JET KY6D Li-beam APDCAM raw data stored in PC *********************************
if (data_source eq 33) then begin
  ; Checking for signal names BES-ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...32
  if (strupcase(strmid(signal_in,0,7)) eq 'BES-ADC') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = fix(strmid(signal_in,7,2))
    endif else begin
      errormess = 'Invalid channel number in name BES-ADCxx.'
      return
    endelse
    catch,/cancel
  endif
  ; Checking for BES-<row>-<column> format. If this is found it will be translated to ADC channels
  ; using apdcam_channel_map.pro
  if (strupcase(strmid(signal_in,0,4)) eq 'BES-') and (strmid(signal_in,5,1) eq '-') then begin
    ; expecting BES-<row>-<column> format
    ; (1,1) is lower-left corner of image in plasma as seen from the optics
    catch,error_catch
    if (error_catch eq 0) then begin
      row = fix(strmid(signal_in,4,1))
      column = fix(strmid(signal_in,6,1))
    endif else begin
      errormess = 'Invalid number in name BES-<row>-<column>.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
    endelse
    data=0
    time=0
    return
    endelse
    catch,/cancel
    if ((row lt 1) or (row gt 4) or (column lt 1) or (column gt 8)) then begin
      errormess = 'Invalid number in name BES-<row>-<column>.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    map=reverse(apdcam_channel_map(data_source=data_source),2)
    chi = map[row-1,column-1]
  endif

  ; If chi is set it contains the channel number for a BES signal
  if (not defined(chi)) then begin
    errormess = 'Unkown JET KY6D channel.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif

  if (not keyword_set(nodata)) then begin
    ; Loading various parameters from the config file. If these are not available (e.g. no confog file)
    ; there are defaults after this block
    adc_block = fix((chi-1)/8)
    load_config_parameter,shot,'ADCSettings','ChannelMask'+i2str(adc_block+1),data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      mask = ishft(1,(chi-1) mod 8)
      if (s.value and mask eq 0) then begin
        errormess = 'Channel is not available in this shot.'
        if (not keyword_set(silent)) then print,errormess
        return
      endif
    endif

    load_config_parameter,shot,'ADCSettings','Trigger',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      trigger= s.value
      if (trigger lt 0) then trigger = 0
    endif

    load_config_parameter,shot,'ADCSettings','ADCMult',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      ADC_Mult= s.value
    endif

    load_config_parameter,shot,'ADCSettings','ADCDiv',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      ADC_Div= s.value
    endif

    load_config_parameter,shot,'ADCSettings','Samplediv',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      samplediv= s.value
    endif

    load_config_parameter,shot,'ADCSettings','SampleNumber',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      samplenumber= s.value
    endif

    load_config_parameter,shot,'ADCSettings','Bits',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      bits= s.value
    endif

    ; These are the defaults in case any of these were missing. This can happen in very early shots.
    default,trigger,0
    default,ADC_Mult,20
    default,ADC_Div,40
    default,samplediv,5
    default,bits,12

    ; Calculating sampletime
    adclk = 20.0*ADC_mult/ADC_div
    sclk = adclk/samplediv
    sampletime = 1./(sclk*1e6)

    default,samplenumber,long(6./sampletime)

    ; If trange is set we will read only the necesary samples
    if (n_elements(trange) eq 2) then begin
      samplenumber_start = long((trange[0]-trigger)/sampletime)
      if (samplenumber_start lt 0) then begin
        errormess = 'Timerange is before start time of measurement.'
        if (not keyword_set(silent)) then print,errormess
        return
      endif
      samplenumber_read = long(((trange[1]-trange[0]) > 0)/sampletime)
      if (samplenumber_read+samplenumber_start gt samplenumber) then begin
        errormess = 'Timerange end is after end time of measurement.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
        print,errormess
        endelse
        data=0
        time=0
        return
      endif
    endif else begin
      ; if trange is not set we read all data
      samplenumber_start = 0
      samplenumber_read = samplenumber
    endelse

    ;read the shot file
    datafile = dir_f_name(dir_f_name(datapath,i2str(shot)),'Channel'+i2str(chi-1,digit=2)+'.dat')
    openr,unit,datafile,/get_lun,error=error
    if (error ne 0) then begin
      errormess = 'Error opening file: '+datafile
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    on_ioerror,loaderr_ky6d
    a = assoc(unit,intarr(samplenumber_read),samplenumber_start*2)
    data = reform(a[0])
    close,unit & free_lun,unit
    ; Scaling to volts
    data = data*(2. / 2.^bits)
    time = dindgen(n_elements(data))*sampletime+trigger+samplenumber_start*sampletime
    goto,get_rawsignal_end
  loaderr_ky6d:
    free_lun,unit
    errormess = 'Error reading data file '+datafile
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif else begin  ; nodata
    time = 0
    data = 0
    return
  endelse
endif ; data_source 33


get_rawsignal_end:

if (not keyword_set(no_time)) then begin
  default,trange,[min(time),max(time)]
  ind=where((time ge trange(0)) and (time le trange(1)))
  if (ind(0) lt 0) then begin
    errormess='Cannot find signal '+signal_in+' in time interval.'
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

if (defined(radpulse_limit) and not (data_source eq 28)) then begin
  ; Processing only channels which are listed in radpulse_correction_channels is the local default file.
  ; This is a comma separated list of channel masks
  ch_mask = local_default('radpulse_correction_channels')
  if (ch_mask ne '') then begin
    ch_mask = strsplit(ch_mask,',',/extract)
    n_mask = n_elements(ch_mask)
    found = 0
    for i=0,n_mask-1 do begin
      if (strmatch(signal_in,ch_mask[i],/fold_case)) then found = 1
    endfor
    if (found) then begin
      filter_radiation_pulses,data,data_source=data_source,limit=radpulse_limit,n_pulses=n_pulses
    endif
  endif
endif

if (not keyword_set(from_signal_cache) and keyword_set(cache) and not keyword_set(already_cached)) then begin
  if (size(cache,/type) eq 7) then begin  ; string
    signal_cache_add,name=cache,data=data,time=time,starttime=starttime,sampletime=sampeletime,errormess=err
  endif else begin
    cache_name = i2str(shot)+'_'+full_signal_in
    if (defined(subchannel)) then begin
      if (subchannel ne 0) then cache_name = cache_name+'_'+i2str(subchannel)
    endif
    signal_cache_add,name=cache_name,data=data,time=time,starttime=starttime,sampletime=sampletime,errormess=err
  endelse
  if (err ne '') then begin
    print,'Warning: could not store data in signal cache.'
  endif
endif

end
