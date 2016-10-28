;==========================================================================================

;NTI_WAVELET_FLIPP.PRO

;-- This program runs, when NTI_WAVELET is called from the main menu of MTR
;-- All variable, which MTR read is stored in state variable
;==========================================================================================

pro nti_wavelet_flipp, shotnumber,signals, data_source=data_source,trange=trange,  $
    nocalibrate=nocalibrate,datapath=datapath,local_datapath=local_datapath,cache=cache, $
    search_cache=search_cache,data_names=data_names

;==========================================================================================
; To get a list of available data sources call:
; get_rawsignal,data_names=names
; After return <names> containes a string array, each string is the name of the
; associated data source.
; INPUT:
;  shotnumber: shot number
;  signals: string array of [<data source>/]<signal name> or numeric channel number (see chan_prefiox and chan_postfix)
;       <data_source> is any of the names returned in data_names. This overrides the
;          data_source input
;           Signal names for Li channels:   Li-xx
;           Signal names for Mirnov channels: Mir-<m>-<ch>  <m>: module  <ch>: channel
;  !!  Will return full signal name string (e.g. W7-AS Nicolet/Li-1) !!!!
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
;  trange: time range in sec (default: get all data)
;  /nocalibrate: do not calibrate signal (e.g. relative calibaration of Li channels)
;  /cache:  Store signal in signal cache using the full signal name (see signal_cache_add.pro)
;    cache='name'  Store signal in signal cache using name as signal name
;  /search_cache: Search cache for signal
;  datapath: Path for the datafile
;  local_datapath: The path for the directory where locally cached data are stored (see /store_data)
; OUTPUT:
;  time: time vector
;  data: data vector
;==========================================================================================
for i=0, n_elements(signals)-1 do begin
  get_rawsignal,shotnumber,signals[i],time,data, data_source=data_source,trange=trange,  $
    nocalibrate=nocalibrate,datapath=datapath,local_datapath=local_datapath,cache=cache, $
    search_cache=search_cache,data_names=data_names
  if i EQ 0 then begin
    data_array=fltarr(n_elements(data),n_elements(signals))
    time_array=fltarr(n_elements(time),n_elements(signals))
  endif
  data_array[*,i]=congrid(data,n_elements(data_array[*,0]))
  time_array[*,i]=congrid(time,n_elements(time_array[*,0]))
endfor
;Creating data_block for NTI WAVELET TOOLS (included all nescessarry information for modenumber calculations)
;------------------------------------------------------------------------------------------------------------
;Expeiment Name:
  expname=data_names[data_source]
;Shotnumber:
  shotnumber=shotnumber
;Signal name:
  signame=signals
;Data vector:
  data=data_array
;Time vector:
  time=time_array
;Theta
  theta=fltarr(n_elements(signals))
;Phi
  phi=fltarr(n_elements(signals))

;Calculate geometrical values:
;Here coordinate transformations are to be inserted for different diagnostics
coord_history = "Data loaded from FLIPP, no coordinate information automatically!!!"

;Creating the datablock structure: (This is the expected structure from NTI_WAVELET_GUI.PRO)
flipp_output = { $
;Signal features:
	expname : expname, $
	shotnumber : shotnumber, $
	channels : signals, $
	coord_history : coord_history, $
	data_history : "Loaded-with-FLIPP", $
;Data of signals:
	data : data, $
	time : time, $
	theta : theta, $
	phi : phi $
}

nti_wavelet_gui, input_structure=flipp_output, environment='flipp', event=event

end