; This function returns the BES location in Machine coordinate system

FUNCTION bes_read_position, shot, plot = plot, datapath=datapath, fusion01=fusion01, bes03=bes03, ijwkim=ijwkim
  
;******************************************************************************************************
; PROCEDUE : bes_read_position                                                                        *
; Author   : Young-chul Ghim                                                                          *
; Date     : 18th. Dec. 2012                                                                          *
;******************************************************************************************************
; PURPOSE  :                                                                                          *
;   1. To read the BES position in Machine coordinate system                                          *
;******************************************************************************************************
; INPUT parameters                                                                                    *
;     shot: <integer>: Shot number                                                                    *
; Keywords                                                                                            *
;     plot: 1 or 0: if 1, then plots the BES positions in R-Z plane                                   *
;     datapath: <string> contains the data path                                                       *
;     fusion01: 1 if the data is to be read from fusion01 server                                      *
;     bes03: 1 if the data is to be read from bes03 server on KSTAR                                   *
;     ijwkim: 1 if the data is to be read from ijwkim from fusion01 server                            *
;        NOTE: default location is fusion01                                                           *
;        NOTE: if the location information is incorrect, try to read it from ijwkim                   *
;******************************************************************************************************
; Return value                                                                                        *
;   It returns a strucutre:                                                                           *
;      result.err: if not 0 then, error occured; otherwise data are read successfully                 *
;                  if 1 then no spatial position                                                      *
;                  if 2 then spatial position is available, but other detailed infor is not available *
;      result.errmsg: contains error message if result.err is not 0,                                  *
;                     otherwise contains empty string                                                 *
;      result.data: three-dimensional, [4, 8, 3], array <floating>                                    *
;                    The first two dimensions correspond to the channels                              *
;                    [*, *, 0] contains R (major radius in [m])                                       *
;                    [*, *, 1] contains Z (height from the midplane in [m])                           *
;                    [*, *, 2] contains phi (angle from the centre of M-port, and                     *   
;                                           '+' is counter-clockwise in [degrees])                    *
;      result.orientation: if 0, then horizontal, i.e., 8 radial x 4 vertical                         *
;                          if 1, then vertical, i.e., 4 radial x 8 vertical                           *
;                          if -1, then unknown                                                        *
;******************************************************************************************************
; Examples                                                                                            *
;    d=bes_read_position(7800)                                                                        *
;******************************************************************************************************
;-Notes written on the 18th. Dec. 2012:                                                     *
;    As up today, data from shot number from 7092 and above (KSTAR 2012 Campaign) are stored          *
;    in /media/BES03D2, while data from previous shots are stored in /media/BES03.                    *
;    This routine should be used only for those shots from 7092 and above.                            *
;                                  								      *
;-Notes written on the 15th. July 2015:								      *
;    All the BES data until the 2014 Campaign is saved in the fusion01 server.                        *
;    The directory is /BES_DATA/. 								      *
;    (actually, we have saved the data in the separate 'data' server which are seen from fusion01.    *
;    To accommodate this data location, the code is updated.					      *
;******************************************************************************************************

  default, plot, 0

  result = {err:0, errmsg:''}

; During the 2014 KSTAR Campaing, BES channels are increased from 8x4 to 16x4 channels
  last_8by4_shot = 9427
  if shot LE last_8by4_shot then begin
    nradial = 8
    nvertical = 4
  endif else begin
    nradial = 16
    nvertical = 4
  endelse

  str_shotnumber = STRCOMPRESS(STRING(shot, format='(i0)'), /rem)
  if KEYWORD_SET(datapath) then begin
    fname = datapath + str_shotnumber + '/' + str_shotnumber + '.spat.cal'
    config_fname = datapath + str_shotnumber + '/' + str_shotnumber + '_config.xml'
  endif else begin
    if KEYWORD_SET(ijwkim) then begin
      fname = '/home/ijwkim/Research/KSTAR/BES/spatial_info/' + str_shotnumber + '.spat.cal'
      config_fname = '/home/ijwkim/Research/KSTAR/BES/spatial_info/' + str_shotnumber + '_config.xml'
    endif else if KEYWORD_SET(fusion01) then begin
      fname = '/BES_DATA/APDCAM/' + str_shotnumber + '/' + str_shotnumber + '.spat.cal'
      config_fname = '/BES_DATA/APDCAM/' + str_shotnumber + '/' + str_shotnumber + '_config.xml'
    endif else if KEYWORD_SET(bes03) then begin
      fname = '/media/DATA/APDCAM/' + str_shotnumber + '/' + str_shotnumber + '.spat.cal' 
      config_fname = '/media/DATA/APDCAM/' + str_shotnumber + '/' + str_shotnumber + '_config.xml'
    endif else begin
      fname = '/BES_DATA/APDCAM/' + str_shotnumber + '/' + str_shotnumber + '.spat.cal'
      config_fname = '/BES_DATA/APDCAM/' + str_shotnumber + '/' + str_shotnumber + '_config.xml'
    endelse
  endelse
  PRINT, 'Read BES position from ' + fname
  OPENR, inunit, fname, /get_lun, error=err

  if (err NE 0) then begin
  ;Error opengin the spatial calibration file
    result.err = 1
    result.errmsg = !ERROR_STATE.MSG
    print, 'Failed to load BES position data: ' + result.errmsg
    GOTO, RETURN_RESULT
  endif 

; Load the spatial positions
;  line = ''
; read the first line which contains the BES channel names, then discard.
;  READF, inunit, line
; read the second line which contains the R locations in [mm], then save them.
;  READF, inunit, line
;  R_mm = STRSPLIT(line, ' ', /extract)
;  R = LONG(R_mm[2:*])*1e-3 ;fisrt two elements contain just extra info. change the unit from mm to m while removing sub-mm accuracy.
; Read the third line which contains the Z locations in [mm], then save them.
;  READF, inunit, line
;  Z_mm = STRSPLIT(line, ' ', /extract)
;  Z = LONG(Z_mm[2:*])*1e-3 ;fisrt two elements contain just extra info. change the unit from mm to m while removing sub-mm accuracy.
; read the fourth line which contains the Phi locations in [radians], then save them.
;  READF, inunit, line
;  Phi = STRSPLIT(line, ' ', /extract)
;  Phi = Phi[2:*]*180.0/!PI

;It looks like the order of Z and Phi are changed.
;Before, Z was on the third line and Phis was on the fourth line.
;Now, Phis is on the third line and Z is on the fourth line.
;This is checked on the Oct. 8th, 2014.
;Thus, I change the code to check which component (R, Z or Phi) of BES position the line contains.

; Load the spatial positions
  line = ''
  num_lines = 4
  for i = 0, num_lines - 1 do begin
    READF, inunit, line
    temp_position = STRSPLIT(line, ' ', /extract)
    case STRUPCASE(temp_position[1]) of 
      'R'  : R = LONG(temp_position[2:*])*1e-3 ;fisrt two elements contain just extra info. change the unit from mm to m while removing sub-mm accuracy.
      'Z'  : Z = LONG(temp_position[2:*])*1e-3 ;fisrt two elements contain just extra info. change the unit from mm to m while removing sub-mm accuracy.
      'PHI': Phi = temp_position[2:*]*180.0/!PI
      else : 
    endcase
  endfor

; construct the data array
  data = FLTARR(nvertical, nradial, 3)
  for i = 0, nvertical-1 do begin
    data[i, *, 0] = R[i*nradial:(i+1)*nradial-1]
    data[i, *, 1] = Z[i*nradial:(i+1)*nradial-1]
    data[i, *, 2] = Phi[i*nradial:(i+1)*nradial-1]
  endfor
  FREE_LUN, inunit

  result = CREATE_STRUCT(result, 'data', data)

; Load the APD camera orientation (stored in shotnumber_config.xml file)
  oConfig = OBJ_NEW('IDLffXMLDOMDocument')
;  if KEYWORD_SET(fusion01) then begin
;    config_fname = datapath + '/' + str_shotnumber + '_config.xml'
;  endif else begin
;    config_fname = datapath + str_shotnumber + '/' + str_shotnumber + '_config.xml'
;  endelse
  oConfig->Load, filename = config_fname
  catch, xml_error
  if xml_error ne 0 then begin
    catch, /cancel
    OBJ_DESTROY, oConfig
    result.err = 2
    result.errmsg = 'Failed to open the configuration XML file to obtain APD camera orientation'
    result = CREATE_STRUCT(result, 'orientation', -1)
    GOTO, PLOT_RESULT
  endif

  oTags = oConfig->GetElementsByTagName('ShotSettings')
  if oTags->GetLength() eq 0 then begin
    OBJ_DESTROY, oConfig
    result.err = 2
    result.errmsg = 'Failed get Shot Settings from the configuration XML file to obtain APD camera orientation'
    result = CREATE_STRUCT(result, 'orientation', -1)
    GOTO, PLOT_RESULT
  endif

  oShotSettings = oTags->Item(0)
  oTags = oShotSettings->GetElementsByTagName('Optics')
  if oTags->GetLength() eq 0 then begin
    OBJ_DESTROY, oConfig
    result.err = 2
    result.errmsg = 'Failed get Optics from the configuration XML file to obtain APD camera orientation'
    result = CREATE_STRUCT(result, 'orientation', -1)
    GOTO, PLOT_RESULT  
  endif  
  
  oOptics = oTags->Item(0)
  oTags = oOptics->GetElementsByTagName('APDCAMPosition')
  if oTags->GetLength() eq 0 then begin
    OBJ_DESTROY, oConfig
    result.err = 2
    result.errmsg = 'Failed get APDCAM Position from the configuration XML file to obtain APD camera orientation'
    result = CREATE_STRUCT(result, 'orientation', -1)
    GOTO, PLOT_RESULT
  endif  

  oAPDCAMPos = oTags->Item(0)
  oAttributes = oAPDCAMPos->getAttributes()
  oVal = oAttributes->GetNamedItem('Value')
  APDCAMPos = oVal->GetNodeValue()
  CASE APDCAMPos of
    '12150' : orientation = 1 ;vertical orientation
    '30000' : orientation = 0 ;horizontal orientation
    ELSE: orientation = -1    ;unknown orientation
  ENDCASE
  OBJ_DESTROY, oConfig

  result = CREATE_STRUCT(result, 'orientation', orientation)

PLOT_RESULT:

; plot the BES positions
  if plot eq 1 then begin
    loadct, 5
    safe_colors, /first
    xmin = MIN(result.data[*, *, 0], MAX = xmax)
    xspan = xmax - xmin
    ymin = MIN(result.data[*, *, 1], MAX = ymax)
    yspan = ymax - ymin
    window, /free, xsize=800, ysize=600
    plot, result.data[*, *, 0], result.data[*, *, 1], xr=[xmin-xspan/3.0, xmax+xspan/3.0], yr=[ymin-yspan/3.0, ymax+yspan/3.0], $
          xtitle = 'Major R [m]', ytitle = 'Height Z [m]', title = STRING(shot, format='(i0)'), $
          /iso, xstyle=1, ystyle=1, psym=2, charsize=1.5
    for i=0, nvertical-1 do begin
      for j=0, nradial-1 do begin
        str_ch = STRING(i+1, format='(i0)')+ '-' + STRING(j+1, format='(i0)')
        xyouts, result.data[i, j, 0], result.data[i, j, 1]-0.005, str_ch, alignment = 0.5, charsize=1.0
      endfor
    endfor
  endif

RETURN_RESULT:

  RETURN, result

END
