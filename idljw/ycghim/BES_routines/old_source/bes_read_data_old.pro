;This function reads/saves the KSTAR BES data.

FUNCTION bes_read_data, shot, ch, trange=trange, freq_filter=freq_filter, filter_radiation_pulses=filter_radiation_pulses, fname=fname, $
                                  fusion01=fusion01, bes03=bes03
  
;******************************************************************************************************
; FUNCTION : bes_read_data                                                                            *
; Author   : Young-chul Ghim                                                                          *
; Date     : 10th. Dec. 2012                                                                          *
;******************************************************************************************************
; PURPOSE  :                                                                                          *
;   1. To read the BES data from a specified channel                                                  *
;   2. To save the BES data (allowed format: *.h5 or *.nc)                                            *
;        2.1. *.h5: hdf5 format (Hierarchical Data Format)                                            *
;        2.2. *.nc: NetCDF format                                                                     *
;******************************************************************************************************
; INPUT parameters                                                                                    *
;     shot: <integer>: Shot number                                                                    *
;       ch: <string>: channel number                                                                  *
;           example: '1-1', '3-2', '4-8'                                                              *
; Keywords                                                                                            *
;     trange: two element vector <floating>: time range to be read                                    *
;         if trange is not specified, then it reads from the shot start time to end time              *
;     freq_filter: two element vector <floating>: frequency range to be filtered in [Hz]              *
;     fname: scalar <string>: file name where the data is stored.                                     *
;         if not specified, then it does not save the data into a file                                *
;         fname must contains one of the following two extensions, .h5, or .nc                        *
;         Note: Once you saved a file, then this is one way to read the data from the file in IDL:    *
;              1. *.h5 format                                                                         *
;                 In IDL, type,                                                                       *
;                    IDL> s=h5_parse(fname, /read_data)                                               *
;                    IDL> bes = s.bes._data                                                           *
;                 Then, 'bes' contains all the information in strucuture format                       *
;              2. *.nc format                                                                         *
;                 In IDL, type,                                                                       *
;                    IDL> ncdf_browser, fname                                                         *
;                 Then, you will see a window (GUI-based) where you can see all the data              *
;     fusion01: <0 or 1> If this is set, then the data is read from fusion01.kaist.ac.kr server       *
;     bes03:    <0 or 1> If this is set, then the data is read from BES03 server on KSTAR             *
;        NOTE: default read location is fusion01                                                      *
;******************************************************************************************************
; Return value                                                                                        *
;   It returns a strucutre:                                                                           *
;      result.err: if 0 then, no error.                                                               *
;                  if < 0 then, fatal error, and BES data cannot be read.                             *
;                  if > 0 then, BES data is available, but BES position is not knownw.                *                  
;      result.errmsg: contains error message if result.err is not 0,                                  *
;                     otherwise contains empty string                                                 *
;      result.tvector: vector <floating>: contains time vector for BES data                           *
;      result.data: vector <floating>: contains data from a selected channel                          *
;      result.pos: three-element vector <floating>: contains BES location for selected channels       *
;                  result.pos[0] contains the position of major Radius in [m]                         *
;                  result.pos[1] contains the position of height from the midplane in [m]             *
;                  result.pos[2] contains the toroidal position in [degrees] from M-port centre       *          
;                                where + direction is couter-clockwise                                *
;      result.orientation: scalar <integer>                                                           *
;                  if 0 then horizontal view mode: 8 radial x 4 poloidal                              *
;                  if 1 then vertical view mode: 4 radial x 8 poloidal                                *
;******************************************************************************************************
; Exmples                                                                                             *
;    d=bes_read_data(7821, '3-4')                                                                     *
;    d=bes_read_data(7821, '1-8', trange=[1.3, 4.6], fsave='shot7821_ch1_8.h5')                       *
;******************************************************************************************************

; initiate the reulst structure
  result = {err:0, errmsg:''}

; select the machine to read the data from (fusion01 from KAIST or BES03 from NFRI)
  if (NOT KEYWORD_SET(fusion01)) AND KEYWORD_SET(bes03) then begin
    fusion01 = 0
    bes03 = 1
  endif else begin
    fusion01 = 1
    bes03 = 0
  endelse

; set datapath and data source
  if fusion01 eq 1 then begin
    datapath = '/home/ycghim/Research/KSTAR/BES/raw_data/'
  endif else begin
    datapath = '/media/DATA/APDCAM/'
  endelse 

  data_source = 32 ;for KSTAR
  default, filter_radiation_pulses, 0.02
  default, freq_filter, [0.0, 1.0e6]
  default, dt, 0.5e-6

; get the channel indicies
  ch_inx = FIX(STRSPLIT(ch, '-', /EXTRACT))
  inx0 = ch_inx[0] - 1
  inx1 = ch_inx[1] - 1

; set the BES channel name
  ch_name = 'BES-' + ch

; get the data
  PRINT, 'Reading ' + ch_name + ' data...', format='(A,$)'
  get_rawsignal, shot, ch_name, t, d, data_source = data_source, datapath=datapath, timerange=trange, /nocalibrate, errormess=errmsg
  PRINT, 'Done!'
  if (errmsg ne '') then begin
    result.err = -1
    result.errmsg = errmsg
    GOTO, RETURN_RESULT    
  endif

; Filter the radiation induced spikes
  bes_filter_radiation, d, limit=filter_radiation_pulses    


; Frequency filter the signal
  PRINT, 'Frequency filtering: [' + string(freq_filter[0]/1e3, format='(f0.1)') + ', ' + string(freq_filter[1]/1e3, format='(f0.1)') + '] kHz'
  filtered_data_struct = yc_freq_filter(d, dt, freq_filter[0], freq_filter[1])
  inx_start = filtered_data_struct.inx_nonzero_begin
  inx_end = filtered_data_struct.inx_nonzero_end
  d = filtered_data_struct.data[inx_start:inx_end]
  t = t[inx_start:inx_end]

  result = CREATE_STRUCT(result, 'channel', ch, 'tvector', t, 'data', d)

; get the BES location
  bes_pos = bes_read_position(shot, datapath=datapath) 
  if bes_pos.err ne 0 then begin
    result.err = 1
    result.errmsg = bes_pos.errmsg
  endif else begin
    pos = REFORM(bes_pos.data[inx0, inx1, *])
    result = CREATE_STRUCT(result, 'pos', pos, 'orientation', bes_pos.orientation)
  endelse

; save the data
  if KEYWORD_SET(fname) then begin
    PRINT, 'Saving the data...', format='(A,$)'
  ; get the extension
    extension_inx = STRPOS(fname, '.', /REVERSE_SEARCH)
    extension = STRMID(fname, extension_inx)
    case extension of
      '.h5' : begin ;save the data in *.hdf5 format
        sdata = CREATE_STRUCT('channel', result.channel, 'tvector', result.tvector, 'data', result.data)
        if result.err eq 0 then begin
          sdata = CREATE_STRUCT(sdata, 'pos', result.pos, 'orientation', result.orientation)
        endif
        fileID = H5F_CREATE(fname)
        datatypeID = H5T_IDL_CREATE(sdata)
        dataspaceID = H5S_CREATE_SIMPLE(1)          
        datasetID = H5D_CREATE(fileID, 'BES', datatypeID, dataspaceID)
        H5D_WRITE, datasetID, sdata
        H5F_CLOSE, fileID
      end
      '.nc' : begin
        ID = NCDF_CREATE(fname, /NOCLOBBER) ;Create a new NetCDF file with the file name fname
        NCDF_CONTROL, ID, /FILL ;Fill the file with default values
        ch_dim_ID = NCDF_DIMDEF(ID, 'Ch_Length', STRLEN(ch)) ;Make dimension for channel
        data_dim_ID = NCDF_DIMDEF(ID, 'Data_Npts', SIZE(result.tvector, /DIM)) ;Make dimension for tvector and data
        if result.err eq 0 then begin
          pos_dim_ID = NCDF_DIMDEF(ID, 'Position_Npts', SIZE(result.pos, /DIM)) ;Make dimension for position
          orientation_dim_ID = NCDF_DIMDEF(ID,'Orientation_Npts', 1) ;Make dimension for orientation
        endif
      ; Define variable
        chID = NCDF_VARDEF(ID, 'channel', [ch_dim_ID], /CHAR)
        NCDF_ATTPUT, ID, chID, 'Type', 'String'
        NCDF_ATTPUT, ID, chID, 'Description', 'BES channel number'
        tvectorID = NCDF_VARDEF(ID, 'tvector', [data_dim_ID], /DOUBLE)
        NCDF_ATTPUT, ID, tvectorID, 'Type', 'Double'
        NCDF_ATTPUT, ID, tvectorID, 'Description', 'Time vector'
        dataID = NCDF_VARDEF(ID, 'data', [data_dim_ID], /DOUBLE)
        NCDF_ATTPUT, ID, dataID, 'Type', 'Double'
        NCDF_ATTPUT, ID, dataID, 'Description', 'Raw BES data in [volts]'
        if result.err eq 0 then begin
          posID = NCDF_VARDEF(ID, 'pos', [pos_dim_ID], /FLOAT)
          NCDF_ATTPUT, ID, posID, 'Type', 'Float'
          NCDF_ATTPUT, ID, posID, 'Description', 'BES position: R [m], Z [m] and Toroidal location [rad]'
          orientationID = NCDF_VARDEF(ID, 'orientation', [orientation_dim_ID], /LONG)
          NCDF_ATTPUT, ID, orientationID, 'Type', 'Long'
          NCDF_ATTPUT, ID, orientationID, 'Description', 'If 0 then horizontal viewing mode; if 1 then vertical viewing mode'
        endif
      ; Put file in data mode
        NCDF_CONTROL, ID, /ENDEF
      ; Input data
        NCDF_VARPUT, ID, chID, result.channel
        NCDF_VARPUT, ID, tvectorID, result.tvector
        NCDF_VARPUT, ID, dataID, result.data
        if result.err eq 0 then begin
          NCDF_VARPUT, ID, posID, result.pos
          NCDF_VARPUT, ID, orientationID, result.orientation
        endif
        NCDF_CLOSE, ID
      end
      else: PRINT, 'Specified file format is illegal.  Use *.h5 or *.nc format.'
    endcase
    PRINT, 'Done!'
  endif

RETURN_RESULT:

  RETURN, result

END
