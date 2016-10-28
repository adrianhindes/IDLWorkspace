function mast_bes_read_apd_setting, shot

; define return variable structure
  result = {erc:0l, $		;error number.  This is 0, if no error occured.
            errmsg:'', $	;string of error message if erc is not 0.
            dt:0.0, $		;BES sampling time in [seconds]
            APD_bias:0.0, $	;BES APD Bias voltage in [V]
            viewRadius:0.0}	;BES Viewing Radius (for the centre of the APD camera) in [m]


; Define the NETCDF filename to read APD camera settings
  suff = '.nc'
  str1 = strtrim(string(shot, format='(i0)'), 2)
  pre = '$MAST_DATA/' + str1 + '/LATEST/xbt'
  dir = ''
  str2 = '000000'
  strput, str2, str1, 6-strlen(str1)
  filename = 'NETCDF::' + dir + pre + str2 + suff

; get the clock speed (sampling time of the BES data)
  str_dev_loc = '/devices/d3_APDcamera/clock'
  ds = getdata(str_dev_loc, filename)
  if ds.erc ne 0 then begin
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  dt = ds.data[0]
  result.dt = dt

; get the APD Bias voltage
  str_dev_loc = '/devices/d3_APDcamera/bias'
  ds = getdata(str_dev_loc, filename)
  if ds.erc ne 0 then begin
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  APD_bias = ds.data[0]
  result.APD_bias = APD_bias

; get the APD camera location.
;  The viewing location is the raidal location of the center of the APD camera.
  str_dev_loc = '/devices/d4_mirror/viewRadius'
  ds = getdata(str_dev_loc, filename)
  if ds.erc ne 0 then begin
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif
  viewRadius = ds.data[0]
  result.viewRadius = viewRadius

  return, result

end
