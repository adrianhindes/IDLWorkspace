pro get_rawsignal,shot,signal_name_in,time,data,errorproc=errorproc,errormess=errormess,$
         data_source=data_source,afs=afs,cdrom=cdrom,trange=trange,data_names=data_names,$
         nocalibrate=nocalibrate,calfac=calfac,sampletime=sampletime,equidist=equidist,$
         no_shift_correct=no_shift_correct,timerange=timerange,$
         correction_method=correction_method,p2_points=p2_points,$
         datapath=datapath,local_datapath=local_datapath,filename=filename,nodata=nodata,$
         subchannel=subchannel,chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
         vertical_norm=vertical_norm,vertical_zero=vertical_zero, store_data=store_data,$
         subch_mask=subch_mask,cache=cache,search_cache=search_cache,offset_timerange=offset_timerange,no_offset=no_offset,$
         filter_radiaton_pulses=radpulse_limit,no_time=no_time, data_tree=data_tree, $
         scaling=scaling, auguser=auguser, reserved=reserved,data_arr=data_arr,offset_type=offset_type, $
         offset_timelength=offset_timelength, sequence=sequence, ppfuid=ppfuid, reread=reread, quiet=quiet

; ************* get_rawsignal.pro ********************** S. Zoletnik *** 1.4.1998
; This is the general routine for reading (calibrated) data from different data source
; If a new data source is added, this routine (and meas_config.pro) should be modified.
; To get a list of available data sources call:
; get_rawsignal,data_names=names
; After return <names> containes a string array, each string is the name of the
; associated data source.
; INPUT:
;  shot: shot number
;  signal_name_in: [<data source>/]<signal name> or numeric channel number (see chan_prefiox and chan_postfix)
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
;               34 --> COMPASS Li-BES  D. Refy 1` April 2013
;               35 --> AUG Li-beam data with APDCAM    S. Zoletnik 4 April 2013
;               36 --> JET JPF/PPF data from BEAM server  (Signal name: 'JPF/DH/Y6-DOWN:001' or 'ppf/cxsm/rcor')
;               37 --> ASDEX MDSPlus reading
;               38 --> APDCAM-10G reading
;               39 --> EAST Li-BES
;               40 --> EAST BES
;               41 --> generalized JET data reader (JPF/PPF/MDSPlus)
;               42 --> COMPASS ABP 1. Dec. 2014 M. Lampert
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
;  /store_data: Store data in IDL save file in dir in local_datapath (available for MAST, JET, MAST_NC)
;  /cache:  Store signal in signal cache using the full signal name (see signal_cache_add.pro)
;    cache='name'  Store signal in signal cache using name as signal name
;  /search_cache: Search cache for signal
;  *** Keywords only for CO_2 laser scattering signals ***
;  /no_shift_correct: Do not apply time shift correction for the shift introduced by the hardware
;  correction_method: Time shift correction method
;  *** end of CO2 scattering keywords
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
;  /scaling: if the switch is on, the programme returns scaled APD data (volts), if it is off it returns integer (digit). default: on
;  offset_type: (JET APDCAM yet...)
;   1: default, calculated from offset_timerange
;   2: offsets collected from the offset.dat file
;   3: calculated from the end of the measurement, the length can be set by offset_timelength parameter in the fluct_local_confog.dat, the default, os 0.1s
;  offset_timelength: time interval backwards from the end of the shot from which the offset is calulcated.
;  sequence: JET-PPF sequence number, integer
;  ppfuid: JET-PPF user id (the one who reated the ppf), string
;  reread: re-read data from data_source, rather than restore from local_datapath (implemented for MDSPlus @ JET), default:0
; OUTPUT:
;  time: time vector
;  data: data vector
;  data_names: available data sources (data_names(data_source) is the name of
;              the actual data source
;  sampletime: time resolution of signal in sec
;  signal: the full name of the signal
;  reserved: any experimnet specifc data in a structure
;  data_arr=data_arr: the full array of the signal group for 31 and 37
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

data_names=['W7-AS Nicolet',$ ;0
            'W7-AS Aurora',$ ;1
            'W7-AS Li-standard',$ ;2
            'AUG Li-standard',$ ;3
            'W7-AS Mirnov',$ ;4
            'AUG Nicolet',$ ;5
            'W7-AS Lscat',$ ;6
            'TEXTOR Li-beam',$ ;7
            'TEXTOR Blow-off',$ ;8
            'TEXTOR Li-beam test',$ ;9
            'W7-AS Blow-off',$ ;10
            'JET Li-beam',$ ;11
            'Numtest',$ ;12
            'NI6115',$ ;13
            'W7-AS ECE',$ ;14
            'JET KK3 ECE',$ ;15
            'General',$ ;16
            'CASTOR',$ ;17
            'MT-1M',$ ;18
            'TEXTOR',$ ;19
            'TEXTOR-HE',$ ;20
            'NI-6115 TEST',$ ;21
            'AUG_mirnov',$ ;22
            'MAST',$ ;23
            'NIDATA',$ ;24
            'TEXTOR Fast Li-beam',$ ;25
            'JET-JPF',$ ;26
            'JET-PPF',$ ;27
            'Cache',$ ;28
            'CXRS-BES', $ ;29
            'MAST-NC',$ ;30
            'AUG',$ ;31
            'KSTAR',$ ;32
            'JET-KY6D',$ ;33
            'COMPASS-APDCAM',$ ;34
            'AUG_LIB_APD',$ ;35
            'JET_MDS',$ ;36
            'ASDEX_MDS', $ ;37
            'APDCAM-10G', $ ;38
            'EAST-LiBES',$ ;39
            'EAST-BES',$ ;40
            'JET',$ ;41
            'COMPASS-ABP'] ;42

default, scaling, 1
default, shot,0
if (defined(timerange)) then trange=timerange
if (defined(trange)) then timerange = trange
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
default, data_tree, local_default('data_tree')

forward_function strsplit
forward_function mdsvalue

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
    sysname = data_names[data_source]
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
  ;fname = local_datapath+i2str(shot,digits=5)+signal_in+'.sav'
  fname = dir_f_name(local_datapath,dir_f_name(i2str(shot,digits=5),signal_in+'.sav'))
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

  mod_sig = signal_in

  ; Removing / from signal name

  find_string=['/']
  for j=0,n_elements(find_string)-1 do begin
      i=0
      while (i NE -1) do begin
        i=strpos(signal_in,find_string[j],i)
        IF (i NE -1) THEN BEGIN
          if not defined(ind) then begin
            ind=i
          endif else begin
            ind=[ind,i]
          endelse
          i=i+1
        endif
      endwhile
  endfor
  ind=ind[sort(ind)]
  if (ind[0] ge 0) then begin
    mod_sig_save = mod_sig
    mod_sig = ''
    for i=0, n_elements(ind) do begin
      ind1 = [-1, ind, strlen(signal_in)]
      mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+1,(ind1[i+1]-ind1[i])-1)
    endfor
  endif

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
    ; Radion pulse correction is done now for the subchannel signal, therefore thsi
    ; is commentes out here
    ; Doing radiation pulse correction for the original signal
    ;if (defined(radpulse_limit)) then begin
    ;  ; Processing only channels which are listed in radpulse_correction_channels in the local default file.
    ;  ; This is a comma separated list of channel masks
    ;  ch_mask = local_default('radpulse_correction_channels')
    ;  if (ch_mask ne '') then begin
    ;    ch_mask = strsplit(ch_mask,',',/extract)
    ;    n_mask = n_elements(ch_mask)
    ;    found = 0
    ;    for i=0,n_mask-1 do begin
    ;      if (strmatch(signal_in,ch_mask[i],/fold_case)) then found = 1
    ;    endfor
    ;    if (found) then begin
    ;      filter_radiation_pulses,data,data_source=data_source,limit=radpulse_limit,n_pulses=n_pulses
    ;    endif
    ;  endif
    ;endif

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

  mod_sig=remove_characters(mod_sig,find_string)
  fname = dir_f_name(local_datapath,'JET-JPF_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')
  openr,unit,fname,/get_lun,error=error
  if (error eq 0) then begin
    close,unit & free_lun,unit
    restore,fname
    ;time = dindgen(n_elements(data))*sampletime+starttime
  endif else begin
    ;jpfget, node=signal_in, pulno=shot, data=data, tvec=time, unit=unit,$
    ;        pulsefile='JPF', type='ON', ier=ier
    getdat8, node=signal_in, pulno=shot, data=data, tvec=time, unit=unit, ier=ier ;returns double precision time vector
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
    ndata = n_elements(time)
    sampletime=time[ndata/2]-time[ndata/2-1]
    if (keyword_set(store_data)) then begin
      starttime = time[0]
      save,sampletime,starttime,time,data,file=fname
    endif
  endelse

  ;offset correction for KY6D data
  if (not keyword_set(no_offset)) then begin
  find_string=['KY6D-DOWN']
  for j=0,n_elements(find_string)-1 do begin
      i=0
      while (i NE -1) do begin
        i=strpos(signal_in,find_string[j],i)
        IF (i NE -1) THEN BEGIN
          if not defined(ind) then begin
            ind=i
          endif else begin
            ind=[ind,i]
          endelse
          i=i+1
        endif
      endwhile
  endfor
  if defined(ind) then begin ; if it is KY6D downsampled data
    ; Determining offset. The offset timerange comes from fluct_local_config.dat
      default,offset_type,local_default('offset_type')
      if offset_type EQ '' then offset_type=3
      offset_type=fix(offset_type)
      trigger=time[0]
      samplenumber=n_elements(data)
      samplenumber_start=0
      case offset_type of
      1: begin ;offset from offset_timerange in the fluct_local_config.dat
        offset_sample_start = long((offset_timerange[0]-trigger)/sampletime) > 0
        offset_sample_end = long((offset_timerange[1]-trigger)/sampletime) > 0
        if (offset_sample_end-offset_sample_start gt 0) then begin
             offset = mean(data[(offset_sample_start-samplenumber_start):(offset_sample_end-samplenumber_start-1)])
        endif else begin
          offset = 0
        endelse
        data=data-offset
      end
      2: begin ;offset from offset.dat file, not available here yet
           offset = 0
      end
      3: begin ;calculates offset at the end of the shot from a offset_timelength interval
        default,offset_timelength,local_default('offset_timelength') ;length of the averaging for offset calculation [s]
        if offset_timelength EQ '' then offset_timelength=0.1
        offset_sample_start = long(samplenumber-offset_timelength/sampletime) > 0
        offset_sample_end = long(samplenumber)> 0
        if (offset_sample_end-offset_sample_start gt 0) then begin
             offset = mean(data[(offset_sample_start-samplenumber_start):(offset_sample_end-samplenumber_start-1)])
        endif else begin
           ; As a final resort we do not subtract offset
          offset = 0
        endelse
        data=data-offset
      end
      endcase
  endif

  endif



endif ; data_source 26 (JET-JPF)
;******************* END of JET JPF data ***********************************

;******************* JET PPF data ******************************************
if (data_source eq 27) then begin
mod_sig = signal_in

  ; Removing /,: from signal name

  find_string=['/',':']
  mod_sig=remove_characters(mod_sig,find_string)
  fname = dir_f_name(dir_f_name(local_datapath,i2str(shot,digits=5)),'JET-PPF_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')
  openr,unit,fname,/get_lun,error=error
  if (error eq 0) then begin
    close,unit & free_lun,unit
    restore,fname
  endif else begin
    ; Signal name is expected to have DDA/Datatype form
    ; Finding '/' in name
    if (strpos(signal_in,':') gt 0) then begin
      w=str_sep(signal_in,':')
      ; The first is the DDA
      signal_in = w[0]
      subchannel = w[1]
    endif
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

    default,ppfuid,'JETPPF'
    default,sequence,0
    ppfread,shot=shot,dda=dda,dtype=datatype,data=data,t=time,ierr=ierr, seq=sequence, ppfuid=ppfuid
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
    if size(data,/n_dimensions) EQ 2 then begin
      if subchannel EQ 0 then begin
        errormess = 'Warning: 2D data array, and no subchannel defined! convention: JET-PPF/<DDA>/<dtype>:<subchannel> Returning 2D data.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
      endif else begin
        data=data[subchannel-1,*]
      endelse
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
  a = stregex(signal_in,'xbt_channel[0-3][0-9]')
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
    a = stregex(signal_in,'xbt_channel')
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
    ; This is xbt_channel or BES- signal
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
        data=reform(xbt.apd_data[apd_chan, *])
      endif else begin
        ; offset
        data=reform(xbt.apd_data[apd_chan, *])
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
      if data_tree eq 'local' then begin
        errormess='No data in local directory'
      if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess, /forward
        endif else begin
             print,errormess
        endelse
         time = 0
          data=0
          return
       endif
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
    if data_tree eq 'local' then begin
      catch,error
      if (error eq 0) then begin
         read_signal_in=signal_in
         WHILE (((In = STRPOS(read_signal_in, '/'))) NE -1) DO STRPUT, read_signal_in, '-', In
         restore, datapath+'/MAST_NC_'+i2str(shot)+'_'+read_signal_in+'.sav'
      endif
       catch,/cancel
       if size(data) gt 1 then begin
          ;data is defined
         if (keyword_set(cache)) then begin
         cachename = i2str(shot)+'_'+full_signal_in
         signal_cache_add,name=cachename,data=data_cache,time=time,starttime=time[0],sampletime=sampletime,errormess=err
         endif
       endif else begin
        errormess='No data in local directory'
      if (keyword_set(errorproc)) then begin
            call_procedure,errorproc,errormess, /forward
        endif else begin
             print,errormess
        endelse
         time = 0
          data=0
          return
        endelse

    endif
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
    ;save if needed
    data = reform(data)
    starttime = ds.time[0]
    write_signal_in=signal_in
    WHILE (((In = STRPOS(write_signal_in, '/'))) NE -1) DO STRPUT, write_signal_in, '-', In

    if (keyword_set(store_data)) then begin
       save,shot,starttime,sampletime,data,time, file=datapath+'MAST_NC_'+i2str(shot)+'_'+write_signal_in+'.sav'
    endif

  endelse ;end of other NETCDF file read

endif  ; data_source eq 30

;******************* MAST-NC -> MAST NETCDF data tree ********************



;******************* AUG data ******************************************
if (data_source eq 31) then begin
  ; Signal name is expected to have user/system/data/channel form
  names = strsplit(signal_in,'/',/extract)
  if (n_elements(names) eq 3) then begin
    ; If channel is omitted 1 is used as default
    names = [names,'1']
  endif
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
    ;--An attempt to use the new data downloading routine for AUG trees ---
    ;default,trange,[0,5]
    ;read_common,shot,trange[0],trange[1],time,aug_user,aug_system,0L,aug_unit,data
    ;The original routines are moved from the ASDEX_programs_svn repository to the same repository but into the subdirectory old
    read_signal_bt,shot,aug_user+'/'+aug_system+'/'+ aug_unit,time,data,timerange=trange
    ;--An attempt to use the new data downloading routine for AUG trees ---

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
      data_arr = data
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
  data = 0.
  time = 0.

  if (shot gt 10000) then begin
    APDCAM_10G = 1
  endif

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
        column = fix(strmid(signal_in,6,2))
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
    if (not keyword_set(APDCAM_10G)) then begin
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
    endif else begin
      ;APDCAM 4x16 was installed in 2014 after shot 8500
      if ((row lt 1) or (row gt 4) or (column lt 1) or (column gt 16)) then begin
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
    endelse

    if (not keyword_set(APDCAM_10G)) then begin
      map=reverse(apdcam_channel_map(data_source=data_source),2)
    endif else begin
      map=transpose(apdcam10g_4x16_channel_map())
    endelse
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

      load_config_parameter,shot,'ADCSettings','ExternalTriggerTime',data_source=data_source,output_struct=s,$
         datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        ext_trigger_time= s.value
      endif else begin
        ext_trigger_time = 0
      endelse  


 ;     load_config_parameter,shot,'ADCSettings','ADCMult',data_source=data_source,output_struct=s,$
 ;        datapath=datapath,errormess=e,/silent
 ;     if (e eq '') then begin
 ;       ADC_Mult= s.value
 ;     endif

;      load_config_parameter,shot,'ADCSettings','ADCDiv',data_source=data_source,output_struct=s,$
;         datapath=datapath,errormess=e,/silent
;      if (e eq '') then begin
;        ADC_Div= s.value
;      endif

;      load_config_parameter,shot,'ADCSettings','Samplediv',data_source=data_source,output_struct=s,$
;         datapath=datapath,errormess=e,/silent
;      if (e eq '') then begin
;        samplediv= s.value
;      endif

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

      trigger = trigger+ext_trigger_time
      
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
      if (keyword_set(APDCAM_10G)) then begin
         datafile = dir_f_name(dir_f_name(datapath,i2str(shot)),'Channel_0'+i2str(chi-1,digit=2)+'.dat')
      endif else begin
         datafile = dir_f_name(dir_f_name(datapath,i2str(shot)),'Channel'+i2str(chi-1,digit=2)+'.dat')
      endelse
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
      if (keyword_set(APDCAM_10G)) then begin
        data = (2.0^bits-1)-reform(a[0])
      endif else begin
        data = reform(a[0])
      endelse

      if (not keyword_set(no_offset)) then begin
        ; Determining offset. The offset timerange comes from fluct_local_config
        offset_sample_start = long((offset_timerange[0]-trigger)/sampletime) > 0
        offset_sample_end = long((offset_timerange[1]-trigger)/sampletime) > 0
        if (offset_sample_end-offset_sample_start gt 0) then begin
          if (offset_sample_start ge samplenumber_start) and $
             (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
            ; if data is already read in
            offset = mean(data[offset_sample_start-samplenumber_start:offset_sample_end-samplenumber_start-1])
          endif else begin
            ; reading offset data
            on_ioerror,loaderr_offset
            a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
            offset = mean(a[0])
            if (keyword_set(APDCAM_10G)) then begin
              offset = (2.0^bits-1)-offset
            endif
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
    ecei_name = stregex(strupcase(signal_in),'ECEI/ECEI_[H,L,G][0-2][0-9]0[1-8]',/extract)
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
    endif  ; end ECEI data from file
    ; Checking for ECEI/MIR_[H,L]<channel>_[I,Q] format.
    ; H is 3 MHz, L is 1 MHz
    ; channel is 2 digit like 01, 02, ... (1...16)
    mir_name = stregex(strupcase(signal_in),'ECEI/MIR_[H,L][0-1][0-9]_[I,Q,A,P,C]',/extract)
    if (mir_name ne '') then begin
      ; Found MIR channel name
      mir_ch = fix(strmid(mir_name,10,2))
      if ((mir_ch lt 1) or (mir_ch gt 16)) then begin
        errormess = 'Invalid channel number in MIR signal name.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,errormess,/forward
        endif else begin
          print,errormess
        endelse
        data=0
        time=0
        return
      endif
      stype = strmid(mir_name,strlen(mir_name)-1,1)
      if ((stype eq 'A') or (stype eq 'P') or (stype eq 'C')) then begin
        ; Amplitude, phase or complex signal
        signal_base = strmid(mir_name,0,strlen(mir_name)-1)
        get_rawsignal,shot,'KSTAR/'+signal_base+'I',data_source=data_source,time,di,errormess = errormess
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
        get_rawsignal,shot,'KSTAR/'+signal_base+'Q',data_source=data_source,time,dq,errormess = errormess,sampletime=sampletime
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
        case stype of
          'A': data = sqrt(di^2+dq^2)
          'P': data = atan(di,dq)
          'C': data = complex(di,dq)
        endcase
      endif else begin
        ; I or Q signal
        ; L: edge, H: more inside
        if (strmid(mir_name,9,1) eq 'H')then begin
          datafile = dir_f_name(datapath,'SHOT.0'+i2str(shot,digits=5)+'.acq132_145.h5')
          mir_block = 1
        endif else begin
          datafile = dir_f_name(datapath,'SHOT.0'+i2str(shot,digits=5)+'.acq132_120.h5')
          mir_block = 0
        endelse
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
        if (strmid(mir_name,13,1) eq 'I') then begin
          mir_iq = 0
        endif else begin
          mir_iq = 1
        endelse
        group_name1 = 'ECEI'
        file_ch = (mir_ch-1)*2 + mir_iq
        group_name2 = 'ECEI_M0'+i2str(mir_block*4+file_ch/8+1)+i2str(file_ch mod 8+1,digit=2)
        data_name   = 'Voltage'
        file_id   = h5f_open(datafile)      ; Open HDF5 file
        group_id1 = h5g_open(file_id, group_name1)    ; Open group of level 1
        print,'Reading '+group_name2
        group_id2 = h5g_open(group_id1, group_name2)  ; Open group of level 2
        data_id   = h5d_open(group_id2, data_name)    ; Open dataset
        data = float(h5d_read(data_id))/1e4   ; Read data
        h5d_close, data_id    ; End access to dataset
        h5g_close, group_id2  ; End access to group of level 2
        h5g_close, group_id1  ; End access to group of level 1
        h5f_close, file_id    ; Close HDF5 file
        samplerate = 5e5    ; sampling rate of digitizer [/s]
        nsamples = 5e6  ; # of samples of digitizer
        toffset = -0.1  ; time offset with respect to blip time [s]
        time = dindgen(nsamples)/samplerate + toffset
        sampletime = 1./double(samplerate)
      endelse ; I or Q signal
    endif ; MIR data
    if (n_elements(data) lt 2) then begin
      ; This is assumed to be a KSTAR signal
      ; Virtual name translation
      case strupcase(signal_in) of
        'IP': mdsplus_name = '\RC03/(-1000000.)'
        'P_NBI' : begin
            if (shot lt 8500) then mdsplus_name = '\nb11_pnb+\nb12_pnb' else mdsplus_name = '\nb11_pnb+\nb12_pnb+\nb13_pnb'
          end
        'P_NBI1' : mdsplus_name = '\nb11_pnb'
        'P_NBI2' : mdsplus_name = '\nb12_pnb'
        'P_NBI3' : mdsplus_name = '\nb13_pnb'
        'P_ECRH' : mdsplus_name = '(ECH_VFWD1:FOO-0.23)*105/1000.'
        'E_NBI1' : mdsplus_name = '(\nb11_vg1)'
        'E_NBI2' : mdsplus_name = '(\nb12_vg1)'
        'E_NBI3' : mdsplus_name = '(\nb13_vg1)'
        'NEL': mdsplus_name = '\NE_INTER01/2.'
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

    endif ;  This is KSTAR signal
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
    ;map=apdcam_channel_map(data_source=data_source)
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
    ;adc_block = fix((chi-1)/8)
    adc_block = fix((chi)/8)
    load_config_parameter,shot,'ADCSettings','ChannelMask'+i2str(adc_block+1),data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      ;mask = ishft(1,(chi-1) mod 8)
      mask = ishft(1,(chi) mod 8)
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
    ;datafile = dir_f_name(dir_f_name(datapath,i2str(shot)),'Channel'+i2str(chi-1,digit=2)+'.dat')
    datafile = dir_f_name(dir_f_name(datapath,i2str(shot)),'Channel'+i2str(chi,digit=2)+'.dat')
    ;print,datafile
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
    if (not keyword_set(no_offset)) then begin

      ; Determining offset. The offset timerange comes from fluct_local_config.dat
      default,offset_type,local_default('offset_type')
      if offset_type EQ '' then offset_type=1
      offset_type=fix(offset_type)
      case offset_type of
      1: begin ;offset from offset_timerange in the fluct_local_config.dat
        offset_sample_start = long((offset_timerange[0]-trigger)/sampletime) > 0
        offset_sample_end = long((offset_timerange[1]-trigger)/sampletime) > 0
        if (offset_sample_end-offset_sample_start gt 0) then begin
          if (offset_sample_start ge samplenumber_start) and $
             (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
             ; if data is already read in
             offset = mean(data[(offset_sample_start-samplenumber_start):(offset_sample_end-samplenumber_start-1)])
          endif else begin
             ; reading offset data
             on_ioerror,loaderr_offset_JET_APDCAM
             a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
             offset = mean(a[0])
          endelse
        endif else begin
          loaderr_offset_JET_APDCAM:
          ; As a final resort we do not subtract offset
          offset = 0
        endelse
        data=data-offset
      end
      2: begin ;offset from offset.dat file
        offsetmat=loadncol(dir_f_name(dir_f_name(datapath,i2str(shot)),'offsets.dat'),format='int' )
         if offsetmat[0,0] EQ 0 then begin
           ; As a final resort we do not subtract offset
           offset = 0
         endif else begin
           offset=(offsetmat[where(offsetmat[*,0] EQ chi),1])[0]
         endelse
         data = data-offset
      end
      3: begin ;calculates offset at the end of the shot from a offset_timelength interval
        default,offset_timelength,local_default('offset_timelength') ;length of the averaging for offset calculation [s]
        if offset_timelength EQ '' then offset_timelength=0.1
        offset_sample_start = long(samplenumber-offset_timelength/sampletime) > 0
        offset_sample_end = long(samplenumber)> 0
        if (offset_sample_end-offset_sample_start gt 0) then begin
          if (offset_sample_start ge samplenumber_start) and $
             (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
             ; if data is already read in
             offset = mean(data[(offset_sample_start-samplenumber_start):(offset_sample_end-samplenumber_start-1)])
          endif else begin
             ; reading offset data
             on_ioerror,loaderr_offset_JET_APDCAM1
             a = assoc(unit,intarr(offset_sample_end-offset_sample_start),offset_sample_start*2)
             offset = mean(a[0])
          endelse

        endif else begin
          loaderr_offset_JET_APDCAM1:
          ; As a final resort we do not subtract offset
          offset = 0
        endelse
        data=data-offset
      end
      else: print,'No valid offset_type. Offset is not substracted.'
      endcase
    endif ; offset correction

    close,unit & free_lun,unit
    ; Scaling to volts
    if scaling EQ 1 then data = data*(2. / 2.^bits)
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


; Added on 2013.09.12   D. Refy
;
if (data_source eq 34) then begin
;default,compass_trigger,0.94

  ; Checking for signal names BES-ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...32
  if (strupcase(strmid(signal_in,0,4)) eq 'ADC-') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = strmid(signal_in,4,2)
    endif else begin
      errormess = 'Invalid channel number in name ADC-xx.'
      return
    endelse
    catch,/cancel
  endif

; modify data path in case of calibration shot
if (shot GT 1) AND (shot LT 3000) then begin
  datapath=local_default('datapath')
  datapath=dir_f_name(datapath,'calibration')
endif

 if (strupcase(strmid(signal_in,0,4)) eq 'BES-') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      ;chi = strmid(signal_in,4,2)
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
    endif else begin
      errormess = 'Invalid channel number in name BES-xx.'
      return
    endelse
    catch,/cancel
  endif

  if (strupcase(strmid(signal_in,0,4)) eq 'APD-') then begin
    ; expecting APD-XX format
    catch,error_catch
    if (error_catch eq 0) then begin
      apdnumber = fix(strmid(signal_in,4,2))
    endif else begin
      errormess = 'Invalid number in name APD-XX.'
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
    if ((apdnumber lt 1) or (apdnumber gt 18)) then begin
      errormess = 'Invalid number in name APD-XX.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif

    load_config_parameter,shot,'Optics','APD-'+i2str(apdnumber),data_source=data_source,output_struct=s,$
      datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      chi= string(fix(s.value),format='(I2.2)')
    endif
  endif

  ; If chi is set it contains the channel number for a BES signal
  if (not defined(chi)) then begin
    errormess = 'Unkown COMPASS APD channel.'
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

;    if (subchannel ne 0) then begin
;      deflection_config,shot,signal_in,period_n=period_sample_n,period_cycle_n=period_cycle_n,mask_up=mask_up,mask_down=mask_down,$
;                        start_samp=start_sample,starttime=starttime,period_time=period_time,errormess=errormess,datapath=datapath
;      if (errormess ne '') then begin
;        if (keyword_set(errorproc)) then begin
;          call_procedure,errorproc,errormess,/forward
;        endif else begin
;          print,errormess
;        endelse
;        data_b=0
;        time_b=0
;        return
;      endif
;    endif

    load_config_parameter,shot,'Timing','Trigger',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      compass_trigger= s.value
    endif

    load_config_parameter,shot,'Timing','StartTime',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      starttime= s.value
    endif

    load_config_parameter,shot,'Timing','EndTime',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      endtime= s.value
    endif

    load_config_parameter,shot,'Timing','SampleFreq',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      samplefreq= s.value
    endif

    load_config_parameter,shot,'Timing','SampleNumber',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      samplenumber= s.value
    endif
    
    load_config_parameter,shot,'ADCSettings','resolution',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=e,/silent
    if (e eq '') then begin
      bits= s.value
    endif
    
;
;    load_config_parameter,shot,'Timing','Bits',data_source=data_source,output_struct=s,$
;       datapath=datapath,errormess=e,/silent
;    if (e eq '') then begin
;      bits= s.value
;    endif

    ; These are the defaults in case any of these were missing. This can happen in very early shots.
    ;default,starttime,0
    ;default,endtime,1
    ;default,samplefreq,1
    ;default,samplenumber,long((endtime-starttime)*samplefreq*1e6)
    ;default,bits,14

    ; Calculating sampletime
    sampletime = 1./(samplefreq*1e6)



    ; If trange is set we will read only the necesary samples
    if (n_elements(trange) eq 2) then begin
      samplenumber_start = long((trange[0]-compass_trigger)/sampletime)
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
    datafile = dir_f_name(dir_f_name(datapath,dir_f_name(i2str(shot),'data')),'Channel'+i2str(chi,digits=2)+'.dat')
    print,datafile
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
    on_ioerror,loaderr_compass_apd
    a = assoc(unit,intarr(samplenumber_read),samplenumber_start*2)
    data = reform(a[0])
    if (not keyword_set(no_offset)) then begin
      ; Determining offset. The offset timerange comes from fluct_local_config
      offset_sample_start = long((offset_timerange[0]-compass_trigger)/sampletime) > 0
      offset_sample_end = long((offset_timerange[1]-compass_trigger)/sampletime) > 0
      if (offset_sample_end-offset_sample_start gt 0) then begin
        if (offset_sample_start ge samplenumber_start) and $
          (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
        ; if data is already read in
          offset = mean(data[offset_sample_start:offset_sample_end-1])
        endif else begin
          ; reading offset data
          on_ioerror,loaderr_offset_compass_apd
          a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
          offset = mean(a[0])
        endelse
      endif else begin
        loaderr_offset_compass_apd:
        ; As a final resort we do not subtract offset
        offset = 0
      endelse
      data = data-offset
    endif ; offset correction

    close,unit & free_lun,unit
    ; Scaling to volts
    data = data*(2. / 2.^bits)
    time = dindgen(n_elements(data))*sampletime+starttime+compass_trigger+samplenumber_start*sampletime

;    if (subchannel ne 0) then begin
;
;      if (not defined(subch_mask)) then begin
;        if (subchannel eq 1) then mask=mask_down
;        if (subchannel eq 2) then mask=mask_up
;      endif else begin
;        mask = subch_mask
;      endelse
;      default,trange,[starttime,starttime+(period_cycle_n-1.)*sampletime]
;      trange=float(trange)
;      if (trange[0] lt starttime) then trange[0] = starttime
;      if (trange[0] ge trange[1]) then begin
;        errormess='Start of time interval is after end of interval.'
;          if (keyword_set(errorproc)) then begin
;            call_procedure,errorproc,errormess,/forward
;          endif else begin
;            print,errormess
;          endelse
;         data=0
;         time=0
;         return
;      endif
;      if (trange[1] gt starttime+(period_cycle_n-1.)*period_time) then begin
;        trange[1] = starttime+(period_cycle_n-1.)*period_time
;      endif
;      start_period = long((trange(0)-starttime)/(period_time))
;      end_period = long((trange(1)-starttime)/(period_time))
;      interval_start_sample = long(start_period)*period_sample_n+start_sample
;      interval_stop_sample = (long(end_period)+1)*period_sample_n+start_sample-1
;      if (interval_start_sample lt 0) then begin
;        errormess = 'Requested time interval starts before start time of measurement.'
;      endif
;      if (interval_stop_sample ge n_elements(data)) then begin
;        errormess = 'Requested time interval ends after end of measurement.'
;      endif
;      if (errormess ne '') then begin
;        if (keyword_set(errorproc)) then begin
;          call_procedure,errorproc,errormess,/forward
;        endif else begin
;          print,errormess
;        endelse
;        data=0
;        time=0
;        return
;      endif
;      data = data[interval_start_sample:interval_stop_sample]
;      time = time[interval_start_sample:interval_stop_sample]
;      ind = lonarr((end_period-start_period+1)*n_elements(mask))
;      ind1 = lindgen(end_period-start_period+1)*period_sample_n
;      ind2 = lindgen(end_period-start_period+1)*n_elements(mask)
;      for i=0,n_elements(mask)-1 do ind(ind2+i) = ind1+mask(i)
;      data = data(ind)
;      time = time[ind]
;
;  endif  ;; subchannel ne 0


    goto,get_rawsignal_end
  loaderr_compass_apd:
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
endif; data_source 34

;******************* COMPASS BES using APDCAM ********************

; ***************** AUG Li-beam APDCAM raw data stored in PC *********************************
if (data_source eq 35) then begin
  ; Checking for signal names FIB<input_fibre_nr>
  ; If this is requested the channel correspondig to the <input_fibre_nr> is read. <input_fibre_nr> is the fibre number coming from the periscope. (1..60)
  if (strupcase(strmid(signal_in,0,3)) eq 'FIB') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      fib = fix(strmid(signal_in,3,2))
    endif else begin
      errormess = 'Invalid channel number in name FIBxx.'
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
    for i=1,32 do begin
      load_config_parameter,shot,'Optics','Fibre_'+i2str(i),data_source=data_source,output_struct=s,$
        datapath=datapath,errormess=e,/silent
      if (e eq '') then begin
        conf_fib= s.value
        ;print,conf_fib
        if fib EQ conf_fib then begin
          chi=i
          ;print, chi
        endif
      endif
    endfor
  endif


  ; Checking for signal names ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...32
  if (strupcase(strmid(signal_in,0,3)) eq 'ADC') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = fix(strmid(signal_in,3,2))
    endif else begin
      errormess = 'Invalid channel number in name ADCxx.'
      return
    endelse
    catch,/cancel
  endif
  ; Checking for APD-<row>-<column> format. If this is found it will be translated to ADC channels
  ; using apdcam_channel_map.pro
  if (strupcase(strmid(signal_in,0,4)) eq 'APD-') and (strmid(signal_in,5,1) eq '-') then begin
    ; expecting BES-<row>-<column> format
    catch,error_catch
    if (error_catch eq 0) then begin
      row = fix(strmid(signal_in,4,1))
      column = fix(strmid(signal_in,6,1))
    endif else begin
      errormess = 'Invalid number in name APD-<row>-<column>.'
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
      errormess = 'Invalid number in name APD-<row>-<column>.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    map=apdcam_channel_map(data_source=data_source)
    chi = map[row-1,column-1]
    ;print, chi
  endif

  ; If chi is set it contains the channel number for a BES signal
  if (not defined(chi)) then begin
    errormess = 'Unkown AUG Li-beam APDCAM channel.'
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
    ;default,trigger,0
    ;default,ADC_Mult,20
    ;default,ADC_Div,40
    ;default,samplediv,5
    ;default,bits,12

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
    shot_cent=shot/100
    datafile = dir_f_name(dir_f_name(datapath,dir_f_name(i2str(shot_cent),i2str(shot))),'Channel'+i2str(chi-1,digit=2)+'.dat')
    openr,unit,datafile,/get_lun,error=error
    if (error ne 0) then begin
      errormess = 'Error opening file: '+datafile
      datafile1 = dir_f_name(dir_f_name(datapath,i2str(shot)),'Channel'+i2str(chi-1,digit=2)+'.dat')
      openr,unit,datafile1,/get_lun,error=error
      if (error ne 0) then begin
        errormess = 'Error opening file: '+datafile1
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
    on_ioerror,loaderr_augli
    a = assoc(unit,intarr(samplenumber_read),samplenumber_start*2)
    data = reform(a[0])

    if (not keyword_set(no_offset)) then begin
      ; Determining offset. The offset timerange comes from fluct_local_config
      offset_sample_start = long((offset_timerange[0]-trigger)/sampletime) > 0
      offset_sample_end = long((offset_timerange[1]-trigger)/sampletime) > 0
      if (offset_sample_end-offset_sample_start gt 0) then begin
        if (offset_sample_start ge samplenumber_start) and $
          (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
        ; if data is already read in
          offset = mean(data[offset_sample_start:offset_sample_end-1])
        endif else begin
          ; reading offset data
          on_ioerror,loaderr_offset_AUG_APDCAM
          a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
          offset = mean(a[0])
        endelse
      endif else begin
        loaderr_offset_AUG_APDCAM:
        ; As a final resort we do not subtract offset
        offset = 0
      endelse
      data = data-offset
    endif ; offset correction

    close,unit & free_lun,unit
    ; Scaling to volts
    if scaling EQ 1 then data = data*(2. / 2.^bits)
    time = dindgen(n_elements(data))*sampletime+trigger+samplenumber_start*sampletime
    goto,get_rawsignal_end
  loaderr_augli:
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
endif ; data_source 35


; ***************** END OF AUG Li-beam APDCAM raw data stored in PC *********************************


;******************* JET JPF/PPF data from BEAM server ******************************************
if (data_source eq 36) then begin
default,store_data,1
default,reread,0
default,quiet,1
signal_full=signal_in
;extract jet_subchannel name if exists
  if (strpos(signal_in,':') gt 0) then begin
    w=str_sep(signal_in,':')
    signal_in = w[0]
    jet_subchannel = w[1]
  endif

; signal name for saving is without jet_subchannel
  mod_sig = signal_full
; Removing /,:,< from signal name
  find_string=['/',':']
  mod_sig=remove_characters(mod_sig,find_string)

  ;find out if JPF
  found=0
  find_string=['JPF']
  mod_sig=remove_characters(mod_sig,find_string,found=found)
  if found EQ 1 then begin
    read_signal=signal_full
    fname = dir_f_name(local_datapath,'JET-JPF_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')
  endif else begin
    ;find out if PPF
    find_string=['PPF']
    mod_sig=remove_characters(mod_sig,find_string,found=found)
    if found EQ 1 then begin
      read_signal=signal_in
      if defined(sequence) then mod_sig=mod_sig+i2str(sequence)
      if defined(ppfuid) then mod_sig=mod_sig+ppfuid
      fname = dir_f_name(local_datapath,'JET-PPF_'+i2str(shot,digits=5)+'_'+mod_sig+'.sav')
    endif
  endelse
  
  ;openr,unit,fname,/get_lun,error=error
  ;if (error eq 0) then begin
  if file_test(fname) AND not reread then begin
    ;close,unit & free_lun,unit
    restore,fname
    if not quiet then print,'Data restored from: '+fname
    ;time = dindgen(n_elements(data))*sampletime+starttime
  endif else begin

    mdsconnect,'mdsplus.jet.efda.org',status=status
    if (status eq 1) then begin
      if defined(ppfuid) then u=mdsvalue('_sig=ppfuid("'+ ppfuid +'")')
      if defined(sequence) then read_signal=read_signal+'/'+i2str(sequence)
      ;print,read_signal
      data=mdsvalue('_sig=jet("'+read_signal+'",'+i2str(shot,digits=5)+')',status=status, quiet=quiet)
      ;stop
      if (status NE 0) then begin 
        if size(data,/n_dimensions) EQ 1 then time=mdsvalue('dim_of(_sig)')
        if size(data,/n_dimensions) EQ 2 then begin
          p = mdsvalue('dim_of(_sig,0)')
          time  = mdsvalue('dim_of(_sig,1)')
          if not defined(jet_subchannel) then begin
            errormess = 'Warning: 2D data array, and no jet_subchannel defined! convention: JET-PPF/<DDA>/<dtype>:<jet_subchannel>'
            if (keyword_set(errorproc)) then begin
              call_procedure,errorproc,errormess,/forward
            endif else begin
              print,errormess
            endelse
          endif else begin
            data=reform(data[jet_subchannel-1,*])
          endelse
        endif
      endif  
      mdsdisconnect
    endif 
    if (status eq 0) then begin
      errormess = 'Error reading JET JPF/PPF data. Shot: '+i2str(shot)+', signal:'+read_signal+', error code:'+i2str(status)
      if defined(ppfuid) then errormess=errormess+', ppfuid:'+ppfuid
      if defined(sequence) then errormess=errormess+', sequence:'+i2str(sequence)
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
    ;sampletime = double(time[ndata-1]-time[0])/double(ndata-1); ;!!!!!!!!!!!This is not ok, because sampletime will be corrupted in case of non equidistant sampling.
    ; !!! get sampletime from the middle of the time vector
    sampletime = mean(double(time[ndata/2-5:ndata/2+5]-time[ndata/2-6:ndata/2+4]))
    
    ;sampletime = round(sampletime/1e-8)*double(1e-8)
    ;time = time[0]+dindgen(ndata)*sampletime
    if (keyword_set(store_data)) then begin
      starttime = time[0]
      ;save,sampletime,starttime,data,file=fname
      save,time,starttime,data,sampletime,file=fname
      if not quiet then print,'Data stored locally at: '+fname
    endif
  endelse

;  if size(data,/n_dimensions) EQ 2 then begin
;
;  endif

endif ; data_source 36 (JET JPF/PPF online)
;******************* END of JET JPF/PPF data from BEAM server ***********************************


;******************* AUG data from external location through MDSPlus******************************************
if (data_source eq 37) then begin
store_data=1 ; storing on BEAM server is on by default
  ; Signal name is expected to have user/system/data/channel form
  names = strsplit(signal_in,'/',/extract)
  if (n_elements(names) eq 3) then begin
    ; If channel is omitted 1 is used as default
    names = [names,'1']
  endif
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
      mdsaug,shot,aug_user+'/'+aug_system+'/'+ aug_unit,time,data,area,auguser=auguser,timerange=trange
      if ((size(data))[0] lt 1) then begin
        errormess = 'Error reading AUG data through MDSPlus. Shot: '+i2str(shot)+', signal: '+signal_in
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
      data_arr=data
      data = reform(data[*,aug_channel-1])
    endif
    ndata = n_elements(time)
    sampletime = (time[ndata-1]-time[0])/(ndata-1)
    if (keyword_set(store_data)) then begin
      save,sampletime,time,data,file=fname
    endif
  endelse
endif ; data_source 37 (AUG)
;******************* END of AUG data from external location through MDSPlus ***********************************

;******************* APDCAM-10G data - general******************************************
if (data_source eq 38) then begin
  ; Checking for signal names ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...
  if (strupcase(strmid(signal_in,0,3)) eq 'ADC') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = fix(strmid(signal_in,3,3))
    endif else begin
      errormess = 'Invalid channel number in name ADCxx.'
      return
    endelse
    catch,/cancel
  endif

  load_apdcam_config_parameter,'ADCSettings','ADCMult',output_struct=s,$
     datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    ADCmult= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse

  load_apdcam_config_parameter,'ADCSettings','ADCDiv',output_struct=s,$
     datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    ADCdiv= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse


  load_apdcam_config_parameter,'ADCSettings','Samplediv',output_struct=s,$
     datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    Samplediv= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse

  sampletime = 1./(2e7/ADCdiv*ADCmult/Samplediv)

  load_apdcam_config_parameter,'ADCSettings','SampleNumber',output_struct=s,$
       datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    SampleNumber= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse

  load_apdcam_config_parameter,'ADCSettings','Bits',output_struct=s,$
       datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    bits = s.value
  endif  else begin
    time = 0
    data = 0
    return
  endelse

  datafile = dir_f_name(datapath,'Channel_'+i2str(chi-1,digit=3)+'.dat')
  openr,unit,datafile,/get_lun,error=error

  if (error ne 0) then begin
    errormess = 'Error opening file: '+datafile
    data = 0
    time = 0
    return
  endif

  trigger = 0
  if (defined(timerange)) then begin
    samplenumber_start = long((timerange[0]-trigger)/sampletime)
    samplenumber_read = long((timerange[1]-timerange[0])/sampletime)
    if (samplenumber_read+samplenumber_start gt samplenumber) then begin
      errormess = 'Requested end of signal is after end of measurement.'
      time = 0
      data = 0
      return
    endif
  endif else begin
    samplenumber_start = 0
    samplenumber_read = samplenumber
  endelse

  on_ioerror,apdcam10g_read_error
  a = assoc(unit,intarr(SampleNumber_read),samplenumber_start*2)
  data = reform(a[0])
  time = (dindgen(samplenumber_read)+samplenumber_start)*sampletime+trigger
  close,unit & free_lun,unit

  goto,get_rawsignal_end


  apdcam10g_read_error:
  close,unit & free_lun,unit
  errormess = 'Error reading data file: '+datafile
  time = 0
  data = 0
  return



endif ; data_source 38 (APDCAM-10G)
;******************* END of APDCAM-10G ***********************************


;******************* EAST-Li BES system ******************************************
if (data_source eq 39) then begin
  ; Checking for signal names LIBES-ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...64
  if (strupcase(strmid(signal_in,0,9)) eq 'LIBES-ADC') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = fix(strmid(signal_in,9,2))
    endif else begin
      errormess = 'Invalid channel number in name LIBES-ADCxx.'
      return
    endelse
    catch,/cancel
  endif

  ; Checking for LIBES-<row>-<column> format. If this is found it will be translated to ADC channels
  ; using apdcam10g_channel_map.pro
  if (strupcase(strmid(signal_in,0,6)) eq 'LIBES-') and (strmid(signal_in,7,1) eq '-') then begin
    ; expecting LIBES-<row>-<column> format
    ; (1,1) is lower-left corner of image in plasma as seen from the optics
    catch,error_catch
    if (error_catch eq 0) then begin
      row = fix(strmid(signal_in,6,1))
      column = fix(strmid(signal_in,8,2))
    endif else begin
      errormess = 'Invalid number in name LIBES-<row>-<column>.'
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
    if ((row lt 1) or (row gt 4) or (column lt 1) or (column gt 16)) then begin
      errormess = 'Invalid number in name LIBES-<row>-<column>.'
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,errormess,/forward
      endif else begin
        print,errormess
      endelse
      data=0
      time=0
      return
    endif
    map = apdcam10g_channel_map('4x16')
    chi = map[column-1,row-1]
  endif

  if (not defined(chi)) then begin
    errormess = 'Unknown signal in EAST Li-BES measurement.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif

  load_config_parameter,shot,'ADCSettings','Samplediv',data_source=data_source,output_struct=s,$
     datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    Samplediv= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse


  load_config_parameter,shot,'ADCSettings','SampleNumber',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    SampleNumber= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse

  load_config_parameter,shot,'ADCSettings','Bits',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    bits = s.value
  endif  else begin
    time = 0
    data = 0
    return
  endelse
  ; Converting if the register contents and not the actual bits value is present.
  if (bits lt 3) then begin
    case bits of
      0: bits_c = 14
      1: bits_c = 12
      2: bits_c = 8
    endcase
    bits = bits_c
  endif

  ; Assuming 20MHz ADC frequency
  sampletime = 1./(20e6/Samplediv)
  shotdir=i2str(shot)
  datafile = dir_f_name(dir_f_name(datapath,shotdir),'Channel_'+i2str(chi-1,digit=3)+'.dat')
  openr,unit,datafile,/get_lun,error=error

  if (error ne 0) then begin
    errormess = 'Error opening file: '+datafile
    data = 0
    time = 0
    return
  endif

  trigger = -0.1
  if (defined(timerange)) then begin
    samplenumber_start = long((timerange[0]-trigger)/sampletime)
    samplenumber_read = long((timerange[1]-timerange[0])/sampletime)
    if (samplenumber_read+samplenumber_start gt samplenumber) then begin
      errormess = 'Requested end of signal is after end of measurement.'
      time = 0
      data = 0
      return
    endif
  endif else begin
    samplenumber_start = 0
    samplenumber_read = samplenumber
  endelse

  on_ioerror,east_read_error
  a = assoc(unit,intarr(SampleNumber_read),samplenumber_start*2)
  data = reform(a[0])
  time = (dindgen(samplenumber_read)+samplenumber_start)*sampletime+trigger

  if (not keyword_set(no_offset)) then begin
    offset_sample_start = long((offset_timerange[0]-trigger)/sampletime) > 0
    offset_sample_end = long((offset_timerange[1]-trigger)/sampletime) > 0
    if (offset_sample_end-offset_sample_start gt 0) then begin
      if (offset_sample_start ge samplenumber_start) and $
          (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
        ; if data is already read in memory
        offset = mean(data[offset_sample_start:offset_sample_end-1])
      endif else begin
        ; reading offset data
        on_ioerror,east_read_error
        a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
        offset = mean(a[0])
      endelse
      data = offset - data
    endif else begin
      errormess = 'Invalid offset time.'
      time = 0
      data = 0
      return
    endelse
  endif else begin
    data = 2^bits - data
  endelse
  close,unit & free_lun,unit

  ; Scaling to Volts
  data = data/2.^bits*2.
  goto,get_rawsignal_end


  east_read_error:
  close,unit & free_lun,unit
  errormess = 'Error reading data file: '+datafile
  time = 0
  data = 0
  return


endif ; data_source 39 EAST-Li BES

;******************* END of EAST Li BES system ***********************************

;******************* EAST-BES system ******************************************
if (data_source eq 40) then begin
  ; Checking for signal names BES-ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...128
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

  if (strupcase(strmid(signal_in,0,4)) eq 'BES-') and (strmid(signal_in,5,1) eq '-') then begin
    ; expecting BES-<row>-<column> format
    catch,error_catch
    if (error_catch eq 0) then begin
      row = fix(strmid(signal_in,4,1))
      column = fix(strmid(signal_in,6,2))
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
    if ((row lt 1) or (row gt 8) or (column lt 1) or (column gt 16)) then begin
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
    map = apdcam10g_channel_map('8x16')
    chi = map[column-1,row-1]
  endif

  if (not defined(chi)) then begin
    errormess = 'Unknown signal in EAST BES measurement.'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif else begin
      print,errormess
    endelse
    data=0
    time=0
    return
  endif

 load_config_parameter,shot,'ADCSettings','Samplediv',data_source=data_source,output_struct=s,$
     datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    Samplediv= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse


  load_config_parameter,shot,'ADCSettings','SampleNumber',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    SampleNumber= s.value
  endif else begin
    time = 0
    data = 0
    return
  endelse

  load_config_parameter,shot,'ADCSettings','Bits',data_source=data_source,output_struct=s,$
       datapath=datapath,errormess=errormess,/silent
  if (errormess eq '') then begin
    bits = s.value
  endif  else begin
    time = 0
    data = 0
    return
  endelse
  ; Converting if the register contents and not the actual bits value is present.
  if (bits lt 3) then begin
    case bits of
      0: bits_c = 14
      1: bits_c = 12
      2: bits_c = 8
    endcase
    bits = bits_c
  endif

  ; Assuming 20MHz ADC frequency
  sampletime = 1./(20e6/Samplediv)
  shotdir=i2str(shot)
  datafile = dir_f_name(dir_f_name(datapath,shotdir),'Channel_'+i2str(chi-1,digit=3)+'.dat')
  openr,unit,datafile,/get_lun,error=error

  if (error ne 0) then begin
    errormess = 'Error opening file: '+datafile
    data = 0
    time = 0
    return
  endif

  trigger = -0.1
  if (defined(timerange)) then begin
    samplenumber_start = long((timerange[0]-trigger)/sampletime)
    samplenumber_read = long((timerange[1]-timerange[0])/sampletime)
    if (samplenumber_read+samplenumber_start gt samplenumber) then begin
      errormess = 'Requested end of signal is after end of measurement.'
      time = 0
      data = 0
      return
    endif
  endif else begin
    samplenumber_start = 0
    samplenumber_read = samplenumber
  endelse
  on_ioerror,east_bes_read_error
  a = assoc(unit,intarr(SampleNumber_read),samplenumber_start*2)
  data = reform(a[0])
  time = (dindgen(samplenumber_read)+samplenumber_start)*sampletime+trigger

  if (not keyword_set(no_offset)) then begin
    offset_sample_start = long((offset_timerange[0]-trigger)/sampletime) > 0
    offset_sample_end = long((offset_timerange[1]-trigger)/sampletime) > 0
    if (offset_sample_end-offset_sample_start gt 0) then begin
      if (offset_sample_start ge samplenumber_start) and $
          (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
        ; if data is already read in memory
        offset = mean(data[offset_sample_start:offset_sample_end-1])
      endif else begin
        ; reading offset data
        on_ioerror,east_read_error
        a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
        offset = mean(a[0])
      endelse
      data = offset - data
    endif else begin
      errormess = 'Invalid offset time.'
      time = 0
      data = 0
      return
    endelse
  endif else begin
    data = 2^bits - data
  endelse
  close,unit & free_lun,unit

  ; Scaling to Volts
  data = data/2.^bits*2.
  goto,get_rawsignal_end

 east_bes_read_error:
  close,unit & free_lun,unit
  errormess = 'Error reading data file: '+datafile
  time = 0
  data = 0
  return

endif ; data_source 40 EAST BES

;******************* END of EAST BES system ***********************************

;******************* JET general data reader ******************************************
if (data_source eq 41) then begin
;  signal_full=signal_in
;  ;extract subchannel name if exists
;  if (strpos(signal_in,':') gt 0) then begin
;    w=str_sep(signal_in,':')
;    signal_in = w[0]
;    subchannel = w[1]
;  endif
;
;  ; signal name for saving is without subchannel
;  mod_sig = signal_full
;  ; Removing /,:,< from signal name
;  find_string=['/',':']
;  mod_sig=remove_characters(mod_sig,find_string)

  ;find out if JPF
  found=0
  mod_sig=signal_in
  find_string=['JPF/']
  mod_sig=remove_characters(mod_sig,find_string,found=found)
  if found EQ 1 then begin
    if file_test(file_which('getdat8.pro')) EQ 1 then begin
      data_source_in=26
      signal_in=mod_sig 
    endif else begin
      data_source_in=36
    endelse
  endif else begin
    ;find out if PPF
    find_string=['PPF/']
    mod_sig=remove_characters(mod_sig,find_string,found=found)
    if found EQ 1 then begin
      if file_test(file_which('ppfread.pro')) EQ 1 then begin
        data_source_in=27 
        signal_in=mod_sig 
      endif else begin
        data_source_in=36
      endelse
    endif else begin
      ;find out if APD
      find_string=['APD/']
      mod_sig=remove_characters(mod_sig,find_string,found=found)
      if found EQ 1 then begin
        data_source_in=33
        signal_in=mod_sig
      endif else begin
        ;find out if BES-
        find_string=['BES-']
        mod_sig=remove_characters(mod_sig,find_string,found=found)
        if found EQ 1 then begin
          data_source_in=33
        endif
      endelse
    endelse
  endelse
  if found EQ 1 then begin
  get_rawsignal,shot,signal_in,time,data,errorproc=errorproc,errormess=erroormess,$
    data_source=data_source_in,afs=afs,cdrom=cdrom,trange=trange,data_names=data_names,$
    nocalibrate=nocalibrate,calfac=calfac,sampletime=sampletime,equidist=equidist,$
    no_shift_correct=no_shift_correct,timerange=timerange,$
    correction_method=correction_method,p2_points=p2_points,$
    datapath=datapath,local_datapath=local_datapath,filename=filename,nodata=nodata,$
    subchannel=subchannel,chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
    vertical_norm=vertical_norm,vertical_zero=vertical_zero, store_data=store_data,$
    subch_mask=subch_mask,cache=cache,search_cache=search_cache,offset_timerange=offset_timerange,no_offset=no_offset,$
    filter_radiaton_pulses=radpulse_limit,no_time=no_time, data_tree=data_tree, $
    scaling=scaling, auguser=auguser, reserved=reserved,data_arr=data_arr,offset_type=offset_type, $
    offset_timelength=offset_timelength, sequence=sequence, ppfuid=ppfuid, reread=reread, quiet=quiet
  endif else begin
    print,'Channel name did not match, convention: "JET/JPF/SUBSYSTEM/NODE:CHANNEL" or "JET/PPF/..." or "JET/APD/BES-x-y" or "JET/APD/BES-x-y"...'
  endelse
endif ; data_source 41 JET general data reader

;******************* END of JET general data reader ***********************************


;******************* COMPASS BES ABP ********************
;***             Added 1st Dec. 2014 M. Lampert       ***
;********************************************************

if (data_source eq 42) then begin

;default,compass_trigger,0.94

  ; Checking for signal names BES-ADC<ch>
  ; If this is requested APDCAM ADC channels are read. <ch> is the ADC channel, 1...32
  if (strupcase(strmid(signal_in,0,4)) eq 'ADC-') then begin
    catch,error_catch
    if (error_catch eq 0) then begin
      chi = strmid(signal_in,4,2)
    endif else begin
      errormess = 'Invalid channel number in name ADC-xx.'
      return
    endelse
    catch,/cancel
  endif

  ; If chi is set it contains the channel number for a BES signal
  if (not defined(chi)) then begin
    errormess = 'Unknown COMPASS ABP channel.'
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

    if (subchannel ne 0) then begin
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


;load_config_parameter,shot,'Timing','StartTime',data_source=data_source,output_struct=s,$
;  datapath=datapath,errormess=e,/silent
;if (e eq '') then begin
;  starttime= s.value
;endif
;
;load_config_parameter,shot,'Timing','Trigger',data_source=data_source,output_struct=s,$
;  datapath=datapath,errormess=e,/silent
;if (e eq '') then begin
;  endtime= s.value
;endif
;
;load_config_parameter,shot,'Timing','EndTime',data_source=data_source,output_struct=s,$
;  datapath=datapath,errormess=e,/silent
;if (e eq '') then begin
;  compass_trigger= s.value
;endif
;
;load_config_parameter,shot,'Timing','SampleFreq',data_source=data_source,output_struct=s,$
;  datapath=datapath,errormess=e,/silent
;if (e eq '') then begin
;  samplefreq= s.value
;endif
;
;load_config_parameter,shot,'Timing','SampleNumber',data_source=data_source,output_struct=s,$
;  datapath=datapath,errormess=e,/silent
;if (e eq '') then begin
;  samplenumber= s.value
;endif
;
;load_config_parameter,shot,'ADCSettings','resolution',data_source=data_source,output_struct=s,$
;  datapath=datapath,errormess=e,/silent
;if (e eq '') then begin
;  bits= s.value
;endif



    ; These are the defaults in case any of these were missing. This can happen in very early shots.
    default,starttime,0
    default,endtime,1
    default,samplefreq,1
    default,samplenumber,long((endtime-starttime)*samplefreq*1e6)
    default,bits,14
    default,compass_trigger, 0.912
    ; Calculating sampletime
    sampletime = 1./(samplefreq*1e6)

    datafile = dir_f_name(dir_f_name(datapath,dir_f_name(i2str(shot),dir_f_name('data','ABP'))),'Channel'+i2str(chi-1,digits=2)+'.dat')

    ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! patch to work aroud corrupted XML
    a=file_info(datafile)
    samplenumber=a.size/2.
    samplefreq=samplenumber/1e6/long(endtime-starttime)
    sampletime = 1./(samplefreq*1e6)
    ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! patch to work aroud corrupted XML



    ; If trange is set we will read only the necesary samples
    if (n_elements(trange) eq 2) then begin
      samplenumber_start = long((trange[0]-compass_trigger)/sampletime)
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
    on_ioerror,loaderr_compass_apd
    a = assoc(unit,intarr(samplenumber_read),samplenumber_start*2)
    data = reform(a[0])
    ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! patch to work aroud corrupted XML
    print, max(data), min(data)
    if max(abs(data)) GE 4096 then begin
      bits=14
      print, 'WARNING: resolution calculated from signal amplitude, 14 bit applied'
    endif else begin
      bits=12
      print, 'WARNING: resolution calculated from signal amplitude, 12 bit applied'
    endelse
    ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! patch to work aroud corrupted XML
    
    if (not keyword_set(no_offset)) then begin
      ; Determining offset. The offset timerange comes from fluct_local_config
      offset_sample_start = long((offset_timerange[0]-compass_trigger)/sampletime) > 0
      offset_sample_end = long((offset_timerange[1]-compass_trigger)/sampletime) > 0
      if (offset_sample_end-offset_sample_start gt 0) then begin
        if (offset_sample_start ge samplenumber_start) and $
          (offset_sample_end le samplenumber_start+samplenumber_read-1) then begin
        ; if data is already read in
          offset = mean(data[offset_sample_start:offset_sample_end-1])
        endif else begin
          ; reading offset data
          on_ioerror,loaderr_offset_compass_apd
          a = assoc(unit,intarr(offset_sample_end-offset_sample_start+1),offset_sample_start*2)
          offset = mean(a[0])
        endelse
      endif else begin
        ; As a final resort we do not subtract offset
        offset = 0
      endelse
      data = data-offset
    endif ; offset correction

    close,unit & free_lun,unit
    ; Scaling to volts

    data = data*(2. / 2.^bits)
    time = dindgen(n_elements(data))*sampletime+starttime+compass_trigger+samplenumber_start*sampletime

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



      ;data calibration
      data=data/100/2e3*1e6 ;The signal in uA

    goto,get_rawsignal_end
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



endif

;******************* COMPASS BES ABP ********************


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
  if size(data,/n_dimensions) EQ 1 then data=data(ind) 
  if size(data,/n_dimensions) EQ 2 then data=data(*,ind)
endif

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

; Radiation pulse correction
if (defined(radpulse_limit) and not (data_source eq 28) and not keyword_set(subchannel)) then begin
  ; Processing only channels which are listed in radpulse_correction_channels in the local default file.
  ; This is a comma separated list of channel masks
  ch_mask = local_default('radpulse_correction_channels')
  if (ch_mask ne '') then begin
    ch_mask = strsplit(ch_mask,',',/extract)
    n_mask = n_elements(ch_mask)
    found = 0
    for i=0,n_mask-1 do begin
      if (strmatch(signal_in,ch_mask[i],/fold_case)) then found = 1
    endfor
    if (data_source eq 30) and (ch_mask eq 'all') then found = 1 ;MAST source ch_mask all is OK
    if (found) then begin
      filter_radiation_pulses,data,data_source=data_source,limit=radpulse_limit,n_pulses=n_pulses,subchannel=subchannel
      if (data_source eq 30) then print, 'radiation_pulses='+i2str(n_pulses)
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
